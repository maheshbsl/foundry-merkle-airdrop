// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^ 0.8.26;

import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {BagelToken} from "src/BagelToken.sol";
import {Test} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Test {
   
   bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
   uint256 public s_amountToTransfer = 4 * 25 * 10**18;
   MerkleAirdrop airdrop;
   BagelToken token;

   function run() external returns (MerkleAirdrop, BagelToken) {
       return deployMerkleAirdrop();
   }

   function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
       vm.startBroadcast();
       airdrop = new MerkleAirdrop(ROOT, IERC20(address(token)));
       token = new BagelToken();
       // mint some tokens to the contract deployer
       token.mint(token.owner(),s_amountToTransfer);
       // transfer the tokens to the airdrop
       token.transfer(address(airdrop), s_amountToTransfer);
       vm.stopBroadcast();
       return (airdrop, token);
   }
}