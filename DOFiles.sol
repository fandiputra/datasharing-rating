pragma solidity <0.7.0;

import "./Shared.sol";
import "./Controller.sol";

contract DataOwnerFiles {
    // State variables
    address public dataOwner;
    // Shared.File[] public files;
    bytes32[] public bundleHashes;
    mapping(bytes32 => Shared.File) public files;
    mapping(bytes32 => Shared.Request) public request;
    bytes32 public tokenID;
    Controller controller;

    // Mediator
    constructor(address controllerAddress) public {
        dataOwner = msg.sender;
        controller = Controller(controllerAddress);
    }

    // Modifiers
    modifier onlyDataOwner {
        require(msg.sender == dataOwner, "DataOwner required");
        _;
    }

    modifier onlyDataRequester {
        require(controller.isDataRequesterRegistered(msg.sender));
        _;
    }

    modifier onlyOracle {
        require(controller.isOracleRegistered(msg.sender));
        _;
    }

    modifier onlyMPA {
        require(controller.isMPARegistered(msg.sender));
        _;
    }

    function addFile(bytes32 _bundleHash, byte _permissions) public onlyDataOwner {
        bundleHashes.push(_bundleHash);

        Shared.File memory newFile;
        newFile.permissions = _permissions;
        files[_bundleHash] = newFile;

        emit fileAddedDataOwner();
        emit fileAddedMPA();
    }

    event fileAddedDataOwner(); // Inform dataOwner // TODO: finish this // TODO: make sure this is correct (no timeout issues)
    event fileAddedMPA();
    function setFileMPAAuthRequiredCount(bytes32 _bundleHash, uint8 _MPAAuthRequiredCount) public onlyDataOwner {
        bundleHashes.push(_bundleHash);

        Shared.File memory newFile;
        newFile.permissions = 0x01;
        newFile.MPAAuthRequiredCount = _MPAAuthRequiredCount;
        files[_bundleHash] = newFile;

        emit fileAddedDataOwner();
        emit fileAddedMPA();
    }


    function requestFile(bytes32 _bundleHash, uint8 _minOracleCount, uint8 _maxOracleCount) public onlyDataOwner {
        // require(Shared.checkPublicKey(_publicKey), "Valid public key required");
        // require((uint(keccak256(_publicKey)) & (0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) == uint(msg.sender), "Valid public key required");
        require(_minOracleCount <= _maxOracleCount, "_minOracleCount <= _maxOracleCount required");

        bundleHashes.push(_bundleHash);

        Shared.Request memory newRequest;
        newRequest.dataRequester = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        newRequest.requestTime = block.timestamp;
        newRequest.minOracleCount = _minOracleCount;
        newRequest.maxOracleCount = _maxOracleCount;
        newRequest.oraclesEvaluated = false;
        request[_bundleHash] = newRequest;
    }

    // Respond to a pending request (done by dataOwner)
    event requestRespondedDataRequester();
    event requestRespondedDataOwner();
    event requestRespondedOracles(); // TODO: must include bundle hash and so and so
    function respondRequest(bytes32 _bundleHash, bool _grant) public onlyDataOwner {
        if (_grant) {
            bundleHashes.push(_bundleHash);

            Shared.Request memory newRequest;
            newRequest.dataRequester = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
            newRequest.requestTime = block.timestamp;
            newRequest.minOracleCount = 1;
            newRequest.maxOracleCount = 10;
            newRequest.oraclesEvaluated = false;
            newRequest.granted = true;
            newRequest.MPAAuthCount = 1;
            request[_bundleHash] = newRequest;
        }

        emit requestRespondedDataRequester();
        emit requestRespondedDataOwner();

    }

    // Add oracle response (done by oracle)
    function addOracleResponse(bytes32 _bundleHash) public onlyDataOwner {

        bundleHashes.push(_bundleHash);

        Shared.Request memory newRequest;
        newRequest.dataRequester = 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db;
        newRequest.requestTime = block.timestamp;
        newRequest.minOracleCount = 1;
        newRequest.maxOracleCount = 10;
        newRequest.oraclesEvaluated = true;
        newRequest.granted = true;
        newRequest.MPAAuthCount = 1;
        newRequest.oracleAddresses = 0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678;
        newRequest.oracleRatings = 75;
        //tokenID = keccak256(abi.encodePacked("0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678", "1621224605"));
        tokenID = 0x79b7a312383371a2c60bcc6175f12b3028a2cdabf59d88242d21743800b17397;

        request[_bundleHash] = newRequest;
    }
}
