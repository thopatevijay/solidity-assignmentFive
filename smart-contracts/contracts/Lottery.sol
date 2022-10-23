// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LotteryToken} from "./Token.sol";

contract Lottery is Ownable {
    LotteryToken public paymentToken;
    uint256 public closingTime;
    bool public betsOpen;
    uint256 public betPrice;
    uint256 public betFee;

    uint256 public prizePool;
    uint256 public ownerPool;

    mapping(address => uint256) public prize;

    address[] _slots;

    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 _betPrice,
        uint256 _betFee
    ) {
        paymentToken = new LotteryToken(tokenName, tokenSymbol);
        betPrice = _betPrice;
        betFee = _betFee;
    }

    modifier whenBetsClosed() {
        require(!betsOpen, "Lottery: Bets are not closed");
        _;
    }

    modifier whenBetsOpen() {
        require(betsOpen && block.timestamp < closingTime,
        "Lottery : bets are closed"
        );
        _;
    }

    function openBets(uint256 _closingTime) public onlyOwner whenBetsClosed {
        require(
            _closingTime > block.timestamp,
            "Closing time must be in the future"
        );
        closingTime = _closingTime;
        betsOpen = true;
    }

    function purchaseTokens() public payable{
        paymentToken.mint(msg.sender, msg.value);
    }

    function bet() public whenBetsOpen{
        ownerPool += betFee;
        prizePool += betPrice;
        _slots.push(msg.sender);
        paymentToken.transferFrom(msg.sender, address(this), betPrice + betFee);
    }

    function betMany(uint256 times) public{
        require(times > 0);
        while(times > 0) {
            bet();
            times--;
        }
    }

    function closeLottery() public {
        require(block.timestamp >= closingTime, "Lottery : Too soon to close");
        require(betsOpen, "Lottery : Already closed");
        if(_slots.length > 0) {
            uint256 winnerIndex = getRandomNumber() % _slots.length;
            address winner = _slots[winnerIndex];
            prize[winner] += prizePool;
            prizePool = 0;
            delete (_slots);
        }
        betsOpen = false;
    }

    function getRandomNumber() public view returns (uint256 randomNumber) {
        randomNumber =  block.difficulty;
    }

    function prizeWithdraw(uint256 amount) public {
        require(amount <= prize[msg.sender], "Lottery : Not enough price");
        prize[msg.sender] -= amount;
        paymentToken.transfer(msg.sender, amount);
    }

    function ownerWithdraw(uint256 amount) public onlyOwner {
        require(amount <= ownerPool, "Lottery : Not enough fees collected");
        ownerPool -= amount;
        paymentToken.transfer(msg.sender, amount);
    }

    function returnTokens(uint256 amount) public {
        paymentToken.burnFrom(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }
}
