From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 26 Feb 2005 00:25:16 +0000
Subject: RE: [PATCH] random ia64 sched-domains values
Message-Id: <200502260025.j1Q0PGg10838@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <421EDE70.3010501@yahoo.com.au>
In-Reply-To: <421EDE70.3010501@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nick Piggin wrote on Friday, February 25, 2005 3:42 PM
> >>These are some values I just found from thin-air that should
> >>hopefully make ia64 work after the latest sched patches.
> >>
> >>+	.cache_hot_time		= (10*1000000),		\
> >
> >
> > In 2.6.9, cache_hot_time gets the value from cache_decay_tick, since
> > when this become a constant again?
> >
>
> Not sure. cache_decay_ticks isn't set to anything meaningful on
> ia64 anyway. Nor i386 for that matter.


This parameter is known to be sensitive for one db workload.  It was
discussed about 4 month back.  The conclusion was that there is NO one
magic constant that works for every workloads on every platforms. Until
a new auto tune algorithm is written/tested, it was decided that we use
cache_decay_ticks as a boot time tunable for cache_hot_time.

I guess it somehow got lost soon after 2.6.9.  This needs to be reinstated.

Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>


--- linux-2.6.10/include/linux/topology.h	Fri Jan  7 21:44:04 2005
+++ linux-2.6.10/include/linux/topology.h	Fri Feb 25 16:02:44 2005
@@ -109,7 +109,7 @@
 	.max_interval		= 4,			\
 	.busy_factor		= 64,			\
 	.imbalance_pct		= 125,			\
-	.cache_hot_time		= (5*1000000/2),	\
+	.cache_hot_time		= cache_decay_ticks*1000000 ? : (5*1000000/2),\
 	.cache_nice_tries	= 1,			\
 	.per_cpu_gain		= 100,			\
 	.flags			= SD_LOAD_BALANCE	\


