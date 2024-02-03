// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import "../imports/solc-v0.8.x/provableAPI.sol";

//Contract that fetches and saves the last fetched pokemon weight from the pokemon API
contract PokemonWeightFetcher is usingProvable {
    
    uint256 public weight;
    event LogWeightUpdated(uint256 weight);
    event LogNewProvableQuery(string description);

    function _callback(bytes32 myid, uint256 result) public {
        if (msg.sender != provable_cbAddress()) revert();
        weight = result;
        emit LogWeightUpdated(result);
    }

    function updateWeigth(string calldata pokemon) payable public {
        if(provable_getPrice("URL") > address(this).balance) {
            emit LogNewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            string memory apiUrl = string(abi.encodePacked("json(https://pokeapi.co/api/v2/pokemon/", pokemon, ").weight"));
            emit LogNewProvableQuery("Provable query was sent, standing by for the answer...");
            provable_query("URL", apiUrl);
        }
    }

}