From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Tue, 28 Sep 2004 02:46:04 +0000
Subject: [PATCH] Check enabled field of processor affinity
Message-Id: <20040928114604.5a2a89e4.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, acpi-devel@lists.sourceforge.net
Cc: tokunaga.keiich@jp.fujitsu.com

Hi there,

I think that acpi_numa_processor_affinity_init() should check the
enabled field of processor affinity because ACPI spec says "If clear,
the OSPM ignores the contents of the Processor Local APIC/SAPIC
Affinity Structure".

Thanks,
Keiichiro Tokunaga


Name: Check enabled field of processor affinity
Status: Compiled on 2.6.9-rc2
Signed-off-by: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>

---

 linux-2.6.9-rc2-enabled-bit-kei/arch/ia64/kernel/acpi.c |    4 ++++
 1 files changed, 4 insertions(+)

diff -puN arch/ia64/kernel/acpi.c~enabled_fix arch/ia64/kernel/acpi.c
--- linux-2.6.9-rc2-enabled-bit/arch/ia64/kernel/acpi.c~enabled_fix	2004-09-28 10:24:18.620152358 +0900
+++ linux-2.6.9-rc2-enabled-bit-kei/arch/ia64/kernel/acpi.c	2004-09-28 10:24:18.623082067 +0900
@@ -385,6 +385,10 @@ acpi_numa_slit_init (struct acpi_table_s
 void __init
 acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa)
 {
+	/* Ignore disabled entries */
+	if (!pa->flags.enabled)
+		return;
+
 	/* record this node in proximity bitmap */
 	pxm_bit_set(pa->proximity_domain);
 

_
