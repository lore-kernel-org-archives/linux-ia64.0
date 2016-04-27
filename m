From: David Daney <ddaney.cavm@gmail.com>
Date: Wed, 27 Apr 2016 18:07:14 +0000
Subject: [PATCH v6 12/14] acpi, numa, srat: Improve SRAT error detection and add messages.
Message-Id: <1461780436-27182-13-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461780436-27182-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

From: David Daney <david.daney@cavium.com>

Loosely based on code from Robert Richter and Hanjun Guo.

Improve out of range node detection as well as allow for Larger SRAT
entities.

Add printing of nice messages.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/acpi/numa.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index d7d0499..50c8f42 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -252,8 +252,11 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 
 	if (srat_disabled())
 		goto out_err;
-	if (ma->header.length != sizeof(struct acpi_srat_mem_affinity))
+	if (ma->header.length < sizeof(struct acpi_srat_mem_affinity)) {
+		pr_err("SRAT: Unexpected header length: %d\n",
+		       ma->header.length);
 		goto out_err_bad_srat;
+	}
 	if ((ma->flags & ACPI_SRAT_MEM_ENABLED) = 0)
 		goto out_err;
 	hotpluggable = ma->flags & ACPI_SRAT_MEM_HOT_PLUGGABLE;
@@ -267,13 +270,17 @@ acpi_numa_memory_affinity_init(struct acpi_srat_mem_affinity *ma)
 		pxm &= 0xff;
 
 	node = acpi_map_pxm_to_node(pxm);
-	if (node < 0) {
-		printk(KERN_ERR "SRAT: Too many proximity domains.\n");
+	if (node = NUMA_NO_NODE || node >= MAX_NUMNODES) {
+		pr_err("SRAT: Too many proximity domains.\n");
 		goto out_err_bad_srat;
 	}
 
-	if (numa_add_memblk(node, start, end) < 0)
+	if (numa_add_memblk(node, start, end) < 0) {
+		pr_err("SRAT: Failed to add memblk to node %u [mem %#010Lx-%#010Lx]\n",
+		       node, (unsigned long long) start,
+		       (unsigned long long) end - 1);
 		goto out_err_bad_srat;
+	}
 
 	node_set(node, numa_nodes_parsed);
 
-- 
1.7.11.7

