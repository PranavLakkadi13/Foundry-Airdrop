// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MerkleAirdrop} from "../src/Merkle-Airdrop.sol";
import {PranavCoin} from "../src/PranavCoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Script} from "forge-std/Script.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 amountToMint = 25 * 1e18 * 4;


    function run() external returns (MerkleAirdrop, PranavCoin) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, PranavCoin) {
        vm.startBroadcast();
        PranavCoin token = new PranavCoin();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(address(airdrop), amountToMint);
        vm.stopBroadcast();
        return (airdrop, token);
    }
}
