// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "../libraries/LibAppStorage.sol";

contract MessageFacet {
    // Use the same shared storage
    function setMessage(string calldata _message) external {
        AppStorage storage s = LibAppStorage.diamondStorage();
        s.message = _message;
        // Can also access count from here
        s.count += 1; // Increment count when setting message
    }

    function getMessage() external view returns (string memory) {
        return LibAppStorage.diamondStorage().message;
    }
}
