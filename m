From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Sat, 17 Jan 2004 00:22:36 +0000
Subject: Re: [PATCH] Kconfig cleanup, part 1
Message-Id: <200401161722.36261.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401161136.37066.bjorn.helgaas@hp.com>
In-Reply-To: <200401161136.37066.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 16 January 2004 2:39 pm, Peter Chubb wrote:
>  config IA64_HP_ZX1
> -	bool "HP-zx1"
> +	bool "HP"
> 
> Please don't do this.  You'll get people selecting it for the HP
> I2000 and RX4610, which are *not* based on the ZX1 chipset, even
> though they're made by HP.

OK, here's a revision of the patch that addresses this problem.  First
the interdiff, with the revised whole patch following:

diff -u edited/arch/ia64/Kconfig edited/arch/ia64/Kconfig
--- edited/arch/ia64/Kconfig	Fri Jan 16 11:14:30 2004
+++ edited/arch/ia64/Kconfig	Fri Jan 16 17:14:56 2004
@@ -69,7 +69,7 @@
 
 	  generic	 For any supported IA-64 system
 	  DIG-compliant  For DIG ("Developer's Interface Guide") compliant systems.
-	  HP		 For HP systems
+	  HP-zx1/sx1000	 For HP zx1 and sx1000 systems
 	  SGI-SN2	 For SGI Altix systems
 	  Ski-simulator  For the HP simulator (<http://www.hpl.hp.com/research/linux/ski/>)
 
@@ -79,10 +79,10 @@
 	bool "DIG-compliant"
 
 config IA64_HP_ZX1
-	bool "HP"
+	bool "HP-zx1/sx1000"
 	help
-	  Build a kernel that runs on HP systems.  This adds support
-	  for the HP I/O MMU.
+	  Build a kernel that runs on HP zx1 and sx1000 systems.  This adds
+	  support for the HP I/O MMU.
 
 config IA64_SGI_SN2
 	bool "SGI-SN2"

---------------------------------------------------------------------
Here comes the revised entire patch:

=== arch/ia64/Kconfig 1.52 vs edited ==--- 1.52/arch/ia64/Kconfig	Mon Dec 29 23:09:39 2003
+++ edited/arch/ia64/Kconfig	Fri Jan 16 17:14:56 2004
@@ -16,10 +16,11 @@
 	  The Itanium Processor Family is Intel's 64-bit successor to
 	  the 32-bit X86 line.  The IA-64 Linux project has a home
 	  page at <http://www.linuxia64.org/> and a mailing list at
-	  linux-ia64@linuxia64.org.
+	  linux-ia64@vger.kernel.org.
 
 config 64BIT
-	def_bool y
+	bool
+	default y
 
 config MMU
 	bool
@@ -34,13 +35,13 @@
 	default y
 
 choice
-	prompt "IA-64 processor type"
+	prompt "Processor type"
 	default ITANIUM
 
 config ITANIUM
 	bool "Itanium"
 	help
-	  Select your IA-64 processor type.  The default is Intel Itanium.
+	  Select your IA-64 processor type.  The default is Itanium.
 	  This choice is safe for all IA-64 systems, but may not perform
 	  optimally on systems with, say, Itanium 2 or newer processors.
 
@@ -52,7 +53,7 @@
 endchoice
 
 choice
-	prompt "IA-64 system type"
+	prompt "System type"
 	default IA64_GENERIC
 
 config IA64_GENERIC
@@ -61,41 +62,34 @@
 	select ACPI_NUMA
 	select VIRTUAL_MEM_MAP
 	select DISCONTIGMEM
-	---help---
+	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
 	  a kernel for your specific system, it will be faster and smaller.
 
-	  To find out what type of IA-64 system you have, you may want to
-	  check the IA-64 Linux web site at <http://www.linux-ia64.org/>.
-	  As of the time of this writing, most hardware is DIG compliant,
-	  so the "DIG-compliant" option is usually the right choice.
-
-	  HP-simulator   For the HP simulator
-	  (<http://software.hp.com/ia64linux/>).
-	  HP-zx1         For HP zx1-based systems.
+	  generic	 For any supported IA-64 system
+	  DIG-compliant  For DIG ("Developer's Interface Guide") compliant systems.
+	  HP-zx1/sx1000	 For HP zx1 and sx1000 systems
 	  SGI-SN2	 For SGI Altix systems
-	  DIG-compliant  For DIG ("Developer's Interface Guide") compliant
-	  systems.
+	  Ski-simulator  For the HP simulator (<http://www.hpl.hp.com/research/linux/ski/>)
 
 	  If you don't know what to do, choose "generic".
 
 config IA64_DIG
 	bool "DIG-compliant"
 
-config IA64_HP_SIM
-	bool "HP-simulator"
-
 config IA64_HP_ZX1
-	bool "HP-zx1"
+	bool "HP-zx1/sx1000"
 	help
-	  Build a kernel that runs on HP zx1-based systems.  This adds support
-	  for the zx1 I/O MMU and makes root bus bridges appear in PCI config
-	  space (required for zx1 agpgart support).
+	  Build a kernel that runs on HP zx1 and sx1000 systems.  This adds
+	  support for the HP I/O MMU.
 
 config IA64_SGI_SN2
 	bool "SGI-SN2"
 
+config IA64_HP_SIM
+	bool "Ski-simulator"
+
 endchoice
 
 choice
@@ -104,7 +98,7 @@
 
 config IA64_PAGE_SIZE_4KB
 	bool "4KB"
-	---help---
+	help
 	  This lets you select the page size of the kernel.  For best IA-64
 	  performance, a page size of 8KB or 16KB is recommended.  For best
 	  IA-32 compatibility, a page size of 4KB should be selected (the vast
@@ -135,7 +129,7 @@
 	bool
 	depends on !IA64_HP_SIM
 	default y
-	---help---
+	help
 	  ACPI/OSPM support for Linux is currently under development. As such,
 	  this support is preliminary and EXPERIMENTAL.  Configuring ACPI
 	  support enables kernel interfaces that allow higher level software
@@ -183,7 +177,7 @@
 	default y
 
 config ITANIUM_BSTEP_SPECIFIC
-	bool "Enable Itanium B-step specific code"
+	bool "Itanium B-step specific code"
 	depends on ITANIUM
 	help
 	  Select this option to build a kernel for an Itanium prototype system
@@ -198,38 +192,30 @@
 
 # align cache-sensitive data to 64 bytes
 config MCKINLEY_ASTEP_SPECIFIC
-	bool "Enable McKinley A-step specific code"
+	bool "McKinley A-step specific code"
 	depends on MCKINLEY
 	help
 	  Select this option to build a kernel for an IA-64 McKinley prototype
 	  system with any A-stepping CPU.
 
 config MCKINLEY_A0_SPECIFIC
-	bool "Enable McKinley A0/A1-step specific code"
+	bool "McKinley A0/A1-step specific code"
 	depends on MCKINLEY_ASTEP_SPECIFIC
 	help
 	  Select this option to build a kernel for an IA-64 McKinley prototype
 	  system with an A0 or A1 stepping CPU.
 
 config NUMA
-	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y if IA64_SGI_SN2 || IA64_GENERIC
+	bool "NUMA support"
+	depends on !IA64_HP_SIM
+	default y if IA64_SGI_SN2
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor
 	  server systems.  If in doubt, say N.
 
-config DISCONTIGMEM
-	bool "Discontiguous memory support" if (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC) && NUMA && VIRTUAL_MEM_MAP
-	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
-	help
-	  Say Y to support efficient handling of discontiguous physical memory,
-	  for architectures which are either NUMA (Non-Uniform Memory Access)
-	  or have huge holes in the physical address space for other reasons.
-	  See <file:Documentation/vm/numa> for more.
-
 config VIRTUAL_MEM_MAP
-	bool "Enable Virtual Mem Map"
+	bool "Virtual mem map"
 	default y if !IA64_HP_SIM
 	help
 	  Say Y to compile the kernel with support for a virtual mem map.
@@ -238,8 +224,18 @@
 	  require the DISCONTIGMEM option for your machine. If you are
 	  unsure, say Y.
 
+config DISCONTIGMEM
+	bool "Discontiguous memory support"
+	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC) && NUMA && VIRTUAL_MEM_MAP
+	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
+	help
+	  Say Y to support efficient handling of discontiguous physical memory,
+	  for architectures which are either NUMA (Non-Uniform Memory Access)
+	  or have huge holes in the physical address space for other reasons.
+	  See <file:Documentation/vm/numa> for more.
+
 config IA64_MCA
-	bool "Enable IA-64 Machine Check Abort"
+	bool "Machine Check Abort"
 	default y if !IA64_HP_SIM
 	help
 	  Say Y here to enable machine check support for IA-64.  If you're
@@ -249,7 +245,7 @@
 	bool "Power Management support"
 	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
 	default y
-	---help---
+	help
 	  "Power Management" means that parts of your computer are shut
 	  off or put into a power conserving "sleep" mode if they are not
 	  being used.  There are two competing standards for doing this: APM
@@ -269,11 +265,11 @@
 
 config IOSAPIC
 	bool
-	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2
+	depends on !IA64_HP_SIM
 	default y
 
 config IA64_SGI_SN_SIM
-	bool "Enable SGI Medusa Simulator Support"
+	bool "SGI Medusa Simulator Support"
 	depends on IA64_SGI_SN2
 	help
 	  If you are compiling a kernel that will run under SGI's IA-64
@@ -284,7 +280,7 @@
 	default "18"
 
 choice
-	prompt "IA-64 Huge TLB Page Size"
+	prompt "Huge TLB page size"
 	depends on HUGETLB_PAGE
 	default HUGETLB_PAGE_SIZE_16MB
 
@@ -318,7 +314,7 @@
 
 config IA64_PAL_IDLE
 	bool "Use PAL_HALT_LIGHT in idle loop"
-	---help---
+	help
 	  Say Y here to enable use of PAL_HALT_LIGHT in the cpu_idle loop.
 	  This allows the CPU to enter a low power state when idle.  You
 	  can enable CONFIG_IA64_PALINFO and check /proc/pal/cpu0/power_info
@@ -326,24 +322,34 @@
 	  unsure your firmware supports it, answer N.
 
 config SMP
-	bool "SMP support"
-	---help---
+	bool "Symmetric multi-processing support"
+	help
 	  This enables support for systems with more than one CPU. If you have
-	  a system with only one CPU say N. If you have a system with more than
-	  one CPU, say Y.
+	  a system with only one CPU, say N.  If you have a system with more
+	  than one CPU, say Y.
 
 	  If you say N here, the kernel will run on single and multiprocessor
-	  systems, but will use only one CPU of a multiprocessor system. If
+	  systems, but will use only one CPU of a multiprocessor system.  If
 	  you say Y here, the kernel will run on many, but not all,
-	  singleprocessor system. On a singleprocessor system, the kernel
+	  single processor systems.  On a single processor system, the kernel
 	  will run faster if you say N here.
 
-	  See also the <file:Documentation/smp.tex>,
-	  <file:Documentation/smp.txt>, and the SMP-HOWTO available at
-	  <http://www.tldp.org/docs.html#howto>.
+	  See also the <file:Documentation/smp.txt> and the SMP-HOWTO
+	  available at <http://www.tldp.org/docs.html#howto>.
 
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
         help
@@ -356,8 +362,13 @@
           Say Y here if you are building a kernel for a desktop, embedded
           or real-time system.  Say N if you are unsure.
 
+config HAVE_DEC_LOCK
+	bool
+	depends on (SMP || PREEMPT)
+	default y
+
 config IA32_SUPPORT
-	bool "Support running of Linux/x86 binaries"
+	bool "Support for Linux/x86 binaries"
 	help
 	  IA-64 processors can execute IA-32 (X86) instructions.  By
 	  saying Y here, the kernel will include IA-32 system call
@@ -370,11 +381,6 @@
 	depends on IA32_SUPPORT
 	default y
 
-config HAVE_DEC_LOCK
-	bool
-	depends on (SMP || PREEMPT)
-	default y
-
 config PERFMON
 	bool "Performance monitor support"
 	help
@@ -394,7 +400,6 @@
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
-
 config EFI
 	bool
 	depends on !IA64_HP_SIM
@@ -410,17 +415,6 @@
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
@@ -448,7 +442,7 @@
 
 config HOTPLUG
 	bool "Support for hot-pluggable devices"
-	---help---
+	help
 	  Say Y here if you want to plug devices into your computer while
 	  the system is running, and be able to use them quickly.  In many
 	  cases, the devices can likewise be unplugged at any time too.

