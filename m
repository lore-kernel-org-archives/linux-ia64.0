From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 30 Jun 2004 00:04:43 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200406300004.i5U04h7p027370@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Thanks!

	--david

 arch/ia64/Kconfig               |    2 
 arch/ia64/Makefile              |    3 
 arch/ia64/configs/sn2_defconfig |  486 ++++++++++++++++------------------------
 arch/ia64/kernel/efi_stub.S     |    6 
 arch/ia64/kernel/entry.S        |    4 
 arch/ia64/kernel/head.S         |   22 +
 arch/ia64/kernel/iosapic.c      |   25 --
 arch/ia64/kernel/module.c       |   22 +
 arch/ia64/kernel/pal.S          |   19 +
 arch/ia64/kernel/setup.c        |   29 ++
 arch/ia64/mm/discontig.c        |    2 
 arch/ia64/sn/io/sn2/bte_error.c |    4 
 arch/ia64/sn/kernel/bte.c       |  148 +++++++-----
 arch/ia64/sn/kernel/setup.c     |    3 
 include/asm-ia64/iosapic.h      |   21 +
 include/asm-ia64/smp.h          |    4 
 include/asm-ia64/sn/bte.h       |   49 +---
 include/asm-ia64/sn/pda.h       |    2 
 include/asm-ia64/sn/sn_cpuid.h  |    1 
 19 files changed, 437 insertions(+), 415 deletions(-)

through these ChangeSets:

