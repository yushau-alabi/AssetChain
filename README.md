# AssetChain: Tokenized Asset Management Platform

## Overview

AssetChain is a comprehensive smart contract platform built on Stacks (Bitcoin L2) that enables the tokenization and fractional ownership of real-world assets through Semi-Fungible Tokens (SFTs). The platform combines asset management, governance, and dividend distribution capabilities with robust compliance features.

## Key Features

### Asset Tokenization

- Register high-value real-world assets and tokenize them into 100,000 SFT units
- Support for asset metadata through URIs
- Value boundaries from 1,000 to 1 trillion units

### Ownership Management

- Fully on-chain ownership tracking
- Transparent token balance system
- Support for token transfers (to be implemented)

### Dividend Distribution

- Proportional dividend claiming based on token ownership
- Automatic calculation of claimable amounts
- Accounting system to prevent double-claims

### Governance System

- Proposal creation with configurable parameters
- Democratic voting mechanism (one token, one vote)
- Minimum ownership threshold for proposal creation (10% of tokens)
- Customizable voting durations and quorum requirements

### Regulatory Compliance

- Built-in KYC system with multiple clearance levels
- Time-bound KYC approvals
- Configurable compliance requirements per asset

### Oracle Integration

- Price feed system for asset valuation
- Support for trusted external data sources
- Timestamp validation to ensure data freshness

## Technical Details

### Data Structures

The contract utilizes the following data maps:

1. **assets**: Stores core asset information including:

   - Owner principal
   - Metadata URI
   - Asset value
   - Lock status
   - Creation timestamp
   - Price update timestamp
   - Total dividends distributed

2. **token-balances**: Tracks SFT ownership across users and assets

3. **kyc-status**: Maintains compliance information for addresses:

   - Approval status
   - KYC level (0-5)
   - Expiry block height

4. **proposals**: Stores governance proposal data:

   - Title
   - Associated asset ID
   - Voting period (start/end heights)
   - Execution status
   - Vote tallies
   - Minimum vote threshold

5. **votes**: Records individual voting activity

6. **dividend-claims**: Tracks dividend distribution and claims

7. **price-feeds**: Stores oracle price data with source attribution

### Functions

#### Asset Management

- `register-asset`: Creates a new asset with metadata and initial valuation

#### Dividend System

- `claim-dividends`: Allows token holders to claim their share of distributed dividends

#### Governance

- `create-proposal`: Initiates a new governance proposal
- `vote`: Casts votes on active proposals

#### Read-Only Functions

- `get-asset-info`: Retrieves asset details
- `get-balance`: Checks token balance for a specific owner and asset
- `get-proposal`: Retrieves proposal details
- `get-vote`: Checks voting history
- `get-price-feed`: Gets latest price data
- `get-last-claim`: Retrieves dividend claim history

### Input Validation

The contract implements strict validation for all parameters:

- Asset values must be within defined boundaries
- Durations must be reasonable (1 hour to 1 day in blocks)
- KYC levels must be valid (0-5)
- Expiry periods must be valid (up to 1 year)
- Metadata URIs must be valid and non-empty
- Vote counts must be positive and not exceed total supply

## Use Cases

1. **Real Estate Tokenization**

   - Fractionalize high-value properties
   - Distribute rental income as dividends
   - Governance for property management decisions

2. **Art & Collectibles**

   - Democratize ownership of valuable art pieces
   - Enable fractional trading of collectibles
   - Exhibition revenue as dividends

3. **Business Equity**

   - Tokenize private company shares
   - Distribute profits as dividends
   - Governance for key business decisions

4. **Infrastructure Projects**
   - Fund and tokenize infrastructure development
   - Distribute revenue as dividends
   - Community governance for project direction

## Development Roadmap

### Current Implementation

- Core asset registration
- Dividend claiming mechanism
- Basic governance system
- Compliance framework

### Planned Enhancements

- Token transfer functionality
- Secondary market support
- Enhanced oracle integration
- Improved governance execution
- Audit trail and transparency features

## Security Considerations

The contract includes several security measures:

- Strict owner-only functions for critical operations
- Comprehensive input validation
- Error codes for clear failure states
- Safe math practices to prevent overflows
- Compliance checks before sensitive operations

## Compliance Framework

AssetChain is designed with regulatory compliance in mind:

- KYC requirements can be tailored to specific jurisdictions
- Expiry system ensures KYC information remains current
- Adaptable to evolving regulatory landscapes

## Technical Requirements

- Clarity language compatibility
- Stacks blockchain deployment
- Clarinet for testing and development
