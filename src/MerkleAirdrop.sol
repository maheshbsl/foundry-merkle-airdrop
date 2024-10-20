// SPDX-License-Identifier: SEE LICENSE IN LICENSE

pragma solidity ^0.8.26;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712 {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    error MerkleAirdrop_InvalidProof();
    error MerkleAirDrop_AlreadyClaimed(address account);
    error MerkleAirdrop_InavlidSignature();

    event Claimed(address account, uint256 amount);

    address[] claimers;
    mapping(address claimer => bool claim) private s_hasClaimed;

    struct  AirdropClaim {
        address account;
        uint256 amount;
    }

    bytes32 public constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    // some list of addresses
    // allow someone in the list to claim token
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdropToken;

    // constructor
    /**
     * When a new MerkleAirdrop is created,
     * we have to pass the merkle root and airdrop token address in the constructor.
     * @param merkleRoot The merkle root
     * @param airdropToken The airdopTokn
     *
     */
    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1.0") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }
    /**
     *
     * @param account The account the user wants to claim the token in
     * @param amount The token amount that the user wants to claim
     * @param merkeleProof This includes hashes of the sibling nodes in the merkle tree
     * @param v The signature v
     * @param r The signature r
     * @param s The signature s
     */

    function claim(address account, uint256 amount, bytes32[] calldata merkeleProof, uint8 v, bytes32 r, bytes32 s) external {
        // if the account has already claimed then revert
        if (s_hasClaimed[account]) {
            revert MerkleAirDrop_AlreadyClaimed(account);
        }
        //if the signature is invalid then revert
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop_InavlidSignature();
        }
        // leaf -> take address and amount and hash it
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

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
    /**
     * @param account The address of the account that is claiming the airdrop
     * @param amount The amount of the token that the user wants to claim
     * @return the digest (combine the domain separator and hash message, add the eip191 prefix, hash the result)
     */
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount})))
        );
    }

    function _isValidSignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s) public pure returns (bool) {
        (address recoveredAddress,,) = ECDSA.tryRecover(digest, v, r, s);
        return recoveredAddress == account;
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
