From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 04 Dec 2003 22:00:58 +0000
Subject: [PATCH] 2.4.x arch/ia64 update
Message-Id: <marc-linux-ia64-107057737007273@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Subject: bk pull

Hi Marcelo,

Please do a

	bk pull http://lia64.bkbits.net/to-marcelo-2.4

This will update the following files:

 arch/ia64/config.in              |    4 
 arch/ia64/configs/dig            |   32 +
 arch/ia64/configs/generic        |   34 +
 arch/ia64/configs/numa           |   34 +
 arch/ia64/configs/ski            |   17 
 arch/ia64/configs/zx1            |   32 +
 arch/ia64/defconfig              |   33 +
 arch/ia64/hp/common/sba_iommu.c  |  226 ++++++-----
 arch/ia64/hp/zx1/hpzx1_machvec.c |    2 
 arch/ia64/hp/zx1/hpzx1_misc.c    |   21 -
 arch/ia64/ia32/ia32_entry.S      |   13 
 arch/ia64/ia32/sys_ia32.c        |   46 ++
 arch/ia64/kernel/acpi.c          |    4 
 arch/ia64/kernel/efi.c           |   65 +--
 arch/ia64/kernel/gate.S          |   28 -
 arch/ia64/kernel/mca.c           |   44 +-
 arch/ia64/kernel/mca_asm.S       |  278 +++++++-------
 arch/ia64/kernel/pci.c           |    2 
 arch/ia64/kernel/perfmon.c       |    4 
 arch/ia64/kernel/salinfo.c       |  774 ++++++++++++++++++++++++---------------
 arch/ia64/kernel/setup.c         |    2 
 arch/ia64/kernel/time.c          |    1 
 arch/ia64/kernel/traps.c         |    4 
 arch/ia64/lib/Makefile           |    1 
 arch/ia64/lib/xor.S              |  184 +++++++++
 arch/ia64/mm/init.c              |    3 
 arch/ia64/mm/tlb.c               |    2 
 arch/ia64/tools/Makefile         |   15 
 include/asm-ia64/kmap_types.h    |   31 +
 include/asm-ia64/machvec.h       |    7 
 include/asm-ia64/machvec_hpzx1.h |   12 
 include/asm-ia64/mca.h           |    1 
 include/asm-ia64/mca_asm.h       |   12 
 include/asm-ia64/pal.h           |  172 +++++++-
 include/asm-ia64/param.h         |   33 -
 include/asm-ia64/sal.h           |    4 
 include/asm-ia64/uaccess.h       |   12 
 include/asm-ia64/xor.h           |  250 ------------
 38 files changed, 1461 insertions(+), 978 deletions(-)

through these ChangeSets:

<bjorn.helgaas@hp.com> (03/12/02 1.1199)
   ia64: update default configs

<kaos@sgi.com> (03/12/01 1.1198)
   ia64: sync salinfo.c with 2.6 (suser -> capable, use standard macros).
   
   Make salinfo.c more compatible with 2.6.  This is the 2.4 bit of
   http://marc.theaimsgroup.com/?l=linux-ia64&m6974968032730&w=2

<davidm@tiger.hpl.hp.com> (03/12/01 1.1197)
   ia64: Fix a bug in sigtramp() which corrupted ar.rnat when unwinding
   	across a signal trampoline (in user space).  Reported by
   	Laurent Morichetti.

<davidm@tiger.hpl.hp.com> (03/12/01 1.1196)
   ia64: Fix a alternate-signal-stack bug which could corrupt RNaT bits
   	when bspstore happened to point to an RNaT-slot.
   	Bug reported by Matt Chapman.

<kyle@engsoc.carleton.ca> (03/11/19 1.1162.14.25)
   ia64: Don't print anything for unimplemented syscalls.

<alex.williamson@hp.com> (03/11/19 1.1162.14.24)
   ia64: make hpzx1 fake pci device safer
   
      The fake PCI devices created in the 2.4 zx1 machvec provide PCI-like
   config space access to the chipset.  However, there are some registers
   in there that have side effects that you don't just want to stumble
   across.  These are all out beyond the configuration header space, so
   nothing should rely on them.  This patch prevents access to the
   dangerous one that you'd touch looking through /proc/bus/pci.  You can
   probably still shoot yourself in the foot, but you shouldn't be able to
   do it by reading through the proc files.  2.6 has removed these fake
   devices, so the patch is not applicable.

