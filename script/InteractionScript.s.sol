// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/Merkle-Airdrop.sol";
//import {Console} from "forge-std/Console.sol";

contract ClaimAirdropScript is Script {

    address ClaimingAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 ClaimingAmount = 25000000000000000000;

    bytes32 proofPermitOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofPermitTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] proof = [proofPermitOne, proofPermitTwo];

    bytes private SIGNATURE = hex"1fabe6bce5a0b52e2f0c22db537866e2e7ea6d4e2dcc3ae57c975af39b11656873871bfbdf5067eda988e71114b875bfe9d492ce0911fd39273870a79873b28e1c";


    function run() external {
        address mostRecentContract = DevOpsTools.get_most_recent_deployment("MerkleAirdrop",block.chainid);
        ClaimAirdrop(mostRecentContract);
    }

    function ClaimAirdrop(address airdrop) internal {

        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);

        vm.startBroadcast();
        MerkleAirdrop airdropContract = MerkleAirdrop(airdrop);
        airdropContract.claim_By_Permit(proof,ClaimingAddress,ClaimingAmount,v,r,s);
//        console.log("Claimed Airdrop");
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}