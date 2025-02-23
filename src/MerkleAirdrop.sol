//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirDrop is EIP712 {
    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    error MerkleAirDrop__invalidProof();
    error MerkleAirDrop__Claimed();
    error MerkleAirDrop__InvalidSignature();

    event Claim(address indexed account, uint256 indexed amount);

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");
    IERC20 private immutable i_token;
    mapping(address claimer => bool claimed) private s_hasClaimed;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    constructor(bytes32 merkleRoot, IERC20 airDropToken) EIP712("MerkleAirDrop", "1.0.0") {
        i_merkleRoot = merkleRoot;
        i_token = airDropToken;
    }

    function _isValidSig(address signer, bytes32 digest, uint8 _v, bytes32 _r, bytes32 _s)
        internal
        pure
        returns (bool)
    {
        // could also use SignatureChecker.isValidSignatureNow(signer, digest, signature)
        (
            address actualSigner,
            /*ECDSA.RecoverError recoverError*/
            ,
            /*bytes32 signatureLength*/
        ) = ECDSA.tryRecover(digest, _v, _r, _s);
        return (actualSigner == signer);
    }

    function getMessage(address account, uint256 amount) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({account: account, amount: amount}))));
    }

    function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
        external
    {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (s_hasClaimed[account]) {
            revert MerkleAirDrop__Claimed();
        }
        if (!_isValidSig(account, getMessage(account, amount), v, r, s)) {
            revert MerkleAirDrop__InvalidSignature();
        }
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirDrop__invalidProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_token.safeTransfer(account, amount);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_token;
    }
}
