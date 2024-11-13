// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/Diamond.sol";
import "../src/facets/CounterFacet.sol";
import "../src/facets/MessageFacet.sol";
import "../src/facets/TimestampFacet.sol";

contract DiamondTest is Test {
    Diamond diamond;
    CounterFacet counterFacet;
    MessageFacet messageFacet;
    TimestampFacet timestampFacet;

    function setUp() public {
        // Deploy contracts
        diamond = new Diamond();
        counterFacet = new CounterFacet();
        messageFacet = new MessageFacet();
        timestampFacet = new TimestampFacet();

        // Add functions to diamond
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);

        // Counter selectors
        bytes4[] memory counterSelectors = new bytes4[](2);
        counterSelectors[0] = counterFacet.increment.selector;
        counterSelectors[1] = counterFacet.getCount.selector;

        // Message selectors - need both setMessage and getMessage
        bytes4[] memory messageSelectors = new bytes4[](2); // Changed from 1 to 2
        messageSelectors[0] = messageFacet.setMessage.selector;
        messageSelectors[1] = messageFacet.getMessage.selector; // Added this

        // Timestamp selectors
        bytes4[] memory timestampSelectors = new bytes4[](1);
        timestampSelectors[0] = timestampFacet.setTimestamp.selector;

        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(counterFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: counterSelectors
        });

        cuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(messageFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: messageSelectors
        });

        cuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(timestampFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: timestampSelectors
        });

        diamond.diamondCut(cuts, address(0), "");
    }

    function test_ExtendedStorage() public {
        CounterFacet diamondAsCounter = CounterFacet(address(diamond));
        TimestampFacet diamondAsTimestamp = TimestampFacet(address(diamond));

        // Initial count should be 0
        assertEq(diamondAsCounter.getCount(), 0);

        // Set timestamp (which also increments count)
        diamondAsTimestamp.setTimestamp();

        // Count should be incremented
        assertEq(diamondAsCounter.getCount(), 1);
    }

    function test_MultipleStorageInteractions() public {
        CounterFacet diamondAsCounter = CounterFacet(address(diamond));
        MessageFacet diamondAsMessage = MessageFacet(address(diamond));
        TimestampFacet diamondAsTimestamp = TimestampFacet(address(diamond));

        // Interact with all facets
        diamondAsMessage.setMessage("Hello"); // count += 1
        diamondAsCounter.increment(); // count += 1
        diamondAsTimestamp.setTimestamp(); // count += 1

        // Final count should be 3
        assertEq(diamondAsCounter.getCount(), 3);

        // Check message
        assertEq(diamondAsMessage.getMessage(), "Hello");
    }

    function testFuzz_TimestampUpdate(address caller) public {
        vm.assume(caller != address(0));

        TimestampFacet diamondAsTimestamp = TimestampFacet(address(diamond));

        // Call setTimestamp as different addresses
        vm.prank(caller);
        diamondAsTimestamp.setTimestamp();
    }
}
