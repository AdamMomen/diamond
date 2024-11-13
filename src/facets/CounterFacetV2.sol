// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../libraries/LibAppStorage.sol";
import "forge-std/console.sol";

contract CounterFacetV2 {
    // Same storage, new implementation
    function increment() external {
        AppStorage storage s = LibAppStorage.getStorage();
        uint256 oldCount = s.count;
        s.count += 10; // Now increments by 10 instead of 1
        console.log("CounterV2 incremented from:", oldCount, "to:", s.count);
    }

    function getCount() external view returns (uint256) {
        return LibAppStorage.getStorage().count;
    }
}
