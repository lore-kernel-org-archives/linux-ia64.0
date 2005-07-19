From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 19 Jul 2005 01:31:27 +0000
Subject: [PATCH] Fix unused variable acpi_madt_rev
Message-Id: <20050719013127.GF10518@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix

arch/ia64/kernel/acpi.c:71: warning: 'acpi_madt_rev' defined but not used

when building for the simulator (which has no ACPI) by moving inside
an ACPI ifdef'd area.

--

Signed-Off-By: Ian Wienand <ianw@gelato.unsw.edu.au>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -68,8 +68,6 @@ EXPORT_SYMBOL(pm_power_off);
 unsigned char acpi_kbd_controller_present = 1;
 unsigned char acpi_legacy_devices;
 
-static unsigned int __initdata acpi_madt_rev;
-
 unsigned int acpi_cpei_override;
 unsigned int acpi_cpei_phys_cpuid;
 
@@ -135,6 +133,8 @@ acpi_get_sysname (void)
 
 #define ACPI_MAX_PLATFORM_INTERRUPTS	256
 
+static unsigned int __initdata acpi_madt_rev;
+
 /* Array to record platform interrupt vectors for generic interrupt routing. */
 int platform_intr_list[ACPI_MAX_PLATFORM_INTERRUPTS] = {
 	[0 ... ACPI_MAX_PLATFORM_INTERRUPTS - 1] = -1
