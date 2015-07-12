From: Bjorn Helgaas <bhelgaas@google.com>
Date: Sun, 12 Jul 2015 22:02:11 +0000
Subject: [PATCH 3/3] IRQ: Print "unexpected IRQ" messages consistently across architectures
Message-Id: <20150712220211.7166.42035.stgit@bhelgaas-glaptop2.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
In-Reply-To: <20150712215559.7166.33068.stgit@bhelgaas-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-arch@vger.kernel.org, linux-mips@linux-mips.org, linux-am33-list@redhat.com, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-parisc@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, adi-buildroot-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-alpha@vger.kernel.org, x86@kernel.org, linuxppc-dev@lists.ozlabs.org

Many architectures use a variant of "unexpected IRQ trap at vector %x" to
log unexpected IRQs.  This is confusing because (a) it prints the Linux IRQ
number, but "vector" more often refers to a CPU vector number, and (b) it
prints the IRQ number in hex with no base indication, while Linux IRQ
numbers are usually printed in decimal.

Print the same text ("unexpected IRQ %d") across all architectures.

No functional change other than the output text.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/alpha/kernel/irq.c            |    2 +-
 arch/blackfin/kernel/irqchip.c     |    2 +-
 arch/c6x/kernel/irq.c              |    2 +-
 arch/ia64/kernel/irq.c             |    2 +-
 arch/m68k/include/asm/hardirq.h    |    2 +-
 arch/mips/kernel/irq.c             |    2 +-
 arch/mn10300/kernel/irq.c          |    2 +-
 arch/parisc/include/asm/hardirq.h  |    2 +-
 arch/powerpc/include/asm/hardirq.h |    2 +-
 arch/s390/include/asm/hardirq.h    |    2 +-
 arch/sh/kernel/irq.c               |    2 +-
 arch/tile/kernel/irq.c             |    2 +-
 arch/x86/kernel/irq.c              |    2 +-
 include/asm-generic/hardirq.h      |    2 +-
 14 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/arch/alpha/kernel/irq.c b/arch/alpha/kernel/irq.c
index 51f2c86..9acdc14 100644
--- a/arch/alpha/kernel/irq.c
+++ b/arch/alpha/kernel/irq.c
@@ -34,7 +34,7 @@ DEFINE_PER_CPU(unsigned long, irq_pmi_count);
 void ack_bad_irq(unsigned int irq)
 {
 	irq_err_count++;
-	printk(KERN_CRIT "Unexpected IRQ trap at vector %u\n", irq);
+	printk(KERN_CRIT "Unexpected IRQ %d\n", irq);
 }
 
 #ifdef CONFIG_SMP 
