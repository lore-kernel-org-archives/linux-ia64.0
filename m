From: Steven Rostedt <rostedt@goodmis.org>
Date: Thu, 12 Feb 2009 16:48:30 +0000
Subject: [git pull] preempt-count: force hardirq-count to max of 10
Message-Id: <alpine.DEB.1.10.0902121139230.15469@gandalf.stny.rr.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-m68k@vger.kernel.org, linux-ia64@vger.kernel.org, kernel@avr32linux.org
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, =?ISO-8859-15?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>, Tony Luck <tony.luck@intel.com>, Mike Travis <travis@sgi.com>, isimatu.yasuaki@jp.fujitsu.com


Ingo,

Please pull the latest tip/tracing/core tree, which can be found at:

  git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/linux-2.6-trace.git
tip/tracing/core


Steven Rostedt (1):
      preempt-count: force hardirq-count to max of 10

----
 arch/alpha/include/asm/hardirq.h |   13 ----------
 arch/avr32/include/asm/hardirq.h |   11 --------
 arch/ia64/include/asm/hardirq.h  |   10 --------
 include/linux/hardirq.h          |   48 +++++++++++++++++++-------------------
 4 files changed, 24 insertions(+), 58 deletions(-)
---------------------------
commit 5a5fb7dbe88dd57dc2bef0f3be9da991e789612d
Author: Steven Rostedt <srostedt@redhat.com>
Date:   Thu Feb 12 10:53:37 2009 -0500

    preempt-count: force hardirq-count to max of 10
    
    To add a bit in the preempt_count to be set when in NMI context, we
    found that some archs did not have enough bits to spare. This is
    due to the hardirq_count being a mask that can hold NR_IRQS.
    
    Some archs allow for over 16000 IRQs, and that would require a mask
    of 14 bits. The sofitrq mask is 8 bits and the preempt disable mask
    is also 8 bits.  The PREEMP_ACTIVE bit is bit 30, and bit 31 would
    make the preempt_count (which is type int) a negative number.
    A negative preempt_count is a sign of failure.
    
    Add them up 14+8+8+1+1 you get 32 bits. No room for the NMI bit.
    
    But the hardirq_count is to track the number of nested IRQs, not
    the number of total IRQs.  This originally took the paranoid approach
    of setting the max nesting to NR_IRQS. But when we have archs with
    over 1000 IRQs, it is not practical to think they will ever all
    nest on a single CPU. Not to mention that this would most definitely
    cause a stack overflow.
    
    This patch sets a max of 10 bits to be used for IRQ nesting.
    I did a 'git grep HARDIRQ' to examine all users of HARDIRQ_BITS and
    HARDIRQ_MASK, and found that making it a max of 10 would not hurt
    anyone. I did find that the m68k expected it to be 8 bits, so
    I allow for the archs to set the number to be less than 10.
    
    I removed the setting of HARDIRQ_BITS from the archs that set it
    to more than 10. This includes ALPHA, ia64 and avr32.
    
    This will always allow room for the NMI bit, and if we need to allow
    for NMI nesting, we have 4 bits to play with.
    
    Signed-off-by: Steven Rostedt <srostedt@redhat.com>

