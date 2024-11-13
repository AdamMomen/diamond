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
        diamond.addFunction(address(counterFacet), counterFacet.increment.selector);
        diamond.addFunction(address(counterFacet), counterFacet.getCount.selector);
        diamond.addFunction(address(messageFacet), messageFacet.setMessage.selector);
        diamond.addFunction(address(messageFacet), messageFacet.getMessage.selector);
        diamond.addFunction(address(timestampFacet), timestampFacet.setTimestamp.selector);
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
