//SPDX-License-Identifier:MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirDrop} from "../src/MerkleAirdrop.sol";
import {Token} from "../src/Token.sol";
import {ZkSyncChainChecker} from "../lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {deployerMerkle} from "../script/DeployMerkle.s.sol";

contract MerkleRootTest is ZkSyncChainChecker, Test {
    MerkleAirDrop public Merkle;
    Token public token;
    bytes32 public root = 0x6e0a8ef529f24dc8a81283499f31c8389fc0af804f31c69b943fcf114ae1229c;
    address user;
    address GasPayer;
    uint256 userPrivateKey;
    uint256 public constant AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public constant AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 constant PROOF1 = 0xb7aa5046099c28f99fc73360f3e7d70fa0e996c2955e298d65e7230e59bb7828;
    bytes32 constant PROOF2 = 0xf4216065bf6ac971b2f1ba0fef5920345dcaeceabf5f200030a1cd530dd44a89;
    bytes32[] public PROOF = [PROOF1, PROOF2];
    //uint256 private constant ANVIL_USER_PK = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    //address private constant ANVIL_USER_ADD = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
        if (!isZkSyncChain()) {
            deployerMerkle deployer = new deployerMerkle();
            (Merkle, token) = deployer.deployMerkleAirDrop();
        } else {
            token = new Token();
            Merkle = new MerkleAirDrop(root, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(Merkle), AMOUNT_TO_SEND);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
        GasPayer = makeAddr("GasPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = Merkle.getMessage(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        vm.prank(GasPayer);
        Merkle.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
