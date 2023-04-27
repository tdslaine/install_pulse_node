# attaches to geth docker session - change folder accordingly to your setup.
#!/bin/bash

docker exec -it execution geth attach /blockchain/execution/geth/geth.ipc
