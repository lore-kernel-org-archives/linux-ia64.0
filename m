From: Al Stone <al.stone@linaro.org>
Date: Wed, 19 Aug 2015 22:07:27 +0000
Subject: [PATCH v2 4/5] ACPI / X86: remove usage of BAD_MADT_ENTRY
Message-Id: <1440022048-6285-5-git-send-email-al.stone@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
In-Reply-To: <1440022048-6285-1-git-send-email-al.stone@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-pm@vger.kernel.org, linaro-acpi@lists.linaro.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Al Stone <al.stone@linaro.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org

Now that we have introduced the bad_madt_entry() function, and that
function is being invoked in acpi_table_parse_madt() for us, there
is no longer any need to use the BAD_MADT_ENTRY macro.

Signed-off-by: Al Stone <al.stone@linaro.org>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Len Brown <len.brown@intel.com>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: x86@kernel.org
---
 arch/x86/kernel/acpi/boot.c | 27 ---------------------------
 1 file changed, 27 deletions(-)

diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
index 75e8bad..f2a70b2 100644
--- a/arch/x86/kernel/acpi/boot.c
+++ b/arch/x86/kernel/acpi/boot.c
@@ -194,9 +194,6 @@ acpi_parse_x2apic(struct acpi_subtable_header *header, const unsigned long end)
 
 	processor = (struct acpi_madt_local_x2apic *)header;
 
-	if (BAD_MADT_ENTRY(processor, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	apic_id = processor->local_apic_id;
@@ -227,9 +224,6 @@ acpi_parse_lapic(struct acpi_subtable_header * header, const unsigned long end)
 
 	processor = (struct acpi_madt_local_apic *)header;
 
-	if (BAD_MADT_ENTRY(processor, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	/*
@@ -252,9 +246,6 @@ acpi_parse_sapic(struct acpi_subtable_header *header, const unsigned long end)
 
 	processor = (struct acpi_madt_local_sapic *)header;
 
-	if (BAD_MADT_ENTRY(processor, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	acpi_register_lapic((processor->id << 8) | processor->eid,/* APIC ID */
@@ -271,9 +262,6 @@ acpi_parse_lapic_addr_ovr(struct acpi_subtable_header * header,
 
 	lapic_addr_ovr = (struct acpi_madt_local_apic_override *)header;
 
-	if (BAD_MADT_ENTRY(lapic_addr_ovr, end))
-		return -EINVAL;
-
 	acpi_lapic_addr = lapic_addr_ovr->address;
 
 	return 0;
@@ -287,9 +275,6 @@ acpi_parse_x2apic_nmi(struct acpi_subtable_header *header,
 
 	x2apic_nmi = (struct acpi_madt_local_x2apic_nmi *)header;
 
-	if (BAD_MADT_ENTRY(x2apic_nmi, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	if (x2apic_nmi->lint != 1)
@@ -305,9 +290,6 @@ acpi_parse_lapic_nmi(struct acpi_subtable_header * header, const unsigned long e
 
 	lapic_nmi = (struct acpi_madt_local_apic_nmi *)header;
 
-	if (BAD_MADT_ENTRY(lapic_nmi, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	if (lapic_nmi->lint != 1)
@@ -411,9 +393,6 @@ acpi_parse_ioapic(struct acpi_subtable_header * header, const unsigned long end)
 
 	ioapic = (struct acpi_madt_io_apic *)header;
 
-	if (BAD_MADT_ENTRY(ioapic, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	/* Statically assign IRQ numbers for IOAPICs hosting legacy IRQs */
@@ -462,9 +441,6 @@ acpi_parse_int_src_ovr(struct acpi_subtable_header * header,
 
 	intsrc = (struct acpi_madt_interrupt_override *)header;
 
-	if (BAD_MADT_ENTRY(intsrc, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	if (intsrc->source_irq = acpi_gbl_FADT.sci_interrupt) {
@@ -503,9 +479,6 @@ acpi_parse_nmi_src(struct acpi_subtable_header * header, const unsigned long end
 
 	nmi_src = (struct acpi_madt_nmi_source *)header;
 
-	if (BAD_MADT_ENTRY(nmi_src, end))
-		return -EINVAL;
-
 	acpi_table_print_madt_entry(header);
 
 	/* TBD: Support nimsrc entries? */
-- 
2.4.3

