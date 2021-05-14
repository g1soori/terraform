#!/bin/env python

"""
This is template for ansible dynamic inventory script. 
"""

import json
import argparse

host = "host_ip"

def get_inventory_data():
    return {
        "93k": {
            "hosts": ["93k"],
            "vars": {
                "ansible_python_interpreter": "/opt/tools/bin/python",
                "ansible_ssh_host": host
            }
        }
    }

def read_cli_args():
    global args
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--host', action='store')
    args = parser.parse_args()

# Default main function
if __name__ == "__main__":
    global args
    read_cli_args()
    inventory_data = get_inventory_data()
    if args and args.list:
        print(json.dumps(inventory_data))
    elif args.host:
        print(json.dumps({'_meta': {'hostvars': {}}}))