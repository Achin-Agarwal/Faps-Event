import fs from 'fs';
import path from 'path';
import getISTDateString from '../utils/getDate.js';
import url from 'url';

const excludedExtensions = ['.js', '.css', '.png', '.jpg', '.jpeg', '.gif', '.ico', '.svg'];
const BATCH_SIZE = 100;

let allRequestsBatch = [];
let filteredRequestsBatch = [];

function prependLog(filePath, logData) {
    fs.readFile(filePath, 'utf8', (err, data) => {
        if (err && err.code !== 'ENOENT') {
            console.error(`Failed to read ${filePath}:`, err);
            return;
        }
        const updatedLog = logData.join('') + (data || ''); // Prepend new log batch
        fs.writeFile(filePath, updatedLog, (err) => {
            if (err) {
                console.error(`Failed to write to ${filePath}:`, err);
            }
        });
    });
}

function writeLogBatches() {
    const allRequestsLogPath = path.join(path.resolve(), 'all_requests.log');
    const filteredLogPath = path.join(path.resolve(), 'filtered_requests.log');

    if (allRequestsBatch.length >= BATCH_SIZE) {
        prependLog(allRequestsLogPath, allRequestsBatch);
        allRequestsBatch = [];
    }

    if (filteredRequestsBatch.length >= BATCH_SIZE) {
        prependLog(filteredLogPath, filteredRequestsBatch);
        filteredRequestsBatch = [];
    }
}

export default function requestLogger(req, _, next) {
    try {
        console.log('Request:', req.originalUrl);
        const parsedUrl = url.parse(req.originalUrl);
        const extension = path.extname(parsedUrl.pathname);

        const timestamp = getISTDateString();
        const method = req.method;
        const ip = req.headers['do-connecting-ip'] || req.headers['x-forwarded-for'] || req.connection.remoteAddress;

        const log = `${timestamp} | ${method} ${req.originalUrl} | ${ip}\n`;

        allRequestsBatch.unshift(log);
        if (!excludedExtensions.includes(extension)) {
            filteredRequestsBatch.unshift(log);
        }

        writeLogBatches();

        next();
    } catch (error) {
        console.error(error);
        next();
    }
}
