//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./ITextCapsuleRender.sol";
import "./utils/Dates.sol";
import "./utils/Base64.sol";

/**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
                              888888888888                                                                    
                                   88                             ,d                                          
                                   88                             88                                          
                                   88   ,adPPYba,  8b,     ,d8  MM88MMM                                       
                                   88  a8P_____88   `Y8, ,8P'     88                                          
                                   88  8PP"""""""     )888(       88                                          
                                   88  "8b,   ,aa   ,d8" "8b,     88,                                         
                                   88   `"Ybbd8"'  8P'     `Y8    "Y888                                                                                                               
       ,ad8888ba,                                                    88              
      d8"'    `"8b                                                   88              
     d8'                                                             88              
     88             ,adPPYYba,  8b,dPPYba,   ,adPPYba,  88       88  88   ,adPPYba,  
     88             ""     `Y8  88P'    "8a  I8[    ""  88       88  88  a8P_____88  
     Y8,            ,adPPPPP88  88       d8   `"Y8ba,   88       88  88  8PP"""""""  
      Y8a.    .a8P  88,    ,88  88b,   ,a8"  aa    ]8I  "8a,   ,a88  88  "8b,   ,aa 
       `"Y8888Y"'   `"8bbdP"Y8  88`YbbdP"'   `"YbbdP"'   `"YbbdP'Y8  88   `"Ybbd8"'  
                                88                                                   
    Come.                       88
    Enter your prophecies.
    Enter your declarations.
    Enter your ideias.
    Make your friends accountable for their promises. 
    Meme the sh*t out of it.

    Only time will tell.       

    Start here:
    - Pick a time in the future.
    - Send a text. 
    The text cannot be destroyed or modified until that time comes.
    When that time comes (and if it comes) your capsule opens up and you’re allowed to send another text.                                                                                                                                                                                                                                                                                                                
*/

contract TextCapsule is ERC721Enumerable, Ownable {
    uint256 public constant FIRST_HUNDRED_ARE_FREE = 100;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant TEXT_CHAR_LIMIT = 280;
    uint256 public constant SIGNATURE_CHAR_LIMIT = 27;

    address public renderAddress;

    mapping(uint256 => Capsule) public capsules;

    event TextSent(uint256 tokenId);

    constructor(address _renderAddress)
        ERC721("The text capsules", "TEXTCAP")
        Ownable()
    {
        renderAddress = _renderAddress;
    }

    function setMetadataAddress(address _renderAddress) public onlyOwner {
        renderAddress = _renderAddress;
    }

    /**
      just gonna                                              
         ad88888ba                                     88  
        d8"     "8b                                    88  
        Y8,                                            88  
        `Y8aaaaa,     ,adPPYba,  8b,dPPYba,    ,adPPYb,88  
          `"""""8b,  a8P_____88  88P'   `"8a  a8"    `Y88  
                `8b  8PP"""""""  88       88  8b       88  
        Y8a     a8P  "8b,   ,aa  88       88  "8a,   ,d88  
         "Y88888P"    `"Ybbd8"'  88       88   `"8bbdP"Y8it
           dude    

        Send a text to your open capsule.
     */
    function send(
        string memory text,
        string memory signature,
        uint256 openDate,
        uint256 tokenId
    ) public {
        require(_exists(tokenId), "The capsule does not exist");
        require(msg.sender == ownerOf(tokenId), "Not your capsule");
        require(
            isOpen(capsules[tokenId].openDate, capsules[tokenId].sendDate),
            "The capsule is closed"
        );
        require(
            bytes(text).length > 0 && bytes(text).length <= TEXT_CHAR_LIMIT,
            "Incorrect text length"
        );
        require(
            bytes(signature).length <= SIGNATURE_CHAR_LIMIT,
            "Signature is too long"
        );

        capsules[tokenId] = Capsule(
            text,
            signature,
            block.timestamp,
            openDate,
            capsules[tokenId].creationDate
        );

        emit TextSent(tokenId);
    }

    /**
        88b           d88  88                       
        888b         d888  ""                ,d     
        88`8b       d8'88                    88     
        88 `8b     d8' 88  88  8b,dPPYba,  MM88MMM  
        88  `8b   d8'  88  88  88P'   `"8a   88     
        88   `8b d8'   88  88  88       88   88     
        88    `888'    88  88  88       88   88,    
        88     `8'     88  88  88       88   "Y888  

        Mint a new capsule.
        The process of minting creates a new & unique capsule and saves your text inside.

        - The `text` has a char limit defined by `TEXT_CHAR_LIMIT`.
        - The `signature` has a char defined by `SIGNATURE_CHAR_LIMIT`. It can be an empty string.
        - `openDate` defines the date that the text expires and the capsule opens up to be re-used.
        The variable is measured in seconds since epoch like `block.timestamp`.
        To close a capsule forever set `openDate` as 0.
    */
    function mint(
        string memory text,
        string memory signature,
        uint256 openDate
    ) external payable {
        uint256 tokenId = totalSupply();

        require(tokenId < MAX_SUPPLY, "All capsules minted");

        if (tokenId >= FIRST_HUNDRED_ARE_FREE) {
            require(msg.value >= 0.001 ether, "Not enought funds");
        }

        _mint(msg.sender, tokenId);

        capsules[tokenId].creationDate = block.timestamp;

        send(text, signature, openDate, tokenId);
    }

    function metadata(uint256 tokenId)
        internal
        view
        virtual
        returns (string memory)
    {
        Capsule memory capsule = capsules[tokenId];

        string memory image = ITextCapsuleRender(renderAddress).render(
            tokenId,
            capsule
        );
        bool capsuleIsOpen = isOpen(capsule.openDate, capsule.sendDate);

        bytes memory data = abi.encodePacked(
            '{ "name": "Capsule #',
            Strings.toString(tokenId),
            '", "description": "',
            capsuleIsOpen ? "An open" : "A closed",
            " capsule with a text inside... `",
            capsule.text,
            '`", "image": "',
            image
        );
        bytes memory attributes = abi.encodePacked(
            '", "attributes": [{ "trait_type": "State", "value": "',
            capsuleIsOpen ? "Open" : "Closed",
            '"}, { "trait_type": "Signature", "value": "',
            bytes(capsule.signature).length > 0 ? capsule.signature : "None",
            '"}, { "trait_type": "Time since creation", "value": "',
            Dates.parseDate(block.timestamp - capsule.creationDate),
            '"}, { "trait_type": "Time since text was sent", "value": "',
            Dates.parseDate(block.timestamp - capsule.sendDate),
            '"}, { "trait_type": "Time remaining", "value": "',
            capsule.openDate < capsule.sendDate ||
                block.timestamp > capsule.openDate
                ? "None"
                : Dates.parseDate(capsule.openDate - block.timestamp),
            '"}]}'
        );

        string memory json = Base64.encode(
            bytes(string(abi.encodePacked(data, attributes)))
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function isOpen(uint256 openDate, uint256 sendDate)
        public
        view
        returns (bool)
    {
        return openDate < block.timestamp && openDate >= sendDate;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "The capsule does not exist");
        require(renderAddress != address(0), "No metadata address");

        return metadata(tokenId);
    }

    function withdraw(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }
}
