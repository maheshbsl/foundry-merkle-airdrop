// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Test, console} from "forge-std/Test.sol";
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
    bytes32 proof1 = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proof2 = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public proof = [proof1, proof2];
    address gasPayer;
    address user;
    uint256 privateKey;

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
        (user, privateKey) = makeAddrAndKey("user");
         gasPayer = makeAddr("gasPayer");
    }

    function testanyoneCanClaimUsingSignature() public {
        // staring balance
        uint256 startingBalnce = token.balanceOf(user);
        // gettig the message hash
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        // sign the message with the user's private key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        // claim the airdrop using the user signature by the gasPayer
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, proof, v, r, s);

        // balance of the user after claim
        uint256 balanceAfterClaim = token.balanceOf(user);
        assert(balanceAfterClaim == startingBalnce + AMOUNT_TO_CLAIM);
    }

    function testUserCanClaim() public  view{
       console.log("user address: ", user);
    }
}
