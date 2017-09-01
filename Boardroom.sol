/* Boardroom Contract for Organizational Governance
//This script is meant to facilitate company decision making.
  +Board members can submit proposals with a deadline, and all other members can vote to accept or reject.
  +If the proposal's score is positive when the deadline hits, it is archived as a company policy.
  +If the proposal's score is negative, it is rejected and archived.
  +Board members can challenge a decision after the deadline is reached to force a revote.
  +Each board member will have a voting weight which determines how many points they are able to commit to the proposal.

To Do:
//Finish challenge function
//Only allow challenge when remaining vote weight outweighs difference
//Allow voting until weight vote is expired for that proposal*/

pragma solidity ^0.4.6;

contract Owner {
  address owner;

  function Owner() {
      owner = msg.sender;
  }
}

contract Boardroom is Owner {
    address[] boardMembersArray; //Keep all boardmembers addresses in an array, in order of when they were added.

    function Boardroom(){
        boardMembersArray.push(msg.sender);

    }
      //Keep track of your BoardMembers in a Struct. Key is the hash of sender address & password.
    mapping(bytes32 => BoardMember) boardMembers;
    
    //Keep track of all the proposals. Key is the text of the proposal & the sender address.
    mapping(bytes32 => Proposal) proposals;
    

    struct BoardMember {
       address memberAddress;       //Member's address
       bytes32 memberName;          //Member's name
       uint voteWeight;             //How much the member's vote is worth
       uint[] membersProposals;     //Proposals proposed by the member, array of proposalHashes
       uint[] memberVotes;          //Array to keep track of member's votes object {proposalHash, voteTypeUpOrDown}
       //uint256 voteHistory;         //Map to keep track of all proposals voted on by key proposalHash. True = voted.
    }
    
    struct Proposal {
        bytes32 proposalText;   //Text of proposal
        address memberAddress;  // Member who proposed address
        address memberName;     // Member who proposed name
        bytes32 proposalHash;   //Proposal text hashed
        bool approved;          //Has this test been approved?
        uint deadlineBlock;     //If no votes by deadline, then rejected. If votes are not cast by everyone, total for/against score will cause accept/reject.
        bool challenged;        //Reopened for vote by someone with more weight than final for/against score
        address[] yesVotes;     //Who voted up
        address[] noVotes;      //Who voted down
        uint score;             //What is the total score
    }
    
    
    event LogProposal(bytes32 proposalText, bytes32 proposalHash, address memberName, address memberAddress);
    event LogVote(address member, bytes32 proposalHash, bool voteType);
    event LogRejected(uint balance);
    event LogChallenge();
    
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
    /* Trying to solve error on
    function injectHash (memberPassword, memberAddress)
                returns (uint256) {
                return keccak256(memberPassword,  memberAddress);
                }*/
    
    //Creates a new member, must be executed by owner. 
    //Member must be in same room as owner to enter password without revealing.
    function addMember(
                bytes32 memberName, 
                address memberAddress, 
                uint256 memberPassword, 
                uint    voteWeight)
            isOwner(){
                bytes32 passwordHash;
                //mapping(bytes32 => VoteHistory) voteHistory;
                passwordHash = keccak256 (memberPassword, memberAddress);
                boardMembers[passwordHash] = BoardMember({
                                              memberAddress: memberAddress,
                                              memberName: memberName,
                                              amount: msg.value,
                                              passwordHash: passwordHash,
                                              voteWeight: voteWeight
                                              //voteHistory: 
                                             });
                //Add this member to the board members array.                          
                boardMembersArray.push(boardMembers[passwordHash].memberAddress);
        }

    //Owner can change weight of members, but member must consent.
    //Member must provide password in person to change their weight.
   function changeVoteWeight(uint newVoteWeight, address _memberAddress, bytes32 _membersPassword)
        isOwner(){
        bytes32 passwordHash;
          passwordHash = keccak256(_memberAddress,  _membersPassword);
          boardMembers[passwordHash].voteWeight = newVoteWeight;
   }


    //Submit a proposal to the board
    function propose(bytes32 proposal, bytes32 _password, uint deadline) //User inputs text for the proposal when calling this function as well as their password, and the number of blocks until deadline
        {
         bytes32 passwordHash;
        passwordHash = keccak256(_password, msg.sender);
        //Require that this exact proposal does not already exist
        require(keccak256(proposal) != proposals[keccak256(proposal)].proposalText);
        proposals[keccak256(proposal, msg.sender)] = Proposal({
                                                        memberAddress: msg.sender,
                                                        memberName: boardMembers[passwordHash].memberName,
                                                        deadlineBlock: block.number + deadline,
                                                        proposalText: proposal,
                                                        proposalHash: passwordHash,
                                                        approved: false,
                                                        challenged: false,
                                                        yesVotes: boardMembers[passwordHash].voteWeight,
                                                        noVotes: 0
                                                        }
        //Track proposal keys in an array.
        //BoardMember[passwordHash].membersProposals.push(proposals[keccak256(proposal)]);

        });
    }


    //vote yes or no to a proposal
    function vote(bytes32 proposal, bytes32 password, bool voteTypeTrueUpFalseDown){
        uint256 passwordHash;
        uint voteWeight;
        passwordHash = keccak256(password, msg.sender);
        /*If approved proposal has less points than a late contrarian vote, initiate challenge, which re-opens voting*/
        require(Proposal[keccak256(proposal)].approved != true);
        /*Require only one vote per member per proposal*/
        if(!voteTypeTrueUpFalseDown){
            voteWeight += boardMembers[passwordHash].voteWeight * -1;
            proposals[proposal].noVotes.push(msg.sender);
        } else {
            voteWeight += boardMembers[passwordHash].voteWeight;
            proposals[proposal].yesVotes.push(msg.sender);
        }
    }

    //Put a resolved proposal back on the table for another vote
    function challenge(bytes32 memberPassword){
     //Restrict to members who have more weight than proposal.score?
     
     require(msg.sender);
     LogChallenge();
    }

}
