//Finish challenge function
//Allow voting only once per member per proposals
//

pragma solidity ^0.4.6;

contract Owner() {
  address owner;

  function Owner() {
      owner = msg.sender;
  }
}

contract Boardroom is Owner {

  function Boardroom{

  }

  mapping(bytes32 => BoardMember) boardMembers;
  mapping(bytes32 => Proposal) proposals;

  struct BoardMember {
       address memberAddress;   //Member's address
       bytes32 memberName;      //Member's name
       uint voteWeight;         //How much the member's vote is worth
       uint[] membersProposals; //Proposals proposed by the member, array of proposalHashes
       uint[] memberVotes;      //Array to keep track of member's votes object {proposalHash, voteTypeUpOrDown}

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
        uint score;            //What is the total score

    }

   event LogProposal(bytes32 proposalText, bytes32 proposalHash, address memberName, address memberAddress);
   event LogVote(address member, bytes32 proposalHash, bool voteType);
   event LogRejected(uint balance);
   event LogChallenge();

   modifier isOwner() {
        require(msg.sender == owner)
   }

   /* How can I determine if a user is a member?
   modifier isMember() {
        if (msg.sender == boardMember[???]) _;
   }*/

   //Creates a new member, must be executed by owner. Member must be in same room as owner to enter password without revealing.
   function addMember(bytes32 _memberName, address _memberAddress, bytes32 _memberPassword, uint _voteWeight)
        isOwner(){
          passwordHash keccak256(_memberPassword,  _memberAddress)
          boardMembers[passwordHash] = BoardMember({
                                          memberAddress: _memberAddress,
                                          memberName: _memberName,
                                          amount: msg.value,
                                          passwordHash: passwordHash,
                                          voteWeight: _voteWeight
                                      })};
   }

   //Owner can change weight of members
   function changeVoteWeight(uint newVoteWeight, address _memberAddress, bytes32 _membersPassword) //Weight change must be mutually agreed. Member must provide password to change their weight.
        isOwner(){
          passwordHash keccak256(_memberAddress,  _membersPassword);
          boardMembers[passwordHash].voteWeight = newVoteWeight;
   }

   //Submit a proposal to the board
   function propose(bytes32 _proposal, bytes32 _password, uint deadline) //User inputs text for the proposal when calling this function as well as their password, and the number of blocks until deadline
        isMember(){
          passwordHash = keccak256(_password, msg.sender)
          require(keccak256(_proposal) != proposals[keccak256(_proposal)].proposalText) //Require that this exact proposal does not already exist
          proposals[keccak256(_proposal, msg.sender)] = Proposal({
                                            memberAddress: msg.sender,
                                            memberName: Boardmember[passwordHash].memberName,
                                            deadlineBlock: block.number + deadline,
                                            proposalText: _proposal
                                            })};
          BoardMember[passwordHash].membersProposals.push(proposals[keccak256(_proposal])
   }

   //vote yes or no to a proposal
   function vote(_proposal, _password, voteTypeTrueUpFalseDown){
        passwordHash = keccak256(_password, msg.sender);
        /*If approved proposal has less points than a late contrarian vote, initiate challenge, which re-opens voting*/
        require(Proposal[keccak256(_proposal)].approved != true)
        /*Require only one vote per member per proposal*/
        if(!voteTypeTrueUpFalseDown){
            voteWeight += boardMembers[passwordHash].voteWeight * -1;
            proposals[_proposal].noVotes.push(msg.sender);
        } else() {
            voteWeight += boardMembers[passwordHash].voteWeight;
            proposals[_proposal].yesVotes.push(msg.sender);
        }
   }

   function challenge(){
     //Put a resolved proposal back on the table for another vote
     //Restrict to members who have more weight than proposal.score?
     LogChallenge()
   }

}
