From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 24 Jun 2003 03:03:45 +0000
Subject: bk pull
Message-Id: <marc-linux-ia64-105642385109708@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/to-linus-2.5

This will update the files shown below.

This update brings the ia64 tree ever closer to building
out-of-the-box from your tree.  The way to make this work was to avoid
conflicting declarations for irq_desc and init_thread_union.  For
irq_desc, I just renamed the macro to irq_descp().  I expect this will
be renamed back to irq_desc() if and when the big irq.c merge happens.
Similarly, for init_thread_union, I simply renamed the variable in
arch/ia64/kernel/init_task.c to init_thread_mem and thereby I bypassed
the conflicting declaration in linux/sched.h.  Perhaps this could be
done better in the future, but this approach will get us going without
adding more #ifdef's to platform-independent files.

The only outstanding patches are Sam's Makefile update to use .incbin
(instead of LD_BLOB) and a small bug fix to a SCSI driver.  Once those
are in, we should be able to get good ia64 kernels out of your tree.

Thanks!

	--david

 arch/ia64/sn/io/drivers/ifconfig_net.c |  298 ----------------
 arch/ia64/Kconfig                      |    8 
 arch/ia64/Makefile                     |    5 
 arch/ia64/defconfig                    |  614 +++++++++++++++++++--------------
 arch/ia64/kernel/acpi.c                |   63 ---
 arch/ia64/kernel/efi.c                 |    2 
 arch/ia64/kernel/efivars.c             |    2 
 arch/ia64/kernel/gate.S                |   18 
 arch/ia64/kernel/head.S                |    4 
 arch/ia64/kernel/init_task.c           |   12 
 arch/ia64/kernel/iosapic.c             |    6 
 arch/ia64/kernel/irq.c                 |   38 +-
 arch/ia64/kernel/irq_ia64.c            |    2 
 arch/ia64/kernel/mca.c                 |    2 
 arch/ia64/kernel/perfmon.c             |  308 ++++------------
 arch/ia64/kernel/smpboot.c             |    2 
 arch/ia64/lib/Makefile                 |    7 
 arch/ia64/pci/pci.c                    |    2 
 arch/ia64/scripts/toolchain-flags      |    8 
 arch/ia64/sn/io/drivers/Makefile       |    2 
 arch/ia64/sn/io/hwgfs/hcl.c            |   25 -
 arch/ia64/sn/io/machvec/pci.c          |    4 
 arch/ia64/sn/io/machvec/pci_dma.c      |   28 -
 arch/ia64/sn/kernel/Makefile           |    3 
 arch/ia64/sn/kernel/idle.c             |    6 
 arch/ia64/sn/kernel/machvec.c          |    1 
 arch/ia64/sn/kernel/setup.c            |   27 -
 include/asm-ia64/agp.h                 |    5 
 include/asm-ia64/hw_irq.h              |   10 
 include/asm-ia64/thread_info.h         |    1 
 include/asm-ia64/timex.h               |   11 
 include/asm-ia64/tlb.h                 |    1 
 include/asm-ia64/topology.h            |    9 
 33 files changed, 558 insertions(+), 976 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (03/06/23 1.1327.4.24)
   ia64: Update defconfig.  Add missing include to <asm-ia64/tlb.h>.  Fix
   	compiler warning in perfmon.c.

<davidm@tiger.hpl.hp.com> (03/06/23 1.1327.4.23)
   ia64: Rename irq_desc() to irq_descp() to avoid conflict with variable
   	of same name declared in linux/irq.h.  The expectation is that
   	this variable will be removed eventually and then irq_descp()
   	can be renamed to irq_desc() again.  But for now, this makes it
   	easier to compile against Linus' source tree.

<davidm@tiger.hpl.hp.com> (03/06/23 1.1327.4.22)
   Drop pcibios_update_resource() #warning.

<davidm@tiger.hpl.hp.com> (03/06/23 1.1327.4.21)
   ia64: Rename init_thread_union to init_task_mem to avoid conflicting
   	declration in <linux/sched.h>.

<jes@wildopensource.com> (03/06/23 1.1327.4.20)
   [PATCH] ia64: fix static initializers
   
   No need to explicitly zero out global variables.

<davidm@wailua.hpl.hp.com> (03/06/20 1.1327.4.19)
   ia64: More perfmon fixes:
            - removes 2.4 specific macros/inline functions
            - fix rum vs. rsm bug for psr.up
            - introduce cleaner PMC_IS_CONTROL() macro
            - only save the value of psr.up on ctxsw (not whole psr)"

<davidm@tiger.hpl.hp.com> (03/06/20 1.1327.4.18)
   ia64: Fix a alternate-signal-stack bug which could corrupt RNaT bits
   	when bspstore happened to point to an RNaT-slot.
   	Bug reported by Matt Chapman.

<alext@fc.hp.com> (03/06/20 1.1327.4.17)
   [PATCH] ia64: cleanup xor build rule to take advantage of lib-m
   

<jbarnes@sgi.com> (03/06/20 1.1327.4.16)
   [PATCH] ia64: sn2 updates for 2.5.72
   
   Here's a patch against your bk tree that keeps things building for sn2
   (and working with the discontig patch applied).

<davidm@tiger.hpl.hp.com> (03/06/19 1.1327.4.15)
   Kconfig:
     Add back IDE configuration.

<davidm@tiger.hpl.hp.com> (03/06/18 1.1327.4.14)
   ia64: Simplify the script to use only $CC and $OBJDUMP.  Besides being simpler,
   	this also ensure we really do test the linker which will be
   	used when building the gate DSO.

<davidm@tiger.hpl.hp.com> (03/06/18 1.1327.4.13)
   ia64: Minor cleanups; fix non-SMP build.

<chadt@sgi.com> (03/06/18 1.1327.4.12)
   [PATCH] ia64: early_printk for SGI SN2
   

<davidm@tiger.hpl.hp.com> (03/06/18 1.1327.4.11)
   ia64: Two more minor cleanups for 2.5.72.

<davidm@tiger.hpl.hp.com> (03/06/18 1.1327.4.10)
   ia64: Drop obsolete ACPI SPCR support.

<jbarnes@sgi.com> (03/06/18 1.1327.4.9)
   [PATCH] ia64: generic kernel support for sn2
   
   I _think_ I got this one right (at least, it booted on hw).  It should
   allow generic kernels to include the sn2 code.

<jbarnes@sgi.com> (03/06/18 1.1327.4.8)
   [PATCH] ia64: PCI fixes for sn2
   
   Updates the PCI routines for sn2.

<jbarnes@sgi.com> (03/06/18 1.1327.4.7)
   [PATCH] ia64: hwgfs fix for sn2
   
   Small fix for hwgfs on sn2.

<jbarnes@sgi.com> (03/06/18 1.1327.4.6)
   [PATCH] ia64: mark_idle() fixes for sn2
   
   Small patch to fixup the new mark_idle() stuff for sn2.

<jbarnes@sgi.com> (03/06/18 1.1327.4.5)
   [PATCH] ia64: bitshift fix
   
   I think there are other 64p issues in other places, but we found this
   one while doing 2.5 bringup on hardware.

