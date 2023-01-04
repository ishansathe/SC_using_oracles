//SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.0/contracts/math/SafeMath.sol";
contract FundMe
{
    mapping (address => uint256) public addressFundedAmount;
    address owner;
    
    constructor()
    {
        owner = msg.sender;
        //the sender of message will be the owner of this contract (i.e us, in this case)
    }

    function fund() public payable
    {
        uint256 minUSD = 30;
        
        //Making sure the withdrawer is the initiator of this contract and not some greedy boii.

        require(convert(msg.value) >= minUSD, "You need to spend more eth");
        //tbh 1 eth is way more than 30$, so I just used 30 finney which is then around 36$ (value will vary based on date and
        //time of conversion)
        addressFundedAmount[msg.sender] += msg.value;
    }

    modifier admin
    {
        require (msg.sender == owner);
        _;
    }

    function withdraw() admin public payable
    {   
        address payable a = payable(msg.sender);
        a.transfer(address(this).balance);
    }


    function getVersion() public view returns (uint256)
    {
        AggregatorV3Interface rate = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        //The above contract address contains the code that stores data feed of USD/ETH conversion rate.
        return rate.version();
    }

    function getPrice() public view returns (uint256)
    //This function will give you the current price of 1 eth
    {
        AggregatorV3Interface rate = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        //The above contract address contains the code that stores data feed of USD/ETH conversion rate.
        (
            ,
            int256 answer,
            ,
            ,
            //these contain 4 values, but we want only 1 so we set the rest to return blank values (else will give us warnings)
            
        ) = rate.latestRoundData();

        return uint256(answer / 1000000);
        // we used this so that we can get exact price of 1 eth (ignoring the decimal values) in USD
    }
    


    function convert(uint256 fundedAmount) public view returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 inUSD = (ethPrice * fundedAmount)/ 100000000000000000000;
        //I considered adding 2 more 0s above since the conversion value was coming to be incorrect. (saying it was 2 decimals
        //ahead of what it actually should be)
        //this value will have to change depending on whether we use finney or other denomination.
        return inUSD;
    }
    
}
