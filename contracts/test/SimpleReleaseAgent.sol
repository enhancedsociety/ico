pragma solidity ^0.4.8;

import "../ReleasableToken.sol";


/**
 * To test transfer lock up release.
 */
contract SimpleReleaseAgent {

  ReleasableToken token;

  function SimpleReleaseAgent(ReleasableToken _token)  public {
    token = _token;
  }

  function release()  public {
    token.releaseTokenTransfer();
  }
}
