From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sun, 21 Dec 2003 08:05:52 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <marc-linux-ia64-107199397320597@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105942507026161@msgid-missing>
In-Reply-To: <marc-linux-ia64-105942507026161@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Andrew,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Thanks!

	--david

 MAINTAINERS                     |    5 
 arch/ia64/Kconfig               |   16 
 arch/ia64/Makefile              |   11 
 arch/ia64/configs/sn2_defconfig |  693 ++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/Makefile       |    3 
 arch/ia64/kernel/acpi.c         |   62 ---
 arch/ia64/kernel/asm-offsets.c  |    4 
 arch/ia64/kernel/efi.c          |   12 
 arch/ia64/kernel/gate.S         |   10 
 arch/ia64/kernel/head.S         |    2 
 arch/ia64/kernel/ia64_ksyms.c   |    2 
 arch/ia64/kernel/iosapic.c      |    3 
 arch/ia64/kernel/irq.c          |   37 +-
 arch/ia64/kernel/ivt.S          |   54 +--
 arch/ia64/kernel/mca.c          |  211 +++++++-----
 arch/ia64/kernel/mca_asm.S      |  356 +++++++++++++-------
 arch/ia64/kernel/perfmon.c      |    2 
 arch/ia64/kernel/salinfo.c      |  525 +++++++++++++++++++++++++++++-
 arch/ia64/kernel/smpboot.c      |    2 
 arch/ia64/kernel/vmlinux.lds.S  |    2 
 arch/ia64/lib/Makefile          |    1 
 arch/ia64/lib/dec_and_lock.c    |   42 ++
 arch/ia64/mm/discontig.c        |  146 ++++----
 arch/ia64/mm/init.c             |   21 +
 arch/ia64/pci/pci.c             |    3 
 include/asm-ia64/acpi.h         |    3 
 include/asm-ia64/intrinsics.h   |    2 
 include/asm-ia64/mca.h          |   13 
 include/asm-ia64/numa.h         |    2 
 include/asm-ia64/numnodes.h     |    4 
 include/asm-ia64/pal.h          |  160 +++++++--
 include/asm-ia64/pgtable.h      |    4 
 include/asm-ia64/sal.h          |   12 
 include/asm-ia64/spinlock.h     |    2 
 include/asm-ia64/system.h       |    7 
 include/asm-ia64/uaccess.h      |  349 ++++++--------------
 36 files changed, 2082 insertions(+), 701 deletions(-)

through these ChangeSets:

<kaos@sgi.com> (03/12/20 1.1524)
   [PATCH] ia64: Convert cmc deadlock avoidance patch from 2.4 to 2.6
   

<tony.luck@intel.com> (03/12/19 1.1523)
   [PATCH] ia64: enable recovery from TLB errors
   
   Here's the updated version of the MCA TLB recovery patch.

<kaos@sgi.com> (03/12/19 1.1522)
   [PATCH] ia64: fix deadlock in ia64_mca_cmc_int_caller()
   
   smp_call_function() must not be called from interrupt context (can
   deadlock on tasklist_lock).  Use keventd to call smp_call_function().

<kaos@sgi.com> (03/12/19 1.1521)
   [PATCH] ia64: sync pal/sal/salinfo/mca with 2.4 code
   
   Forward port the recent changes to pal.h, sal.h, mca.h, salinfo.c and
   mca.c from 2.4.23-rc2 to 2.6.0-test9.
   
   This converts 2.6 to use salinfo instead of printing CMC/CPE/MCA/INIT
   records in the kernel.  It makes the two kernel versions as close
   together as possible.

<jbarnes@sgi.com> (03/12/19 1.1520)
   [PATCH] ia64: sn2 defconfig file
   
   As promised, here's a patch to add an sn2 defconfig file to get people
   started with 2.6 kernels.  I even turned on CONFIG_IA64_SGI_SIM support
   to make Jack happy :)

<jbarnes@sgi.com> (03/12/19 1.1519)
   [PATCH] ia64: initialize bootmem maps in reverse order
   
   The arch-independent bootmem code now requires that arches initialize
   their bootmem maps in reverse order (in particular, from high to low
   addesses), otherwise alloc_bootmem_pages_low() won't work.  This change
   makes the ia64 code do just that, so that machines without an IOMMU can
   allocate their bounce buffers in low memory at early boot.  It also adds
   a sanity check to the early init code to make sure that each node has a
   local data area, because if they don't, many things will break later on
   and may be hard to track down.

<bjorn.helgaas@hp.com> (03/12/19 1.1518)
   [PATCH] ia64: Prevent SAL calls from being preempted
   
   (SAL_CALL_REENTRANT): Disable preemption around the SAL call to
   make sure we don't get rescheduled on a different CPU.

<bjorn.helgaas@hp.com> (03/12/19 1.1517)
   [PATCH] ia64: Force generic and hp kernels to use 16MB granules
   
   This forces the granule size to 16MB for HP zx1 and generic
   kernels.  HP sx1000 machines require this.

<bjorn.helgaas@hp.com> (03/12/19 1.1516)
   [PATCH] ia64: Remove unused ACPI functions.
   
   Remove unused functions:
       acpi_get_prt()
       acpi_get_interrupt_model()
       acpi_get_addr_space()

