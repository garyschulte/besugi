#!/bin/bash

echo "USE AT YOUR OWN RISK"
read -p "Are you sure you've double checked the values and want to make this deposit? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
fi

source goerli-shadow-fork-1.env

if [[ -z "${VALIDATORS_MNEMONIC}" ]]; then
  read -p "Enter the validator mnemonic or <enter> to generate it: " -r
  echo
  if [[ -z "${REPLY}" ]]; then
    VALIDATORS_MNEMONIC=`eth2-val-tools mnemonic | tee /tmp/secrets/validator_seed.txt`
  else 
    VALIDATORS_MNEMONIC="${REPLY}"
  fi
fi

if [[ -z "${WITHDRAWALS_MNEMONIC}" ]]; then
  WITHDRAWALS_MNEMONIC="${VALIDATORS_MNEMONIC}"
fi

if [[ -z "${ETH1_FROM_ADDR}" ]]; then
  read -p "Enter the eth1 address to deposit from: " -r
  echo
  ETH1_FROM_ADDR="${REPLY}"
fi

if [[ -z "${ETH1_FROM_PRIV}" ]]; then
  read -p "Enter the private key for your eth1 address: " -r
  echo
  ETH1_FROM_PRIV=${REPLY}
fi

echo "using: \n\tETH1_FROM_ADDR: $ETH1_FROM_ADDR \n\tETH1_FROM_PRIV: $ETH1_FROM_PRIV\n\tVALIDATORS_MNEMONIC: $VALIDATORS_MNEMONIC\n\tWITHDRAWALS_MNEMONIC: $WITHDRAWALS_MNEMONIC"

eth2-val-tools deposit-data \
  --source-min=0 \
  --source-max=1 \
  --amount=$DEPOSIT_AMOUNT \
  --fork-version=$FORK_VERSION \
  --withdrawals-mnemonic="$WITHDRAWALS_MNEMONIC" \
  --validators-mnemonic="$VALIDATORS_MNEMONIC" > $DEPOSIT_DATAS_FILE_LOCATION


# Iterate through lines, each is a json of the deposit data and some metadata
while read x; do
   account_name="$(echo "$x" | jq '.account')"
   pubkey="$(echo "$x" | jq '.pubkey')"
   echo "Sending deposit for validator $account_name $pubkey"
   ethereal beacon deposit \
      --allow-unknown-contract=$FORCE_DEPOSIT \
      --address="$DEPOSIT_CONTRACT_ADDRESS" \
      --connection=$ETH1_RPC \
      --data="$x" \
      --value="$DEPOSIT_ACTUAL_VALUE" \
      --from="$ETH1_FROM_ADDR" \
      --privatekey="$ETH1_FROM_PRIV"
   echo "Sent deposit for validator $account_name $pubkey"
   sleep 3
done < "$DEPOSIT_DATAS_FILE_LOCATION"
