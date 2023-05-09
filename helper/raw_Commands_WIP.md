### Prunning DB with geth

```bash
sudo docker stop execution && sudo docker container prune -f \

sudo docker run -it -v /home/blockchain/execution/geth/:/blockchain \
registry.gitlab.com/pulsechaincom/go-pulse:latest \
--datadir /blockchain \
snapshot prune-state
```


### List keys currently validating with prysm

```bash
docker run --rm -it -v "${install_path}/wallet:/wallet" registry.gitlab.com/pulsechaincom/prysm-pulse/validator:latest accounts list --pulsechain-testnet-v4  --wallet-dir=/wallet --wallet-password-file=/wallet/pw.txt
```
