#!/bin/bash

set -e

SD=$(dirname $0)

cd $SD

vagrant destroy --force

vagrant up

VMS="
debian7
debian8
ubuntu1204
ubuntu1404
ubuntu1604
"

for name in $VMS; do

    echo ""
    echo "============================================================"
    echo "testing on $name"
    echo "============================================================"
    echo ""

    vagrant ssh -c "sudo unattended-upgrades -d" $name
done
