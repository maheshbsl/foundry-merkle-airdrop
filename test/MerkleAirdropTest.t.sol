// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    MerkleAirdrop airdrop;
    BagelToken token;
    DeployMerkleAirdrop deployer;
    bytes32 public constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public constant AMOUNT_TO_CLAIM = 25 * 10**18; // a user can claim 25 bagel
    uint256 public s_amountToTransfer = 4 * 25 * 10**18;

    function setUp() public {
        if (!isZkSyncChain()) {
            deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.run();
        }else {
            // if it is zksync chain, we have to deploy manually
            airdrop = new MerkleAirdrop(ROOT, IERC20(address(token)));
            token = new BagelToken();
            // mint some tokens to the contract deployer
            token.mint(token.owner(), s_amountToTransfer);
            // transfer the tokens to the airdrop
            token.transfer(address(airdrop), s_amountToTransfer);
        }
    }

    function testuserCanClaim() public {}
}
