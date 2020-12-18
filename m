From: "Enrico Weigelt, metux IT consult" <info@metux.net>
Date: Fri, 18 Dec 2020 14:57:24 +0000
Subject: [PATCH 01/23] kernel: irq: irqdescs: warn on spurious IRQ
Message-Id: <20201218145746.24205-2-info@metux.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201218145746.24205-1-info@metux.net>
In-Reply-To: <20201218145746.24205-1-info@metux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mark.rutland@arm.com, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, catalin.marinas@arm.com, will@kernel.org, msalter@redhat.com, jacquiot.aurelien@gmail.com, gerg@linux-m68k.org, geert@linux-m68k.org, tsbogend@alpha.franken.de, James.Bottomley@HansenPartnership.com, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, bp@alien8.de, x86@kernel.org, hpa@zytor.com, linus.walleij@linaro.org, bgolaszewski@baylibre.com, maz@kernel.org, tony@atomide.com, arnd@arndb.de, linux-alpha@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-gpio@vger.kernel.org, linux-omap@vger.kernel.org, linux-arch@vger.kernel.org

Add a warning on spurious IRQs to __handle_domain_irq(), also telling the
linux IRQ number (if any), the hw IRQ number and the max nr of IRQs.

That's far more informative than the warnings in (some of) the individual
arch's ack_bad_irq()'s. These aren't really helpful since either the
other callers already had printed more detailed information or (when called
by __handle_domain_irq()) the printout just doesn't tell anything useful.

Signed-off-by: Enrico Weigelt, metux IT consult <info@metux.net>
---
 kernel/irq/irqdesc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/irq/irqdesc.c b/kernel/irq/irqdesc.c
index e810eb9906ea..62a381351775 100644
--- a/kernel/irq/irqdesc.c
+++ b/kernel/irq/irqdesc.c
@@ -681,6 +681,9 @@ int __handle_domain_irq(struct irq_domain *domain, unsigned int hwirq,
 	 * than crashing, do something sensible.
 	 */
 	if (unlikely(!irq || irq >= nr_irqs)) {
+		if (printk_ratelimit())
+			pr_warn("spurious IRQ: irq=%d hwirq=%d nr_irqs=%d\n",
+				irq, hwirq, nr_irqs);
 		ack_bad_irq(irq);
 		ret = -EINVAL;
 	} else {
-- 
2.11.0
