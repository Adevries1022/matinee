// Makes short synthetic clips into samples/ for playback testing: one file
// per codec, audio or subtitle case that Roku clients tend to get wrong.
// Needs ffmpeg and ffprobe on PATH. Run with `npm run samples`.
// See docs/testing-playback.md for what each clip tests.
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync, writeFileSync, rmSync } from 'node:fs';
import path from 'node:path';
import { root } from './env.mjs';

const OUT = path.join(root, 'samples');
const SRC = path.join(OUT, '.src');
const SECONDS = 20;
const LONG_SECONDS = 30 * 60;

function run(cmd, args) {
    return spawnSync(cmd, args, { encoding: 'utf8', maxBuffer: 64 * 1024 * 1024 });
}

for (const tool of ['ffmpeg', 'ffprobe']) {
    const r = run(tool, ['-version']);
    if (r.error || r.status !== 0) {
        console.error(`${tool} isn't on PATH. Install FFmpeg, open a new terminal, and run this again:`);
        console.error('  winget install Gyan.FFmpeg');
        process.exit(1);
    }
}

const encoders = run('ffmpeg', ['-hide_banner', '-encoders']).stdout;
const filters = run('ffmpeg', ['-hide_banner', '-filters']).stdout;
const hasEncoder = (name) => new RegExp(`^\\s\\S{6}\\s${name}\\s`, 'm').test(encoders);
const hasDrawtext = /\sdrawtext\s/.test(filters);

mkdirSync(SRC, { recursive: true });

// ---------- Video and audio sources ----------

// A burned-in label, frame number and clock, so seeks are easy to see.
function fontPart() {
    const arial = 'C:/Windows/Fonts/arial.ttf';
    if (existsSync(arial)) return "fontfile='C\\:/Windows/Fonts/arial.ttf'";
    return 'font=Sans';
}
function videoFilter(label) {
    if (!hasDrawtext) return 'null';
    const f = fontPart();
    const box = 'box=1:boxcolor=black@0.6:boxborderw=12:fontcolor=white';
    return [
        `drawtext=${f}:${box}:fontsize=h/14:x=(w-tw)/2:y=h/12:text='${label}'`,
        `drawtext=${f}:${box}:fontsize=h/10:x=(w-tw)/2:y=h-th-h/8:text='frame %{n}   %{pts\\:hms}'`,
    ].join(',');
}
function videoInput(size, seconds) {
    return ['-f', 'lavfi', '-i', `testsrc2=size=${size}:rate=24:duration=${seconds}`];
}

// A different tone per channel, so a wrong channel map can be heard.
const TONES = [440, 550, 660, 220, 330, 770];
function audioInput(layout, seconds) {
    const n = layout === 'stereo' ? 2 : 6;
    const expr = TONES.slice(0, n).map((hz) => `0.25*sin(${hz}*2*PI*t)`).join('|');
    return ['-f', 'lavfi', '-i', `aevalsrc=${expr}:s=48000:c=${layout}:d=${seconds}`];
}

const H264 = ['-c:v', 'libx264', '-preset', 'veryfast', '-pix_fmt', 'yuv420p', '-b:v', '2500k', '-g', '48'];
const H264_10 = ['-c:v', 'libx264', '-preset', 'veryfast', '-pix_fmt', 'yuv420p10le', '-profile:v', 'high10', '-b:v', '2500k', '-g', '48'];
const HEVC = ['-c:v', 'libx265', '-preset', 'fast', '-pix_fmt', 'yuv420p', '-b:v', '2000k', '-tag:v', 'hvc1', '-x265-params', 'log-level=error:keyint=48'];
const HDR10 = [
    '-c:v', 'libx265', '-preset', 'fast', '-pix_fmt', 'yuv420p10le', '-profile:v', 'main10', '-b:v', '2500k', '-tag:v', 'hvc1',
    '-color_primaries', 'bt2020', '-color_trc', 'smpte2084', '-colorspace', 'bt2020nc',
    '-x265-params',
    'log-level=error:keyint=48:hdr10=1:colorprim=bt2020:transfer=smpte2084:colormatrix=bt2020nc:' +
        'master-display=G(13250,34500)B(7500,3000)R(34000,16000)WP(15635,16450)L(10000000,1):max-cll=1000,400',
];
function av1() {
    if (hasEncoder('libsvtav1')) return ['-c:v', 'libsvtav1', '-preset', '10', '-b:v', '1500k', '-g', '48'];
    if (hasEncoder('libaom-av1')) return ['-c:v', 'libaom-av1', '-cpu-used', '8', '-row-mt', '1', '-b:v', '1500k', '-g', '48'];
    return null;
}
const AAC2 = ['-c:a', 'aac', '-b:a', '160k'];
const AAC6 = ['-c:a', 'aac', '-b:a', '384k'];

