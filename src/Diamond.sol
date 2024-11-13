// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IDiamondCut} from "./interfaces/IDiamondCut.sol";
import "forge-std/console.sol";

contract Diamond is IDiamondCut {
    // Simple mapping to store which function goes to which facet
    mapping(bytes4 => address) public functionToFacet;
    address public owner;

    constructor() {
        owner = msg.sender;
        console.log("Diamond deployed, owner:", owner);
    }

    function addFunction(address facetAddress, bytes4 functionSelector) external {
        require(msg.sender == owner, "Only owner");
        require(functionToFacet[functionSelector] == address(0), "Function already exists");
        functionToFacet[functionSelector] = facetAddress;
        console.log("Added function selector:", uint32(functionSelector));
        console.log("to facet:", facetAddress);
    }

    fallback() external payable {
        address facet = functionToFacet[msg.sig];
        require(facet != address(0), "Function does not exist");

        console.log("Fallback called with selector:", uint32(msg.sig));
        console.log("Delegating to facet:", facet);

        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable {}
}
