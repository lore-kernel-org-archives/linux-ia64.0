From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 13 Jan 2004 01:17:44 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200401130117.i0D1HiGa012728@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

Note: this part:

 ia64/configs/generic_defconfig      | 1045 ------------------------------------
 ia64/configs/generic_defconfig      | 1045 ++++++++++++++++++++++++++++++++++++
is a no-op.  It is due to a bad patch, which couldn't be applied with
-p1 but bk-applypatch applied anyhow. ;-(
The file has been moved to the correct place now.

Thanks!

	--david

 ia64/configs/generic_defconfig      | 1045 ------------------------------------
 arch/ia64/Kconfig                   |    9 
 arch/ia64/configs/generic_defconfig | 1045 ++++++++++++++++++++++++++++++++++++
 arch/ia64/configs/sn2_defconfig     |   65 ++
 arch/ia64/hp/common/sba_iommu.c     |  494 ++++++-----------
 arch/ia64/ia32/sys_ia32.c           |    2 
 arch/ia64/kernel/acpi.c             |    2 
 arch/ia64/kernel/efi.c              |    3 
 arch/ia64/kernel/ia64_ksyms.c       |  132 ----
 arch/ia64/kernel/irq.c              |    5 
 arch/ia64/kernel/irq_ia64.c         |    2 
 arch/ia64/kernel/machvec.c          |    4 
 arch/ia64/kernel/perfmon.c          |   59 --
 arch/ia64/kernel/process.c          |    1 
 arch/ia64/kernel/setup.c            |    5 
 arch/ia64/kernel/smp.c              |    4 
 arch/ia64/kernel/smpboot.c          |    5 
 arch/ia64/kernel/time.c             |    1 
 arch/ia64/kernel/unwind.c           |    9 
 arch/ia64/lib/Makefile              |    4 
 arch/ia64/lib/io.c                  |    4 
 arch/ia64/mm/init.c                 |   10 
 arch/ia64/mm/tlb.c                  |    3 
 arch/ia64/pci/pci.c                 |    3 
 ia64/configs/generic_defconfig      | 1045 ++++++++++++++++++++++++++++++++++++
 include/asm-ia64/page.h             |    2 
 26 files changed, 2440 insertions(+), 1523 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/01/12 1.1513)
   ia64: Fix bad patch breakage: move generic-defconfig to where it belongs.

<davidm@tiger.hpl.hp.com> (04/01/12 1.1512)
   ia64: Avoid use of cast expressions as lvalues.  They're ugly and may be
   	dropped from GCC at some point in the future.

<alex.williamson@hp.com> (04/01/12 1.1511)
   [PATCH] ia64: sba_iommu update
   
   This patch does a couple things:
         * Allows iommu page size different than PAGE_SIZE.  This was
           largely done by Bjorn.  The motivation for this is that sx1000
           hardware officially only supports use of the iommu with a 4k
           page size.  Thus the default is now 4k for sx1000 and PAGE_SIZE
           for zx1.
         * Cleanup the runtime statistics gathering such that we can turn
           it on for some info w/o impacting runtime performance.

<davidm@tiger.hpl.hp.com> (04/01/12 1.1510)
   ia64: Turn on CONFIG_EFI unconditionaly (even for HP Ski simulator).

<davidm@tiger.hpl.hp.com> (04/01/12 1.1509)
   ia64: Minor fix for get_order() so it works even for insanely large
   	arguments.

<schwab@suse.de> (04/01/12 1.1508)
   [PATCH] ia64: __ia64_memcpy_fromio() may be missing from kernel
   
   When building a highly modular, non-generic kernel it can happen that
   arch/ia64/lib/io.o is not included in the image because nothing built-in
   needs __ia64_memcpy_fromio, etc., yet it may be called from a module.  We
   should force it to be linked in.

<jbarnes@sgi.com> (04/01/12 1.1507)
   [PATCH] ia64: sn2 defconfig update
   
   Just a quick update for the sn2_defconfig file now that some more config
   options have been added.

<bjorn.helgaas@hp.com> (04/01/12 1.1506)
   [PATCH] ia64: HP IOTLB startup msg
   
   This patch adds a little noise on the console.  I like to see this
   info because it matches up with the AGPGART aperture info later on.

<davidm@tiger.hpl.hp.com> (04/01/12 1.1505)
   ia64: add generic defconfig file
   
   	Here's a generic_defconfig that works on all the ia64
   	platforms I'm aware of, and we can always update it if it's
   	missing a driver or two.  Compile tested 'make compressed' and
   	'make modules', and boot tested on sn2, and I think Alex boot
   	tested on an HP machine.

<davidm@tiger.hpl.hp.com> (04/01/05 1.1474.66.3)
   Many files:
     ia64: Cleanup EXPORT_SYMBOL usage
   
   	This cleans up the use of EXPORT_SYMBOL in ia64_ksyms.c by
   	moving most of them to the place where the symbol is defined.
   	Ideally, only symbols defined in assembler sources should
   	remain here, but there are some cases where an EXPORT_SYMBOL
   	is missing outside the arch/ia64 tree.  I did not change them
   	for now.  Also, EXPORT_SYMBOL_NOVERS is obsolete.

<davidm@tiger.hpl.hp.com> (04/01/05 1.1474.66.2)
   ia64: Skip zero-length resources in PCI root bridge _CRS.  This fixes
   some ugly messages that used to show up on Tiger and other Intel
   boxes:
   
           alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:02 failed
           alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:08 failed
           alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:08 failed
           alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:08 failed
           alloc 0xffff-0x0 from PCI IO for PCI Bus 0000:08 failed
           alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:09 failed
           alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:0f failed

<davidm@tiger.hpl.hp.com> (04/01/02 1.1474.66.1)
   ia64: fix potential deadlocks due to printk()
   
   	Remove all debug printk() for routines which are called with a
   	runqueue lock held, since those could trigger a deadlock.

