From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 16 Mar 2004 00:17:39 +0000
Subject: [PATCH] ia64/Kconfig
Message-Id: <200403151717.39545.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This Kconfig patch basically just makes ia64 look a little more like i386:
	- moves system type above processor type
	- moves PM & ACPI to a new top-level menu
	- moves PCI/PCMCIA to a new top-level menu

=== arch/ia64/Kconfig 1.63 vs edited ==--- 1.63/arch/ia64/Kconfig	Thu Mar 11 13:58:54 2004
+++ edited/arch/ia64/Kconfig	Mon Mar 15 17:15:31 2004
@@ -39,24 +39,6 @@
 	default y
 
 choice
-	prompt "Processor type"
-	default ITANIUM
-
-config ITANIUM
-	bool "Itanium"
-	help
-	  Select your IA-64 processor type.  The default is Itanium.
-	  This choice is safe for all IA-64 systems, but may not perform
-	  optimally on systems with, say, Itanium 2 or newer processors.
-
-config MCKINLEY
-	bool "Itanium 2"
-	help
-	  Select this to configure for an Itanium 2 (McKinley) processor.
-
-endchoice
-
-choice
 	prompt "System type"
 	default IA64_GENERIC
 
@@ -97,6 +79,24 @@
 endchoice
 
 choice
+	prompt "Processor type"
+	default ITANIUM
+
+config ITANIUM
+	bool "Itanium"
+	help
+	  Select your IA-64 processor type.  The default is Itanium.
+	  This choice is safe for all IA-64 systems, but may not perform
+	  optimally on systems with, say, Itanium 2 or newer processors.
+
+config MCKINLEY
+	bool "Itanium 2"
+	help
+	  Select this to configure for an Itanium 2 (McKinley) processor.
+
+endchoice
+
+choice
 	prompt "Kernel page size"
 	default IA64_PAGE_SIZE_16KB
 
@@ -129,52 +129,6 @@
 
 endchoice
 
-config ACPI
-	bool
-	depends on !IA64_HP_SIM
-	default y
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
-
 config IA64_BRL_EMU
 	bool
 	depends on ITANIUM
@@ -251,27 +205,6 @@
 		Say Y here to enable support for IBM EXA Cyclone time source.
 		If you're unsure, answer N.
 
-config PM
-	bool "Power Management support"
-	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y
-	help
-	  "Power Management" means that parts of your computer are shut
-	  off or put into a power conserving "sleep" mode if they are not
-	  being used.  There are two competing standards for doing this: APM
-	  and ACPI.  If you want to use either one, say Y here and then also
-	  to the requisite support below.
-
-	  Power Management is most important for battery powered laptop
-	  computers; if you have a laptop, check out the Linux Laptop home
-	  page on the WWW at <http://www.linux-on-laptops.com/> and the
-	  Battery Powered Linux mini-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Note that, even if you say N here, Linux on the x86 architecture
-	  will issue the hlt instruction if nothing is to be done, thereby
-	  sending the processor to sleep and saving power.
-
 config IOSAPIC
 	bool
 	depends on !IA64_HP_SIM
@@ -389,10 +322,89 @@
 
 source "fs/Kconfig.binfmt"
 
+endmenu
+
+menu "Power management and ACPI"
+
+config PM
+	bool "Power Management support"
+	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
+	default y
+	help
+	  "Power Management" means that parts of your computer are shut
+	  off or put into a power conserving "sleep" mode if they are not
+	  being used.  There are two competing standards for doing this: APM
+	  and ACPI.  If you want to use either one, say Y here and then also
+	  to the requisite support below.
+
+	  Power Management is most important for battery powered laptop
+	  computers; if you have a laptop, check out the Linux Laptop home
+	  page on the WWW at <http://www.linux-on-laptops.com/> and the
+	  Battery Powered Linux mini-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that, even if you say N here, Linux on the x86 architecture
+	  will issue the hlt instruction if nothing is to be done, thereby
+	  sending the processor to sleep and saving power.
+
+config ACPI
+	bool
+	depends on !IA64_HP_SIM
+	default y
+	help
+	  ACPI/OSPM support for Linux is currently under development. As such,
+	  this support is preliminary and EXPERIMENTAL.  Configuring ACPI
+	  support enables kernel interfaces that allow higher level software
+	  (OSPM) to manipulate ACPI defined hardware and software interfaces,
+	  including the evaluation of ACPI control methods.  If unsure, choose
+	  N here.  Note, this option will enlarge your kernel by about 120K.
+
+	  This support requires an ACPI compliant platform (hardware/firmware).
+	  If both ACPI and Advanced Power Management (APM) support are
+	  configured, whichever is loaded first shall be used.
+
+	  This code DOES NOT currently provide a complete OSPM implementation
+	  -- it has not yet reached APM's level of functionality.  When fully
+	  implemented, Linux ACPI/OSPM will provide a more robust functional
+	  replacement for legacy configuration and power management
+	  interfaces, including the Plug-and-Play BIOS specification (PnP
+	  BIOS), the Multi-Processor Specification (MPS), and the Advanced
+	  Power Management specification (APM).
+
+	  Linux support for ACPI/OSPM is based on Intel Corporation's ACPI
+	  Component Architecture (ACPI CA). The latest ACPI CA source code,
+	  documentation, debug builds, and implementation status information
+	  can be downloaded from:
+	  <http://developer.intel.com/technology/iapc/acpi/downloads.htm>.
+
+	  The ACPI Sourceforge project may also be of interest:
+	  <http://sf.net/projects/acpi/>
+
+config ACPI_INTERPRETER
+	bool
+	depends on !IA64_HP_SIM
+	default y
+
+config ACPI_KERNEL_CONFIG
+	bool
+	depends on !IA64_HP_SIM
+	default y
+	help
+	  If you say `Y' here, Linux's ACPI support will use the
+	  hardware-level system descriptions found on IA-64 systems.
+
 if !IA64_HP_SIM
 
 source "drivers/acpi/Kconfig"
 
+endif
+
+endmenu
+
+if !IA64_HP_SIM
+
+menu "Bus options (PCI, PCMCIA)"
+
 config PCI
 	bool "PCI support"
 	help
@@ -416,9 +428,9 @@
 
 source "drivers/pcmcia/Kconfig"
 
-endif
-
 endmenu
+
+endif
 
 source "drivers/Kconfig"
 

