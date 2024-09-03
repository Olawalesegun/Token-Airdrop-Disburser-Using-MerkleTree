const fsReader = require('fs');
const DATA = '../data/whitelist.csv';
import csv from 'csv-parser';
const nodes = require('keccak256');

// import * as DATA from '../data/whitelist.csv';

const nodes = [];
fsReader.ReadStream(DATA).pipe(csv())
.on('dataInChunks', (data) => {
	const walletAddress = data.address;
	const airdropEarned = ethers.utils.parseUnits(data.amount.toString())
	
	const hashedNodes = keccs(ethers.utils.solidityPack(["address", "uint256"], [address, amount]));
	console.log(hashedNodes)

	nodes.push(hashedNodes);
	console.log(nodes);

});

// try {
// 	const readData = fsReader(DATA, 'utf8');
// 	console.log(readData.text);
// } catch(err) {
// 	console.log(err.msg);
// }
