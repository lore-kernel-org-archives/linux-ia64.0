From: Jack Steiner <steiner@sgi.com>
Date: Mon, 06 Dec 2004 19:32:32 +0000
Subject: [PATCH] - Cacheline align jiffies_64
Message-Id: <20041206193232.GA14994@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Is there any reason jiffies_64 should not be cacheline aligned?


On large systems, system overhead on cpu 0 is higher than on other
cpus. On a completely idle 512p system, the average amount of system time 
on cpu 0 is 2.4%  and .15% on cpu 1-511.

A second interesting data point is that if I run a busy-loop
program on cpus 1-511, the system overhead on cpu 0 drops 
significantly.


I moved the timekeeper to cpu 1. The excessive system time moved
to cpu 1 and the system time on cpu 0 dropped to .2%.



Further investigation showed that the problem was caused by false
sharing of the cacheline containing jiffies_64. On the kernel that
I was running, both jiffies_64 & pal_halt share the same cacheline.
Idle cpus are frequently accessing pal_halt. Minor kernel
changes (including some of the debugging code that I used to find the 
problem :-(  ) can cause variables to move & change the false sharing - the
symptoms of the problem can change or disappear.

The following shows system time on cpus 0-3 before & after the fix:

	OLD
		0.23   2.71   0.15   0.15
	
	ALIGNED
		0.22   0.75   0.16   0.15




Signed-off-by: Jack Steiner <steiner@sgi.com>

Cachealign jiffies_64 to prevent unexpected aliasing in the caches.



Index: linux/arch/ia64/kernel/time.c
=================================--- linux.orig/arch/ia64/kernel/time.c	2004-11-30 20:30:11.000000000 -0600
+++ linux/arch/ia64/kernel/time.c	2004-12-06 13:17:45.170451297 -0600
@@ -32,7 +32,7 @@
 
 extern unsigned long wall_jiffies;
 
-u64 jiffies_64 = INITIAL_JIFFIES;
+u64 jiffies_64 __cacheline_aligned_in_smp = INITIAL_JIFFIES;
 
 EXPORT_SYMBOL(jiffies_64);
 






-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


