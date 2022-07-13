//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/utils/Counters.sol";

/// @title P2P Trade Operations with Bidding Option
/// @author Pankaj Jagtap

contract TradeOperations {
    using Counters for Counters.Counter;
    Counters.Counter public itemId;

    uint256 public listingFee = 0.25 ether;
    uint256 public bidFee = 0.25 ether;
    uint256 public orderExpiry = 60 * 60 * 24;

    // EVENTS
    event SellOrderPlaced(
        uint256 itemId,
        string description,
        uint256 sellingPrice,
        address indexed seller,
        uint256 timestamp,
        uint256 deadline
    );

    event BidPlaced(
        uint256 itemId,
        address indexed bidder,
        uint256 bidPrice,
        uint256 timestamp
    );

    event SaleCancelled(
        uint256 itemId,
        address indexed seller,
        uint256 timestamp
    );

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
        uint256 highestBid;
        address highestBidder;
        uint256 timestamp;
        uint256 deadline;
        bool isSold;
    }

    struct Bid {
        uint256 orderId;
        address bidder;
        uint256 price;
        uint256 timestamp;
    }

    // MAPPINGS
    mapping(uint256 => Item) public itemIdToItemMap;
    mapping(address => Bid) public biddersMapping; // Every Bid order is mapped to the bidder's address

    // MAIN FUNCTIONS
    function sellItem(uint256 _sellingPrice, string memory _description)
        external
        payable
    {
        require(msg.value == listingFee, "Sending listing fee");
        require(_sellingPrice > 0, "Cannot sell for Free");

        itemId.increment();
        uint256 _itemId = itemId.current();

        uint256 _deadline = block.timestamp + orderExpiry;

        itemIdToItemMap[_itemId] = Item(
            _itemId,
            _description,
            _sellingPrice,
            msg.sender,
            0,
            address(0),
            block.timestamp,
            _deadline,
            false
        );

        emit SellOrderPlaced(
            _itemId,
            _description,
            _sellingPrice,
            msg.sender,
            block.timestamp,
            _deadline
        );
    }

    function cancelSale(uint256 _itemId) external itemIdExists(_itemId) {
        Item memory item = itemIdToItemMap[_itemId];
        require(item.seller == msg.sender, "You are not the seller");
        require(item.highestBidder == address(0), "People have bidded");

        delete itemIdToItemMap[_itemId];

        emit SaleCancelled(_itemId, msg.sender, block.timestamp);
    }

    function bid(uint256 _itemId, uint256 _amount) external payable {
        Item storage item = itemIdToItemMap[_itemId];

        require(msg.value == bidFee, "Need to pay Bid Fee");
        require(block.timestamp < item.deadline, "Deadline has passed");
        require(
            biddersMapping[msg.sender].price == 0,
            "You have already have a Bid"
        );
        require(_amount > item.highestBid, "Need to bid more");

        biddersMapping[msg.sender] = Bid(
            _itemId,
            msg.sender,
            _amount,
            block.timestamp
        );
        item.highestBid = _amount;
        item.highestBidder = msg.sender;
    }

    function sendFunds(uint256 _itemId) external payable {
        Item storage item = itemIdToItemMap[_itemId];

        require(
            msg.sender == item.highestBidder,
            "Need to be the highest Bidder"
        );
        require(msg.value >= item.highestBid, "Send highest bid amount");
        require(block.timestamp > item.deadline, "Deadline has not passed");

        payable(item.seller).transfer(item.highestBid);
        item.isSold = true;
    }
}
