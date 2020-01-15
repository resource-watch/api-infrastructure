#!/bin/bash

touch /home/"${user}"/.ssh/authorized_keys

${echo_rows}

chown ${user}: /home/"${user}"/.ssh/authorized_keys
chmod 0600 /home/"${user}"/.ssh/authorized_keys
