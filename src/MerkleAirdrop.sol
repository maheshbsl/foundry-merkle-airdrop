// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.26 ;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    using SafeERC20 for IERC20;

    error MerkleAirdrop_InvalidProof();
    error MerkleAirDrop_AlreadyClaimed(address account);

    event Claimed(address account, uint256 amount);

    address[] claimers;
    mapping(address claimer => bool claim) private s_hasClaimed;

    // some list of addresses
    // allow someone in the list to claim token
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    // constructor
    /**
     * When a new MerkleAirdrop is created,
     * we have to pass the merkle root and airdrop token address in the constructor.
     **@param merkleRoot The merkle root
     * @param airdropToken The airdopTokn
     * */
    constructor (bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /**
     * 
     * @param account The account the user wants to claim the token in
     * @param amount The token amount that the user wants to claim
     * @param merkeleProof This includes hashes of the sibling nodes in the merkle tree
     */

    function claim(address account, uint256 amount, bytes32[] calldata merkeleProof) external {

        // if the account has already claimed then revert
        if (s_hasClaimed[account]) {
            revert MerkleAirDrop_AlreadyClaimed(account);
        }
         // leaf -> take address and amount and hash it 
         bytes32 leaf = keccak256(abi.encode(account, amount));

         // proof 
         // if the proof is invalid then revert
        if (!MerkleProof.verify(merkeleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop_InvalidProof();
        }
        // update the mapping for claim account 
        s_hasClaimed[account] = true;
        
        // emit the event as claimed
        emit Claimed(account, amount);
        
        // if the proof is valid then claim
        i_airdropToken.safeTransfer(account, amount);
    }


    function getAirDropToken() public view returns (IERC20) {
        return i_airdropToken;
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }
    
    function getClaimerStutus(address account) public view returns (bool) {
        return s_hasClaimed[account];
    }

}