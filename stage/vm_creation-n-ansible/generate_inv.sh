#!/bin/bash

# This script will generate the python script for ansible dynamic inventory

file=/tmp/${1}.py
cp inventory.py $file
sed -i "s/host_ip/$2/g" $file