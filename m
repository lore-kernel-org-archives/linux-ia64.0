From: Andreas Dilger <adilger@clusterfs.com>
Date: Mon, 22 Sep 2003 22:21:14 +0000
Subject: Re: adilger_irq patch
Message-Id: <marc-linux-ia64-106426969402495@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
below is a patch that we have been running on ia64 for several months now.
It makes the IRQ stack overflow checking a bit more robust, and also adds
a config option to be consistent with i386.

One important change is that stack overflow messages to the console are
rate limited, because without it if you ever hit this your console will
continually spew messages as the console output is slower than the IRQ
rate and you will continue to be over the stack limit forever.  This
causes the machine to effectively lock up without the rate limiting.

The stack overflow margin is increased slightly for larger stack sizes,
because we probably shouldn't be getting so close to the end of a larger
64kB stack either.  Not really critical, we never run with 64kB stacks.

--- ./arch/ia64/config.in.orig	Wed Feb 26 13:17:02 2003
+++ ./arch/ia64/config.in	Wed Mar 12 17:24:27 2003
@@ -280,6 +280,7 @@ if [ "$CONFIG_DEBUG_KERNEL" != "n" ]; th
       fi
       bool '    Early printk on VGA' CONFIG_IA64_EARLY_PRINTK_VGA
    fi
+   bool '  Check for stack overflows' CONFIG_DEBUG_STACKOVERFLOW
    bool '  Debug memory allocations' CONFIG_DEBUG_SLAB
    bool '  Spinlock debugging' CONFIG_DEBUG_SPINLOCK
    bool '  Turn on compare-and-exchange bug checking (slow!)' CONFIG_IA64_DEBUG_CMPXCHG
--- ./arch/ia64/kernel/irq_ia64.c.orig	Wed Feb 26 13:17:02 2003
+++ ./arch/ia64/kernel/irq_ia64.c	Wed Mar 12 17:23:19 2003
@@ -40,8 +40,6 @@
 # include <asm/perfmon.h>
 #endif
 
-#define IRQ_DEBUG	0
-
 /* default base addr of IPI table */
 unsigned long ipi_base_addr = (__IA64_UNCACHED_OFFSET | IA64_IPI_DEFAULT_BASE_ADDR);
 
@@ -82,7 +80,7 @@ ia64_handle_irq (ia64_vector vector, str
 #	define IS_RESCHEDULE(vec)	(0)
 #endif
 
-#if IRQ_DEBUG
+#ifdef CONFIG_DEBUG_STACKOVERFLOW
 	{
 		unsigned long bsp, sp;
 
@@ -96,21 +94,25 @@ ia64_handle_irq (ia64_vector vector, str
 		asm ("mov %0=ar.bsp" : "=r"(bsp));
 		asm ("mov %0=sp" : "=r"(sp));
 
-		if ((sp - bsp) < 1024) {
+		if (unlikely((sp - bsp) <
+			     1024 + (IA64_STK_OFFSET > 32768 ? 8192 : 0))) {
 			static unsigned char count;
-			static long last_time;
+			static long next_time;
 
-			if (jiffies - last_time > 5*HZ)
+			if (time_after(jiffies, next_time))
 				count = 0;
 			if (++count < 5) {
-				last_time = jiffies;
-				printk("ia64_handle_irq: DANGER: less than "
-				       "1KB of free stack space!!\n"
-				       "(bsp=0x%lx, sp=%lx)\n", bsp, sp);
+				next_time = jiffies + 5*HZ;
+				printk(KERN_ERR "%s: DANGER: %s has %lu bytes "
+				       "stack left! sp=%#lx bsp=%#lx\n",
+				       __FUNCTION__, current->comm,
+				       sp - bsp, sp, bsp);
+				//show_regs(regs);
+				show_stack(0);
 			}
 		}
 	}
-#endif /* IRQ_DEBUG */
+#endif /* CONFIG_DEBUG_STACKOVERFLOW */
 
 	/*
 	 * Always set TPR to limit maximum interrupt nesting depth to


Cheers, Andreas
--
Andreas Dilger
http://sourceforge.net/projects/ext2resize/
http://www-mddsp.enel.ucalgary.ca/People/adilger/

