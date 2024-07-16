// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
    //    List of addresses
    //    Only the address in the list can claim the tokens
    //    address[] public addresses;  ---> This way is too expensive and can cause DOS attacks
    using SafeERC20 for IERC20;

    //////////////////////////////////////////////
    ///////////////// ERRORS /////////////////////
    //////////////////////////////////////////////
    error MerkleAirdrop__ClaimFailedInvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    //////////////////////////////////////////////
    ///////////////// EVENTS /////////////////////
    //////////////////////////////////////////////
    event AirdropClaim(address indexed account, uint256 indexed amount);

    //////////////////////////////////////////////
    //////////// STATE VARIABLES /////////////////
    //////////////////////////////////////////////
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_token;
    mapping(address => bool) public s_claimed;

    constructor(bytes32 merkleRoot, IERC20 token) {
        i_merkleRoot = merkleRoot;
        i_token = token;
    }

    //////////////////////////////////////////////
    //////////// CORE FUNCTIONS //////////////////
    //////////////////////////////////////////////

    function claim(bytes32[] calldata merkleProof, address account, uint256 amount) external {
        //        using the account and the amount we can calculate the leaf node (hash)

        if (s_claimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        //        here we are hashing the leaf twice to prevent it from pre image attack if ever their is another
        //        leaf that produces the same hash , but anyhow keccak is secure enough to prevent this but we
        //        are doing it as a practice that we follow
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__ClaimFailedInvalidProof();
        }
        s_claimed[account] = true;

        emit AirdropClaim(account, amount);
        SafeERC20.safeTransfer(i_token, account, amount);
    }

    //////////////////////////////////////////////
    //////////// GETTER FUNCTIONS ////////////////
    //////////////////////////////////////////////

    function ClaimedAirdrop(address account) external view returns (bool) {
        return s_claimed[account];
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getToken() external view returns (IERC20) {
        return i_token;
    }
}
