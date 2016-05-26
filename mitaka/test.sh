#!/bin/bash
echo "put"
read tmp
if [[ $tmp = "y" || $tmp = "Y" ]]; then
	echo "bingo!"
fi
