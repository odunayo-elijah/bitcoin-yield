# 🟧 Bitcoin Layer-2 Yield Aggregator Protocol

## Overview

The **Bitcoin Layer-2 Yield Aggregator Protocol** is a decentralized smart contract system built to optimize yield generation across Bitcoin-native DeFi ecosystems. Leveraging Layer-2 protocols such as Lightning and Stacks, this protocol allows users to deposit capital, automatically distribute risk, and compound yield with security guarantees rooted in Bitcoin.

---

## ✨ Key Features

* **Decentralized Yield Aggregation**
  Integrates multiple Bitcoin Layer-2 protocols to provide the best available returns.

* **Risk-Distributed Allocation**
  Enforces protocol-level allocation caps to ensure diversified exposure.

* **Automated Compounding**
  Periodically calculates and reinvests accrued yield for optimized capital growth.

* **Security-First Design**
  Implements strict validation and owner-only management functions for protocol safety.

---

## 📐 Protocol Architecture

```plaintext
                 +--------------------------+
                 |   Bitcoin Mainchain     |
                 +--------------------------+
                           |
                           v
                 +--------------------------+
                 |   Bitcoin Layer-2s       |
                 |  (Lightning, Stacks, etc.)|
                 +--------------------------+
                           |
                           v
                 +--------------------------+
                 |   Yield Aggregator SC    |
                 |--------------------------|
                 | - Protocol Registry      |
                 | - User Deposits          |
                 | - Risk Allocation Logic  |
                 | - Yield Computation      |
                 +--------------------------+
                           |
            +--------------+--------------+
            |                             |
    +---------------+           +------------------+
    | Protocol A:   |           | Protocol B:      |
    | Lightning Yld |           | Stacks Rewards   |
    +---------------+           +------------------+
```

### Components

* **`supported-protocols`**: Map storing metadata for each yield protocol (name, APY, caps, active status).
* **`user-deposits`**: Tracks individual user deposits and timestamps.
* **`protocol-total-deposits`**: Aggregates total protocol usage for enforcement of max allocation.
* **Global Constants & Validation**: Enforces APY caps, naming rules, deposit limits, and allocation constraints.

---

## ⚙️ Core Functions

| Function               | Access     | Purpose                                                      |
| ---------------------- | ---------- | ------------------------------------------------------------ |
| `add-protocol`         | Owner-only | Adds a new supported Layer-2 yield protocol                  |
| `deactivate-protocol`  | Owner-only | Disables a protocol for future deposits                      |
| `deposit`              | Public     | Deposits funds into a protocol and records user state        |
| `withdraw`             | Public     | Withdraws user principal + accrued yield                     |
| `calculate-yield`      | Read-only  | Computes yield based on deposit time and APY                 |
| `initialize-protocols` | Auto/Owner | Seeds protocol with predefined strategies (e.g., Stacks, LN) |

---

## 🛡️ Error Handling

| Error Code                        | Meaning                       |
| --------------------------------- | ----------------------------- |
| `ERR-UNAUTHORIZED (u1)`           | Action not permitted          |
| `ERR-INSUFFICIENT-FUNDS (u2)`     | Not enough balance            |
| `ERR-INVALID-PROTOCOL (u3)`       | Protocol not recognized       |
| `ERR-WITHDRAWAL-FAILED (u4)`      | Withdrawal could not complete |
| `ERR-DEPOSIT-FAILED (u5)`         | Deposit operation failed      |
| `ERR-PROTOCOL-LIMIT-REACHED (u6)` | Max allocation hit            |
| `ERR-INVALID-INPUT (u7)`          | Invalid input parameters      |

---

## 🚀 Getting Started

1. **Deploy the Contract**
   The protocol will auto-initialize with predefined protocols.

2. **Add More Protocols (Optional)**
   Use `add-protocol` to whitelist new Bitcoin L2 yield providers.

3. **Users Deposit**
   End users can call `deposit` with desired `protocol-id` and amount.

4. **Track or Withdraw**
   Use `calculate-yield` for viewing accrued earnings. Call `withdraw` to exit.

---

## 📌 Example Initialization

```clojure
(try! (add-protocol u1 "Bitcoin Lightning Yield" u500 u20))
(try! (add-protocol u2 "Stacks Stacking Rewards" u750 u30))
```

---

## 🧠 Future Improvements

* **Auto-Yield Compounding Scheduler**
* **DAO Governance for Protocol Onboarding**
* **Cross-chain Bitcoin yield strategies (e.g., Rootstock, Liquid)**
