From: nomura@hpc.bs1.fc.nec.co.jp
Date: Thu, 22 Nov 2001 11:36:47 +0000
Subject: [Linux-ia64] where to set rr for uncached region
Message-Id: <marc-linux-ia64-105590698805542@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

Current code sets rr for region 6 (kernel uncached region) in ia64_mmu_init().
However, thinking about application processors, there are some printk()s
before ia64_mmu_init() to be called.
Since printk() ends up in vt_console_print() and store to uncached region
will happen, I think this cause a problem.

In reality, MCAs always happen on our machine after AP prints
"CPU 1: mapping PAL code ..." to serial console. The processor log
shows that MCA happend in vt_console_print() on CPU1.

I can work around the problem by applying this patch.

I've noticed the problem when EARLY_PRINTK was deleted from config option.
So I'm curious about whether anyone has not experienced same kind of problem.


diff -u -r1.1.1.8.6.1 head.S
--- arch/ia64/kernel/head.S	2001/10/04 10:31:46	1.1.1.8.6.1
+++ arch/ia64/kernel/head.S	2001/10/05 02:18:17
@@ -111,7 +111,6 @@
 	mov ar.fpsr=r2
 	;;
 
-#ifdef CONFIG_IA64_EARLY_PRINTK
 	mov r3=(6<<8) | (KERNEL_PG_SHIFT<<2)
 	movl r2=6<<61
 	;;
@@ -119,7 +118,6 @@
 	;;
 	srlz.i
 	;;
-#endif
 
 #define isAP	p2	// are we an Application Processor?
 #define isBP	p3	// are we the Bootstrap Processor?


Best regards.
--
NOMURA, Jun'ichi <j-nomura@ce.jp.nec.com, nomura@hpc.bs1.fc.nec.co.jp>
HPC Operating System Group, 1st Computers Software Division,
Computers Software Operations Unit, NEC Solutions.

