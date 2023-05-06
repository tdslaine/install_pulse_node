### Prunning DB with geth

```bash
sudo docker stop execution && sudo docker container prune -f \

sudo docker run -it -v /home/blockchain/execution/geth/:/blockchain \
registry.gitlab.com/pulsechaincom/go-pulse:latest \
--datadir /blockchain \
snapshot prune-state
```
