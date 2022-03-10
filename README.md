# Besugi

Docker-compose repo that makes it super easy to participate in kiln with Besu

## Handling the deposit

The docker image in eth2-val-tools directory will handle making the deposit for you, including creating your valiator mnemonic. from project root:

```
  cd eth2-val-tools
  docker build -t besugi/eth2-val-tools .
  cd ..
  docker run -v `pwd`/secrets:/tmp/secrets -it --entrypoint /app/exec_deposits.sh besugi/eth2-val-tools
```

If you let the deposit script create your mnemonic, it will be in `secrets/validator_seed.txt`

## Config

edit `kiln.vars` and fill in your:
* IP_ADDRESS (your public/external IP address)
* COINBASE (your eth1 address for rewards)
* HOST_NAME (the name you want to show up on kintsugi ethstats)
* VALIDATORS_MNEMOMIC (the phrase for your validator from the deposit step above)
 

## Run the Consensus client combo 

### for Teku:
  `docker-compose --env-file kiln.vars -f docker-compose.besu-teku.yaml up`

### for Lighthouse
  `docker-compose --env-file kiln.vars -f docker-compose.besu-lighthouse.yaml up`

### for Lodestar
  `docker-compose --env-file kiln.vars -f docker-compose.besu-lodestar.yaml up`

### for Nimbus
  `docker-compose --env-file kiln.vars -f docker-compose.besu-nimbus.yaml up`
