#!/bin/bash

arch=`uname -m`
dest_kernel="hello-vmlinux.bin"
image_bucket_url="https://s3.amazonaws.com/spec.ccfc.min/img"

if [ ${arch} = "x86_64" ]; then
    kernel="${image_bucket_url}/hello/kernel/hello-vmlinux.bin"
elif [ ${arch} = "aarch64" ]; then
    kernel="${image_bucket_url}/aarch64/ubuntu_with_ssh/kernel/vmlinux.bin"
else
    echo "cannot run firecracker on $arch architecture!"
    exit 1
fi

echo "downloading $kernel..."
curl -fssl -o $dest_kernel $kernel

echo "saved kernel file to $dest_kernel."
