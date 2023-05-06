# Prunning DB
sudo docker run -it -v /home/blockchain/execution/geth/:/blockchain registry.gitlab.com/pulsechaincom/go-pulse:latest --datadir /blockchain snapshot prune-state
