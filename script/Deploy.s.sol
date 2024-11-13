// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/Diamond.sol";
import "../src/facets/CounterFacet.sol";
import "./DiamondManager.s.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Diamond and Facets
        Diamond diamond = new Diamond();
        CounterFacet counterFacet = new CounterFacet();

        // Create Diamond Manager
        // DiamondManager manager = new DiamondManager();

        // Add initial facet
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = CounterFacet.increment.selector;
        selectors[1] = CounterFacet.getCount.selector;

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(counterFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: selectors
        });

        diamond.diamondCut(cuts, address(0), "");

        vm.stopBroadcast();
    }
}
