From: tony.luck@intel.com
Date: Tue, 03 May 2005 21:08:58 +0000
Subject: catching up on the backlog
Message-Id: <200505032108.j43L8wc21277@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I've picked through the list of patches in my backlog, and applied
this bunch to my release tree ... before I ask Linus to pull, it
would be useful to get some SGI testing (since the majority of the
changes are SGI related).

-Tony

 arch/ia64/Kconfig                   |   19 
 arch/ia64/hp/common/sba_iommu.c     |   34 
 arch/ia64/kernel/acpi.c             |   23 
 arch/ia64/kernel/entry.S            |    2 
 arch/ia64/kernel/fsys.S             |    4 
 arch/ia64/kernel/mca_drv.c          |    4 
 arch/ia64/kernel/mca_drv_asm.S      |   18 
 arch/ia64/kernel/process.c          |   41 
 arch/ia64/kernel/signal.c           |    3 
 arch/ia64/lib/flush.S               |    6 
 arch/ia64/lib/memcpy_mck.S          |    2 
 arch/ia64/lib/memset.S              |    2 
 arch/ia64/sn/kernel/Makefile        |    7 
 arch/ia64/sn/kernel/io_init.c       |   10 
 arch/ia64/sn/kernel/mca.c           |   34 
 arch/ia64/sn/kernel/setup.c         |   31 
 arch/ia64/sn/kernel/tiocx.c         |   60 
 arch/ia64/sn/kernel/xp_main.c       |  289 +++
 arch/ia64/sn/kernel/xp_nofault.S    |   31 
 arch/ia64/sn/kernel/xpc.h           |  991 +++++++++++
 arch/ia64/sn/kernel/xpc_channel.c   | 2297 ++++++++++++++++++++++++++
 arch/ia64/sn/kernel/xpc_main.c      | 1064 ++++++++++++
 arch/ia64/sn/kernel/xpc_partition.c |  984 +++++++++++
 arch/ia64/sn/kernel/xpnet.c         |  715 ++++++++
 arch/ia64/sn/pci/pcibr/pcibr_dma.c  |    2 
 arch/ia64/sn/pci/tioca_provider.c   |    2 
 drivers/char/Kconfig                |    2 
 include/asm-ia64/sn/addrs.h         |    8 
 include/asm-ia64/sn/arch.h          |   17 
 include/asm-ia64/sn/fetchop.h       |   85 
 include/asm-ia64/sn/l1.h            |    3 
 include/asm-ia64/sn/pda.h           |    1 
 include/asm-ia64/sn/shub_mmr.h      |   24 
 include/asm-ia64/sn/shubio.h        | 3108 +++++++++++++++++-------------------
 include/asm-ia64/sn/sn_cpuid.h      |    7 
 include/asm-ia64/sn/sn_fru.h        |   44 
 include/asm-ia64/sn/sndrv.h         |   47 
 include/asm-ia64/sn/xp.h            |  436 +++++
 kernel/exit.c                       |    2 
 mm/page_alloc.c                     |    2 
 40 files changed, 8525 insertions(+), 1936 deletions(-)

commit 012914dad25bd5cacf88af4429eecda62a06020d
tree e265fa0cf7dccef220bc26a16c1f0694b4b4bbee
parent 3ea8b477b4b9d3e75b5e9b8aea41259f45031823
author Russ Anderson <(rja@sgi.com)> Sat, 23 Apr 2005 00:08:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:58:17 -0700

    [patch] MCA recovery module undefined symbol fix

    The patch "MCA recovery improvements" added do_exit to mca_drv.c.
    That's fine when the mca recovery code is built in the kernel
    (CONFIG_IA64_MCA_RECOVERY=y) but breaks building the mca recovery
    code as a module (CONFIG_IA64_MCA_RECOVERY=m).

    Most users are currently building this as a module, as loading
    and unloading the module provides a very convenient way to turn
    on/off error recovery.

    This patch exports do_exit, so mca_drv.c can build as a module.

    Signed-off-by: Russ Anderson (rja@sgi.com)
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 3ea8b477b4b9d3e75b5e9b8aea41259f45031823
tree d9ab6af871931241152f0d87084a1ba0ace02480
parent 32709d8ae67356559839a9a9e4b26f79134e45a6
author Mark Maule <maule@sgi.com> Mon, 11 Apr 2005 21:20:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:52:22 -0700

    [IA64] altix: fix TIOCA dmamap list_add

    Correct a bug where tioca_dma_mapped() is putting tioca dma map structs
    on the wrong list.

    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 32709d8ae67356559839a9a9e4b26f79134e45a6
