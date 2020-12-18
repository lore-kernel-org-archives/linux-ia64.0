From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Fri, 18 Dec 2020 14:57:41 +0000
Subject: [PATCH 18/23] arch: arm64: use generic irq error counter
Message-Id: <20201218145746.24205-19-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201218145746.24205-1-info@metux.net>
In-Reply-To: <20201218145746.24205-1-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, catalin.marinas@arm.com, will@kernel.org, msalter@redhat.com, jacquiot.aurelien@gmail.com, gerg@linux-m68k.org, geert@linux-m68k.org, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, bp@alien8.de, x86@kernel.org, hpa@zytor.com, linus.walleij@linaro.org, bgolaszewski@baylibre.com, maz@kernel.org, tony@atomide.com, arnd@arndb.de, linux-alpha@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-gpio@vger.kernel.org, linux-omap@vger.kernel.org, linux-arch@vger.kernel.org

Use the newly introduced irq error counter, that's already maintained
by all callers of ack_bad_irq(), in order to remove duplicate code.

Signed-off-by: Enrico Weigelt, metux IT consult <info@metux.net>
---
 arch/arm64/include/asm/hardirq.h | 9 ++-------
 arch/arm64/kernel/smp.c          | 6 ++----
 2 files changed, 4 insertions(+), 11 deletions(-)

diff --git a/arch/arm64/include/asm/hardirq.h b/arch/arm64/include/asm/hardirq.h
index cbfa7b6f2e09..760922571084 100644
--- a/arch/arm64/include/asm/hardirq.h
+++ b/arch/arm64/include/asm/hardirq.h
@@ -13,7 +13,8 @@
 #include <asm/kvm_arm.h>
 #include <asm/sysreg.h>
 
-#define ack_bad_irq ack_bad_irq
+#define ack_bad_irq(irq)
+
 #include <asm-generic/hardirq.h>
 
 #define __ARCH_IRQ_EXIT_IRQS_DISABLED	1
@@ -85,10 +86,4 @@ do {									\
 		write_sysreg(___hcr, hcr_el2);				\
 } while (0)
 
-static inline void ack_bad_irq(unsigned int irq)
-{
-	extern unsigned long irq_err_count;
-	irq_err_count++;
-}
-
 #endif /* __ASM_HARDIRQ_H */
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index 2499b895efea..0edc565ea735 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -33,7 +33,7 @@
 #include <linux/kernel_stat.h>
 #include <linux/kexec.h>
 #include <linux/kvm_host.h>
-
+#include <asm-generic/irq-err.h>
 #include <asm/alternative.h>
 #include <asm/atomic.h>
 #include <asm/cacheflush.h>
@@ -798,8 +798,6 @@ static const char *ipi_types[NR_IPI] __tracepoint_string = {
 
 static void smp_cross_call(const struct cpumask *target, unsigned int ipinr);
 
-unsigned long irq_err_count;
-
 int arch_show_interrupts(struct seq_file *p, int prec)
 {
 	unsigned int cpu, i;
@@ -813,7 +811,7 @@ int arch_show_interrupts(struct seq_file *p, int prec)
 		seq_printf(p, "      %s\n", ipi_types[i]);
 	}
 
-	seq_printf(p, "%*s: %10lu\n", prec, "Err", irq_err_count);
+	seq_printf(p, "%*s: %10lu\n", prec, "Err", irq_err_get());
 	return 0;
 }
 
-- 
2.11.0