diff --git a/arch/alpha/include/asm/hardirq.h b/arch/alpha/include/asm/hardirq.h
index d953e23..8897146 100644
--- a/arch/alpha/include/asm/hardirq.h
+++ b/arch/alpha/include/asm/hardirq.h
@@ -14,17 +14,4 @@ typedef struct {
 
 void ack_bad_irq(unsigned int irq);
 
-#define HARDIRQ_BITS	12
-
-/*
- * The hardirq mask has to be large enough to have
- * space for potentially nestable IRQ sources in the system
- * to nest on a single CPU. On Alpha, interrupts are masked at the CPU
- * by IPL as well as at the system level. We only have 8 IPLs (UNIX PALcode)
- * so we really only have 8 nestable IRQs, but allow some overhead
- */
-#if (1 << HARDIRQ_BITS) < 16
-#error HARDIRQ_BITS is too low!
-#endif
-
 #endif /* _ALPHA_HARDIRQ_H */
diff --git a/arch/avr32/include/asm/hardirq.h b/arch/avr32/include/asm/hardirq.h
index 2673543..015bc75 100644
--- a/arch/avr32/include/asm/hardirq.h
+++ b/arch/avr32/include/asm/hardirq.h
@@ -20,15 +20,4 @@ void ack_bad_irq(unsigned int irq);
 
 #endif /* __ASSEMBLY__ */
 
-#define HARDIRQ_BITS	12
-
-/*
- * The hardirq mask has to be large enough to have
- * space for potentially all IRQ sources in the system
- * nesting on a single CPU:
- */
-#if (1 << HARDIRQ_BITS) < NR_IRQS
-# error HARDIRQ_BITS is too low!
-#endif
-
 #endif /* __ASM_AVR32_HARDIRQ_H */
diff --git a/arch/ia64/include/asm/hardirq.h b/arch/ia64/include/asm/hardirq.h
index 140e495..d514cd9 100644
--- a/arch/ia64/include/asm/hardirq.h
+++ b/arch/ia64/include/asm/hardirq.h
@@ -20,16 +20,6 @@
 
 #define local_softirq_pending()		(local_cpu_data->softirq_pending)
 
-#define HARDIRQ_BITS	14
-
-/*
- * The hardirq mask has to be large enough to have space for potentially all IRQ sources
- * in the system nesting on a single CPU:
- */
-#if (1 << HARDIRQ_BITS) < NR_IRQS
-# error HARDIRQ_BITS is too low!
-#endif
-
 extern void __iomem *ipi_base_addr;
 
 void ack_bad_irq(unsigned int irq);
diff --git a/include/linux/hardirq.h b/include/linux/hardirq.h
index f3cf86e..9841221 100644
--- a/include/linux/hardirq.h
+++ b/include/linux/hardirq.h
@@ -15,61 +15,61 @@
  * - bits 0-7 are the preemption count (max preemption depth: 256)
  * - bits 8-15 are the softirq count (max # of softirqs: 256)
  *
- * The hardirq count can be overridden per architecture, the default is:
+ * The hardirq count can in theory reach the same as NR_IRQS.
+ * In reality, the number of nested IRQS is limited to the stack
+ * size as well. For archs with over 1000 IRQS it is not practical
+ * to expect that they will all nest. We give a max of 10 bits for
+ * hardirq nesting. An arch may choose to give less than 10 bits.
+ * m68k expects it to be 8.
  *
- * - bits 16-27 are the hardirq count (max # of hardirqs: 4096)
- * - ( bit 28 is the PREEMPT_ACTIVE flag. )
+ * - bits 16-25 are the hardirq count (max # of nested hardirqs: 1024)
+ * - bit 26 is the NMI_MASK
+ * - bit 28 is the PREEMPT_ACTIVE flag
  *
  * PREEMPT_MASK: 0x000000ff
  * SOFTIRQ_MASK: 0x0000ff00
- * HARDIRQ_MASK: 0x0fff0000
+ * HARDIRQ_MASK: 0x03ff0000
+ *     NMI_MASK: 0x04000000
  */
 #define PREEMPT_BITS	8
 #define SOFTIRQ_BITS	8
+#define NMI_BITS	1
 
-#ifndef HARDIRQ_BITS
-#define HARDIRQ_BITS	12
+#define MAX_HARDIRQ_BITS 10
 
-#ifndef MAX_HARDIRQS_PER_CPU
-#define MAX_HARDIRQS_PER_CPU NR_IRQS
+#ifndef HARDIRQ_BITS
+# define HARDIRQ_BITS	MAX_HARDIRQ_BITS
 #endif
 
-/*
- * The hardirq mask has to be large enough to have space for potentially
- * all IRQ sources in the system nesting on a single CPU.
- */
-#if (1 << HARDIRQ_BITS) < MAX_HARDIRQS_PER_CPU
-# error HARDIRQ_BITS is too low!
-#endif
+#if HARDIRQ_BITS > MAX_HARDIRQ_BITS
+#error HARDIRQ_BITS too high!
 #endif
 
 #define PREEMPT_SHIFT	0
 #define SOFTIRQ_SHIFT	(PREEMPT_SHIFT + PREEMPT_BITS)
 #define HARDIRQ_SHIFT	(SOFTIRQ_SHIFT + SOFTIRQ_BITS)
+#define NMI_SHIFT	(HARDIRQ_SHIFT + HARDIRQ_BITS)
 
 #define __IRQ_MASK(x)	((1UL << (x))-1)
 
 #define PREEMPT_MASK	(__IRQ_MASK(PREEMPT_BITS) << PREEMPT_SHIFT)
 #define SOFTIRQ_MASK	(__IRQ_MASK(SOFTIRQ_BITS) << SOFTIRQ_SHIFT)
 #define HARDIRQ_MASK	(__IRQ_MASK(HARDIRQ_BITS) << HARDIRQ_SHIFT)
+#define NMI_MASK	(__IRQ_MASK(NMI_BITS)     << NMI_SHIFT)
 
 #define PREEMPT_OFFSET	(1UL << PREEMPT_SHIFT)
 #define SOFTIRQ_OFFSET	(1UL << SOFTIRQ_SHIFT)
 #define HARDIRQ_OFFSET	(1UL << HARDIRQ_SHIFT)
+#define NMI_OFFSET	(1UL << NMI_SHIFT)
 
-#if PREEMPT_ACTIVE < (1 << (HARDIRQ_SHIFT + HARDIRQ_BITS))
+#if PREEMPT_ACTIVE < (1 << (NMI_SHIFT + NMI_BITS))
 #error PREEMPT_ACTIVE is too low!
 #endif
 
-#define NMI_OFFSET	(PREEMPT_ACTIVE << 1)
-
-#if NMI_OFFSET >= 0x80000000
-#error PREEMPT_ACTIVE too high!
-#endif
-
 #define hardirq_count()	(preempt_count() & HARDIRQ_MASK)
 #define softirq_count()	(preempt_count() & SOFTIRQ_MASK)
-#define irq_count()	(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK))
+#define irq_count()	(preempt_count() & (HARDIRQ_MASK | SOFTIRQ_MASK \
+				 | NMI_MASK))
 
 /*
  * Are we doing bottom half or hardware interrupt processing?
@@ -82,7 +82,7 @@
 /*
  * Are we in NMI context?
  */
-#define in_nmi()	(preempt_count() & NMI_OFFSET)
+#define in_nmi()	(preempt_count() & NMI_MASK)
 
 #if defined(CONFIG_PREEMPT)
 # define PREEMPT_INATOMIC_BASE kernel_locked()

