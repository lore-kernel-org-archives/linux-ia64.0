From: Yijing Wang <wangyijing@huawei.com>
Date: Fri, 15 Aug 2014 02:49:15 +0000
Subject: [PATCH 1/3] MSI: Use __get_cached_msi_msg() instead of get_cached_msi_msg()
Message-Id: <1408072461-9914-1-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, linux-ia64@vger.kernel.org

Get_cached_msi_msg() only be called in two places,
ia64_set_msi_irq_affinity() and sn_set_msi_irq_affinity().

The code flow is:
irq = irq_data->irq
    get_cached_msi_msg(irq)
	    irq_get_msi_desc(irq)
		    irq_get_irq_data(irq)
			    msi_desc = irq_data->desc
        __get_cached_msi_msg(msi_desc, msg)

This is crazy, we can use __get_cached_msi_msg(irq_data->desc, msg)
directly to simplify the flow. Now no one use get_cached_msi_msg(),
let's remove it. Then we rename __get_cached_msi_msg() to
get_cached_msi_msg().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Thomas Gleixner <tglx@linutronix.de>
CC: x86@kernel.org
CC: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/msi_ia64.c    |    2 +-
 arch/ia64/sn/kernel/msi_sn.c   |    4 ++--
 arch/x86/kernel/apic/io_apic.c |    2 +-
 drivers/pci/msi.c              |    9 +--------
 include/linux/msi.h            |    3 +--
 5 files changed, 6 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index c430f91..4efe748 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -23,7 +23,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 	if (irq_prepare_move(irq, cpu))
 		return -1;
 
-	get_cached_msi_msg(irq, &msg);
+	get_cached_msi_msg(idata->msi_desc, &msg);
 
 	addr = msg.address_lo;
 	addr &= MSI_ADDR_DEST_ID_MASK;
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index afc58d2..8bec242 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -175,8 +175,8 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 	 * Release XIO resources for the old MSI PCI address
 	 */
 
-	get_cached_msi_msg(irq, &msg);
-        sn_pdev = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
+	get_cached_msi_msg(data->msi_desc, &msg);
+	sn_pdev = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	pdev = sn_pdev->pdi_linux_pcidev;
 	provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index 81e08ef..a1b34f6 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -3007,7 +3007,7 @@ msi_set_affinity(struct irq_data *data, const struct cpumask *mask, bool force)
 	if (ret)
 		return ret;
 
-	__get_cached_msi_msg(data->msi_desc, &msg);
+	get_cached_msi_msg(data->msi_desc, &msg);
 
 	msg.data &= ~MSI_DATA_VECTOR_MASK;
 	msg.data |= MSI_DATA_VECTOR(cfg->vector);
diff --git a/drivers/pci/msi.c b/drivers/pci/msi.c
index 5a40516..988224f 100644
--- a/drivers/pci/msi.c
+++ b/drivers/pci/msi.c
@@ -296,7 +296,7 @@ void read_msi_msg(unsigned int irq, struct msi_msg *msg)
 	__read_msi_msg(entry, msg);
 }
 
-void __get_cached_msi_msg(struct msi_desc *entry, struct msi_msg *msg)
+void get_cached_msi_msg(struct msi_desc *entry, struct msi_msg *msg)
 {
 	/* Assert that the cache is valid, assuming that
 	 * valid messages are not all-zeroes. */
@@ -306,13 +306,6 @@ void __get_cached_msi_msg(struct msi_desc *entry, struct msi_msg *msg)
 	*msg = entry->msg;
 }
 
-void get_cached_msi_msg(unsigned int irq, struct msi_msg *msg)
-{
-	struct msi_desc *entry = irq_get_msi_desc(irq);
-
-	__get_cached_msi_msg(entry, msg);
-}
-
 void __write_msi_msg(struct msi_desc *entry, struct msi_msg *msg)
 {
 	if (entry->dev->current_state != PCI_D0) {
diff --git a/include/linux/msi.h b/include/linux/msi.h
index 8103f32..e3adf93 100644
--- a/include/linux/msi.h
+++ b/include/linux/msi.h
@@ -16,10 +16,9 @@ struct msi_desc;
 void mask_msi_irq(struct irq_data *data);
 void unmask_msi_irq(struct irq_data *data);
 void __read_msi_msg(struct msi_desc *entry, struct msi_msg *msg);
-void __get_cached_msi_msg(struct msi_desc *entry, struct msi_msg *msg);
+void get_cached_msi_msg(struct msi_desc *entry, struct msi_msg *msg);
 void __write_msi_msg(struct msi_desc *entry, struct msi_msg *msg);
 void read_msi_msg(unsigned int irq, struct msi_msg *msg);
-void get_cached_msi_msg(unsigned int irq, struct msi_msg *msg);
 void write_msi_msg(unsigned int irq, struct msi_msg *msg);
 
 struct msi_desc {
-- 
1.7.1

