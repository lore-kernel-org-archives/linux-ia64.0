From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 10 Oct 2002 19:42:14 +0000
Subject: [Linux-ia64] BitKeeper tree for 2.4.x
Message-Id: <marc-linux-ia64-105590709805154@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I am maintaining a BitKeeper tree that tracks Marcelo's 2.4.x
tree and the current ia64 patch.  My intent is that we will still
produce a plain patch against Marcelo's releases, just as David
has always done.  The BitKeeper tree merely provides visibility
into the current state of what will become the next ia64 patch.

I try to keep the BitKeeper tree working, but I don't do much
testing before updating it, so it should be regarded as unstable
work-in-progress.

The BitKeeper tools, licensing agreement, and documentation are
available here:

    http://www.bitkeeper.com

To get a local copy of the tree, use a BitKeeper command like
this:

    bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Subsequently, you can use "bk pull" in the linux-ia64-2.4/
directory to update your local repository.

The repository is hosted by BitMover, Inc., which provides a web
interface with a browsable source tree and ChangeSet history
here:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

Here are the interesting changes since the 2.4.19-ia64-020821 patch:

  * Driver changes:
    - bcm: dropped (you may be able to use tg3 instead).
    - e1000: dropped 4.1.7, adopted upstream (currently 4.3.15-k1).
    - e100: RX_ALIGN now upstream; only last_rx_time fix in ia64 patch.
    - acenic: dropped ia64 patches; upstream has most or all.
    - forte: dropped 1.45, adopted upstream (currently 1.51).

  * SPCR/DBGP support removed (encumbered by Microsoft IP; use HCDP instead).
  * McKinley A-step config doc removed (code was already gone).
  * HP prototype code removed (Matthew Wilcox).
  * include/asm-ia64/offsets.h removed.
  * sim{eth,scsi,serial} (drivers for HP simulator) moved to arch/ia64/hp/sim/.
  * drivers/media/{radio,video}/dummy.c removed.

  * Support for write-coalescing mappings removed.
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

Bjorn



