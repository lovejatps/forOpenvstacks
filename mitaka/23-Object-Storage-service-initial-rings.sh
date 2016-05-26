#!/bin/bash
STORAGE_NODE_MANAGEMENT_INTERFACE_IP_ADDRESS=$1
DEVICE_NAME=$2
DEVICE_WEIGHT=$3
cd /etc/swift
swift-ring-builder account.builder create 10 3 1
swift-ring-builder account.builder add --region 1 --zone 1 --ip ${STORAGE_NODE_MANAGEMENT_INTERFACE_IP_ADDRESS} --port 6002 --device ${DEVICE_NAME} --weight ${DEVICE_WEIGHT}
