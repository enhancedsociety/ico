# Introduction

This document details the configuration and execution of bounty / bonus reward mechanism provided by the Token Market ICO tools.

# Setup

Perform the following activities on the Token Market ICO docker instance.

1. Install Dependencies for Token Market ICO Bounty/Bonus tools

```
pip3 install splinter
apt-get install curl libnss3
```

2. Install Chrome Driver 

```
CHROME_DRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`
wget http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
mv chromedriver /usr/local/bin
```

3. Install Chrome 

```
sudo curl -sS -o - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add
sudo echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
sudo apt-get -y update
sudo apt-get -y install google-chrome-stable
```

4. Token Market does not detect the parameter local as an acceptable chain value so configure the mainnet chain in populus.json to refer to your local geth instance.

```
  "chains": {
    "mainnet": {
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

5. Create a CSV file for example distribute.csv consisting of the list of Bounty/Bonus recieving addresses. Example below.

```
address,amount
0x77cA2e7E9AA9f0494560Ed0EAcBE1B1B90F9fcb6,10
0xCA5eA7C6124D5Ea18C45f4664edd88EE0838D405,10
```

6. Unlock the wallet which owns the Token Contract on the geth console and use it to publish the Issuer Contract too. 

```
web3.personal.unlockAccount(web3.eth.accounts[0], "PASSWORD",36000);
```

7. Comment out the below in ico/cmd/distributetokens.py so it does not try to browse etherscan for verification.


```
 #verify_contract(
            #    project=project,
            #    libraries={},  # TODO: Figure out how to pass around
            #    chain_name=chain_name,
            #    address=issuer.address,
            #    contract_name="Issuer",
            #    contract_filename=fname,
            #    constructor_args=const_args,
            #    # libraries=runtime_data["contracts"][name]["libraries"],
            #    browser_driver=browser_driver,
            #    compiler=solc_version)
            # link = get_etherscan_link(chain_name, issuer.address)

            # print("Issuer verified contract is", link)
```

# Execution / Testing 

1. Execute the Bounty/Bonus Tools for the first time. This will create an Issuer Contract.


```
python3.5 ico/cmd/distributetokens.py --chain="mainnet" --gas-price="50" --address="0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6" --master-address="0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6" --token 0xbf0De463A0C543ed8e3941b04E02D48954f85CD9 --csv-file crowdsales/distribute.csv

Web3 provider is RPC connection http://172.21.0.1:8545
Deployer account address is 0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6
Deployer account balance is 33073.48 ETH
Token is 0xbf0de463a0c543ed8e3941b04e02d48954f85cd9
Total supply is 100000000000000000000000000000
Upgrade master is 0x41f32f70119e9deead9681d371207cae0b2c16f6
Deployer account token balance is 100000000000000000000000000000
Token decimal places is 18
Using gas price of 50.0 GWei
Deploying new issuer contract ['0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6', '0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6', '0xbf0de463a0c543ed8e3941b04e02d48954f85cd9'] transaction parameters {'gasPrice': 50000000000, 'from': '0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6'}
Deployment transaction is 0x2669b66caf8c49199efcb222ae21febc7056a669db298d2193c46f73ae18a8f0
Waiting contract to be deployed
Contract constructor arguments are 00000000000000000000000041f32f70119e9deead9681d371207cae0b2c16f600000000000000000000000041f32f70119e9deead9681d371207cae0b2c16f6000000000000000000000000bf0de463a0c543ed8e3941b04e02d48954f85cd9
Issuer contract is 0xea96aba2431a3a6831c6f8c07bebd39878745afd
Currently issued 0
Issuer allowance 0
Please use Token.approve() to give some allowance for the issuer contract by master address.

```

2. Use the Token.approve function via Ethereumwallet or Remix to set the Issuer Contract Address as a spender and the amount of Tokens it can give out. Ensure the address approving is same as the specified master-address and also has enough tokens in it to distribute 

3. Rerun the Contract again to Distribute bounties to the addresses specified in the distribute.csv file. Ensure you specify the --issuer-address in this run.

```
python3.5 ico/cmd/distributetokens.py --chain="mainnet" --gas-price="50" --address="0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6" --master-address="0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6" --token 0xbf0De463A0C543ed8e3941b04E02D48954f85CD9 --issuer-address="0xea96aba2431a3a6831c6f8c07bebd39878745afd" --csv-file crowdsales/distribute.csv

Web3 provider is RPC connection http://172.21.0.1:8545
Deployer account address is 0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6
Deployer account balance is 33160.48 ETH
Token is 0xbf0de463a0c543ed8e3941b04e02d48954f85cd9
Total supply is 100000000000000000000000000000
Upgrade master is 0x41f32f70119e9deead9681d371207cae0b2c16f6
Deployer account token balance is 100000000000000000000000000000
Token decimal places is 18
Using gas price of 50.0 GWei
Reusing existing issuer contract
Issuer contract is 0xea96aba2431a3a6831c6f8c07bebd39878745afd
Currently issued 0
Issuer allowance 1000000000000000000000000
Reading data crowdsales/distribute.csv
Total rows 2
Row 0 giving 10000000000000000000 to 0x77cA2e7E9AA9f0494560Ed0EAcBE1B1B90F9fcb6 issuer 0xea96aba2431a3a6831c6f8c07bebd39878745afd time passed 0.0026755332946777344 ETH passed 0.00 gas price 50.0
Row 1 giving 10000000000000000000 to 0xCA5eA7C6124D5Ea18C45f4664edd88EE0838D405 issuer 0xea96aba2431a3a6831c6f8c07bebd39878745afd time passed 0.010854959487915039 ETH passed 0.00 gas price 50.0
Deployment cost is -3.00 ETH
All done! Enjoy your decentralized future.
```

4. Rerun the Contract again to ensure that an accidental rerun will not redistribute bounties.

```
python3.5 ico/cmd/distributetokens.py --chain="mainnet" --gas-price="50" --address="0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6" --master-address="0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6" --token 0xbf0De463A0C543ed8e3941b04E02D48954f85CD9 --issuer-address="0xea96aba2431a3a6831c6f8c07bebd39878745afd" --csv-file crowdsales/distribute.csv

Web3 provider is RPC connection http://172.21.0.1:8545
Deployer account address is 0x41f32F70119E9dEEaD9681d371207cAE0b2C16F6
Deployer account balance is 33199.48 ETH
Token is 0xbf0de463a0c543ed8e3941b04e02d48954f85cd9
Total supply is 100000000000000000000000000000
Upgrade master is 0x41f32f70119e9deead9681d371207cae0b2c16f6
Deployer account token balance is 99999999980000000000000000000
Token decimal places is 18
Using gas price of 50.0 GWei
Reusing existing issuer contract
Issuer contract is 0xea96aba2431a3a6831c6f8c07bebd39878745afd
Currently issued 20000000000000000000
Issuer allowance 999980000000000000000000
Reading data crowdsales/distribute.csv
Total rows 2
Row 0 giving 10000000000000000000 to 0x77cA2e7E9AA9f0494560Ed0EAcBE1B1B90F9fcb6 issuer 0xea96aba2431a3a6831c6f8c07bebd39878745afd time passed 0.0030736923217773438 ETH passed 0.00 gas price 50.0
Already issued, skipping
Row 1 giving 10000000000000000000 to 0xCA5eA7C6124D5Ea18C45f4664edd88EE0838D405 issuer 0xea96aba2431a3a6831c6f8c07bebd39878745afd time passed 0.008187055587768555 ETH passed 0.00 gas price 50.0
Already issued, skipping
Deployment cost is 0.00 ETH
All done! Enjoy your decentralized future.
```


