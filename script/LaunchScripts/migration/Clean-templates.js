#!/usr/bin/env node


/**
* Clean up templates.json (from fetch-templates.js) into a simplified JSON.
* Keeps only the required keys.
*
* Usage:
* node clean-templates.js input.json output.json
*/


const fs = require('fs');
const path = require('path');


if (process.argv.length < 3) {
    console.error('Usage: node clean-templates.js input.json [output.json]');
    process.exit(1);
}


const inPath = process.argv[2];
const outPath = process.argv[3] || 'templates.cleaned.json';


const absIn = path.resolve(process.cwd(), inPath);
const absOut = path.resolve(process.cwd(), outPath);


if (!fs.existsSync(absIn)) {
    console.error(`Input file not found: ${absIn}`);
    process.exit(1);
}


const raw = JSON.parse(fs.readFileSync(absIn, 'utf8'));


const cleaned = {
    items: (raw.items || []).map(({ index, data }) => {
        if (!data) return null;
        return {
            index,
            data: {
                imageURL: data.imageURL,
                name: data.name,
                description: data.description,
                level: data.level,
                top: data.top,
                left: data.left,
                right: data.right,
                bottom: data.bottom
            }
        };
    }).filter(Boolean)
};


fs.writeFileSync(absOut, JSON.stringify(cleaned, null, 2));
console.log(`Saved cleaned JSON to ${absOut}`);