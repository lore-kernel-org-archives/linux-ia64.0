From: "Luck, Tony" <tony.luck@intel.com>
Date: Sun, 23 Jan 2005 03:05:12 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200501230305.j0N35CT12199@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.11

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/sn/include/shub.h         |   39 --
 arch/ia64/configs/tiger_defconfig   |   59 +++-
 arch/ia64/ia32/binfmt_elf32.c       |    6 
 arch/ia64/ia32/sys_ia32.c           |    2 
 arch/ia64/kernel/domain.c           |    5 
 arch/ia64/kernel/efi.c              |    1 
 arch/ia64/kernel/entry.S            |  188 ++++++++------
 arch/ia64/kernel/entry.h            |   25 +
 arch/ia64/kernel/fsys.S             |    5 
 arch/ia64/kernel/gate.S             |    4 
 arch/ia64/kernel/irq.c              |   50 ---
 arch/ia64/kernel/irq_ia64.c         |    6 
 arch/ia64/kernel/ivt.S              |   25 +
 arch/ia64/kernel/mca.c              |    2 
 arch/ia64/kernel/mca_drv.c          |    2 
 arch/ia64/kernel/process.c          |    6 
 arch/ia64/kernel/ptrace.c           |    7 
 arch/ia64/kernel/smpboot.c          |    3 
 arch/ia64/kernel/unwind.c           |    9 
 arch/ia64/lib/bitop.c               |    2 
 arch/ia64/mm/contig.c               |    2 
 arch/ia64/pci/pci.c                 |    3 
 arch/ia64/sn/kernel/bte_error.c     |    1 
 arch/ia64/sn/kernel/irq.c           |   12 
 arch/ia64/sn/kernel/setup.c         |    9 
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |   46 +++
 arch/ia64/sn/pci/pci_dma.c          |  480 +++++++++++-------------------------
 drivers/char/drm/drm_vm.c           |   12 
 drivers/video/fbmem.c               |    9 
 include/asm-ia64/bitops.h           |    2 
 include/asm-ia64/hw_irq.h           |   16 -
 include/asm-ia64/machvec.h          |   15 -
 include/asm-ia64/machvec_init.h     |    2 
 include/asm-ia64/machvec_sn2.h      |    4 
 include/asm-ia64/pal.h              |   20 +
 include/asm-ia64/sal.h              |    2 
 include/asm-ia64/sn/sn_cpuid.h      |    1 
 include/asm-ia64/uaccess.h          |    2 
 include/asm-ia64/unistd.h           |    2 
 include/linux/efi.h                 |   21 +
 40 files changed, 500 insertions(+), 607 deletions(-)

through these ChangeSets:

<tony.luck@intel.com> (05/01/22 1.2017)
   [IA64] clean up loose ends from addition of efi_range_is_wc()
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/22 1.2016)
   [IA64] irq handling cleanup
   
   Patch from Christoph Hellwig to:
   - irq_desc and irq_to_vector machvecs.  SN2 has it's own versions,
     but they're the same as the generic ones
   - kill do do_IRQ and use __do_IRQ directly everywhere
   - kill dead X86 ifdefs
   - move some variable declarations around in irq.c to recuce # of ifdefs
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (05/01/22 1.2015)
   [IA64] remove superfluous layer from sn2 DMA API
   
   When I converted the sn2 code over to the new DMA API, I left the old routines
   in place and added wrappers to call them from the generic DMA API functions.
   This added an unnecessary level of obfuscation since the generic ia64 code
   calls those functions when any of the old style PCI DMA API functions are
   called.  This patch rectifies the problem making the code much easier to
   understand and hopefully a little more efficient (though I'm sure gcc was
   already inlining things pretty well, there were a bunch of unnecessary checks
   that I took this opportunity to remove).  It also shrinks the size of the sn2
   pci_dma.c quite a bit.
    
     pci_dma.c |  480 +++++++++++++++++++-----------------------------------------
     1 files changed, 151 insertions(+), 329 deletions(-)
       
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (05/01/22 1.2014)
   [IA64] fix early SAL init for sn2
   
   sn2 does early initialization of the SAL so it can use it for early console
   support.  Unfortunately, the loop to find the SAL entry point was buggy so
   when we tried out new EFI and SAL system table layouts, the loop didn't
   terminate.  Here's the fix (doh!, use two different loop counters instead of
   one and just return if we find the SAL entry point).
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (05/01/22 1.2013)
   [IA64] new api efi_range_is_wc()
   
   Ok, here you go Tony.  This one fixes the loop and also fixes drm_vm.c.  All
   of the bits aside from the efi.h bit are ia64 specific (either under
   arch/ia64 or __ia64__), so your tree is probably the right place for all of
   it.
    
   This patch adds efi_range_is_wc() to efi.h.  It's used to determine whether an
   address range can be mapped with the write coalescing attribute.  It also
   fixes up some ia64 specific callers to use the new routine instead of
   unconditionally calling pgprot_writecombined, which can be dangerous if used
   on ranges that don't support it.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jes@trained-monkey.org> (05/01/22 1.2012)
   [IA64] fix PAL_PREFETCH_VISIBILITY call
   
   The following patch fixes the ia64_pal_prefetch_visibility function to
   take a transaction type argument for either virtual or physical memory
   as specified in the System Architechture Manual page 2:358.
    
   Signed-Off-By: Jes Sorensen <jes@trained-monkey.org>
   Signed-Off-By: Tony Luck <tony.luck@intel.com>

