// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IDiamondCut {
    // Define possible actions for facets
    enum FacetCutAction {
        Add, // Add new functions
        Replace, // Replace existing functions
        Remove // Remove functions

    }

    // Structure for facet modifications
    struct FacetCut {
        address facetAddress;
        FacetCutAction action;
        bytes4[] functionSelectors;
    }

    // Main function to modify diamond
    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;

    // Events to log changes
    event DiamondCut(FacetCut[] _diamondCut, address _init, bytes _calldata);
}
