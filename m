From: Matthew Wilcox <willy@debian.org>
Date: Wed, 17 Mar 2004 22:58:43 +0000
Subject: [PATCH] kill unused ACPI configgery
Message-Id: <20040317225843.GV25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The config ACPI helptext isn't used because the option is never
presented to the user.
ACPI_KERNEL_CONFIG is unused.
ACPI_INTERPRETER is now set in drivers/acpi/Kconfig.

Index: arch/ia64/Kconfig
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/Kconfig,v
retrieving revision 1.11
diff -u -p -r1.11 Kconfig
--- a/arch/ia64/Kconfig	16 Mar 2004 15:39:50 -0000	1.11
+++ b/arch/ia64/Kconfig	17 Mar 2004 22:54:06 -0000
@@ -133,47 +128,6 @@ config ACPI
 	bool
 	depends on !IA64_HP_SIM
 	default y
-	help
-	  ACPI/OSPM support for Linux is currently under development. As such,
-	  this support is preliminary and EXPERIMENTAL.  Configuring ACPI
-	  support enables kernel interfaces that allow higher level software
-	  (OSPM) to manipulate ACPI defined hardware and software interfaces,
-	  including the evaluation of ACPI control methods.  If unsure, choose
-	  N here.  Note, this option will enlarge your kernel by about 120K.
-
-	  This support requires an ACPI compliant platform (hardware/firmware).
-	  If both ACPI and Advanced Power Management (APM) support are
-	  configured, whichever is loaded first shall be used.
-
-	  This code DOES NOT currently provide a complete OSPM implementation
-	  -- it has not yet reached APM's level of functionality.  When fully
-	  implemented, Linux ACPI/OSPM will provide a more robust functional
-	  replacement for legacy configuration and power management
-	  interfaces, including the Plug-and-Play BIOS specification (PnP
-	  BIOS), the Multi-Processor Specification (MPS), and the Advanced
-	  Power Management specification (APM).
-
-	  Linux support for ACPI/OSPM is based on Intel Corporation's ACPI
-	  Component Architecture (ACPI CA). The latest ACPI CA source code,
-	  documentation, debug builds, and implementation status information
-	  can be downloaded from:
-	  <http://developer.intel.com/technology/iapc/acpi/downloads.htm>.
-
-	  The ACPI Sourceforge project may also be of interest:
-	  <http://sf.net/projects/acpi/>
-
-config ACPI_INTERPRETER
-	bool
-	depends on !IA64_HP_SIM
-	default y
-
-config ACPI_KERNEL_CONFIG
-	bool
-	depends on !IA64_HP_SIM
-	default y
-	help
-	  If you say `Y' here, Linux's ACPI support will use the
-	  hardware-level system descriptions found on IA-64 systems.
 
 config IA64_BRL_EMU
 	bool

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
