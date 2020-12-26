#!/bin/bash

arch=`uname -m`
dest_rootfs="hello-rootfs.ext4"
image_bucket_url="https://s3.amazonaws.com/spec.ccfc.min/img"

if [ ${arch} = "x86_64" ]; then
    rootfs="${image_bucket_url}/hello/fsfiles/hello-rootfs.ext4"
elif [ ${arch} = "aarch64" ]; then
    rootfs="${image_bucket_url}/aarch64/ubuntu_with_ssh/fsfiles/xenial.rootfs.ext4"
else
    echo "cannot run firecracker on $arch architecture!"
    exit 1
fi

echo "downloading $rootfs..."
curl -fssl -o $dest_rootfs $rootfs

echo "saved root block device to $dest_rootfs."
