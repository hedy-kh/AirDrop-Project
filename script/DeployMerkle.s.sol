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

contract deployerMerkle is Script {
    bytes32 s_merkle = 0x6e0a8ef529f24dc8a81283499f31c8389fc0af804f31c69b943fcf114ae1229c;
    uint256 s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirDrop() public returns (MerkleAirDrop, Token) {
        vm.startBroadcast();
        Token token = new Token();
        MerkleAirDrop airdrop = new MerkleAirDrop(s_merkle, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();
        return (airdrop, token);
    }

    function run() external returns (MerkleAirDrop, Token) {
        return deployMerkleAirDrop();
    }
}
// function deployMerkleAirdrop() public returns (MerkleAirdrop, BagelToken) {
//     vm.startBroadcast();
//     BagelToken bagelToken = new BagelToken();
//     MerkleAirdrop airdrop = new MerkleAirdrop(ROOT, IERC20(bagelToken));
//     // Send Bagel tokens -> Merkle Air Drop contract
//     bagelToken.mint(bagelToken.owner(), AMOUNT_TO_TRANSFER);
//     IERC20(bagelToken).transfer(address(airdrop), AMOUNT_TO_TRANSFER);
//     vm.stopBroadcast();
//     return (airdrop, bagelToken);
// }
