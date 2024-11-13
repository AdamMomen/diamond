// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/console.sol";

contract CounterFacet {
    // Note: Storage layout must be compatible with Diamond
    struct Storage {
        uint256 count; // default value is 0
    }

    // This is how we access the storage in the Diamond
    bytes32 constant STORAGE_POSITION = keccak256("diamond.storage.counter");

    function getStorage() internal pure returns (Storage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    // Our counter functions
    function increment() external {
        // This runs in Diamond's context due to delegatecall
        Storage storage s = getStorage();
        uint256 oldCount = s.count;
        s.count += 1; // Modifies Diamond's storage
        console.log("Counter incremented from:", oldCount, "to:", s.count);
    }

    function getCount() external view returns (uint256) {
        Storage storage s = getStorage();
        console.log("Getting count:", s.count);
        return s.count;
    }
}
