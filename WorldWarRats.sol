// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LithiumReservoir.sol";

contract WorldWarRats {
    LithiumReservoir public lithiumReservoir;
    mapping(address => uint256) public ratLithium;  // Lithium given to Rat
    mapping(address => uint256) public czarLithium; // Lithium given to Rat Czar
    mapping(address => uint256) public userLithiumContribution; // Tracks each user's total contribution

    uint256 public ratFirearms;
    uint256 public czarFirearms;
    address public crowned;
    address public lastContributor;
    address public nukeHolder;
    bool public nuked;

    event LithiumGiven(address indexed user, string side, uint256 amount);
    event CrownUpdated(address indexed crowned);
    event FirearmGained(string side, uint256 firearms);
    event Nuked(string side);

    constructor(address _lithiumReservoir) {
        lithiumReservoir = LithiumReservoir(_lithiumReservoir);
    }

    // Give Lithium to either the Rat or the Rat Czar
    function giveLithium(string memory side, uint256 amount) external {
        require(lithiumReservoir.getUserLithiumBalance(msg.sender) >= amount, "Not enough Lithium to give.");
        require(
            keccak256(abi.encodePacked(side)) == keccak256(abi.encodePacked("rat")) ||
            keccak256(abi.encodePacked(side)) == keccak256(abi.encodePacked("czar")),
            "Invalid side. Choose 'rat' or 'czar'."
        );

        lithiumReservoir.transferLithium(msg.sender, amount); // Transfer lithium from user
        userLithiumContribution[msg.sender] += amount;
        lastContributor = msg.sender; // Track the last contributor

        if (keccak256(abi.encodePacked(side)) == keccak256(abi.encodePacked("rat"))) {
            ratLithium[msg.sender] += amount;
            if (ratLithium[msg.sender] >= 5) {
                ratFirearms++;
                ratLithium[msg.sender] -= 5;
                emit FirearmGained("rat", ratFirearms);
            }
        } else if (keccak256(abi.encodePacked(side)) == keccak256(abi.encodePacked("czar"))) {
            czarLithium[msg.sender] += amount;
            if (czarLithium[msg.sender] >= 5) {
                czarFirearms++;
                czarLithium[msg.sender] -= 5;
                emit FirearmGained("czar", czarFirearms);
            }
        }

        updateCrown();
        checkForNukeHolder();
        emit LithiumGiven(msg.sender, side, amount);
    }

    // Update which side has the crown based on who has more firearms
    function updateCrown() internal {
        if (ratFirearms > czarFirearms) {
            crowned = address(1); // Rat has the crown
        } else if (czarFirearms > ratFirearms) {
            crowned = address(2); // Czar has the crown
        } else {
            crowned = address(0); // No crown if both are equal
        }
        emit CrownUpdated(crowned);
    }

    // Check if a nuke should be given to the last contributor after 20 firearms
    function checkForNukeHolder() internal {
        if (ratFirearms >= 3 || czarFirearms >= 3) {
            nukeHolder = lastContributor; // Last contributor gets the nuke
        }
    }

    // Nuke either the Rat or the Rat Czar
    function nuke(string memory side) external {
        require(msg.sender == nukeHolder, "Only the last contributor can nuke.");
        require(!nuked, "Already nuked!");

        nuked = true;
        emit Nuked(side);
    }
}