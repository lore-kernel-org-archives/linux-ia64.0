From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 Jul 2004 07:19:03 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <16646.487.574903.387442@napali.hpl.hp.com>
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

 arch/ia64/configs/sn2_defconfig |   16 +++++-
 arch/ia64/defconfig             |  103 ++++++++++++++++++++++++----------------
 arch/ia64/hp/sim/hpsim_irq.c    |    7 ++
 arch/ia64/ia32/binfmt_elf32.c   |    6 +-
 arch/ia64/kernel/acpi.c         |   26 ----------
 arch/ia64/kernel/irq.c          |   20 +++++--
 arch/ia64/kernel/mca.c          |    4 -
 arch/ia64/kernel/perfmon.c      |   14 +++--
 arch/ia64/kernel/process.c      |   10 ---
 arch/ia64/mm/init.c             |    6 +-
 arch/ia64/sn/kernel/mca.c       |    3 -
 include/asm-ia64/elf.h          |    6 +-
 include/asm-ia64/page.h         |    2 
 include/asm-ia64/processor.h    |    3 -
 include/asm-ia64/sn/sn2/io.h    |    5 +
 include/asm-ia64/sn/sn_sal.h    |    4 -
 16 files changed, 127 insertions(+), 108 deletions(-)

through these ChangeSets:

<davidm@tiger.hpl.hp.com> (04/07/26 1.1854)
   ia64: Update for elf_read_implies_exec() macro changes in mainline tree.

<davidm@tiger.hpl.hp.com> (04/07/26 1.1852)
   ia64: Update defconfig

<davidm@tiger.hpl.hp.com> (04/07/26 1.1851)
   ia64: Oops, SN2 needs pending_irq_cpumask to be global.

<davidm@tiger.hpl.hp.com> (04/07/26 1.1850)
   ia64: Clean up arch/ia64/kernel/irq.c a bit.

<kaneshige.kenji@jp.fujitsu.com> (04/07/26 1.1849)
   [PATCH] ia64: fix bug in irq_affinity_write_proc()
   
   Writing 'R' or 'r' character to /proc/irq/<IRQ#>/smp_affinity
   cause a kernel Oops. The following patch fixes this issue.
   
   Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<steiner@sgi.com> (04/07/23 1.1848)
   [PATCH] ia64: Update function prototype for sn_io_addr
   
   Add "const" to function prototype for sn_io_addr. Cuts boot time
   on simulator in half.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<jbarnes@sgi.com> (04/07/20 1.1847)
   [PATCH] ia64: sn2 requires a 3.40 or better PROM
   
   The SGI 3.40 PROM includes a fix for the move of the init_task to
   region 5, so specify that in sn_sal.h.  Unfortunately, the check for
   the minimum required version happens *after* the hang/MCA that is
   symptomatic of the bug, so this message also acts as an announcement
   of the requirement.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<jbarnes@engr.sgi.com> (04/07/19 1.1845)
   [PATCH] ia64:  update sn2_defconfig to include new console
   
   Now that Linus' tree has the new sn2 console driver, make sn2_defconfig enable 
   it by default.  The device is major 204, minor 40.  Note that you'll probably 
   have to update your elilo.conf and inittab to use the new driver, as it's 
   called ttySG0 rather than ttyS0.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<eranian@hpl.hp.com> (04/07/16 1.1844)
   [PATCH] ia64: fix perfmon bug that could result in kernel hang
   
   This patch fixes a potential kernel hang in perfmon during
   PFM_UNLOAD_CONTEXT.  This commands requires that the monitored task be
   stopped (except when self-monitoring). The task state tests in
   check_task_state() were incorrect and an actively running task was
   accepted for PFM_UNLOAD_CONTEXT. This eventually leads to a kernel
   hang.
   
   Signed-off-by: Stephane Eranian <eranian@hpl.hp.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<davidm@tiger.hpl.hp.com> (04/07/16 1.1843)
   ia64: Nuke two compiler-warnings.

<jbarnes@engr.sgi.com> (04/07/16 1.1842)
   [PATCH] ia64: make madt parsing quieter
   
   We already get this info in other forms from other boot messages, so kill the 
   printing of the MADT entries as they're parsed.  This patch significantly 
   reduces the amount of output from a boot of a 512p system.
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<josha@sgi.com> (04/07/15 1.1784.20.17)
   [PATCH] ia64: fix obsolete and now misleading comment
   
   Signed-off-by: Josh Aas <josha@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

<kaos@sgi.com> (04/07/14 1.1784.20.16)
   [PATCH] ia64: Extend oem section types for SN mca records
   
   SN mca records now contain oem data for platform memory errors.
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: David Mosberger <davidm@hpl.hp.com>

