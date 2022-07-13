# P2P Trade Operations

# Smart Contract 1 - TradeOperations

1. Users can create Buy and Sell Orders for any item.
2. Bidders bid on those orders during the allotted time interval.
3. The highest bidder will complete the transaction.

# Smart Contract 2 - Escrow Model

1. User1 can create a Buy and Sell Order for any item.
2. User2 can Sell and Buy respectively for that item.
3. Both will transfer the funds to the escrow account. 
4. If both parties find any dispute within the transaction, 
    For eg. User1 puts an item for sale. User2 to buy that, sends funds to an escrow account.
                 User1 is supposed to ship that item to User2 (off-chain). Only then the escrow account will send funds to User1.
                 Otherwise, admin will find out what went wrong. (Off chain process)

# Deployed Contracts
Contracts are deployed on Rinkeby Network

1. JagguToken contract is deployed at (0x1C5a19dd34995d10202a7E15Bc0A4458fdF7dE5D)
    - Etherscan link - https://rinkeby.etherscan.io/address/0x1C5a19dd34995d10202a7E15Bc0A4458fdF7dE5D

2. TradeOperations contract is deployed at (0x9ae8Be1CE80b2942b062e6F5f42ed5cB6ce876f2) 
    - Etherscan link - https://rinkeby.etherscan.io/address/0x9ae8Be1CE80b2942b062e6F5f42ed5cB6ce876f2

