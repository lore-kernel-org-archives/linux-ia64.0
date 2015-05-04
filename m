From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Mon, 04 May 2015 03:15:37 +0000
Subject: [RFC v1 09/11] genirq: Use helper function to access irq_data->msi_desc
Message-Id: <1430709339-29083-10-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1430709339-29083-1-git-send-email-jiang.liu@linux.intel.com>
In-Reply-To: <1430709339-29083-1-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Bjorn Helgaas <bhelgaas@google.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Randy Dunlap <rdunlap@infradead.org>, Yinghai Lu <yinghai@kernel.org>, Borislav Petkov <bp@alien8.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Chris Metcalf <cmetcalf@ezchip.com>, Jiang Liu <jiang.liu@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>, Tejun Heo <tj@kernel.org>, Joe Perches <joe@perches.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Use helper function to access irq_data->msi_desc, so we could move
msi_desc from struct irq_data into struct irq_common_data later.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/kernel/msi_ia64.c         |    2 +-
 arch/ia64/sn/kernel/msi_sn.c        |    2 +-
 arch/powerpc/sysdev/xics/ics-opal.c |    2 +-
 arch/powerpc/sysdev/xics/ics-rtas.c |    2 +-
 arch/tile/kernel/pci_gx.c           |    2 +-
 drivers/pci/msi.c                   |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 6c50d332b7d7..591b66d21bd1 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -23,7 +23,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 	if (irq_prepare_move(irq, cpu))
 		return -1;
 
-	__get_cached_msi_msg(idata->msi_desc, &msg);
+	__get_cached_msi_msg(irq_data_get_msi(idata), &msg);
 
 	addr = msg.address_lo;
 	addr &= MSI_ADDR_DEST_ID_MASK;
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index 42b5a13af142..6ccc39b36947 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -175,7 +175,7 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 	 * Release XIO resources for the old MSI PCI address
 	 */
 
-	__get_cached_msi_msg(data->msi_desc, &msg);
+	__get_cached_msi_msg(irq_data_get_msi(data), &msg);
 	sn_pdev = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	pdev = sn_pdev->pdi_linux_pcidev;
 	provider = SN_PCIDEV_BUSPROVIDER(pdev);
diff --git a/arch/powerpc/sysdev/xics/ics-opal.c b/arch/powerpc/sysdev/xics/ics-opal.c
index 3996393c254d..a709d81f885a 100644
--- a/arch/powerpc/sysdev/xics/ics-opal.c
+++ b/arch/powerpc/sysdev/xics/ics-opal.c
@@ -72,7 +72,7 @@ static unsigned int ics_opal_startup(struct irq_data *d)
 	 * card, using the MSI mask bits. Firmware doesn't appear to unmask
 	 * at that level, so we do it here by hand.
 	 */
-	if (d->msi_desc)
+	if (irq_data_get_msi(d))
 		pci_msi_unmask_irq(d);
 #endif
 
diff --git a/arch/powerpc/sysdev/xics/ics-rtas.c b/arch/powerpc/sysdev/xics/ics-rtas.c
index e2665a9dfc0f..f09a7b3136b2 100644
--- a/arch/powerpc/sysdev/xics/ics-rtas.c
+++ b/arch/powerpc/sysdev/xics/ics-rtas.c
@@ -75,7 +75,7 @@ static unsigned int ics_rtas_startup(struct irq_data *d)
 	 * card, using the MSI mask bits. Firmware doesn't appear to unmask
 	 * at that level, so we do it here by hand.
 	 */
-	if (d->msi_desc)
+	if (irq_data_get_msi(d))
 		pci_msi_unmask_irq(d);
 #endif
 	/* unmask it */
diff --git a/arch/tile/kernel/pci_gx.c b/arch/tile/kernel/pci_gx.c
index b1df847d0686..1438c60e263d 100644
--- a/arch/tile/kernel/pci_gx.c
+++ b/arch/tile/kernel/pci_gx.c
@@ -1442,7 +1442,7 @@ static struct pci_ops tile_cfg_ops = {
 /* MSI support starts here. */
 static unsigned int tilegx_msi_startup(struct irq_data *d)
 {
-	if (d->msi_desc)
+	if (irq_data_get_msi(d))
 		pci_msi_unmask_irq(d);
 
 	return 0;
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index c3e7dfcf9ff5..74b48ea0cf26 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -1178,7 +1178,7 @@ EXPORT_SYMBOL(pci_enable_msix_range);
  */
 void pci_msi_domain_write_msg(struct irq_data *irq_data, struct msi_msg *msg)
 {
-	struct msi_desc *desc = irq_data->msi_desc;
+	struct msi_desc *desc = irq_data_get_msi(irq_data);
 
 	/*
 	 * For MSI-X desc->irq is always equal to irq_data->irq. For
-- 
1.7.10.4