tree 876f7e6d3f3f5d835870c8db34d141959db754b0
parent b1b901c2029aa0fd8aa4ac5f04f31648ae2358b4
author Keith Owens <kaos@sgi.com> Fri, 08 Apr 2005 14:23:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:48:55 -0700

    [IA64] SAL to OS callbacks cannot call sleeping

    When SAL calls back into the OS, the OS code is running with preempt
    disabled so it cannot call sleeping functions.

    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit b1b901c2029aa0fd8aa4ac5f04f31648ae2358b4
tree 43f5dde2309d66fa2112a7c2dc46ea7c63fae459
parent 446b8831f5acf2076fa58a66286789eb84f3df2c
author Russ Anderson <rja@sgi.com> Wed, 06 Apr 2005 00:07:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:47:42 -0700

    [IA64] MCA recovery improvements

    Jack Steiner uncovered some opportunities for improvement in
    the MCA recovery code.

      1) Set bsp to save registers on the kernel stack.
      2) Disable interrupts while in the MCA recovery code.
      3) Change the way the user process is killed, to avoid 
         a panic in schedule.

    Testing shows that these changes make the recovery code much 
    more reliable with the 2.6.12 kernel.

    Signed-off-by: Russ Anderson <rja@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 446b8831f5acf2076fa58a66286789eb84f3df2c
tree 250506863a6e103444584d609cdb577e87b3a499
parent 7d5f9c0f10255000ca007fb03773c6b825c2b9ce
author David Woodhouse <dwmw2@infradead.org> Tue, 05 Apr 2005 17:47:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:45:39 -0700

    [IA64] fix ia64 syscall auditing

    Attached is a patch against David's audit.17 kernel that adds checks
    for the TIF_SYSCALL_AUDIT thread flag to the ia64 system call and
    signal handling code paths.  The patch enables auditing of system
    calls set up via fsys_bubble_down, as well as ensuring that
    audit_syscall_exit() is called on return from sigreturn.

    Neglecting to check for TIF_SYSCALL_AUDIT at these points results in
    incorrect information in audit_context, causing frequent system panics
    when system call auditing is enabled on an ia64 system.

    I have tested this patch and have seen no problems with it.

    [Original patch from Amy Griffis ported to current kernel by David Woodhouse]

    From: Amy Griffis <amy.griffis@hp.com>
    From: David Woodhouse <dwmw2@infradead.org>
    Signed-off-by: Chris Wright <chrisw@osdl.org>
    Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 7d5f9c0f10255000ca007fb03773c6b825c2b9ce
tree 5f53e41ef4cbe5ced2c5884ee5dde8df1fcaa509
parent de7548d0e202263bb6bfd7574a7889e85a691937
author Zwane Mwaikambo <zwane@arm.linux.org.uk> Wed, 30 Mar 2005 21:40:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:40:18 -0700

    [IA64] reduce cacheline bouncing in cpu_idle_wait

    Andi noted that during normal runtime cpu_idle_map is bounced around a lot,
    and occassionally at a higher frequency than the timer interrupt wakeup
    which we normally exit pm_idle from.  So switch to a percpu variable.

    I didn't move things to the slow path because it would involve adding
    scheduler code to wakeup the idle thread on the cpus we're waiting for.

    Signed-off-by: Zwane Mwaikambo <zwane@arm.linux.org.uk>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit de7548d0e202263bb6bfd7574a7889e85a691937
