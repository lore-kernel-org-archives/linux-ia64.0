From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 05 Jun 2004 05:57:19 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16577.24767.404535.964974@napali.hpl.hp.com>
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

 MAINTAINERS                            |    6 
 arch/ia64/Kconfig                      |   18 -
 arch/ia64/configs/sim_defconfig        |  535 +++++++++++++++++++++++++++++++++
 arch/ia64/ia32/binfmt_elf32.c          |   13 
 arch/ia64/kernel/entry.S               |    2 
 arch/ia64/kernel/head.S                |   36 ++
 arch/ia64/kernel/iosapic.c             |    2 
 arch/ia64/kernel/irq.c                 |    6 
 arch/ia64/kernel/setup.c               |   19 -
 arch/ia64/kernel/smpboot.c             |    3 
 arch/ia64/kernel/time.c                |    8 
 arch/ia64/kernel/vmlinux.lds.S         |    5 
 arch/ia64/lib/Makefile                 |    2 
 arch/ia64/lib/bitop.c                  |   88 +++++
 arch/ia64/pci/pci.c                    |    4 
 arch/ia64/sn/io/machvec/iomv.c         |    2 
 arch/ia64/sn/io/sn2/pcibr/pcibr_slot.c |   50 ++-
 include/asm-ia64/bitops.h              |   92 -----
 include/asm-ia64/system.h              |    2 
 include/asm-ia64/unistd.h              |    1 
 20 files changed, 764 insertions(+), 130 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/06/04 1.1822)
   ia64: Kill unused external declaration of "acpi_legacy_devices".

<kaos@sgi.o> (04/06/04 1.1821)
   ia64: work around linker bug
   
   Building 2.6.6-ia64-040521, using GNU ld version 2.14.90.0.4 20030523.
   __gp is sometimes set incorrectly.  Instead of being .got + 0x2000000,
   it is set to .data + 0x2000000, which breaks some LTOFF22 and GPREL22
   entries.
   
   This is non-deterministic, changing the path name to the kernel tree
   which changes the size of some messages in .data is enough to make the
   linker get it right.  Force __gp to be based on .got.
   
   HJ Lu says this is fixed in newer versions of binutils but the work around
   is sensible enough that it is a better solution than forcing everybody
   to upgrade binutils.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<akpm@osdl.org> (04/06/04 1.1820)
   [PATCH] ia64: uninline find_next_bit on ia64
   
   From: Paul Jackson <pj@sgi.com>
   
   Move the page of code (~700 bytes of instructions) for find_next_bit and
   find_next_zero_bit from inline in include/asm-ia64/bitops.h to a real function
   in arch/ia64/lib/bitops.c, leaving a declaration and macro wrapper behind.
   
   The other arch's with almost this same code might want to also uninline it:
   alpha, parisc, ppc, sh, sparc, sparc64.
   
   These are too big to inline.
   
   Signed-off-by: Paul Jackson <pj@sgi.com>
   Signed-off-by: Andrew Morton <akpm@osdl.org>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<alext@fc.hp.com> (04/06/04 1.1819)
   [PATCH] ia64: fix comment-typo in entry.S
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<garyhade@us.ibm.com> (04/06/04 1.1818)
   [PATCH] ia64: Fix early serial console setup regression on the IBM x450 and x455
   
   This patch removes the ACPI LEGACY_DEVICES IA-PC boot architecture
   flag as a condition for early serial console setup.  This flag may not
   be set on some systems (e.g. IBM x450 and x455) where early serial
   console setup is possible.
   
   Signed-off-by: Gary Hade <garyhade@us.ibm.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<alex.williamson@hp.com> (04/06/04 1.1817)
   [PATCH] ia64: setup cpu_to_node for cpus not present
   
   In latest linux-2.5 bitkeeper, if you turn on CONFIG_HOTPLUG_CPU w/
   an NR_CPUS greater than physically presents CPUs, you'll end up taking
   an MCA in __alloc_percpu().  kmem_cache_alloc_node() gets called with a
   node value of -1.  It seems other architectures are defaulting the
   cpu_to_node map to zero for possible, but not present cpus.  Here's a
   trivial patch that does the same for ia64.
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<davidm@tiger.hpl.hp.com> (04/06/04 1.1726.29.9)
   ia64: Avoid intermediate-overflows in sched_clock().
   
   Bug reported by Zoran Menyhart.

<arun.sharma@intel.com> (04/06/03 1.1726.29.8)
   [PATCH] ia64: disable in-kernel ia32 emulation post Madison
   
   For IPF processors beyond Madison, this patches changes the kernel to
   allow IA-32 application execution exclusively using IA-32EL.
   
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<arun.sharma@intel.com> (04/06/03 1.1726.29.7)
   [PATCH] ia64: tighten FPH state context switch check
   
   In the absence of this patch, a process can set it's own mfh bit and
   potentially view another process's high floating point registers. So a
   check is needed.
   
   Signed-off-by: Arun Sharma <arun.sharma@intel.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<pfg@sgi.com> (04/06/03 1.1726.29.6)
   [PATCH] ia64: for SN2, disable MST errors on probe
   
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<maeda.naoaki@jp.fujitsu.com> (04/06/01 1.1726.29.5)
   ia64: fix /proc/ioports regression in 2.6.6 on Tiger4
   
   This patch fixes a problem that "cat /proc/ioports" loops
   on some IA64 machines that use quirk_io_region(). The problem
   is caused by redundant resource claim by quirk_io_region()
   and pcibios_fixup_device_resources(). The patch prevents 
   this condition and is written by Matthew Wilcox.
   
   Signed-off-by: Maeda Naoaki <maeda.naoaki@jp.fujitsu.com>

<davidm@tiger.hpl.hp.com> (04/06/01 1.1726.29.4)
   ia64: Add defconfig for Ski simulator (patch by Darren Williams).
   

<davidm@tiger.hpl.hp.com> (04/06/01 1.1726.29.3)
   Update ia64 linux mailing-list and web-site addresses.

<dsw@gelato.unsw.edu.au> (04/06/01 1.1726.29.2)
   ia64: define pending_irq_cpumask in irq.c
   
   This fixes a build-problem with the Ski simulator.  The simulator doesn't
   include iosapic.c and hence pending_irq_cpumask never got defined.

<jbarnes@engr.sgi.com> (04/05/27 1.1726.6.4)
   [PATCH] ia64: don't udelay() in sn_mmiob
   
   sn_mmiob is a lightweight way to ensure PCI write ordering, intended
   to be used as an alternative to doing a PIO read. Unfortunately, with
   the udelay() in there, it ends up being slower than a PCI read on
   small configurations, so remove it in favor of a simple cpu_relax().

<bjorn.helgaas@hp.com> (04/05/27 1.1726.6.3)
   [PATCH] ia64: fix hotplug config placement
   
   HOTPLUG_CPU depends on SMP, so why not put it under SMP?

<davidm@tiger.hpl.hp.com> (04/05/27 1.1726.6.2)
   ia64: Reserve syscall # for vserver().

