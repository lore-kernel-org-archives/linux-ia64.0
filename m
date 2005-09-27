From: Bob Picco <bob.picco@hp.com>
Date: Tue, 27 Sep 2005 19:22:43 +0000
Subject: Re: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <20050927192243.GU16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050922161418.GW16066@localhost.localdomain>
In-Reply-To: <20050922161418.GW16066@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Bob Picco wrote:	[Tue Sep 27 2005, 10:09:20AM EDT]
> luck wrote:	[Mon Sep 26 2005, 08:03:09PM EDT]
> > >I'm assuming you refer to the config changes in arch/ia64/Kconfig. Well the
> > >new ones are documented in mm/Kconfig.  If that documentation is inadequate,
> > >then I can attempt to supply more.
> > 
> > There aren't any words in there about why I might want to use
> > sparsemem ... just a standard version of if you don't know what
> > to pick, go with the old discontig stuff.
> I can't say there is disagreement with this point. So you'd obviously like
> more help text in mm/Kconfig?
> > 
> > 
> > >Should you think we won't get sufficient test converage without some default
> > >configuration files, then I'd suggest the two mentioned about be introduced.
> > 
> > This is definitely the prime issue ... config space on ia64
> > is already very fragmented, so testting of some combination
> > of options is rare to non-existant.  If SPARSEMEM isn't turned
> > on, then it won't be used by anyone that isn't already reading
> > the lhms list.  Coupled with the lack of sales pitch in the
> > Kconfig help files, it looks like this isn't going to be used
> > by anyone!
> Yep. I thought this is what you are after.
> > 
> > >Long term should SPARSEMEM become the default and DISCONTIG+VIRTUAL_MEM_MAP
> > >be obsoleted then we could remove the config files.
> > 
> > If benchmarks show no difference, then I'll consolidate the
> > configuration options.  I still think that VIRTUAL_MEM_MAP
> > has a great deal of elegance to it ... auto-sizing to just
> > about any degree of sparseness, but I think we need to
> > simplify.
> Well I'm not attempting to be critical of VIRTUAL_MEM_MAP. Obviously it 
> satisfies a solution which was previously unanswered. I'm just hoping to reduce
> our configuration options.  We aren't even remotely close to possibly
> considering this.
> > 
> The bigsur problem isn't nodedata.h related. It's in arch/ia64/Kconfig which
> figures. I should have this resolved some time today after checking
> the default configs.
> > -Tony
> > -
> bob
Okay. There was a bug in my Kconfig.  All defconfigs and my own memory model
configs build correctly and produce the correct config options.  Below is
a replacement for patch 1/4 which I've included for your config testing.  I'll
post V5 patchset when we agree on where we want to proceed with config(s).  

I'm thinking all we need is sparsemem_defconfig which is defconfig but with
the SPARSEMEM memory model.  

thanks,

bob

 arch/ia64/Kconfig     |   94 +++++++++++++++++++++++++++++---------------------
 arch/ia64/mm/Makefile |    5 +-
 2 files changed, 58 insertions(+), 41 deletions(-)

Index: linux-2.6.14-rc2/arch/ia64/Kconfig
=================================--- linux-2.6.14-rc2.orig/arch/ia64/Kconfig	2005-09-26 19:16:57.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/Kconfig	2005-09-27 14:31:21.000000000 -0400
@@ -63,8 +63,6 @@ config IA64_GENERIC
 	select ACPI
 	select NUMA
 	select ACPI_NUMA
-	select VIRTUAL_MEM_MAP
-	select DISCONTIGMEM
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
@@ -176,40 +174,6 @@ config IA64_L1_CACHE_SHIFT
 	default "6" if ITANIUM
 
 # align cache-sensitive data to 64 bytes
