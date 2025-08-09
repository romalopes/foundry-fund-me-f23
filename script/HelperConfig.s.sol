// SPDX-LICENSE-Identifier: MIT
pragma solidity 0.8.19;
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
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
            activeNetworkConfig = getAnvilEth();
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

    function getAnvilEth() public pure returns (NetworkConfig memory) {
        // This function is a placeholder for getting the Anvil ETH address.
        // In a real implementation, you would fetch this from an environment variable or configuration.
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress: 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43 // Example address
        });
        return sepoliaConfig;
    }
}
