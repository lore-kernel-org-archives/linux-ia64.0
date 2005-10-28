From: Robin Holt <holt@sgi.com>
Date: Fri, 28 Oct 2005 20:04:24 +0000
Subject: Re: [Patch 1/1] 4-level page tables.
Message-Id: <20051028200424.GB11692@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051028200256.GA11692@attica.americas.sgi.com>
In-Reply-To: <20051028200256.GA11692@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Just wanted to post the one benchmark result I do have
so far.

2.6.14 kernel (git from linus) run kernbench with:

####################### Default 3-level page tables.
Average Half Load -j 31 Run:
Elapsed Time 81.906
User Time 1592.39
System Time 104.802
Percent CPU 2071.4
Context Switches 46444.8
Sleeps 80594

Average Optimal -j 252 Load Run:
Elapsed Time 105.266
User Time 1662.17
System Time 469.142
Percent CPU 2027
Context Switches 184595
Sleeps 547319

Average Maximal -j Load Run:
Elapsed Time 125.802
User Time 1691.75
System Time 646.408
Percent CPU 1859.6
Context Switches 167269
Sleeps 628345

####################### 4-level page tables.
Average Half Load -j 31 Run:
Elapsed Time 82.466
User Time 1589.34
System Time 106.238
Percent CPU 2055.8
Context Switches 45411.8
Sleeps 79616.8

Average Optimal -j 252 Load Run:
Elapsed Time 102.828
User Time 1669.48
System Time 455.258
Percent CPU 2075
Context Switches 178368
Sleeps 523149

Average Maximal -j Load Run:
Elapsed Time 130.212
User Time 1663.33
System Time 629.866
Percent CPU 1764
Context Switches 159147
Sleeps 651491
