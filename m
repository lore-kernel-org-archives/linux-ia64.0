From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 23 Sep 2014 05:27:25 +0000
Subject: [PATCH v3 4/9] MSI: Use __get_cached_msi_msg() instead of get_cached_msi_msg()
Message-Id: <1411450050-1510-5-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1411450050-1510-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1411450050-1510-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, Yijing Wang <wangyijing@huawei.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Get_cached_msi_msg() only be called in two places,
ia64_set_msi_irq_affinity() and sn_set_msi_irq_affinity().

The code flow is:
irq = irq_data->irq
    get_cached_msi_msg(irq)
	    irq_get_msi_desc(irq)
		    irq_get_irq_data(irq)
			    msi_desc = irq_data->desc
        __get_cached_msi_msg(msi_desc, msg)

This is crazy, we should use __get_cached_msi_msg(irq_data->desc, msg)
directly to simplify the flow.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Tony Luck <tony.luck@intel.com>
CC: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/msi_ia64.c  |    2 +-
 arch/ia64/sn/kernel/msi_sn.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index c430f91..8c3730c 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -23,7 +23,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 	if (irq_prepare_move(irq, cpu))
 		return -1;
 
-	get_cached_msi_msg(irq, &msg);
+	__get_cached_msi_msg(idata->msi_desc, &msg);
 
 	addr = msg.address_lo;
 	addr &= MSI_ADDR_DEST_ID_MASK;
diff --git a/arch/ia64/sn/kernel/msi_sn.c b/arch/ia64/sn/kernel/msi_sn.c
index afc58d2..446e779 100644
--- a/arch/ia64/sn/kernel/msi_sn.c
+++ b/arch/ia64/sn/kernel/msi_sn.c
@@ -175,8 +175,8 @@ static int sn_set_msi_irq_affinity(struct irq_data *data,
 	 * Release XIO resources for the old MSI PCI address
 	 */
 
-	get_cached_msi_msg(irq, &msg);
-        sn_pdev = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
+	__get_cached_msi_msg(data->msi_desc, &msg);
+	sn_pdev = (struct pcidev_info *)sn_irq_info->irq_pciioinfo;
 	pdev = sn_pdev->pdi_linux_pcidev;
 	provider = SN_PCIDEV_BUSPROVIDER(pdev);
 
-- 
1.7.1

