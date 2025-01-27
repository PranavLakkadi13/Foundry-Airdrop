// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/Merkle-Airdrop.sol";
import {PranavCoin} from "../src/PranavCoin.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test,ZkSyncChainChecker {
    MerkleAirdrop private airdrop;
    PranavCoin private token;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;

    uint256 AmountToClaim = 25 * 1e18;
    uint256 AmountToMint = AmountToClaim * 4;

    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOF = [proofOne, proofTwo];


    bytes32 proofPermitOne = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 proofPermitTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] PROOFPERMIT = [proofPermitOne, proofPermitTwo];

    address user;
    address bob;
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
        bob = vm.addr(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);
    }

    function testUsersCanClaim() public {
        uint256 startBalance = token.balanceOf(user);

        vm.prank(user);
        //        "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D",
        //      "25000000000000000000"
        airdrop.claimSelf(PROOF, AmountToClaim);
        //        airdrop.claim(PROOF, 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D, 25000000000000000000);
        uint256 endBalance = token.balanceOf(user);
        assert(endBalance > startBalance);
    }

    function testUserCanClaimWithPermit() public {
        uint256 startBalance = token.balanceOf(bob);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80,airdrop._getMessage(bob, AmountToClaim));

        vm.prank(user);
        airdrop.claim_By_Permit(PROOFPERMIT, bob, AmountToClaim, v, r, s);

        uint256 endBalance = token.balanceOf(bob);
        assert(endBalance > startBalance);
    }

    function testUserCanClaimWithPermitBySignature() public {
        uint256 startBalance = token.balanceOf(bob);

        bytes memory signature = hex"1fabe6bce5a0b52e2f0c22db537866e2e7ea6d4e2dcc3ae57c975af39b11656873871bfbdf5067eda988e71114b875bfe9d492ce0911fd39273870a79873b28e1c";

        vm.prank(user);
        airdrop.claim_By_Permit_By_Signature(PROOFPERMIT, address(bob), AmountToClaim, signature);

        uint256 endBalance = token.balanceOf(bob);
        assert(endBalance > startBalance);
    }
}
