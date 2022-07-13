//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title P2P Trade Operations with Escrow Model
/// @author Pankaj Jagtap

contract EscrowModel is Ownable {
    using Counters for Counters.Counter;
    Counters.Counter public itemId;

    uint256 public listingFee = 0.1 ether; // Fee to sell item on platform
    uint256 public orderExpiry = 60 * 60 * 24; // Buyers can claim refund after 1 day

    // EVENTS
    event SellOrderPlaced(
        uint256 itemId,
        string description,
        uint256 sellingPrice,
        address indexed seller
    );

    event BuyOrderPlaced(
        uint256 itemId,
        uint256 buyingPrice,
        address indexed buyer,
        uint256 timestamp,
        uint256 deadline
    );

    event TradeExecuted(
        uint256 itemId,
        uint256 sellingPrice,
        address indexed seller,
        address indexed buyer
    );

    event CancelSellOrder(uint256 itemId, address indexed seller);

    event BuyerRefundClaimed(address indexed buyer);

    event ListingFeeChanged(uint256 listingFee);

    // MODIFIERS
    modifier itemIdExists(uint256 _itemId) {
        uint256 currentItemId = itemId.current();
        require(_itemId > 0 && _itemId <= currentItemId, "Item does not exist");
        _;
    }

    // STRUCTS
    struct Item {
        uint256 itemId;
        string description;
        uint256 sellingPrice;
        address seller;
        bool isSellerSatisfied;
        bool isBuyerSatisfied;
    }

    struct Buyer {
        address buyer;
        uint256 buyingPrice;
        uint256 timestamp;
        uint256 deadline;
    }

    // MAPPINGS
    mapping(uint256 => Item) public itemIdToItemMap;
    mapping(uint256 => Buyer) public itemIdToBuyer;

    // MAIN FUNCTIONS
    function sellItem(uint256 _sellingPrice, string memory _description)
        external
        payable
    {
        require(msg.value == listingFee, "Sending listing fee");
        require(_sellingPrice > 0, "Cannot sell for Free");

        itemId.increment();
        uint256 _itemId = itemId.current();

        itemIdToItemMap[_itemId] = Item(
            _itemId,
            _description,
            _sellingPrice,
            msg.sender,
            false,
            false
        );

        emit SellOrderPlaced(_itemId, _description, _sellingPrice, msg.sender);
    }

    function cancelSale(uint256 _itemId) external itemIdExists(_itemId) {
        Item memory item = itemIdToItemMap[_itemId];
        require(
            item.seller == msg.sender,
            "You are not the seller of the item"
        );

        delete itemIdToItemMap[_itemId];

        emit CancelSellOrder(_itemId, msg.sender);
    }

    function buyItem(uint256 _itemId, uint256 _buyingPrice)
        external
        payable
        itemIdExists(_itemId)
    {
        require(_buyingPrice > 0, "Cannot buy for Free");
        require(
            itemIdToBuyer[_itemId].buyingPrice == 0,
            "Buyer already exists"
        );
        require(msg.value == _buyingPrice, "Send exact buying price");

        uint256 _deadline = block.timestamp + orderExpiry;

        itemIdToBuyer[_itemId] = Buyer(
            msg.sender,
            _buyingPrice,
            block.timestamp,
            _deadline
        );

        emit BuyOrderPlaced(
            _itemId,
            _buyingPrice,
            msg.sender,
            block.timestamp,
            _deadline
        );
    }

    function isSellerSatisfied(uint256 _itemId, bool _reply)
        external
        itemIdExists(_itemId)
        returns (bool)
    {
        Item storage item = itemIdToItemMap[_itemId];
        require(item.seller == msg.sender, "You are not the seller");
        item.isSellerSatisfied = _reply;
        return _reply;
    }

    function isBuyerSatisfied(uint256 _itemId, bool _reply)
        external
        itemIdExists(_itemId)
        returns (bool)
    {
        require(
            itemIdToBuyer[_itemId].buyer == msg.sender,
            "You are not the buyer"
        );

        itemIdToItemMap[_itemId].isBuyerSatisfied = _reply;
        return _reply;
    }

    function claimBuyerFunds(uint256 _itemId) external itemIdExists(_itemId) {
        Buyer memory b = itemIdToBuyer[_itemId];

        require(b.buyer == msg.sender, "You are not the buyer");
        require(block.timestamp > b.deadline, "Deadline has not passed");

        payable(b.buyer).transfer(b.buyingPrice);

        delete itemIdToBuyer[_itemId];

        emit BuyerRefundClaimed(msg.sender);
    }

    function _sendFunds(uint256 _itemId)
        external
        onlyOwner
        itemIdExists(_itemId)
    {
        Item memory item = itemIdToItemMap[_itemId];
        Buyer memory b = itemIdToBuyer[_itemId];

        require(
            b.deadline > block.timestamp && block.timestamp > b.timestamp,
            "Deadline has passed"
        );

        if (item.isSellerSatisfied && item.isBuyerSatisfied) {
            payable(item.seller).transfer(b.buyingPrice);

            delete itemIdToItemMap[_itemId];

            emit TradeExecuted(
                _itemId,
                item.sellingPrice,
                item.seller,
                b.buyer
            );
        }
    }

    function _changeListingFee(uint256 _listingFee) internal onlyOwner {
        listingFee = _listingFee;

        emit ListingFeeChanged(listingFee);
    }
}
