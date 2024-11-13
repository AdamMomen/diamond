// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/Diamond.sol";
import "../src/facets/CounterFacet.sol";
import "../src/facets/MessageFacet.sol";

contract DiamondTest is Test {
    Diamond diamond;
    CounterFacet counterFacet;
    MessageFacet messageFacet;

    function setUp() public {
        // Deploy contracts
        diamond = new Diamond();
        counterFacet = new CounterFacet();
        messageFacet = new MessageFacet();

        // Get function selectors for counter functions
        bytes4 incrementSelector = counterFacet.increment.selector;
        bytes4 getCountSelector = counterFacet.getCount.selector;
        bytes4 getMessageSelector = messageFacet.getMessage.selector;
        bytes4 setMessageSelector = messageFacet.setMessage.selector;

        // Add functions to diamond
        diamond.addFunction(address(counterFacet), incrementSelector);
        diamond.addFunction(address(counterFacet), getCountSelector);
        diamond.addFunction(address(messageFacet), setMessageSelector);
        diamond.addFunction(address(messageFacet), getMessageSelector);
    }

    function test_Counter() public {
        // Create interface to interact with diamond
        CounterFacet diamondAsCounter = CounterFacet(address(diamond)); // Cast diamond address as CounterFacet type

        // Initial count should be 0
        assertEq(diamondAsCounter.getCount(), 0);

        // Increment counter
        diamondAsCounter.increment();

        // Count should be 1
        assertEq(diamondAsCounter.getCount(), 1);
    }

    function test_Message() public {
        MessageFacet diamondAsMessage = MessageFacet(address(diamond));
        assertEq(diamondAsMessage.getMessage(), "");
        diamondAsMessage.setMessage("Hello, World!");
        assertEq(diamondAsMessage.getMessage(), "Hello, World!");
    }
}
