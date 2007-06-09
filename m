From: Christoph Lameter <clameter@sgi.com>
Date: Sat, 09 Jun 2007 00:03:22 +0000
Subject: RE: [IA64] Set default page size to 64k
Message-Id: <Pine.LNX.4.64.0706081658400.4650@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706071803570.14490@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Some numbers from Mel Gorman's test on IA64

Source can be found at http://lkml.org/lkml/2007/3/9/198. This was 
before the atomic ops et al optimizations for netperf.

KernBench Comparison
--------------------
                           2.6.21-rc2-mm2-clean       2.6.21-rc2-mm2-slub      %diff
User   CPU time                        1084.64                   1032.93      4.77%
System CPU time                          73.38                     63.14     13.95%
Total  CPU time                        1158.02                   1096.07      5.35%
Elapsed    time                         307.00                    285.62      6.96%


