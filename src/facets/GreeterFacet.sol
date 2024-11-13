// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/console.sol";

contract GreeterFacet {
    struct Storage {
        string greeting;
    }

    bytes32 constant STORAGE_POSITION = keccak256("diamond.storage.greeter");

    function getStorage() internal pure returns (Storage storage s) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function greet(string memory name) external returns (string memory) {
        Storage storage s = getStorage();
        s.greeting = string.concat("Hello, ", name);
        return s.greeting;
    }
}
