#!/bin/bash
cd /app

if [ "$1" == "y" ]; then
    rm -rf ./resources/datadir
fi

echo "SequencerAddress" $SequencerAddress
echo "ChainID" $ChainID


if [ ! -d "./resources/datadir" ]; then
    mkdir -p ./resources/datadir
    (
      cd ./resources
      echo "pwd" > datadir/password
      if [ "$MASTER" == "1" ]; then
        echo $SequencerPriv > datadir/block-signer-key
        /app/bin/geth account import --datadir=datadir --password=datadir/password datadir/block-signer-key
      fi
      /app/bin/geth init --datadir=datadir genesis.json
    )
fi


if [ "$MASTER" == "1" ]; then
  ./bin/geth \
      --datadir ./resources/datadir \
      --http \
      --http.corsdomain="*" \
      --http.vhosts="*" \
      --http.addr=0.0.0.0 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.api=eth,net,web3,txpool \
      --ws.port=8546 \
      --ws.origins="*" \
      --syncmode=full \
      --gcmode=archive \
      --nodiscover \
      --maxpeers=0 \
      --networkid=$ChainID \
      --authrpc.vhosts="*" \
      --authrpc.addr=0.0.0.0 \
      --authrpc.port=8551 \
      --authrpc.jwtsecret=./resources/jwt.txt \
      --rollup.disabletxpoolgossip=false \
      --password=./resources/datadir/password \
      --allow-insecure-unlock \
      --mine \
      --miner.etherbase=$SequencerAddress \
      --log.debug \
      --unlock=$SequencerAddress 2>&1 | cronolog $PWD/resources/logs/%Y-%m-%d.log
else
  ./bin/geth \
      --datadir ./resources/datadir \
      --http \
      --http.corsdomain="*" \
      --http.vhosts="*" \
      --http.addr=0.0.0.0 \
      --ws \
      --ws.addr=0.0.0.0 \
      --ws.port=8546 \
      --ws.origins="*" \
      --syncmode=full \
      --gcmode=archive \
      --nodiscover \
      --maxpeers=0 \
      --networkid=$ChainID \
      --authrpc.vhosts="*" \
      --authrpc.addr=0.0.0.0 \
      --authrpc.port=8551 \
      --authrpc.jwtsecret=./resources/jwt.txt \
      --rollup.disabletxpoolgossip=false \
      --password=./resources/datadir/password \
      --allow-insecure-unlock \
      --log.debug 2>&1 | cronolog $PWD/resources/logs/%Y-%m-%d.log
fi

