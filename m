From: Alex Chiang <achiang@hp.com>
Date: Wed, 17 Sep 2008 00:25:33 +0000
Subject: Re: Kernel now broken on Ski simulator
Message-Id: <20080917002533.GD10224@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <87hc8yddun.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87hc8yddun.wl%peter@chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

* Peter Chubb <peterc@gelato.unsw.edu.au>:
> >>>>> "Alex" = Alex Chiang <achiang@hp.com> writes:
> 
> Alex> * Luck, Tony <tony.luck@intel.com>:
> >> > Until Ski is fixed to implement IPIs, you need to boot with the >
> >> force_pal_cache_flush argument to the kernel.
> >> 
> >> We could #ifndef CONFIG_IA64_HP_SIM around the test (since the
> >> simulator presumably doesn't have the SAL cache flush bug :-)
> 
> Alex> Hm, I started playing with this and turns out I started peeling
> Alex> an onion I didn't really want to touch...
> 
> Bad config file I think.  Start with make sim_defconfig and go on from
> there.

I just wrote the trivial version of the patch, that doesn't
bother compiling out the function definition, to keep the #ifdefs
to a minimum.

Odd, I would have expected the linker to optimize it out, but I
guess not...

achiang@bob:/linux/arch/ia64/kernel$ nm setup.o | grep check_sal_cache_flush
achiang@bob:/linux/arch/ia64/kernel$ nm sal.o | grep check_sal_cache_flush
00000000000000e0 T check_sal_cache_flush

Tony, this is a regression, so it seems appropriate for 2.6.27.

Thanks.

/ac

From: Alex Chiang <achiang@hp.com>
Subject: [PATCH] [IA64] Ski simulator doesn't need check_sal_cache_flush

Peter Chubb reported that commit 3463a93def55c309f3c0d0a8aaf216be3be42d64
(Update check_sal_cache_flush to use platform_send_ipi()) broke
Ski because it does not implement IPIs.

Tony Luck suggested we just #ifndef out the call, so here is a
trivial patch that does so.

Signed-off-by: Alex Chiang <achiang@hp.com>
---
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index c27d5b2..de636b2 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -616,7 +616,9 @@ setup_arch (char **cmdline_p)
 		ia64_mca_init();
 
 	platform_setup(cmdline_p);
+#ifndef CONFIG_IA64_HP_SIM
 	check_sal_cache_flush();
+#endif
 	paging_init();
 }
 
