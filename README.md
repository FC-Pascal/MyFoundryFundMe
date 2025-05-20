FundMe Smart Contract (Foundry)
This project is a Solidity smart contract built and tested using the Foundry framework. It is based on the Cyfrin Foundry Full Course, and includes core functionality for decentralized funding and secure ETH withdrawals.

📁 Project Structure

fundme-foundry/
│
├── lib/                            # Installed dependencies (e.g., chainlink contracts)
│
├── script/                         # Deployment scripts
│   └── DeployFundMe.s.sol
│
├── src/                            # Main contract source code
│   └── FundMe.sol
│
├── test/                           # Test cases written in Solidity
│   └── TestFundMe.t.sol
│
├── foundry.toml                    # Foundry project configuration
├── .gitignore
└── README.md                       # Project overview and instructions

📜 Features
Accepts ETH funding only from the contract owner (can be modified for public use).

Enforces a minimum funding amount in USD (via Chainlink price feeds).

Keeps track of funders and their contributions.

Allows only the owner to withdraw funds.

Includes a gas-optimized cheaperWithdraw function.

🧪 Tests
Includes tests for:

Revert on insufficient funding

Address-to-amount mapping updates

Adding funders

Owner-only access to withdrawals

Withdraw scenarios with single/multiple funders

Full balance withdrawal

🔧 Tech Stack
Solidity ^0.8.19

Foundry (Forge, Anvil)

Chainlink Price Feeds

MockV3Aggregator for unit testing

▶️ Running the Project
# Clone the repo
git clone https://github.com/FC-Pascal/MyFoundryFundMe.git
cd fundme-foundry

# Install dependencies
forge install

# Run the tests
forge test -vv

👤 Author
Built with ❤️ by @I_am_Anon_x on X (formerly Twitter)