<kaos@sgi.com> (03/11/17 1.1162.14.23)
   ia64: Update PAL_MC_ERROR_INFO structures for SDM 2.1.

<kaos@sgi.com> (03/11/17 1.1162.14.22)
   ia64: Add the ability for user space salinfo to ask kernel salinfo
   	and/or the prom to decode the oem data sections of SAL records.
   
   The user space salinfo decode program can only dump oem data areas in
   hex, every ia64 platform has different oem data.  One option is to have
   OEM specific versions of the user space salinfo program, but that
   introduces version skew between user space and the kernel.  By
   definition, the prom knows best about what the oemdata means.
   
   This patch allows user space to write 'oemdata <cpu> <offset>' to
   /proc/sal/mca/data, passing the offset within the record of the EFI
   GUID at the start of the section that contains oemdata.  If the
   platform supports decoding of the oemdata then the next read from
   /proc/sal/mca/data will return the decoded text.  If the platform does
   not support decoding of oemdata, it returns EOF and user space salinfo
   defaults to printing oem data in hex, as before.

<kaos@sgi.com> (03/11/17 1.1162.14.21)
   ia64: Clean up kernel salinfo state checking.
   
   Different bits of arch/ia64/kernel/salinfo.c checked different fields
   to determine what state the processing was in.  Rationalise them all to
   a single state flag.  This also positions for the ability to extend
   kernel salinfo to handle more operations.
   
   Get rid of the new_read flag, read the record when the user asks for it
   or after clearing a record.

<jsm@fc.hp.com> (03/11/17 1.1162.14.20)
   ia64: fix show_mem() panic

<arun.sharma@intel.com> (03/11/14 1.1162.14.18)
   ia64: Don't mix user/kernel pointers in 32-bit stat/statfs emulation
   
   Andi Kleen's description:
   
       Jeff Dike pointed out that these functions access the user
       path name inside set_fs(KERNEL_DS). This allows the user
       to compare any memory that can be reached from 32bit syscalls 
       to a path name. 

<kochi@hpc.bs1.fc.nec.co.jp> (03/11/14 1.1162.14.17)
   [PATCH] ia64: don't access per-CPU data of off-line CPUs
   
   This patch prevents a crash that happens when per-CPU data is allocated
   only for CPUs that are online.

<bjorn.helgaas@hp.com> (03/10/30 1.1162.7.2)
   Cset exclude: kaos@sgi.com[helgaas]|ChangeSet|20031030215302|13517

<kaos@sgi.com> (03/10/30 1.1148.26.21)
   ia64: Clean up kernel salinfo state checking.
   
   Different bits of arch/ia64/kernel/salinfo.c checked different fields
   to determine what state the processing was in.  Rationalise them all to
   a single state flag.  This also positions for the ability to extend
   kernel salinfo to handle more operations.
   
   Get rid of the new_read flag, read the record when the user asks for it
   or after clearing a record.

<kaos@sgi.com> (03/10/30 1.1148.26.20)
   ia64: fix comment typo (sal.h)

<kaos@sgi.com> (03/10/30 1.1148.26.19)
   ia64: print header from INIT records

<arun.sharma@intel.com> (03/10/30 1.1148.26.18)
   [PATCH] ia64: make strace of ia32 processes work again
   
   Newer versions of strace manipulate the syscall arguments and to make this
   work for ia32 processes, we need to reload the syscall args after
   doing the syscall-trace callback.

<kaos@sgi.com> (03/10/23 1.1148.31.5)
   ia64: salinfo.c cleanup and race removal
   
   I have reworked salinfo.c to get a clean separation between the
   interrupt handler that is called from mca.c and the rest of the salinfo
   code that runs in user context.
   
   It is critical that the interrupt handler part of salinfo must never
   fail or deadlock, mca.c must be allowed to continue to get decent
   debugging information.  With this rework, the handler only saves the
   address of the buffer, sets the event bit and calls up() on the salinfo
   data semaphore then returns to mca.c.
   
   The information that was split between salinfo_event (4), salinfo_data
   (4) and salinfo_buffer (NR_CPUS*4) has been consolidated into a single
   salinfo_data (4) structure.  The consolidation simplifies the code and
   the locking.
   
   Use set_cpus_allowed() instead of using IPI to read and clear SAL
   records.  This does not disable interrupts and keeps the clean
   separation between interrupt and user context.  As a bonus, this code
   is ready for machines with > 64 cpus in a single system image.
   
   The rework removes the races and deadlocks that were mentioned on this
   list last week.  It also avoids multiple reads of the SAL record when
   user space has to read the record in multiple chunks.  I am still
   stress testing the code, this release is a request for comments.

