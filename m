From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 12 Mar 2004 05:37:57 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200403120537.i2C5bv4a010602@napali.hpl.hp.com>
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

Thanks!

	--david

 arch/ia64/Kconfig                      |   81 --
 arch/ia64/configs/zx1_defconfig        | 1078 +++++++++++++++++++++++++++++++++
 arch/ia64/hp/common/sba_iommu.c        |   68 --
 arch/ia64/hp/sim/simserial.c           |   19 
 arch/ia64/ia32/ia32_support.c          |    2 
 arch/ia64/kernel/head.S                |    4 
 arch/ia64/kernel/iosapic.c             |   11 
 arch/ia64/kernel/irq_ia64.c            |   15 
 arch/ia64/kernel/mca.c                 |    3 
 arch/ia64/kernel/process.c             |    4 
 arch/ia64/kernel/sal.c                 |  197 +++---
 arch/ia64/pci/pci.c                    |   63 +
 arch/ia64/sn/io/hwgfs/ramfs.c          |    2 
 arch/ia64/sn/io/sn2/pcibr/pcibr_dvr.c  |    4 
 arch/ia64/sn/io/sn2/pcibr/pcibr_intr.c |    2 
 arch/ia64/sn/io/sn2/pciio.c            |    3 
 arch/ia64/sn/io/sn2/shub_intr.c        |    9 
 arch/ia64/sn/kernel/irq.c              |    6 
 drivers/char/sn_serial.c               |   35 -
 include/asm-ia64/hardirq.h             |   12 
 include/asm-ia64/sal.h                 |   13 
 include/asm-ia64/sn/router.h           |    1 
 include/asm-ia64/unistd.h              |    3 
 23 files changed, 1367 insertions(+), 268 deletions(-)

through these ChangeSets:

<jbarnes@sgi.com> (04/03/11 1.1707)
   [PATCH] ia64: fix misc. sn2 warnings
   
   This patch fixes a few warnings that have cropped up in the sn2 code:
     - hwgfs function prototype mismatch
     - pconn uninitialized in pciio.c
     - printk formatting fixes in pcibr_dvr.c
     - kill volatile qualifier in pcibr_intr.c

<willy@debian.org> (04/03/11 1.1706)
   [PATCH] ia64: Convert to use the generic drivers/Kconfig mechanism.
   

<kaneshige.kenji@jp.fujitsu.com> (04/03/10 1.1705)
   ia64: don't unmask iosapic interrupts by default
   
   In ia64 kernel, IOSAPIC's RTEs for PCI interrupts are unmasked at the
   boot time before installing device drivers. I think it is very dangerous.
   If some PCI devices without device driver generate interrupts, interrupts
   are generated repeatedly because these interrupt requests are never
   cleared. I think RTEs for PCI interrupts should be unmasked by device
   driver.  This patch fixes the problem.

<pfg@sgi.com> (04/03/10 1.1703)
   [PATCH] ia64: Altix affinity fix

<davidm@tiger.hpl.hp.com> (04/03/10 1.1702)
   [PATCH] ia64: fix preempt bug in IA32 subsystem
   
   Without this patch, IA32 programs will stall when CONFIG_PREEMPT is enabled.

<pfg@sgi.com> (04/03/10 1.1701)
   [PATCH] ia64: minor cleanups for SN2 console driver
   

<pfg@sgi.com> (04/03/08 1.1642.2.3)
   [PATCH] ia64: fix SN2 console driver to use console_initcall()
   

<davidm@tiger.hpl.hp.com> (04/03/08 1.1642.2.2)
   ia64: Reserve 3 syscall numbers for Andi Kleen's NUMA interface.

<schwab@suse.de> (04/03/04 1.1612.27.18)
   ia64: Fix staircase effect on Altix serial console
   
   Serial console output on Altix didn't convert NL to CRNL.

