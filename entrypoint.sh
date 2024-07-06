#!/bin/sh
set -exo pipefail

function cleanup {
    umount /merged
}

# Assign default options if nothing is specified
OPTIONS=${MERGERFS_OPTIONS:-"allow_other,use_ino,cache.files=partial,dropcacheonclose=true,moveonenospc=true,category.create=mfs"}

# if a path to a config file is set, it takes precedence
if [ -n "${MERGERFS_CONFIG_PATH}" ]; then
    OPTIONS="config=${MERGERFS_CONFIG_PATH}"
fi

mergerfs -o "${OPTIONS}" /disks/*: /merged


trap cleanup EXIT INT

while [[ $(ps -eo 'comm' | grep mergerfs -c) -gt 0 ]]; do
    sleep 1
done

echo mergerfs terminated
