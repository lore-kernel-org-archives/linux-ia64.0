From: Matthew Wilcox <willy@debian.org>
Date: Tue, 07 Oct 2003 18:01:11 +0000
Subject: [PATCH] clean up Kconfig a bit
Message-Id: <marc-linux-ia64-106555019402117@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch cleans up arch/ia64/Kconfig a bit.

 - Remove duplicate settings of ACPI symbols
 - Kill unused ACPI_KERNEL_CONFIG
 - Use def_bool where appropriate
 - Reorder and reindent some entries to minimise the diff from i386
 - Use kernel/power/Kconfig instead of our own config PM
 - Add telephony.

Index: arch/ia64/Kconfig
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/Kconfig,v
retrieving revision 1.4
diff -u -p -r1.4 Kconfig
--- a/arch/ia64/Kconfig	28 Sep 2003 04:04:46 -0000	1.4
+++ b/arch/ia64/Kconfig	7 Oct 2003 17:56:56 -0000
@@ -10,8 +10,7 @@ source "init/Kconfig"
 menu "Processor type and features"
 
 config IA64
-	bool
-	default y
+	def_bool y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
 	  the 32-bit X86 line.  The IA-64 Linux project has a home
@@ -22,16 +21,13 @@ config 64BIT
 	def_bool y
 
 config MMU
-	bool
-	default y
+	def_bool y
 
 config RWSEM_XCHGADD_ALGORITHM
-	bool
-	default y
+	def_bool y
 
 config TIME_INTERPOLATION
-	bool
-	default y
+	def_bool y
 
 choice
 	prompt "IA-64 processor type"
@@ -127,57 +123,6 @@ config IA64_PAGE_SIZE_64KB
 
 endchoice
 
-config ACPI
-	bool
-	depends on !IA64_HP_SIM
-	default y
-	---help---
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
-config ACPI_EFI
-	bool
-	depends on !IA64_HP_SIM
-	default y
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
@@ -266,28 +211,6 @@ config IA64_MCA
 	  Say Y here to enable machine check support for IA-64.  If you're
 	  unsure, answer Y.
 
-config PM
-	bool "Power Management support"
-	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y
-	---help---
-	  "Power Management" means that parts of your computer are shut
-	  off or put into a power conserving "sleep" mode if they are not
-	  being used.  There are two competing standards for doing this: APM
-	  and ACPI.  If you want to use either one, say Y here and then also
-	  to the requisite support below.
-
-	  Power Management is most important for battery powered laptop
-	  computers; if you have a laptop, check out the Linux Laptop home
-	  page on the WWW at
-	  <http://www.cs.utexas.edu/users/kharker/linux-laptop/> and the
-	  Battery Powered Linux mini-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  Note that, even if you say N here, Linux on the x86 architecture
-	  will issue the hlt instruction if nothing is to be done, thereby
-	  sending the processor to sleep and saving power.
-
 config IOSAPIC
 	bool
 	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2
@@ -347,7 +270,7 @@ config IA64_PAL_IDLE
 	  unsure your firmware supports it, answer N.
 
 config SMP
-	bool "SMP support"
+	bool "Symmetric multi-processing support"
 	---help---
 	  This enables support for systems with more than one CPU. If you have
 	  a system with only one CPU say N. If you have a system with more than
@@ -365,17 +288,28 @@ config SMP
 
 	  If you don't know what to do here, say N.
 
+config NR_CPUS
+	int "Maximum number of CPUs"
+	depends on SMP
+	default "64"
+	help
+	  You should set this to the number of CPUs in your system, but
+	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
+	  only use 2 CPUs on a >2 CPU system.  Setting this to a value larger
+	  than 64 will cause the use of a CPU mask array, causing a small
+	  performance hit.
+
 config PREEMPT
 	bool "Preemptible Kernel"
-        help
-          This option reduces the latency of the kernel when reacting to
-          real-time or interactive events by allowing a low priority process to
-          be preempted even if it is in kernel mode executing a system call.
-          This allows applications to run more reliably even when the system is
-          under load.
+	help
+	  This option reduces the latency of the kernel when reacting to
+	  real-time or interactive events by allowing a low priority process to
+	  be preempted even if it is in kernel mode executing a system call.
+	  This allows applications to run more reliably even when the system is
+	  under load.
 
-          Say Y here if you are building a kernel for a desktop, embedded
-          or real-time system.  Say N if you are unsure.
+	  Say Y here if you are building a kernel for a desktop, embedded
+	  or real-time system.  Say N if you are unsure.
 
 config IA32_SUPPORT
 	bool "Support running of Linux/x86 binaries"
