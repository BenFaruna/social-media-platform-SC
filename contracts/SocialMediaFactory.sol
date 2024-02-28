// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./SocialMedia.sol";

contract SocialMediaFactory {
    address owner;

    address[] deploySocialMedia;

    event SocialMediaCreated();

    constructor() {
        owner = msg.sender;
    }

    function createSocialMedia(string memory _adminUsername) public {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (msg.sender != owner) {
            revert Errors.ONLY_OWNER();
        }

        SocialMedia _newSocialMedia = new SocialMedia(
            msg.sender,
            _adminUsername
        );
        deploySocialMedia.push(address(_newSocialMedia));

        emit SocialMediaCreated();
    }

    function getLastSocialMedia() public view returns (address) {
        if (msg.sender == address(0)) {
            revert Errors.ZERO_ADDRESS_CALL();
        }

        if (deploySocialMedia.length == 0) {
            revert Errors.NO_SOCIAL_MEDIA_CREATED();
        }

        return deploySocialMedia[deploySocialMedia.length - 1];
    }
}
