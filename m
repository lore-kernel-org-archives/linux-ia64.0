From: Samuel Holland <samuel@sholland.org>
Date: Fri, 01 Jul 2022 20:00:48 +0000
Subject: [PATCH v3 0/8] genirq: Provide real IRQ affinity masks in non-SMP configs
Message-Id: <20220701200056.46555-1-samuel@sholland.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: Samuel Holland <samuel@sholland.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, Bartosz Golaszewski <brgl@bgdev.pl>, Bjorn Helgaas <bhelgaas@google.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Broadcom internal kernel review list <bcm-kernel-feedback-list@broadcom.com>, Chris Zankel <chris@zankel.net>, Colin Ian King <colin.king@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Dexuan Cui <decui@microsoft.com>, Florian Fainelli <f.fainelli@gmail.com>, Guo Ren <guoren@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Haiyang Zhang <haiyangz@microsoft.com>, Helge Deller <deller@gmx.de>, Ingo Molnar <mingo@redhat.com>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Jan Beulich <jbeulich@suse.com>, Joerg Roedel <joro@8bytes.org>, Juergen Gross <jgross@suse.com>, Julia Lawall <Julia.Lawall@inria.fr>, "K. Y. Srinivasan" <kys@microsoft.com>, Kees Cook <keescook@chromium.org>, =?UTF-8?q?Krzysztof=20Wilczy=C5=84ski?= <kw@linux.com>, Linus Walleij <linus.walleij@linaro.org>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Max Filippov <jcmvbkbc@gmail.com>, Maximilian Heyne <mheyne@amazon.de>, Oleksandr Tyshchenko <oleksandr_tyshchenko@epam.com>, Rich Felker <dalias@libc.org>, Richard Henderson <rth@twiddle.net>, Rikard Falkeborn <rikard.falkeborn@gmail.com>, Rob Herring <robh@kernel.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Sven Schnelle <svens@stackframe.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Wei Liu <wei.liu@kernel.org>, Wei Xu <xuwei5@hisilicon.com>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, iommu@lists.linux-foundation.org, iommu@lists.linux.dev, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hyperv@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-pci@vger.kernel.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, xen-devel@lists.xenproject.org

This series solves some inconsistency with how IRQ affinity masks are
handled between SMP and non-SMP configurations.

In non-SMP configs, an IRQ's true affinity is always cpumask_of(0), so
irq_{,data_}get_affinity_mask now return that, instead of returning an
uninitialized per-IRQ cpumask. This change makes iterating over the
affinity mask do the right thing in both SMP and non-SMP configurations.

To accomplish that:
 - patches 1-3 disable some library code that was broken anyway on !SMP
 - patches 4-7 refactor the code so that irq_{,data_}get_affinity_mask
   can return a const cpumask, since that is what cpumask_of provides
 - patch 8 drops the per-IRQ cpumask and replaces it with cpumask_of(0)

This series was split from the v2 series here, which uses the new
behavior in the RISC-V PLIC irqchip driver:

https://lore.kernel.org/lkml/20220616064028.57933-1-samuel@sholland.org/

Changes in v3:
 - New patch to fix build errors in uniprocessor MIPS configs
 - New patch to drop irq_init_effective_affinity
 - New patch to introduce irq_data_update_affinity
 - New patch to make the returned cpumasks const
 - Use cpumask_of(0) instead of cpu_possible_mask

Changes in v2:
 - New patch to prevent GENERIC_IRQ_IPI from being selected on !SMP

Samuel Holland (8):
  irqchip/mips-gic: Only register IPI domain when SMP is enabled
  genirq: GENERIC_IRQ_IPI depends on SMP
  genirq: GENERIC_IRQ_EFFECTIVE_AFF_MASK depends on SMP
  genirq: Drop redundant irq_init_effective_affinity
  genirq: Refactor accessors to use irq_data_get_affinity_mask
  genirq: Add and use an irq_data_update_affinity helper
  genirq: Return a const cpumask from irq_data_get_affinity_mask
  genirq: Provide an IRQ affinity mask in non-SMP configs

 arch/alpha/kernel/irq.c              |  2 +-
 arch/arm/mach-hisi/Kconfig           |  2 +-
 arch/ia64/kernel/iosapic.c           |  2 +-
 arch/ia64/kernel/irq.c               |  4 +-
 arch/ia64/kernel/msi_ia64.c          |  4 +-
 arch/mips/cavium-octeon/octeon-irq.c |  4 +-
 arch/parisc/kernel/irq.c             |  2 +-
 arch/sh/kernel/irq.c                 |  7 +--
 arch/x86/hyperv/irqdomain.c          |  2 +-
 arch/xtensa/kernel/irq.c             |  7 +--
 drivers/iommu/hyperv-iommu.c         |  2 +-
 drivers/irqchip/Kconfig              | 19 +++----
 drivers/irqchip/irq-bcm6345-l1.c     |  4 +-
 drivers/irqchip/irq-mips-gic.c       | 80 +++++++++++++++++++---------
 drivers/parisc/iosapic.c             |  2 +-
 drivers/pci/controller/pci-hyperv.c  | 10 ++--
 drivers/sh/intc/chip.c               |  2 +-
 drivers/xen/events/events_base.c     |  7 +--
 include/linux/irq.h                  | 34 ++++++++----
 kernel/irq/Kconfig                   |  2 +
 kernel/irq/chip.c                    |  8 +--
 kernel/irq/debugfs.c                 |  2 +-
 kernel/irq/ipi.c                     | 16 +++---
 kernel/irq/manage.c                  | 10 +---
 24 files changed, 140 insertions(+), 94 deletions(-)

-- 
2.35.1
