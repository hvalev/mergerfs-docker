#!/bin/sh

function cleanup {
    umount /merged
}

mergerfs -o allow_other,use_ino,cache.files=partial,dropcacheonclose=true,moveonenospc=true,category.create=mfs /disks/*: /merged


trap cleanup EXIT INT

while [[ $(ps -eo 'comm' | grep mergerfs -c) -gt 0 ]]; do
    sleep 1
done

echo mergerfs terminated