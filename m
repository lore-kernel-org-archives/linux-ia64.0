From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Sat, 23 Aug 2003 06:07:17 +0000
Subject: [PATCH] smpboot: fix printk type warning
Message-Id: <marc-linux-ia64-106161914309697@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Possibly fallout from cpumask changes (?)....


patch_name:	cpus_printk.patch
patch_version:	2003-08-22.22:22:33
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	fix printk type warning
product:	Linux
product_versions: 260-test4
diffstat:	 arch/ia64/kernel/smpboot.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

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
