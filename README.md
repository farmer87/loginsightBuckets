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
 
#### 命令訊息

在Log Insight主機上，執行以下的命令將會列出現在所有的存儲桶，而這些存儲桶正是我們之前提到Log Insight存放日誌的地方。

```bash
# /usr/lib/loginsight/application/sbin/bucket-index show
```

每筆紀錄包含以下項目：

- **id**：亂數產生的編碼，根據此識別碼，可在
/storage/core/loginsight/cidata/store/目錄中找到識別碼相同的目錄。
- **status**: 儲存桶狀態，有archived跟active兩種狀態。
- created: 儲存桶建立時間。注意格式使用的時區是UTC(+0000)。
- **startTime**/**endTime**: 儲存桶使用時間。注意格式使用的是UNIX時間戳記。時區會採用Log Insight設定的時區組態。
- **size**: 儲存桶容量。大約500MB(0.5GB)左右。

由於Log Insight原生儲存桶的紀錄較不易判讀，所以透過撰寫程式進行相關資料轉換。將上述所提相關資訊取出，並將相關時間轉換成本地時區。

#### 程式實作

根據Log Insight命令資訊及儲存統架構，撰寫出以下程式以便輕鬆取得目前儲存桶運作狀態。

    - vrliBucketInfo.sh
      - 取得目前Log Insight主機儲存桶資訊 
    - getBucket.sh
      - 取得最後n個儲存桶檔案系統架構。預設n=1




-----

