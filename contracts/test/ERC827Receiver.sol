pragma solidity ^0.4.8;

contract ERC827Receiver {
  function ERC827Receiver()  public {
    
  }

  function receive() public returns(bool){
    return true;
  }
}
