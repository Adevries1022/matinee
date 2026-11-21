// Loads .env from the repo root into process.env and checks for required keys.
// Never prints values: .env holds the Roku dev password and the Jellyfin API key.
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

export function loadEnv(required) {
    const file = path.join(root, '.env');
    if (!existsSync(file)) {
        fail('No .env file. Copy .env.example to .env and fill it in.');
    }
    process.loadEnvFile(file);
    const missing = required.filter((k) => !process.env[k]);
    if (missing.length) {
        fail(`.env is missing: ${missing.join(', ')}`);
    }
}

export function fail(message) {
    console.error(message);
    process.exit(1);
}
