From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:35 +0000
Subject: [RFC PATCH 24/32] arm64, irqchip/gic-v3, ACPI: Move MADT GICC enabled check into a helper
Message-Id: <20230203135043.409192-25-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

ACPI, irqchip and the architecture code all inspect the MADT
enabled bit for a GICC entry in the MADT.

The addition of an 'online capable' bit means all these sites need updating.

Move the current checks behind a helper to make future updates easier.

Signed-off-by: James Morse <james.morse@arm.com>
---
 arch/arm64/kernel/smp.c       |  2 +-
 drivers/acpi/processor_core.c |  2 +-
 drivers/irqchip/irq-gic-v3.c  | 10 ++++------
 include/linux/acpi.h          |  5 +++++
 4 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/arch/arm64/kernel/smp.c b/arch/arm64/kernel/smp.c
index ffc5d76cf695..5669b013c2b7 100644
--- a/arch/arm64/kernel/smp.c
+++ b/arch/arm64/kernel/smp.c
@@ -525,7 +525,7 @@ acpi_map_gic_cpu_interface(struct acpi_madt_generic_interrupt *processor)
 {
 	u64 hwid = processor->arm_mpidr;
 
-	if (!(processor->flags & ACPI_MADT_ENABLED)) {
+	if (!acpi_gicc_is_usable(processor)) {
 		pr_debug("skipping disabled CPU entry with 0x%llx MPIDR\n", hwid);
 		return;
 	}
diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
index 2ac48cda5b20..1ba273622faa 100644
--- a/drivers/acpi/processor_core.c
+++ b/drivers/acpi/processor_core.c
@@ -90,7 +90,7 @@ static int map_gicc_mpidr(struct acpi_subtable_header *entry,
 	struct acpi_madt_generic_interrupt *gicc  	    container_of(entry, struct acpi_madt_generic_interrupt, header);
 
-	if (!(gicc->flags & ACPI_MADT_ENABLED))
+	if (!acpi_gicc_is_usable(gicc))
 		return -ENODEV;
 
 	/* device_declaration means Device object in DSDT, in the
diff --git a/drivers/irqchip/irq-gic-v3.c b/drivers/irqchip/irq-gic-v3.c
index 997104d4338e..d484cccfd612 100644
--- a/drivers/irqchip/irq-gic-v3.c
+++ b/drivers/irqchip/irq-gic-v3.c
@@ -2189,8 +2189,7 @@ gic_acpi_parse_madt_gicc(union acpi_subtable_headers *header,
 	u32 size = reg = GIC_PIDR2_ARCH_GICv4 ? SZ_64K * 4 : SZ_64K * 2;
 	void __iomem *redist_base;
 
-	/* GICC entry which has !ACPI_MADT_ENABLED is not unusable so skip */
-	if (!(gicc->flags & ACPI_MADT_ENABLED))
+	if (!acpi_gicc_is_usable(gicc))
 		return 0;
 
 	redist_base = ioremap(gicc->gicr_base_address, size);
@@ -2240,7 +2239,7 @@ static int __init gic_acpi_match_gicc(union acpi_subtable_headers *header,
 	 * If GICC is enabled and has valid gicr base address, then it means
 	 * GICR base is presented via GICC
 	 */
-	if ((gicc->flags & ACPI_MADT_ENABLED) && gicc->gicr_base_address) {
+	if (acpi_gicc_is_usable(gicc) && gicc->gicr_base_address) {
 		acpi_data.enabled_rdists++;
 		return 0;
 	}
@@ -2249,7 +2248,7 @@ static int __init gic_acpi_match_gicc(union acpi_subtable_headers *header,
 	 * It's perfectly valid firmware can pass disabled GICC entry, driver
 	 * should not treat as errors, skip the entry instead of probe fail.
 	 */
-	if (!(gicc->flags & ACPI_MADT_ENABLED))
+	if (!acpi_gicc_is_usable(gicc))
 		return 0;
 
 	return -ENODEV;
@@ -2308,8 +2307,7 @@ static int __init gic_acpi_parse_virt_madt_gicc(union acpi_subtable_headers *hea
 	int maint_irq_mode;
 	static int first_madt = true;
 
-	/* Skip unusable CPUs */
-	if (!(gicc->flags & ACPI_MADT_ENABLED))
+	if (!acpi_gicc_is_usable(gicc))
 		return 0;
 
 	maint_irq_mode = (gicc->flags & ACPI_MADT_VGIC_IRQ_MODE) ?
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index a59bca4dbcd5..d8e59953a27f 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -267,6 +267,11 @@ acpi_table_parse_cedt(enum acpi_cedt_type id,
 int acpi_parse_mcfg (struct acpi_table_header *header);
 void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
 
+static inline bool acpi_gicc_is_usable(struct acpi_madt_generic_interrupt *gicc)
+{
+	return (gicc->flags & ACPI_MADT_ENABLED);
+}
+
 /* the following numa functions are architecture-dependent */
 void acpi_numa_slit_init (struct acpi_table_slit *slit);
 
-- 
2.30.2
