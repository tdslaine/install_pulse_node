### Prunning DB with geth

```bash
sudo docker stop execution && sudo docker container prune -f \

sudo docker run -it -v /home/blockchain/execution/geth/:/blockchain \
--name="geth_prun"
registry.gitlab.com/pulsechaincom/go-pulse:latest \
--datadir /blockchain \
snapshot prune-state

sudo docker stop geth_prun && sudo docker container prune -f
```


### List keys currently validating with prysm

```bash
docker run --rm -it -v "${install_path}/wallet:/wallet" registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest accounts list --pulsechain-testnet-v4  --wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt
```

### Get Validator infos from local beacon

prym:
 ```bash
 curl -X 'GET'   'http://127.0.0.1:3500/eth/v1/beacon/states/head/validators/YOUR_VALIDATOR_INDEX'   -H 'accept: application/json' 
```

lighthouse:
```bash
curl -X 'GET'   'http://127.0.0.1:5052/eth/v1/beacon/states/head/validators/YOUR_VALIDATOR_INDEX'   -H 'accept: application/json' 
```
