From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 12 Mar 2004 23:05:45 +0000
Subject: bk pull on 2.4 ia64 linux tree
Message-Id: <200403121605.45744.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Marcelo,

Please do a

	bk pull http://lia64.bkbits.net/to-marcelo-2.4

This will update the files shown below.

Thanks,
  Bjorn


 arch/ia64/ia32/ia32_signal.c   |    2 
 arch/ia64/kernel/Makefile      |    2 
 arch/ia64/kernel/ia64_ksyms.c  |    2 
 arch/ia64/kernel/mca.c         | 2056 +++++++++--------------------------------
 arch/ia64/kernel/pci.c         |    4 
 arch/ia64/kernel/ptrace.c      |   48 
 arch/ia64/kernel/salinfo.c     |   59 +
 arch/ia64/kernel/signal.c      |    6 
 arch/ia64/kernel/smpboot.c     |    1 
 arch/ia64/kernel/unwind.c      |  238 ++--
 arch/ia64/kernel/unwind_i.h    |   10 
 arch/ia64/sn/kernel/mca.c      |   92 +
 arch/ia64/tools/Makefile       |    1 
 include/asm-ia64/a.out.h       |    4 
 include/asm-ia64/bugs.h        |    6 
 include/asm-ia64/byteorder.h   |    4 
 include/asm-ia64/checksum.h    |    4 
 include/asm-ia64/current.h     |    4 
 include/asm-ia64/errno.h       |    6 
 include/asm-ia64/fcntl.h       |    6 
 include/asm-ia64/ioctl.h       |    6 
 include/asm-ia64/ioctls.h      |    6 
 include/asm-ia64/mca.h         |   59 -
 include/asm-ia64/mman.h        |    6 
 include/asm-ia64/namei.h       |    4 
 include/asm-ia64/page.h        |    8 
 include/asm-ia64/param.h       |    6 
 include/asm-ia64/poll.h        |    6 
 include/asm-ia64/posix_types.h |    6 
 include/asm-ia64/processor.h   |   23 
 include/asm-ia64/resource.h    |    6 
 include/asm-ia64/scatterlist.h |    4 
 include/asm-ia64/siginfo.h     |    6 
 include/asm-ia64/signal.h      |    4 
 include/asm-ia64/socket.h      |    8 
 include/asm-ia64/sockios.h     |    9 
 include/asm-ia64/stat.h        |    4 
 include/asm-ia64/statfs.h      |    6 
 include/asm-ia64/termbits.h    |    6 
 include/asm-ia64/termios.h     |    4 
 include/asm-ia64/types.h       |    6 
 include/asm-ia64/uaccess.h     |    2 
 include/asm-ia64/unaligned.h   |    5 
 include/asm-ia64/unwind.h      |    6 
 include/asm-ia64/user.h        |    4 
 45 files changed, 882 insertions(+), 1883 deletions(-)

through these ChangeSets:

<bjorn.helgaas@hp.com> (04/03/04 1.1320)
   ia64: Remove obsolete sigcontext comment.

<bjorn.helgaas@hp.com> (04/03/04 1.1319)
   ia64: Use __builtin_trap() in BUG() when available.

<kaos@sgi.com> (04/03/04 1.1318)
   ia64: copy SAL records so we don't drop them when events occur fast
   
   Taking a copy of the record ensures that a continuous stream of CPE or
   CMC errors will still process some of the records.  Using a copy also
   saves space.  The buffers in mca.c are maximum size and are permanently
   allocated.  Doing a kmalloc in salinfo_log_wakeup uses smaller records
   (actual size rather than maximum) and the records will only exist for
   as long as they are required.

<davidm@tiger.hpl.hp.com> (04/03/04 1.1317)
   ia64: Fix bug in ia64_get_scratch_nat_bits()/ia64_put_scratch_nat_bits().

<davidm@tiger.hpl.hp.com> (04/03/03 1.1316)
   ia64: Back-port from libunwind: fix off-by-one error in kernel-unwinder.
   
   There are no known failures due to this bug, but it's clearly a bug and
   given the right compiler, it could trigger and lead to bad stack traces etc.

<kaos@sgi.com> (04/03/03 1.1315)
   ia64: add OEM data decode for SGI MCA handler
   
   salinfo_decode can call into the kernel to decode oem data, via the
   optional and platform specific program called salinfo_decode_oem.  SGI
   SN platforms decode oemdata by calling from kernel into the prom.

<bjorn.helgaas@hp.com> (04/03/03 1.1314)
   ia64: unwind: Add some UNW_DEBUG stuff and remove KDB bits to follow 2.6.

