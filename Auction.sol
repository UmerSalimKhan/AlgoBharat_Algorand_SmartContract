// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Auction{

    address payable public Auctioneer;
    uint public StaringBid = 15 ether;
    uint public stblock; //start time
    uint public etblock; //end time


    enum Auc_State {Started, Running, Ended}
    Auc_State public AuctionState;

    uint public highestPayableBid;
    uint public bidInc;

    address payable public  highestBidder;

    mapping(address => uint) public bids;

    constructor(){
        Auctioneer = payable(msg.sender);
        AuctionState = Auc_State.Running;
        stblock = block.number;
        etblock = stblock + 240;
        bidInc = 15 ether;
        
    }

  

    modifier notOwner(){
        require(msg.sender != Auctioneer, "Owner cannot Bid");
        _;
    }
    modifier Owner(){
        require(msg.sender == Auctioneer);
        _;
    }

 
    modifier started(){
        require(block.number>stblock);
        _;
    }
    modifier beforeEnding(){
        require(block.number<etblock);
        _;
    }

   
    function EndAuction() public Owner{
        AuctionState = Auc_State.Ended;
    }

    function min(uint a, uint b) pure private returns (uint){
            if(a<=b)
            return a;
            else
            return b; 
    }

    function Bid() payable public notOwner started beforeEnding{

        require(AuctionState == Auc_State.Running);
        require(msg.value>= 15 ether, "Owner's Starting bid is 15 ether! your bid should be greater than 15 ether");

        uint currentBid = bids[msg.sender] + msg.value;

        require(currentBid>highestPayableBid);

        bids[msg.sender] = currentBid;

        if(currentBid<bids[highestBidder]){
            highestPayableBid = min(currentBid+bidInc,bids[highestBidder]);
        }
        else{
            highestPayableBid = min(currentBid,bids[highestBidder]+bidInc);
            highestBidder = payable(msg.sender);
        }

    }

    function FinalizeAuction() public{
        require( AuctionState == Auc_State.Ended || block.number>etblock);
        require(msg.sender == Auctioneer || bids[msg.sender]>0);

        address payable person;
        uint value;

       
        
            if(msg.sender == Auctioneer){
                person = Auctioneer;
                value = highestPayableBid;
            }
            else{
                if(msg.sender == highestBidder){
                    person = highestBidder;
                    value = bids[highestBidder]-highestPayableBid;
                }
                else{
                    person = payable(msg.sender);
                    value = bids[msg.sender];
                }
            
        }
        bids[msg.sender] = 0;
        person.transfer(value);
    }
}
