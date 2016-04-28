From: Russell King <rmk+kernel@arm.linux.org.uk>
Date: Thu, 28 Apr 2016 09:28:14 +0000
Subject: [PATCH 06/12] ARM: kexec: advertise location of bootable RAM
Message-Id: <E1aviF4-0000jG-MO@rmk-PC.arm.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160428092644.GX19428@n2100.arm.linux.org.uk>
In-Reply-To: <20160428092644.GX19428@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org
Cc: devicetree@vger.kernel.org, Eric Biederman <ebiederm@xmission.com>, Fenghua Yu <fenghua.yu@intel.com>, Haren Myneni <hbabu@us.ibm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>, Jonathan Corbet <corbet@lwn.net>, kexec@lists.infradead.org, Kumar Gala <galak@codeaurora.org>, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, Mark Rutland <mark.rutland@arm.com>, Pawel Moll <pawel.moll@arm.com>, Rob Herring <robh+dt@kernel.org>, Santosh Shilimkar <ssantosh@kernel.org>, Tony Luck <tony.luck@intel.com>, Vivek Goyal <vgoyal@redhat.com>

Advertise the location of bootable RAM to kexec-tools.  kexec needs to
know where it can place the kernel in RAM, and so be executable when
the system needs to jump into it.

Advertise these areas in /proc/iomem with a "System RAM (boot alias)"
tag.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 arch/arm/kernel/setup.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 19b25ad61385..7cf1c0d4f773 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -847,10 +847,29 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 	kernel_data.end     = virt_to_phys(_end - 1);
 
 	for_each_memblock(memory, region) {
+		phys_addr_t start = __pfn_to_phys(memblock_region_memory_base_pfn(region));
+		phys_addr_t end = __pfn_to_phys(memblock_region_memory_end_pfn(region)) - 1;
+		unsigned long boot_alias_start;
+
+		/*
+		 * Some systems have a special memory alias which is only
+		 * used for booting.  We need to advertise this region to
+		 * kexec-tools so they know where bootable RAM is located.
+		 */
+		boot_alias_start = phys_to_idmap(start);
+		if (arm_has_idmap_alias() && boot_alias_start != INVALID_IDMAP_ADDR) {
+			res = memblock_virt_alloc(sizeof(*res), 0);
+			res->name = "System RAM (boot alias)";
+			res->start = boot_alias_start;
+			res->end = phys_to_idmap(end);
+			res->flags = IORESOURCE_MEM | IORESOURCE_BUSY;
+			request_resource(&iomem_resource, res);
+		}
+
 		res = memblock_virt_alloc(sizeof(*res), 0);
 		res->name  = "System RAM";
-		res->start = __pfn_to_phys(memblock_region_memory_base_pfn(region));
-		res->end = __pfn_to_phys(memblock_region_memory_end_pfn(region)) - 1;
+		res->start = start;
+		res->end = end;
 		res->flags = IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY;
 
 		request_resource(&iomem_resource, res);
-- 
2.1.0