tree eee071a29e77fbfacc5dc6ff8c9c10d9dcc23f02
parent bb0fc085457cf6a865b8232b0cefab3a7819df44
author Mike Habeck <habeck@sgi.com> Fri, 25 Mar 2005 19:34:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:36:09 -0700

    [IA64-SGI] Altix only: Fix for sn_dma_flush

    The following patch fixes a bug in the SGI Altix sn_dma_flush code.  
    sn_dma_flush is broken in 2.6.  The code isn't waiting for the DMA 
    data to be flushed out of the PIC ASIC. This patch is based off the 
    linux-ia64-test-2.6.12 tree

    Signed-off-by: Mike Habeck <habeck@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit bb0fc085457cf6a865b8232b0cefab3a7819df44
tree deaa9e3b58d6e40cb2bdba61898bf8373dc02688
parent c0b12422e5e1d041026dd27074de17d2d7e32c4e
author Alex Williamson <alex.williamson@hp.com> Thu, 24 Mar 2005 22:58:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:33:18 -0700

    [IA64] use common pxm function

    This patch simplifies a couple places where we search for _PXM
    values in ACPI namespace.  Thanks,

    Signed-off-by: Alex Williamson <alex.williamson@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit c0b12422e5e1d041026dd27074de17d2d7e32c4e
tree 1818ff91a52bea353469ba787f492dd2ca303fe2
parent 3a7d555bfc4d4631d9118fb4d0ed7ab62cc2ca1c
author Colin Ngam <cngam@sgi.com> Fri, 18 Mar 2005 16:38:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 13:21:03 -0700

    [IA64-SGI] Altix only: Register Error Interrupt

    The following patch ensures that the correct error interrupt handling 
    routine is initialized.  This patch is based on the 2.6.12 ia64 release tree.

    Signed-off-by: Colin Ngam <cngam@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 3a7d555bfc4d4631d9118fb4d0ed7ab62cc2ca1c
tree 3f788937066dff5befaf3b4e70539bf3f9e4702b
parent a2d974da0afe659cff98913184a97c0ee686d02b
author Dean Nelson <dcn@sgi.com> Mon, 04 Apr 2005 13:14:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:50:22 -0700

    [IA64-SGI] convert AMO address found in XPC's reserved page

    This patch detects the existence of an uncached physical AMO address setup
    by EFI's XPBOOT (SGI) and converts it to an uncached virtual AMO address.
    Depends on a patch submitted on 23 March 2005 with the subject of:
        [PATCH 2/3] SGI Altix cross partition functionality (2nd revision)

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit a2d974da0afe659cff98913184a97c0ee686d02b
tree 1a1479280445226104ddc062bed2e2806639352e
parent 89eb8eb927e324366c3ac0458998aaf9953fc5cd
author Dean Nelson <dcn@sgi.com> Wed, 23 Mar 2005 20:50:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:37:19 -0700

    [IA64-SGI] SGI Altix cross partition functionality [3/3]

    This patch contains the cross partition pseudo-ethernet driver (XPNET)
    functional support module.

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 89eb8eb927e324366c3ac0458998aaf9953fc5cd
tree c5f77d88bc42821134de6ea49a5663654df38e56
parent 21223a9e78050919499d3d9039170e608eb939cc
author Dean Nelson <dcn@sgi.com> Wed, 23 Mar 2005 19:50:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:36:00 -0700

    [IA64-SGI] SGI Altix cross partition functionality [2/3]

    This patch contains the communication module (XPC) for cross partition
    communication on a partitioned SGI Altix.

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 21223a9e78050919499d3d9039170e608eb939cc
tree 8691970d17425f6e79b0567633d106ce88db0b8e
parent b0d82bd5df874f7dadbeced1b0163473387da37c
author Tony Luck <aegl@agluck-lia64.sc.intel.com> Tue, 03 May 2005 12:25:50 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:25:50 -0700

    [IA64] manually apply changes to arch/ia64/sn/kernel/Makefile

    cg-patch couldn't apply the patch to Makefile, and my dumb script
    rushed on and ran cg-commit without this change.

    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit b0d82bd5df874f7dadbeced1b0163473387da37c
