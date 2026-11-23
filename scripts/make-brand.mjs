// Renders the channel icons and splash screen from design/brand/logo.svg
// with headless Microsoft Edge (or Chrome), so the wordmark uses the app's
// own Space Grotesk. Run with `npm run brand` after changing the logo.
// The in-app mark (images/icon_logo.png) is drawn by make-images.mjs.
import { readFileSync, writeFileSync, mkdtempSync, existsSync, copyFileSync, rmSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { root } from './env.mjs';

const BG = '#0B0D12'; // Midnight, the default Theme (and the manifest's splash_color)
const TEXT = '#F2F3F5';

const browsers = [
    'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe',
    'C:/Program Files/Microsoft/Edge/Application/msedge.exe',
    'C:/Program Files/Google/Chrome/Application/chrome.exe',
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/usr/bin/google-chrome',
    '/usr/bin/chromium',
];
const browser = browsers.find((b) => existsSync(b));
if (!browser) {
    console.error('Needs Microsoft Edge or Google Chrome to render the images.');
    process.exit(1);
}

const svg = readFileSync(path.join(root, 'design/brand/logo.svg'), 'utf8');
const font = pathToFileURL(path.join(root, 'fonts/SpaceGrotesk-Bold.ttf')).href;
const work = mkdtempSync(path.join(tmpdir(), 'matinee-brand-'));

// markH: height of the ticket; text: wordmark size (0 for none); stack:
// wordmark under the mark instead of beside it.
function page(w, h, markH, text, stack) {
    const gap = stack ? Math.round(markH * 0.28) : Math.round(markH * 0.3);
    return `<!doctype html><html><head><style>
@font-face { font-family: Brand; src: url('${font}'); }
html, body { margin: 0; width: ${w}px; height: ${h}px; background: ${BG}; overflow: hidden; }
body { display: flex; flex-direction: ${stack ? 'column' : 'row'}; align-items: center; justify-content: center; gap: ${gap}px; }
svg { height: ${markH}px; width: auto; display: block; }
span { font: ${text}px Brand; color: ${TEXT}; letter-spacing: ${(text * 0.08).toFixed(1)}px; line-height: 1; padding-left: ${(text * 0.08).toFixed(1)}px; }
</style></head><body>${svg}${text ? '<span>MATINEE</span>' : ''}</body></html>`;
}

function render(name, w, h, markH, text, stack) {
    const html = path.join(work, `${name}.html`);
    writeFileSync(html, page(w, h, markH, text, stack));
    const out = path.join(work, `${name}.png`);
    execFileSync(browser, [
        '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1', '--disable-lcd-text',
        `--window-size=${w},${h}`, `--screenshot=${out}`, pathToFileURL(html).href,
    ], { stdio: 'ignore' });
    copyFileSync(out, path.join(root, 'images', name));
    console.log(`images/${name} (${w}x${h})`);
}

render('icon_hd.png', 336, 210, 74, 34, true);
render('icon_sd.png', 248, 140, 50, 24, true);
render('splash_fhd.png', 1920, 1080, 260, 88, true);
rmSync(work, { recursive: true, force: true });