diff --git a/arch/blackfin/kernel/irqchip.c b/arch/blackfin/kernel/irqchip.c
index 0ba2576..608741e 100644
--- a/arch/blackfin/kernel/irqchip.c
+++ b/arch/blackfin/kernel/irqchip.c
@@ -20,7 +20,7 @@ static atomic_t irq_err_count;
 void ack_bad_irq(unsigned int irq)
 {
 	atomic_inc(&irq_err_count);
-	printk(KERN_ERR "IRQ: spurious interrupt %d\n", irq);
+	printk(KERN_ERR "unexpected IRQ %d\n", irq);
 }
 
 static struct irq_desc bad_irq_desc = {
diff --git a/arch/c6x/kernel/irq.c b/arch/c6x/kernel/irq.c
index 247e0eb..cd7fb55 100644
--- a/arch/c6x/kernel/irq.c
+++ b/arch/c6x/kernel/irq.c
@@ -120,7 +120,7 @@ void __init init_IRQ(void)
 
 void ack_bad_irq(int irq)
 {
-	printk(KERN_ERR "IRQ: spurious interrupt %d\n", irq);
+	printk(KERN_ERR "unexpected IRQ %d\n", irq);
 	irq_err_count++;
 }
 
diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index 812a1e6..b198c69 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -31,7 +31,7 @@
  */
 void ack_bad_irq(unsigned int irq)
 {
-	printk(KERN_ERR "Unexpected irq vector 0x%x on CPU %u!\n", irq, smp_processor_id());
+	printk(KERN_ERR "unexpected IRQ %d on CPU %u!\n", irq, smp_processor_id());
 }
 
 #ifdef CONFIG_IA64_GENERIC
diff --git a/arch/m68k/include/asm/hardirq.h b/arch/m68k/include/asm/hardirq.h
index 6c61852..5f0fe98 100644
--- a/arch/m68k/include/asm/hardirq.h
+++ b/arch/m68k/include/asm/hardirq.h
@@ -9,7 +9,7 @@
 
 static inline void ack_bad_irq(unsigned int irq)
 {
-	pr_crit("unexpected IRQ trap at vector %02x\n", irq);
+	pr_crit("unexpected IRQ %d\n", irq);
 }
 
 /* entry.S is sensitive to the offsets of these fields */
diff --git a/arch/mips/kernel/irq.c b/arch/mips/kernel/irq.c
index 8eb5af8..f6b9ce9 100644
--- a/arch/mips/kernel/irq.c
+++ b/arch/mips/kernel/irq.c
@@ -31,7 +31,7 @@
  */
 void ack_bad_irq(unsigned int irq)
 {
-	printk("unexpected IRQ # %d\n", irq);
+	printk("unexpected IRQ %d\n", irq);
 }
 
 atomic_t irq_err_count;
diff --git a/arch/mn10300/kernel/irq.c b/arch/mn10300/kernel/irq.c
index 480de70..c7b780d 100644
--- a/arch/mn10300/kernel/irq.c
+++ b/arch/mn10300/kernel/irq.c
@@ -197,7 +197,7 @@ static struct irq_chip mn10300_cpu_pic_edge = {
  */
 void ack_bad_irq(int irq)
 {
-	printk(KERN_WARNING "unexpected IRQ trap at vector %02x\n", irq);
+	printk(KERN_WARNING "unexpected IRQ %d\n", irq);
 }
 
 /*
diff --git a/arch/parisc/include/asm/hardirq.h b/arch/parisc/include/asm/hardirq.h
index 9b3bd03..c093c4f 100644
--- a/arch/parisc/include/asm/hardirq.h
+++ b/arch/parisc/include/asm/hardirq.h
@@ -41,6 +41,6 @@ DECLARE_PER_CPU_SHARED_ALIGNED(irq_cpustat_t, irq_stat);
 		this_cpu_write(irq_stat.__softirq_pending, (x))
 #define or_softirq_pending(x)	this_cpu_or(irq_stat.__softirq_pending, (x))
 
-#define ack_bad_irq(irq) WARN(1, "unexpected IRQ trap at vector %02x\n", irq)
+#define ack_bad_irq(irq) WARN(1, "unexpected IRQ %d\n", irq)
 
 #endif /* _PARISC_HARDIRQ_H */
diff --git a/arch/powerpc/include/asm/hardirq.h b/arch/powerpc/include/asm/hardirq.h
index 8add8b8..aa8ebbb 100644
--- a/arch/powerpc/include/asm/hardirq.h
+++ b/arch/powerpc/include/asm/hardirq.h
@@ -30,7 +30,7 @@ DECLARE_PER_CPU_SHARED_ALIGNED(irq_cpustat_t, irq_stat);
 
 static inline void ack_bad_irq(unsigned int irq)
 {
-	printk(KERN_CRIT "unexpected IRQ trap at vector %02x\n", irq);
+	printk(KERN_CRIT "unexpected IRQ %d\n", irq);
 }
 
 extern u64 arch_irq_stat_cpu(unsigned int cpu);
diff --git a/arch/s390/include/asm/hardirq.h b/arch/s390/include/asm/hardirq.h
index b7eabaa..08eeacd 100644
--- a/arch/s390/include/asm/hardirq.h
+++ b/arch/s390/include/asm/hardirq.h
@@ -20,7 +20,7 @@
 
 static inline void ack_bad_irq(unsigned int irq)
 {
-	printk(KERN_CRIT "unexpected IRQ trap at vector %02x\n", irq);
+	printk(KERN_CRIT "unexpected IRQ %d\n", irq);
 }
 
 #endif /* __ASM_HARDIRQ_H */
diff --git a/arch/sh/kernel/irq.c b/arch/sh/kernel/irq.c
index eb10ff8..093e434 100644
--- a/arch/sh/kernel/irq.c
+++ b/arch/sh/kernel/irq.c
@@ -30,7 +30,7 @@ atomic_t irq_err_count;
 void ack_bad_irq(unsigned int irq)
 {
 	atomic_inc(&irq_err_count);
-	printk("unexpected IRQ trap at vector %02x\n", irq);
+	printk("unexpected IRQ %d\n", irq);
 }
 
 #if defined(CONFIG_PROC_FS)
diff --git a/arch/tile/kernel/irq.c b/arch/tile/kernel/irq.c
index 22044fc..c8e4f88 100644
--- a/arch/tile/kernel/irq.c
+++ b/arch/tile/kernel/irq.c
@@ -250,7 +250,7 @@ EXPORT_SYMBOL(tile_irq_activate);
 
 void ack_bad_irq(unsigned int irq)
 {
-	pr_err("unexpected IRQ trap at vector %02x\n", irq);
+	pr_err("unexpected IRQ %d\n", irq);
 }
 
 /*
diff --git a/arch/x86/kernel/irq.c b/arch/x86/kernel/irq.c
index 3c6b069..a0d46d2 100644
--- a/arch/x86/kernel/irq.c
+++ b/arch/x86/kernel/irq.c
@@ -40,7 +40,7 @@ void (*x86_platform_ipi_callback)(void) = NULL;
 void ack_bad_irq(unsigned int irq)
 {
 	if (printk_ratelimit())
-		pr_err("unexpected IRQ trap at vector %02x\n", irq);
+		pr_err("unexpected IRQ %d\n", irq);
 
 	/*
 	 * Currently unexpected vectors happen only on SMP and APIC.
diff --git a/include/asm-generic/hardirq.h b/include/asm-generic/hardirq.h
index 04d0a97..516ff5f 100644
--- a/include/asm-generic/hardirq.h
+++ b/include/asm-generic/hardirq.h
@@ -14,7 +14,7 @@ typedef struct {
 #ifndef ack_bad_irq
 static inline void ack_bad_irq(unsigned int irq)
 {
-	printk(KERN_CRIT "unexpected IRQ trap at vector %02x\n", irq);
+	printk(KERN_CRIT "unexpected IRQ %d\n", irq);
 }
 #endif
 

