// Draws Matinee's icons and shapes into images/ as white PNGs, which the
// app tints with blendColor. Run with `npm run images` after changing a shape.
// Icons use the 24-unit geometry of the Lumen design boards.
import { deflateSync } from 'node:zlib';
import { writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { root } from './env.mjs';

const OUT = path.join(root, 'images');
const SS = 4; // supersampling per axis

// ---------- PNG ----------
const crcTable = new Uint32Array(256).map((_, n) => {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    return c >>> 0;
});
function crc32(buf) {
    let c = 0xffffffff;
    for (const b of buf) c = crcTable[(c ^ b) & 0xff] ^ (c >>> 8);
    return (c ^ 0xffffffff) >>> 0;
}
function chunk(kind, data) {
    const len = Buffer.alloc(4);
    len.writeUInt32BE(data.length);
    const body = Buffer.concat([Buffer.from(kind, 'ascii'), data]);
    const crc = Buffer.alloc(4);
    crc.writeUInt32BE(crc32(body));
    return Buffer.concat([len, body, crc]);
}
// rgba: Uint8Array of w*h*4
function png(w, h, rgba) {
    const raw = Buffer.alloc((w * 4 + 1) * h);
    for (let y = 0; y < h; y++) {
        raw[y * (w * 4 + 1)] = 0;
        Buffer.from(rgba.buffer, y * w * 4, w * 4).copy(raw, y * (w * 4 + 1) + 1);
    }
    const ihdr = Buffer.alloc(13);
    ihdr.writeUInt32BE(w, 0);
    ihdr.writeUInt32BE(h, 4);
    ihdr[8] = 8;
    ihdr[9] = 6;
    return Buffer.concat([
        Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
        chunk('IHDR', ihdr),
        chunk('IDAT', deflateSync(raw, { level: 9 })),
        chunk('IEND', Buffer.alloc(0)),
    ]);
}

// ---------- Geometry (signed distance, negative inside) ----------
const hypot = Math.hypot;
function segDist(px, py, ax, ay, bx, by) {
    const dx = bx - ax, dy = by - ay;
    const l2 = dx * dx + dy * dy;
    let t = l2 ? ((px - ax) * dx + (py - ay) * dy) / l2 : 0;
    t = Math.max(0, Math.min(1, t));
    return hypot(px - (ax + t * dx), py - (ay + t * dy));
}
function inPoly(px, py, pts) {
    let inside = false;
    for (let i = 0, j = pts.length - 1; i < pts.length; j = i++) {
        const [xi, yi] = pts[i], [xj, yj] = pts[j];
        if ((yi > py) !== (yj > py) && px < ((xj - xi) * (py - yi)) / (yj - yi) + xi) inside = !inside;
    }
    return inside;
}
function roundRectSd(px, py, x, y, w, h, r) {
    const cx = x + w / 2, cy = y + h / 2;
    const qx = Math.abs(px - cx) - (w / 2 - r);
    const qy = Math.abs(py - cy) - (h / 2 - r);
    return hypot(Math.max(qx, 0), Math.max(qy, 0)) + Math.min(Math.max(qx, qy), 0) - r;
}
function angleIn(a, a0, a1) {
    // is angle a (deg) within [a0, a1] going counter-clockwise from a0 to a1
    const norm = (v) => ((v % 360) + 360) % 360;
    const span = norm(a1 - a0);
    return norm(a - a0) <= span;
}

// Primitives. Each returns a function (x, y) => covered? in its own units.
const P = {
    line: (x1, y1, x2, y2, w) => (x, y) => segDist(x, y, x1, y1, x2, y2) <= w / 2,
    poly: (pts, w, closed = false) => (x, y) => {
        const n = closed ? pts.length : pts.length - 1;
        for (let i = 0; i < n; i++) {
            const [ax, ay] = pts[i], [bx, by] = pts[(i + 1) % pts.length];
            if (segDist(x, y, ax, ay, bx, by) <= w / 2) return true;
        }
        return false;
    },
    fillPoly: (pts) => (x, y) => inPoly(x, y, pts),
    circle: (cx, cy, r, w) => (x, y) => Math.abs(hypot(x - cx, y - cy) - r) <= w / 2,
    fillCircle: (cx, cy, r) => (x, y) => hypot(x - cx, y - cy) <= r,
    ellipse: (cx, cy, rx, ry, w) => (x, y) => {
        // approximate stroke of an ellipse by normalised distance
        const k = hypot((x - cx) / rx, (y - cy) / ry);
        const d = (k - 1) * Math.min(rx, ry);
        return Math.abs(d) <= w / 2;
    },
    // Arc from a0 to a1 degrees (counter-clockwise on screen means decreasing y-down angle;
    // here angles are standard atan2 in y-down space, swept increasing from a0 to a1).
    arc: (cx, cy, r, a0, a1, w) => (x, y) => {
        const a = (Math.atan2(y - cy, x - cx) * 180) / Math.PI;
        if (angleIn(a, a0, a1)) return Math.abs(hypot(x - cx, y - cy) - r) <= w / 2;
        const e0 = [cx + r * Math.cos((a0 * Math.PI) / 180), cy + r * Math.sin((a0 * Math.PI) / 180)];
        const e1 = [cx + r * Math.cos((a1 * Math.PI) / 180), cy + r * Math.sin((a1 * Math.PI) / 180)];
        return hypot(x - e0[0], y - e0[1]) <= w / 2 || hypot(x - e1[0], y - e1[1]) <= w / 2;
    },
    rect: (x0, y0, w0, h0, r, w) => (x, y) => Math.abs(roundRectSd(x, y, x0, y0, w0, h0, r)) <= w / 2,
    fillRect: (x0, y0, w0, h0, r) => (x, y) => roundRectSd(x, y, x0, y0, w0, h0, r) <= 0,
};

function raster(w, h, scale, shapes, offX = 0, offY = 0) {
    const img = new Uint8Array(w * h * 4);
    for (let py = 0; py < h; py++) {
        for (let px = 0; px < w; px++) {
            let hits = 0;
            for (let sy = 0; sy < SS; sy++) {
                for (let sx = 0; sx < SS; sx++) {
                    const x = (px + (sx + 0.5) / SS - offX) / scale;
                    const y = (py + (sy + 0.5) / SS - offY) / scale;
                    if (shapes.some((s) => s(x, y))) hits++;
                }
            }
            const i = (py * w + px) * 4;
            img[i] = img[i + 1] = img[i + 2] = 255;
            img[i + 3] = Math.round((hits / (SS * SS)) * 255);
        }
    }
    return img;
}

function save(name, w, h, rgba) {
    writeFileSync(path.join(OUT, name), png(w, h, rgba));
}

// ---------- Icons (24-unit viewBox, drawn at 64 px) ----------
// A gear outline: teeth flat-topped trapezoids between outer and inner radii.
function gearPoints(cx, cy, outer, inner, teeth) {
    const pts = [];
    const step = (Math.PI * 2) / teeth;
    const at = (r, a) => [cx + r * Math.cos(a), cy + r * Math.sin(a)];
    for (let i = 0; i < teeth; i++) {
        const a = i * step - Math.PI / 2;
        pts.push(at(inner, a - step * 0.5));
        pts.push(at(inner, a - step * 0.27));
        pts.push(at(outer, a - step * 0.17));
        pts.push(at(outer, a + step * 0.17));
        pts.push(at(inner, a + step * 0.27));
    }
    return pts;
}
const S = 1.8;
const mirror = (pts) => pts.map(([x, y]) => [24 - x, y]);
const icons = {
    search: [P.circle(11, 11, 7, S), P.line(20, 20, 16.5, 16.5, S)],
    home: [P.poly([[4, 10.5], [12, 4], [20, 10.5], [20, 20], [15, 20], [15, 14], [9, 14], [9, 20], [4, 20]], S, true)],
    series: [P.rect(3, 6, 18, 12, 2, S), P.line(8, 21, 16, 21, S), P.poly([[9, 3], [12, 6], [15, 3]], S)],
    movies: [
        P.rect(3, 4, 18, 16, 2, S), P.line(7, 4, 7, 20, S), P.line(17, 4, 17, 20, S),
        P.line(3, 9, 7, 9, S), P.line(3, 15, 7, 15, S), P.line(17, 9, 21, 9, S), P.line(17, 15, 21, 15, S),
    ],
    mylist: [P.poly([[6, 3], [18, 3], [18, 21], [12, 17], [6, 21]], S, true)],
    mylist_on: [P.fillPoly([[6, 3], [18, 3], [18, 21], [12, 17], [6, 21]]), P.poly([[6, 3], [18, 3], [18, 21], [12, 17], [6, 21]], S, true)],
    requests: [P.poly([[12, 3], [14.6, 8.6], [20.6, 9.3], [16.1, 13.4], [17.3, 19.4], [12, 16.5], [6.7, 19.4], [7.9, 13.4], [3.4, 9.3], [9.4, 8.6]], S, true)],
    // Discover: a compass, its needle pointing to the top right.
    discover: [P.circle(12, 12, 9, S), P.poly([[15.5, 8.5], [13.4, 13.4], [8.5, 15.5], [10.6, 10.6]], S, true)],
    // Rotten Tomatoes score: a tomato with its leafy crown.
    tomato: [P.fillCircle(12, 14, 7.5), P.fillPoly([[7.5, 4.5], [10.5, 5.5], [12, 2.5], [13.5, 5.5], [16.5, 4.5], [14.5, 6.4], [9.5, 6.4]])],
    activity: [P.line(12, 4, 12, 15, S), P.poly([[7, 10.5], [12, 15.5], [17, 10.5]], S), P.line(5, 20, 19, 20, S)],
    settings: [P.poly(gearPoints(12, 12, 9.5, 7, 8), S, true), P.circle(12, 12, 3, S)],
    // My requests: a download arrow inside a circle (Activity's arrow sits on a line).
    downloads: [P.circle(12, 12, 9, S), P.line(12, 7, 12, 16, S), P.poly([[8.5, 12.5], [12, 16], [15.5, 12.5]], S)],
    play: [P.fillPoly([[7, 4.5], [7, 19.5], [19.5, 12]])],
    pause: [P.fillRect(6, 5, 4, 14, 1), P.fillRect(14, 5, 4, 14, 1)],
    info: [P.circle(12, 12, 9, 2), P.line(12, 11, 12, 17, 2), P.line(12, 7.5, 12, 8, 2)],
    plus: [P.line(12, 5, 12, 19, 2), P.line(5, 12, 19, 12, 2)],
    // More: three dots in a row, for Title Options.
    more: [P.fillCircle(5.5, 12, 2), P.fillCircle(12, 12, 2), P.fillCircle(18.5, 12, 2)],
    // Go to show: an arrow pointing right.
    goto: [P.line(5, 12, 18, 12, 2), P.poly([[12.5, 6], [18.5, 12], [12.5, 18]], 2)],
    hide: [P.arc(12, 21, 13, -136, -44, S), P.arc(12, 3, 13, 44, 136, S), P.circle(12, 12, 3, S), P.line(4, 4, 20, 20, S)],
    check: [P.poly([[5, 12.5], [10, 17], [19, 7.5]], 2)],
    back: [P.poly([[15, 5], [8, 12], [15, 19]], 2)],
    trailer: [P.rect(3, 5, 18, 14, 2, 2), P.fillPoly([[10, 9.5], [10, 14.5], [14, 12]])],
    rewind10: [
        P.arc(12, 12, 8, -134.5, 180, S), P.poly([[4, 4], [4, 8], [8, 8]], S),
        P.line(10.3, 10.6, 10.3, 15.2, 1.3), P.ellipse(13.6, 12.9, 1.6, 2.3, 1.3),
    ],
    forward10: [
        P.arc(12, 12, 8, 0, 314.5, S), P.poly(mirror([[4, 4], [4, 8], [8, 8]]), S),
        P.line(10.3, 10.6, 10.3, 15.2, 1.3), P.ellipse(13.6, 12.9, 1.6, 2.3, 1.3),
    ],
    subtitles: [P.rect(3, 5, 18, 14, 2, S), P.line(7, 11, 11, 11, S), P.line(13, 11, 17, 11, S), P.line(7, 15, 13, 15, S), P.line(15, 15, 17, 15, S)],
    audio: [P.poly([[4, 9], [4, 15], [8, 15], [13, 19], [13, 5], [8, 9]], S, true), P.arc(12.93, 12, 5, -44.4, 44.4, S)],
    next: [P.fillPoly([[6, 5], [6, 19], [15, 12]]), P.fillRect(16, 5, 2.5, 14, 1)],
    close: [P.line(6, 6, 18, 18, 2), P.line(18, 6, 6, 18, 2)],
    server: [P.rect(4, 4, 16, 7, 1.5, S), P.rect(4, 13, 16, 7, 1.5, S), P.fillCircle(8, 7.5, 1.1), P.fillCircle(8, 16.5, 1.1)],
    scan: [P.arc(12, 12, 8, -90, 180, 2)],
    // The Matinee mark (design/brand/logo.svg): a notched ticket with a play
    // triangle and a stub line cut through it.
    logo: [(x, y) => {
        if (roundRectSd(x, y, 0.5, 4, 23, 16, 1.6) > 0) return false;
        if (hypot(x - 0.5, y - 12) < 2.4 || hypot(x - 23.5, y - 12) < 2.4) return false;
        if (inPoly(x, y, [[9.2, 7.8], [9.2, 16.2], [15, 12]])) return false;
        if (Math.abs(x - 18.2) < 0.4 && y > 5.6 && y < 18.4 && Math.floor((y - 5.6) / 1.6) % 2 === 0) return false;
        return true;
    }],
    backspace: [P.poly([[9, 6], [20, 6], [20, 18], [9, 18], [3, 12]], S, true), P.line(12, 9.5, 17, 14.5, S), P.line(17, 9.5, 12, 14.5, S)],
    user: [P.circle(12, 8, 4, S), P.arc(12, 21, 8, 180, 360, S)],
    signout: [P.poly([[10, 4], [5, 4], [5, 20], [10, 20]], S), P.line(9, 12, 20, 12, S), P.poly([[16, 8], [20, 12], [16, 16]], S)],
};

// ---------- 9-patches ----------
// A Roku 9-patch has a 1 px border: black marks on the top row and left
// column show the stretchable middle. Corners keep their size.
function ninePatch(name, inner, r, shapes) {
    const size = inner + 2;
    const img = raster(size, size, 1, shapes, 1, 1);
    const mark = (x, y) => {
        const i = (y * size + x) * 4;
        img[i] = img[i + 1] = img[i + 2] = 0;
        img[i + 3] = 255;
    };
    // clear the border, then mark the stretchable middle
    for (let i = 0; i < size; i++) {
        for (const [x, y] of [[i, 0], [0, i], [i, size - 1], [size - 1, i]]) {
            img[(y * size + x) * 4 + 3] = 0;
        }
    }
    const mid0 = 1 + r, mid1 = size - 2 - r;
    for (let i = mid0; i <= mid1; i++) {
        mark(i, 0);
        mark(0, i);
    }
    save(name, size, size, img);
}

function fill(r) {
    const inner = r * 2 + 2;
    ninePatch(`fill_r${r}.9.png`, inner, r, [P.fillRect(0, 0, inner, inner, r)]);
}
function ring(r, w) {
    const inner = r * 2 + 2;
    ninePatch(`ring_r${r}_w${w}.9.png`, inner, r, [(x, y) => {
        const d = roundRectSd(x, y, 0, 0, inner, inner, r);
        return d <= 0 && d >= -w;
    }]);
}
// The outside of a rounded corner, for covering a Poster's square corners.
function corners(r) {
    const inner = r * 2 + 2;
    ninePatch(`corners_r${r}.9.png`, inner, r, [(x, y) => roundRectSd(x, y, 0, 0, inner, inner, r) > 0 && x > 0 && y > 0 && x < inner && y < inner]);
}

// ---------- Gradients (white, alpha only) ----------
function gradient(name, w, h, alphaAt) {
    const img = new Uint8Array(w * h * 4);
    for (let y = 0; y < h; y++) {
        for (let x = 0; x < w; x++) {
            const i = (y * w + x) * 4;
            img[i] = img[i + 1] = img[i + 2] = 255;
            img[i + 3] = Math.round(Math.max(0, Math.min(1, alphaAt(x / (w - 1), y / (h - 1)))) * 255);
        }
    }
    save(name, w, h, img);
}
const stops = (list) => (t) => {
    for (let i = 1; i < list.length; i++) {
        const [t0, a0] = list[i - 1], [t1, a1] = list[i];
        if (t <= t1) return a0 + ((t - t0) / (t1 - t0)) * (a1 - a0);
    }
    return list[list.length - 1][1];
};

mkdirSync(OUT, { recursive: true });
for (const [name, shapes] of Object.entries(icons)) {
    save(`icon_${name}.png`, 64, 64, raster(64, 64, 64 / 24, shapes));
}
// Fills come in these radii (a pill is a fill whose radius is half its height).
// Each has a 4 px focus ring 4 px larger, and a 2 px outline of the same radius.
const RADII = [4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 36, 48];
for (const r of RADII) {
    fill(r);
    ring(r + 4, 4);
    ring(r, 2);
}
for (const r of [10, 12, 14]) corners(r);

// Circles: a solid dot (seek thumb, status dots), avatars and the profile focus ring.
save('circle.png', 64, 64, raster(64, 64, 1, [P.fillCircle(32, 32, 31.5)]));
save('circle_fill.png', 240, 240, raster(240, 240, 1, [P.fillCircle(120, 120, 119.5)]));
save('circle_ring.png', 248, 248, raster(248, 248, 1, [P.circle(124, 124, 120, 4)]));
save('circle_mask.png', 240, 240, raster(240, 240, 1, [(x, y) => hypot(x - 120, y - 120) > 119.5]));
save('circle_dashed.png', 216, 216, raster(216, 216, 1, [(x, y) => {
    const d = hypot(x - 108, y - 108);
    if (Math.abs(d - 107) > 1) return false;
    const a = (Math.atan2(y - 108, x - 108) + Math.PI) / (2 * Math.PI);
    return Math.floor(a * 72) % 2 === 0;
}]));

// The loading spinner: a quarter arc that turns over a faint full track.
save('spinner_arc.png', 96, 96, raster(96, 96, 1, [P.arc(48, 48, 42, -90, 0, 7)]));
save('spinner_track.png', 96, 96, raster(96, 96, 1, [P.circle(48, 48, 42, 7)]));

// Horizontal: Home Hero (solid to 0.88 at 32%, clear at 68%) and Detail art fade.
gradient('grad_hero.png', 256, 2, stops([[0, 1], [0.32, 0.88], [0.68, 0]]));
gradient('grad_detail.png', 256, 2, stops([[0, 1], [0.36, 1], [0.52, 0.7], [0.78, 0]]));
gradient('grad_h.png', 256, 2, (t) => 1 - t);
// Vertical: clear at the top to solid at the bottom, and the reverse.
gradient('grad_v.png', 2, 256, (_t, s) => s);
gradient('grad_vd.png', 2, 256, (_t, s) => 1 - s);

console.log('Images written to images/');
