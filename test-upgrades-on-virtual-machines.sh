#!/bin/bash

set -e

SD=$(dirname $0)

cd $SD

vagrant destroy --force

vagrant up

vagrant ssh -c "sudo unattended-upgrades -d" debian
vagrant ssh -c "sudo unattended-upgrades -d" ubuntu
