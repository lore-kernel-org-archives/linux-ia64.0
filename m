From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 02 Jul 2003 17:08:36 +0000
Subject: kernel update (relative to 2.4.21)
Message-Id: <marc-linux-ia64-105716647121510@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 kernel patch for Linux 2.4.21 is available here:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.21-ia64-030702.diff.gz

The current 2.4-based ia64 tree is also available as a BitKeeper
repository.  You can browse the changelog and the source files with a
normal browser at:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

or you can use the BitKeeper tools to maintain a local copy of the
tree like this:

    $ bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Bjorn



Changes since the June 3, 2003 2.4.21 interim patch:

    - runtime platform detection (Martin Hicks).
    - add hugetlb uid/gid/etc mount options and file attributes (Rohit Seth).
    - export EFI system table info in /proc (Chad Smith).
    - work around ia32 race condition (Arun Sharma).
    - fix ia32 msgsnd/msgrcv off-by-4 error (Arun Sharma).
    - fix ia32 munmap size = 0 return (Arun Sharma).
    - fix ia32 mmap (addr + len > IA32_PAGE_OFFSET) error (Arun Sharma).
    - don't allow ptrace to set syscall arg NaT bits (John Marvin).
    - SGI SN update 030630 (John Hesterberg).
    - ignore empty address ranges from ACPI _CRS.

