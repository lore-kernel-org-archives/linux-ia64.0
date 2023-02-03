From: James Morse <james.morse@arm.com>
Date: Fri, 03 Feb 2023 13:50:37 +0000
Subject: [RFC PATCH 26/32] irqchip/gic-v3: Add support for ACPI's disabled but 'online capable' CPUs
Message-Id: <20230203135043.409192-27-james.morse@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230203135043.409192-1-james.morse@arm.com>
In-Reply-To: <20230203135043.409192-1-james.morse@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pm@vger.kernel.org, loongarch@lists.linux.dev, kvmarm@lists.linux.dev, kvm@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Cc: Marc Zyngier <maz@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Lorenzo Pieralisi <lpieralisi@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Sudeep Holla <sudeep.holla@arm.com>, Borislav Petkov <bp@alien8.de>, H Peter Anvin <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will@kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Huacai Chen <chenhuacai@kernel.org>, James Morse <james.morse@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Oliver Upton <oliver.upton@linux.dev>, Len Brown <lenb@kernel.org>, Rafael Wysocki <rafael@kernel.org>, WANG Xuerui <kernel@xen0n.name>, Salil Mehta <salil.mehta@huawei.com>, Russell King <linux@armlinux.org.uk>, Jean-Philippe Brucker <jean-philippe@linaro.org>

To support virtual CPU hotplug, ACPI has added an 'online capable' bit
to the MADT GICC entries. This indicates a disabled CPU entry may not
be possible to online via PSCI until firmware has set enabled bit in
_STA.

What about the redistributor in the GICC entry? ACPI doesn't want to say.
Assume the worst: When a redistributor is described in the GICC entry,
but the entry is marked as disabled at boot, assume the redistributor
is inaccessible.

The GICv3 driver doesn't support late online of redistributors, so this
means the corresponding CPU can't be brought online either. Clear the
possible and present bits.

Systems that want CPU hotplug in a VM can ensure their redistributors
are always-on, and describe them that way with a GICR entry in the MADT.

When mapping redistributors found via GICC entries, handle the case
where the arch code believes the CPU is present and possible, but it
does not have an accessible redistributor. Print a warning and clear
the present and possible bits.

Signed-off-by: James Morse <james.morse@arm.com>
----
Disabled but online-capable CPUs cause this message to be printed
if their redistributors are described via GICC:
| GICv3: CPU 3's redistributor is inaccessible: this CPU can't be brought online

If ACPI's _STA tries to make the cpu present later, this message is printed:
| Changing CPU present bit is not supported
---
 drivers/irqchip/irq-gic-v3.c | 14 ++++++++++++++
 include/linux/acpi.h         |  3 ++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/irqchip/irq-gic-v3.c b/drivers/irqchip/irq-gic-v3.c
index a8b969d652b6..8c1ea3df0094 100644
--- a/drivers/irqchip/irq-gic-v3.c
+++ b/drivers/irqchip/irq-gic-v3.c
@@ -2187,11 +2187,25 @@ gic_acpi_parse_madt_gicc(union acpi_subtable_headers *header,
 				(struct acpi_madt_generic_interrupt *)header;
 	u32 reg = readl_relaxed(acpi_data.dist_base + GICD_PIDR2) & GIC_PIDR2_ARCH_MASK;
 	u32 size = reg = GIC_PIDR2_ARCH_GICv4 ? SZ_64K * 4 : SZ_64K * 2;
+	int cpu = get_cpu_for_acpi_id(gicc->uid);
 	void __iomem *redist_base;
 
 	if (!acpi_gicc_is_usable(gicc))
 		return 0;
 
+	/*
+	 * Capable but disabled CPUs can be brought online later. What about
+	 * the redistributor? ACPI doesn't want to say!
+	 * Virtual hotplug systems can use the MADT's "always-on" GICR entries.
+	 * Otherwise, prevent such CPUs from being brought online.
+	 */
+	if (!(gicc->flags & ACPI_MADT_ENABLED)) {
+		pr_warn_once("CPU %u's redistributor is inaccessible: this CPU can't be brought online\n", cpu);
+		set_cpu_present(cpu, false);
+		set_cpu_possible(cpu, false);
+		return 0;
+	}
+
 	redist_base = ioremap(gicc->gicr_base_address, size);
 	if (!redist_base)
 		return -ENOMEM;
diff --git a/include/linux/acpi.h b/include/linux/acpi.h
index d8e59953a27f..c1b74ebd5774 100644
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -269,7 +269,8 @@ void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
 
 static inline bool acpi_gicc_is_usable(struct acpi_madt_generic_interrupt *gicc)
 {
-	return (gicc->flags & ACPI_MADT_ENABLED);
+	return ((gicc->flags & ACPI_MADT_ENABLED ||
+		 gicc->flags & ACPI_MADT_GICC_CPU_CAPABLE));
 }
 
 /* the following numa functions are architecture-dependent */
-- 
2.30.2
