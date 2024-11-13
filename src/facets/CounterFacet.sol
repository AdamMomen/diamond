// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../libraries/LibAppStorage.sol";
import "forge-std/console.sol";

contract CounterFacet {
    // Use the shared storage
    function increment() external {
        AppStorage storage s = LibAppStorage.getStorage();
        uint256 oldCount = s.count;
        s.count += 1;
        console.log("Counter incremented from:", oldCount, "to:", s.count);
    }

    function getCount() external view returns (uint256) {
        return LibAppStorage.getStorage().count;
    }
}
