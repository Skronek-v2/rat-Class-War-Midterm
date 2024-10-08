// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LithiumReservoir {
    uint256 public constant maxDailyLithium = 5; // Max lithium claimable per day
    uint256 public constant lithiumPerClaim = 1; // Lithium claimable per transaction
    mapping(address => uint256) public userLithiumBalance; // Tracks each user's lithium
    mapping(address => uint256) public lastClaimedTime; // Tracks last claim time for each user
    mapping(address => uint256) public dailyClaimedAmount; // Tracks daily claimed lithium

    event LithiumClaimed(address indexed user, uint256 amount);

    // Claim 1 Lithium (up to 5 per day)
    function claimLithium() external {
        require(canClaim(msg.sender), "You can only claim up to 5 Lithium per day.");
        userLithiumBalance[msg.sender] += lithiumPerClaim;
        dailyClaimedAmount[msg.sender] += lithiumPerClaim;
        lastClaimedTime[msg.sender] = block.timestamp;
        emit LithiumClaimed(msg.sender, lithiumPerClaim);
    }

    // Check if the user can claim more lithium today (up to 5 daily)
    function canClaim(address user) public view returns (bool) {
        if (block.timestamp >= lastClaimedTime[user] + 1 days) {
            return true;
        }
        return dailyClaimedAmount[user] < maxDailyLithium;
    }

    // Reset daily claim tracking after 24 hours
    function resetDailyClaims(address user) internal {
        if (block.timestamp >= lastClaimedTime[user] + 1 days) {
            dailyClaimedAmount[user] = 0;
        }
    }

    // Transfer lithium to another contract (called by WorldWarRats)
    function transferLithium(address from, uint256 amount) external {
        require(userLithiumBalance[from] >= amount, "Not enough Lithium.");
        userLithiumBalance[from] -= amount;
    }

    // Get user's lithium balance
    function getUserLithiumBalance(address user) external view returns (uint256) {
        return userLithiumBalance[user];
    }
}
