// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// 1) Hacerlo upgradable para introducirle cambios
// 2) Hacer los merkletrees para whitelistear
 

// ██╗    ██╗██╗  ██╗ ██████╗     ██╗███████╗    ▄▄███▄▄· █████╗ ███╗   ███╗ ██████╗ ████████╗    ██████╗
// ██║    ██║██║  ██║██╔═══██╗    ██║██╔════╝    ██╔════╝██╔══██╗████╗ ████║██╔═══██╗╚══██╔══╝    ╚════██╗
// ██║ █╗ ██║███████║██║   ██║    ██║███████╗    ███████╗███████║██╔████╔██║██║   ██║   ██║         ▄███╔╝
// ██║███╗██║██╔══██║██║   ██║    ██║╚════██║    ╚════██║██╔══██║██║╚██╔╝██║██║   ██║   ██║         ▀▀══╝
// ╚███╔███╔╝██║  ██║╚██████╔╝    ██║███████║    ███████║██║  ██║██║ ╚═╝ ██║╚██████╔╝   ██║         ██╗
//  ╚══╝╚══╝ ╚═╝  ╚═╝ ╚═════╝     ╚═╝╚══════╝    ╚═▀▀▀══╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝    ╚═╝         ╚═╝

/**
 * @title Don Rouch
 * WhoIsSamot - an 1155 contract for  0800 Don Rouch
 */
contract DonRouch is ERC1155Supply, Ownable , ReentrancyGuard{

    using SafeMath for uint256;
    using Strings for string;

    struct itemData {
        uint256 maxSupply;
        uint256 maxToMint;
        uint256 maxPerWallet;
        uint256 initialSupply;
    }
    bool public saleIsActive = false;
    string public name;
    string public symbol;
    string public baseURI= "https://samotclub.mypinata.cloud/ipfs/QmeLn1Vx2FLMQypLPqQfohYqEt4kJnUx5DUpc3pmwGU85w/";

    mapping(uint256 => itemData) public idStats ; 


    constructor(
        string memory _uri
        ,
        string memory _name,
        string memory _symbol
    ) ERC1155(_uri) {
        name = _name;
        symbol = _symbol;
        createItem(1, 1, 1, 1, 10);
        createItem(2, 3, 2, 1, 10);
    }

    function uri(uint256 _id) override public view returns (string memory){
        require(exists(_id), "ERC1155: NONEXISTENT_TOKEN");
        return(
            string(abi.encodePacked(baseURI,Strings.toString(_id),".json"))
        );
    }

    function setBaseURI(string memory _baseURI) external onlyOwner{
        baseURI = _baseURI;
    }

    function setURI(string memory _newURI) public onlyOwner {
        _setURI(_newURI);
    }


    function setMaxToMint(uint256 _maxToMint, uint256 _id) external onlyOwner {
        idStats[_id].maxToMint = _maxToMint;
    }

    function setMaxPerWallet(uint256 _maxPerWallet, uint256 _id) external onlyOwner {
        idStats[_id].maxPerWallet = _maxPerWallet;
    }

    function setMaxSupply(uint256 _maxSupply, uint256 _id) external onlyOwner {
        idStats[_id].maxSupply = _maxSupply;
    }


    function setInitialSupply(uint256 _initialSupply, uint256 _id) external onlyOwner {
        idStats[_id].initialSupply = _initialSupply;
    }

    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;
    }
    
    function createItems(uint256[] memory _ids, uint256[] memory _maxPerWallet, uint256[] memory _maxToMint,uint256[] memory _initialSupply,uint256[] memory _maxSupply) public onlyOwner{
        for(uint256 i = 0; i< _ids.length; i++){
        idStats[_ids[i]].maxPerWallet = _maxPerWallet[i];
        idStats[_ids[i]].maxToMint = _maxToMint[i];
        idStats[_ids[i]].initialSupply = _initialSupply[i];
        idStats[_ids[i]].maxSupply = _maxSupply[i];
        _mint(msg.sender,_ids[i],_initialSupply[i],"");
        }
    }

    function createItem(uint256 _id, uint256 _maxPerWallet, uint256 _maxToMint,uint256 _initialSupply,uint256 _maxSupply) public onlyOwner{
        idStats[_id].maxPerWallet = _maxPerWallet;
        idStats[_id].maxToMint = _maxToMint;
        idStats[_id].initialSupply = _initialSupply;
        idStats[_id].maxSupply = _maxSupply;
        _mint(msg.sender,_id,_initialSupply,"");
    }

    function claimItem(uint256 _quantity,uint256 _id) external {
        require(saleIsActive, "Claim is not active.");
        require(
            totalSupply(_id).add(_quantity) <= idStats[_id].maxSupply,  
            "Minting limit reached."
        );
        require(_quantity > 0, "Quantity cannot be 0.");
        require(
                balanceOf(msg.sender,_id).add(_quantity) <= idStats[_id].maxPerWallet,
                "Exceeds wallet limit."
            );
        require(
                _quantity <= idStats[_id].maxToMint, 
                "Exceeds NFT per transaction limit."
            );
        _mint(msg.sender,_id,_quantity,"");
        totalSupply(_id).add(_quantity);
    }

    function claimItems(uint256[] calldata _quantities,uint256[] calldata _ids) external {
        require(saleIsActive, "Claim is not active.");
        for(uint256 i=0;i<_ids.length;i++){
            require(totalSupply(_ids[i]).add(_quantities[i]) <= idStats[_ids[i]].maxSupply,   
            "Minting limit reached.");
            require(_quantities[i] > 0, "Quantity cannot be 0.");
            require(
                balanceOf(msg.sender,_ids[i]).add(_quantities[i]) <= idStats[_ids[i]].maxPerWallet,
                "Exceeds wallet limit."
            );
            require(
                _quantities[i] <= idStats[_ids[i]].maxToMint, 
                "Exceeds NFT per transaction limit."
            );
            totalSupply(_ids[i]).add(_quantities[i]);

        }
        _mintBatch(msg.sender,_ids,_quantities,"");
    }
    
    
    function withdraw() external onlyOwner nonReentrant {
            (bool success, ) = msg.sender.call{value: address(this).balance}("");
            require(success, "Transfer failed."); 
    }
}
