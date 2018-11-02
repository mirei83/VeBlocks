### create Database for Vechain Blockexplorer
CREATE DATABASE VeBlocks;
USE VeBlocks;



### create Tables for TestnetBlocks
CREATE TABLE testnet_blocks (
    block_number int,
    block_id VARCHAR(100),
    block_size int,
    block_time TIMESTAMP not null,
    gasLimit int,
    gasUsed int,
    totalScore int,
    primary key (block_number),
    unique IDX_blockid (block_id)
) ENGINE=InnoDB;

CREATE TABLE testnet_transactions (
    tx_number int auto_increment not null,
    tx_id VARCHAR(100),
    block_id VARCHAR(100),
    origin VARCHAR(66),
    gascoef int,
    gas int,
    gaspayer VARCHAR(66),
    gaspayed int,
    reward int,
    reverted boolean,
    primary key (tx_number),
    UNIQUE KEY IDX_txid (tx_id),
    FOREIGN KEY (block_id)
    REFERENCES testnet_blocks(block_id)
) ENGINE=InnoDB;

CREATE TABLE testnet_clauses (
    clause_number int auto_increment not null,
    tx_id VARCHAR(100),
    to_Address VARCHAR(66),
    amount bigint,
    data VARCHAR(10000),
    primary key (clause_number),
    FOREIGN KEY (tx_id)
    REFERENCES testnet_transactions(tx_id)
) ENGINE=InnoDB;


### create Tables for MainnetBlocks
CREATE TABLE mainnet_blocks (
    block_number int,
    block_id VARCHAR(100),
    block_size int,
    block_time TIMESTAMP not null,
    gasLimit int,
    gasUsed int,
    totalScore int,
    primary key (block_number),
    unique IDX_blockid (block_id)
) ENGINE=InnoDB;

CREATE TABLE mainnet_transactions (
    tx_number int auto_increment not null,
    tx_id VARCHAR(100),
    block_id VARCHAR(100),
    origin VARCHAR(66),
    gascoef int,
    gas int,
    gaspayer VARCHAR(66),
    gaspayed int,
    reward int,
    reverted boolean,
    primary key (tx_number),
    UNIQUE KEY IDX_txid (tx_id),
    FOREIGN KEY (block_id)
    REFERENCES mainnet_blocks(block_id)
) ENGINE=InnoDB;



CREATE TABLE mainnet_clauses (
    clause_number int auto_increment not null,
    tx_id VARCHAR(100),
    to_Address VARCHAR(66),
    amount bigint,
    data VARCHAR(10000),
    primary key (clause_number),
    FOREIGN KEY (tx_id)
    REFERENCES mainnet_transactions(tx_id)
) ENGINE=InnoDB;


### Create User Vechain and grand access from localhost and local Network
CREATE USER 'vechain'@'localhost' IDENTIFIED BY 'VeChainToDaMoon';
GRANT INSERT, SELECT, UPDATE ON VeBlocks.* TO 'vechain'@'localhost';