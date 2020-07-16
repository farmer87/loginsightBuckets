#!/bin/bash
#
# edited by semigod
#
# 2020/07/15

connect () {
    cmd="${1}"
    sshpass -p ${liPass} ssh -o ConnectTimeout=10 -o PubkeyAuthentication=no \
                                     -o StrictHostKeyChecking=no ${liUser}@${liIp} "${cmd}" 2> /dev/null
}

getBucketIndex () {
    connect "/usr/lib/loginsight/application/sbin/bucket-index show" > ${bucketIndex}
    sed -i '1d' ${bucketIndex}
    #sed -i '/NULL/d' ${bucketIndex}
}

showBucket () {
    basePath='/storage/core/loginsight/cidata/store'
    num=1
    bucketId=($(grep 'archived' ${bucketIndex} | tail -n ${num} | awk -F', ' '{print $2}' | sed s'/id=//'))
    bucketCount=${#bucketId[@]}

    echo -e "\n[TASK] List the last ${num} archived buckets in [${liIp}]\n"

    for ((i=0;i<${bucketCount};i++)); do
        echo -e "Bucket ID: [${bucketId}]"
        echo "======"
        connect "du -h ${basePath}/${bucketId[$i]}"
        echo "------"
        ## list index
        echo -e "[index]\n"
        connect "ls -C -w 120 ${basePath}/${bucketId[$i]}/index"
        echo "------"
        ## list repository
        echo -e "[repository]\n"
        connect "ls ${basePath}/${bucketId[$i]}/repository"
        echo
    done
    exit
}

liPassport='li.passport'
if [ ! -f "${liPassport}" ]; then
    echo -e "<!> Passport [li.passport] is NOT FOUND <!>"
    exit
else
    liIp=$(cat ${liPassport} | cut -d: -f1)
    liPass=$(cat ${liPassport} | cut -d: -f2)
fi

liUser='root'
bucketIndex="${liIp}_bucket.index"

if [ ! -f "${bucketIndex}" ]; then
    getBucketIndex
fi

## 
showBucket


