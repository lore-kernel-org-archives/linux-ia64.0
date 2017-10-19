From: Waiman Long <longman@redhat.com>
Date: Thu, 19 Oct 2017 15:21:40 +0000
Subject: Re: [PATCH-tip v7 00/15] locking/rwsem: Rework rwsem-xadd & enable new rwsem features
Message-Id: <ecb6fd0b-a242-1426-112e-e582898565d2@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>

Hi,

I had just run the rwsem microbenchmark on a 1-socket 44-core Qualcomm
Amberwing (Centriq 2400) arm64 system. There were 18 writer and 18
reader threads running.

For the patched kernel, the results were:

                       Reader                       Writer
  CS Load         Locking Ops/Thread           Locking Ops/Thread
  -------         ------------------           ------------------
     1          18,800/103,894/223,371      496,362/695,560/1,034,278
    10          28,503/ 68,834/154,348      425,708/791,553/1,469,845
    50           7,997/ 28,278/102,327      431,577/897,064/1,898,146
   100          31,628/ 52,555/ 89,431      432,844/580,496/  910,290
 1us sleep      15,625/ 16,071/ 16,535       42,339/ 44,866/   46,189

                     Reader                       Writer
  CS Load     Slowpath Locking Ops         Slowpath Locking Ops
  -------     --------------------         --------------------
     1            1,296,904                     11,196,177
    10            1,125,334                     13,242,082
    50              284,342                     14,960,882
   100              916,305                      9,652,818
 1us sleep          289,177                        807,584

                 All Writers        Half Writers
  CS Load    Locking Ops/Thread  Locking Ops/Thread     % Change
  -------    ------------------  ------------------     --------
     1           1,634,230           695,560             -57.4
    10           1,658,228           791,553             -52.3
    50           1,494,180           897,064             -40.0
   100           1,089,364           580,496             -46.7
 1us sleep          25,380            44,866             +76.8

It is obvious that for arm64, the writers are preferred under all
circumstances. One special thing about the results was that for the
all writers case, the number of slowpath calls were exceedingly small.
It was about 1000 or less which are significantly less than in x86-64
which was in the millions. Maybe it was due to the LL/SC architecture
that allows it to stay in the fast path as much as possible with
homogenous operation.

The corresponding results for the unpatched kernel were:

                       Reader                       Writer
  CS Load         Locking Ops/Thread           Locking Ops/Thread
  -------         ------------------           ------------------
     1           23,898/23,899/23,905        45,264/177,375/461,387
    10           25,114/25,115/25,122        26,188/190,517/458,960
    50           23,762/23,762/23,763        67,862/174,640/269,519
   100           25,050/25,051/25,053        57,214/200,725/814,178
 1us sleep            6/     6/     7             6/ 58,512/180,892

                 All Writers        Half Writers
  CS Load    Locking Ops/Thread  Locking Ops/Thread     % Change
  -------    ------------------  ------------------     --------
     1           1,687,691           177,375             -89.5
    10           1,627,061           190,517             -88.3
    50           1,469,431           174,640             -88.1
   100           1,148,905           200,725             -82.5
 1us sleep          29,865            58,512             +95.9

Cheers,
Longman
