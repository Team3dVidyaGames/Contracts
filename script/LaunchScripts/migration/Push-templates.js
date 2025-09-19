#!/usr/bin/env node

/**
 * Push cleaned templates into a deployed contract by calling:
 *
 * function addTemplateId(
 *   string memory imageURL,
 *   string memory description,
 *   string memory name,
 *   uint8 top,
 *   uint8 left,
 *   uint8 right,
 *   uint8 bottom,
 *   uint8 level
 * ) external
 *
 * Input JSON format (from clean-templates.js):
 * {
 *   "items": [
 *     { "index": 1, "data": { imageURL, name, description, level, top, left, right, bottom } }, ...
 *   ]
 * }
 *
 * Usage:
 *   node push-templates.js \
 *     --rpc "https://YOUR_RPC" \
 *     --address 0xYourContract \
 *     --input cleaned.json \
 *     --keyfile wallet.json \
 *     --password mypassword \
 *     --confirm
 */

const fs = require('fs');
const path = require('path');

let ethers;
try {
    ethers = require('ethers');
} catch (e) {
    console.error('Please install ethers: npm i ethers');
    process.exit(1);
}

const ABI = [
    {
        "inputs": [
            { "internalType": "string", "name": "imageURL", "type": "string" },
            { "internalType": "string", "name": "description", "type": "string" },
            { "internalType": "string", "name": "name", "type": "string" },
            { "internalType": "uint8", "name": "top", "type": "uint8" },
            { "internalType": "uint8", "name": "left", "type": "uint8" },
            { "internalType": "uint8", "name": "right", "type": "uint8" },
            { "internalType": "uint8", "name": "bottom", "type": "uint8" },
            { "internalType": "uint8", "name": "level", "type": "uint8" }
        ],
        "name": "addTemplateId",
        "outputs": [],
        "stateMutability": "nonpayable",
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

function requireArg(args, key) {
    if (!args[key] || args[key] === true) {
        console.error(`Missing required --${key}`);
        process.exit(1);
    }
}

function asUint8(x, name) {
    const n = Number(x);
    if (!Number.isInteger(n) || n < 0 || n > 255) throw new Error(`${name} must be uint8 (0..255), got ${x}`);
    return n;
}

async function loadWallet(args, provider) {
    if (args.key && args.key !== true) {
        return new ethers.Wallet(args.key, provider);
    }
    if (args.keyfile && args.password && args.password !== true) {
        const keyfilePath = path.resolve(process.cwd(), args.keyfile);
        if (!fs.existsSync(keyfilePath)) {
            console.error(`Keyfile not found: ${keyfilePath}`);
            process.exit(1);
        }
        const json = fs.readFileSync(keyfilePath, 'utf8');
        try {
            const w = await ethers.Wallet.fromEncryptedJson(json, args.password);
            return w.connect(provider);
        } catch (err) {
            console.error('Failed to decrypt keyfile:', err.message || err);
            process.exit(1);
        }
    }
    console.error('Provide credentials via --key or (--keyfile and --password)');
    process.exit(1);
}

async function main() {
    const args = parseArgs(process.argv);
    requireArg(args, 'rpc');
    requireArg(args, 'address');
    requireArg(args, 'input');

    const confirm = !!args.confirm;

    const start = args.start !== undefined && args.start !== true ? Number(args.start) : null;
    const end = args.end !== undefined && args.end !== true ? Number(args.end) : null;

    const provider = new (ethers.providers ? ethers.providers.JsonRpcProvider : ethers.JsonRpcProvider)(args.rpc);
    const wallet = await loadWallet(args, provider);

    const contract = new ethers.Contract(args.address, ABI, wallet);

    const inputPath = path.resolve(process.cwd(), args.input);
    if (!fs.existsSync(inputPath)) {
        console.error(`Input file not found: ${inputPath}`);
        process.exit(1);
    }
    const json = JSON.parse(fs.readFileSync(inputPath, 'utf8'));
    if (!json.items || !Array.isArray(json.items)) {
        console.error('Input JSON must have an "items" array');
        process.exit(1);
    }

    const items = json.items
        .filter(Boolean)
        .filter(({ index }) => (start === null || index >= start) && (end === null || index <= end));

    console.log(`Loaded ${json.items.length} items. Will process ${items.length} item(s).`);
    console.log(confirm ? 'MODE: LIVE (sending transactions)' : 'MODE: DRY-RUN (no transactions will be sent)');

    const overrides = {};
    if (args.gasLimit && args.gasLimit !== true) overrides.gasLimit = Number(args.gasLimit);
    if (args.gasPrice && args.gasPrice !== true) overrides.gasPrice = ethers.utils ? ethers.utils.parseUnits(args.gasPrice, 'gwei') : ethers.parseUnits(args.gasPrice, 'gwei');
    if (args.maxFeePerGas && args.maxFeePerGas !== true) overrides.maxFeePerGas = (ethers.utils ? ethers.utils.parseUnits(args.maxFeePerGas, 'gwei') : ethers.parseUnits(args.maxFeePerGas, 'gwei'));
    if (args.maxPriorityFeePerGas && args.maxPriorityFeePerGas !== true) overrides.maxPriorityFeePerGas = (ethers.utils ? ethers.utils.parseUnits(args.maxPriorityFeePerGas, 'gwei') : ethers.parseUnits(args.maxPriorityFeePerGas, 'gwei'));

    const failed = [];
    let sent = 0;

    for (const { index, data } of items) {
        if (!data) {
            console.warn(`Skipping index ${index}: data is null`);
            continue;
        }

        const imageURL = data.imageURL ?? '';
        const description = data.description ?? '';
        const name = data.name ?? '';
        const top = asUint8(data.top, 'top');
        const left = asUint8(data.left, 'left');
        const right = asUint8(data.right, 'right');
        const bottom = asUint8(data.bottom, 'bottom');
        const level = asUint8(data.level, 'level');

        const argsTuple = [imageURL, description, name, top, left, right, bottom, level];

        if (!confirm) {
            console.log(`[DRY] addTemplateId(${JSON.stringify(argsTuple)}) for index ${index}`);
            continue;
        }

        try {
            // Preflight simulation to catch reverts early and surface reasons (ethers v5/v6 compatible)
            try {
                if (contract.callStatic && typeof contract.callStatic.addTemplateId === 'function') {
                    // ethers v5 style
                    await contract.callStatic.addTemplateId(...argsTuple, overrides);
                } else if (contract.addTemplateId && contract.addTemplateId.staticCall) {
                    // ethers v6 style
                    await contract.addTemplateId.staticCall(...argsTuple, overrides);
                } else {
                    // If neither interface exists, skip simulation
                    console.warn('⚠️  Skipping simulation: callStatic/staticCall not available on this ethers version.');
                }
            } catch (simErr) {
                console.error(`❌ Simulation failed for index ${index}: ${simErr.message || simErr}`);
                failed.push(index);
                if (!args.continue) {
                    console.error('Stopping due to simulation failure (use --continue to skip).');
                    break;
                }
                continue;
            }

            const tx = await contract.addTemplateId(...argsTuple, overrides);
            console.log(`Sent tx for index ${index}: ${tx.hash}`);

            const confs = (args.waitConf && args.waitConf !== true) ? Number(args.waitConf) : 1;
            const receipt = await tx.wait(confs);
            sent++;
            console.log(`  Mined in block ${receipt.blockNumber}`);

            if (args.delay && args.delay !== true) {
                await new Promise((r) => setTimeout(r, Number(args.delay)));
            }
        } catch (err) {
            console.error(`❌ Failed on index ${index}: ${err.message || err}`);
            failed.push(index);
            if (!args.continue) {
                console.error('Stopping due to failure (use --continue to skip failures).');
                break;
            }
        }
    }

    console.log(`Done. Sent ${sent} transaction(s).`);
    if (failed.length) console.log(`Failed indexes: ${failed.join(', ')}`);
}

main().catch((e) => {
    console.error(e);
    process.exit(1);
});
