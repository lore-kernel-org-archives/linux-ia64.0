From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 21 Oct 2004 00:17:49 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200410210017.i9L0Hn210088@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.10

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Makefile                      |    3 
 arch/ia64/hp/common/sba_iommu.c         |    1 
 arch/ia64/ia32/ia32priv.h               |    4 
 arch/ia64/kernel/domain.c               |   32 
 arch/ia64/kernel/mca.c                  |    4 
 arch/ia64/kernel/unwind.c               |   81 
 arch/ia64/lib/swiotlb.c                 |   18 
 arch/ia64/mm/discontig.c                |    2 
 arch/ia64/mm/numa.c                     |    2 
 arch/ia64/pci/pci.c                     |    2 
 arch/ia64/sn/include/pci/pcidev.h       |    5 
 arch/ia64/sn/include/pci/pic.h          |    2 
 arch/ia64/sn/include/pci/tiocp.h        |    2 
 arch/ia64/sn/include/shub.h             |   24 
 arch/ia64/sn/kernel/io_init.c           |    2 
 arch/ia64/sn/kernel/iomv.c              |   12 
 arch/ia64/sn/kernel/setup.c             |   18 
 arch/ia64/sn/kernel/sn2/io.c            |   16 
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |  113 
 arch/ia64/sn/kernel/sn2/sn_hwperf.c     |   14 
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c    |   11 
 arch/ia64/sn/pci/pci_dma.c              |    1 
 arch/ia64/sn/pci/pcibr/pcibr_dma.c      |    4 
 drivers/char/snsc.c                     |    1 
 drivers/serial/sn_console.c             |    2 
 include/asm-ia64/machvec.h              |   32 
 include/asm-ia64/sn/addrs.h             |   32 
 include/asm-ia64/sn/io.h                |   40 
 include/asm-ia64/sn/shub_mmr.h          |31523 --------------------------------
 include/asm-ia64/topology.h             |   21 
 30 files changed, 294 insertions(+), 31730 deletions(-)

through these ChangeSets:

<jbarnes@sgi.com> (04/10/20 1.2010.1.10)
   [IA64-SGI] more sparse I/O accessor fixes
   
   I forgot to add 'const volatile' to the I/O read/write functions in the last
   patch, and also forgot to update the _relaxed variants.  This patch fixes
   that by adding 'const volatile' to the sn2 specific read/write routines as
   well as the ia64 machine vector wrappers.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/10/20 1.2010.1.9)
   [IA64-SGI] sparse cleanups & misc fixes for sn2
   
   This is a big patch mostly because I trimmed shub_mmr.h down from 17M to 11k
   or so.  It fixes a number of things sparse discovered and removes some dead
   code, fixes up some prototypes, etc.  Of note:
    
   o sn_proc_fs.c was directly dereferencing user pointers, fixed
   o sn_hwperf.c was missing an include and was using asm-ia64 directly
   o the I/O routines were all missing proper sparse annotations
   o dead code in prominfo_proc.c has been removed
   o fix generic build by putting numionodes into asm/sn/io.h
   
   With this patch applied, the check build is pretty clean.  The sn_console bit
   depends on some of the other changes, so it's included here.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/10/20 1.2010.1.8)
   [IA64] fix sba_iommu build
   
   sba_iommu.c needs to include linux/nodemask.h for node_online now.  Here's a
   patch to add it.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/20 1.2010.1.7)
   [IA64-SGI] Mod to allow functions other than zero to use virtual channel 1.
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/10/20 1.2010.1.6)
   [IA64-SGI] snsc.c: snsc needs asm/sn/io.h
   
   The sn system controller driver needs asm/sn/io.h in order to build correctly
   (it was missing the numionodes declaration).
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<pfg@sgi.com> (04/10/20 1.2010.1.5)
   [IA64] export sn_dma_mapping_error for libata
   
   Signed-off-by: Patrick Gefre <pfg@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/10/20 1.2010.1.4)
   [IA64] numa.c, discontig.c: sparse: use NULL, not 0
   
   Clean up a couple of places that were using 0 instead of NULL, which is the
   more proper value.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/10/20 1.2010.1.3)
   [IA64] mca.c: sparse cleanup
   
   Looks like we were casting a value into a union and sparse doesn't like that.
   Why not just assign it directly to the appropriate field?
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<hawkes@sgi.com> (04/10/20 1.2010.1.2)
   [IA64] top level scheduler domain for ia64
   
   Some have noticed that the overlapping sched domains code doesn't quite work
   as intended (it results in disjoint domains on some machines), and that a top
   level, machine spanning domain is needed.  This patch from John Hawkes adds
   it to the ia64 code.  This allows processes to run on all CPUs in large
   systems, though balancing is limited.  It should go to Linus soon now
   otherwise large systems will only have ~16p (depending on topology) usable by
   the scheduler.  I sanity checked it on a small system after rediffing John's
   original, and he's done some testing on very large systems.
    
    Nick, can you buy off on the sched.c change?  Alternatively, do you want to
    send that fix separately John? Nick did indeed ACK this change, but it isn't
    dependent on this ia64 specific part ... so it's going to be submitted
    separately.
     
   Signed-off-by: John Hawkes <hawkes@sgi.com>
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<suresh.b.siddha@intel.com> (04/10/20 1.1988.80.20)
   [IA64] fallback to swiotlb for consistent DMA mappings
   
   Patch supplied by Suresh Siddha
   
   This is mainly needed for EM64T platforms and makes sense for ia64 too.
   Need of this was broughtup sometime(long time?) back on lkml.
   http://www.ussg.iu.edu/hypermail/linux/kernel/0406.3/0112.html
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (04/10/20 1.1988.80.19)
   [IA64] Avoid a rare deadlock during unwind
   
   There is a rare deadlock condition during unwind script creation.  If
   build_script() is interrupted in the middle of creating the script, it
   holds the script write lock.  If the interrupt handler needs to call
   unwind for some failure condition, unwind will try to read the
   incomplete script and will deadlock on the script lock.
   
   The fix is to disable interrupts while building the script, so
   interrupt handlers never see partial scripts.
   
   Promoting spin_lock_irqsave() from script_new() to find_save_locs()
   changes the indentation, so the patch looks bigger than it really is.
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/10/20 1.1988.80.18)
   [IA64] uninitialised flags element could cause crashes
   
   window is not zeroed, so the flags should be assigned, not modified.
   This can lead to crashes at boot if the IO and Memory resources overlap.
   
   Patch supplied by Matthew Wilcox
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<arun.sharma@intel.com> (04/10/20 1.1988.80.17)
   [IA64] Add missing prototypes to kill warnings in sys_ia32.c
   
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/10/20 1.1988.80.16)
   [IA64] Allow -mtune=merced for gcc 3.4
   
   Patch submitted by H. J. Lu
   
     Gcc 3.4.2 fixed ia64 -mtune=merced regressions on Linux 2.6 kernel:
   
     http://gcc.gnu.org/bugzilla/show_bug.cgi?id278
   
     I have been using this patch for several months now.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

