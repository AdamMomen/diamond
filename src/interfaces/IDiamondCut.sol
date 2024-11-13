// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IDiamondCut {
    // Just one simple function to add a new function to our diamond
    function addFunction(address facetAddress, bytes4 functionSelector) external;
}
