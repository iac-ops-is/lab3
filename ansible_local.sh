#!/bin/bash

cd ansible

echo "current directory is $PWD";

ANSIBLE_CONFIG=ansible.cfg ansible-playbook -i inventories/local/hosts.ini lab2.yml