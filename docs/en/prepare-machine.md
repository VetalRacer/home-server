# Prepare

Prepare your machine before run playbook:
- copy (`prepare_server.sh`) to remote machine, you can use scp (`scp -P 22 prepare_server.sh  <username>@<ip>:/home/<username>/ `)
- login on your remote machine, you can use ssh (`ssh -p 22 <username>@<ip>`)
- change permission (`prepare_server.sh`) script, you can use (`chmod +x prepare_server.sh`)
- execute script (`./prepare_server.sh`)
- after script execution server will be rebooted

----
This script change ssh port, root login and set static ip
