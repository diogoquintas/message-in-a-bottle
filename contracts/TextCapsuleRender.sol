//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "./utils/Base64.sol";
import "./utils/Dates.sol";
import "./ITextCapsuleRender.sol";

contract TextCapsuleRender is ITextCapsuleRender {
    function render(uint256 tokenId, Capsule memory capsule)
        external
        pure
        override
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 40 40">',
            "<style>p { font-family: sans-serif; font-size: 2.5px; font-weight: 100; margin: 1px; margin-top: 2px; margin-bottom: 0.5px; color: white; word-break: break-word; } .signature { text-align: right; font-size: 1px; margin-top: 0; } foreignObject { background-color: black; }</style>",
            '<foreignObject x="0" y="0" width="100%" height="100%"><p xmlns="http://www.w3.org/1999/xhtml">',
            escapeText(capsule.text),
            '</p><p xmlns="http://www.w3.org/1999/xhtml" class="signature">',
            escapeText(capsule.signature),
            "</p></foreignObject>",
            renderIris(tokenId, capsule.creationDate),
            "</svg>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    /**                            
        88              88             
        88              ""             
        88                             
        88  8b,dPPYba,  88  ,adPPYba,  
        88  88P'   "Y8  88  I8[    ""  
        88  88          88   `"Y8ba,   
        88  88          88  aa    ]8I  
        88  88          88  `"YbbdP"'  
                               
        This function will generate a unique set of 9 colors.
        From those 9 colors, 1 will be used as background and the other 8 distributed through a line with random sizes.
        The Iris is unique to each capsule and it never changes.                 
     */
    function renderIris(uint256 tokenId, uint256 creationDate)
        internal
        pure
        returns (string memory)
    {
        bytes32 hash = keccak256(
            abi.encodePacked("TEXTCAP", creationDate, tokenId)
        );
        string[9] memory colors;

        for (uint256 i = 0; i < colors.length; i++) {
            colors[i] = string(
                abi.encodePacked("#", bytes3ToHexStr(bytes3(hash)))
            );

            // Shift 6 hex characters in the hash (24 bits)
            hash = hash << 24;
        }

        return
            string(
                abi.encodePacked(
                    // background
                    string(
                        abi.encodePacked(
                            '<rect width="100%" height="2" x="0" y="38" fill="',
                            colors[0],
                            '"/>'
                        )
                    ),
                    getIrisTissue(0, hash, colors[1]),
                    getIrisTissue(5, hash, colors[2]),
                    getIrisTissue(10, hash, colors[3]),
                    getIrisTissue(15, hash, colors[4]),
                    getIrisTissue(20, hash, colors[5]),
                    getIrisTissue(25, hash, colors[6]),
                    getIrisTissue(30, hash, colors[7]),
                    getIrisTissue(35, hash, colors[8])
                )
            );
    }

    function getIrisTissue(
        uint256 x,
        bytes32 hash,
        string memory color
    ) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '<rect width="',
                    Strings.toString(
                        uint256(keccak256(abi.encodePacked(hash, x))) % 5
                    ),
                    '" height="2" x="',
                    Strings.toString(x),
                    '" y="38" fill="',
                    color,
                    '"/>'
                )
            );
    }

    function escapeText(string memory text)
        internal
        pure
        returns (string memory)
    {
        bytes memory textInBytes = bytes(text);
        string memory result = "";

        for (uint256 i = 0; i < textInBytes.length; i++) {
            if (textInBytes[i] == "<") {
                result = string(
                    abi.encodePacked(bytes(result), bytes("&#60;"))
                );
            } else if (textInBytes[i] == "&") {
                result = string(
                    abi.encodePacked(bytes(result), bytes("&#38;"))
                );
            } else {
                result = string(
                    abi.encodePacked(bytes(result), textInBytes[i])
                );
            }
        }

        return result;
    }

    // https://stackoverflow.com/a/69316712 ❤️
    function bytes3ToHexStr(bytes3 i) internal pure returns (string memory) {
        uint24 n = uint24(i);

        return uint24ToHexStr(n);
    }

    function uint8ToHexChar(uint8 i) internal pure returns (uint8) {
        return (i > 9) ? (i + 87) : (i + 48);
    }

    function uint24ToHexStr(uint24 i) internal pure returns (string memory) {
        bytes memory o = new bytes(6);
        uint24 mask = 0x00000f;

        o[5] = bytes1(uint8ToHexChar(uint8(i & mask)));
        i = i >> 4;

        o[4] = bytes1(uint8ToHexChar(uint8(i & mask)));
        i = i >> 4;

        o[3] = bytes1(uint8ToHexChar(uint8(i & mask)));
        i = i >> 4;

        o[2] = bytes1(uint8ToHexChar(uint8(i & mask)));
        i = i >> 4;

        o[1] = bytes1(uint8ToHexChar(uint8(i & mask)));
        i = i >> 4;

        o[0] = bytes1(uint8ToHexChar(uint8(i & mask)));

        return string(o);
    }
}