<kaos@sgi.com> (03/10/23 1.1148.31.4)
   ia64: Trivial fixes for correct field type in formats.  prfunc_t does not
   	include attribute format so gcc does not pick these up automatically.

<davidm@tiger.hpl.hp.com> (03/10/23 1.1148.31.3)
   ia64: Fix efi_mem_type() and efi_mem_attributes() to avoid potential
   	underflows.  In my case, the underflows occurred with the
   	first memory descriptor which got trimmed down to a size of 0.
   	Due to the underflow, this descriptor ended up covering the entire
   	address-range which in turn caused Bad Things to happen with the
   	X server.

<bjorn.helgaas@hp.com> (03/10/22 1.1148.31.2)
   [PATCH] ia64: fix EFI memory map trimming
   
   This fixes a problem in EFI memory map trimming. For example,
   here's part of the memory map on my i2000:
   
       mem00: type=4, attr=0x9, range=[0x0000000000000000-0x0000000000001000) (0MB)
       mem01: type=7, attr=0x9, range=[0x0000000000001000-0x0000000000088000) (0MB)
       mem02: type=4, attr=0x9, range=[0x0000000000088000-0x00000000000a0000) (0MB)
       mem03: type=5, attr=0x8000000000000009, range=[0x00000000000c0000-0x0000000000100000) (0MB)
       mem04: type=7, attr=0x9, range=[0x0000000000100000-0x0000000004000000) (63MB)
       mem05: type=2, attr=0x9, range=[0x0000000004000000-0x00000000049ba000) (9MB)
       mem06: type=7, attr=0x9, range=[0x00000000049ba000-0x000000007ec0b000) (1954MB)
       ...
   
   There's a hole at 0xa0000-0xc0000, so we should ignore all the WB memory
   in that granule.  With 16MB granules, the existing code trims like this
   (note the 4K page at 0x0 should have been ignored, but wasn't).

<bjorn.helgaas@hp.com> (03/10/22 1.1148.27.7)
   ia64: add kmap_types.h to make crypto, etc compile.  (This is just
   	a dummy file from 2.6 and shouldn't ever be used.)

<iod00d@hp.com> (03/10/22 1.1148.27.6)
   ia64: put xor functions in .S file (backported from 2.6).
   
   gcc-3.3 doesn't like the asm("") spread out over 250 lines.
   I gather gcc-3.3 doesn't like line breaks inside a string.
   Besides, it just feels wrong to have a 250 line asm().
   
   Fortunately 2.6 already fixes this problem. Here's a "back port"
   of xor.S from davidm's linux-ia64-2.5 bk tree.
   
   BTW, since the function prototypes in xor.h are identical,
   I've assumed 2.6 xor.S is functionally identical/compatible too.
   
   grant

<tony.luck@intel.com> (03/10/22 1.1148.27.5)
   [PATCH] ia64: Another MCA fix
   
   The definition of the pal_process_state_info_s structure
   misses out some useful pieces (e.g. the "mi" bit which indicates
   whether we should call PAL_MC_ERROR_INFO to get more details).
   
   Worse yet, some of the bits are in the wrong places (cc/tc/bc).
   
   See Volume 2 of "Intel Itanium Architecture Software Developer's
   Manual".  (In the Rev 2.1 October 2002 edition, p. 2:268 and 2:276).

<tony.luck@intel.com> (03/10/22 1.1148.27.4)
   [PATCH] ia64: fix register numbers in MCA save/restore
   
   This corrects the save/restore code in mca_asm.S
   which was written long ago, before the assembler understood
   mnemonic names for 'cr' and 'ar' registers (in fact it
   appears to have been written pre-silicon, some of the
   control register numbers don't match with what actually
   got built).  There were other goofs too (like using
   0, 1, 2, etc. for region register subscripts).

<tony.luck@intel.com> (03/10/22 1.1148.27.3)
   [PATCH] ia64: infinite loop in ia64_mca_wakeup_ipi_wait
   
   This bugfix has been hiding inside the MCA TLB patches.
   
   There is an infinite loop in ia64_mca_wakeup_ipi_wait() because
   the compiler optimizes away the test at the bottom of the while
   loop.  It does this because IA64_MCA_WAKEUP_VECTOR is 0xf0, so
   irr_bit is known to be the constant 0x30, a.k.a. 48 in decimal.
   So when the compiler looks at the expression:
   
   
   It observes that 1' as unsigned
   long.

<bjorn.helgaas@hp.com> (03/10/10 1.1148.15.2)
   ia64: The "HP_ZX1" kernel works on sx1000-based machines as well as
   	zx1-based ones, so make the descriptions a little more generic.

<bjorn.helgaas@hp.com> (03/09/30 1.1136.4.6)
   ia64: Clear corrected errors (CMCs and CPEs) in the kernel
   
   If we don't clear them in the kernel, we'll "rediscover" the same error
   next time around.  So the kernel now reads the record, saves it (max
   of one buffered record per event per CPU), decodes part of it, and
   clears it from SAL.

<kochi@hpc.bs1.fc.nec.co.jp> (03/09/30 1.1136.4.5)
   ia64: initialize bootmem later, since acpi_table_init() doesn't need it.

<kaos@sgi.com> (03/09/30 1.1136.4.4)
   ia64: mca_asm.h documentation fixes
   
   Documentation fix for mca_asm.h.  Refer to the released Intel manual
   and correct a field name.  No functional changes.

<davidm@tiger.hpl.hp.com> (03/09/30 1.1136.4.3)
   ia64: Mark access_ok() as likely to succeed (as is done in x86 tree).

<khalid@fc.hp.com> (03/09/30 1.1136.4.2)
   ia64: do_settimeofday: fix compensation for lost ticks

<bjorn.helgaas@hp.com> (03/09/19 1.1120.4.3)
   ia64: Bail out of SBA init function if no IOC found.  Avoids spurious (but harmless)
   	"No IOC for PCI Bus 0000:00 in ACPI" messages when booting generic
   	kernel on non-ZX1 hardware.

<davidm@tiger.hpl.hp.com> (03/09/19 1.1120.4.2)
   ia64: Control /proc/bus/mckinley/zx1 via separate SBA_PROC_FS macro and turn
         SBA_PROC_FS off by default (it's too much of a scalability bottleneck).

<jbarnes@sgi.com> (03/09/18 1.1109.14.6)
   [PATCH] ia64: protect PAL mapping printk with EFI_DEBUG
   
   Having this print out for every CPU on a large system was a pain, so
   protect the printk with EFI_DEBUG.

<davidm@tiger.hpl.hp.com> (03/09/18 1.1109.14.5)
   ia64: In <asm-ia64/param.h>, do not include <linux/config.h> outside
   	the #ifdef __KERNEL__ bracket.  Doing so pollutes the user-
   	level namespace.  Bug report & proposed fix by GOTO Masanori.

<bjorn.helgaas@hp.com> (03/09/18 1.1109.14.4)
   ia64: Remove platform_pci_enable_device() machine vector and synchronize
   	sba_iommu.c with 2.5.

<arun.sharma@intel.com> (03/09/17 1.1109.12.5)
   ia64: CONFIG_IA32_SUPPORT can only be static, not a module

<kaos@sgi.com> (03/09/17 1.1109.12.4)
   ia64: fix offsets.h generation bootstrap problem
   
   2.4.22 deleted include/asm-ia64/offsets.h from the kernel tree.  If
   there is no other copy of that file on the include paths (say for cross
   compiling) then make dep breaks, offsets.h is required before you can
   build offsets.h.

<eranian@hpl.hp.com> (03/09/17 1.1109.12.3)
   ia64: perfmon-1 inheritance bugfix
   
   The attached patch fixes a long standing bug in the perfmon-1 implementation
   for all 2.4 based kernels.  The PFM_FL_INHERIT_ONCE flag is defined as
   allowing a perfmon context to be clone ONCE across fork. Without this
   fix, it is in fact clone to all first level child of the parent process.
   That's why, for instance, when you run pfmon-2.0 on a command, you see
   3 active per-process sessions instead of two (pfmon is multi-threaded).

<arun.sharma@intel.com> (03/09/17 1.1109.12.2)
   [PATCH] ia64: MINSIGSTKSZ on ia32
   
   MINSIGSTKSZ is defined differently for i386 and ia64. This patch improves
   compatibility with apps which use sigaltstack(2) with sizes between
   MINSIGSTKSZ_IA32 and MINSIGSTKSZ.


Thanks!

Bjorn

