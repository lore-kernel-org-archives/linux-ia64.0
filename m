From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Jan 2004 01:37:14 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200401270137.i0R1bEqF012062@napali.hpl.hp.com>
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

This will update the files shown below (only ia64-specific files are
touched).

Thanks!

	--david

 include/asm-ia64/machvec_sn1.h            |   85 -----------------
 arch/ia64/Kconfig                         |  149 +++++++++++++-----------------
 arch/ia64/hp/common/sba_iommu.c           |   17 +++
 arch/ia64/kernel/entry.S                  |   53 ++++++++--
 arch/ia64/kernel/ia64_ksyms.c             |    8 +
 arch/ia64/kernel/irq_lsapic.c             |    5 -
 arch/ia64/kernel/smpboot.c                |    8 -
 arch/ia64/kernel/time.c                   |    3 
 arch/ia64/sn/io/sn2/xbow.c                |    2 
 arch/ia64/sn/kernel/sn2/Makefile          |    2 
 arch/ia64/sn/kernel/sn2/sn2_smp.c         |    5 -
 arch/ia64/sn/kernel/sn2/timer_interrupt.c |   64 ++++++++++++
 include/asm-ia64/a.out.h                  |    4 
 include/asm-ia64/bugs.h                   |    6 -
 include/asm-ia64/byteorder.h              |    4 
 include/asm-ia64/checksum.h               |    4 
 include/asm-ia64/current.h                |    4 
 include/asm-ia64/errno.h                  |   12 --
 include/asm-ia64/fcntl.h                  |    6 -
 include/asm-ia64/ioctl.h                  |    6 -
 include/asm-ia64/ioctls.h                 |    6 -
 include/asm-ia64/machvec.h                |    7 +
 include/asm-ia64/machvec_sn2.h            |    2 
 include/asm-ia64/mman.h                   |    6 -
 include/asm-ia64/namei.h                  |    4 
 include/asm-ia64/numa.h                   |    4 
 include/asm-ia64/param.h                  |    6 -
 include/asm-ia64/poll.h                   |    6 -
 include/asm-ia64/posix_types.h            |    8 +
 include/asm-ia64/processor.h              |    6 -
 include/asm-ia64/resource.h               |    6 -
 include/asm-ia64/scatterlist.h            |    4 
 include/asm-ia64/siginfo.h                |    6 -
 include/asm-ia64/signal.h                 |    4 
 include/asm-ia64/socket.h                 |    8 +
 include/asm-ia64/sockios.h                |    9 +
 include/asm-ia64/stat.h                   |    4 
 include/asm-ia64/statfs.h                 |    6 -
 include/asm-ia64/termbits.h               |    6 -
 include/asm-ia64/termios.h                |    4 
 include/asm-ia64/tlb.h                    |    4 
 include/asm-ia64/types.h                  |    6 -
 include/asm-ia64/uaccess.h                |    2 
 include/asm-ia64/unaligned.h              |    5 -
 include/asm-ia64/user.h                   |    4 
 45 files changed, 310 insertions(+), 270 deletions(-)

through these ChangeSets:

<eranian@hpl.hp.com> (04/01/26 1.1525)
   [PATCH] ia64: fix icc compilation
   

<iod00d@hp.com> (04/01/26 1.1524)
   [PATCH] ia64: enable PIOW/DMAR relaxed ordering on ZX1

<schwab@suse.de> (04/01/26 1.1523)
   [PATCH] ia64: Fix xbow.c compilation
   
   This fixes a conflicting declaration in xbow.c.

<matthewc@cse.unsw.edu.au> (04/01/26 1.1522)
   ia64: Fix ptrace infrastructure some more so that strace'd sigreturn()
   	works without trashing any registers.

<mort@wildopensource.com> (04/01/23 1.1498.1.3)
   ia64: remove old sn1 machvec header file

<davidm@tiger.hpl.hp.com> (04/01/23 1.1498.1.2)
   ia64: Fix merge error: remove duplicate NR_CPUS.

<davidm@tiger.hpl.hp.com> (04/01/23 1.1474.119.11)
   ia64: Patch by Jesse Barnes: remove unnecessary set_affinity handler.

<bjorn.helgaas@hp.com> (04/01/23 1.1474.119.10)
   [PATCH] ia64: remove MCA (MicroChannel) cruft
   
   MCA_bus is now referenced only when CONFIG_MCA is set,
   so we should be able to remove the definition from ia64.

<mort@wildopensource.com> (04/01/23 1.1474.119.9)
   [PATCH] ia64: add platform_timer_interrupt() hook
   

<davidm@tiger.hpl.hp.com> (04/01/23 1.1474.119.8)
   ia64: Fix typo in comment in asm-ia64/posix_types.h.

<davidm@tiger.hpl.hp.com> (04/01/23 1.1474.119.7)
   ia64: Drop copyright notices on header files which are either entirely trivial
   	or ended up being trivial variations of another file.  Fix some
   	missing attributions and rephrase existing attributions for specifity.

<suresh.b.siddha@intel.com> (04/01/22 1.1474.119.6)
   [PATCH] ia64: replace inline assembly in sn2 code

<akpm@osdl.org> (04/01/21 1.1474.119.5)
   [PATCH] ia64: i2c config fix
   
   ia64 needs to include i2c by hand

<bjorn_helgaas@hp.com> (04/01/21 1.1474.119.4)
   [PATCH] ia64: Kconfig cleanup, part 1

<davidm@tiger.hpl.hp.com> (04/01/19 1.1474.119.3)
   ia64: arch/ia64/Kconfig URL update: www.linux-on-laptops.com

<jbarnes@sgi.com> (04/01/16 1.1474.119.2)
   [PATCH] ia64: kill some more warnings
   
   Kills a warning and a false sense of safety by removing the volatile
   qualifier on cpu_to_node_map[] and node_to_cpu_mask[].  Also fix the
   printk for total processors since num_online_cpus() can return an int or
   a long depending on the value of NR_CPUS.

<jbarnes@sgi.com> (04/01/16 1.1474.119.1)
   [PATCH] ia64: fix cast in irq_lsapic.c
   
   This patch just updates the cast in irq_lsapic.c to use the cpumask_t
   type for the noop cast assignment to smp_affinity.

