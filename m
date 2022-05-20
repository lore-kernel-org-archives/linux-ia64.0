From: Peng Liu <liupeng256@huawei.com>
Date: Fri, 20 May 2022 07:37:46 +0000
Subject: [PATCH v2 1/2] numa: create node_available() helper
Message-Id: <20220520073747.1184091-2-liupeng256@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220520073747.1184091-1-liupeng256@huawei.com>
In-Reply-To: <20220520073747.1184091-1-liupeng256@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bhelgaas@google.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, lorenzo.pieralisi@arm.com, guohanjun@huawei.com, sudeep.holla@arm.com, rafael@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, logang@deltatee.com, martin.oliveira@eideticom.com, thunder.leizhen@huawei.com, axboe@kernel.dk, kch@nvidia.com, ming.lei@redhat.com, shinichiro.kawasaki@wdc.com, mcgrof@kernel.org, jiangguoqing@kylinos.cn, jpittman@redhat.com, dave@stgolabs.net, liupeng256@huawei.com, wangkefeng.wang@huawei.com, linux-block@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Lots of code does
	node != NUMA_NO_NODE && !node_online(node)
or
	node = NUMA_NO_NODE || node_online(node)
so create node_available() to do this to simplify code.

Signed-off-by: Peng Liu <liupeng256@huawei.com>
---
 arch/ia64/hp/common/sba_iommu.c | 2 +-
 arch/x86/pci/acpi.c             | 2 +-
 drivers/acpi/arm64/iort.c       | 2 +-
 drivers/pci/pci-sysfs.c         | 2 +-
 include/linux/nodemask.h        | 3 +++
 mm/mempolicy.c                  | 2 +-
 6 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 8ad6946521d8..da3a010bb5fb 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -1969,7 +1969,7 @@ sba_map_ioc_to_node(struct ioc *ioc, acpi_handle handle)
 	unsigned int node;
 
 	node = acpi_get_node(handle);
-	if (node != NUMA_NO_NODE && !node_online(node))
+	if (!node_available(node))
 		node = NUMA_NO_NODE;
 
 	ioc->node = node;
diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 052f1d78a562..d4909daa44d9 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -254,7 +254,7 @@ static int pci_acpi_root_get_node(struct acpi_pci_root *root)
 			dev_info(&device->dev, FW_BUG "no _PXM; falling back to node %d from hardware (may be inconsistent with ACPI node numbers)\n",
 				node);
 	}
-	if (node != NUMA_NO_NODE && !node_online(node))
+	if (!node_available(node))
 		node = NUMA_NO_NODE;
 
 	return node;
diff --git a/drivers/acpi/arm64/iort.c b/drivers/acpi/arm64/iort.c
index f2f8f05662de..bdf690010b97 100644
--- a/drivers/acpi/arm64/iort.c
+++ b/drivers/acpi/arm64/iort.c
@@ -1251,7 +1251,7 @@ static int  __init arm_smmu_v3_set_proximity(struct device *dev,
 	if (smmu->flags & ACPI_IORT_SMMU_V3_PXM_VALID) {
 		int dev_node = pxm_to_node(smmu->pxm);
 
-		if (dev_node != NUMA_NO_NODE && !node_online(dev_node))
+		if (!node_available(dev_node))
 			return -EINVAL;
 
 		set_dev_node(dev, dev_node);
diff --git a/drivers/pci/pci-sysfs.c b/drivers/pci/pci-sysfs.c
index c263ffc5884a..502490d26c1d 100644
--- a/drivers/pci/pci-sysfs.c
+++ b/drivers/pci/pci-sysfs.c
@@ -344,7 +344,7 @@ static ssize_t numa_node_store(struct device *dev,
 	if ((node < 0 && node != NUMA_NO_NODE) || node >= MAX_NUMNODES)
 		return -EINVAL;
 
-	if (node != NUMA_NO_NODE && !node_online(node))
+	if (!node_available(node))
 		return -EINVAL;
 
 	add_taint(TAINT_FIRMWARE_WORKAROUND, LOCKDEP_STILL_OK);
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index 567c3ddba2c4..e7d30807df5b 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -70,6 +70,7 @@
  *
  * int node_online(node)		Is some node online?
  * int node_possible(node)		Is some node possible?
+ * int node_available(node)		Node online or NUMA_NO_NODE
  *
  * node_set_online(node)		set bit 'node' in node_online_map
  * node_set_offline(node)		clear bit 'node' in node_online_map
@@ -510,6 +511,8 @@ static inline int node_random(const nodemask_t *mask)
 #define num_possible_nodes()	num_node_state(N_POSSIBLE)
 #define node_online(node)	node_state((node), N_ONLINE)
 #define node_possible(node)	node_state((node), N_POSSIBLE)
+#define node_available(node) \
+		((node) = NUMA_NO_NODE || node_state((node), N_ONLINE))
 
 #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
 #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 8c74107a2b15..7a31b006c5e8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -141,7 +141,7 @@ int numa_map_to_online_node(int node)
 {
 	int min_dist = INT_MAX, dist, n, min_node;
 
-	if (node = NUMA_NO_NODE || node_online(node))
+	if (node_available(node))
 		return node;
 
 	min_node = node;
-- 
2.25.1
