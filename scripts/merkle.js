const fsReader = require('fs');
const csv = require('csv-parser');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');
const { getAddress, parseUnits, solidityPacked, keccak256: ethersKeccack256 } = require('ethers');
const path = require('path');

const whitelistedAddresses = path.join(__dirname, "../data", "merkleAddresses.csv");

const leaves = [];

fsReader.createReadStream(whitelistedAddresses)
.pipe(csv())
.on("data", (data) => {
 try{

  // if (!ethers || !ethers.utils || !ethers.utils.getAddress) {
  //   throw new Error("ethers.utils.getAddress is not available.");
  // }

  const addressOnEachStream = getAddress(data.address.trim());
  let amountOnEachStream = data.amount.toString().trim();
  amountOnEachStream = parseUnits(amountOnEachStream, 18);
  

  const hashedAddress = keccak256(solidityPacked(["address", "uint256"], [addressOnEachStream,amountOnEachStream]));
  // const hashedAddress = keccak256(`${addressOnEachStream},${amountOnEachStream}`);
  // console.log(addressOnEachStream);
  // console.log(amountOnEachStream);

  leaves.push(hashedAddress.toString("hex"));
  console.log("Hashes ARE::: ", leaves);

 
 }catch(error) {
  console.error("Issues:::", error.message);
  console.error('Data with ish:::', data);
 }
})
.on("end", () => {
  const merkle = new MerkleTree(leaves, keccak256, {sortPairs: true});
  console.log("MERKLE:::", merkle);
  const rootHash = merkle.getHexRoot();
  console.log("ROOT HASH:::", rootHash);

  const proof = {}
  let i = 0;
  leaves.map((data) => {
    proof[i] = merkle.getHexProof(data);
    i++;
  })

  console.log("ALL OUR WHITELIST CSV PROOF ARE:::", proof);

  // WORKING WITH WINGLE ADDRESS AND VERIFYING It

  const addressToWorkWith = "0xdD870fA1b7C4700F2BD7f44238821C26f7392148";
  const amount = parseUnits("10", 18);
  
  const leafNodeForAddressToWorkWith = keccak256(solidityPacked(["address", "uint256"], [addressToWorkWith, amount]));
  console.log("Hash For Address We are Testing/Working On:::", leafNodeForAddressToWorkWith.toString('hex'));

  const leafExist = leaves.includes(leafNodeForAddressToWorkWith.toString('hex'));
  console.log("Does this leaf proof exist in the merkle tree::: ", leafExist);

  const rootProofForAddressWeAreWorkingWith = merkle.getHexProof(leafNodeForAddressToWorkWith);
  console.log("The Root Proof For Address We are Working With is:::", rootProofForAddressWeAreWorkingWith);

  
})