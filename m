From: Dan Am <sendmail@lonx.net>
Date: Tue, 18 Nov 2003 12:11:25 +0000
Subject: /proc/meminfo
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_txgu/ezrJ77cWeZ"
Message-Id: <marc-linux-ia64-106915749804036@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_txgu/ezrJ77cWeZ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,
running rhas2.1 with 2.4.18-e.31smp  (stock-redhat) on a rx2600. I noticed 
that the figures from /proc/meminfo and thus top seem to add somewhat 
different to i386:
"Shared" and "buffers" and "free" add up  to only 1.6 GB with 2GB available   
In i386 all three add up to the total available. 
I include two listings. Does that make sense and if so how ? I did search this 
lists archive for hints on "top" and "meminfo" . 

Tia & regards 

Dan 

--Boundary-00=_txgu/ezrJ77cWeZ
Content-Type: text/plain;
  charset="us-ascii";
  name="meminfoi386"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="meminfoi386"

        total:    used:    free:  shared: buffers:  cached:
Mem:  1057861632 678666240 379195392        0 198885376 366485504
Swap: 789618688        0 789618688
MemTotal:      1033068 kB
MemFree:        370308 kB
MemShared:           0 kB
Buffers:        194224 kB
Cached:         357896 kB
SwapCached:          0 kB
Active:         191296 kB
Inactive:       381736 kB
HighTotal:      130992 kB
HighFree:         2044 kB
LowTotal:       902076 kB
LowFree:        368264 kB
SwapTotal:      771112 kB
SwapFree:       771112 kB
BigFree:             0 kB
        total:    used:    free:  shared: buffers:  cached:
Mem:  1057861632 678674432 379187200        0 198893568 366485504
Swap: 789618688        0 789618688
MemTotal:      1033068 kB
MemFree:        370300 kB
MemShared:           0 kB
Buffers:        194232 kB
Cached:         357896 kB
SwapCached:          0 kB
Active:         191320 kB
Inactive:       381720 kB
HighTotal:      130992 kB
HighFree:         2044 kB
LowTotal:       902076 kB
LowFree:        368256 kB
SwapTotal:      771112 kB
SwapFree:       771112 kB
BigFree:             0 kB

--Boundary-00=_txgu/ezrJ77cWeZ
Content-Type: text/plain;
  charset="us-ascii";
  name="meminfoia64"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="meminfoia64"

        total:    used:    free:  shared: buffers:  cached:
Mem:  2092859392 2026700800 66158592        0 49397760 1532116992
Swap: 2147450880        0 2147450880
MemTotal:      2043808 kB
MemFree:         64608 kB
MemShared:           0 kB
Buffers:         48240 kB
Cached:        1496208 kB
SwapCached:          0 kB
Active:         975584 kB
Inact_dirty:    749392 kB
Inact_clean:     36448 kB
Inact_target:   352272 kB
HighTotal:           0 kB
HighFree:            0 kB
LowTotal:      2043808 kB
LowFree:         64608 kB
SwapTotal:     2097120 kB
SwapFree:      2097120 kB
Committed_AS: 49680752 kB
HugePages_Total:     0
HugePages_Free:      0
Hugepagesize:    262144 kB

--Boundary-00=_txgu/ezrJ77cWeZ--