<eranian@hpl.hp.com> (05/01/22 1.2011)
   [IA64] entry.S: perfmon psr.pp fix
   
   Problem:
   	There exists a case where we stop monitoring, i.e. clear
   	psr.pp/dcr.pp, via IPI. This is when the stop is triggered
   	by a close(), either explicit in the application or implicit
   	via exit_files(). The IPI is necessary because at the time the
   	thread (controlling the context) issues a close() it may not run
   	on the CPU the context is bound to. Yet the call must succeed,
   	hence we need to propagate the call to the right CPU.
   	But what is the problem then?
   	Under IPI, we invoke a perfmon routine which clear the kernel
   	(live) kernel psr.pp bit and also dcr.pp. Then we return from
   	the function and execute the kernel exit path which restores
   	the interrupted state. Unfortunately, this restores the kernel
   	psr from ipsr which now contains a stale value. Therefore
   	monitoring in the kernel will be active even though we stopped it.
   	You cannot modify the "global" psr in an interrupt routine because
   	it will be systematically restored on the way back.
   	
   Solution:
   	We need to patch ipsr.pp in the kernel exit path to reflect the
   	kernel value of the kernel psr.pp bit. This must be done only when
   	returning to kernel. 
   
   	The proposed patch does patch ipsr.pp such that it is identical
   	to psr.pp. The patch is subtle because the exit path does not have
   	a lot of free registers and also because we need to schedule for
   	a psr read. I had to shuffle  things around a little bit.
   
   	The patch is important because there will be another situation where
   	this problem can occur once we incorporate the support for event set
   	and multiplexing. In this configuration, you may be in the middle of
   	the idle loop and on a timer interrupt, you may stop monitoring.
   	Slightly different condition, yet same problem with ipsr.pp vs. psr.pp.
   
   
   Changelog:
   	- update kernel exit path when returning to kernel to copy
   	psr.pp to ipsr.pp. This is necesary to ensure that if psr.pp
   	was modified during the kernel entry, the change is propagated
   	the the psr.pp of the of the interrupted thread. Psr.pp can
   	be modified as a consequence of an IPI under certain conditions,
   	such as when a system-wide context is closed from a remote CPU.
   
   Special thanks to David for reworking the patch to fit
   into the enhanced exit path.
   
   signed-off-by: stephane eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/22 1.2010)
   [IA64] clean up ptrace corner cases
   
   Patch from yanmin.zhang@intel.com to fix up some corner cases
   in ptrace.  Many thanks to davidm for reviewing and improving.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/22 1.2009)
   [IA64] mca.c: delete unused "return_to_sal" label
   
   Label is unused, and so the compiler generates a warning.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.2008)
   [IA64] entry.S update the copyright year & fix a comment
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.2007)
   [IA64] Use srlz.d instead of srlz.i in ia64_leave_syscall
   
   Use srlz.d instead of srlz.i.  Safe because we don't care whether
   the VHPT walker sees the clearing of PSR.ic (if it does, that's fine
   if it doesn't, it's OK too since the kernel-text is pinned anyhow).
   Good for another 11+ cycles in (normal) getpid().
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.2006)
   [IA64] Improve ia64_leave_syscall() for McKinley-type cores.
   
   Optimize ia64_leave_syscall() a bit better for McKinley-type cores.
   The patch looks big, but that's mostly due to renaming r16/r17 to r2/r3.
   Good for a 13 cycle improvement.
    
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.2005)
   [IA64] Resched skip_rbs_switch to run 4 cycles faster on McKinley-type cores
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.2004)
   [IA64] entry.S: Align rse_clear_invalid to double-bundle boundary.
   
   Trivial patch: align rse_clear_invalid to 32-byte boundary.  Good for
   a 9 cycle speed up.
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.2003)
   [IA64] Don't forget to initialize PKStk for kernel-threads
   
   Kernel-threads had both pUStk and pKStk set to FALSE, which was
   unintentional.  I don't think the bug has shown any ill effects, but
   it's clearly wrong and could come around to bite us later, so let's
   fix it now.  Depends on the previous patch to clean up C usage of the
   global/root-function predicates.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.2002)
   [IA64] cleanup C uage of global/root-function predicates
    
   The patch below is purely a cleanup but it's a prerequisite for the
   next bug fix patch.
      
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<nacc@us.ibm.com> (05/01/22 1.2001)
   [IA64] smpboot.c: use msleep(100) instead of inlined equivalent
   
   Use msleep() instead of schedule_timeout() to guarantee the task
   delays as expected.
   
   Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<rja@sgi.com> (05/01/22 1.2000)
   [IA64] increase limit on #pages to isolate for MCA errors
   
   The fixed sized array of pages that are isolated because of 2xECC
   memory errors can run out.  Increasing the size of the array is a
   band-aid measure, the real fix will require changes to generic code
   to add some bits to page_flags so that pages with errors can be
   marked so as to prevent them ever being examined.
   
   Signed-off-by: Russ Anderson <rja@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.1999)
   [IA64] sys_ia32.c: add missing __user annotation for sparse
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (05/01/22 1.1998)
   [IA64] Sanity check unw_unwind_to_user
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.1997)
   [IA64] domain.c: eliminate warning when compiling CONFIG_NUMA=n
   
   When compiling for non-NUMA variable "node" ended up not being used,
   which solicits a warning from GCC.  Fix is to evluate cpu_to_node(i)
   in place.  This has the effect of doing cpu_to_node(i) twice on NUMA,
   but this is init code, so performance is not an issue (and even if
   it were, you can just declare cpu_to_node() as being a pure function,
   so the compiler can eliminate the second call).
   
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<davidm@hpl.hp.com> (05/01/22 1.1996)
   [IA64] uaccess.h: add missing __user annotation for sparse
   
   I was getting a lot of spurious warnings with "make C=1", due to a
   missing "__user" attribute.  I'm not sure whether this got lost or
   whether earlier versions of sparse failed to warn about it, but it's
   clearly needed (and the i386 version of uaccess.h does the same).
   	    
   Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/22 1.1995)
   [IA64] binfmt_elf32.c: BUG if insert_vm_struct fails
   
   It seems that in ia64_elf32_init, instead of calling return, if we insert
   an overlapping vma, we should instead BUG(). We should never get into this
   code path, because the vma's are set above PAGE_OFFSET, and thus a
   Xmalicious user can not trigger this code path. This change is being
   suggested mainly for clarity. Thanks to Stephen Tweedie for pointing out
   that returning early in ia64_elf32_init could have unpredictable results.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<markgw@sgi.com> (05/01/22 1.1994)
   [IA64] fix SN2 hwperf error handling
   
   Fix the error handling for the SN2 hardware perf ioctl interface.
    
   Signed-off-by: Mark Goodwin <markgw@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (05/01/22 1.1993)
   [IA64] Delete: arch/ia64/sn/include/shub.h
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (05/01/22 1.1992)
   [IA64] Delete duplicate SN2 definition of cpu_logical_id for UP build
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<bob.picco@hp.com> (05/01/22 1.1991)
   [IA64] fix declaration of __find_next_zero_bit, first arg is "const"
   
   Signed-off-by: Bob Picco <bob.picco@hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/22 1.1990)
   [IA64] tiger_defconfig: updated for 2.6.11-rc2
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/19 1.1986)
   [IA64] two trivial build fixes for generic uniprocessor
   
   Patches supplied by Dann Frazier.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<rja@sgi.com> (05/01/18 1.1984)
   [IA64] contig.c save physical address of MCA save area
   
   Ashok Raj uncovered a problem while testing the MCA code
   on a tiger box with contig memory.  The virtual address
   was getting saved instead of the physical address of the
   MCA save area.  This patch fixes that problem.
    
   Signed-off-by: Russ Anderson <rja@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

