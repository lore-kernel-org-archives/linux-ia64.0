From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Date: Fri, 17 Jul 2020 17:59:54 +0000
Subject: [PATCH v2 1/6] ACPI: Add out of bounds and numa_off protections to pxm_to_node
Message-Id: <20200717175959.899775-2-Jonathan.Cameron@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200717175959.899775-1-Jonathan.Cameron@huawei.com>
In-Reply-To: <20200717175959.899775-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, martin@geanix.com, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, linuxarm@huawei.com, Dan Williams <dan.j.williams@intel.com>, Song Bao Hua <song.bao.hua@hisilicon.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

The function should check the validity of the pxm value before using
it to index the pxm_to_node_map array.

Whilst hardening this code may be good in general, the main intent
here is to enable following patches that use this function to replace
acpi_map_pxm_to_node for non SRAT usecases which should return
NO_NUMA_NODE for PXM entries not matching with those in SRAT.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 drivers/acpi/numa/srat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/acpi/numa/srat.c b/drivers/acpi/numa/srat.c
index 5be5a977da1b..8ef44ee0d76b 100644
--- a/drivers/acpi/numa/srat.c
+++ b/drivers/acpi/numa/srat.c
@@ -31,7 +31,7 @@ int acpi_numa __initdata;
 
 int pxm_to_node(int pxm)
 {
-	if (pxm < 0)
+	if (pxm < 0 || pxm >= MAX_PXM_DOMAINS || numa_off)
 		return NUMA_NO_NODE;
 	return pxm_to_node_map[pxm];
 }
-- 
2.19.1
