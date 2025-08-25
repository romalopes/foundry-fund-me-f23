// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMerTest is Test {
    FundMe public fundMe;
    uint256 public number = 5e18; //5 * 10 ** 18;
    address USER = makeAddr("user");

    uint256 public constant SEND_VALUE = 0.1 ether; // just a value to make sure we are sending enough!
    uint160 public constant USER_NUMBER = 50;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    // address public constant USER = address(USER_NUMBER);

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether); // Give USER 10 ETH
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

    function test_fundNotEnoughEth() public {
        // Test that funding with less than the minimum USD fails
        vm.expectRevert("You need to spend more ETH!");
        uint256 insufficientAmount = 1 * 10; // 1 ETH is less than the minimum USD requirement
        // vm.deal(address(this), insufficientAmount); // Send 1 ETH to this contract
        // vm.startPrank(address(this)); // Start a prank as this address
        fundMe.fund{value: insufficientAmount}(); // Call the fund function
            // vm.stopPrank();
            // The above line should revert, so we don't need to check the state after this
            // assertEq(fundMe.getFunder(0), address(this)); // This line would fail if the revert occurs
            // assertEq(fundMe.getAddressToAmountFunded
            // fundMe.fund{value: 1 * 10 ** 18}(); // 1 ETH is less than the minimum USD requirement
    }

    function testFundUpdatesFundedDataStructure() public {
        fundMe.fund{value: 10e18}(); // Fund the contract with 10 ETH
        uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this));
        assertEq(amountFunded, 10e18); // Check that the amount funded is correct
        address funder = fundMe.getFunder(0);
        assertEq(funder, address(this)); // Check that the funder is correct
            // assertEq(msg.sender, funder); // Check that the sender is correct
            // assertEq(msg.sender, address(this)); // Check that the sender is correct
    }

    function testFundUpdatesFundedDataStructureWithPrank() public {
        vm.prank(USER); // Start a prank as USER
        fundMe.fund{value: 10e18}(); // Fund the contract with 10 ETH
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, 10e18); // Check that the amount funded is correct
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); // Check that the funder is correct
            // assertEq(msg.sender, funder); // Check that the sender is correct
            // assertEq(msg.sender, address(this)); // Check that the sender is correct
    }

    function test_fund() public {
        // Test the fund function
        uint256 value = 5 * 10 ** 18; // 5 ETH
        vm.deal(address(this), value); // Send 5 ETH to this contract
        vm.startPrank(address(this)); // Start a prank as this address
        fundMe.fund{value: value}(); // Call the fund function
        vm.stopPrank();

        // Check that the funder has been added
        assertEq(fundMe.getFunder(0), address(this));
        assertEq(fundMe.getAddressToAmountFunded(address(this)), value);
        //  assertEq(msg.sender, address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testAddsFunderToArayofFunders() public {
        // Test that the funder is added to the array of funders
        vm.prank(USER); // Start a prank as USER
        fundMe.fund{value: 10e18}(); // Fund the contract with 10 ETH
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER); // Check that the funder is correct
    }

    modifier funded() {
        vm.prank(USER); // Start a prank as USER
        fundMe.fund{value: 10e18}(); // Fund the contract with 10 ETH
        _;
    }

    uint256 internal constant GAS_PRICE = 1;

    function testOnlyOwnerCanWithdraw() public funded {
        // Test that only the owner can withdraw
        // vm.expectRevert("Ownable: caller is not the owner");
        // vm.expectRevert(FundMe__NotOwner());

        vm.expectRevert();
        fundMe.withdraw(); // Attempt to withdraw as USER
    }

    function testWithdrawWithaSingleFunder() public funded {
        // Test the withdraw function with a single funder
        uint256 initialOnwerBalance = fundMe.getOwner().balance;
        uint256 initialFundMeBalance = address(fundMe).balance;

        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE); // Set gas price to 0 for testing
        vm.prank(fundMe.getOwner()); // Start a prank as the owner
        fundMe.withdraw(); // Withdraw funds
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        console.log("Gas used for withdraw: %s", gasUsed);
        console.log("Initial Owner Balance: %s", initialOnwerBalance);
        console.log("Initial FundMe Balance: %s", initialFundMeBalance);
        // Check the final balances
        uint256 finalOnwerBalance = fundMe.getOwner().balance;
        uint256 finalFundMeBalance = address(fundMe).balance;
        assertEq(finalFundMeBalance, 0); // Check that the contract balance is 0
        assertEq(initialFundMeBalance + initialOnwerBalance, finalOnwerBalance); // Check that the owner's balance is updated correctly
        assertEq(fundMe.getAddressToAmountFunded(USER), 0); // Check that the amount funded is reset to 0
    }

    // Can we do our withdraw function a cheaper way?
    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2 + USER_NUMBER;

        uint256 originalFundMeBalance = address(fundMe).balance; // This is for people running forked tests!

        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundedeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundedeBalance + startingOwnerBalance == fundMe.getOwner().balance);

        uint256 expectedTotalValueWithdrawn = ((numberOfFunders) * SEND_VALUE) + originalFundMeBalance;
        uint256 totalValueWithdrawn = fundMe.getOwner().balance - startingOwnerBalance;

        assert(expectedTotalValueWithdrawn == totalValueWithdrawn);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2 + USER_NUMBER;

        uint256 originalFundMeBalance = address(fundMe).balance; // This is for people running forked tests!

        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // we get hoax from stdcheats
            // prank + deal
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundedeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundedeBalance + startingOwnerBalance == fundMe.getOwner().balance);

        uint256 expectedTotalValueWithdrawn = ((numberOfFunders) * SEND_VALUE) + originalFundMeBalance;
        uint256 totalValueWithdrawn = fundMe.getOwner().balance - startingOwnerBalance;

        assert(expectedTotalValueWithdrawn == totalValueWithdrawn);
    }
}
