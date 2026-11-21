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
