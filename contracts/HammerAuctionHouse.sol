// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface IAuctionFinalizable {
    function finalizeAuction(uint256 auctionId) external;
}

contract HammerAuctionHouse {

    struct AuctionInfo {
        address auctionContract;
        uint256 internalAuctionId; // ID inside that contract
        bool finalized;
    }

    mapping(uint256 => AuctionInfo) public auctions;
    uint256 public auctionCounter;

    event AuctionRegistered(
        uint256 indexed auctionId,
        address auctionContract,
        uint256 internalAuctionId
    );

    event AuctionFinalized(uint256 indexed auctionId);

    modifier exists(uint256 auctionId) {
        require(auctionId < auctionCounter, "Invalid auctionId");
        _;
    }

    function registerAuction(
        address auctionContract,
        uint256 internalAuctionId
    ) external {
        require(auctionContract != address(0), "Zero address");

        auctions[auctionCounter] = AuctionInfo({
            auctionContract: auctionContract,
            internalAuctionId: internalAuctionId,
            finalized: false
        });

        emit AuctionRegistered(
            auctionCounter,
            auctionContract,
            internalAuctionId
        );

        auctionCounter++;
    }

    function finalizeAuction(uint256 auctionId)
        external
        exists(auctionId)
    {
        AuctionInfo storage auction = auctions[auctionId];

        require(!auction.finalized, "Already finalized");

        IAuctionFinalizable(auction.auctionContract)
            .finalizeAuction(auction.internalAuctionId);

        auction.finalized = true;

        emit AuctionFinalized(auctionId);
    }
}
