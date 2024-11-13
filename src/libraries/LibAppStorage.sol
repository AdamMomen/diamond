// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Shared storage structure
struct AppStorage {
    uint256 count;
    string message;
}

// Library to help access shared storage
library LibAppStorage {
    bytes32 constant STORAGE_POSITION = keccak256("app.storage");

    function diamondStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
