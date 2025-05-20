// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // Get funds from users
    // Withdraw funds
    // Set a minimum funding value in USD

    address public owner;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 1e18; // 50 USD
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        if (addressToAmountFunded[msg.sender] == 0) {
            funders.push(msg.sender);
        }
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function getPrice() public view returns (uint256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return uint256(price * 1e10); // 1e10 to convert to 18 decimals
    }

    function getConversionRate(uint256 ethAmount) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); // Reset the funders array

        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory fundersMemory = funders;
        for (uint256 funderIndex = 0; funderIndex < fundersMemory.length; funderIndex++) {
            address funder = fundersMemory[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0); // Reset the funders array
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    function getFunder(uint256 index) public view returns (address) {
        return funders[index];
    }

    function getAddressToAmountFunded(address _user) public view returns (uint256) {
        return addressToAmountFunded[_user];
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
