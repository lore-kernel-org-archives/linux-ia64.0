From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 22 Aug 2002 13:42:55 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.19)
Message-Id: <marc-linux-ia64-105590701905973@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The latest ia64 kernel patch is available here:

    ftp://ftp.kernel.org/pub/linux/kernel/ports/v2.4/linux-2.4.19-ia64-020821.diff.gz

Note that this patch retains support for the Microsoft-encumbered SPCR
and DBGP ACPI tables, even though they have been removed from 2.4.19.
I'd like to remove this soon, though.

Bjorn


ChangeLog

- 2.4.19 changes, just as a heads up:
  - Support for HCDP (DIG64 Headless Console Debug Port) added.
  - Support for SPCR & DBGP (CONFIG_SERIAL_ACPI) was removed from
    2.4.19.  I kept it in the ia64 patch because some people still
    rely on it, but I'd like to remove it eventually.

- Remove hpsim_console simcons_wait_key() due to struct console changes.
- Fix really_local_irq_count() typo (David Mosberger).
- SYM53C8XX version 2 fixes (?).
- Fix flush_tlb_page problem (UP only) (Dan Magenheimer, David Mosberger).
- ACPI: prefer WB mapping over UC (a region may support both) (?).
- Print FPSWA revision (Takayoshi Kochi).
- copy_user fix (Ken Chen).
- Makefile fixes (David Lombard).
- SGI devfs config fixes for xconfig (Keith Owens).
- Fix CPU bitmask truncation to 32 bits.
- do_profile() cleanup (David Mosberger).
- SMP floating-point context switch optimization (Asit Mallick).
- Fix corruption of perfmon registers by ptrace (Stephane Eranian).
- Disable PCI decoding while sizing BARs (Tatsuya Tsurukawa).
- Detect keyboard controller via ACPI, acpi.c cleanup.
- Add early printk support for UARTs.
- ForteMedia FM801 sound driver update (Martin Petersen).
- Make ACPI GPE0/GPE1 optional (Chris McDermott).
- IOSAPIC cleanup (Takayoshi Kochi):
  - Cleanup irq/vector/pin terminology
  - Remove gsi_to_vector_map[]
  - Remove ACPI irq = vector assumption
  - Dynamic vector allocation
- Add iosapic PCI segment support.
- Add pcibios PCI segment support.
- Add support for ACPI _TRA (PCI memory space only for now).
- Add platform vector hook in pcibios_enable_device.
- Detect HP sba_iommu via ACPI, support multiple IOCs.
- Correct memory_lseek return (David Mosberger).
- Correct /proc/<pid>/mem lseek return.
- Fix GPT RAID autodetect (only worked for first partition) (Alex Williamson).
- Move efi.h from include/asm-ia64 to include/linux (Matt Domsch).
- Temporarily restore ACPI SPCR/DBGP support (was removed from 2.4.19).
- defconfig update ("generic" kernel, virtual mem_map, add drivers for
  fusion mpt, aic7xxx, sym53c8xx (ver 2), tulip, e1000, tigon 3,
  zx1 AGPGART).


