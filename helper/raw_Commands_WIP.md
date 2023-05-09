### Prunning DB with geth
###### note: ajdust the /blockchain part of the command to your setup...

```bash
sudo docker stop execution && sudo docker container prune -f \

sudo docker run --rm -it \
-v /blockchain/execution/geth/:/blockchain \
--name="geth_prun" \
registry.gitlab.com/pulsechaincom/go-pulse:latest \
--datadir /blockchain \
snapshot prune-state

#sudo docker stop geth_prun && sudo docker container prune -f
```


### List keys currently validating with prysm
###### note: ajdust the blockchain part of the command to your setup...
```bash
docker run --rm -it -v "/blockchain/wallet:/wallet" registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest accounts list --pulsechain-testnet-v4  --wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt
```

### Get Validator infos from local beacon
###### note: replace YOUR_VALIDATOR_INDEX with the index from beacon-explorer...e.g. 7654

prym:
 ```bash
 curl -X 'GET'   'http://127.0.0.1:3500/eth/v1/beacon/states/head/validators/YOUR_VALIDATOR_INDEX'   -H 'accept: application/json' 
```

lighthouse:
```bash
curl -X 'GET'   'http://127.0.0.1:5052/eth/v1/beacon/states/head/validators/YOUR_VALIDATOR_INDEX'   -H 'accept: application/json' 
```

### Submit bls-to-execution change to beacon
###### note: @filename is the json generated from the bls-to-exeuction converion via staking-cli

prysm:
```bash
curl -X 'POST' \
  'localhost:3500/eth/v1/beacon/pool/bls_to_execution_changes' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d @filename.json
```

lighthouse:
```bash
curl -X 'POST' \
  'localhost:5052/eth/v1/beacon/pool/bls_to_execution_changes' \
  -H 'accept: */*' \
  -H 'Content-Type: application/json' \
  -d @filename.json
```
