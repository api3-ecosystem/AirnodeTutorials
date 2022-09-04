//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@api3/airnode-protocol/contracts/rrp/requesters/RrpRequesterV0.sol";

// An requester that will return the Tesla Stock Price by calling a dxFeed airnode.
contract Requester is RrpRequesterV0 {

    bytes public parameters =
        abi.encode(
            bytes32("1SSSS"),
            bytes32("symbol"),
            "TSLA",
            bytes32("event"),
            "Trade",
            bytes32("_path"),
            "Trade.TSLA.price",
            bytes32("_type"),
            "int256"
        );

    mapping(bytes32 => bool) public incomingFulfillments;
    mapping(bytes32 => int256) public fulfilledData;

    constructor(address _rrpAddress) RrpRequesterV0(_rrpAddress) {}

    function makeRequest(
        address airnode,
        bytes32 endpointId,
        address sponsor,
        address sponsorWallet
        
    ) external {
        bytes32 requestId = airnodeRrp.makeFullRequest(
            airnode,
            endpointId,
            sponsor,
            sponsorWallet,
            address(this),
            this.fulfill.selector,
            parameters
        );
        incomingFulfillments[requestId] = true;
    }

    function fulfill(bytes32 requestId, bytes calldata data)
        external
        onlyAirnodeRrp
    {
        require(incomingFulfillments[requestId], "No such request made");
        delete incomingFulfillments[requestId];
        int256 decodedData = abi.decode(data, (int256));
        fulfilledData[requestId] = decodedData;
    }
}