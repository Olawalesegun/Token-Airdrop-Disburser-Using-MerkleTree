// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    address private owner;
    IERC20 public token;
    bytes32 public merkleRoot;
    

    mapping(address => bool) public claimed;

    event AirdropClaimed(address indexed account, uint256 amount);
    event MerkleRootUpdated(bytes32 newMerkleRoot);
    event TokensWithdrawn(address indexed owner, uint256 amount);

    constructor(address _token, bytes32 _merkleRoot) {
        if (_token == address(0)) {
            revert InvalidTokenAddress();
        }
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
        owner = msg.sender;
    }

    error InvalidTokenAddress();
    error AlreadyClaimed();
    error InvalidProof();
    error InsufficientBalance();
    error NotOwner();

    function claimAirdrop(uint256 amount, bytes32[] calldata proof) external {
        if (claimed[msg.sender]) {
            revert AlreadyClaimed();
        }
        
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        if (!MerkleProof.verify(proof, merkleRoot, leaf)) {
            revert InvalidProof();
        }

        claimed[msg.sender] = true;

        if (token.balanceOf(address(this)) < amount) {
            revert InsufficientBalance();
        }

        token.transfer(msg.sender, amount);
        emit AirdropClaimed(msg.sender, amount);
    }

    function updateMerkleRoot(bytes32 newMerkleRoot) external onlyOwner {
        merkleRoot = newMerkleRoot;
        emit MerkleRootUpdated(newMerkleRoot);
    }

    function withdrawTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        if (balance == 0) {
            revert InsufficientBalance();
        }
        token.transfer(msg.sender, balance);
        emit TokensWithdrawn(msg.sender, balance);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }


}






// pragma solidity ^0.8.24;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";


// contract MerkleAirdrop is Ownable {
//   IERC20 public erctokenAddressAccepted;
//   bytes32 public merkleTreeRoot;

//   mapping(address => bool) public claimedAirdropPool;

//   constructor(bytes32 _merkleTreeRoot, IERC20 _token) {
//     merkleTreeRoot = _merkleTreeRoot;
//     erctokenAddressAccepted = _token;
//   }
//   error AddressZeroCannotClaim();

//   function claim(uint256 amountToClaim, bytes32[] calldata proof) external {
//     if(msg.sender == address(0)) {
//       revert AddressZeroCannotClaim();
//     }

//     if(claimedAirdropPool[msg.sender]) {
//       revert ThisAddressAlreadyClaimedAirdrop();
//     }
//     require(!airdropPool[msg.sender], "Airdrop already claimed");
//         bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amountToClaim));
        
//         require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");

//         hasClaimed[msg.sender] = true;

//         require(token.transfer(msg.sender, amount), "Token transfer failed");
        
//         emit AirdropClaimed(msg.sender, amount);
//   }

// }