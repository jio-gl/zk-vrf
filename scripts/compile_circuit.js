const { wasm: snarkjs } = require("snarkjs");
const fs = require("fs");

async function compile() {
    const { circuits } = JSON.parse(fs.readFileSync("circuits.json"));
    
    for (const circuit of circuits) {
        const input = `./circuits/${circuit.name}.circom`;
        const output = `./build/${circuit.name}_js/${circuit.name}.wasm`;
        
        await snarkjs.compile(
            input,
            circuit.config || {}
        ).then(async ({ constraints, reference, symbols, warnings }) => {
            fs.mkdirSync(`./build/${circuit.name}_js`, { recursive: true });
            fs.writeFileSync(output, await wasm);
            console.log(`✅ Compiled ${circuit.name}`);
        });
    }
}

compile(); 