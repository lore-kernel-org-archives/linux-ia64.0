From: tony.luck@intel.com
Date: Mon, 23 Aug 2004 21:23:48 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200408232123.i7NLNmw11016@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.9

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/sn/fakeprom/Makefile           |   29 -
 arch/ia64/sn/fakeprom/README             |   93 ---
 arch/ia64/sn/fakeprom/fpmem.c            |  252 ----------
 arch/ia64/sn/fakeprom/fpmem.h            |   76 ---
 arch/ia64/sn/fakeprom/fprom.lds          |  103 ----
 arch/ia64/sn/fakeprom/fpromasm.S         |  395 ---------------
 arch/ia64/sn/fakeprom/fw-emu.c           |  775 -------------------------------
 arch/ia64/sn/fakeprom/klgraph_init.c     |  205 --------
 arch/ia64/sn/fakeprom/main.c             |  109 ----
 arch/ia64/sn/fakeprom/make_textsym       |  174 ------
 arch/ia64/sn/fakeprom/runsim             |  387 ---------------
 arch/ia64/ia32/ia32_support.c            |    6 
 arch/ia64/kernel/cyclone.c               |    2 
 arch/ia64/kernel/head.S                  |    3 
 arch/ia64/kernel/time.c                  |    2 
 arch/ia64/lib/swiotlb.c                  |  114 +++-
 arch/ia64/sn/io/machvec/pci_bus_cvlink.c |    3 
 arch/ia64/sn/kernel/bte.c                |    7 
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c     |   24 
 include/asm-ia64/acpi.h                  |    3 
 include/asm-ia64/sal.h                   |    2 
 include/asm-ia64/sn/sn_cpuid.h           |    8 
 22 files changed, 138 insertions(+), 2634 deletions(-)

through these ChangeSets:

<jbarnes@sgi.com> (04/08/18 1.1970.1.1)
   [ACPI] ia64 build fix
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kenneth.w.chen@intel.com> (04/08/18 1.1982)
   [IA64] head.S: update comments to match code
   
   Update comments in function ia64_switch_mode_virt() to reflect actual
   implementation from recent region 5 init_task bug fix.
   
   Signed-off-by: Ken Chen <kenneth.w.chen@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/18 1.1981)
   [IA64] cyclone.c: Add includes for build on uni-processor.
   
   Small patch to fix the includes for the cyclone timer.  We just happen to be
   getting these if CONFIG_SMP is on, but if it's turned off the build breaks.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<roe@sgi.com> (04/08/18 1.1980)
   [IA64-SGI] report coherence id in /proc/sgi_sn/coherence_id
   
   Current SGI Altix systems have a NUMAlink domain size of 1024
   compute nodes and are fully cache coherent up to 256 compute
   nodes (compute nodes are even-numbered).  Systems larger than
   256 nodes are partitioned into multiple cache coherent systems.
   This patch exports a partition's coherence id to users via the
   /proc/sgi_sn/coherence_id file.
    
   Signed-off-by: Dean Roe <roe@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/18 1.1979)
   [IA64] time.c: Downgrade printk of cpu speed to KERN_DEBUG
   
   This patch turns the per-CPU frequency printk into a KERN_DEBUG instead of a
   KERN_INFO so it'll show up in the system log but won't be printed at boot,
   since it's a big pain on system with a lot of CPUs.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<edwardsg@sgi.com> (04/08/18 1.1978)
   [IA64] ia32_support.c: Check whether page_alloc failed.
   
   It's pretty unlikely these page allocations would fail, but we should
   still check them.
   
   Signed-off-by: Greg Edwards <edwardsg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (04/08/18 1.1977)
   [IA64-SGI] The SN2 fakeprom directories/files should be deleted.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/18 1.1976)
   [IA64-SGI] bte.c: kill expression as lvalue warning
   
   A recent patch caused a warning about not using expressions as lvalues
   to crop up in bte.c (or maybe it's just that I'm using gcc-3.4.1 now).
   This patch fixes it by creating a temporary to store the register whose
   address we want to get and stuff into the per-bte info structure.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/18 1.1975)
   [IA64-SGI] Assign parent to PCI devices.
   
   In working on the patch to export PCI ROM space via sysfs, I found that the
   sn2 PCI code doesn't assign a parent resource to any of the PCI device
   resources as it builds them.  This provides a simple fix for that problem.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<schwab@suse.de> (04/08/17 1.1974)
   [IA64] <asm-ia64/acpi.h> still declares deleted acpi_register_irq.
   
   Signed-off-by: Andreas Schwab <schwab@suse.de>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<seto.hidetoshi@jp.fujitsu.com> (04/08/17 1.1973)
   [IA64] floating point regs are not 16-byte aligned inside SAL error record
   
   Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<ak@suse.de> (04/08/17 1.1972)
   [IA64] various issues in the IA64 swiotlb code
   
   The biggest change is better overflow handling, partly ported from the AMD64 
   IOMMU  code.  This is important for some 3d drivers who make use of this and can 
   map a lot of memory.
   
   First it increases the default memory usage of swiotlb to 64MB.
   This was the value used in production systems in 2.4 (e.g. in SLES8) and the default
   was far too small.  Note this is only allocated when the swiotlb is needed.
   
   pci_map_single will not panic anymore on an overflow. Instead it returns
   a pointer to a scratch area and allows the caller to check using 
   dma_mapping_error(). It still panics when the overflow buffer is exceeded.
   
   dma_mapping_error support is implemented.
   
   pci_map_sg will never panic now, but just return 0. Near all callers 
   of it seem to have proper error checking for this (IDE will even handle
   it without erroring out) 
   
   The handling of passing a NULL device is improved, previously it would 
   never map in this case. i386 and other architectures assume NULL means a 4GB
   limit instead.   This code does this now too.
   
   I added support for swiotlb=force for easier testing.
   
   Patch supplied by Andi Kleen & Suresh Siddha
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/17 1.1971)
   [ACPI] ia64 build fix
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

