// Presses remote buttons on the Roku over ECP (port 8060), with a short pause between each.
// Usage: npm run key -- Left Down Down Select   (also Up, Right, Back, Home, Play, Info, Rev, Fwd)
// "OK" is accepted as an alias for Select. Needs ROKU_IP in .env.
import { setTimeout as sleep } from 'node:timers/promises';
import { loadEnv, fail } from './env.mjs';

loadEnv(['ROKU_IP']);
const keys = process.argv.slice(2);
if (!keys.length) fail('Usage: npm run key -- <Key> [<Key> ...]');

const delay = Number(process.env.KEY_DELAY_MS ?? 400);
for (const raw of keys) {
    const key = raw.toLowerCase() === 'ok' ? 'Select' : raw;
    const res = await fetch(`http://${process.env.ROKU_IP}:8060/keypress/${encodeURIComponent(key)}`, { method: 'POST' })
        .catch((err) => fail(`Could not reach the Roku: ${err.cause?.code ?? err.message}`));
    if (!res.ok) fail(`The Roku rejected key "${key}" (HTTP ${res.status}).`);
    await sleep(delay);
}
