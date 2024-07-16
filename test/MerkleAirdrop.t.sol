// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/Merkle-Airdrop.sol";
import {PranavCoin} from "../src/PranavCoin.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop private airdrop;
    PranavCoin private token;
    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address user;
    uint256 userAmount;

    function setUp() public {
        token = new PranavCoin();
        airdrop = new MerkleAirdrop(ROOT, token);
        (user, userAmount) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {}
}
