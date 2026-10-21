const readline = require('readline');

const API_KEY = 'XAQ.Ab8RN6LB3rFaTcy-51aE7bbTGVuG36lUbi87-lMfZMll941omA';
const URL = 'https://stitch.googleapis.com/mcp';

let sessionId = null;

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    terminal: false
});

rl.on('line', async (line) => {
    const trimmed = line.trim();
    if (!trimmed) return;

    try {
        const headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/event-stream',
            'X-Goog-Api-Key': API_KEY,
        };

        if (sessionId) {
            headers['Mcp-Session-Id'] = sessionId;
        }

        const res = await fetch(URL, {
            method: 'POST',
            headers: headers,
            body: trimmed,
        });

        const newSessionId = res.headers.get('mcp-session-id') || res.headers.get('x-mcp-session-id');
        if (newSessionId) {
            sessionId = newSessionId;
        }

        const text = await res.text();

        if (!res.ok) {
            process.stderr.write(`Bridge HTTP ${res.status}: ${text}\n`);
            const msg = JSON.parse(trimmed);
            if (msg.id !== undefined) {
                process.stdout.write(JSON.stringify({
                    jsonrpc: '2.0',
                    id: msg.id,
                    error: { code: -32000, message: `Stitch HTTP ${res.status}: ${text.slice(0, 500)}` },
                }) + '\n');
            }
            return;
        }

        if (!text) return;

        const lines = text.split('\n');
        for (let l of lines) {
            let clean = l.trim();
            if (clean.startsWith('data: ')) {
                clean = clean.substring(6).trim();
            }
            if (clean && clean !== '[DONE]') {
                process.stdout.write(clean + '\n');
            }
        }
    } catch (err) {
        process.stderr.write(`Bridge Error: ${err.message}\n`);
        try {
            const msg = JSON.parse(trimmed);
            if (msg.id !== undefined) {
                process.stdout.write(JSON.stringify({
                    jsonrpc: '2.0',
                    id: msg.id,
                    error: { code: -32000, message: `Bridge Error: ${err.message}` },
                }) + '\n');
            }
        } catch {}
    }
});