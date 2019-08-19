From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 19 Aug 2019 13:22:49 +0000
Subject: [PATCH 04/11] iommu/amd: Request passthrough mode from IOMMU core
Message-Id: <20190819132256.14436-5-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190819132256.14436-1-joro@8bytes.org>
In-Reply-To: <20190819132256.14436-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

Get rid of the iommu_pass_through variable and request
passthrough mode via the new iommu core function.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 drivers/iommu/amd_iommu.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/iommu/amd_iommu.c b/drivers/iommu/amd_iommu.c
index b607a92791d3..7434b34d7a94 100644
--- a/drivers/iommu/amd_iommu.c
+++ b/drivers/iommu/amd_iommu.c
@@ -436,7 +436,7 @@ static int iommu_init_device(struct device *dev)
 	 * invalid address), we ignore the capability for the device so
 	 * it'll be forced to go into translation mode.
 	 */
-	if ((iommu_pass_through || !amd_iommu_force_isolation) &&
+	if ((iommu_default_passthrough() || !amd_iommu_force_isolation) &&
 	    dev_is_pci(dev) && pci_iommuv2_capable(to_pci_dev(dev))) {
 		struct amd_iommu *iommu;
 
@@ -2226,7 +2226,7 @@ static int amd_iommu_add_device(struct device *dev)
 
 	BUG_ON(!dev_data);
 
-	if (iommu_pass_through || dev_data->iommu_v2)
+	if (dev_data->iommu_v2)
 		iommu_request_dm_for_dev(dev);
 
 	/* Domains are initialized for this device - have a look what we ended up with */
@@ -2805,7 +2805,7 @@ int __init amd_iommu_init_api(void)
 
 int __init amd_iommu_init_dma_ops(void)
 {
-	swiotlb        = (iommu_pass_through || sme_me_mask) ? 1 : 0;
+	swiotlb        = (iommu_default_passthrough() || sme_me_mask) ? 1 : 0;
 	iommu_detected = 1;
 
 	if (amd_iommu_unmap_flush)
-- 
2.16.4
