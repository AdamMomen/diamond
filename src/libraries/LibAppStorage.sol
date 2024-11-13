// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Shared storage structure
struct AppStorage {
    uint256 count;
    string message;
}

// New storage structure for extension
struct AppStorageExt {
    uint256 timestamp;
    address lastCaller;
}

// Library to help access shared storage
library LibAppStorage {
    bytes32 constant STORAGE_POSITION = keccak256("app.storage");
    bytes32 constant STORAGE_EXTENSION_POSITION = keccak256("app.storage.extension");

    // Original storage access
    function getStorage() internal pure returns (AppStorage storage ds) {
        bytes32 position = STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }

    // Extended storage access
    function getStorageExt() internal pure returns (AppStorageExt storage ds) {
        bytes32 position = STORAGE_EXTENSION_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
