From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 07 Jan 2004 00:32:22 +0000
Subject: FYI, ZX1 config problem in 2.4.23/2.4.24
Message-Id: <200401061732.22576.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When I changed the "HP-zx1" kernel config choice to just "HP",
I seem to have exposed an oddity in the way menuconfig works.
The menu contains this:

        "generic                CONFIG_IA64_GENERIC             \
         DIG-compliant          CONFIG_IA64_DIG                 \
         HP-simulator           CONFIG_IA64_HP_SIM              \
         HP                     CONFIG_IA64_HP_ZX1              \
         SGI-SN2                CONFIG_IA64_SGI_SN2" generic

and apparently when the user selects "HP", menuconfig turns on
the *simulator* symbol (CONFIG_IA64_HP_SIM) instead of the HP_ZX1
symbol.  I think this looks like a menuconfig bug, but the easiest
way around it is probably to use a patch like this:

=== arch/ia64/config.in 1.31 vs edited ==--- 1.31/arch/ia64/config.in	Thu Oct 16 15:56:24 2003
+++ edited/arch/ia64/config.in	Tue Jan  6 17:29:22 2004
@@ -33,7 +33,7 @@
 choice 'IA-64 system type'					\
 	"generic		CONFIG_IA64_GENERIC		\
 	 DIG-compliant		CONFIG_IA64_DIG			\
-	 HP-simulator		CONFIG_IA64_HP_SIM		\
+	 Ski-simulator		CONFIG_IA64_HP_SIM		\
 	 HP			CONFIG_IA64_HP_ZX1		\
 	 SGI-SN2		CONFIG_IA64_SGI_SN2" generic
 
One symptom of this problem are messages like this when linking
the kernel:

ld: Dwarf Error: Could not find abbrev number 105.
ld: Dwarf Error: Could not find abbrev number 94.
ld: Dwarf Error: Could not find abbrev number 114.
ld: Dwarf Error: Could not find abbrev number 103.
ld: Dwarf Error: Could not find abbrev number 522.
ld: Dwarf Error: Could not find abbrev number 109.
ld: Dwarf Error: Line offset (1936617315) bigger than line size (200501).
ld: Dwarf Error: Could not find abbrev number 115.
ld: Dwarf Error: Could not find abbrev number 4112.
ld: Dwarf Error: Could not find abbrev number 95.
drivers/char/char.o: In function `to_utf8':
drivers/char/char.o(.text.init+0x2e72): undefined reference to `probe_serial_acpi'

