// SPDX-License-Identifier: GPL-3.0

/*
    This statement specifies the version of the Solidity compiler used to compile the contract.
    In this case, the contract requires a version of Solidity between 0.8.2 (inclusive) and 0.9.0 (exclusive).
*/
pragma solidity >=0.8.2 <0.9.0;

/*
    The Auction contract is a smart contract that facilitates the auction process for a collection of tokens.
    It includes functions for starting an auction, placing bids, ending auctions, and withdrawing funds.

    The contract defines a Token struct that represents each token being auctioned.
    The struct contains information such as the current owner of the token, the highest bid amount, the address of the highest bidder, and the status of the auction.

    The contract utilizes several mappings to store data related to the auction.
    The historyBidders mapping keeps track of the bid history for each token, associating each bidder's address with the corresponding bid amount.
    The tokens mapping stores the Token struct for each token ID. The profits mapping maintains the profits/losses for each address participating in the auction.

    The startAuction function allows the owner of a token to initiate an auction by specifying the token ID and the starting price.
    It verifies that the token is not already in an active auction, that the sender is the token owner, and that the starting price is greater than zero.

    The bid function enables participants to place bids on an active auction by providing the token ID and the bid amount.
    It verifies that the sender is not the token owner, that the auction is active, and that the bid amount exceeds the current highest bid.
    It updates the highest bid details, records the bid in the bid history, and adjusts the profits of the bidder.

    The endAuction function allows the token owner to end an active auction for a specific token.
    It verifies that the auction is active and that the sender is the token owner. If there is a highest bidder, it transfers the bid amount to the token owner,
    updates the profits accordingly, and transfers the ownership of the token to the highest bidder.
    It then resets the auction details.

    The withdraw function allows participants to withdraw their funds from a concluded auction.
    It verifies that the auction is not active, that the sender is not the token owner or the highest bidder, and that the sender has a positive bid amount.
    It transfers the funds to the sender and adjusts their profits accordingly.

    Additionally, the contract includes a getProfit function that allows participants to check their current profit/loss balance.

    Overall, the Auction contract provides functionality for conducting auctions, handling bids, and managing funds in a secure and transparent manner.
*/
contract Auction {

    /*
        This defines a Token struct that represents a token in the auction.
        
        It contains the following variables: 
        * owner (the address of the token owner),
        * highestBid (the amount of the highest bid),
        * highestBidder (the address of the participant with the highest bid)
        * active (indicates whether the auction is active or not)
    */
    struct Token {
        address owner;
        uint256 highestBid;
        address highestBidder;
        bool active;
    }

    /*
        Three mappings are declared here. 
        The historyBidders mapping keeps track of the bid amounts made by each participant for each token (using a double mapping).
        The tokens mapping associates a token ID with its corresponding Token struct. 
        The profits mapping keeps track of the profits of addresses.
        Addresses can have both positive profits (when they sell a token at a higher price) and negative profits (when they participate in the auction).
    */
    mapping(uint256 => mapping(address => uint256)) public historyBidders;
    mapping(uint256 => Token) public tokens;
    mapping(address => int256) public profits;


    function beforeAuction(uint256 id) external {
        /* It ensures that the sender's address is valid and not the zero address. */
        require(msg.sender != address(0), "Invalid sender address");

        /* It ensures that the token has not been previously pushed and that the ownership is not already assigned. */
        require(tokens[id].owner == address(0), "Token can only be pushed once");

        Token memory newToken = Token({
            owner: msg.sender,
            active: false,
            highestBid: 0,
            highestBidder: address(0)
        });
        tokens[id] = newToken;
    }

    /*
        The startAuction function is used to start an auction for a specific token.
    */
    function startAuction(uint256 id, uint256 startPrice) external {
        /* It ensures that the sender's address is valid and not the zero address. */
        require(msg.sender != address(0), "Invalid sender address");
        
        /* 
            These require statements verify that the sender is the owner of the token, the auction is not already active for this token,
            and the start price is greater than zero.
        */
        require(msg.sender == tokens[id].owner, "Sender does not own the token");
        require(!tokens[id].active, "Auction already active for this token");
        require(startPrice > 0, "Start price cannot be zero");

        /* 
            The auction details are initialized with the start price, highest bidder set to address 0, and the 
        */
        tokens[id].highestBid = startPrice;
        tokens[id].highestBidder = address(0);
        tokens[id].active = true;
    }

    /*
        The bid function is used for placing a bid on a token in the auction.

        It verifies that the sender is not the owner of the token, the auction is active for the token, the bid amount is higher 
        than the current highest bid, and the bid amount is greater than or equal to the start price.
    */
    function bid(uint256 id) external payable {
        /* It ensures that the sender's address is valid and not the zero address. */
        require(msg.sender != address(0), "Invalid sender address");

        require(msg.sender != tokens[id].owner, "You cannot bid on your token");
        require(tokens[id].active, "Auction is not active for this token");
        require(msg.value >= tokens[id].highestBid,"Bid amount must be larger than or equal to start price");
        /*
            This code block updates the highest bid details by assigning the bid amount and the bidder's address to the respective variables.
            It also records the bid amount in the historyBidders mapping for future reference and deducts the bid amount from the bidder's profits.
        */
        tokens[id].highestBid = msg.value;
        tokens[id].highestBidder = msg.sender;
        historyBidders[id][msg.sender] = msg.value;

        /* decrease the profit balance of the bidder */
        profits[msg.sender] -= int(msg.value);
    }

    /* 
        The endAuction function is used to end the auction for a specific token.
        It verifies that the auction is active for the token and that the sender is the owner of the token.
    */
    function endAuction(uint256 id) external {
        /* It ensures that the sender's address is valid and not the zero address. */
        require(msg.sender != address(0), "Invalid sender address");

        require(tokens[id].active, "Auction is not active for this token");
        require(msg.sender == tokens[id].owner, "Sender is not the auction starter");

        /*
            If there is a highest bidder for the token, the code block updates the bid amount of the highest bidder to zero in the historyBidders mapping.
            It transfers the bid amount to the auction starter (token owner) and adds the bid amount to their profits.
            Finally, the ownership of the token is transferred to the highest bidder.
        */
        if (tokens[id].highestBidder != address(0)) {           
            historyBidders[id][tokens[id].highestBidder] = 0;

            (bool success, ) = payable(msg.sender).call{value: tokens[id].highestBid}("");
            require(success, "Transfer failed: Insufficient funds or reverted");
            
            tokens[id].owner = tokens[id].highestBidder;            
            profits[msg.sender] += int(tokens[id].highestBid);
        }

        /*
            This code block resets the auction details by setting the highest bid amount to zero, the highest bidder to address 0, and marking the auction as inactive.
        */
        tokens[id].highestBid = 0;
        tokens[id].highestBidder = address(0);
        tokens[id].active = false;
    }

    /*
        The withdraw function allows participants to withdraw their bid amount after the auction ends.
        It verifies that the auction is not active for the token, the sender is not the token owner, and the sender is not the highest bidder.
    */
    function withdraw(uint256 id) external {
        /* It ensures that the sender's address is valid and not the zero address. */
        require(msg.sender != address(0), "Invalid sender address");

        require(!tokens[id].active, "Auction is still active for this token");
        require(tokens[id].owner != msg.sender, "You cannot withdraw beacuse you are the owner of the token");
        require(msg.sender != tokens[id].highestBidder, "You are the highest bidder and you cannot withdraw");
        /*
            If the sender has a non-zero bid amount in the historyBidders mapping, the code transfers the bid amount back to the sender, updates their profits,
            and resets their bid amount to zero.
        */
        if (historyBidders[id][msg.sender] > 0) {
            (bool success, ) = payable(msg.sender).call{value: historyBidders[id][msg.sender]}("");
            require(success, "Transfer failed: Insufficient funds or reverted");
            
            profits[msg.sender] += int(historyBidders[id][msg.sender]);
            historyBidders[id][msg.sender] = 0;
        }
    }

    /*
        The getProfit function allows participants to check their profits.
        It returns the profit of the caller (msg.sender) divided by 1 ether (to convert from Wei to Ether).
    */
    function getProfit() external view returns (int256) {
        /* It ensures that the sender's address is valid and not the zero address. */
        require(msg.sender != address(0), "Invalid sender address");
        return profits[msg.sender];
    }

}
