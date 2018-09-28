# Introduction

This document details the setup of an ethereum development environment required to execute and troubleshoot TokenMarket ICO contracts.

It utilizes the following components

- Token Market ICO Git Hub Repo (https://github.com/TokenMarketNet/ico.git)
- Open Zeppelin Git Hub Repo (https://github.com/OpenZeppelin/zeppelin-solidity.git)
- Geth v1.8.3 (https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.8.3-329ac18e.tar.gz)
- Ethereum Wallet v0.10.0 (https://github.com/ethereum/mist/releases/download/v0.10.0/Ethereum-Wallet-linux64-0-10-0.zip)
- Docker CE (Community Edition)

Optional used for Troubleshooting
- remix.ethereum.org
- Remixd 


# Environment Setup

1. Install Docker

```

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce
sudo apt-get install docker-compose
sudo systemctl enable docker
sudo systemctl start docker
docker --version
Docker version 18.03.0-ce, build 0520e24

```

2. Obtain Token Market & (Zeppelin) Repo

```
mkdir ~/Projects
cd ~/Projects
git clone --recursive https://github.com/TokenMarketNet/ico.git

```

3.  Extract Geth

```
cd ~/Projects
tar -zxvf geth-linux-amd64-1.8.3-329ac18e.tar.gz
cd geth-linux-amd64-1.8.3-329ac18e

```

4. Now start geth with the below command. Note : rpc related parameters are included so geth allows connections from Remix and TokenMarket.

``` 
./geth --dev --datadir=/home/toor/.ethereum/private  --rpcapi "personal,web3,eth,net,db,debug" --rpc --rpcaddr "0.0.0.0" --rpccorsdomain "*" console'

```

5. Install and Configure Ethereum Wallet to connect to your local Instance.

``` 
cd ~/Projects
unzip Ethereum-Wallet-linux64-0-10-0.zip
mv linux-unpacked etherwallet0.10.0
cd etherwallet0.10.0
./ethereumwallet --rpc ~/.ethereum/private/geth.ipc
```

# Working with TokenMarket ICO platform

1. Switch over to a new terminal and start TokenMarket ICO docker instance.

```
cd ~/Projects/ico
docker-compose up &
docker exec -it tkn /bin/bash
```

2. To have Token Market ICO utilize your Local Chain once logged into the token market docker instance edit /usr/src/app/populus.json and set the endpoint_uri to your default gateway and port 8545. Note the default GW using the below command in the docker instance.

```
ip route
default via 172.21.0.1 dev eth0 
172.21.0.0/16 dev eth0  proto kernel  scope link  src 172.21.0.3 
```

3. Edit /usr/src/app/populus.json and replace the configuration for the local chain with the following for it to point to your geth instance.


```
    "local": {
      "chain": {
        "class": "populus.chain.external.ExternalChain"
      },
      "contracts": {
        "backends": {
          "JSONFile": {
            "$ref": "contracts.backends.JSONFile"
          },
          "Memory": {
            "$ref": "contracts.backends.Memory"
          },
          "ProjectContracts": {
            "$ref": "contracts.backends.ProjectContracts"
          },
          "TestContracts": {
            "$ref": "contracts.backends.TestContracts"
          }
        }
      },
      "web3": {
        "provider": {
          "class": "web3.providers.rpc.HTTPProvider",
          "settings": {
            "endpoint_uri": "http://172.21.0.1:8545",
            "request_kwargs": {
                "timeout": 180
            }
          }
        }
      }
    },


 ```  

4. Configure the parameter for the chain in the .yml you will be using to refer to your local chain.

```
local-token:
    chain: local
```

5. Unlock your wallet (Incase you have set password for the Primary DEV account). 

Switch to your geth console and enter the following command with your password to unlock your wallet for the account  you will be publishing the contract with. (in this case accounts[0])

```
web3.personal.unlockAccount(web3.eth.accounts[0], "PASSWORD");
```


6. Test publishing a contract using Token Market ICO tools. 

```
python3 ico/cmd/deploycontracts.py --deployment-file crowdsales/crowdsale-token-example.yml --deployment-name local-token --address 0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6

Web3 provider is RPC connection http://172.21.0.1:8545
Owner address is 0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6
Owner balance is 33437.49 ETH
Starting CrowdsaleToken deployment, with arguments  {'_symbol': 'MOO', '_mintable': False, '_decimals': 18, '_initialSupply': 100000000000000000000000000000, '_name': 'MooToken'}
CrowdsaleToken address is 0x1455c31b25fa6fb20aa38edf6b1a09534355321f
CrowdsaleToken constructor arguments payload is 0x00000000000000000000000000000000000000000000000000000000000000a000000000000000000000000000000000000000000000000000000000000000e00000000000000000000000000000000000000001431e0fae6d7217caa00000000000000000000000000000000000000000000000000000000000000000000012000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000084d6f6f546f6b656e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000034d4f4f0000000000000000000000000000000000000000000000000000000000
CrowdsaleToken libraries are {'SafeMathLib': '0x00d085562309d6e13ffe646c11ad5875a58aee62'}
Writing partial report crowdsales/crowdsale-token-example.partial-report.yml
Performing post-deployment contract actions
Action: # By default, our crowdsale token tranfers work only on whitelisted address.
Action: # (To prevent shadow markets during the token sale).
Action: # In post-actions we make token transferable.
Action: # Make owner to be address / contract that controls the release
Action: confirm_tx(token.transact({"from": deploy_address}).setReleaseAgent(deploy_address))
Action: # Unlock token transfers
Action: confirm_tx(token.transact({"from": deploy_address}).releaseTokenTransfer())
Performing deployment verification
Verification: # Token is now transferable
Verification: assert token.call().released()
Verification: # We deployed using coinbase account
Verification: # assert deploy_address == web3.eth.accounts[0]
Verification: # Check that the owner got all initial balance
Verification: # assert token.call().balanceOf(deploy_address) == 100000000000*10**18
Deployment cost is -33.00 ETH
All done! Enjoy your decentralized future.
```

7. Note the address of the Token Contract and add it in your Ethereum Wallet using the Watch Token Option. In order to obtain the contract ABI/JSON and interact with it you can use remix.


# Setting up remix

Remix allows you to obtain contract ABI's, troubleshoot for errors, debug transactions and test deployin parameters which will help you build the .yml files required by TokenMarket ICO python tools.

1. Install remixd

```
sudo npm install -g remixd --unsafe-perm=true --allow-root
```

2. Configure remixd contracts directory.

    NOTE : 
    - When using remix with contracts that refer to zeppelin/ a prefix of localhost/ needs to be added to the path so remix.ethereum.org does not look at the Browser cache for the files but instead browses via the localhost to this location.(Refer to Known Issue #2 below in order to know the solution to rectify this).

   - Also remixd does not support symbolic links. Hence configure remix as follows 


```
cp ~/Projects/ico/contracts ~projects/remix.tm_contracts
cp -r ~/Projects/ico/zeppelin ~/projects/remix.tm_contracts/zeppelin

```

3. Start remixd

```
remixd -s /home/username/projects/remix.tm_contracts

[WARN] Any application that runs on your computer can potentially read from and write to all files in the directory.
[WARN] Symbolinc links are not forwarded to Remix IDE

setup notifications for /home/toor/Projects/remix.tm_contracts
Shared folder : /home/toor/Projects/remix.tm_contracts
Tue Apr 10 2018 08:36:26 GMT+1000 (AEST) Remixd is listening on 127.0.0.1:65520
origin http://remix.ethereum.org
Tue Apr 10 2018 08:36:30 GMT+1000 (AEST) Connection accepted.
setup notifications for /home/toor/Projects/remix.tm_contracts

```

4. Configure remix to use your local geth instance.

 - Browse to http://remix.ethereum.org
 - In the Right Pane Click on Run Tab
 - Under Environment Select Web3
 - Specify http://localhost:8545
 - Click on Settings Tab 
 - Select Enable Personal Mode (This will allow you to enter passwords when accessing your local instance to publish contracts)


5. Configure remix to use your local remixd instance.

- Browse to http://remix.ethereum.org
- In the Top Left Corner click on the button that looks like 2 chain links
- Accept the popup shown for connecting to your local remixd instance

Directory hosted via remixd will now be available as localhost.

A really handy tutorial of remix exists here for working with remix http://remix.readthedocs.io/en/latest/#tutorial

# Known Issues and Workarounds

1. Solidity Compiler Version.

Some of the solidity contracts in open zeppelin refer to different versions of solidity compiler and since only v0.4.17 is installed as part of the TokenMarket Docker ICO tools , these need to be replaced with v0.4.17. You can also use the following command under the zeppelin/contracts directory to do so

```
cd zeppelin/contracts
find . -type f -exec sed -i 's/0.4.18/0.4.17/g' {} \;
```

2. Using Remix with Contracts that use non local directory path

When using remix with contracts that refer to zeppelin/ a prefix of localhost/ needs to be added to the path so remix.ethereum.org does not look at the Browser cache for the files but instead browses via the localhost to this location.

So For example change the below in solidity contracts where present from

```
import "zeppelin/contracts/ownership/Ownable.sol";
```

to 

```
import "localhost/zeppelin/contracts/ownership/Ownable.sol";
```

you can also use the following commands in the contracts directory

```
find . -type f -exec sed -i 's/zeppelin/localhost\/zeppelin/g' {} \;
```