Changes since the 2.4.20-ia64-021210 patch:

  * IA64:
    - bugfix in ia64_fls() (Dan Magenheimer, David Mosberger).
    - fix 64->32 bit truncation in brl emulation (Arun Sharma).
    - fix signal delivery when current register frame is incomplete (David
      Mosberger).
    - fix siginfo.si_addr for SIGSEGV from NaT-page-consumption faults (David
      Mosberger).
    - predicate srlz.d after clearing psr.i (David Mosberger).
    - read/write semaphores using atomic ops (Ken Chen).
    - moved ia64_fetch_and_add() el al to intrinsics.h (from David Mosberger's
      2.5 changes).
    - improve optimization of ia64_fetch_and_add (David Mosberger).
    - print ISR for FPSWA faults (Martin Hicks).
    - don't sync ITC if they may drift (Jes Sorensen).
    - fix timer interrupt loss when syncing ITC (Alex Williamson).
    - delay TLB flushing to avoid smp_call_function in context switch path.
    - disable interrupts during context switch to fix occasional hang in
      threaded programs (Bjorn Helgaas, Stephane Eranian, John Marvin).
    - move mmu_gathers into local_cpu_data (Martin Hicks).
    - fix ptrace writes of R4-R7 (David Mosberger).
    - fix corruption of kernel NaT bits via ptrace (David Mosberger).
    - fix page-fault handling of not-present translations in region 5 (John
      Marvin).
    - support for hugetlb (backported from 2.5) (Rohit Seth).
    - fix FPH owner tracking (Asit Mallick, David Mosberger, Arun Sharma).
  * I/O:
    - add barrier so sba_iommu IOPDIR updates are visible (Alex Williamson).
    - remove sym53c8xx "duplicate device detection" (needed to support
      multi-PCI domains).
    - probe only PCI buses reported by ACPI.
    - support multiple IO port spaces (via ACPI PCI root bridge resources).
    - export io_space symbol (Jes Sorensen).
    - fill in /proc/io{mem,ports} with ACPI PCI root bridge resources.
    - various IOSAPIC cleanups.
    - HP Diva multiport serial card fixes (Paul Bame).
    - sync up sba_iommu with 2.5.
    - use seq_file in sba_iommu for large /proc files.
    - implement pcibios_set_mwi() (Grant Grundler, David Mosberger).
  * ACPI:
    - compile fix for ACPI without PCI (Jesse Barnes).
    - leftover SPCR code removed (Matthew Wilcox).
    - add acpi_walk_namespace() and acpi_resource_to_address64().
    - support serial ports from ACPI namespace (Khalid Aziz, Bjorn Helgaas).
    - check _CID and _HID in ACPI hot-plug controller driver (Matthew Wilcox).
    - remove unused acpi_get_addr_space() interface.
    - add acpi_find_vendor_resource for GUID-identified vendor resources.
  * Perfmon (Stephane Eranian):
    - upgrade to 1.4.
    - fix broken system-wide monitoring overflow notifications.
    - correct McKinley opcode matcher reserved bitmask.
    - update to avoid smp_call_function in context-switch path.
  * MCA/CMC/CPE:
    - poll for CPEs on all CPUs (Alex Williamson).
    - poll for CMCs if interrupts happen too fast (Alex Williamson).
    - fix MCA stack size (Keith Owens).
    - set 'always rendezvous for mca' flag (Keith Owens).
    - set rendezvous timeout to 20 seconds (Keith Owens).
    - handle SAL requirements for minimum rendezvous timeout (Keith Owens).
    - dump min-state area in INIT handler (David Mosberger).
    - print backtrace in INIT handler (David Mosberger).
    - fix INIT copying of banked registers (David Mosberger).
    - export SAL logs in /proc/sal/cpuX/ (Bjorn Helgaas).
  * Unwind:
    - cleanups and fixes (David Mosberger, Keith Owens).
    - fix unwind pt_regs_off usage (Andreas Schwab).
    - don't reference past end of unwind-table (Suresh Siddha, David Mosberger).
    - added unwind info consistency checker ("make check") (Harish Patil, David
      Mosberger).
    - improve show_trace_task portability (Vladimir Simonov).
    - fix scratch-regs in coredumps (David Mosberger).
    - call get_scratch_regs only when really needed (Keith Owens).
  * IA32 emulation:
    - fix sys32_mprotect semaphore drop (Arun Sharma).
    - make sys32_ptrace use ptrace_check_attach (Andreas Schwab).
    - make sys32_ipc return -ENOSYS (not -EINVAL) for unknown call number
      (David Mosberger).
    - fix kernel thread address space for request_module from ia32 process
      (Andreas Schwab).
    - make CONFIG_SYSCTL control sys32_sysctl (Peter Chubb, Bjorn Helgaas).
    - add totalhigh, freehigh,mem_unit to  sys32_sysinfo (reported by Andrew
      Clausen).
    - don't turn on O_LARGEFILE automatically on open() (David Mosberger).
    - fix msgctl emulation (Arun Sharma).
    - fix shmctl(IPC_SET) (Arun Sharma).
    - fix shmctl(IPC_STAT) (Arun Sharma).
    - check for bad command in semctl (Arun Sharma).
    - correct rlimit cur/max declarations (Arun Sharma).
    - fix ptrace FPREGS (Venkatesh Pallipadi).
  * Configs:
    - update defconfig.
    - add sample configs in arch/ia64/configs.
    - sim{eth,scsi,serial} (drivers for HP simulator) moved back to drivers/ to
      fix initialization ordering problems.
    - simscsi updated with 2.5 features (i.e., disk size detection).
    - SGI SN files updated (John Hesterberg).
  * Misc bug-fixes:
    - fix early_printk() declaration (Suresh Siddha).
    - workaround in agpgart_be.c for gcc-3.2.2 defect (reported by Alex
      Williamson).
    - export pm_idle (reported by Steve Goldman and Alex Tsariounov).
    - declare test_bit() address as "const" (Peter Chubb).
    - fix efivars locking issues (Matt Domsch, Peter Chubb, David Mosberger).
    - vmlinux.lds.S: Move __start/__end inside sections (Suresh Siddha, David
      Mosberger).
    - wrap pal.h in #ifdef __KERNEL__ for apps that include <linux/modules.h>.
  * Misc cleanup:
    - clean up printk severity levels (from 2.5 change).
    - C99 initializers (from Rusty Russell's 2.5 patch).
    - fix unaligned macros to avoid name clashes (David Mosberger).
    - fix /proc/pal/.../vm_info memory attributes (David Mosberger).
    - consolidate/replace cpu_is_online() with cpu_online() (Martin Hicks).
    - simplify syscalls with force_successful_syscall_return() (from 2.5).
    - remove redundant "cpu not responding message".

Note 1:
    As part of making SAL error records visible in /proc, I removed the dump
    of MCA records on the console.  A user-level daemon can retrieve and
    decode the error records.  A simple example of such a daemon is available
    here:

	    ftp://kernel.org/pub/linux/kernel/people/helgaas/salinfo-0.2.tar.gz

    N.B.:  The kernel used to clear error records from the SAL log.  In the
    new scheme, it is the user-level daemon's responsibility to clear the
    records.  If there is no daemon, the records won't get cleared, and the
    firmware log may fill up, preventing future errors from being logged.

Note 2:
    I normally use either a gcc-2.96 x86->ia64 cross compiler or a gcc-3.2.3
    native compiler, and both work fine for me.  Using the unreleased
    gcc-3.3.1 native compiler, I see test case failures related to signal
    delivery, so I'd avoid that compiler until this is better understood.

