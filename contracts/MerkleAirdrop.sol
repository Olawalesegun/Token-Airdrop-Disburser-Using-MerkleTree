// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdrop {
  address tokenAddress;
  address owner;
  bytes32 merkleRoot;

  error OnlyOwnerCanDoThis();
  error YouAreNotEligibleForAirdrop();
  error YouCantClaimForSomeoneElse();
  error AddressZeroDenied();
  error YouAlreadyClaimed();

  event AirdropClaimedSuccessFully();

  mapping(address => bool) hasUserClaimed;

  constructor(address _tokenAddress, bytes32 _merkleRoot){
    if (msg.sender != owner) {
      revert OnlyOwnerCanDoThis();
    }
    tokenAddress = _tokenAddress;
    merkleRoot = _merkleRoot;
  }
  
  function claimAirdrop(
    address userWalletAddress,
    uint256 amountToClaim,
    bytes32[] calldata userMerkleProof) public{
      if(msg.sender == address(0)) {
        revert AddressZeroDenied();
      }
      if(msg.sender != userWalletAddress) {
        revert YouCantClaimForSomeoneElse();
      }
      if(hasUserClaimed[msg.sender] == true) {
        revert YouAlreadyClaimed();
      }
      if(!confirmMerkleProofInHash(userMerkleProof, amountToClaim)){
        revert YouAreNotEligibleForAirdrop();
      }
      IERC20(tokenAddress).transfer(userWalletAddress, amountToClaim);
      hasUserClaimed[msg.sender] = true;

      emit AirdropClaimedSuccessFully();
    }

  function confirmMerkleProofInHash(bytes32[] calldata _merkleProof, uint256 _amount) public view returns(bool) {
    bytes32 leafNodes = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _amount))));
    bool isVerified = MerkleProof.verify(_merkleProof, merkleRoot, leafNodes);
    if(isVerified){
      return true;
    } else {
      return false;
    }
    
    // if(merkleRoot.includes(_merkleProof)){
    //   return true;
    // }
    // else {
    //   return false;
  }
}