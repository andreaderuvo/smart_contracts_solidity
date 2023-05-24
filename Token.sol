// SPDX-License-Identifier: GPL-3.0

/*
    This statement specifies the version of the Solidity compiler used to compile the contract.
    In this case, the contract requires a version of Solidity between 0.8.2 (inclusive) and 0.9.0 (exclusive).
*/
pragma solidity >=0.8.2 <0.9.0;

/*
    The Token contract is a smart contract that manages a collection of tokens.
    It provides functions for minting new tokens, transferring ownership of tokens, granting authorizations for token transfers, and approving token transfers.

    The contract utilizes two mappings: tokenOwners and authorisations.
    The tokenOwners mapping associates each token ID with the address of its current owner.
    The authorisations mapping stores the address that is authorized to transfer each token ID.

    The contract includes a creator variable to track the address of the contract creator, and a modifier onlyCreator that ensures certain 
    functions can only be called by the creator.

    The mint function allows the creator to mint new tokens by assigning an owner address to a specific token ID.
    It enforces that a token can only be minted once and that the recipient address is valid.

    The transfer function enables the current owner of a token to transfer its ownership to a new address.
    It verifies the sender is the owner and performs the transfer while canceling any existing authorization for the token.

    The transferFrom function allows the owner or an authorized address to transfer ownership of a token from one address to another.
    It checks the sender's authority, the current owner, and cancels any authorization for the token.

    The approve function permits the token owner to authorize a specific address to transfer their token.
    It removes any previous authorization and sets a new authorization if the spender address is valid.

    Overall, the Token contract provides basic functionalities for managing ownership and authorization of tokens,
    allowing for secure and controlled token transfers within the contract.
*/
contract Token {
    /*
        This code defines a contract named Token that maintains two mappings: tokenOwners and authorisations.
        The tokenOwners mapping stores the address of the owner for each token ID, and the authorisations mapping stores the address
        that is authorized to transfer each token ID.
    */
    mapping(uint => address) public tokenOwners;
    mapping(uint => address) public authorisations;

    /*
        This line declares a private variable creator of type address.
    */
    address private creator;
    
    /*
        This is a modifier named onlyCreator. It ensures that the function it modifies is only executed by the creator of the contract.
    */
    /*modifier onlyCreator() {
        assert(msg.sender == creator);
        _;
    }*/

    /* 
        This is the constructor function. It sets the creator variable to the address of the account that deployed the contract.
    */
    constructor() {
        creator = msg.sender;
    }

    /*
        The mint function is used to create a new token with the given ID and assign it to the specified address (to).
        It can only be called by the creator of the contract.
        It asserts that the token ID does not have an existing owner (address(0)) and that the recipient address is not the null address (address(0)).
    */
    function mint(uint id, address to) external /*onlyCreator*/ {
        require(msg.sender != address(0), "Invalid sender address");

        /* Alternative way to don't use the onlyCreator modifier */
        require(msg.sender == creator, "Only the owner of the contract can mint");
        require(tokenOwners[id] == address(0), "Token already minted");
        require(to != address(0), "Invalid recipient address");
        tokenOwners[id] = to;

        /* 
            Verifies that the ownership transfer was successful
        */
        assert(tokenOwners[id] == to);
    }

    /*
        The transfer function is used to transfer ownership of a token with the given ID to a new address (to).
        It verifies that the current owner of the token is not the null address, the sender of the transfer is the current owner, and the sender is not the null address.
        It deletes any existing authorization for the token and updates the ownership to the new address.
    */
    function transfer(uint id, address to) external {
        require(msg.sender != address(0), "Invalid sender address");

        address owner = tokenOwners[id];
        require(owner != address(0), "Token does not exist");
        require(msg.sender == owner, "Only the token owner can transfer the token, use transferFrom if you are authorised");
        require(to != owner, "You can not transfer to yourself");
        


        /* 
            It is a logical delete as proposed in the assignment.
            It could also be physically deleted using delete authorisations[id] (better).
        */
        authorisations[id] = address(0);

        tokenOwners[id] = to;

        /* 
            Verifies that the authorization was deleted
        */
        assert(authorisations[id] == address(0));

        /* 
            Verifies that the ownership transfer was successful
        */
        assert(tokenOwners[id] == to);
    }

    /*
        The transferFrom function is similar to transfer, but it allows a designated address (msg.sender or the authorised address)
        to transfer the token from the from address to the to address.
        It checks the ownership and authorization, as well as the sender and owner addresses.
    */
    function transferFrom(uint id, address from, address to) external {
        require(msg.sender != address(0), "Invalid sender address");
        
        address owner = tokenOwners[id];
        address authorised = authorisations[id];
        require(owner != address(0), "Token does not exist");
        require(msg.sender == owner || msg.sender == authorised, "Not authorized to transfer the token");        

        require(owner == from, "Sender is not the current owner of the token");
        require(to != from, "You cannot transfer if from and to are equals");

        /* 
            It is a logical delete as proposed in the assignment.
            It could also be physically deleted using delete authorisations[id] (better).
        */
        authorisations[id] = address(0);

        tokenOwners[id] = to;

        /* 
            Verifies that the authorization was deleted
        */
        assert(authorisations[id] == address(0));

        /* 
            Verifies that the ownership transfer was successful
        */
        assert(tokenOwners[id] == to);
    }

    /*
        The approve function is used to grant authorization to transfer a token to a specific address (spender).
        It verifies that the sender is the owner of the token and sets the new authorization
        only if the spender address is not the null address.
    */
    function approve(uint id, address spender) external {
        address owner = tokenOwners[id];

        /* not needed as suggested by solc but inserted as requested in the exercise */
        require(msg.sender != address(0), "Invalid sender address");

        require(msg.sender == owner, "The sender must own the token to grant authorisation");
        require(msg.sender != spender, "You are already approved since it is your token");


        if (spender != address(0)) {
            authorisations[id] = spender;
        } else {
            /* 
                It is a logical delete as proposed in the assignment.
                It could also be physically deleted using delete authorisations[id] (better).
            */
            authorisations[id] = address(0);
        }

        /*
            Verifies that the authorization was set correctly
        */
        assert(authorisations[id] == spender);

    }
}