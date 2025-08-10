// Fund
// Withdraw

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script {
    // FundMe public fundMe;
    function fundFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(mostRecentDeployment));
        fundMe.fund{value: 0.1 ether}(); // Fund with 0.01 ETH
        vm.stopBroadcast();
        console.log("Funded FundMe contract at address: %s", mostRecentDeployment);
        console.log("Funded with 0.01 ETH");
        console.log("Current balance: %s", address(fundMe).balance);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // vm.startBroadcast();
        fundFundMe(mostRecentDeployed);
        // vm.stopBroadcast();
        console.log("Funded FundMe contract at address: %s", mostRecentDeployed);
        console.log("Current balance: %s", address(mostRecentDeployed).balance);
    }
}

contract WithdrawFundMe is Script {
    // FundMe public fundMe;
    function withdrawFundMe(address mostRecentDeployment) public {
        vm.startBroadcast();
        FundMe fundMe = FundMe(payable(mostRecentDeployment));
        fundMe.withdraw(); // Fund with 0.01 ETH
        vm.stopBroadcast();
        console.log("Funded FundMe contract at address: %s", mostRecentDeployment);
        console.log("Current balance: %s", address(fundMe).balance);
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // vm.startBroadcast();
        withdrawFundMe(mostRecentDeployed);
        // vm.stopBroadcast();
        console.log("Funded FundMe contract at address: %s", mostRecentDeployed);
        console.log("Current balance: %s", address(mostRecentDeployed).balance);
    }
}
