From: Martin Hicks <mort@wildopensource.com>
Date: Thu, 20 Mar 2003 19:03:57 +0000
Subject: [Linux-ia64] [patch] logical CPU numbering
Message-Id: <marc-linux-ia64-105590723705277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

If a CPU fails to start during smp_boot_cpus(), then the logical CPU
numbering gets will have a "hole".  Using the number of booted CPU's
instead of the loop index will correct this.

This patch is against 2.4.21-pre5.

thanks,
mh

-- 
Wild Open Source Inc.                  mort@wildopensource.com



--- linux-2.4.21-pre5-ia64-030312.pristine/arch/ia64/kernel/smpboot.c	Sun Mar 16 10:18:53 2003
+++ linux-2.4.21-pre5-ia64-030312/arch/ia64/kernel/smpboot.c	Thu Mar 20 10:47:07 2003
@@ -522,7 +522,7 @@
 			/*
 			 * Make sure we unmap all failed CPUs
 			 */
-			if (ia64_cpu_to_sapicid[cpu] = -1)
+			if (ia64_cpu_to_sapicid[cpucount] = -1)
 				printk("phys CPU#%d not responding - cannot use it.\n", cpu);
 		}
 

