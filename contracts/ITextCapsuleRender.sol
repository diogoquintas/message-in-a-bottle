//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

struct Capsule {
    string text;
    string signature;
    uint256 sendDate;
    uint256 openDate;
    uint256 creationDate;
}

interface ITextCapsuleRender {
    function render(uint256 tokenId, Capsule memory capsule)
        external
        view
        returns (string memory);
}
