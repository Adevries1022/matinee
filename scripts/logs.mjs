// Streams the Roku's BrightScript debug log (prints, errors, crashes) from port 8085.
// Matinee's own lines start with [Matinee]. Ctrl+C to stop. Needs ROKU_IP in .env.
import net from 'node:net';
import { loadEnv } from './env.mjs';

loadEnv(['ROKU_IP']);
const host = process.env.ROKU_IP;
const socket = net.connect({ host, port: 8085 });

socket.setEncoding('utf8');
socket.on('connect', () => console.error(`Connected to ${host}:8085. Ctrl+C to stop.`));
socket.on('data', (chunk) => process.stdout.write(chunk));
socket.on('error', (err) => {
    console.error(`Could not read the debug log from ${host}:8085 (${err.code ?? err.message}). Is the Roku on, with Developer Mode enabled?`);
    process.exit(1);
});
socket.on('close', () => process.exit(0));

// Forward typed lines so debugger commands (bt, var, cont) work when the app stops on an error.
process.stdin.pipe(socket);
process.on('SIGINT', () => {
    socket.destroy();
    process.exit(0);
});