<tony.luck@intel.com> (04/06/29 1.1808)
   [PATCH] ia64: fix reloc-out-of-range error on module loading
   
   I'm hitting this problem because the module I want to load was
   compiled with -g, so the filesize is absolutely huge.  kernel/module.c
   does a vmalloc() to inhale the entire file, and then two calls to
   module_alloc() (which calls vmalloc() on ia64) to load the 'init' and
   'core' sections. The 'init' is small and slips into a gap early in the
   vmalloc playspace, while the 'core' area is allocated after the huge
   area that was allocated for the inhaled copy of the whole file.
   
   I made a one coding change to Jean-Marc's version, adding a check to
   see whether the init/core sections are close enough together for the
   PCREL21B to reach (they almost always are).
   
   I've kept the test that there are no jumps from core to init (though
   the message that is printed is almost as unhelpful as the one that you
   get when you statically link a module into the kernel that has calls
   to the discarded .exit section :-)
   
   This patch stalled out before on the question of whether a PLT was
   overkill for a section-to-section branch, and whether it would be
   better to use relaxation techniques to extend the range.  Doing that
   might be more elegant in some way, but it needs a whole heap of extra
   code (to count how many relaxed branches need to be added and
   allocated them as needed).  This seems a lot of extra code that is
   only ever going to be exercised by maniacs like me with 49MB .ko
   files.
   
   I fixed up the comments to be a little more heplful.
   
   Signed-off-by: <tony.luck@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<jbarnes@engr.sgi.com> (04/06/29 1.1807)
   [PATCH] ia64: update early printk for new console driver
   
   The Altix console driver has been replaced in Andrew's tree by a new
   one that uses the serial core API.  Update the early_console_setup
   routine to use the new config option so that it's ready when the
   driver hits Linus' tree.  This will also fix a build bug since the old
   driver hasn't been updated.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<kenneth.w.chen@intel.com> (04/06/29 1.1806)
   [PATCH] ia64: fix incorrect initialization of ar.k4 for BP
   
   The patch to move the current pointer for init_task from region 7 to
   region 5 inadvertendly caused ar.k4 (CURRENT_STACK) to be initialized
   improperly for the bootstrap processor.  Fix this by initializing it
   to -1.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<kenneth.w.chen@intel.com> (04/06/29 1.1805)
   [PATCH] ia64: Clean up needlessly large stack frames in PAL-call stubs
   
   The code allocated all 96 stacked registers, for no apparent reason.
   
   Also, fix ia64_pal_call_static() to switch RSE to enforced-lazy, LE
   mode before the PAL-call.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<kenneth.w.chen@intel.com> (04/06/29 1.1804)
   [PATCH] ia64: change ia64_switch_mode_{phys,virt}() to preserve bsp/sp
   
   Change ia64_switch_mode_phys() and ia64_switch_mode_virt() to preserve
   the virtual sp/bsp and update the call-sites accordingly.  This avoids
   problems with the init_task pointer which lives in region 5 now.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<hjl@lucon.org> (04/06/29 1.1803)
   [PATCH] ia64: Don't use -mtune=merced for gcc 3.4
   
   Gcc 3.4 has a new DFA scheduler for ia64. Unfortunately, it is not
   well tested for Itanium 1. When I tried to use gcc 3.4 to compile
   2.6 kernel configured for Merced, gcc failed in many places:
   
   http://gcc.gnu.org/bugzilla/show_bug.cgi?id598
   http://gcc.gnu.org/bugzilla/show_bug.cgi?id653
   http://gcc.gnu.org/bugzilla/show_bug.cgi?id655
   http://gcc.gnu.org/bugzilla/show_bug.cgi?id130
   http://gcc.gnu.org/bugzilla/show_bug.cgi?id142
   http://gcc.gnu.org/bugzilla/show_bug.cgi?id143
   
   Some of them have been fixed. But I am afraid many more remain. I don't
   know how many Itanium 1 machines left in production use. If people want
   to optimize kernel for Itanium 1, they can stick with the older gccs.
   Or they should upgrade their machines. I think the gcc developer's time
   should be better spent on somewhere else. I have been using this patch
   for a while, kernel seems to work OK.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<bjorn.helgaas@hp.com> (04/06/29 1.1802)
   [PATCH] ia64: fix a couple of comment typos
   
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<bjorn.helgaas@hp.com> (04/06/29 1.1801)
   [PATCH] ia64: define cpu_logical_id() always
   
   Define cpu_logical_id() even when !SMP.  I added uses of this in some
   iosapic printk's, which broke the UP build.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<alex.williamson@hp.com> (04/06/25 1.1800)
   [PATCH] ia64: trashing bootmem on non-NUMA boxes
   
   call_pernode_memory() is rounding memory regions to page boundaries,
   but in the non-NUMA case, it's incorrectly passing the rounded start and
   the original length.  Any reserved memory regions sitting beyond a
   memory region that isn't nicely aligned is potentially at risk for
   getting freed and trashed.  This is a fairly nasty bug that can bite in
   very hard to find ways.  In my case, the EFI memory map was getting
   overwritten, causing the ACPI methods to access chipset registers
   cachable instead of uncachable.  It could potentially be causing some of
   the random hangs and strange behavior we're seeing lately.
   
   Signed-off-by: Alex Williamson <alex.williamson@hp.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<jbarnes@engr.sgi.com> (04/06/25 1.1799)
   [PATCH] ia64: another sn2_defconfig update
   
   This update fixes the FAT default NLS options and trims some others.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<bjorn.helgaas@hp.com> (04/06/25 1.1798)
   [PATCH] ia64: minor IOSAPIC cleanup
   
   Introduce iosapic_{read,write,eoi} to hide the IOSAPIC REG_SELECT
   stuff.  i386 and x86_64 already do this for io_apic_{read,write}.
   
   Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<jbarnes@engr.sgi.com> (04/06/25 1.1797)
   [PATCH] ia64: make SN2 use 16MB granules, too
   
   Altix needs to use 16MB granules to prevent attribute aliasing in low
   memory space.  This patch makes the kernel configuration system
   enforce that requirement.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<holt@sgi.com> (04/06/25 1.1796)
   [PATCH] ia64: Fixups for the SN2 Block Transfer Engine
   
   The attached patch contains some cleanups to the bte code and introduces
   the ability to excercise bte interfaces on other nodes.  This is an SGI
   Altix specific piece of hardware.
   
   Signed-off by: Robin Holt
   Signed-off by: Jesse Barnes
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<jbarnes@engr.sgi.com> (04/06/25 1.1795)
   [PATCH] ia64: early console registration
   
   Allow consoles to register early if they're capable of early output.
   If one of them registers successfully, set CPU 0 online so that
   printk() will actually call the console drivers.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

