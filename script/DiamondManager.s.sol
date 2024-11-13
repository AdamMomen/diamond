// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Script.sol";
import "../src/Diamond.sol";
import "../src/facets/CounterFacet.sol";
import "../src/facets/MessageFacet.sol";
import "../src/facets/TimestampFacet.sol";

contract DiamondManager is Script {
    // Helper function to get all selectors from a contract
    function getSelectors(address contractAddress) internal view returns (bytes4[] memory) {
        // Get contract code
        bytes memory code = contractAddress.code;

        // Extract function selectors
        bytes4[] memory selectors = new bytes4[](10); // Adjust size as needed
        uint256 count = 0;

        // code.length - 3 ensures we don't read past the end of the bytecode
        for (uint256 i = 0; i < code.length - 3; i++) {
            bytes4 selector;
            assembly {
                selector := mload(add(add(code, 0x20), i))
            }

            // Check if this is a valid function selector
            try IContract(contractAddress).supportsInterface(selector) returns (bool supported) {
                if (supported) {
                    selectors[count] = selector;
                    count++;
                }
            } catch {}
        }

        // Trim array to actual size
        assembly {
            mstore(selectors, count)
        }

        return selectors;
    }

    function upgradeFacet(Diamond diamond, address oldFacet, address newFacet) public {
        // Get all selectors from old facet
        bytes4[] memory selectors = getSelectors(oldFacet);

        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);

        // Replace all functions
        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: newFacet,
            action: IDiamondCut.FacetCutAction.Replace,
            functionSelectors: selectors
        });

        diamond.diamondCut(cuts, address(0), "");
    }
}

// Helper interface for selector detection
interface IContract {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
