// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test} from "forge-std/Test.sol";
import {MyToken} from "../src/MyToken.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";

contract MyTokenTest is Test {
    MyToken public myToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        DeployMyToken deployMyToken = new DeployMyToken();
        myToken = deployMyToken.run();

        vm.prank(msg.sender);
        myToken.transfer(bob, STARTING_BALANCE);
    }

    function testBobBalance() public {
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        // Bob approves Alice to spend tokens on his behalf
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        uint256 transferAmount = 50;

        vm.prank(bob);
        myToken.transfer(alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);
        assertEq(myToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testTransferFromInsufficientAllowance() public {
        uint256 initialAllowance = 10;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 20;

        vm.prank(alice);
        vm.expectRevert();
        // This should fail as the allowance is insufficient
        myToken.transferFrom(bob, alice, transferAmount);
    }

    function testTransferFromZeroAllowance() public {
        uint256 transferAmount = 20;

        vm.prank(alice);
        vm.expectRevert();
        // This should fail as Alice has zero allowance from Bob
        myToken.transferFrom(bob, alice, transferAmount);
    }
}
