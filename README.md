# Staking Contracts for Timelockers
GEN &amp; Fever Staking Contracts

![Staking](https://user-images.githubusercontent.com/34641838/230521331-e7ed7edc-9b37-44a0-b3f4-4a9200494730.png)

This repository provides a GEN and Fever staking mechanism; whereby, the user receives GEN as a reward for staking GEN or stGEN in the contract.

- Staking guide can be found in [here](https://whitepaper.gen.foundation/product/timelockers/staking).

## Installation

### Setup

- **Node.js**

      sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
      nvm install 12.18.3
      node -v

- **Truffle**

      sudo npm install -g truffle@5.1.39 --unsafe-perm=true

- **Ganache** installation guide can be found in [here](https://www.trufflesuite.com/ganache).

- **MetaMask** installation guide can be found in [here](https://metamask.io/).

### Commands

- Install necessarily Node.js packages

      npm install

- Deploy smart contracts to the Ethereum blockchain

      truffle migrate --reset
      
- Deploy and run the front-end application

      npm start run

The DApp with the screenshots can be found on [Timelockers](https://www.timelockers.club/).

## Author
Generation Foundation

## License
This system is available under the MIT license. See the LICENSE file for more info.