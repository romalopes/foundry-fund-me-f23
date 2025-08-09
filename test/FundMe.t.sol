// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMerTest is Test {
    FundMe public fundMe;
    uint256 public number = 5e18; //5 * 10 ** 18;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function test_FundMe() public view {
        console.log("\n\n-----FundMe contract deployed successfully\n\n");
        // Test the initial state of the contract
        assertEq(number, 5 * 10 ** 18);
        // assertEq(fundMe.i_owner(), address(this));
    }

    function test_minimumUsd() public view {
        // Test the minimum USD requirement
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function test_ownerIsMsgSender() public view {
        // Test that the owner is the message sender
        console.log("msg.sender: %s", msg.sender);
        // assertEq(fundMe_2.getOwner(), msg.sender);
        // assertEq(fundMe_2.getOwner(), address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function test_isPriceFeedVersionAccurate() public view {
        // Test that the price feed version is accurate
        uint256 version = fundMe.getVersion();
        console.log("Price Feed Version: %s", version);
        require(version > 0, "Price feed version should be greater than 0");
        assert(version == 4);
        assertEq(version, 4);
    }
}
