From: Matt Chapman <matthewc@cse.unsw.edu.au>
Date: Fri, 10 May 2002 09:20:06 +0000
Subject: [Linux-ia64] Strange performance monitoring results
Message-Id: <marc-linux-ia64-105590701905566@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Linux 2.4.18-ia64-020508 (CONFIG_PERFMON, !CONFIG_DISABLE_VHPT)
* pfmon 1.0
* Uniprocessor Itanium C1-step 
* lat_ctx from LMbench 2.0p2 (ftp://ftp.bitmover.com/lmbench/)

(Though I get the same results with 2.4.16 and pfmon 0.06a.)

% pfmon -e ITLB_MISSES_FETCH,ITLB_INSERTS_HPW ./lat_ctx 5

"size=0k ovr=2.65
5 2.52
               221400 ITLB_MISSES_FETCH
                  133 ITLB_INSERTS_HPW

The ITLB misses figure seems much too big, especially given the number
of hardware pagetable walker inserts is low.  Every few times I also get
very big figures for DTLB_MISSES, although not DTC_MISSES (I would have
thought DTLB_MISSES should be less than DTC_MISSES?).

Am I doing something wrong?

Matt


