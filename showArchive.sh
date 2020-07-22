#!/bin/bash
#
# edited by semigod
#
# 2020/07/20

nfsIp='10.7.150.51'
nfsSharedPath='Share00'
nfsSource="${nfsIp}:/${nfsSharedPath}"
passport='my.passport'
myPass=$(cat ${passport})

## make a mount-point directory
#echo -e "\n[TASK] Check if the nfs mountpoint is existed."
mountPoint='/mnt/nfs_shared'
if [ ! -d "${mountPoint}" ]; then
#    echo -e " - make a mountpoint"
    mkdir -p ${mountPoint}
#else
#    echo -e " - Done"
fi

## check if the nfs mountpoint is mounted
#echo -e "\n[TASK] Check if the nfs mountpoint is mounted."
nfsStatus=$(mount -l | grep "${mountPoint}")
#if [ ! -z "${nfsStatus}" ] &&  [ "$(echo ${nfsStatus} | awk '{print $1}')" == "${nfsSource}" ]; then
#    echo -e "<!> [${mountPoint}] has been mounted. <!>"
#else
#    echo -e "<!> mount [${nfsSource}] to [${mountPoint}]."
if [ -z "${nfsStatus}" ]; then
    echo ${myPass} | sudo -S mount -t nfs ${nfsSource} ${mountPoint} 2> /dev/null
fi

## check the archived storage"
echo -e "\n[TASK] show the archived information"
tree ${mountPoint}

## show the last 2 archived files
./getBucket.sh 

