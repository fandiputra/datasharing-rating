pragma solidity <0.7.0;

library Shared {
    // Structs
    struct File {
        byte permissions; // Access rules

        mapping(uint => Request) requests;
        uint16 requestCount;

        uint8 MPAAuthRequiredCount;

    }

    struct Request {
        address dataRequester;
        uint requestTime;
        uint8 minOracleCount;
        uint8 maxOracleCount;

        bool granted;
        uint8 MPAAuthCount;

        bool oraclesEvaluated;
        address oracleAddresses;
        uint16 oracleRatings;

    }

    struct DO {
        bool registered;

        uint16 averageContractRating;
        uint16 contractRatingCount;

        uint16 averageDataRequesterRating;
        uint16 dataRequesterRatingCount;
    }

    struct DR {
        bool registered;

        uint8 MPAAuthCount;
        address[] MPAAuthAddresses;
        bytes1[] claims;

        bytes32[] tokenIDs;
        mapping(bytes32 => DRToken) tokens;
    }

    struct DRToken{
        bool exists;
        address oracleAddress;
    }

    struct Oracle {
        bool registered;

        uint16 averageContractRating;
        uint16 contractRatingCount;

        uint16 averageDataRequesterRating;
        uint16 dataRequesterRatingCount;

        bytes32[] tokenIDs;
        mapping (bytes32 => OracleToken) tokens;
    }

    struct MPA {
        bool registered;
    }

    struct OracleToken {
        bool exists;
        address dataRequesterAddress;
    }


}
