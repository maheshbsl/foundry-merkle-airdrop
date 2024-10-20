// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {

    function run() external  {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("DeployMerkleAirdrop", block.chainid);
        claimAirDrop(mostRecentlyDeployed);
    }

    function claimAirDrop(address airdrop) public {

    }
}