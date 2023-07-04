### Prunning DB with geth
###### note: ajdust the /blockchain part of the command to your setup...

```bash
sudo docker stop -t 300 execution && sudo docker container prune -f \

sudo docker run --rm --name geth_prune -it -v /home/blockchain/execution/geth:/geth \
registry.gitlab.com/pulsechaincom/go-pulse:latest \
snapshot prune-state \
--datadir /geth

#sudo -u geth docker run --rm -it --name="geth_prun" \
#-v /blockchain/execution/geth/:/blockchain \
#registry.gitlab.com/pulsechaincom/go-pulse:latest \
#snapshot prune-state \
#--datadir /blockchain/geth 

```
### Show Version

###### Prysm beacon
```bash
docker exec -it beacon /app/cmd/beacon-chain/beacon-chain --version
```

###### Prysm validator
```bash
docker exec -it validator /app/cmd/validator/validator --version
```

###### Lighthouse beacon & validator
```bash
curl -X GET "http://localhost:5052/eth/v1/node/version" -H 'accept: application/json' | jq
```

###### Geth

```bash
docker exec -it execution geth version
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
