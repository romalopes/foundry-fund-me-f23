// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public constant DECIMAL = 8; // 8 decimals for ETH/USD
    int256 public constant INITIAL_PRICE = 2000 * 10 ** 8; // Initial answer of 2000 USD for 1 ETH

    NetworkConfig public activeNetworkConfig;
    struct HelperConfigData {
        address priceFeedAddress;
    }

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia
            // console.log("Using Sepolia network configuration");
            activeNetworkConfig = getSepoliaEth();
        } else if (block.chainid == 31337) {
            // Anvil
            activeNetworkConfig = getOrCreateAnvilEth();
            // console.log("Using Anvil network configuration");
        } else {
            revert("Unsupported network");
        }
        // This constructor is intentionally left empty.
        // It can be used to initialize any state variables if needed in the future.
    }

    function getSepoliaEth() public pure returns (NetworkConfig memory) {
        // This function is a placeholder for getting the Alchemy Sepolia ETH address.
        // In a real implementation, you would fetch this from an environment variable or configuration.
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43 // Example address
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEth() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }
        // 1. Deploy the mocks
        // 2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );

        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeedAddress: address(mockV3Aggregator)
        });
        return anvilConfig;
    }
}
