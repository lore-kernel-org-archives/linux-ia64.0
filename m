From: Adrian Bunk <bunk@stusta.de>
Date: Tue, 07 Feb 2006 23:17:13 +0000
Subject: [2.6 patch] let IA64_GENERIC select more stuff
Message-Id: <20060207231713.GG3524@stusta.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060207221157.GA3524@stusta.de> <9883.1139351831@ocs3>
In-Reply-To: <9883.1139351831@ocs3>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keith Owens <kaos@sgi.com>
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Feb 08, 2006 at 09:37:11AM +1100, Keith Owens wrote:
> 
> A generic IA64 kernel requires (at least) the ACPI and NUMA options in
> order to run on all the IA64 platforms out there.  Omitting those
> options and relying on the user to set them by hand is going to cause
> more problems.
> 
> If anything, there should be more options being set as a side effect of
> selecting IA64_GENERIC, including ARCH_DISCONTIGMEM_ENABLE,
> ARCH_SPARSEMEM_ENABLE, PCI and even SMP.

IOW, you want the patch below?

Not that I'm a big fan of this approach, but if it should be done this 
way, it should be done right.

cu
Adrian


<--  snip  -->


Let IA64_GENERIC select more stuff (as wanted by the ia64 developers).


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig.old	2006-02-07 23:07:29.000000000 +0100
+++ linux-2.6.16-rc1-mm5-ia64/arch/ia64/Kconfig	2006-02-08 00:13:58.000000000 +0100
@@ -73,10 +73,12 @@
 config IA64_GENERIC
 	bool "generic"
 	select ACPI
 	select NUMA
 	select ACPI_NUMA
+	select PCI
+	select SMP
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
 	  a kernel for your specific system, it will be faster and smaller.
 
@@ -132,10 +134,11 @@
 	  This choice is safe for all IA-64 systems, but may not perform
 	  optimally on systems with, say, Itanium 2 or newer processors.
 
 config MCKINLEY
 	bool "Itanium 2"
+	depends on IA64_GENERIC=n
 	help
 	  Select this to configure for an Itanium 2 (McKinley) processor.
 
 endchoice
 
@@ -318,11 +321,11 @@
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
 	  or have huge holes in the physical address space for other reasons.
  	  See <file:Documentation/vm/numa> for more.
 
 config ARCH_FLATMEM_ENABLE
-	def_bool y
+	def_bool y if IA64_GENERIC=n
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	depends on ARCH_DISCONTIGMEM_ENABLE
 

