From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 20 Jun 2003 18:50:03 +0000
Subject: Re: 2.5.72 for ia64 released
MIME-Version: 1
Content-Type: multipart/mixed; boundary="5I6of5zJg18YgZEa"
Message-Id: <marc-linux-ia64-105613502420459@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105605890319553@msgid-missing>
In-Reply-To: <marc-linux-ia64-105605890319553@msgid-missing>
To: linux-ia64@vger.kernel.org


--5I6of5zJg18YgZEa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

This one Works For Me (tm).  Does it look ok?

Thanks,
Jesse

On Fri, Jun 20, 2003 at 11:45:19AM -0700, Jesse Barnes wrote:
> On Fri, Jun 20, 2003 at 11:41:55AM -0700, David Mosberger wrote:
> > >>>>> On Fri, 20 Jun 2003 11:35:31 -0700, jbarnes@sgi.com (Jesse Barnes) said:
> > 
> >   Jesse> DISCONTIGMEM, NUMA, and ACPI_NUMA have to be turned on
> >   Jesse> automatically for generic kernels...
> > 
> > I thought the DISCONTIGMEM support is making assumptions about the
> > physical memory layout.  If this is still true, DISCONTIGMEM and
> > GENERIC cannot go together.
> 
> No, the discontig patch I posted earlier should allow this.  We've
> tested it quite a bit in 2.4.
> 
> > I suspect it would be more preferable if you could make it possible
> > for a non-NUMA kernel to boot on your machine.
> 
> That might be nice, but I'd rather have CONFIG_GENERIC turn on
> CONFIG_NUMA.  It shouldn't get in the way of non-NUMA machines...
> 
> Thanks,
> Jesse
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--5I6of5zJg18YgZEa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ia64-kconfig-2.5.72-ia64-bk.patch"

===== drivers/acpi/Kconfig 1.9 vs edited =====
--- 1.9/drivers/acpi/Kconfig	Tue Mar 25 13:32:08 2003
+++ edited/drivers/acpi/Kconfig	Fri Jun 20 11:34:15 2003
@@ -133,7 +133,7 @@
 
 config ACPI_NUMA
 	bool "NUMA support" if NUMA && (IA64 && !IA64_HP_SIM || X86 && ACPI && !ACPI_HT_ONLY && !X86_64)
-	default y if IA64 && IA64_SGI_SN
+	default y if IA64_GENERIC || IA64_SGI_SN2
 
 config ACPI_TOSHIBA
 	tristate "Toshiba Laptop Extras"
===== arch/ia64/Kconfig 1.33 vs edited =====
--- 1.33/arch/ia64/Kconfig	Thu Jun 19 00:54:35 2003
+++ edited/arch/ia64/Kconfig	Fri Jun 20 11:41:52 2003
@@ -210,8 +210,8 @@
 	  system with an A0 or A1 stepping CPU.
 
 config NUMA
-	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y if IA64_SGI_SN2
+	bool
+	default y if IA64_SGI_SN2 || IA64_GENERIC
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor
@@ -235,8 +235,7 @@
 
 config DISCONTIGMEM
 	bool
-	depends on IA64_SGI_SN2 || (IA64_GENERIC || IA64_DIG || IA64_HP_ZX1) && NUMA
-	default y
+	default y if IA64_SGI_SN2 || IA64_GENERIC
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
@@ -245,8 +244,7 @@
 
 config VIRTUAL_MEM_MAP
 	bool "Enable Virtual Mem Map"
-	depends on !NUMA
-	default y if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
+	default y if !IA64_HP_SIM
 	help
 	  Say Y to compile the kernel with support for a virtual mem map.
 	  This is an alternate method of supporting large holes in the
@@ -259,8 +257,8 @@
 	  are unsure, say Y.
 
 config IA64_MCA
-	bool "Enable IA-64 Machine Check Abort" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y if IA64_SGI_SN2
+	bool "Enable IA-64 Machine Check Abort"
+	default y if !IA64_HP_SIM
 	help
 	  Say Y here to enable machine check support for IA-64.  If you're
 	  unsure, answer Y.
@@ -292,43 +290,12 @@
 	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2
 	default y
 
-config IA64_SGI_SN_DEBUG
-	bool "Enable extra debugging code"
-	depends on IA64_SGI_SN2
-	help
-	  Turns on extra debugging code in the SGI SN (Scalable NUMA) platform
-	  for IA-64.  Unless you are debugging problems on an SGI SN IA-64 box,
-	  say N.
-
 config IA64_SGI_SN_SIM
 	bool "Enable SGI Medusa Simulator Support"
 	depends on IA64_SGI_SN2
 	help
 	  If you are compiling a kernel that will run under SGI's IA-64
 	  simulator (Medusa) then say Y, otherwise say N.
-
-config IA64_SGI_AUTOTEST
-	bool "Enable autotest (llsc). Option to run cache test instead of booting"
-	depends on IA64_SGI_SN2
-	help
-	  Build a kernel used for hardware validation. If you include the
-	  keyword "autotest" on the boot command line, the kernel does NOT boot.
-	  Instead, it starts all cpus and runs cache coherency tests instead.
-
-	  If unsure, say N.
-
-config SERIAL_SGI_L1_PROTOCOL
-	bool "Enable protocol mode for the L1 console"
-	depends on IA64_SGI_SN2
-	help
-	  Uses protocol mode instead of raw mode for the level 1 console on the
-	  SGI SN (Scalable NUMA) platform for IA-64.  If you are compiling for
-	  an SGI SN box then Y is the recommended value, otherwise say N.
-
-config PERCPU_IRQ
-	bool
-	depends on IA64_SGI_SN2
-	default y
 
 # On IA-64, we always want an ELF /proc/kcore.
 config KCORE_ELF

--5I6of5zJg18YgZEa--
