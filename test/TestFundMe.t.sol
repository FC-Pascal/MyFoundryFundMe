// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "./mocks/MockV3Aggregator.sol";

contract TestFundMe is Test {
    FundMe public fundMe;
    MockV3Aggregator public mockV3Aggregator;

    address public USER = makeAddr("user");
    address public OWNER;

    function setUp() public {
        OWNER = address(this);
        mockV3Aggregator = new MockV3Aggregator(8, 2000e8); // 2000 USD
        fundMe = new FundMe(address(mockV3Aggregator));
        vm.deal(USER, 10 ether);
    }

    function testFundingFailsWithoutMinimumEth() public {
        vm.prank(USER);
        vm.expectRevert(bytes("You need to spend more ETH!"));
        fundMe.fund{value: 1 wei}();
    }

    function testFundingUpdatesDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: 1 ether}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 1 ether);
    }

    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: 1 ether}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.prank(USER);
        vm.expectRevert(bytes("Not owner"));
        fundMe.withdraw();
    }

    function testOwnerCanWithdraw() public {
        vm.prank(USER);
        fundMe.fund{value: 1 ether}();
        // check balances before

        uint256 ownerStartBalnace = OWNER.balance;
        uint256 contractBal = address(fundMe).balance;

        vm.prank(OWNER); // call from owner
        fundMe.withdraw();

        uint256 ownerEndBal = OWNER.balance;
        assertEq(address(fundMe).balance, 0); // contract balance should be 0
        assertEq(ownerEndBal, ownerStartBalnace + contractBal); // owner received the balance
    }

    function testMultipleFundersWithdraw() public {
        address funder1 = makeAddr("funder1");
        address funder2 = makeAddr("funder2");

        vm.deal(funder1, 1 ether);
        vm.deal(funder2, 1 ether);

        vm.prank(funder1);
        fundMe.fund{value: 1 ether}();

        vm.prank(funder2);
        fundMe.fund{value: 1 ether}();

        uint256 startingBalance = OWNER.balance;
        uint256 contractBal = address(fundMe).balance;

        vm.prank(OWNER);
        fundMe.withdraw();

        uint256 endingBalance = OWNER.balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(endingBalance, startingBalance + contractBal); // Assuming owner started with 0
    }

    function testMultipleFundersCheaperWithdraw() public {
        address funder1 = makeAddr("funder1");
        address funder2 = makeAddr("funder2");

        vm.deal(funder1, 1 ether);
        vm.deal(funder2, 1 ether);

        vm.prank(funder1);
        fundMe.fund{value: 1 ether}();

        vm.prank(funder2);
        fundMe.fund{value: 1 ether}();

        uint256 startingBalance = OWNER.balance;
        uint256 contractBal = address(fundMe).balance;

        vm.prank(OWNER);
        fundMe.cheaperWithdraw();

        uint256 endingBalance = OWNER.balance;

        assertEq(address(fundMe).balance, 0);
        assertEq(endingBalance, startingBalance + contractBal); // Assuming owner started with 0
    }

    receive() external payable {}
}