// ---------- Subtitles ----------

function srtFile(name, text, count) {
    let body = '';
    for (let i = 0; i < count; i++) {
        const from = i * 4 + 1;
        const ts = (s) => `00:00:${String(s).padStart(2, '0')},000`;
        body += `${i + 1}\r\n${ts(from)} --> ${ts(from + 2)}\r\n${text} (line ${i + 1})\r\n\r\n`;
    }
    const file = path.join(SRC, name);
    writeFileSync(file, body);
    return file;
}
function assFile(name, text, color) {
    let events = '';
    for (let i = 0; i < 5; i++) {
        const from = i * 4 + 1;
        events += `Dialogue: 0,0:00:${String(from).padStart(2, '0')}.00,0:00:${String(from + 2).padStart(2, '0')}.00,Default,,0,0,0,,${text} (line ${i + 1})\r\n`;
    }
    const body = [
        '[Script Info]', 'ScriptType: v4.00+', 'PlayResX: 1920', 'PlayResY: 1080', '',
        '[V4+ Styles]',
        'Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding',
        `Style: Default,Arial,64,${color},&H000000FF,&H00000000,&H80000000,0,0,0,0,100,100,0,0,1,3,1,2,40,40,60,1`,
        '',
        '[Events]',
        'Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text',
        events,
    ].join('\r\n');
    const file = path.join(SRC, name);
    writeFileSync(file, body);
    return file;
}

// ---------- The samples ----------

const samples = [
    { file: '01-h264-aac-stereo.mp4', label: '01 H.264 AAC stereo MP4', video: H264, audio: AAC2, layout: 'stereo', extra: ['-movflags', '+faststart'] },
    { file: '02-h264-aac-5.1.mkv', label: '02 H.264 AAC 5.1', video: H264, audio: AAC6, layout: '5.1' },
    { file: '03-h264-eac3-5.1.mkv', label: '03 H.264 EAC3 5.1', video: H264, audio: ['-c:a', 'eac3', '-b:a', '640k'], layout: '5.1' },
    { file: '04-h264-dts-5.1.mkv', label: '04 H.264 DTS 5.1', video: H264, audio: ['-c:a', 'dca', '-strict', '-2'], layout: '5.1', needs: 'dca' },
    { file: '05-h264-truehd-5.1.mkv', label: '05 H.264 TrueHD 5.1', video: H264, audio: ['-c:a', 'truehd', '-strict', '-2'], layout: '5.1', needs: 'truehd' },
    { file: '06-h264-10bit.mkv', label: '06 H.264 10-bit', video: H264_10, audio: AAC2, layout: 'stereo' },
    { file: '07-hevc-8bit.mkv', label: '07 HEVC 8-bit', video: HEVC, audio: AAC2, layout: 'stereo', needs: 'libx265' },
    { file: '08-hevc-10bit-hdr10.mkv', label: '08 HEVC 10-bit HDR10', video: HDR10, audio: AAC2, layout: 'stereo', needs: 'libx265' },
    { file: '09-av1.mkv', label: '09 AV1', video: av1(), audio: AAC2, layout: 'stereo' },
    {
        file: '10-subs-2ass-2srt.mkv', label: '10 Two ASS and two SRT tracks', video: H264, audio: AAC2, layout: 'stereo',
        subs: [
            { path: assFile('ass-a.ass', 'ASS track A - English - yellow', '&H0000FFFF'), codec: 'ass', lang: 'eng', title: 'ASS A (English)', disposition: 'default' },
            { path: assFile('ass-b.ass', 'ASS track B - French - cyan', '&H00FFFF00'), codec: 'ass', lang: 'fre', title: 'ASS B (French)', disposition: '0' },
            { path: srtFile('srt-c.srt', 'SRT track C - English', 5), codec: 'srt', lang: 'eng', title: 'SRT C (English)', disposition: '0' },
            { path: srtFile('srt-d.srt', 'SRT track D - Spanish', 5), codec: 'srt', lang: 'spa', title: 'SRT D (Spanish)', disposition: '0' },
        ],
    },
    {
        file: '11-srt-forced-english.mkv', label: '11 Forced English SRT', video: H264, audio: AAC2, layout: 'stereo',
        subs: [
            { path: srtFile('srt-forced.srt', 'FORCED English line', 3), codec: 'srt', lang: 'eng', title: 'English (Forced)', disposition: 'forced' },
        ],
    },
    {
        file: '12-h264-30min-lowbitrate.mkv', label: '12 H.264 30 min seek test', size: '426x240', seconds: LONG_SECONDS,
        video: ['-c:v', 'libx264', '-preset', 'veryfast', '-pix_fmt', 'yuv420p', '-b:v', '150k', '-maxrate', '250k', '-bufsize', '500k', '-g', '48'],
        audio: ['-c:a', 'aac', '-b:a', '64k'], layout: 'stereo',
    },
];

