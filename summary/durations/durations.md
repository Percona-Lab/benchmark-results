---

title: "Percona Xtrabackup: Compression and Encryption performance"
author: "Percona Lab"
generated on:July 15, 2016
output:
  html_document:
    self_contained: false 
    lib_dir: libs
<!--  md_document:
    variant: markdown_github -->

---


# Percona Xtrabackup 2.3.4 - Encryption and Compression performance 

## Setup

* Client and server on the same machine 
* Sysbench oltp workload running during all tests
* 21GB datadir (restored between tests)
* CPU: 48 logical CPU threads (Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz). 
* Memory: 120GB. 
* Disk: hdd (HGST HUH728080ALE600), ssd (Intel 3600 nvme) 
* Encryption (E) and Compression (C) tested with 1, 4, 8, 16 and 32 threads


## Backup duration 

Backup duration by type, number of threads, and disk type, faceted by
--parallel threads. The
horizontal line on each graph shows the duration for the baseline (non
compressed, non encrypted) backup. 

![plot of chunk global](figure/global-1.png)

```
##     disk                type parallel_threads threads backup_duration
## 7    ssd         compression                1       4              74
## 12   ssd         compression                1       8              74
## 17   ssd         compression                1      16              74
## 27   ssd         compression                1      48              74
## 22   ssd         compression                1      32              75
## 28   ssd         compression                4      48              75
## 32   ssd         compression                1      62              75
## 33   ssd         compression                4      62              75
## 23   ssd         compression                4      32              76
## 18   ssd         compression                4      16              77
## 15   ssd         compression               16       8              78
## 14   ssd         compression                8       8              79
## 16   ssd         compression               32       8              79
## 19   ssd         compression                8      16              79
## 21   ssd         compression               32      16              79
## 24   ssd         compression                8      32              79
## 25   ssd         compression               16      32              79
## 9    ssd         compression                8       4              80
## 11   ssd         compression               32       4              80
## 13   ssd         compression                4       8              80
## 29   ssd         compression                8      48              80
## 34   ssd         compression                8      62              80
## 35   ssd         compression               16      62              80
## 36   ssd         compression               32      62              80
## 88   ssd xbstream_compressed                1      32              80
## 8    ssd         compression                4       4              81
## 20   ssd         compression               16      16              81
## 30   ssd         compression               16      48              81
## 31   ssd         compression               32      48              81
## 81   ssd xbstream_compressed                4       8              81
## 85   ssd xbstream_compressed                4      16              81
## 89   ssd xbstream_compressed                4      32              81
## 10   ssd         compression               16       4              82
## 26   ssd         compression               32      32              82
## 84   ssd xbstream_compressed                1      16              82
## 77   ssd xbstream_compressed                4       4              83
## 78   ssd xbstream_compressed                8       4              83
## 80   ssd xbstream_compressed                1       8              83
## 86   ssd xbstream_compressed                8      16              83
## 76   ssd xbstream_compressed                1       4              84
## 82   ssd xbstream_compressed                8       8              84
## 90   ssd xbstream_compressed                8      32              85
## 83   ssd xbstream_compressed               16       8              88
## 91   ssd xbstream_compressed               16      32              88
## 79   ssd xbstream_compressed               16       4              89
## 87   ssd xbstream_compressed               16      16              89
## 111  ssd     xbstream_qpress               16      32              89
## 98   ssd     xbstream_qpress                8       4              90
## 99   ssd     xbstream_qpress               16       4              90
## 101  ssd     xbstream_qpress                4       8              90
## 107  ssd     xbstream_qpress               16      16              90
## 93   ssd     xbstream_qpress                4       1              91
## 106  ssd     xbstream_qpress                8      16              91
## 109  ssd     xbstream_qpress                4      32              91
## 94   ssd     xbstream_qpress                8       1              92
## 97   ssd     xbstream_qpress                4       4              92
## 103  ssd     xbstream_qpress               16       8              92
## 102  ssd     xbstream_qpress                8       8              93
## 95   ssd     xbstream_qpress               16       1              94
## 110  ssd     xbstream_qpress                8      32              94
## 105  ssd     xbstream_qpress                4      16              95
## 74   ssd xbstream_compressed                8       1             100
## 73   ssd xbstream_compressed                4       1             101
## 75   ssd xbstream_compressed               16       1             102
## 100  ssd     xbstream_qpress                1       8             106
## 104  ssd     xbstream_qpress                1      16             110
## 108  ssd     xbstream_qpress                1      32             110
## 96   ssd     xbstream_qpress                1       4             111
## 72   ssd xbstream_compressed                1       1             113
## 92   ssd     xbstream_qpress                1       1             113
## 4    ssd         compression                8       1             119
## 6    ssd         compression               32       1             119
## 3    ssd         compression                4       1             120
## 5    ssd         compression               16       1             120
## 2    ssd         compression                1       1             129
## 37   ssd          encryption                1       1             131
## 42   ssd          encryption                1       4             131
## 57   ssd          encryption                1      32             131
## 52   ssd          encryption                1      16             132
## 67   ssd          encryption                1      62             132
## 47   ssd          encryption                1       8             133
## 62   ssd          encryption                1      48             133
## 68   ssd          encryption                4      62             135
## 38   ssd          encryption                4       1             136
## 48   ssd          encryption                4       8             136
## 53   ssd          encryption                4      16             136
## 63   ssd          encryption                4      48             136
## 43   ssd          encryption                4       4             137
## 58   ssd          encryption                4      32             138
## 64   ssd          encryption                8      48             140
## 39   ssd          encryption                8       1             142
## 54   ssd          encryption                8      16             143
## 55   ssd          encryption               16      16             143
## 59   ssd          encryption                8      32             143
## 69   ssd          encryption                8      62             143
## 70   ssd          encryption               16      62             143
## 41   ssd          encryption               32       1             144
## 44   ssd          encryption                8       4             144
## 49   ssd          encryption                8       8             144
## 51   ssd          encryption               32       8             144
## 45   ssd          encryption               16       4             145
## 46   ssd          encryption               32       4             145
## 50   ssd          encryption               16       8             145
## 56   ssd          encryption               32      16             145
## 60   ssd          encryption               16      32             145
## 61   ssd          encryption               32      32             145
## 65   ssd          encryption               16      48             145
## 66   ssd          encryption               32      48             145
## 71   ssd          encryption               32      62             145
## 40   ssd          encryption               16       1             146
```

