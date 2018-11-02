## -----------------------------------------------------------------------------
## VeBlocks - a nerdy, MySQL-based Blockexplorer for VeChain
##
## This code was written because I was curious about some information about the
## Blockchain that the normal BlockExplorer could not give me.
## 
## Enjoy. Make it better. Share.
##
## (c) by MiRei - contribute some VET/VTHOR: 0x811a2737cC1D879b2398f1072f262D7499c61964
## ----------------------------------------------------------------------------
##
## Just some example SQL Queries you can start with.


### Show blocks with most clauses
select mainnet_blocks.block_number as BlockNumber, mainnet_blocks.block_id, count(distinct mainnet_clauses.tx_id) as transactions, count(mainnet_transactions.block_id) as Clauses from mainnet_blocks 
left join mainnet_transactions on mainnet_transactions.block_id = mainnet_blocks.block_id 
left join mainnet_clauses on mainnet_clauses.tx_id = mainnet_transactions.tx_id group by 1 order by clauses desc limit 10;

### Show blocks with most transactions
select mainnet_blocks.block_number as BlockNumber, count(distinct mainnet_clauses.tx_id) as Transactions, count(mainnet_transactions.block_id) as Clauses from mainnet_blocks 
left join mainnet_transactions on mainnet_transactions.block_id = mainnet_blocks.block_id 
left join mainnet_clauses on mainnet_clauses.tx_id = mainnet_transactions.tx_id group by 1 order by transactions desc limit 10;

### Show transactions with most clauses
select mainnet_blocks.block_number as Blocknumber, mainnet_transactions.tx_id as TxID, count(*) as Clauses from mainnet_clauses 
inner join mainnet_transactions on mainnet_clauses.tx_id = mainnet_transactions.tx_id inner join mainnet_blocks on mainnet_transactions.block_id = mainnet_blocks.block_id 
group by mainnet_clauses.tx_id order by Clauses desc limit 10;

### Show blocks with most used gas
select block_number as BlockNumber, gasUsed as Gas from mainnet_blocks order by Gas desc limit 10;

### Show biggest blocks (in byte)
select block_number as BlockNumber, block_size as Size from mainnet_blocks order by Size  desc limit 10;

### Show days with most transactions
select DATE(mainnet_blocks.block_Time) as Date, count(distinct mainnet_transactions.tx_id) as Transactions from mainnet_blocks  
left join mainnet_transactions on mainnet_transactions.block_id = mainnet_blocks.block_id group by 1 order by 2 desc limit 10;

### Show transactions of last 10 days
select DATE(mainnet_blocks.block_Time) as Date, count(distinct mainnet_transactions.tx_id) as Transactions from mainnet_blocks  
left join mainnet_transactions on mainnet_transactions.block_id = mainnet_blocks.block_id group by 1 order by 1 desc limit 10;

### Show days with most clauses
select DATE(mainnet_blocks.block_Time) as Date, count(mainnet_clauses.tx_id) as Clauses from mainnet_blocks
left join mainnet_transactions on mainnet_transactions.block_id = mainnet_blocks.block_id
left join mainnet_clauses on mainnet_clauses.tx_id = mainnet_transactions.tx_id group by 1 order by 2 desc limit 10;

### Show clauses of last 10 days
select DATE(mainnet_blocks.block_Time) as Date, count(mainnet_clauses.tx_id) as Clauses from mainnet_blocks
left join mainnet_transactions on mainnet_transactions.block_id = mainnet_blocks.block_id
left join mainnet_clauses on mainnet_clauses.tx_id = mainnet_transactions.tx_id group by 1 order by 1 desc limit 10;

### Top 10 Sender
select mainnet_transactions.origin as Sender, count(*) as Transactions from mainnet_transactions group by Sender order by Transactions desc limit 10;

### TOP 10 Reciever
select to_Address as Reciever, count(*) as Transactions from mainnet_clauses group by Reciever order by Transactions desc limit 10;

### TOP 10 TX payer
select gaspayer as GasPayer, count(1) as payedTX from mainnet_transactions group by gaspayer order by payedTX desc limit 10;

