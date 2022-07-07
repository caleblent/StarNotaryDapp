pragma solidity ^0.5.0;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {

    struct Star {
        string name;
    }

    string public constant name = "Star Notary Token";
    string public constant symbol = "SNT"; // SNT = Star Notary Token 

    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;


    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    // Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale the Star you don't owned");
        starsForSale[_tokenId] = _price;
    }


    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId); // We can't use _addTokenTo or_removeTokenFrom functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    function lookUptokenIdToStarInfo(uint256 tokenId) public view returns (string memory) {
        // uses compareStrings() method to compare the tokenId name that returns with the empty string
        // if a star with the token Id does not exist, then it will return true (cuz it will equal "")
        // We want this to evaluate to false (if it exists), so the opposite is taken as an argument
        // in the require() function (by using the ! operator)
        require(!compareStrings(tokenIdToStarInfo[tokenId].name, ""), "A star with this token ID does not exist"); 

        // if the value exists in the first place, it will now return this value
        return tokenIdToStarInfo[tokenId].name;
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        address owner1Address = ownerOf(_tokenId1);
        address owner2Address = ownerOf(_tokenId2);

        // check to see if both tokens have the same owner
        require(owner1Address != owner2Address, "These tokens are both owned by the same owner");

        // swap the stars using _transferFrom()
        _transferFrom(owner1Address, owner2Address, _tokenId1);
        _transferFrom(owner2Address, owner1Address, _tokenId2);
    }

    function transferStar(address _transferToAddress, uint256 _tokenId) public {
        // verify that the caller does in fact own the token
        require(ownerOf(_tokenId) == msg.sender);

        // transfer the token to the address specified in the function args[1]
        _transferFrom(msg.sender, _transferToAddress, _tokenId);
    }

}