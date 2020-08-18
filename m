From: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Date: Tue, 18 Aug 2020 14:24:30 +0000
Subject: [PATCH v3 6/6] irq-chip/gic-v3-its: Fix crash if ITS is in a proximity domain without processor or m
Message-Id: <20200818142430.1156547-7-Jonathan.Cameron@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200818142430.1156547-1-Jonathan.Cameron@huawei.com>
In-Reply-To: <20200818142430.1156547-1-Jonathan.Cameron@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>, Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org, martin@geanix.com, Ingo Molnar <mingo@redhat.com>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, linuxarm@huawei.com, Dan Williams <dan.j.williams@intel.com>, Song Bao Hua <song.bao.hua@hisilicon.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

Note this crash is present before any of the patches in this series, but
as explained below it is highly unlikely anyone is shipping a firmware that
causes it. Tests were done using an overriden SRAT.

On ARM64, the gic-v3 driver directly parses SRAT to locate GIC Interrupt
Translation Service (ITS) Affinity Structures. This is done much later
in the boot than the parses of SRAT which identify proximity domains.

As a result, an ITS placed in a proximity domain that is not defined by
another SRAT structure will result in a NUMA node that is not completely
configured and a crash.

ITS [mem 0x202100000-0x20211ffff]
ITS@0x0000000202100000: Using ITS number 0
Unable to handle kernel paging request at virtual address 0000000000001a08
...

Call trace:
  __alloc_pages_nodemask+0xe8/0x338
  alloc_pages_node.constprop.0+0x34/0x40
  its_probe_one+0x2f8/0xb18
  gic_acpi_parse_madt_its+0x108/0x150
  acpi_table_parse_entries_array+0x17c/0x264
  acpi_table_parse_entries+0x48/0x6c
  acpi_table_parse_madt+0x30/0x3c
  its_init+0x1c4/0x644
  gic_init_bases+0x4b8/0x4ec
  gic_acpi_init+0x134/0x264
  acpi_match_madt+0x4c/0x84
  acpi_table_parse_entries_array+0x17c/0x264
  acpi_table_parse_entries+0x48/0x6c
  acpi_table_parse_madt+0x30/0x3c
  __acpi_probe_device_table+0x8c/0xe8
  irqchip_init+0x3c/0x48
  init_IRQ+0xcc/0x100
  start_kernel+0x33c/0x548

ACPI 6.3 allows any set of Affinity Structures in SRAT to define a proximity
domain.  However, as we do not see this crash, we can conclude that no
firmware is currently placing an ITS in a node that is separate from
those containing memory and / or processors.

We could modify the SRAT parsing behavior to identify the existence
of Proximity Domains unique to the ITS structures, and handle them as
a special case of a generic initiator (once support for those merges).

This patch avoids the complexity that would be needed to handle this corner
case, by not allowing the ITS entry parsing code to instantiate new NUMA
Nodes.  If one is encountered that does not already exist, then NO_NUMA_NODE
is assigned and a warning printed just as if the value had been greater than
allowed NUMA Nodes.

"SRAT: Invalid NUMA node -1 in ITS affinity"

Whilst this does not provide the full flexibility allowed by ACPI,
it does fix the problem.  We can revisit a more sophisticated solution if
needed by future platforms.

Change is simply to replace acpi_map_pxm_to_node with pxm_to_node reflecting
the fact a new mapping is not created.

Signed-off-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Reviewed-by: Hanjun Guo <guohanjun@huawei.com>
---
 drivers/irqchip/irq-gic-v3-its.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/irqchip/irq-gic-v3-its.c b/drivers/irqchip/irq-gic-v3-its.c
index 95f097448f97..b59b63ee3fa6 100644
--- a/drivers/irqchip/irq-gic-v3-its.c
+++ b/drivers/irqchip/irq-gic-v3-its.c
@@ -5263,7 +5263,12 @@ static int __init gic_acpi_parse_srat_its(union acpi_subtable_headers *header,
 		return -EINVAL;
 	}
 
-	node = acpi_map_pxm_to_node(its_affinity->proximity_domain);
+	/*
+	 * Note that in theory a new proximity node could be created by this
+	 * entry as it is an SRAT resource allocation structure.
+	 * We do not currently support doing so.
+	 */
+	node = pxm_to_node(its_affinity->proximity_domain);
 
 	if (node = NUMA_NO_NODE || node >= MAX_NUMNODES) {
 		pr_err("SRAT: Invalid NUMA node %d in ITS affinity\n", node);
-- 
2.19.1
