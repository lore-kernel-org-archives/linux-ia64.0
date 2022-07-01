From: Samuel Holland <samuel@sholland.org>
Date: Fri, 01 Jul 2022 20:00:52 +0000
Subject: [PATCH v3 4/8] genirq: Drop redundant irq_init_effective_affinity
Message-Id: <20220701200056.46555-5-samuel@sholland.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220701200056.46555-1-samuel@sholland.org>
In-Reply-To: <20220701200056.46555-1-samuel@sholland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Samuel Holland <samuel@sholland.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, Bartosz Golaszewski <brgl@bgdev.pl>, Bjorn Helgaas <bhelgaas@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Broadcom internal kernel review list <bcm-kernel-feedback-list@broadcom.com>, Chris Zankel <chris@zankel.net>, Colin Ian King <colin.king@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dexuan Cui <decui@microsoft.com>, Florian Fainelli <f.fainelli@gmail.com>, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Haiyang Zhang <haiyangz@microsoft.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Jan Beulich <jbeulich@suse.com>, Joerg Roedel <joro@8bytes.org>, Juergen Gross <jgross@suse.com>, Julia Lawall <Julia.Lawall@inria.fr>, "K. Y. Srinivasan" <kys@microsoft.com>, Kees Cook <keescook@chromium.org>, =?UTF-8?q?Krzysztof=20Wilczy=C5=84ski?= <kw@linux.com>, Linus Walleij <linus.walleij@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Maximilian Heyne <mheyne@amazon.de>, Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Rikard Falkeborn <rikard.falkeborn@gmail.com>, Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Sven Schnelle <svens@stackframe.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Wei Liu <wei.liu@kernel.org>, Wei Xu <xuwei5@hisilicon.com>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, iommu@lists.linux-foundation.org, iommu@lists.linux.dev, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hyperv@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-pci@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, xen-devel@lists.xenproject.org

It does exactly the same thing as irq_data_update_effective_affinity.

Signed-off-by: Samuel Holland <samuel@sholland.org>
---

Changes in v3:
 - New patch to drop irq_init_effective_affinity

 kernel/irq/manage.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index 8c396319d5ac..40fe7806cc8c 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -205,16 +205,8 @@ static void irq_validate_effective_affinity(struct irq_data *data)
 	pr_warn_once("irq_chip %s did not update eff. affinity mask of irq %u\n",
 		     chip->name, data->irq);
 }
-
-static inline void irq_init_effective_affinity(struct irq_data *data,
-					       const struct cpumask *mask)
-{
-	cpumask_copy(irq_data_get_effective_affinity_mask(data), mask);
-}
 #else
 static inline void irq_validate_effective_affinity(struct irq_data *data) { }
-static inline void irq_init_effective_affinity(struct irq_data *data,
-					       const struct cpumask *mask) { }
 #endif
 
 int irq_do_set_affinity(struct irq_data *data, const struct cpumask *mask,
@@ -347,7 +339,7 @@ static bool irq_set_affinity_deactivated(struct irq_data *data,
 		return false;
 
 	cpumask_copy(desc->irq_common_data.affinity, mask);
-	irq_init_effective_affinity(data, mask);
+	irq_data_update_effective_affinity(data, mask);
 	irqd_set(data, IRQD_AFFINITY_SET);
 	return true;
 }
-- 
2.35.1