<bjorn.helgaas@hp.com> (03/12/19 1.1515)
   [PATCH] ia64: Remove extraneous printks (we get the same information from ACPI).
   
   (iosapic_init): Remove extraneous printk.
   (pci_acpi_scan_root): Remove extraneous printk.

<bjorn.helgaas@hp.com> (03/12/19 1.1514)
   [PATCH] ia64: Fix PCI root bridge resources to handle prior allocations.
   
   (alloc_resources):  Use insert_resource(), not request_resource(), to
   allocate PCI root bridge windows.  This fixes the problem
   where root bridge window allocation fails because an early
   driver (like VGA) has already allocated things.

<jbarnes@sgi.com> (03/12/19 1.1513)
   [PATCH] ia64: make NODES_SHIFT a little biggger
   
   Make NODES_SHIFT larger to accomodate 256 node machines.

<jbarnes@sgi.com> (03/12/19 1.1512)
   [PATCH] ia64: update sn2 MAINTAINERS file entry
   

<jbarnes@sgi.com> (03/12/19 1.1511)
   [PATCH] ia64: make cpu_to_node_map unsigned
   
   This small fix is needed for machines with more than 128 nodes.

<steiner@sgi.com> (03/12/19 1.1510)
   [PATCH] ia64: prevent buffer-overrun in acpi_numa_memory_affinity_init()
   
   The code in acpi_numa_memory_affinity_init that sorts the node_memblk
   can overrun the array & clobber the memory that follows the end of the
   array. The error will be seen only on systems that fill the
   node_memblk array and only if SAL doesnt sort the entries in the SRAT.

<peterc@gelato.unsw.edu.au> (03/12/19 1.1509)
   [PATCH] ia64: enable out-of-tree compilation for IA64
   

<davidm@tiger.hpl.hp.com> (03/12/16 1.1507)
   ia64: Bring export of spin-lock contention-routines in sync with
   	this change:  Jim Wilson says that gcc v3.3 also supports
   	marking ar.pfs as clobbered, so use ia64_spinlock_contention()
   	for any GCC with v3.3 or newer.

<davidm@tiger.hpl.hp.com> (03/12/13 1.1506)
   ia64: Fix compiler warning in intrinsics.h.

<davidm@tiger.hpl.hp.com> (03/12/13 1.1505)
   ia64: Fix ivt overflow that occurred when turning on
   	CONFIG_DISABLE_VHPT.

<davidm@tiger.hpl.hp.com> (03/12/13 1.1504)
   ia64: Fix bug discovered by Bill Nottingham & Jakub Jelinek where
   	put_user() arguments with function-calls would cause the
   	macro to return unexpected values.  Fixed by avoiding macro
   	argument evaluation while r8/r9 are in use for exception-handling
   	purposes.  Also, consolidated access-macros so that GCC and
   	Intel compiler use 90% the same code.

<davidm@tiger.hpl.hp.com> (03/12/11 1.1503)
   ia64: Based on patch by Jerome Marchand: Add ia64-optimized
   	atomic_dec_and_lock().  Actually, this could be the generic
   	version for any platform that has cmpxchg().

<davidm@tiger.hpl.hp.com> (03/12/10 1.1502)
   ia64: Switch places for the gate pages and the guard page.  This improves
   	backwards-compatibility with older (broken) versions of GCC which
   	recognize a signal-handler only if it is in the address range
   	from 0xa000000000000100. to 0xa000000000020000.

<davidm@tiger.hpl.hp.com> (03/12/10 1.1501)
   ia64: Jim Wilson says that gcc v3.3 also supports marking ar.pfs as
   	clobbered, so use ia64_spinlock_contention() for any GCC with
   	v3.3 or newer.

<peter@chubb.wattle.id.au> (03/12/08 1.1500)
   [PATCH] ia64: make perfmon CONFIG_PREEMPT-safe again
   
   Here's a  fix for non-preemption safety in perfmon.c.
   
   I haven't tried it while running a preemption stress test, but this
   allows q-syscollect to work.

<jakub@redhat.com> (03/12/04 1.1499)
   [PATCH] ia64: fix typo in vmlinux.lds.S
   
   The security init section was incorrectly using PAGE_OFFSET instead of
   LOAD_OFFSET.

<pj@sgi.com> (03/12/01 1.1498)
   [PATCH] ia64: fix smp_affinity user-space accesses
   
   Here is a new improved patch for verifying user access to string
   passed in to kernel on write to /proc/irq/<pid>/smp_affinity.
   
   The access_ok() but missing __get_user() on each byte earlier patch
   has been replaced with a copy_from_user().
   
   I have built it and verified that it handles write requests
   as before, on an ia64 system (well - you can no longer pass
   more than 14 spaces after the 'R' - tough).

<davidm@tiger.hpl.hp.com> (03/11/26 1.1497)
   ia64: Fix a bug in sigtramp() which corrupted ar.rnat when unwinding
   	across a signal trampoline (in user space).  Reported by
   	Laurent Morichetti.