<jbarnes@sgi.com> (04/03/03 1.1612.27.17)
   [PATCH] ia64: Don't assume iosapic interrupt controllers
   
   Some ia64 machines don't use an iosapic interrupt controller (a
   flagrant violation of the DIG64 spec), so don't assume it's there in
   mca.c.  Platforms that provide a ACPI_INTERRUPT_CPEI vector are
   responsible for registering its interrupt controller type in platform
   specific code, iosapic.c:iosapic_register_platform_intr() does this
   for platforms with an iosapic where the CPEI vector is listed in the
   ACPI namespace, and on sn2, all external interrupts are assigned the
   irq_type_sn type, so this change of assumption should be safe.

<edwardsg@sgi.com> (04/03/02 1.1612.27.16)
   ia64: fix missing include in include/asm-ia64/sn/router.h

<davidm@tiger.hpl.hp.com> (04/03/02 1.1612.27.15)
   ia64: More SAL cleanups/fixes.
   
   Based on patch by Matthew Wilcox: make kernel work with old (broken) firmware
   again and fix UP build problems.

<davidm@tiger.hpl.hp.com> (04/03/02 1.1612.27.14)
   ia64: Rename ia64_invoke_kernel_thread_helper() to start_kernel_thread()
   	for symmetry with start_kernel() and to make it obvious when the
   	end of the call-chain has been reached.
   

<hch@lst.de> (04/03/01 1.1612.27.13)
   [PATCH] ia64: simserial module refcounting update

<davidm@tiger.hpl.hp.com> (04/03/01 1.1612.27.12)
   ia64: Move irq_enter()/irq_exit() from hardirq.h to irq_ia64.c.  The work
   	done by these routines is very special and needs to be done
   	at exactly the right time.  Removing it from the header-file
   	reduces the risk of accidental misuse.  Other arch maintainers agree
   	that this is the Right Thing to do.

<willy@debian.org> (04/03/01 1.1612.27.11)
   [PATCH] ia64: Add support for extended PCI config space
   
   Support for extended config space on ia64.
   
    - Add the new parameter 'type' to ia64_sal_pci_config_{read,write}
    - Change callers to match.
    - Don't check `value' for NULL -- drivers/pci/access.c guarantees it isn't.
    - Make pci_sal_ops static.
    - Add pci_sal_ext_ops.
    - Introduce pci_set_sal_ops() as an arch_initcall to ensure the raw_pci_ops
      get set before we walk the ACPI namespace to discover PCI root bridges

<willy@debian.org> (04/03/01 1.1612.27.10)
   [PATCH] ia64: SAL cleanup
   
   This patch reorganises sal.c and adds a small amount of new functionality.
   
    - Introduce sal_revision to report what revision of the SAL spec is
      supported by the system.
    - Introduce sal_version to report what version of the vendor's SAL
      implementation is present.
    - Introduce SAL_VERSION_CODE to allow for easy comparisons.
    - Print the version at boot, and remove the 'oem=' and 'vendor=' strings.
    - Refactor ia64_sal_init() into several smaller functions.
    - Delete the dead variables 'max' and 'min'.
    - Stop printing the pal_proc and sal_proc entry addresses.
    - Print "None" if there are no SAL platform features.

<willy@debian.org> (04/03/01 1.1612.27.9)
   [PATCH] ia64: add zx1_defconfig
   
   Here's my attempt at a zx1_defconfig.  I haven't checked it on many
   of the zx1 boxes (only zx2000 and rx2600) but I've set some options
   I know are needed on the other boxes.

<alex.williamson@hp.com> (04/02/28 1.1612.27.8)
   ia64: minor 2.6 sba_iommu update
   
   This is a minor update to sba_iommu initialization code.  I moved the
   relaxed ordering to the zx1 specific init routine, those registers don't
   do anything on sx1000.  The iommu page size setup is more generalized on
   ACPI ID, so the sx1000 specific init routine goes away.  And the virtual
   dma_mask on zx1 was tweaked a little to better reflect the memory
   address space.

