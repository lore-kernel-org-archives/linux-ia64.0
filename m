From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Wed, 11 Dec 2002 04:44:12 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.20)
Message-Id: <marc-linux-ia64-105590709805540@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 kernel patch for Linux 2.4.20 is available here:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.20-ia64-021210.diff.gz

The current 2.4-based ia64 tree is also available as a BitKeeper
repository.  You can browse the changelog and the source files with a
normal browser at:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

or you can use the BitKeeper tools to maintain a local copy of the
tree like this:

    $ bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Note that the SPCR and DBGP support has been removed.  In the opinion
of HP lawyers, that support contained Microsoft intellectual property,
so they requested its removal.

Bjorn


Changes since the 2.4.19-ia64-020821 patch:

  * Driver changes:
    - bcm: dropped (you may be able to use tg3 instead).
    - e1000: dropped 4.1.7, adopted upstream (currently 4.4.12-k1)
    - e100: RX_ALIGN now upstream; only last_rx_time fix in ia64 patch.
    - acenic: dropped ia64 patches; upstream has most or all.
    - forte: dropped 1.45, adopted upstream (currently 1.55).

  * SPCR/DBGP support removed (encumbered by Microsoft IP; use HCDP instead).
  * McKinley A-step config doc removed (code was already gone).
  * HP prototype code removed (Matthew Wilcox).
  * include/asm-ia64/offsets.h removed.
  * sim{eth,scsi,serial} (drivers for HP simulator) moved to arch/ia64/hp/sim/.
  * drivers/media/{radio,video}/dummy.c removed.
  * Support for /dev/mem write-coalescing mappings removed.
  * Support for non-cached mappings of main memory removed.
  * Support scatterlist page/offset in sba_iommu.
  * AGP/DRM rework to make it more presentable.
    - DRM: dropped obsolete #ifdef __alpha__ diffs.
    - DRM: r128, radeon: made all 460GX checks run-time, not compile-time.
  * ACPI CRS cleanup (Takayoshi Kochi).
  * ACPI debug fixes (Takayoshi Kochi).
  * Fix many warnings (Andreas Schwab).
  * Fix I/O macros (inb, outb, etc) (Andreas Schwab, David Mosberger).
  * If more than NR_CPUS found, ignore extras.
  * Add generic RAID xor routines with prefetch (Matthew Wilcox).
  * Discard *.text.exit and *.data.exit sections (Matthew Wilcox).
  * Fix edge-triggered IRQ handling (David Mosberger).
  * Alternate signal stack fixes (David Mosberger).
  * VFS extended attribute syscall numbers (Andreas Gruenbacher).
  * binfmt argv[1] preservation (David Mosberger).
  * Preserve FP registers around firmware calls (John Marvin, David Mosberger).
  * FPU load/save optimization (Fenghua Yu).
  * Syscalls for Extended Attribute VFS infrastructure (Andreas Gruenbacher).
  * Use virtual mem map automatically when needed (John Marvin).
  * Fix mremap when returning "negative" addresses (Matt Chapman, David Mosberger).
  * Add breakpoint hook for simulator (Peter Chubb, David Mosberger).
  * Fix memcpy to return destination address (Ken Chen).
  * Fix EFI handling of complicated memory maps (David Mosberger).
  * Fix ACPI global lock acquire/release (David Mosberger).
  * __init/__devinit fixup for PCI hotplug (Jung-Ik Lee).
  * Fix TLB flushing for multi-threaded address spaces on SMP (David Mosberger).
  * Bugfixes and cleanup in MCA logging (Jenna Hall).
  * Poll for corrected platform errors if no CPE interrupt (Alex Williamson).
  * MCA and data corruption fixes in HP ZX1 IOMMU driver (Alex Williamson).
    - NOTE: SGI pci_dma.c requires corresponding changes.
  * HP ZX1 AGP bridge detected via ACPI, not fake PCI devices.
  * Perfmon update to version 1.2 (Stephane Eranian).
  * Scan PCI buses 0-255 (not 0-254).
  * Skip blind PCI probe when root bridges reported by ACPI.
  * ACPI: backport bugfix so we see all 460GX PCI root bridges.
  * Save/restore FP state in IA32 exception handling (Venkatesh Pallipadi).
  * IA32 ptrace: support xmm regs, bug fixes (Venkatesh Pallipadi).
  * Fix several unaligned access problems (David Mosberger).
  * Fix fork/ptrace deadlock (David Mosberger).

The following major pieces of the ia64 patch are unchanged since
2.4.19-ia64-020821:

  * ACPI: CA version 20020517 (upstream has version 20011018).
  * qla1280: 3.23 Beta (upstream has 3.00-Beta).
  * qla2x00: 4.31.7b (not in upstream).

NOTE: I removed the mmap support for MAP_WRITECOMBINED and
MAP_NONCACHED to avoid issues with memory attribute aliasing.
The only user of these that I know about is XFree86, which still
seems functional when we ignore the attributes it requests.  I'm
very interested in any problems caused by this change.


