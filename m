From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 25 Mar 2004 20:30:23 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200403252030.i2PKUNW8026746@napali.hpl.hp.com>
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

This will update the files shown below.  All ia64-specific stuff with
several important fixes.

Thanks!

	--david

 arch/ia64/Kconfig                    |   50 -----
 arch/ia64/hp/common/sba_iommu.c      |    8 
 arch/ia64/kernel/gate.S              |    2 
 arch/ia64/kernel/machvec.c           |   23 ++
 arch/ia64/kernel/process.c           |   21 +-
 arch/ia64/kernel/setup.c             |   69 ++++----
 arch/ia64/kernel/smp.c               |   14 -
 arch/ia64/kernel/smpboot.c           |    2 
 arch/ia64/kernel/time.c              |   32 ++-
 arch/ia64/kernel/traps.c             |    2 
 arch/ia64/kernel/unaligned.c         |    2 
 arch/ia64/kernel/vmlinux.lds.S       |    9 +
 arch/ia64/lib/swiotlb.c              |    7 
 arch/ia64/mm/extable.c               |    2 
 arch/ia64/mm/fault.c                 |    2 
 arch/ia64/pci/pci.c                  |    3 
 arch/ia64/sn/io/machvec/pci_dma.c    |    7 
 arch/ia64/sn/io/sn2/shub.c           |  292 ++++-------------------------------
 arch/ia64/sn/kernel/mca.c            |    2 
 arch/ia64/sn/kernel/sn2/sn_proc_fs.c |   57 ------
 drivers/char/sn_serial.c             |   18 +-
 include/asm-ia64/dma-mapping.h       |    3 
 include/asm-ia64/machvec.h           |   58 ++----
 include/asm-ia64/machvec_hpzx1.h     |   14 -
 include/asm-ia64/machvec_sn2.h       |    2 
 include/asm-ia64/processor.h         |   34 ++--
 include/asm-ia64/sn/sndrv.h          |    5 
 include/asm-ia64/uaccess.h           |    6 
 28 files changed, 242 insertions(+), 504 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/03/25 1.1678)
   ia64: Correct value for PREFETCH_STRIDE.

<davidm@tiger.hpl.hp.com> (04/03/25 1.1677)
   ia64: Minor formatting fix for two earlier patches.

<davidm@tiger.hpl.hp.com> (04/03/25 1.1676)
   ia64: Improve layout of cpuinfo_ia64
   
   Stephane made some measurements on the access-pattern of the cpuinfo_ia64
   members and based on those results, this patch reorganizes the structure
   for better cache-line sharing.

<bjorn.helgaas@hp.com> (04/03/24 1.1675)
   [PATCH] ia64: fix name conflict with handle_exception()
   
   I tried to build usb/gadget/file_storage.c (CONFIG_USB_FILE_STORAGE=y),
   but it uses "handle_exception()" for its own purposes, which conflicts
   with the ia64 definition.  ia64 only uses handle_exception() within
   arch code, so it seems like we ought to rename it to be ia64-specific.
   done_with_exception() looks similar, so I renamed it as well, although
   there's no actual conflict.

<willy@debian.org> (04/03/23 1.1643.36.8)
   [PATCH] ia64: Fix SAL 3.2 detection
   
   This important fix checks the SAl *revision* rather than
   the *version*.  I carefully documented which was which, then used the
   wrong one.

<markgw@sgi.com> (04/03/23 1.1643.36.7)
   [PATCH] ia64: deprecate SN2 linkstatd
   
   This patch against 2.6.5-rc2 affects the SGI/SN platform only. It deprecates
   a kernel daemon for our interconnect traffic statistics which has been
   replaced by a userland tool.

<alex.williamson@hp.com> (04/03/23 1.1643.36.6)
   [PATCH] ia64: lost sx1000 naming in sba_iommu
   
   Mainly cosmetic, but Bjorn noticed I got a little over zealous in
   cleaning out the sx1000 specific init routines in sba_iommu.  This adds
   back in the ID->name mapping so it doesn't show up as "Unknown".

<jbarnes@sgi.com> (04/03/23 1.1643.36.5)
   [PATCH] ia64: quiet sn_serial driver
   
   Bjorn pointed out that the sn console driver will spew printks if
   compiled in even if no hardware is present.  In addition to fixing
   that, I took the opportunity to cleanup/correct a few other printks in
   that driver.

<kaos@sgi.com> (04/03/23 1.1643.36.4)
   [PATCH] ia64: SN2 salinfo oemdata race fix
   
   sn_oemdata_* variables must only be used under the sn_oemdata_mutex.

<davidm@tiger.hpl.hp.com> (04/03/23 1.1643.36.3)
   ia64: Manual merge of Andrew/Alex/Bjorn's dma_mapping_error() changes.

<akpm@osdl.org> (04/03/23 1.1643.36.2)
   [PATCH] ia64: add dma_mapping_error() support
   

<kenneth.w.chen@intel.com> (04/03/19 1.1643.14.9)
   [PATCH] ia64: Interim pal_halt_light patch
   
   While the sysctl variable is being worked out in the general kernel, here is
   an interim patch which allows boot-time/dynamic control over the use of
   PAL_HALT_LIGHT in the idle-loop.

<jeremy@sgi.com> (04/03/18 1.1643.14.8)
   [PATCH] ia64: make level sensitive interrupt emulation default on SN2
   
   SN2 doesn't fully support level triggered interrupts.  As a
   workaround, we need this patch to force another interrupt if the line
   is still high after a handler completes.

<davidm@tiger.hpl.hp.com> (04/03/18 1.1643.14.7)
   ia64: Small cleanup in __kernel_sigtramp().

<davidm@tiger.hpl.hp.com> (04/03/17 1.1643.14.6)
   ia64: GCC v3.5 fixes.
   
   GCC v3.5 doesn't like it when a function gets cast to a
   function-pointer with a different signature.  In fact, it exterts
   extreme prejudice in this case and replaces the call-site with a call
   to __builtin_trap()!  Fix this by providing appropriately typed
   dummy-functions for the macvec operations as needed.
   
   While at it, also clean up some machvec handlers which weren't used anywhere.

<kaos@sgi.com> (04/03/17 1.1643.14.5)
   [PATCH] ia64: force all kernel sections into one and the same segment
   
   Older versions of the linker do not handle cross-segment segment-relative
   relocations properly.  This becomes a real problem when the linker decides
   to put .text and .text.init into different segments (for whatever reasons)
   because in that case, broken linkers will produce a broken unwind section,
   which can cause nasty Heisenbugs, where, for example, unwinding may or may
   not work depending on the exact value of the IP in a function.

<willy@debian.org> (04/03/17 1.1643.14.4)
   [PATCH] ia64: kill unused ACPI configgery
   
   The config ACPI helptext isn't used because the option is never
   presented to the user.
   ACPI_KERNEL_CONFIG is unused.
   ACPI_INTERPRETER is now set in drivers/acpi/Kconfig.

<bjorn.helgaas@hp.com> (04/03/17 1.1643.14.3)
   [PATCH] ia64: init IO port space, IO accessors earlier
   
   This is a minor patch to get things setup so consoles can
   work earlier.  (No change to consoles here, I just split this
   out to make the diff easier to read.)
   
   (io_port_init): New function, same old code to setup ia64_iobase
   and legacy IO port space.
   (setup_arch): Call io_port_init() and machvec_init() as early as
   possible so consoles can work earlier.

