From: Al Stone <al.stone@linaro.org>
Date: Wed, 09 Sep 2015 21:09:48 +0000
Subject: [PATCH v3 2/5] ACPI / ARM64: remove usage of BAD_MADT_ENTRY/BAD_MADT_GICC_ENTRY
Message-Id: <1441832991-28200-3-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1441832991-28200-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1441832991-28200-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linaro-kernel@lists.linaro.org, linux-ia64@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>, Al Stone <al.stone@linaro.org>, patches@linaro.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>

Now that we have introduced the bad_madt_entry() function, and that
function is being invoked in acpi_table_parse_madt() for us, there
is no longer any need to use the BAD_MADT_ENTRY macro, or in the case
of arm64, the BAD_MADT_GICC_ENTRY, too.

Signed-off-by: Al Stone <al.stone@linaro.org>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
Reviewed-and-tested-by: Sudeep Holla <sudeep.holla@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Jason Cooper <jason@lakedaemon.net>
---
 arch/arm64/include/asm/acpi.h | 8 --------
 arch/arm64/kernel/smp.c       | 2 --
 drivers/irqchip/irq-gic.c     | 6 ------
 3 files changed, 16 deletions(-)

diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
index 208cec0..ed7e212 100644
--- a/arch/arm64/include/asm/acpi.h
+++ b/arch/arm64/include/asm/acpi.h
@@ -19,14 +19,6 @@
 #include <asm/cputype.h>
 #include <asm/smp_plat.h>
 
-/* Macros for consistency checks of the GICC subtable of MADT */
-#define ACPI_MADT_GICC_LENGTH	\
-	(acpi_gbl_FADT.header.revision < 6 ? 76 : 80)
-
-#define BAD_MADT_GICC_ENTRY(entry, end)						\
-	(!(entry) || (unsigned long)(entry) + sizeof(*(entry)) > (end) ||	\
-	 (entry)->header.length != ACPI_MADT_GICC_LENGTH)
-
 /* Basic configuration for ACPI */
 #ifdef	CONFIG_ACPI
 /* ACPI table mapping after acpi_gbl_permanent_mmap is set */
diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index dbdaacd..66cc8c4 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -451,8 +451,6 @@ acpi_parse_gic_cpu_interface(struct acpi_subtable_header *header,
 	struct acpi_madt_generic_interrupt *processor;
 
 	processor = (struct acpi_madt_generic_interrupt *)header;
-	if (BAD_MADT_GICC_ENTRY(processor, end))
-		return -EINVAL;
 
 	acpi_table_print_madt_entry(header);
 
diff --git a/drivers/irqchip/irq-gic.c b/drivers/irqchip/irq-gic.c
index e6b7ed5..b3530e3 100644
--- a/drivers/irqchip/irq-gic.c
+++ b/drivers/irqchip/irq-gic.c
@@ -1189,9 +1189,6 @@ gic_acpi_parse_madt_cpu(struct acpi_subtable_header *header,
 
 	processor = (struct acpi_madt_generic_interrupt *)header;
 
-	if (BAD_MADT_GICC_ENTRY(processor, end))
-		return -EINVAL;
-
 	/*
 	 * There is no support for non-banked GICv1/2 register in ACPI spec.
 	 * All CPU interface addresses have to be the same.
@@ -1213,9 +1210,6 @@ gic_acpi_parse_madt_distributor(struct acpi_subtable_header *header,
 
 	dist = (struct acpi_madt_generic_distributor *)header;
 
-	if (BAD_MADT_ENTRY(dist, end))
-		return -EINVAL;
-
 	dist_phy_base = dist->base_address;
 	return 0;
 }
-- 
2.4.3

