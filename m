From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 25 Aug 2003 19:16:36 +0000
Subject: Re: [PATCH] smpboot: fix printk type warning
Message-Id: <marc-linux-ia64-106183930013686@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106161914309697@msgid-missing>
In-Reply-To: <marc-linux-ia64-106161914309697@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


 Randy> Possibly fallout from cpumask changes (?)....

Probably.  The patch looks fine to me and I'll apply it.

However, num_online_cpus() is defined in terms of cpus_weight(), which
may expand into hweight32() or hweight64().  hweight32() is declared
to return "unsigned int".  The return type for hweight64() doesn't
appear to be totally consistent.  E.g., sparc64 returns "unsigned int"
whereas everything else appears to return "unsigned long".

I suspect that, at the lest, cpumask.h should be fixed to return a
fixed type.

	--david

 Randy> patch_name:	cpus_printk.patch
 Randy> patch_version:	2003-08-22.22:22:33
 Randy> author:		Randy.Dunlap <rddunlap@osdl.org>
 Randy> description:	fix printk type warning
 Randy> product:	Linux
 Randy> product_versions: 260-test4
 Randy> diffstat:	 Randy>  arch/ia64/kernel/smpboot.c |    2 +-
 Randy>  1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naur ./arch/ia64/kernel/smpboot.c~cpus ./arch/ia64/kernel/smpboot.c
--- ./arch/ia64/kernel/smpboot.c~cpus	Fri Aug 22 16:53:14 2003
+++ ./arch/ia64/kernel/smpboot.c	Fri Aug 22 22:20:52 2003
@@ -560,7 +560,7 @@
 		if (cpu_online(cpu))
 			bogosum += cpu_data(cpu)->loops_per_jiffy;
 
-	printk(KERN_INFO "Total of %d processors activated (%lu.%02lu BogoMIPS).\n",
+	printk(KERN_INFO "Total of %lu processors activated (%lu.%02lu BogoMIPS).\n",
 	       num_online_cpus(), bogosum/(500000/HZ), (bogosum/(5000/HZ))%100);
 }
 


--
~Randy
