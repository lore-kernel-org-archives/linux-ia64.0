From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 09 Sep 2003 17:28:32 +0000
Subject: kernel update (relative to 2.4.22)
Message-Id: <marc-linux-ia64-106312897006127@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 kernel patch for Linux 2.4.22 is available here:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.22-ia64-030909.diff.gz

The current 2.4-based ia64 tree is also available as a BitKeeper
repository.  You can browse the changelog and the source files with a
normal browser at:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

or you can use the BitKeeper tools to maintain a local copy of the
tree like this:

    $ bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Bjorn


Changes since the 2.4.21-ia64-030702 patch:

  * IA64:
    - kernel entry/exit optimizations (Rohit Seth).
    - add support for 16-byte instructions (CSD/SSD) (Rohit Seth).
    - get supported TLB purge page sizes from PAL (Rohit Seth).
    - use "hint @pause" in cpu_relax() and spinlock contention path (Rohit Seth).
    - add barrier to cpu_relax() (Bjorn Helgaas).
    - use PAL_HALT_LIGHT in cpu_idle() (disabled in generic config to avoid
	firmware defects) (Alex Williamson).
    - improve scaling of fpassist printk (John Hawkes).
    - fix EFI memory map trimming (Tony Luck).
  * I/O:
    - return PCI domain for pci_controller_num() (Matthew Wilcox).
    - add/cleanup HP PCI device names (Alex Williamson).
    - fix AGP ACPI device claim (Bjorn Helgaas).
    - add HP AGP 8X support (Bjorn Helgaas).
  * ACPI:
    - new ACPI CA version 20030813! (from upstream).
    - fix ACPI interrupt polarity/trigger interpretation (Takayoshi Kochi).
    - fix ACPI interrupt to IRQ mapping (H. J. Lu).
    - remove unused acpi_pci_get_translations() (Bjorn Helgaas).
    - add ACPI serial port discovery error checking (Bjorn Helgaas).
    - add ACPI serial port discovery for devices in IO port space (Bjorn Helgaas).
    - prefer X_DSDT over DSDT, if it exists (Alex Williamson).
    - handle more than NR_CPUS gracefully from 2.5 (Matt Chapman).
  * MCA/INIT/CMC/CPE:
    - rework CMC/CPE polling using cascaded interrupts (Alex Williamson).
    - backtrace all processes on INIT from 2.5 (David Mosberger).
    - clean up INIT code (Tony Luck).
    - make OS_INIT work again (from 2.5) (Tony Luck).
    - pass GP physical address to SAL (Keith Owens).
    - find correct offset of OEM MCA data (Keith Owens).
  * Perfmon:
    - fix rum/rsm usage (Stephane Eranian).
  * IA32 emulation:
    - fix F_GETLK64/F_SETLK64 handling (Arun Sharma).
    - fix FP denormal handling (Arun Sharma).
    - fix memory leak in sys32_execve (Tony Luck).
  * SGI SN and NUMA support:
    - add NUMA support (Jesse Barnes, Takayoshi Kochi, Jack Steiner, others).
    - support for non-identity-mapped kernels (Jack Steiner).
    - misc SGI fixes (Jack Steiner).
    - another SGI update (Erik Jacobson).
  * Misc bug-fixes:
    - cleanup /dev/mem cacheability checking from 2.5 (David Mosberger).
    - unwind UNW_DPRINT() typo fixes (Keith Owens).
    - user stack size configurable via RLIMIT_STACK from 2.5 (Martin Hicks).
  * Misc cleanup:
    - fix CONFIG_SERIAL_HCDP documentation and indentation (Bjorn Helgaas).
    - fix hugetlb compile problem with gcc-3.4 (Stephane Eranian).
    - configs updated, added new "numa" generic config (Bjorn Helgaas).

