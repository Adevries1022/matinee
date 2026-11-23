// Saves a screenshot of what the Roku is showing to screenshots/<name>.jpg.
// Only works while a sideloaded (dev) app is on screen. Usage: npm run screenshot -- home
// Needs ROKU_IP and ROKU_DEV_PASSWORD in .env.
import { createRequire } from 'node:module';
import { mkdirSync } from 'node:fs';
import path from 'node:path';
import { root, loadEnv, fail } from './env.mjs';

const { rokuDeploy } = createRequire(import.meta.url)('roku-deploy');

loadEnv(['ROKU_IP', 'ROKU_DEV_PASSWORD']);
const name = (process.argv[2] ?? `screenshot-${Date.now()}`).replace(/[^\w.-]+/g, '-');
const outDir = path.join(root, 'screenshots');
mkdirSync(outDir, { recursive: true });

// With another app in front, the Roku hands back its last saved screenshot,
// which looks current but isn't. Check that the dev app is showing first.
const active = await fetch(`http://${process.env.ROKU_IP}:8060/query/active-app`)
    .then((res) => res.text())
    .catch((err) => fail(`Could not reach the Roku: ${err.cause?.code ?? err.message}`));
if (!/<app id="dev"/.test(active)) {
    const shown = active.match(/<app[^>]*>([^<]*)<\/app>/)?.[1] ?? 'something else';
    fail(`Matinee isn't on screen (the TV shows ${shown}), so there's nothing to capture.`);
}

try {
    const file = await rokuDeploy.takeScreenshot({
        host: process.env.ROKU_IP,
        password: process.env.ROKU_DEV_PASSWORD,
        outDir,
        outFile: name
    });
    console.log(path.relative(root, file));
} catch (err) {
    fail(`Screenshot failed: ${err?.message ?? err}`);
}
