// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/Diamond.sol";
import "../src/facets/CounterFacet.sol";
import "../src/facets/CounterFacetV2.sol";
import "./DiamondManager.s.sol";

contract UpgradeScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Get deployed contracts (replace with actual addresses)
        Diamond diamond = Diamond(payable(vm.envAddress("DIAMOND_ADDRESS")));
        CounterFacet oldFacet = CounterFacet(payable(vm.envAddress("COUNTER_FACET_ADDRESS")));

        // Deploy new facet
        CounterFacetV2 newFacet = new CounterFacetV2();

        // Create manager and upgrade
        DiamondManager manager = new DiamondManager();
        manager.upgradeFacet(diamond, address(oldFacet), address(newFacet));

        vm.stopBroadcast();
    }
}
