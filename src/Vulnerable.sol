// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract VulnerableContract {
    mapping(address => uint256) public balances;
    address public owner;
    uint256 public lotteryWinnerSeed;
    address public delegateTarget; // Used for delegatecall vulnerability

    constructor() {
        owner = msg.sender;
    }

    function withdraw(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= _amount;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    address[] public payees;
    uint256 public payoutIndex;

    function processPayouts() public {
        require(payees.length > 0, "No payees available");

        address payee = payees[payoutIndex];
        (bool success, ) = payee.call{value: 1 ether}(""); // Assuming 1 ether for simplicity

        require(success, "Payment failed");

        payoutIndex++;
        if (payoutIndex >= payees.length) {
            payoutIndex = 0; // Reset index
        }
    }

    // Add a payee
    function addPayee(address _payee) public {
        payees.push(_payee);
    }

    function lottery() public view returns (address winner) {
        uint256 randomSeed = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));

        // Select a winner from the list of payees using weak randomness
        uint256 winnerIndex = randomSeed % payees.length;
        winner = payees[winnerIndex];
    }

    function executeDelegateCall(bytes memory data) public {
        require(msg.sender == owner, "Only owner can execute delegatecall");

        (bool success, ) = delegateTarget.delegatecall(data);
        require(success, "Delegatecall failed");
    }

    function setDelegateTarget(address _delegateTarget) public {
        require(msg.sender == owner, "Only owner can set delegate target");
        delegateTarget = _delegateTarget;
    }
}
