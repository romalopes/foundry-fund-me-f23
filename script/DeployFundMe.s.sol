// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    // FundMe public fundMe;

    function run() external returns (FundMe) {
        // 1. Get the price feed address from HelperConfig.  Get the active network configuration basead on the chain ID.
        HelperConfig helperConfig = new HelperConfig();
        address PRICE_FEED_ADDRESS = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(PRICE_FEED_ADDRESS);
        vm.stopBroadcast();
        return fundMe;
    }
}
