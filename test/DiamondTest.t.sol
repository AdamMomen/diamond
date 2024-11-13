// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/Diamond.sol";
import "../src/facets/CounterFacet.sol";
import "../src/facets/GreeterFacet.sol";

contract DiamondTest is Test {
    Diamond diamond;
    CounterFacet counterFacet;
    GreeterFacet greeterFacet;

    function setUp() public {
        // Deploy contracts
        diamond = new Diamond();
        counterFacet = new CounterFacet();
        greeterFacet = new GreeterFacet();

        // Get function selectors for counter functions
        bytes4 incrementSelector = counterFacet.increment.selector;
        bytes4 getCountSelector = counterFacet.getCount.selector;
        bytes4 greetSelector = greeterFacet.greet.selector;

        // Add functions to diamond
        diamond.addFunction(address(counterFacet), incrementSelector);
        diamond.addFunction(address(counterFacet), getCountSelector);
        diamond.addFunction(address(greeterFacet), greetSelector);
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

    function test_Greeter() public {
        GreeterFacet diamondAsGreeter = GreeterFacet(address(diamond));
        assertEq(diamondAsGreeter.greet("Alice"), "Hello, Alice");
    }
}
