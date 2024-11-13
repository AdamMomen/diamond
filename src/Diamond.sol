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

    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external {
        require(msg.sender == owner, "Only owner");

        // Map facet operations
        for (uint256 i = 0; i < _diamondCut.length; i++) {
            FacetCut calldata cut = _diamondCut[i];

            if (cut.action == FacetCutAction.Add) {
                addFunctions(cut.facetAddress, cut.functionSelectors);
            } else if (cut.action == FacetCutAction.Replace) {
                replaceFunctions(cut.facetAddress, cut.functionSelectors);
            } else if (cut.action == FacetCutAction.Remove) {
                removeFunctions(cut.functionSelectors);
            }
        }

        emit DiamondCut(_diamondCut, _init, _calldata);
    }

    function addFunctions(address facetAddress, bytes4[] calldata functionSelectors) internal {
        require(facetAddress != address(0), "Can't add function to zero address");
        console.log("Adding functions to facet:", facetAddress);

        for (uint256 i = 0; i < functionSelectors.length; i++) {
            bytes4 selector = functionSelectors[i];
            require(functionToFacet[selector] == address(0), "Function already exists");
            functionToFacet[selector] = facetAddress;
            console.log("Added function:", uint32(selector), "to facet:", facetAddress);
        }
    }

    function replaceFunctions(address facetAddress, bytes4[] calldata functionSelectors) internal {
        require(facetAddress != address(0), "Can't replace with zero address");

        for (uint256 i = 0; i < functionSelectors.length; i++) {
            bytes4 selector = functionSelectors[i];
            require(functionToFacet[selector] != address(0), "Function doesn't exist");
            require(functionToFacet[selector] != facetAddress, "Can't replace with same facet");
            functionToFacet[selector] = facetAddress;
            console.log("Replaced function:", uint32(selector), "with facet:", facetAddress);
        }
    }

    function removeFunctions(bytes4[] calldata functionSelectors) internal {
        for (uint256 i = 0; i < functionSelectors.length; i++) {
            bytes4 selector = functionSelectors[i];
            require(functionToFacet[selector] != address(0), "Function doesn't exist");
            delete functionToFacet[selector];
            console.log("Removed function:", uint32(selector));
        }
    }

    fallback() external payable {
        address facet = functionToFacet[msg.sig];
        require(facet != address(0), "Function does not exist");

        console.log("Fallback called with selector:", uint32(msg.sig));
        console.log("Delegating to facet:", facet);

        // Delegate call to the facet
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
