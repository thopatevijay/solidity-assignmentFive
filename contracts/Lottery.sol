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
}
