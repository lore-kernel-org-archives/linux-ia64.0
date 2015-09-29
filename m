From: Al Stone <al.stone@linaro.org>
Date: Tue, 29 Sep 2015 23:45:43 +0000
Subject: [PATCH v5 2/5] ACPI / ARM64: remove usage of BAD_MADT_ENTRY/BAD_MADT_GICC_ENTRY
Message-Id: <1443570346-15378-3-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1443570346-15378-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Al Stone <al.stone@linaro.org>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Jason Cooper <jason@lakedaemon.net>

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
 drivers/irqchip/irq-gic.c     | 3 ---
 3 files changed, 13 deletions(-)

diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
index 6894205..05656fc 100644
--- a/arch/arm64/include/asm/acpi.h
+++ b/arch/arm64/include/asm/acpi.h
@@ -18,14 +18,6 @@
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
index d4add30..67b7b48 100644
--- a/drivers/irqchip/irq-gic.c
+++ b/drivers/irqchip/irq-gic.c
@@ -1206,9 +1206,6 @@ gic_acpi_parse_madt_cpu(struct acpi_subtable_header *header,
 
 	processor = (struct acpi_madt_generic_interrupt *)header;
 
-	if (BAD_MADT_GICC_ENTRY(processor, end))
-		return -EINVAL;
-
 	/*
 	 * There is no support for non-banked GICv1/2 register in ACPI spec.
 	 * All CPU interface addresses have to be the same.
-- 
2.4.3

