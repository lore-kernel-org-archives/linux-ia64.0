From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 05 Dec 2003 23:22:49 +0000
Subject: kernel update (relative to 2.4.23)
Message-Id: <marc-linux-ia64-107066754829233@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The ia64 kernel patch for Linux 2.4.23 is available here:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/v2.4/linux-2.4.23-ia64-031205.diff.gz

The current 2.4-based ia64 tree is also available as a BitKeeper
repository.  You can browse the changelog and the source files with a
normal browser at:

    http://lia64.bkbits.net:8080/linux-ia64-2.4

or you can use the BitKeeper tools to maintain a local copy of the
tree like this:

    $ bk clone bk://lia64.bkbits.net/linux-ia64-2.4 linux-ia64-2.4

Bjorn

Changes since 2.4.22:

  * MCA/INIT/CMC/CPE:
    - clear CMCs and CPEs in the kernel so user daemon not required (Bjorn Helgaas).
    - fix infinite loop in ia64_mca_wakeup_ipi_wait() (Tony Luck).
    - fix register numbers in MCA save/restore (Tony Luck).
    - fix/update pal_process_state_info_s structure (Tony Luck).
    - fix printk format strings (Keith Owens).
    - cleanup salinfo.c and remove races (Keith Owens).
    - add "oemdata" decode support (Keith Owens).
    - update PAL_MC_ERROR_INFO structures for SDM 2.1 (Keith Owens).
    - synchronize salinfo.c with 2.6 (Keith Owens).
  * IA32 emulation:
    - MINSIGSTKSZ fix (Arun Sharma).
    - CONFIG_IA32_SUPPORT can only be static (Arun Sharma).
    - don't mix user/kernel pointers in stat/statfs (Arun Sharma).
    - reload syscall arguments to make strace work (Arun Sharma).
  * Perfmon:
    - PFM_FL_INHERIT_ONCE fix (Stephane Eranian).
  * ACPI:
    - fix error that caused some PCI root bridges to be ignored (Bjorn Helgaas).
  * HP ZX1:
    - ignore access to dangerous CSRs via hpzx1 fake devices (Alex Williamson).
    - turn off sba_iommu counters to improve scalability (David Mosberger).
    - remove "zx1" references: HP_ZX1 flavor supports more than just zx1 (Bjorn Helgaas).
  * Misc bug-fixes:
    - fix offsets.h generation for cross-compiling (Keith Owens).
    - fix param.h include problem (Goto Masanori, David Mosberger).
    - move xor functions to .S file for gcc-3.3 (Grant Grundler).
    - add kmap_types.h so crypto compiles (Grant Grundler).
    - fix EFI memory map trimming (Bjorn Helgaas).
    - fix EFI memory map lookups (David Mosberger).
    - don't access per-CPU data of off-line CPUs (Takayoshi Kochi).
    - fix show_mem ("SysRq m") panic (John Marvin).
    - remove printk for unimplemented syscalls (Kyle McMartin).
    - fix alternate-signal-stack bug which could corrupt RNaT bits
      when bspstore happened to point to an RNaT-slot (David Mosberger).
    - fix sigtramp bug that corrupted ar.rnat (David Mosberger).
    - fix double compensation for lost ticks (Khalid Aziz).
  * Misc cleanup:
    - move ski simulator drivers to arch/ia64/drivers (Bjorn Helgaas).
    - remove enable_device platform vector, from 2.5 (Alex Williamson).
    - skip per-cpu PAL mapping printk (Jesse Barnes).
    - remove qla2xxx driver; see qlogic.com if you need it (Bjorn Helgaas).
    - replace agp_lookup_pte() with  vmalloc_to_page() (Bjorn Helgaas).
    - add dummy kmap_types.h, so crypto compiles (Bjorn Helgaas).