<kaos@sgi.com> (04/03/03 1.1313)
   ia64: update unwind with 2.6 fixes.
   
   The unwind code in 2.4.25 has drifted away from the 2.6.3 version,
   including some missing bug fixes.  This patch bring 2.4.25 unwind as
   close to 2.6.3 as possible.  Changes are :-
   
   * Move unw_table_entry from one header to another.
   * Add Fenghua Yu's change to pt_regs_off.  This is not really in 2.4
     yet, even though the comment says it is.
   * Comment and white space changes.
   * Bug fix to alloc_reg_state().
   * Replace struct_offset() with offsetof().
   * Export unw_* symbols.
   * Avoid deadlock on script->lock.
   
   
   I am not happy with the kludge that avoids the deadlock on
   script->lock, anybody got a better solution?  The kludge assumes that
   the first field in an ia64 rwsem is a spinlock.  I have hit this unwind
   deadlock a couple of times during processing of asynchronous MCA
   events, so I want it fixed.
   
   After this patch, the main differences between 2.4 and 2.6 are the
   handing of the gate page and its DSO data.

<arun.sharma@intel.com> (04/03/03 1.1312)
   ia64: Fix and optimize sys32_rt_sigtimedwait().
   
   Don't pass garbage timespec to sys_rt_sigtimedwait()
   when the user supplied NULL, and optimize uinfo slightly.

<kaos@sgi.com> (04/02/18 1.1310)
   ia64: Delete redundant ia64_mca_check_errors
   
   salinfo automatically processes all record types on all cpus at boot
   time, ia64_mca_check_errors is now redundant.  This also removes the
   need for a called_from_init flag on ia64_mca_log_sal_error_record.

<kaos@ocs.com.au> (04/02/11 1.1308)
   ia64: remove include/asm-ia64/offset.hs in "make mrproper"
   
   Some generated files are not being removed by make clean/mrproper.
   
   include/asm-ia64/offsets.h is built by 'make dep' so must be removed by
   'make mrproper', otherwise 'make dep clean' fails.

<kaos@sgi.com> (04/02/10 1.1306)
   ia64: Periodically check for outstanding MCA or INIT records.

<kaos@ocs.com.au> (04/02/10 1.1305)
   ia64: Correct "did we recover from MCA" test and move up a level.

<bjorn.helgaas@hp.com> (04/02/10 1.1304)
   ia64: (desc_abi): Check for Linux ABI # (3) instead of SysV4 ABI # (0).
   
   This and the corresponding change to arch/ia64/kernel/entry.h:
       (PT_REGS_SAVES): Add unwabi 3 directive (the official Linux ABI #).
   
   are tied to the pt_regs rearrangement in the "kernel entry exit
   optimization" patch from Rohit Seth, Fengua Yu, and Arun Sharma:
   
       The main items covered by this patch are:
       1) Support for 16 bytes instructions as per SDM2.1 (CSD/SSD in pt_regs)
       2) f10-f11 are added as additional scratch registers for kernel's use.
       3) Re-arrange pt_regs to access less cache lines in system call. Reduce
       scratch register saving/restoring in system call path.
       4) A few instruction reorg in low-level code.

<kaos@sgi.com> (04/02/06 1.1290.1.14)
   ia64: MCA, salinfo: calculate irq_safe once and pass it around.
   
   (Patch from Ben Woodward)

<kaos@sgi.com> (04/02/06 1.1290.1.13)
   ia64: Synchronize mca.c with 2.6.  White space, comment, #ifdef, etc.

<bjorn.helgaas@hp.com> (04/02/04 1.1290.1.11)
   ia64: Tidy up MCA printk's.

<kaos@sgi.com> (04/02/04 1.1290.1.10)
   ia64: Reorder mca.c to remove the need for forward declarations and to
   	consolidate related code.

<kaos@sgi.com> (04/02/04 1.1290.1.9)
   ia64: Delete dead variables and functions from mca.c.

<kaos@sgi.com> (04/02/04 1.1290.1.8)
   ia64: Mark MCA variables and functions static where possible

<kaos@sgi.com> (04/02/04 1.1290.1.7)
   ia64: Delete all MCA/INIT/etc record printing code, moved to salinfo_decode in
   	user space.

<kaos@sgi.com> (04/02/04 1.1290.1.6)
   ia64: Avoid deadlock when using printk() for MCA and INIT records.

<davidm@tiger.hpl.hp.com> (04/01/23 1.1276.5.2)
   ia64: Drop copyright notices on header files which are either entirely trivial
   	or ended up being trivial variations of another file.  Fix some
   	missing attributions and rephrase existing attributions for specifity.

<bjorn.helgaas@hp.com> (04/01/21 1.1276.4.2)
   ia64: (acpi_hp_csr_space): Export only if CONFIG_ACPI.

