From: Al Stone <al.stone@linaro.org>
Date: Wed, 16 Sep 2015 23:26:43 +0000
Subject: [PATCH v4 3/5] ACPI / IA64: remove usage of BAD_MADT_ENTRY
Message-Id: <1442446005-19799-4-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1442446005-19799-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1442446005-19799-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Al Stone <al.stone@linaro.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

Now that we have introduced the bad_madt_entry() function, and that
function is being invoked in acpi_table_parse_madt() for us, there
is no longer any need to use the BAD_MADT_ENTRY macro.

Signed-off-by: Al Stone <al.stone@linaro.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/kernel/acpi.c | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index b1698bc..efa3f0a 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -184,9 +184,6 @@ acpi_parse_lapic_addr_ovr(struct acpi_subtable_header * header,
 
 	lapic = (struct acpi_madt_local_apic_override *)header;
 
-	if (BAD_MADT_ENTRY(lapic, end))
-		return -EINVAL;
-
 	if (lapic->address) {
 		iounmap(ipi_base_addr);
 		ipi_base_addr = ioremap(lapic->address, 0);
@@ -201,8 +198,6 @@ acpi_parse_lsapic(struct acpi_subtable_header * header, const unsigned long end)
 
 	lsapic = (struct acpi_madt_local_sapic *)header;
 
-	/*Skip BAD_MADT_ENTRY check, as lsapic size could vary */
-
 	if (lsapic->lapic_flags & ACPI_MADT_ENABLED) {
 #ifdef CONFIG_SMP
 		smp_boot_data.cpu_phys_id[available_cpus] @@ -222,9 +217,6 @@ acpi_parse_lapic_nmi(struct acpi_subtable_header * header, const unsigned long e
 
 	lacpi_nmi = (struct acpi_madt_local_apic_nmi *)header;
 
-	if (BAD_MADT_ENTRY(lacpi_nmi, end))
-		return -EINVAL;
-
 	/* TBD: Support lapic_nmi entries */
 	return 0;
 }
@@ -236,9 +228,6 @@ acpi_parse_iosapic(struct acpi_subtable_header * header, const unsigned long end
 
 	iosapic = (struct acpi_madt_io_sapic *)header;
 
-	if (BAD_MADT_ENTRY(iosapic, end))
-		return -EINVAL;
-
 	return iosapic_init(iosapic->address, iosapic->global_irq_base);
 }
 
@@ -253,9 +242,6 @@ acpi_parse_plat_int_src(struct acpi_subtable_header * header,
 
 	plintsrc = (struct acpi_madt_interrupt_source *)header;
 
-	if (BAD_MADT_ENTRY(plintsrc, end))
-		return -EINVAL;
-
 	/*
 	 * Get vector assignment for this interrupt, set attributes,
 	 * and program the IOSAPIC routing table.
@@ -336,9 +322,6 @@ acpi_parse_int_src_ovr(struct acpi_subtable_header * header,
 
 	p = (struct acpi_madt_interrupt_override *)header;
 
-	if (BAD_MADT_ENTRY(p, end))
-		return -EINVAL;
-
 	iosapic_override_isa_irq(p->source_irq, p->global_irq,
 				 ((p->inti_flags & ACPI_MADT_POLARITY_MASK) =
 				  ACPI_MADT_POLARITY_ACTIVE_LOW) ?
@@ -356,9 +339,6 @@ acpi_parse_nmi_src(struct acpi_subtable_header * header, const unsigned long end
 
 	nmi_src = (struct acpi_madt_nmi_source *)header;
 
-	if (BAD_MADT_ENTRY(nmi_src, end))
-		return -EINVAL;
-
 	/* TBD: Support nimsrc entries */
 	return 0;
 }
-- 
2.4.3

