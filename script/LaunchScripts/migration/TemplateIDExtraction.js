#!/usr/bin/env node


/**
* Fetch Data structs from a Solidity public mapping and save them to a JSON file.
*
* Works with contracts that have:
* struct Data {
* string imageURL;
* string name;
* string description;
* string jsonStorage;
* uint8 level;
* uint8 top;
* uint8 left;
* uint8 right;
* uint8 bottom;
* uint8 slot;
* }
* mapping(uint256 => Data) public template;
*
* Usage:
* node fetch-templates.js \
* --rpc "https://YOUR_RPC" \
* --address 0xYourContractAddress \
* --start 0 \
* --end 99 \
* --out templates.json
*
* Optional:
* --batch 10 // number of concurrent calls (default 10)
*/


const fs = require('fs');
const path = require('path');


let ethers;
try {
    // Prefer ethers v5 (common in scripts). v6 also exposes a compatible Contract/Provider interface for this use.
    ethers = require('ethers');
} catch (e) {
    console.error('Please install ethers: npm i ethers');
    process.exit(1);
}


const ABI = [
    {
        "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
        "name": "template",
        "outputs": [
            { "internalType": "string", "name": "imageURL", "type": "string" },
            { "internalType": "string", "name": "name", "type": "string" },
            { "internalType": "string", "name": "description", "type": "string" },
            { "internalType": "string", "name": "jsonStorage", "type": "string" },
            { "internalType": "uint8", "name": "level", "type": "uint8" },
            { "internalType": "uint8", "name": "top", "type": "uint8" },
            { "internalType": "uint8", "name": "left", "type": "uint8" },
            { "internalType": "uint8", "name": "right", "type": "uint8" },
            { "internalType": "uint8", "name": "bottom", "type": "uint8" },
            { "internalType": "uint8", "name": "slot", "type": "uint8" }
        ],
        "stateMutability": "view",
        "type": "function"
    }
];


function parseArgs(argv) {
    const args = {};
    for (let i = 2; i < argv.length; i++) {
        const k = argv[i];
        if (!k.startsWith('--')) continue;
        const key = k.slice(2);
        const next = argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[++i] : true;
        args[key] = next;
    }
    return args;
}


function required(arg, name) {
    if (arg === undefined || arg === true || arg === '') {
        console.error(`Missing required --${name}`);
        process.exit(1);
    }
}


function toNumber(x) {
    // Handles ethers v5 BigNumber or JS bigint/number
    if (x == null) return x;
    if (typeof x === 'number') return x;
    if (typeof x === 'bigint') return Number(x);
    if (x._isBigNumber || (x && typeof x.toNumber === 'function')) return x.toNumber();
    return Number(x);
}


async function main() {
    const args = parseArgs(process.argv);
    required(args.rpc, 'rpc');
    required(args.address, 'address');
    required(args.start, 'start');
    required(args.end, 'end');


    const start = Number(args.start);
    const end = Number(args.end);
    if (!Number.isInteger(start) || !Number.isInteger(end) || end < start) {
        console.error('--start and --end must be integers, and end >= start');
        process.exit(1);
    }
    const outPath = args.out || 'templates.json';
    const batch = Math.max(1, Number(args.batch || 10));


    // Handle both ethers v5 and v6
    let provider;
    try {
        // Try ethers v6 first
        provider = new ethers.JsonRpcProvider(args.rpc);
    } catch (e) {
        try {
            // Fallback to ethers v5
            provider = new ethers.providers.JsonRpcProvider(args.rpc);
        } catch (e2) {
            console.error('Failed to create provider. Please ensure ethers is properly installed.');
            process.exit(1);
        }
    }
    const contract = new ethers.Contract(args.address, ABI, provider);


    console.log(`Fetching template[${start}..${end}] from ${args.address} on ${args.rpc}`);


    const indexes = Array.from({ length: end - start + 1 }, (_, i) => start + i);
    const results = {};


    // Simple concurrency control
    for (let i = 0; i < indexes.length; i += batch) {
        const chunk = indexes.slice(i, i + batch);
        process.stdout.write(` Querying indexes ${chunk[0]}..${chunk[chunk.length - 1]}... `);


        const datas = await Promise.all(
            chunk.map(async (idx) => {
                try {
                    const d = await contract.template(idx);
                    // d is an array-like + named keys struct; normalize to plain object
                    return [idx, {
                        imageURL: d.imageURL ?? d[0],
                        name: d.name ?? d[1],
                        description: d.description ?? d[2],
                        jsonStorage: d.jsonStorage ?? d[3],
                        level: toNumber(d.level ?? d[4]),
                        top: toNumber(d.top ?? d[5]),
                        left: toNumber(d.left ?? d[6]),
                        right: toNumber(d.right ?? d[7]),
                        bottom: toNumber(d.bottom ?? d[8]),
                        slot: toNumber(d.slot ?? d[9])
                    }];
                } catch (err) {
                    console.warn(`\n ⚠️ Failed to read index ${idx}: ${err.message || err}`);
                    return [idx, null];
                }
            })
        );


        for (const [idx, obj] of datas) {
            results[idx] = obj; // may be null if failed
        }
        console.log('done');
    }


    // Prepare an array sorted by index (and also keep a keyed object for convenience)
    const arrayOut = Object.keys(results)
        .map((k) => Number(k))
        .sort((a, b) => a - b)
        .map((k) => ({ index: k, data: results[k] }));


    const payload = { meta: { contract: args.address, start, end, fetchedAt: new Date().toISOString() }, items: arrayOut };


    const abs = path.resolve(process.cwd(), outPath);
    fs.writeFileSync(abs, JSON.stringify(payload, null, 2));
    console.log(`Saved ${arrayOut.length} entries to ${abs}`);
}


main().catch((e) => {
    console.error(e);
    process.exit(1);
});