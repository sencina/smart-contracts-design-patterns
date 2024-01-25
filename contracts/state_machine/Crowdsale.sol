// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Crowdsale {

    enum Stage {
        Created, Started, Ended
    }

    address payable public owner;
    Stage public currentStage;
    uint256 public fundingGoal;
    uint256 public fundsRaised;

    constructor(uint256 _fundingGaol){
        owner = payable(msg.sender);
        fundingGoal = _fundingGaol;
        currentStage = Stage.Created;
        fundsRaised = 0;
    }

    modifier atStage(Stage stage) {
        require(currentStage == stage, "Invalid crowdsale stage for this actrion");
        _;
    }

    modifier onlyOwner(){
        require(address(msg.sender) == owner, "Only owner can perform this action");
        _;
    }

    function start() public onlyOwner() atStage(Stage.Created){
        currentStage = Stage.Started;
    }

    function fund() public payable atStage(Stage.Started) {
        require(msg.value > 0, "Amount must be greater than 0");
        require(address(msg.sender).balance >= msg.value, "User must have funds to execute this action");
        
        fundsRaised += msg.value;
        if (fundsRaised >= fundingGoal){ currentStage = Stage.Ended;}
    }

    function claimFunds() public payable atStage(Stage.Ended) onlyOwner() {
        payable(msg.sender).transfer(fundsRaised);
    }

}