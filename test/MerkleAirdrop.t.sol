// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/Merkle-Airdrop.sol";
import {PranavCoin} from "../src/PranavCoin.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.sol";

contract MerkleAirdropTest is Test,ZkSyncChainChecker {
    MerkleAirdrop private airdrop;
    PranavCoin private token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    uint256 AmountToClaim = 25 * 1e18;
    uint256 AmountToMint = AmountToClaim * 4;

    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proofOne, proofTwo];
    address user;
    uint256 userPrivKey;

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.deployMerkleAirdrop();
        }
        else {
        token = new PranavCoin();
        airdrop = new MerkleAirdrop(ROOT, IERC20(address(token)));
        token.mint(address(airdrop), AmountToMint);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
    }

    function testUsersCanClaim() public {
        uint256 startBalance = token.balanceOf(user);

        vm.prank(user);
        //        "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D",
        //      "25000000000000000000"
        airdrop.claim(PROOF, address(user), AmountToClaim);
        //        airdrop.claim(PROOF, 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D, 25000000000000000000);
        uint256 endBalance = token.balanceOf(user);
        assert(endBalance > startBalance);
    }
}
