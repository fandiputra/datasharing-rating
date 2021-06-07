pragma solidity <0.7.0;

import "./Shared.sol";

contract Controller {
    // State variables
    address owner;
    mapping (address => Shared.DO) public dataOwners;
    mapping (address => Shared.DR) public dataRequesters;
    mapping (address => Shared.Oracle) public oracles;
    mapping (address => Shared.MPA) public MPAs;
    uint MPACount;

    // Modifier
    modifier notOwner {
        require(msg.sender != owner);
        _;
    }

    modifier onlyNotRegistered {
        require(!dataOwners[msg.sender].registered);
        require(!dataRequesters[msg.sender].registered);
        require(!oracles[msg.sender].registered);
        require(!MPAs[msg.sender].registered);
        _;
    }

    modifier onlyMPA {
        require(MPAs[msg.sender].registered);
        _;
    }

    modifier notOracle {
        require(!oracles[msg.sender].registered);
        _;
    }

    modifier notDataOwner {
        require(!dataOwners[msg.sender].registered);
        _;
    }
    
    // Constructor
    constructor() public {
        owner = msg.sender;
        MPACount = 0;
    }

    // Add dataOwner
    function addDO() public notOracle notOwner onlyNotRegistered {
        Shared.DO memory dataOwner;
        dataOwner.registered = true;
        dataOwner.averageContractRating = 50;
        dataOwner.contractRatingCount = 0;
        dataOwner.averageDataRequesterRating = 50;
        dataOwner.dataRequesterRatingCount = 0;
        dataOwners[msg.sender] = dataOwner;
    }

    // Add dataRequester
    function addDR(bytes1[] memory _claims) public notOracle notOwner onlyNotRegistered {
        Shared.DR memory dataRequester;
        dataRequester.claims= _claims;
        dataRequester.registered= true;
        dataRequesters[msg.sender] = dataRequester;
    }

    function isDRRegistered(address _dataRequesterAddress) public view returns (bool) {
        return dataRequesters[_dataRequesterAddress].registered;
    }

    function getDRMPAAuthCount(address _dataRequesterAddress) public view returns (uint) {
        return dataRequesters[_dataRequesterAddress].MPAAuthCount;
    }

    function authenticateDR(address _dataRequesterAddress) public onlyMPA {
        dataRequesters[_dataRequesterAddress].MPAAuthCount++;
        dataRequesters[_dataRequesterAddress].MPAAuthAddresses.push(msg.sender);
    }

    // Add oracles
    function addOracle() public notOracle notOwner onlyNotRegistered {
        Shared.Oracle memory oracle;
        oracle.registered = true;
        oracle.averageContractRating = 50;
        oracle.contractRatingCount = 0;
        oracle.averageDataRequesterRating = 50;
        oracle.dataRequesterRatingCount = 0;

        oracles[msg.sender] = oracle;
    }

    function isOracleRegistered(address _oracleAddress) public view returns (bool) {
        return oracles[_oracleAddress].registered;
    }

    function addMPA() public notOracle notOwner onlyNotRegistered {
        Shared.MPA memory MPA = Shared.MPA(true);
        MPAs[msg.sender] = MPA;
        MPACount++;
    }

    function isMPARegistered(address _MPAAddress) public view returns (bool) {
        return MPAs[_MPAAddress].registered;
    }

    function getOracleReputations(address[] memory oracleAddresses) view public returns (uint16[] memory) {
        uint16[] memory reputations = new uint16[](oracleAddresses.length);

        for (uint i = 0; i < oracleAddresses.length; i++) {
            Shared.Oracle memory oracle = oracles[oracleAddresses[i]];

            reputations[i] = (oracle.averageContractRating + oracle.averageDataRequesterRating) / 2;
        }

        return reputations;
    }

    function submitContractOracleRatings(address[] memory oracleAdresses, uint16[] memory ratings) public onlyNotRegistered {
        for (uint i = 0; i < 2; i++) {
            Shared.Oracle storage oracle = oracles[oracleAdresses[i]];
            oracle.averageContractRating = (oracle.contractRatingCount * oracle.averageContractRating + ratings[i]) / (oracle.contractRatingCount + 1);
            oracle.contractRatingCount += 1;
        }
    }

     function submitDRToken(address dataRequesterAddress, bytes32 tokenID, address oracleAddress) public onlyNotRegistered {
        dataRequesters[dataRequesterAddress].tokenIDs.push(tokenID);
        dataRequesters[dataRequesterAddress].tokens[tokenID] = Shared.DRToken(true, oracleAddress);
    }

    function submitOracleToken(address oracleAddress, bytes32 tokenID, address dataRequesterAddress) public onlyNotRegistered {
        oracles[oracleAddress].tokenIDs.push(tokenID);
        oracles[oracleAddress].tokens[tokenID] = Shared.OracleToken(true, dataRequesterAddress);
    }

	//ratings
    function submitDROracleRating(address oracleAddress, uint16 rating) public notOracle {

        Shared.Oracle storage oracle = oracles[oracleAddress];
        oracle.averageDataRequesterRating = (oracle.contractRatingCount * oracle.averageContractRating + rating) / (oracle.contractRatingCount + 1);
        oracle.dataRequesterRatingCount += 1;
    }

	//ratings
    function submitDROwnerRating(address dataOwnerAddress, uint16 rating) public notDataOwner {

        Shared.DO storage dataOwner = dataOwners[dataOwnerAddress];
        dataOwner.averageDataRequesterRating = (dataOwner.contractRatingCount * dataOwner.averageContractRating + rating) / (dataOwner.contractRatingCount + 1);
        dataOwner.dataRequesterRatingCount += 1;
    }
}
