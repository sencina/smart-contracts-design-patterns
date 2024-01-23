// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract PaymentSystem {

    uint256 public fee = 10; // 10% fee, there is no native support for floating numbers in Solidity
    mapping(address => bool) public paid; // map to check if it is the first payment of the user who is paying

    function pay(address payable recipient) payable public {
        require(recipient != address(0), "Recipient address cannot be zero");
        require(msg.value != 0, "Amount must not be 0");

        uint256 previousBalance = address(this).balance;
        uint256 transferAmount;

        if (!paid[msg.sender]) {
            // Condition: If it's the first payment from the user
            transferAmount = msg.value;
            paid[msg.sender] = true;
        } else {
            transferAmount = (msg.value * (100 - fee)) / 100;
            if (transferAmount == 0) {
                revert("Transfer amount after fee must be greater than 0"); //This will never happen as the second require catches this, but is an example of how to use it.
            }
        }

        //Tranfers native coin from the msg.sender to the recipient
        recipient.transfer(transferAmount);

        // Assert to check if the contract's balance is updated correctly
        assert(address(this).balance == previousBalance - transferAmount);
    }
}
