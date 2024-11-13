// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../libraries/LibAppStorage.sol";

contract TimestampFacet {
    function setTimestamp() external {
        // It's important to access both storages independently
        AppStorageExt storage ext = LibAppStorage.diamondStorageExt();
        AppStorage storage original = LibAppStorage.diamondStorage();

        ext.timestamp = block.timestamp;
        ext.lastCaller = msg.sender;

        original.count += 1;
    }

    function getTimestamp() external view returns (uint256) {
        return LibAppStorage.diamondStorageExt().timestamp;
    }

    function getLastCaller() external view returns (address) {
        return LibAppStorage.diamondStorageExt().lastCaller;
    }
}
