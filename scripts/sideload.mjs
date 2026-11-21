// Sideloads dist/matinee.zip onto the Roku. Run `npm run deploy` to build, lint and sideload.
// Needs ROKU_IP and ROKU_DEV_PASSWORD in .env, and Developer Mode on the TV.
import { createRequire } from 'node:module';
import { existsSync } from 'node:fs';
import path from 'node:path';
import { root, loadEnv, fail } from './env.mjs';

const { rokuDeploy } = createRequire(import.meta.url)('roku-deploy');

loadEnv(['ROKU_IP', 'ROKU_DEV_PASSWORD']);
const outDir = path.join(root, 'dist');
const outFile = 'matinee.zip';
if (!existsSync(path.join(outDir, outFile))) {
    fail('dist/matinee.zip not found. Run `npm run build` first.');
}

const host = process.env.ROKU_IP;
console.log(`Installing dist/matinee.zip on ${host} ...`);
try {
    const result = await rokuDeploy.publish({
        host,
        password: process.env.ROKU_DEV_PASSWORD,
        outDir,
        outFile,
        retainDeploymentArchive: true,
        failOnCompileError: true,
        timeout: 60000
    });
    const message = result?.message ?? '';
    if (message) console.log(message);
    console.log('Done. Matinee should now be open on the TV.');
} catch (err) {
    const name = err?.name ?? '';
    if (name === 'UnauthorizedDeviceResponseError') {
        fail('Install failed: the Roku rejected the password. Check ROKU_DEV_PASSWORD in .env.');
    } else if (name === 'DeviceUnreachableError' || ['ECONNREFUSED', 'ETIMEDOUT', 'EHOSTUNREACH', 'ENETUNREACH'].includes(err?.code)) {
        fail(`Install failed: could not reach the Roku at ${host} (is it on, and is Developer Mode enabled?).`);
    } else if (name === 'CompileError') {
        fail(`Install failed: the Roku could not compile the app.\n${err.message}`);
    }
    fail(`Install failed: ${err?.message ?? err}`);
}
