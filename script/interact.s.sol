// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
// import {stdJson} from "forge-std/StdJson.sol";
// import {console} from "forge-std/console.sol";
// import {Merkle} from "../lib/murky/src/Merkle.sol";
// import {ScriptHelper} from "../lib/murky/script/common/ScriptHelper.sol";
import {MerkleAirDrop} from "../src/MerkleAirdrop.sol";
import {Token} from "../src/Token.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirDrop is Script {
    error interact__InvalidLength();

    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32 private constant Proof1 = 0x0c7ef881bb675a5858617babe0eb12b538067e289d35d5b044ee76b79d335191;
    bytes32 private constant Proof2 = 0xfdca9e97c40387b7da86b5d064b51680043907b9a9bbb0b58b2a1d82f87e69c7;
    bytes32[] PROOF = [Proof1, Proof2];
    bytes private constant SIGNATURE =
        hex"c090c93f0d124aa8355d2dfc251bb027707722c84849db4c0ac8456c3d6be46163475b0e8a57bc795af6581945a41781202542094f2eb7c0d111d489d88b9bc91b";

    function claimairdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirDrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function splitSignature(bytes memory Sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        //require(Sig.length ==65 ,"invalid signature length");
        if (Sig.length != 65) {
            revert interact__InvalidLength();
        }
        assembly {
            r := mload(add(Sig, 32))
            s := mload(add(Sig, 64))
            v := byte(0, mload(add(Sig, 96)))
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirDrop", block.chainid);
        claimairdrop(mostRecentlyDeployed);
    }
}
