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

formatTime1 () {
    date -d "${1}" +"%Y-%m-%d %T"
}


formatTime2 () {
    if [ "$1" != "--" ]; then
        date -d @$(echo ${1::-3}) +"%Y-%m-%d %T"
    else
        echo "--"
    fi
}

getBucketInfo () {
    while IFS= read -r line; do
        id+=($(echo ${line} | awk -F', ' '{print $2}' | sed 's/^id=//'))
        status+=($(echo ${line} | awk -F', ' '{print $3}' | awk '{print $1}' | sed 's/^status=//'))
        createTime+=($(echo $line | awk -F ', ' '{print $3}' | awk '{print $2}' | sed -e 's/^created=//'))
        # -e 's/\..*$//'))
        sizeMB+=($(echo "scale=2; $(echo ${line} | awk -F', ' '{print $3}' | awk '{print $3}' | sed 's/^size=//') / 1024^2" | bc))
        if [ $(echo ${line} | awk -F', ' '{print $3}' | awk '{print $4}' | grep '[NULL]') ]; then
            startTime+=("--")
            endTime+=("--")
            message+=("--")
        else
            startTime+=($(echo ${line} | awk -F', ' '{print $3}' | awk '{print $4}' | sed 's/^cmd=\[startTime=//'))
            endTime+=($(echo ${line} | awk -F', ' '{print $3}' | awk '{print $5}' | sed 's/^endTime=//'))
            message+=($(echo ${line} | awk -F', ' '{print $3}' | awk '{print $6}' | sed 's/^messages=//'))
        fi
    done < ${bucketIndex}

    bucketCount=${#id[@]}
    activeCount=0
    totalSizeMB=0
    timeZone=$(date +%Z)

    printf "\n%-37s %-9s %-9s %-20s %-20s %-20s %-12s\n" "ID" "Status" "Size(MB)" "Create-Date(${timeZone})" "Start-Date(${timeZone})" "End-Date(${timeZone})" "Messages"
    printf "%-37s %-9s %-9s %-20s %-20s %-20s %-12s\n" "------------------------------------" "--------" "--------" "-------------------" "-------------------" "-------------------" "--------"
    for ((i=0;i<${bucketCount};i++)); do
    #for ((i=0;i<1;i++)); do
        printf "%-37s %-9s %-9s %-20s %-20s %-20s %-10s\n" "${id[$i]}" \
                                                           "${status[$i]}" \
                                                           "${sizeMB[$i]}" \
                                                           "$(formatTime1 "${createTime[$i]}")" \
                                                           "$(formatTime2 "${startTime[$i]}")" \
                                                           "$(formatTime2 "${endTime[$i]}")" \
                                                           "${message[$i]}"
                                                           #"$(echo ${createTime[$i]} | sed 's/T/\ /')" \

        if [ "${status[$i]}" == "active" ]; then
            activeCount=$(expr ${activeCount} + 1)
        fi

        totalSizeMB=$(echo "scale=2; ${totalSizeMB} + ${sizeMB[$i]}" | bc)
    done

    echo "---"
    echo -e " Total: ${bucketCount}    Active: ${activeCount}    Archived: $(expr ${bucketCount} - ${activeCount})    Size(GB): $(echo "scale=2; ${totalSizeMB} / 1024" | bc)"
    echo 
}

liPassport='li.passport'
if [ ! -f "${liPassport}" ] && [ $# -ne 2 ]; then
    echo -e "<!> Passport [li.passport] is NOT FOUND <!>"
    echo -e "<!> Usage: $0 <loginsight_ip> <loginsight_rootpw> <!>"
    exit
elif [ -f "${liPassport}" ]; then
    liIp=$(cat ${liPassport} | cut -d: -f1)
    liPass=$(cat ${liPassport} | cut -d: -f2)
elif [ $# -eq 2 ]; then
    liIp=$1
    liPass=$2
fi

liUser='root'
bucketIndex="${liIp}_bucket.index"

# main () {
    echo -e "\n[TASK] Get the index of buckets"
    getBucketIndex

    echo -e "\n[TASK] Display the status of buckets"
    getBucketInfo

#}

#main