From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Date: Tue, 18 Aug 2020 14:24:27 +0000
Subject: [PATCH v3 3/6] ACPI: Remove side effect of partly creating a node in acpi_map_pxm_to_online_node
Message-Id: <20200818142430.1156547-4-Jonathan.Cameron@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200818142430.1156547-1-Jonathan.Cameron@huawei.com>
In-Reply-To: <20200818142430.1156547-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, martin@geanix.com, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, linuxarm@huawei.com, Dan Williams <dan.j.williams@intel.com>, Song Bao Hua <song.bao.hua@hisilicon.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

Whilst this function will only return an online node, it can have the side
effect of partially creating a new node.  The existing comments suggest this
is intentional, but the usecases of this function are related to NFIT and
HMAT parsing, neither of which should be able to define new nodes.

One route by which the existing behaviour would cause a crash is to have a
_PXM entry in ACPI DSDT attempt to place a device within this partly
created proximity domain. A subsequent call to devm_kzalloc or similar
would result in an attempt to allocate memory on a node for which zone
lists have not been set up and a null pointer dereference.

We prevent such cases by switching to pxm_to_node() within
acpi_map_pxm_to_online_node which cannot cause a new node to be partly
created. If one would previously have been created we now return
NO_NUMA_NODE.  Documentation updated to reflect this change.
We may want to think about renaming acpi_map_pxm_to_online_node to
pxm_to_online_node to reflect this change.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Reviewed-by: Hanjun Guo <guohanjun@huawei.com>
---
 include/linux/acpi.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index 1e4cdc6c7ae2..a9fd122ae878 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -430,13 +430,12 @@ int acpi_get_node(acpi_handle handle);
  * ACPI device drivers, which are called after the NUMA initialization has
  * completed in the kernel, can call this interface to obtain their device
  * NUMA topology from ACPI tables.  Such drivers do not have to deal with
- * offline nodes.  A node may be offline when a device proximity ID is
- * unique, SRAT memory entry does not exist, or NUMA is disabled, ex.
- * "numa=off" on x86.
+ * offline nodes.  A node may be offline when SRAT memory entry does not exist,
+ * or NUMA is disabled, ex. "numa=off" on x86.
  */
 static inline int acpi_map_pxm_to_online_node(int pxm)
 {
-	int node = acpi_map_pxm_to_node(pxm);
+	int node = pxm_to_node(pxm);
 
 	return numa_map_to_online_node(node);
 }
-- 
2.19.1
