// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";

/*
@title MerkleAirdrop
@notice This contract is used to distribute tokens to a list of addresses using Merkle Proofs
@author Pranav Lakkadi
*/
contract MerkleAirdrop is EIP712{
    //    List of addresses
    //    Only the address in the list can claim the tokens
    //    address[] public addresses;  ---> This way is too expensive and can cause DOS attacks
    using SafeERC20 for IERC20;

    //////////////////////////////////////////////
    ///////////////// ERRORS /////////////////////
    //////////////////////////////////////////////
    error MerkleAirdrop__ClaimFailedInvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error  MerkleAirdrop__InvalidSignature();

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

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirDropClaim(address account,uint256 amount)");

    struct AirDropClaim {
        address account;
        uint256 amount;
    }

    constructor(bytes32 merkleRoot, IERC20 token) EIP712("MerkleAirdrop","1") {
        i_merkleRoot = merkleRoot;
        i_token = token;
    }

    //////////////////////////////////////////////
    //////////// CORE FUNCTIONS //////////////////
    //////////////////////////////////////////////

    function claimSelf(bytes32[] calldata merkleProof, uint256 amount) external {
        //        using the account and the amount we can calculate the leaf node (hash)

        if (s_claimed[msg.sender]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        //        here we are hashing the leaf twice to prevent it from pre image attack if ever their is another
        //        leaf that produces the same hash , but anyhow keccak is secure enough to prevent this but we
        //        are doing it as a practice that we follow
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__ClaimFailedInvalidProof();
        }
        s_claimed[msg.sender] = true;

        emit AirdropClaim(msg.sender, amount);
        SafeERC20.safeTransfer(i_token, msg.sender, amount);
    }

    function claim_By_Permit(
        bytes32[] calldata merkleProof,
        address account,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_claimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // check the signature
        if (!_isValidSignature(account, _getMessage(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__ClaimFailedInvalidProof();
        }
        s_claimed[account] = true;

        emit AirdropClaim(account, amount);
        SafeERC20.safeTransfer(i_token, account, amount);
    }


    function claim_By_Permit_By_Signature(
        bytes32[] calldata merkleProof,
        address account,
        uint256 amount,
        bytes memory signature
    ) external {
        if (s_claimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // check the signature
        if (!_isValidSignature(account, _getMessage(account, amount), signature)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__ClaimFailedInvalidProof();
        }
        s_claimed[account] = true;

        emit AirdropClaim(account, amount);
        SafeERC20.safeTransfer(i_token, account, amount);
    }

    //////////////////////////////////////////////
    //////////// INTERNAL FUNCTIONS //////////////
    //////////////////////////////////////////////

    function _isValidSignature(
        address account,
        bytes32 message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address signer, ,) = ECDSA.tryRecover(message, v, r, s);
        return signer == account;
    }

    function _isValidSignature(
        address account,
        bytes32 message,
        bytes memory signature
    ) internal pure returns (bool) {
        (address signer, ,) = ECDSA.tryRecover(message, signature);
        return signer == account;
    }


    function _getMessage(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirDropClaim({account: account, amount: amount})))
        );
    }

    //////////////////////////////////////////////
    //////////// GETTER FUNCTIONS ////////////////
    //////////////////////////////////////////////

    function claimedAirdrop(address account) external view returns (bool) {
        return s_claimed[account];
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getToken() external view returns (address) {
        return address(i_token);
    }
}
