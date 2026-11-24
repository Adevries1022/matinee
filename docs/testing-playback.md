# Testing playback

A set of short synthetic clips, one per case that Roku clients often get wrong. Use them to check that Matinee direct-plays what the Roku can play, transcodes the rest, and picks the right subtitle track.

## Make the samples

1. Install FFmpeg once: `winget install Gyan.FFmpeg`, then open a new terminal.
2. Run `npm run samples`. Clips go to `samples/` (gitignored). The 30-minute clip takes a few minutes; the rest take seconds.

Every clip shows its name, the frame number and the clock burned into the picture, so a seek lands where you can see it. Audio is a different tone per channel (440, 550, 660, 220, 330, 770 Hz for L, R, C, LFE, Ls, Rs), so a wrong channel map is audible. If the local FFmpeg lacks an encoder (TrueHD, DTS, HEVC or AV1), that clip is skipped and the script says so.

## What each sample tests

"Audio transcode" means Jellyfin copies the video and converts only the audio. Matinee logs both that and a full transcode as `Transcode`; the Jellyfin dashboard (Dashboard → Activity, or the playing session's info) shows which it was and why.

| File | Tests | Expected in Matinee |
|---|---|---|
| `01-h264-aac-stereo.mp4` | Baseline | Direct play |
| `02-h264-aac-5.1.mkv` | Multichannel AAC in MKV | Direct play |
| `03-h264-eac3-5.1.mkv` | EAC3 5.1 | Direct play if the Roku reports EAC3 (TV or receiver), otherwise audio transcode |
| `04-h264-dts-5.1.mkv` | DTS (not in Matinee's device profile) | Audio transcode to AC3 5.1 (or AAC stereo if the Roku has no AC3) |
| `05-h264-truehd-5.1.mkv` | TrueHD | Audio transcode, as for DTS |
| `06-h264-10bit.mkv` | H.264 High 10, which Roku can't decode | Transcode. The device profile doesn't list bit-depth limits yet, so watch for a direct play that fails or shows a black picture |
| `07-hevc-8bit.mkv` | HEVC | Direct play on Rokus that decode HEVC (the TCL 55R655 does), transcode on the rest |
| `08-hevc-10bit-hdr10.mkv` | HEVC Main 10 with HDR10 tags | Direct play with the TV switching to HDR on an HDR Roku; transcode elsewhere (colors will look flat, as there's no tone mapping in the clip) |
| `09-av1.mkv` | AV1 (not in the device profile) | Transcode |
| `10-subs-2ass-2srt.mkv` | Two ASS tracks (A English, yellow; B French, cyan) and two SRT tracks (C English, D Spanish), A is default | With Subtitles on Auto: ASS A shows (each line names its track). Switching to B, C or D in the player shows that track's text. Direct play keeps going; text subtitles are drawn by the Roku as WebVTT, so ASS styling (color) is lost |
| `11-srt-forced-english.mkv` | One forced English SRT | Jellyfin marks it forced; the track picker labels it "(Forced)". With Subtitles on Auto it should show its "FORCED" lines |
| `12-h264-30min-lowbitrate.mkv` | 30 minutes at 240p, ~150 kbps | Seek while transcoding: set Settings → Playback & quality → Direct play to "Always transcode", then jump forward and back several minutes. The picture's clock should match the seek bar, with sound in sync |

## Add them to Jellyfin

1. Copy `samples/` to a folder the Jellyfin server can read (or point the library at it directly if Jellyfin runs on this PC).
2. Dashboard → Libraries → Add Media Library. Content type: Movies (or Mixed Movies and Shows). Display name: "Playback tests". Add the folder; turn off metadata downloaders and image fetchers so the clips keep their own names.
3. Hide it from other users: Dashboard → Users → each other user → Access → untick "Playback tests" (or untick "Enable access to all libraries" and pick theirs).
4. Scan the library. Each clip appears under its file name.

## Check the results

Run `npm run logs` while playing each clip. Matinee prints lines starting with `[Matinee] player:`, for example:

```
[Matinee] player: playing after 1840 ms at 0 s (DirectPlay)
```

The word in brackets is the play method, `DirectPlay` or `Transcode`. A `warmed transcode` line appears when a transcode starts partway in. Compare against the table above, and listen and look for what the logs can't show: the right tone in each speaker, the right subtitle text, the clock after a seek.
