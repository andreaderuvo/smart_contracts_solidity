Token Contract
==============

This is a Solidity smart contract that manages a collection of tokens. The contract provides functions for minting new tokens, transferring ownership of tokens, granting authorizations for token transfers, and approving token transfers.

Solidity Version
----------------

The contract requires a version of Solidity between 0.8.2 (inclusive) and 0.9.0 (exclusive).

License
-------

This contract is licensed under the GNU General Public License v3.0 (SPDX-License-Identifier: GPL-3.0).

Contract Details
----------------

The `Token` contract includes the following features:

### State Variables

-   `mapping(uint => address) public tokenOwners`: Stores the address of the owner for each token ID.
-   `mapping(uint => address) public authorisations`: Stores the address authorized to transfer each token ID.
-   `address private creator`: Keeps track of the contract creator's address.

### Constructor

-   `constructor()`: Initializes the `creator` variable with the address of the deploying account.

### Usage

To use this contract, you can deploy it to an Ethereum-compatible blockchain network and interact with it using a compatible wallet or application.

### Functionality

-   `function mint(uint id, address to) external`: Allows the creator to mint a new token with the given ID and assign it to the specified address. The token can only be minted once, and the recipient address must be valid.
-   `function transfer(uint id, address to) external`: Enables the current owner of a token to transfer its ownership to a new address. The sender must be the token owner, and the transfer cancels any existing authorization for the token.
-   `function transferFrom(uint id, address from, address to) external`: Allows the owner or an authorized address to transfer ownership of a token from one address to another. The sender must have the authority to transfer the token, and the transfer cancels any existing authorization for the token.
-   `function approve(uint id, address spender) external`: Permits the token owner to authorize a specific address to transfer their token. The sender must be the owner of the token, and the authorization can be set or revoked by providing a valid spender address.

Please refer to the source code comments for detailed explanations of each function.

### Model checking

```sh
$ uname -a

Linux andreapc 5.19.0-42-generic #43~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Apr 21 16:51:08 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

$ solc --version

solc, the solidity compiler commandline interface

Version: 0.8.20+commit.a1b79de6.Linux.g++

$ time solc Token.sol --model-checker-engine chc --model-checker-show-unproved --model-checker-targets all --model-checker-invariants all

Info: CHC: 6 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.

real	0m2,439s
user	0m1,902s
sys	    0m0,522s

$ time solc Token.sol --model-checker-engine bmc --model-checker-show-unproved --model-checker-targets all --model-checker-invariants all

Info: BMC: 6 verification condition(s) proved safe! Enable the model checker option "show proved safe" to see all of them.

real	0m0,318s
user	0m0,316s
sys	    0m0,000s
```

# Auction Contract

This smart contract facilitates the auction process for a collection of tokens. It includes functions for starting an auction, placing bids, ending auctions, and withdrawing funds.

## Solidity Version

The contract requires a version of Solidity between 0.8.2 (inclusive) and 0.9.0 (exclusive).

License
-------

This contract is licensed under the GNU General Public License v3.0 (SPDX-License-Identifier: GPL-3.0).

## Contract Details

The Auction contract defines a Token struct that represents each token being auctioned. The struct contains information such as the current owner of the token, the highest bid amount, the address of the highest bidder, and the status of the auction.

### State Variables
The contract utilizes several mappings to store data related to the auction:

- The `historyBidders` mapping keeps track of the bid history for each token, associating each bidder's address with the corresponding bid amount.

- The `tokens` mapping stores the Token struct for each token ID.

- The `profits` mapping maintains the profits/losses for each address participating in the auction.

## Functionality

The Auction contract provides the following functions:

-   `beforeAuction(uint256 id)`: This function is used to initialize a token before starting the auction. It ensures that the sender's address is valid and not the zero address. It also verifies that the token has not been previously pushed and that the ownership is not already assigned.
-   `startAuction(uint256 id, uint256 startPrice)`: This function is used to start an auction for a specific token. It ensures that the sender's address is valid and not the zero address. It also verifies that the sender is the owner of the token, the auction is not already active for this token, and the start price is greater than zero.
-   `bid(uint256 id)`: This function is used to place a bid on a token in the auction. It ensures that the sender's address is valid and not the zero address. It verifies that the sender is not the owner of the token, the auction is active for the token, the bid amount is higher than the current highest bid, and the bid amount is greater than or equal to the start price.
-   `endAuction(uint256 id)`: This function is used to end the auction for a specific token. It ensures that the sender's address is valid and not the zero address. It verifies that the auction is active for the token and that the sender is the owner of the token. If there is a highest bidder, it transfers the bid amount to the token owner, updates the profits accordingly, and transfers the ownership of the token to the highest bidder. It then resets the auction details.
-   `withdraw(uint256 id)`:This function allows participants to withdraw their funds from a concluded auction. It ensures that the sender's address is valid and not the zero address. It verifies that the auction is not active, that the sender is not the token owner or the highest bidder, and that the sender has a positive bid amount. It transfers the funds to the sender and adjusts their profits accordingly.
-   `getProfit()`:
This function allows participants to check their current profit/loss balance. It ensures that the sender's address is valid and not the zero address. It returns the profit of the caller (msg.sender) divided by 1 ether (to convert from Wei to Ether).

### Usage

To use this contract, you can deploy it to an Ethereum-compatible blockchain network and interact with it using a compatible wallet or application.

### Model checking
The `bmc` engine does not produce any warnings.

The `chc` engine generates warnings regarding overflow/underflow, but it is not an issue if the minimum version of Solidity is 0.8.0 or higher.

> Arithmetic operations revert on underflow and overflow. You can use unchecked { ... } to use the previous wrapping behaviour. (ref: https://docs.soliditylang.org/en/v0.8.0/080-breaking-changes.html)

```sh
$ uname -a

Linux andreapc 5.19.0-42-generic #43~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Apr 21 16:51:08 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

$ solc --version

solc, the solidity compiler commandline interface

Version: 0.8.20+commit.a1b79de6.Linux.g++

$ time solc Auction.sol --model-checker-engine bmc --model-checker-show-unproved --model-checker-targets all --model-checker-invariants all

Compiler run successful. No output generated.

real    0m0,303s
user    0m0,258s
sys 0m0,037s

$ time solc Auction.sol --model-checker-engine chc --model-checker-show-unproved --model-checker-targets all --model-checker-invariants all

Warning: CHC: Underflow (resulting value less than -2**255) might happen here.

   --> Auction.sol:131:9:

    |

131 |         profits[msg.sender] -= int(msg.value);

    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Warning: CHC: Overflow (resulting value larger than 2**255 - 1) might happen here.

   --> Auction.sol:131:9:

    |

131 |         profits[msg.sender] -= int(msg.value);

    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Warning: CHC: Underflow (resulting value less than -2**255) might happen here.

   --> Auction.sol:157:13:

    |

157 |             profits[msg.sender] += int(tokens[id].highestBid);

    |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Warning: CHC: Overflow (resulting value larger than 2**255 - 1) might happen here.

   --> Auction.sol:157:13:

    |

157 |             profits[msg.sender] += int(tokens[id].highestBid);

    |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Warning: CHC: Underflow (resulting value less than -2**255) might happen here.

   --> Auction.sol:187:13:

    |

187 |             profits[msg.sender] += int(historyBidders[id][msg.sender]);

    |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



Warning: CHC: Overflow (resulting value larger than 2**255 - 1) might happen here.

   --> Auction.sol:187:13:

    |

187 |             profits[msg.sender] += int(historyBidders[id][msg.sender]);

    |             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

real    0m3,020s
user    0m2,887s
sys 0m0,122s
```