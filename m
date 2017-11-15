From: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
Date: Wed, 15 Nov 2017 17:41:02 +0000
Subject: [PATCH] acpi, numa, ia64: Parse all entries of SRAT memory affinity table
Message-Id: <20171115172902.20083-1-ganapatrao.kulkarni@cavium.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org
Cc: fenghua.yu@intel.com, tony.luck@intel.com, rjw@rjwysocki.net, lenb@kernel.org, guohanjun@huawei.com, jnair@caviumnetworks.com, gpkulkarni@gmail.com, Robert.Richter@cavium.com

In current implementation, SRAT Memory Affinity Structure table
parsing is restricted to number of maximum memblocks allowed
(NR_NODE_MEMBLKS). However NR_NODE_MEMBLKS is defined individually as
per architecture requirements. Hence removing the restriction of
SRAT Memory Affinity Structure parsing in acpi driver code and
let architecture code check for allowed memblocks count.
This check is already added in x86 and extending same to ia64.

Signed-off-by: Ganapatrao Kulkarni <ganapatrao.kulkarni@cavium.com>
---
 arch/ia64/kernel/acpi.c | 5 +++++
 drivers/acpi/numa.c     | 3 +--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 1d29b2f..1dacbf5 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -504,6 +504,11 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 	if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
 		return -1;
 
+	if (num_node_memblks >= NR_NODE_MEMBLKS) {
+		pr_err("NUMA: too many memblk ranges\n");
+		return -EINVAL;
+	}
+
 	/* record this node in proximity bitmap */
 	pxm_bit_set(pxm);
 
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 917f1cc..8ccaae3 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -460,8 +460,7 @@ int __init acpi_numa_init(void)
 					srat_proc, ARRAY_SIZE(srat_proc), 0);
 
 		cnt = acpi_table_parse_srat(ACPI_SRAT_TYPE_MEMORY_AFFINITY,
-					    acpi_parse_memory_affinity,
-					    NR_NODE_MEMBLKS);
+					    acpi_parse_memory_affinity, 0);
 	}
 
 	/* SLIT: System Locality Information Table */
-- 
2.9.4