@@ -430,21 +364,12 @@ config EFI_VARS
 	  To use this option, you have to check that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
-config NR_CPUS
-	int "Maximum number of CPUs"
-	depends on SMP
-	default "64"
-	help
-	  You should set this to the number of CPUs in your system, but
-	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
-	  only use 2 CPUs on a >2 CPU system.  Setting this to a value larger
-	  than 64 will cause the use of a CPU mask array, causing a small
-	  performance hit.
-
 source "fs/Kconfig.binfmt"
 
 if !IA64_HP_SIM
 
+source kernel/power/Kconfig
+
 source "drivers/acpi/Kconfig"
 
 config PCI
@@ -484,11 +409,9 @@ config HOTPLUG
 	  agent" (/sbin/hotplug) to load modules and set up software needed
 	  to use devices as you hotplug them.
 
-source "drivers/pci/hotplug/Kconfig"
-
 source "drivers/pcmcia/Kconfig"
 
-source "drivers/parport/Kconfig"
+source "drivers/pci/hotplug/Kconfig"
 
 endif
 
@@ -500,20 +423,24 @@ if !IA64_HP_SIM
 
 source "drivers/mtd/Kconfig"
 
+source "drivers/parport/Kconfig"
+
 source "drivers/pnp/Kconfig"
 
 source "drivers/block/Kconfig"
 
 source "drivers/ide/Kconfig"
 
-source "drivers/ieee1394/Kconfig"
-
-source "drivers/message/i2o/Kconfig"
+source "drivers/cdrom/Kconfig"
 
 source "drivers/md/Kconfig"
 
 source "drivers/message/fusion/Kconfig"
 
+source "drivers/ieee1394/Kconfig"
+
+source "drivers/message/i2o/Kconfig"
+
 endif
 
 
@@ -526,7 +453,7 @@ if !IA64_HP_SIM
 
 source "drivers/isdn/Kconfig"
 
-source "drivers/cdrom/Kconfig"
+source "drivers/telephony/Kconfig"
 
 #
 # input before char - char/joystick depends on it. As does USB.
@@ -573,8 +500,6 @@ source "drivers/usb/Kconfig"
 
 endif
 
-source "lib/Kconfig"
-
 source "arch/ia64/hp/sim/Kconfig"
 
 source "arch/ia64/oprofile/Kconfig"
@@ -604,6 +529,14 @@ config DEBUG_KERNEL
 	  Say Y here if you are developing drivers or trying to debug and
 	  identify kernel problems.
 
+config DEBUG_SLAB
+	bool "Debug memory allocations"
+	depends on DEBUG_KERNEL
+	help
+	  Say Y here to have the kernel do limited verification on memory
+	  allocation as well as poisoning memory on free to catch use of freed
+	  memory.
+
 config IA64_PRINT_HAZARDS
 	bool "Print possible IA-64 dependency violations to console"
 	depends on DEBUG_KERNEL
@@ -637,14 +570,6 @@ config MAGIC_SYSRQ
 	  keys are documented in <file:Documentation/sysrq.txt>. Don't say Y
 	  unless you really know what this hack does.
 
-config DEBUG_SLAB
-	bool "Debug memory allocations"
-	depends on DEBUG_KERNEL
-	help
-	  Say Y here to have the kernel do limited verification on memory
-	  allocation as well as poisoning memory on free to catch use of freed
-	  memory.
-
 config DEBUG_SPINLOCK
 	bool "Spinlock debugging"
 	depends on DEBUG_KERNEL
@@ -654,12 +579,6 @@ config DEBUG_SPINLOCK
 	  best used in conjunction with the NMI watchdog so that spinlock
 	  deadlocks are also debuggable.
 
-config DEBUG_SPINLOCK_SLEEP
-	  bool "Sleep-inside-spinlock checking"
-	  help
-	    If you say Y here, various routines which may sleep will become very
-	    noisy if they are called with a spinlock held.
-
 config IA64_DEBUG_CMPXCHG
 	bool "Turn on compare-and-exchange bug checking (slow!)"
 	depends on DEBUG_KERNEL
@@ -686,8 +605,16 @@ config DEBUG_INFO
 	  Say Y here only if you plan to use gdb to debug the kernel.
 	  If you don't debug the kernel, you can say N.
 	  
+config DEBUG_SPINLOCK_SLEEP
+	bool "Sleep-inside-spinlock checking"
+	help
+	  If you say Y here, various routines which may sleep will become very
+	  noisy if they are called with a spinlock held.	
+
 endmenu
 
 source "security/Kconfig"
 
 source "crypto/Kconfig"
+
+source "lib/Kconfig"

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
