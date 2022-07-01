From: Samuel Holland <samuel@sholland.org>
Date: Fri, 01 Jul 2022 20:00:50 +0000
Subject: [PATCH v3 2/8] genirq: GENERIC_IRQ_IPI depends on SMP
Message-Id: <20220701200056.46555-3-samuel@sholland.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220701200056.46555-1-samuel@sholland.org>
In-Reply-To: <20220701200056.46555-1-samuel@sholland.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Samuel Holland <samuel@sholland.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, Bartosz Golaszewski <brgl@bgdev.pl>, Bjorn Helgaas <bhelgaas@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Broadcom internal kernel review list <bcm-kernel-feedback-list@broadcom.com>, Chris Zankel <chris@zankel.net>, Colin Ian King <colin.king@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dexuan Cui <decui@microsoft.com>, Florian Fainelli <f.fainelli@gmail.com>, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Haiyang Zhang <haiyangz@microsoft.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Jan Beulich <jbeulich@suse.com>, Joerg Roedel <joro@8bytes.org>, Juergen Gross <jgross@suse.com>, Julia Lawall <Julia.Lawall@inria.fr>, "K. Y. Srinivasan" <kys@microsoft.com>, Kees Cook <keescook@chromium.org>, =?UTF-8?q?Krzysztof=20Wilczy=C5=84ski?= <kw@linux.com>, Linus Walleij <linus.walleij@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Maximilian Heyne <mheyne@amazon.de>, Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Rikard Falkeborn <rikard.falkeborn@gmail.com>, Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Sven Schnelle <svens@stackframe.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Wei Liu <wei.liu@kernel.org>, Wei Xu <xuwei5@hisilicon.com>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, iommu@lists.linux-foundation.org, iommu@lists.linux.dev, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hyperv@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-pci@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, xen-devel@lists.xenproject.org, kernel test robot <lkp@intel.com>

The generic IPI code depends on the IRQ affinity mask being allocated
and initialized. This will not be the case if SMP is disabled. Fix up
the remaining driver that selected GENERIC_IRQ_IPI in a non-SMP config.

Reported-by: kernel test robot <lkp@intel.com>
Signed-off-by: Samuel Holland <samuel@sholland.org>
---

(no changes since v2)

Changes in v2:
 - New patch to prevent GENERIC_IRQ_IPI from being selected on !SMP

 drivers/irqchip/Kconfig | 2 +-
 kernel/irq/Kconfig      | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/irqchip/Kconfig b/drivers/irqchip/Kconfig
index d26a4ff7c99f..5dd98a81efc8 100644
--- a/drivers/irqchip/Kconfig
+++ b/drivers/irqchip/Kconfig
@@ -177,7 +177,7 @@ config MADERA_IRQ
 config IRQ_MIPS_CPU
 	bool
 	select GENERIC_IRQ_CHIP
-	select GENERIC_IRQ_IPI if SYS_SUPPORTS_MULTITHREADING
+	select GENERIC_IRQ_IPI if SMP && SYS_SUPPORTS_MULTITHREADING
 	select IRQ_DOMAIN
 	select GENERIC_IRQ_EFFECTIVE_AFF_MASK
 
diff --git a/kernel/irq/Kconfig b/kernel/irq/Kconfig
index 10929eda9825..fc760d064a65 100644
--- a/kernel/irq/Kconfig
+++ b/kernel/irq/Kconfig
@@ -82,6 +82,7 @@ config IRQ_FASTEOI_HIERARCHY_HANDLERS
 # Generic IRQ IPI support
 config GENERIC_IRQ_IPI
 	bool
+	depends on SMP
 	select IRQ_DOMAIN_HIERARCHY
 
 # Generic MSI interrupt support
-- 
2.35.1