-config NUMA
-	bool "NUMA support"
-	depends on !IA64_HP_SIM
-	default y if IA64_SGI_SN2
-	select ACPI_NUMA
-	help
-	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
-	  Access).  This option is for configuring high-end multiprocessor
-	  server systems.  If in doubt, say N.
-
-config VIRTUAL_MEM_MAP
-	bool "Virtual mem map"
-	default y if !IA64_HP_SIM
-	help
-	  Say Y to compile the kernel with support for a virtual mem map.
-	  This code also only takes effect if a memory hole of greater than
-	  1 Gb is found during boot.  You must turn this option on if you
-	  require the DISCONTIGMEM option for your machine. If you are
-	  unsure, say Y.
-
-config HOLES_IN_ZONE
-	bool
-	default y if VIRTUAL_MEM_MAP
-
-config ARCH_DISCONTIGMEM_ENABLE
-	bool "Discontiguous memory support"
-	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB) && NUMA && VIRTUAL_MEM_MAP
-	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
-	help
-	  Say Y to support efficient handling of discontiguous physical memory,
-	  for architectures which are either NUMA (Non-Uniform Memory Access)
-	  or have huge holes in the physical address space for other reasons.
-	  See <file:Documentation/vm/numa> for more.
-
 config IA64_CYCLONE
 	bool "Cyclone (EXA) Time Source support"
 	help
@@ -232,8 +196,10 @@ config IA64_SGI_SN_XP
 	  based on a network adapter and DMA messaging.
 
 config FORCE_MAX_ZONEORDER
-	int
-	default "18"
+	int "MAX_ORDER (11 - 17)"  if !HUGETLB_PAGE
+	range 11 17  if !HUGETLB_PAGE
+	default "17" if HUGETLB_PAGE
+	default "11"
 
 config SMP
 	bool "Symmetric multi-processing support"
@@ -298,6 +264,58 @@ config PREEMPT
 
 source "mm/Kconfig"
 
+config ARCH_SELECT_MEMORY_MODEL
+	def_bool y
+
+config ARCH_DISCONTIGMEM_ENABLE
+	def_bool y
+	help
+	  Say Y to support efficient handling of discontiguous physical memory,
+	  for architectures which are either NUMA (Non-Uniform Memory Access)
+	  or have huge holes in the physical address space for other reasons.
+ 	  See <file:Documentation/vm/numa> for more.
+
+config ARCH_FLATMEM_ENABLE
+	def_bool y
+
+config ARCH_SPARSEMEM_ENABLE
+	def_bool y
+	depends on ARCH_DISCONTIGMEM_ENABLE
+
+config ARCH_DISCONTIGMEM_DEFAULT
+	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
+	depends on ARCH_DISCONTIGMEM_ENABLE
+
+config NUMA
+	bool "NUMA support"
+	depends on !IA64_HP_SIM && !FLATMEM
+	default y if IA64_SGI_SN2
+	help
+	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
+	  Access).  This option is for configuring high-end multiprocessor
+	  server systems.  If in doubt, say N.
+
+# VIRTUAL_MEM_MAP and FLAT_NODE_MEM_MAP are functionally equivalent.
+# VIRTUAL_MEM_MAP has been retained for historical reasons.
+config VIRTUAL_MEM_MAP
+	bool "Virtual mem map"
+	depends on !SPARSEMEM
+	default y if !IA64_HP_SIM
+	help
+	  Say Y to compile the kernel with support for a virtual mem map.
+	  This code also only takes effect if a memory hole of greater than
+	  1 Gb is found during boot.  You must turn this option on if you
+	  require the DISCONTIGMEM option for your machine. If you are
+	  unsure, say Y.
+
+config HOLES_IN_ZONE
+	bool
+	default y if VIRTUAL_MEM_MAP
+
+config HAVE_ARCH_EARLY_PFN_TO_NID
+	def_bool y
+	depends on NEED_MULTIPLE_NODES
+
 config IA32_SUPPORT
 	bool "Support for Linux/x86 binaries"
 	help
Index: linux-2.6.14-rc2/arch/ia64/mm/Makefile
=================================--- linux-2.6.14-rc2.orig/arch/ia64/mm/Makefile	2005-09-26 19:16:57.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/mm/Makefile	2005-09-26 19:49:27.000000000 -0400
@@ -7,6 +7,5 @@ obj-y := init.o fault.o tlb.o extable.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
 obj-$(CONFIG_DISCONTIGMEM) += discontig.o
-ifndef CONFIG_DISCONTIGMEM
-obj-y += contig.o
-endif
+obj-$(CONFIG_SPARSEMEM)	   += discontig.o
+obj-$(CONFIG_FLATMEM)	   += contig.o
