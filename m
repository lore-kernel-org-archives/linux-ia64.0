From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 08 Aug 2003 18:39:54 +0000
Subject: Re: [PATCH] New CMC/CPE polling
Message-Id: <marc-linux-ia64-106036802216384@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105969308328993@msgid-missing>
In-Reply-To: <marc-linux-ia64-105969308328993@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 31 July 2003 5:06 pm, Alex Williamson wrote:
>    Here's a redesign of the CMC and CPE polling for both 2.6.0-test2
> and 2.4.21.  This is roughly the same design I requested comment on
> a while back (BTW, nobody commented...).  Basically, rather than
> flooding all the cpus in parallel, I used some low priority interrupts
> to cascade through the cpus.  This should be much more scalable.  I
> also added a new feature of enabling interrupts for the CMC and CPE
> handlers.  The SAL spec claims these functions are SMP safe and
> re-entrant and even recommends that the corrected error handlers
> should run with interrupts enabled.  It works on HP boxes, others
> might want to double check that their firmware adheres to the spec.
> The combination of these things should keep polling from impacting
> system response time.  I tried to keep the 2.6 and 2.4 code as similar
> as possible, so I also backported __ffs() to 2.4.  Feedback and bug
> reports welcome.  Thanks,

I applied this for 2.4.  I also applied the following patch to fix
some old comments that were slightly misleading (CMC's and CPE's
have already been "corrected"; they're not "correctable".)

#### AUTHOR bjorn.helgaas@hp.com
#### COMMENT START
### Comments for ChangeSet
ia64: Comment changes to fix "correctable" usage.
### Comments for arch/ia64/kernel/acpi.c
Fix usage ("corrected" machine checks and platform errors, not "correctable").
### Comments for include/asm-ia64/hw_irq.h
Fix usage ("corrected" machine checks and platform errors, not "correctable").
### Comments for include/asm-ia64/processor.h
Fix usage ("corrected" machine checks and platform errors, not "correctable").
#### COMMENT END

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1075  -> 1.1076 
#	include/asm-ia64/processor.h	1.22    -> 1.23   
#	include/asm-ia64/hw_irq.h	1.5     -> 1.6    
#	arch/ia64/kernel/acpi.c	1.22    -> 1.23   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/08/08	bjorn.helgaas@hp.com	1.1076
# ia64: Comment changes to fix "correctable" usage.
# --------------------------------------------
#
diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Fri Aug  8 13:33:51 2003
+++ b/arch/ia64/kernel/acpi.c	Fri Aug  8 13:33:51 2003
@@ -217,7 +217,7 @@
 	int vector = -1;
 
 	if (int_type < ACPI_MAX_PLATFORM_INTERRUPTS) {
-		/* correctable platform error interrupt */
+		/* corrected platform error interrupt */
 		vector = platform_intr_list[int_type];
 	} else
 		printk(KERN_ERR "acpi_request_vector(): invalid interrupt type\n");
diff -Nru a/include/asm-ia64/hw_irq.h b/include/asm-ia64/hw_irq.h
--- a/include/asm-ia64/hw_irq.h	Fri Aug  8 13:33:51 2003
+++ b/include/asm-ia64/hw_irq.h	Fri Aug  8 13:33:51 2003
@@ -38,9 +38,9 @@
  * Vectors 0x10-0x1f are used for low priority interrupts, e.g. CMCI.
  */
 #define IA64_CPEP_VECTOR		0x1c	/* corrected platform error polling vector */
-#define IA64_CMCP_VECTOR		0x1d	/* correctable machine-check polling vector */
+#define IA64_CMCP_VECTOR		0x1d	/* corrected machine-check polling vector */
 #define IA64_CPE_VECTOR			0x1e	/* corrected platform error interrupt vector */
-#define IA64_CMC_VECTOR			0x1f	/* correctable machine-check interrupt vector */
+#define IA64_CMC_VECTOR			0x1f	/* corrected machine-check interrupt vector */
 /*
  * Vectors 0x20-0x2f are reserved for legacy ISA IRQs.
  */
diff -Nru a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
--- a/include/asm-ia64/processor.h	Fri Aug  8 13:33:51 2003
+++ b/include/asm-ia64/processor.h	Fri Aug  8 13:33:51 2003
@@ -770,18 +770,12 @@
 #define init_task	(init_task_union.task)
 #define init_stack	(init_task_union.stack)
 
-/*
- * Set the correctable machine check vector register
- */
 static inline void
 ia64_set_cmcv (__u64 val)
 {
 	asm volatile ("mov cr.cmcv=%0" :: "r"(val) : "memory");
 }
 
-/*
- * Read the correctable machine check vector register
- */
 static inline __u64
 ia64_get_cmcv (void)
 {

