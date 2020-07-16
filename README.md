# Log Insight 儲存桶(Bucket)


#### 參考文件
- [log insight deep dive@vmware blog](https://blogs.vmware.com/management/2020/05/vrealize-log-insight-index-partitions-and-variable-retention-deep-dive.html "請先閱讀")

> **再次強調**

    - 請先閱讀參考文件，瞭解Log Insight日誌儲存架構
    - 有關程式撰寫，皆以參考文件實作發想
    - 以下撰寫程式以BASH為主，測試Log Insight版本為8.1


#### 測試準備

    - VMware vSphere & vCenter環境
    - VMware Log Insight
    - SSH連線工具
 
#### 

```bash
$ /usr/lib/loginsight/application/sbin/bucket-index show
```

/usr/lib/loginsight/application/sbin/bucket-index show | awk -F', ' '{print $2}' | sed 's/^id=//'

buckets=($(/usr/lib/loginsight/application/sbin/bucket-index show | awk -F', ' '{print $2}' | sed 's/^id=//' | tail -n 3))
for i in ${buckets[@]}; do du -h ${i}; echo "-----"; done

400K	306b5609-1980-4f86-9630-9175e77c7154/index/fields
313M	306b5609-1980-4f86-9630-9175e77c7154/index
109M	306b5609-1980-4f86-9630-9175e77c7154/repository
422M	306b5609-1980-4f86-9630-9175e77c7154
-----
216K	1c295154-1c5f-423c-9888-aae486517dc6/index/fields
48M	1c295154-1c5f-423c-9888-aae486517dc6/index
17M	1c295154-1c5f-423c-9888-aae486517dc6/repository
65M	1c295154-1c5f-423c-9888-aae486517dc6
-----
224K	2413c2d4-bbfe-410f-97e8-4bda859e386f/index/fields
48M	2413c2d4-bbfe-410f-97e8-4bda859e386f/index
17M	2413c2d4-bbfe-410f-97e8-4bda859e386f/repository
65M	2413c2d4-bbfe-410f-97e8-4bda859e386f
-----

