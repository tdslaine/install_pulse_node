### Will upload precompiled Binarys here once i find a way around the upload limit

#####lighthosue:

sudo docker cp validator:/usr/local/bin/lighthouse TARGET_PATH

#####prysm validator:

sudo docker cp validator:/app/cmd/validator/validator.runfiles/prysm/cmd/validator/validator_/validator TARGET_PATH

#####prysm beacon:

 sudo docker cp  beacon:/app/cmd/beacon-chain/beacon-chain.runfiles/prysm/cmd/beacon-chain/beacon-chain_/beacon-chain TARGET_PATH


#####gopls:

sudo docker cp execution:/usr/local/bin/geth TARGET_PATH



other stuff:

check running docker details (get paths etc...:

docker inspect {beacon|validator|execution}
