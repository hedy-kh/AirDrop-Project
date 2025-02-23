# **Merkle Airdrop**

This project is a Solidity-based smart contract built with the Foundry framework. It enables the secure and efficient distribution of tokens to multiple recipients in a single transaction. The contract utilizes cryptographic proofs to verify recipient eligibility, ensuring that only authorized participants can claim tokens. This approach is inspired by established airdrop mechanisms used in blockchain ecosystems.

---

## **Getting Started**

### **Requirements**

Ensure you have the following installed:

- **Git**: [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)  
  - Verify installation:

    ```bash
    git --version
    ```  

- **Foundry**: [Install Foundry](https://getfoundry.sh/)  
  - Verify installation:

    ```bash
    forge --version
    ```  

This guide assumes you're working with standard Foundry, not Foundry-ZKSync.

---

## **Quickstart**

Clone the repository and install dependencies:

```bash
git clone https://github.com/hedy-kh/AirDrop-Project.git
make  # or use "forge install && forge build" if you don't have make installed
```

---

# **Usage**

## **Pre-deploy: Generate Merkle Proofs**

To distribute tokens, we generate Merkle proofs for an array of recipient addresses. If you want to use the default addresses and proofs in this repository, skip to [Deployment](#deploy).

### **Generating New Merkle Proofs**

1. Update the list of addresses in `GenerateInput.s.sol`.
2. Run the following command to generate the Merkle root and proofs:

Using `make`:

```bash
make merkle
```  

Or manually:

```bash
forge script script/Generateinput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle
```  

3. Retrieve the Merkle root from `script/target/output.json` and update:
   - The `ROOT` variable in the `Makefile` (for zkSync deployments).
   - The `s_merkleRoot` in `DeployMerkleAirdrop.s.sol` (for Ethereum/Anvil deployments).

---

## **Deployment**

### **Deploy to Anvil (Local Network)**

```bash
# Ensure you're using standard Foundry
foundryup
# Start a local Anvil node
make anvil
# Deploy the contracts
make deploy
```

---

## **Interacting with the Contract (Local Anvil Network)**

### **Setup Anvil & Deploy Contracts**

```bash
foundryup
make anvil
make deploy
```

After deployment, copy the **Airdrop Contract Address** and **Token Address**, and paste them into the `AIRDROP_ADDRESS` and `TOKEN_ADDRESS` variables in the `Makefile`.

### **Signing the Airdrop Claim**

```bash
make sign
```

Retrieve the generated signature and update `Interact.s.sol`.  
If you've changed the recipient addresses in the Merkle tree, also update the proof data from `output.json`.

### **Claiming the Airdrop**

```bash
make claim
```

### **Checking Claim Amount**

Verify the claim by checking the balance:

```bash
make balance
```

The default Anvil address (`0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`) will receive the airdropped tokens.

---

## **Testing**

Run tests using Foundry:

```bash
foundryup
forge test
```

For zkSync compatibility:

```bash
make zktest  # Runs: foundryup-zksync && forge test --zksync && foundryup
```

### **Test Coverage**

```bash
forge coverage
```

---

## **Gas Estimation**

Estimate gas costs with:

```bash
forge snapshot
```

Results will be stored in `.gas-snapshot`.

---

## **Code Formatting**

Ensure consistent formatting:

```bash
forge fmt
```

---

## **Conclusion**

This project provides a secure and efficient way to distribute tokens using cryptographic proofs. By leveraging Foundry, ensure a robust testing and deployment process.


