#!/bin/bash

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

NETWORK=${1?Error: Give Network to operate in solo|test|main}


## Variables ##########################################################################################
### MySQL Connect
MySQL_host="localhost"
MySQL_user="vechain"
MySQL_pass="VeChainToDaMoon"
MySQL_db="VeBlocks"

### availibe VeChain Nodes - Nodes as an array. Calls will randomly choose one
### MainnetNodes
VECHAIN_NODE_Mainnet[0]="http://localhost:8669"
#VECHAIN_NODE_Main[1]="http://192.168.1.1:8669"
###TestnetNodes
VECHAIN_NODE_Testnet[0]="http://localhost:8659"
#VECHAIN_NODE_Testnet[1]="http://192.168.1.2:8659"


#### Choose Main/Test/Solo Nodes
NETWORK=${NETWORK,,}

if [ $NETWORK == main ]
  then
    VECHAIN_NODE=${VECHAIN_NODE_Mainnet[RANDOM%${#VECHAIN_NODE_Mainnet[@]}]}
    SQL_Blocks="mainnet_blocks"
    SQL_Tx="mainnet_transactions"
    SQL_Clauses="mainnet_clauses"
    SHOW_Net="M"
  elif [ $NETWORK == test ]
  then
    VECHAIN_NODE=${VECHAIN_NODE_Testnet[RANDOM%${#VECHAIN_NODE_Testnet[@]}]}
    SQL_Blocks="testnet_blocks"
    SQL_Tx="testnet_transactions"
    SQL_Clauses="testnet_clauses"
    SHOW_Net="T"
  else echo "Something is wrong with the choosen Nodes"
fi


#If Y, write data to MySQL. If N, just show on screen.
DoMySQL=Y

while true; do

  ### dynamically choose blocks to import
  Block_Start=`mysql -N -h $MySQL_host -u $MySQL_user -p$MySQL_pass --silent -D $MySQL_db <<< "select block_number from $SQL_Blocks order by block_number desc limit 1;"`
  Block_End=`curl -s -X GET "$(eval "echo $VECHAIN_NODE")/blocks/best" -H  "accept: application/json" | grep 0x | cut -d':' -f2 | cut -d',' -f1`

  ### manually choose blocks to import
  #Block_Start=992200
  #Block_End=992299

   if [ -n "$Block_Start" ] && [ "$Block_Start" -eq "$Block_Start" ] 
    then
      echo ""
    else
      Block_Start=0
  fi


  ## /Variables #########################################################################################
  echo "Initiate Blockimport from "$Block_Start" to $Block_End"
  sleep 2


  for ((Blocknumber=$Block_Start; Blocknumber <= $Block_End; Blocknumber++)); do
    blockinfos=(`curl -s -X GET "$(eval "echo $VECHAIN_NODE")/blocks/$Blocknumber" -H  "accept: application/json" | \
    jq --raw-output '.number,.id,.size,.timestamp,.gasLimit,.gasUsed,.totalScore'`)
  
    echo "################################################################################################"
    echo ""
    echo "$SHOW_Net/B${blockinfos[0]}/Tx/Cx: Using Node  : "$VECHAIN_NODE   
    echo "$SHOW_Net/B${blockinfos[0]}/Tx/Cx: Blocknumber : "${blockinfos[0]}
    echo "$SHOW_Net/B${blockinfos[0]}/Tx/Cx: BlockID     : "${blockinfos[1]}
    echo "$SHOW_Net/B${blockinfos[0]}/Tx/Cx: Blocksize   : "${blockinfos[2]}
    echo "$SHOW_Net/B${blockinfos[0]}/Tx/Cx: gasUsed     : "${blockinfos[5]}
    echo "$SHOW_Net/B${blockinfos[0]}/Tx/Cx: totalScore  : "${blockinfos[6]}

    if [ $DoMySQL == "Y" ]
    then
      mysql -N -h $MySQL_host -u $MySQL_user -p$MySQL_pass --silent -D $MySQL_db <<< "INSERT IGNORE INTO $SQL_Blocks (block_number, block_id, block_size, block_time, gasLimit, gasUsed, totalScore) 
      VALUES ('${blockinfos[0]}', '${blockinfos[1]}', '${blockinfos[2]}', FROM_UNIXTIME('${blockinfos[3]}'), '${blockinfos[4]}', '${blockinfos[5]}', '${blockinfos[6]}');"
    fi

    blocktx=(`curl -s -X GET "$(eval "echo $VECHAIN_NODE")/blocks/$Blocknumber" -H  "accept: application/json" | \
    jq --raw-output '.transactions[]'`)


        transaction=0
    for i in "${blocktx[@]}"
    do
      ### write TX info 
      txinfos=(`curl -s -X GET "$(eval "echo $VECHAIN_NODE")/transactions/$i" -H  "accept: application/json" | jq --raw-output '.gasPriceCoef,.gas,.origin'`)
      txreceipt=(`curl -s -X GET "$(eval "echo $VECHAIN_NODE")/transactions/$i/receipt" -H  "accept: application/json" | jq --raw-output '.gasPayer,.paid,.reward,.reverted'`)
      
      reward_hex=`python -c "print int('${txreceipt[2]}', 16)"`
      reward=`bc -l <<< "$reward_hex /1000000000000000000"`
      
      vthor_hex=`python -c "print int('${txreceipt[1]}', 16)"`
      vthor=`bc -l <<< "$vthor_hex /1000000000000000000"`
      

      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: TxID         :" $i
      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: Origin       :" ${txinfos[2]}
      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: Reverted     :" ${txreceipt[3]}
      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: Gas Payer    :" ${txreceipt[0]}
      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: Gas Reward   :" $reward
      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: GasCoef      :" ${txinfos[0]}
      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: Gas          :" ${txinfos[1]}
      echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/Cx: VTHO Payed   :" $vthor
      
      
      if [ $DoMySQL == "Y" ]
      then
        mysql -N -h $MySQL_host -u $MySQL_user -p$MySQL_pass --silent -D $MySQL_db <<< "INSERT IGNORE INTO $SQL_Tx (tx_id, block_id, origin, gascoef, gas, gaspayer, gaspayed, reward, reverted) 
        VALUES ('$i', '${blockinfos[1]}', '${txinfos[2]}', '${txinfos[0]}', '${txinfos[1]}', '${txreceipt[0]}', '$vthor', '$reward', '${txreceipt[3]}');"
      fi

      ### / write TX Info

      ### get Clauses
      txclauses=(`curl -s -X GET "$(eval "echo $VECHAIN_NODE")/transactions/$i" -H  "accept: application/json" | jq -c '.clauses[]'`)

      clause=0
      SQL_Input=()
      for n in "${txclauses[@]}"
      do
        arr=(${n//\"/ })
        to=0
        to=${arr[3]}
        data=${arr[11]}
      
        if [ ${arr[7]} == "0x0" ]
          then
            amount=0
        else
            amount_hex=`python -c "print int('${arr[7]}', 16)"`
            amount=`bc -l <<< "$amount_hex /1000000000000000000"`
        fi

        echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/C$clause: To           :" $to
        echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/C$clause: Value        :" $amount
        echo "$SHOW_Net/B${blockinfos[0]}/T$transaction/C$clause: Data         :" ${data:0:52}...

        SQL_Input+=("INSERT IGNORE INTO $SQL_Clauses (tx_id, to_Address, amount, data) VALUES ('$i', '$to', '$amount', '$data');")
      
        clause=$((clause + 1))
        ### Process Clauses Done
      done

      if [ $DoMySQL == "Y" ]
        then
          ### Import the whole SQL_Input Array at one. This is so awesome.
          mysql -N -h $MySQL_host -u $MySQL_user -p$MySQL_pass --silent -D $MySQL_db <<< ${SQL_Input[@]}
      fi
      ## Import transaction done
      transaction=$((transaction + 1))
    done

    if (( $Blocknumber % 500 == 0 ))
      then
        echo "SLEEP 1 Sec: Now is the time to safely interrupt!"
        sleep 1
    fi
    ## Import block done
  done
  ## Import blockrange done
  echo ""
  echo "Wait for new blocks."
  sleep 7
done