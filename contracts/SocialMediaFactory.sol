// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./SocialMedia.sol";


contract SocialMediaFactory {
    address owner;

    address[] deploySocialMedia;

    event SocialMediaCreated();


    constructor () {
        owner = msg.sender;
    }

    function createSocialMedia(string memory _adminUsername) public {
        require(msg.sender != address(0), "address zero call");
        require(msg.sender == owner, "only owner can create social media");

        SocialMedia _newSocialMedia = new SocialMedia(_adminUsername);
        deploySocialMedia.push(address(_newSocialMedia));

        emit SocialMediaCreated();
    }

    function getLastSocialMedia() public view returns (address) {
        require(msg.sender != address(0), "address zero call");
        require(deploySocialMedia.length > 0, "no media created");

        return deploySocialMedia[deploySocialMedia.length - 1];
    }
}