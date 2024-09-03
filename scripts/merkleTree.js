const fsReader = require('fs');
// import path from 'path';
const DATA = 'data/whitelist.csv';
const csv = require('csv-parser');
const keccak256 = require('keccak256');
const { MerkleTree } = require('merkletreejs');
const { ethers } = require("ethers");

// import * as DATA from '../data/whitelist.csv';

const nodes = [];
fsReader.createReadStream(DATA).pipe(csv())
.on('data', (data) => {
	const walletAddress = ethers.utils.getAddress(data.address);
	console.log("Wallet Address is:::", walletAddress);
	
	const amountString = data.amount.toString().trim();
	const airdropEarned = ethers.utils.parseUnits(amountString, 18);
	console.log("Airdrop earned is:::", airdropEarned);
	
	const hashedNodes = keccak256(ethers.utils.solidityPack(["address", "uint256"], [walletAddress, airdropEarned]));
	console.log(hashedNodes.toString('hex'));

	nodes.push(hashedNodes);
	console.log(nodes);

}).on("end", function(){
	const merkle = new MerkleTree(nodes, keccak256, {sortPairs: true,});

const rootHash = merkle.getHexRoot();
console.log("final hash gotten is:::", rootHash);

const oneOfTheAddressToBeAirdropped = "0xC0c49B81f9996Ae22BeE60268DFc1e9787e1bB80";
const amount = ethers.utils.parseUnits("400", 18);

const leafForProof = keccak256(ethers.utils.solidityPack(["address", "uint256"], [oneOfTheAddressToBeAirdropped, amount]));
console.log("The Leaf Created for The Proof is:::", leafForProof.toString("hex"));

const proofGottenFromTheLeafAbove = merkle.getHexProof(leafForProof);
console.log("Proof Gotten:::", proofGottenFromTheLeafAbove);
});
// try {
// 	const readData = fsReader(DATA, 'utf8');
// 	console.log(readData.text);
// } catch(err) {
// 	console.log(err.msg);
// }