tree c78294ddaff17034ef77253c587a7512ba813e95
parent 7fbd2a5337b2aa91266abbded97330f909904fd5
author Dean Nelson <dcn@sgi.com> Wed, 23 Mar 2005 19:46:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:16:52 -0700

    [IA64-SGI] SGI Altix cross partition functionality (2nd
    This patch contains the shim module (XP) which interfaces between the
    communication module (XPC) and the functional support modules (like XPNET).

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 7fbd2a5337b2aa91266abbded97330f909904fd5
tree 0aca2260c63b65068e69bc82b5ab55f4da4b9421
parent 21e37283909c12e300ab87c20f5addc878cda9f9
author Dean Nelson <dcn@sgi.com> Wed, 23 Mar 2005 19:11:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:12:42 -0700

    [IA64-SGI] Add some needed externs currently not defined

    Add some needed externs currently not defined.

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 21e37283909c12e300ab87c20f5addc878cda9f9
tree 0a03d3c0c90d8108eefb985272d0d49f31c2c827
parent 7223a93a5321f84337647aef62ef947afd8df41a
author Dean Nelson <dcn@sgi.com> Wed, 23 Mar 2005 19:08:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:11:38 -0700

    [IA64-SGI] Define some additional SHub1 and Shub2 register symbols

    Define some additional SHub1 and SHub2 register symbols.

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 7223a93a5321f84337647aef62ef947afd8df41a
tree 10d4c8e4cb1b4ddf33ca32efbe915ca91d19fcd1
parent 2e34f07ff0c944399a6456e2d91cf0ca1d9a497c
author Dean Nelson <dcn@sgi.com> Wed, 23 Mar 2005 19:00:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:09:32 -0700

    [IA64] Export node_online_map and node_possible_map

    Export node_online_map and node_possible_map so that kernel modules can use
    the nodemask macros, like, for_each_node() and for_each_online_node().

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 2e34f07ff0c944399a6456e2d91cf0ca1d9a497c
tree d09796e3f37d7cd809eceb5d931f1e2171a32f5b
parent ce0a3956b32650e229b68964c4400bbdc5ad3ca1
author Dean Nelson <dcn@sgi.com> Mon, 21 Mar 2005 19:41:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:07:46 -0700

    [PATCH] move cnodeid_to_nasid_table out of pda
    Another step in the effort to eliminate the SN pda structure.
    This patch moves the cnodeid_to_nasid_table field out of the pda,
    making it a standalone per-cpu data item, and exports it so it can
    be accessed by kernel modules.

    Signed-off-by: Dean Nelson <dcn@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit ce0a3956b32650e229b68964c4400bbdc5ad3ca1
tree 79ea53b8321964c903f1379c48ba5c4917992c46
parent ae40aae9b9b8e336714ebb3f16410da6e69d6ac8
author Bruce Losure <blosure@sgi.com> Mon, 25 Apr 2005 19:41:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:01:07 -0700

    [IA64-SGI] Altix patch to add bricktype knowledge to tiocx

    Here is a patch to enable the SGI tiocx bus driver to distingush between
    FPGA-attached h/w and non-FPGA-attached h/w.

    Signed-off-by: Bruce Losure <blosure@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit ae40aae9b9b8e336714ebb3f16410da6e69d6ac8
tree aa900ab7187e5206d30f78c1e5fad98a84a81293
parent c2d1d65ad441c8abe624bdb1c2cff2e47c8c1ee1
author Bruce Losure <blosure@sgi.com> Mon, 04 Apr 2005 13:23:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 12:00:01 -0700

    [IA64-SGI] Altix patch to fix missing Kconfig dependency.

    This is a one-liner to make the mbcs driver depend on SGI_TIOCX in the
    drivers/char/Kconfig file.

    Signed-off-by: Bruce Losure <blosure@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit c2d1d65ad441c8abe624bdb1c2cff2e47c8c1ee1
tree 3d88b27fe6409d1ebc9849e29b0e660d437decce
parent 2074615a13a4f250e0a4e3f6ec8e3733b950a783
author Bruce Losure <blosure@sgi.com> Thu, 24 Mar 2005 12:28:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 11:58:37 -0700

    [IA64-SGI] Altix only: Remove hubdev SAL call 

    Hi Tony,

    This patch against ia64-test-2.6.12 fixes a bug where the tiocx code
    was inadvertently un-doing some address modifications done in earlier
    fixup code.    This patch just removes the offending code.

    Signed-off-by: Bruce Losure <blosure@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 2074615a13a4f250e0a4e3f6ec8e3733b950a783
tree 20af73cd640c88f5bedcb081fd5e850bf23b7b86
parent 43cc67251882f60c796c8729cefc0e05b550976c
author David Mosberger-Tang <davidm@hpl.hp.com> Fri, 18 Feb 2005 19:09:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 11:27:33 -0700

    [IA64] use fc.i for fluch_icache_range()

    This is a small patch to switch fluch_icache_range() to use fc.i
    instead of fc.  This would save time on processors which can establish
    i-cache coherency without flushing the cache-line out to memory (not
    that any current processors do).  On existing processors, fc.i behaves
    like fc.  The only caveat is that very old assemblers may not know
    about fc.i yet.

    Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 43cc67251882f60c796c8729cefc0e05b550976c
tree 7d5a7a24eaf4f6afc76ce98b368eb9579bf59c8b
parent 6adc4cc0eead0c1897d7f1416d749c8e7c91e0bc
author Jes Sorensen <jes@wildopensource.com> Thu, 17 Feb 2005 09:41:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 11:26:05 -0700

    [IA64-SGI] cleanup shubio.h

    This patch cleans up include/asm/sn/shubio.h by removing a ton of
    whitespaces and running it through Lindent, reducing it's size by almost
    30KB. No actual content has been changed.

    Signed-off-by: Jes Sorensen <jes@wildopensource.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 6adc4cc0eead0c1897d7f1416d749c8e7c91e0bc
tree 0409af16566bde54a3d75fb0675a26a5cbc4603a
parent 9df6f705c0934a49d0f0a3468a5b5044c8aec4f1
author Jesse Barnes <jbarnes@sgi.com> Wed, 16 Feb 2005 16:38:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 11:16:31 -0700

    [IA64-SGI] remove unused sn header files

    This patch makes Jes' patch (which also contains the removal of fetchop.h) a 
    bit smaller, and removes two other unused files at the same time, sndrv.h and 
    sn_fru.h.

    Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 9df6f705c0934a49d0f0a3468a5b5044c8aec4f1
tree 045807d5f55b61d6222c6dada311237a9badeddc
parent 512f64295f2f0049515dcc4e97c1f1ae0df9629c
author David Mosberger-Tang <davidm@hpl.hp.com> Fri, 25 Mar 2005 00:16:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 10:56:42 -0700

    [IA64] fix typos caught by new assembler

    Patch below fixes 3 trivial typos which are caught by the new
    assembler (v2.169.90).  Please apply.

    [Note: fix to memcpy that was also part of this patch was separately
     applied from patches by H.J. and Andreas ... so the delta here only
     has the other two fixes. -Tony]

    Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 512f64295f2f0049515dcc4e97c1f1ae0df9629c
tree d2079e3972a7cd52f4b72cbd988dd4168dc2c0ec
parent 7a9bdd8842d0847f3b15068550a3632a2d259057
author Andreas Schwab <schwab@suse.de> Tue, 26 Apr 2005 23:00:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 10:49:29 -0700

    [IA64] Fix memcpy_mck.S for current binutils

    The current ia64 assembler complains about mismatching .proc/.endp pairs.
    (Same patch also sent by H.J. Lu)

    Signed-off-by: Andreas Schwab <schwab@suse.de>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 7a9bdd8842d0847f3b15068550a3632a2d259057
tree 548d1f72a9dbdf74b67e45f5f536a71e94c26b81
parent ac09f698f1cda91e890fb75f4cb38253d60ff017
author Suresh Siddha <suresh.b.siddha@intel.com> Tue, 05 Apr 2005 18:05:00 -0700
committer Tony Luck <tony.luck@intel.com> Tue, 03 May 2005 10:33:28 -0700

    [IA64] Add config SCHED_SMT

    Now that we have MC/MT detection patches in, appended patch allows us to
    configure MT scheduler optimizations. For now, we will this option off
    by default.

    There is some discussion going on lkml about setting up sched-domains 
    which are absolutely needed (like for example, we shouldn't setup SMT domain
    for non MT processors). Once that patch goes in, we can enable this option by
    default.

    Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