function build(s) {
    const seconds = s.seconds ?? SECONDS;
    const args = ['-hide_banner', '-loglevel', 'error', '-y', ...videoInput(s.size ?? '1280x720', seconds), ...audioInput(s.layout, seconds)];
    const subs = s.subs ?? [];
    for (const sub of subs) args.push('-i', sub.path);
    args.push('-map', '0:v', '-map', '1:a');
    subs.forEach((_, i) => args.push('-map', `${i + 2}:s`));
    args.push('-vf', videoFilter(s.label), ...s.video, ...s.audio);
    args.push('-metadata', `title=${s.label}`, '-metadata:s:a:0', 'language=eng');
    subs.forEach((sub, i) => {
        args.push(`-c:s:${i}`, sub.codec, `-metadata:s:s:${i}`, `language=${sub.lang}`, `-metadata:s:s:${i}`, `title=${sub.title}`, `-disposition:s:${i}`, sub.disposition);
    });
    args.push(...(s.extra ?? []), '-t', String(seconds), path.join(OUT, s.file));
    return run('ffmpeg', args);
}

const made = [];
const skipped = [];
for (const s of samples) {
    if (!s.video) {
        skipped.push(`${s.file}: this ffmpeg has no AV1 encoder (libsvtav1 or libaom-av1)`);
        continue;
    }
    if (s.needs && !hasEncoder(s.needs)) {
        skipped.push(`${s.file}: this ffmpeg has no ${s.needs} encoder`);
        continue;
    }
    process.stdout.write(`Making ${s.file}${s.seconds ? ' (30 minutes, takes a while)' : ''}... `);
    const r = build(s);
    if (r.status !== 0) {
        console.log('failed');
        rmSync(path.join(OUT, s.file), { force: true });
        skipped.push(`${s.file}: ffmpeg failed: ${(r.stderr || '').trim().split('\n').slice(-2).join(' ')}`);
        continue;
    }
    const probe = run('ffprobe', ['-v', 'error', '-show_entries', 'stream=codec_type,codec_name,profile,pix_fmt,channel_layout', '-of', 'compact=p=0:nk=1', path.join(OUT, s.file)]);
    console.log('done');
    made.push(`${s.file}\n    ${probe.stdout.trim().split(/\r?\n/).join('\n    ')}`);
}
rmSync(SRC, { recursive: true, force: true });

if (!hasDrawtext) console.log('\nNote: this ffmpeg has no drawtext filter, so clips have no burned-in frame counter.');
console.log(`\nMade ${made.length} samples in ${OUT}:`);
for (const m of made) console.log(`  ${m}`);
if (skipped.length) {
    console.log('\nSkipped:');
    for (const m of skipped) console.log(`  ${m}`);
}
