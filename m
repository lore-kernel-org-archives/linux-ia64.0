From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 19 Aug 2019 13:22:48 +0000
Subject: [PATCH 03/11] iommu: Use Functions to set default domain type in iommu_set_def_domain_type()
Message-Id: <20190819132256.14436-4-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190819132256.14436-1-joro@8bytes.org>
In-Reply-To: <20190819132256.14436-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

There are functions now to set the default domain type which
take care of updating other necessary state. Don't open-code
it in iommu_set_def_domain_type() and use those functions
instead.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 drivers/iommu/iommu.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index 84acd47936ac..3ee50bb22ca2 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -178,9 +178,11 @@ static int __init iommu_set_def_domain_type(char *str)
 	if (ret)
 		return ret;
 
-	iommu_set_cmd_line_dma_api();
+	if (pt)
+		iommu_set_default_passthrough(true);
+	else
+		iommu_set_default_translated(true);
 
-	iommu_def_domain_type = pt ? IOMMU_DOMAIN_IDENTITY : IOMMU_DOMAIN_DMA;
 	return 0;
 }
 early_param("iommu.passthrough", iommu_set_def_domain_type);
-- 
2.16.4
