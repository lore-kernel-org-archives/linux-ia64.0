From: tony.luck@intel.com
Date: Mon, 25 Apr 2005 21:31:52 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200504252131.j3PLVqP03282@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Here's all the patches that are ready to be migrated from my "test" BK tree.
[everything from that tree execpt a series of patches to speed up the system
call path from David Mosberger, these can wait for 2.6.12]

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git

This will update the files shown below.

Thanks!

-Tony

 ia64/Kconfig                               |    2 
 ia64/configs/sn2_defconfig                 |    2 
 ia64/hp/common/sba_iommu.c                 |   96 +--
 ia64/kernel/entry.S                        |   14 
 ia64/kernel/iosapic.c                      |  360 +++++++++---
 ia64/kernel/irq_ia64.c                     |   16 
 ia64/kernel/perfmon.c                      |   59 --
 ia64/kernel/perfmon_default_smpl.c         |   13 
 ia64/kernel/setup.c                        |   69 ++
 ia64/kernel/smpboot.c                      |  217 +++++++
 ia64/kernel/unwind.c                       |   27 
 ia64/lib/memcpy_mck.S                      |    2 
 ia64/mm/contig.c                           |    3 
 ia64/mm/discontig.c                        |    3 
 ia64/mm/fault.c                            |    9 
 ia64/mm/init.c                             |   74 +-
 ia64/sn/include/pci/pcibr_provider.h       |    6 
 ia64/sn/include/pci/pcibus_provider_defs.h |   43 -
 ia64/sn/include/pci/pcidev.h               |   54 -
 ia64/sn/kernel/Makefile                    |    1 
 ia64/sn/kernel/bte.c                       |   20 
 ia64/sn/kernel/bte_error.c                 |   76 +-
 ia64/sn/kernel/huberror.c                  |    9 
 ia64/sn/kernel/io_init.c                   |   78 ++
 ia64/sn/kernel/irq.c                       |   19 
 ia64/sn/kernel/setup.c                     |    9 
 ia64/sn/kernel/sn2/sn_hwperf.c             |  112 +++
 ia64/sn/kernel/tiocx.c                     |  548 ++++++++++++++++++
 ia64/sn/pci/Makefile                       |    2 
 ia64/sn/pci/pci_dma.c                      |   39 -
 ia64/sn/pci/pcibr/pcibr_ate.c              |    4 
 ia64/sn/pci/pcibr/pcibr_dma.c              |  105 +--
 ia64/sn/pci/pcibr/pcibr_provider.c         |   24 
 ia64/sn/pci/pcibr/pcibr_reg.c              |    4 
 ia64/sn/pci/tioca_provider.c               |  668 ++++++++++++++++++++++
 char/Kconfig                               |   14 
 char/Makefile                              |    3 
 char/mbcs.c                                |  849 +++++++++++++++++++++++++++++
 char/mbcs.h                                |  553 ++++++++++++++++++
 char/snsc.c                                |    8 
 char/snsc.h                                |   40 +
 char/snsc_event.c                          |  304 ++++++++++
 asm-ia64/hw_irq.h                          |    1 
 asm-ia64/pal.h                             |   68 ++
 asm-ia64/perfmon.h                         |   12 
 asm-ia64/pgalloc.h                         |  144 ++--
 asm-ia64/processor.h                       |   10 
 asm-ia64/sal.h                             |   12 
 asm-ia64/smp.h                             |    5 
 asm-ia64/sn/addrs.h                        |    6 
 asm-ia64/sn/bte.h                          |   53 +
 asm-ia64/sn/geo.h                          |   45 -
 asm-ia64/sn/nodepda.h                      |    4 
 asm-ia64/sn/pcibus_provider_defs.h         |   52 +
 asm-ia64/sn/pcidev.h                       |   58 +
 asm-ia64/sn/pda.h                          |    3 
 asm-ia64/sn/shub_mmr.h                     |   37 +
 asm-ia64/sn/sn_sal.h                       |   46 +
 asm-ia64/sn/tioca.h                        |  596 ++++++++++++++++++++
 asm-ia64/sn/tioca_provider.h               |  206 +++++++
 asm-ia64/sn/tiocx.h                        |   71 ++
 asm-ia64/sn/types.h                        |    3 
 62 files changed, 5390 insertions(+), 600 deletions(-)

commit 605036cf8443b9172b24954dc1fd218e2049f91b
tree 6c74011e73452ff0a4d3212fef5373b241a843b0
parent fc626b278a05a0fe3eb9abd1733120f2f400cbcd
author Jesse Barnes <jbarnes@sgi.com> Mon, 25 Apr 2005 13:31:04 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:31:04 -0700

    From: jbarnes@sgi.com
    
    [IA64] fix ia64 Kconfig to allow CONFIG_PM on sn2
    
    This probably should have been fixed when I fixed up the generic build for
    discontig+numa machines, but oh well.
    
    CONFIG_PM is allowable for generic builds but not for sn2 builds, which
    doesn't make much sense, and in fact breaks the build if recent ACPI bits are
    added to the tree.  It looks like the only arch that needs to prevent
    CONFIG_PM stuff is the ski simulator (though those options could probably use
    some cleanup as well), so remove the big conditional and replace it with a
    simple test for IA64_HP_SIM instead.
    
    Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit fc626b278a05a0fe3eb9abd1733120f2f400cbcd
tree f9eb4dabb5ee45700b4f422dcf6bbaa27c7cc58e
parent 67639deb099c6085acc447c1b7d6a17792dedad0
author Greg Howard <ghoward@sgi.com> Mon, 25 Apr 2005 13:29:46 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:29:46 -0700

    [IA64-SGI] snsc_event.c new file
    
    Forgot the "bk new" to add this file. Part of the patch
    from Greg Howard
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 67639deb099c6085acc447c1b7d6a17792dedad0
tree b9cdf0d92ff2c02e7ed182a93d7ea270ba752b10
parent b9e41d7fb62ae26adee84c18048037214ce5d866
author Greg Howard <ghoward@sgi.com> Mon, 25 Apr 2005 13:28:52 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:28:52 -0700

    [IA64] Altix system controller event handling
    
    The following is an update of the patch I sent yesterday
    (3/9/05) incorporating suggestions from Christoph Hellwig and
    Andreas Schwab.  It allows Altix and Altix-like systems to
    handle environmental events generated by the system controllers,
    and should apply on top of Jack Steiner's patch of 3/1/05 ("New
    chipset support for SN platform") and Mark Goodwin's patch of
    3/8/05 ("Altix SN topology support for new chipsets and pci
    topology").
    
    Signed-off-by: Greg Howard <ghoward@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit b9e41d7fb62ae26adee84c18048037214ce5d866
tree d39f224bce0113f860417f81acceb5d2cb8428b3
parent e1ed81ab7a34fc0f92f2e200825bdb6d86d6c8ef
author Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> Mon, 25 Apr 2005 13:27:48 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:27:48 -0700

    [IA64] iosapic.c: typo ... s/spin_unlock_irq/spin_unlock/
    
    vector sharing patch had a typo ... mismatched spin_lock() with
    a spin_unlock_irq().  Fix from Kenji Kaneshige.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit e1ed81ab7a34fc0f92f2e200825bdb6d86d6c8ef
tree 488b22465b9108142b2df16d6e267b0ddda2b839
parent 24eeb568aeeaee771b9f0a6fd6f5d01040a887da
author Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:27:12 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:27:12 -0700

    [IA64] print "siblings" before {physical,core,thread} id
    
    Rohit and Suresh changed their mind about the order to print things
    in /proc/cpuinfo, but didn't include the change in the version of
    the patch they sent to me.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 24eeb568aeeaee771b9f0a6fd6f5d01040a887da
tree 4d3e731845cde292b5a40ff7db97cce639dc073c
parent e927ecb05e1ce4bbb1e10f57008c94994e2160f5
author Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com> Mon, 25 Apr 2005 13:26:23 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:26:23 -0700

    [IA64] vector sharing (Large I/O system support)
    
    Current ia64 linux cannot handle greater than 184 interrupt sources
    because of the lack of vectors. The following patch enables ia64 linux
    to handle greater than 184 interrupt sources by allowing the same
    vector number to be shared by multiple IOSAPIC's RTEs. The design of
    this patch is besed on "Intel(R) Itanium(R) Processor Family Interrupt
    Architecture Guide".
    
    Even if you don't have a large I/O system, you can see the behavior of
    vector sharing by changing IOSAPIC_LAST_DEVICE_VECTOR to fewer value.
    
    Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit e927ecb05e1ce4bbb1e10f57008c94994e2160f5
tree bc8256cc074f02d557088696035982fa7ae0b301
parent 6118ec847e8e35393efc0f88394c2f5dd48c3313
author Suresh Siddha <suresh.b.siddha@intel.com> Mon, 25 Apr 2005 13:25:06 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:25:06 -0700

    [IA64] multi-core/multi-thread identification
    
    Version 3 - rediffed to apply on top of Ashok's hotplug cpu
    patch.  /proc/cpuinfo output in step with x86.
    
    This is an updated MC/MT identification patch based on the 
    previous discussions on list. 
    
    Add the Multi-core and Multi-threading detection for IPF.
      - Add new core and threading related fields in /proc/cpuinfo.
    		Physical id
    		Core id
    		Thread id
    		Siblings
      - setup the cpu_core_map and cpu_sibling_map appropriately
      - Handles Hot plug CPU
     
    Signed-off-by: Suresh Siddha <suresh.b.siddha@intel.com>
    Signed-off-by: Gordon Jin <gordon.jin@intel.com>
    Signed-off-by: Rohit Seth <rohit.seth@intel.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 6118ec847e8e35393efc0f88394c2f5dd48c3313
tree 81b1eb429f1d7154ec7a36c3b6c0418ba2029f02
parent f0a8d3c9ec1f82d2a41faa6c46b8db7bd5b1eb8d
author Keith Owens <kaos@sgi.com> Mon, 25 Apr 2005 13:23:47 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:23:47 -0700

    [IA64] __copy_user breaks on unaligned src
    
    memcpy_mck.S::__copy_user breaks in the prefetch code under these conditions :-
    
    * src is unaligned and
    * dst is near the end of a page and
    * the page after dst is unmapped.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit f0a8d3c9ec1f82d2a41faa6c46b8db7bd5b1eb8d
tree 2b01c7a6d8513e9b08749d3c9cdafdc2cbf19d6b
parent 0985ea8f2db87d32b0b750229889e55fed7458ef
author Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:22:44 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:22:44 -0700

    [IA64] Need to handle lfetch in "no_context" case.
    
    Thanks to Mark for tracking down this one.  Users of __copy_from_user_inatomic()
    will be sad if we don't handle lfetch faults for the "no_context" case.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 0985ea8f2db87d32b0b750229889e55fed7458ef
tree 76e292f65c01b5f298a7a8d5a03287229c4be3a3
parent a37d98f6a98254c05315e0bbf45c4602942d14b1
author Mark Goodwin <markgw@sgi.com> Mon, 25 Apr 2005 13:21:54 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:21:54 -0700

    [IA64-SGI] Altix SN add support for slots in geoid_t locator
    
    This patch against ia64-test-2.6.12 is needed for forthcoming
    Altix chipsets. It renames geoid_any_t to geoid_common_t and
    splits the 8bit 'slab' field into two 4bit fields for 'slab'
    and 'slot'. Similar changes in the Altix SAL will retain backward
    compatibility for old kernels.
    
    Signed-off-by: Mark Goodwin <markgw@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit a37d98f6a98254c05315e0bbf45c4602942d14b1
tree 8d6a3b98118866319a76d719efa9d7fbe5914854
parent 93a07d0a0e7b013ee73fb39d4edb07b47288912e
author David Mosberger-Tang <davidm@hpl.hp.com> Mon, 25 Apr 2005 13:20:38 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:20:38 -0700

    [IA64] fix syscall-optimization goof
    
    Sadly, I goofed in this syscall-tuning patch:
    
    ChangeSet 1.1966.1.40 2005/01/22 13:31:05 davidm@hpl.hp.com
      [IA64] Improve ia64_leave_syscall() for McKinley-type cores.
    
      Optimize ia64_leave_syscall() a bit better for McKinley-type cores.
      The patch looks big, but that's mostly due to renaming r16/r17 to r2/r3.
      Good for a 13 cycle improvement.
    
    The problem is that the size of the physical stacked registers was
    loaded into the wrong register (r3 instead of r17).  Since r17 by
    coincidence always had the value 1, this had the effect of turning
    rse_clear_invalid into a no-op.  That poses the risk of leaking kernel
    state back to user-land and is hence not acceptable.
    
    The fix below is simple, but unfortunately it costs us about 28 cycles
    in syscall overhead. ;-(
    
    Unfortunately, there isn't much we can do about that since those
    registers have to be cleared one way or another.
    
    	--david
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 93a07d0a0e7b013ee73fb39d4edb07b47288912e
tree e68ba0b39bcc8a9e844889af1229c024be29e95c
parent 95ff439a517835aa2bdf725fafbb025a63984289
author Russ Anderson <rja@sgi.com> Mon, 25 Apr 2005 13:19:52 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:19:52 -0700

    [IA64-SGI] Shub2 BTE support - BTE recovery code
    
    patch 2:
    	Shub2 BTE recovery code will be implemented in SAL.  
    	Define the SAL interface.
    	Modify bte_error to call SAL for shub2.
    
    Signed-off-by: Russ Anderson <rja@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 95ff439a517835aa2bdf725fafbb025a63984289
tree 4d04b1bfcbe4a4c0b27e7b58e3edb77b4111a3a2
parent 4628d7cada7a19166ba8fe57f5ef0f0009694e1e
author Russ Anderson <rja@sgi.com> Mon, 25 Apr 2005 13:19:11 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:19:11 -0700

    [IA64-SGI] Add new MMR definitions/Modify BTE initialiation&copy.
    
    patch 1:
    	Add new MMR definitions.
    	Modify BTE initialiation.
    	Modify BTE copy.
    
    Signed-off-by: Russ Anderson <rja@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 4628d7cada7a19166ba8fe57f5ef0f0009694e1e
tree 86fa31598303768755a4caeee662b4c999c3a929
parent e96c9b4779e651a7469bea677be3a08f70be399e
author Mark Maule <maule@sgi.com> Mon, 25 Apr 2005 13:18:02 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:18:02 -0700

    [IA64-SGI] disable TIOCA GART TLB prefetching
    
    Patch to disable SGI TIOCA GART TLB prefetching due to hw bug.
    
    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit e96c9b4779e651a7469bea677be3a08f70be399e
tree 12ae1cb3dde60b65dc2682371624260de6cea79a
parent c411cb56586915350e4cdb6f228e9da2adba3285
author Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:16:59 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:16:59 -0700

    [IA64] MAX_PGT_FREES_PER_PASS must be 'L' to avoid warning
    
    'min' is very picky about types of arguments, make it happy
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit c411cb56586915350e4cdb6f228e9da2adba3285
tree 61cf8e8eb97592d2e3d8e7524dfabde731d97d12
parent 5f6602a101993592b437b801c401443bec65d0cf
author Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:16:16 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:16:16 -0700

    [IA64] fix: warning: `ql_size' might be used uninitialized
    
    Oops.  Should have caught this before I checked it in.
    
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 5f6602a101993592b437b801c401443bec65d0cf
tree 603ce367a349b9454a7f6b77953b3ecdf194ec68
parent fde740e4dd4a05ca8957490d468fa9b2770f5bd6
author Alex Williamson <alex.williamson@hp.com> Mon, 25 Apr 2005 13:14:36 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:14:36 -0700

    [IA64] sba_iommu bug fixes
    
       This fixes a couple of bugs in the zx1/sx1000 sba_iommu.  These are
    all pretty low likelihood of hitting.  The first problem is a simple off
    by one, deep in the sba_alloc_range() error path.  Surrounding that was
    a lock ordering problem that could have potentially deadlocked with the
    order the locks are grabbed in sba_unmap_single().  I moved the resource
    locking into sba_search_bitmap() to prevent this.  Finally, there's a
    potential race between unmapping pdir entries and marking incoming DMA
    pages clean.  If you see any oddities, please let me know, but I've
    tested it pretty thoroughly here.  Tony, please apply.  Thanks,
    
    BTW, many of the options in this driver not on by default are becoming
    more and more broken.  I'll be working on some patches to clean them
    out, but I wanted to get this bug fix out first.
    
    Signed-off-by: Alex Williamson <alex.williamson@hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit fde740e4dd4a05ca8957490d468fa9b2770f5bd6
tree 04bc0221bc6c59379a17f3631fc4bd3c886e1d61
parent ff3eb55ed97db3f12964beeffe3d34602d295367
author Robin Holt <holt@sgi.com> Mon, 25 Apr 2005 13:13:16 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:13:16 -0700

    [IA64] Percpu quicklist for combined allocator for pgd/pmd/pte.
    
    This patch introduces using the quicklists for pgd, pmd, and pte levels
    by combining the alloc and free functions into a common set of routines.
    This greatly simplifies the reading of this header file.
    
    This patch is simple but necessary for large numa configurations.
    It simply ensures that only pages from the local node are added to a
    cpus quicklist.  This prevents the trapping of pages on a remote nodes
    quicklist by starting a process, touching a large number of pages to
    fill pmd and pte entries, migrating to another node, and then unmapping
    or exiting.  With those conditions, the pages get trapped and if the
    machine has more than 100 nodes of the same size, the calculation of
    the pgtable high water mark will be larger than any single node so page
    table cache flushing will never occur.
    
    I ran lmbench lat_proc fork and lat_proc exec on a zx1 with and without
    this patch and did not notice any change.
    
    On an sn2 machine, there was a slight improvement which is possibly
    due to pages from other nodes trapped on the test node before starting
    the run.  I did not investigate further.
    
    This patch shrinks the quicklist based upon free memory on the node
    instead of the high/low water marks.  I have written it to enable
    preemption periodically and recalculate the amount to shrink every time
    we have freed enough pages that the quicklist size should have grown.
    I rescan the nodes zones each pass because other processess may be
    draining node memory at the same time as we are adding.
    
    Signed-off-by: Robin Holt <holt@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit ff3eb55ed97db3f12964beeffe3d34602d295367
tree 91a29b33ec016e8fb5280e6896f2faf26bd69e54
parent c1298c5c7e5763a3b2fd4a9535d474ff6e54cd53
author Bruce Losure <blosure@sgi.com> Mon, 25 Apr 2005 13:12:02 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:12:02 -0700

    [IA64-SGI]
    
    Missed the "bk new" for this file in the last commit.
    
    Signed-off-by: Bruce Losure <blosure@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit c1298c5c7e5763a3b2fd4a9535d474ff6e54cd53
tree 9235aeedfff44ddb7330ce119ad285bf92e65253
parent e1e19747ecce9117610b8f3b57a3e95734230319
author Aaron J Young <ayoung@sgi.com> Mon, 25 Apr 2005 13:11:14 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:11:14 -0700

    [IA64-SGI] Altix: enable poweroff
    
    This patch adds the necessary "hook" to allow SGI/SN
    machines to perform a system power off upon a 
    'init 0', 'halt -p', 'poweroff' or 'shutdown -h'.
    
    The "hook" is to set the pm_power_off callback
    to ia64_sn_power_down(). pm_power_off is checked
    in machine_power_off()/do_poweroff() and, if set, is executed. 
    ia64_sn_power_down() is a function already present (but not 
    used currently) in the sn kernel.
    ia64_sn_power_down() makes a SAL call to execute the
    power off.
    
    Signed-off-by: Aaron J Young <ayoung@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit e1e19747ecce9117610b8f3b57a3e95734230319
tree df3d9ed57ad8155de89d1d80bbfec1833d2621fb
parent 4944930ab748942e41ea4dc313fcb0946aee3f17
author Bruce Losure <blosure@sgi.com> Mon, 25 Apr 2005 13:09:41 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:09:41 -0700

    [IA64-SGI] Bus driver for the CX port of SGI's TIO chip.
    
    This patch is to provide CX port infrastructure for SGI TIO-based
    h/w.   Also a 'core services' driver for SGI FPGA-based h/w.
                                                                                    
    Signed-off-by: Bruce Losure <blosure@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 4944930ab748942e41ea4dc313fcb0946aee3f17
tree 5d23e420c0d7f4387237028ca2dca1ec97f59861
parent 658b32cad9ae087bd34f35a925fd75b76d663d4e
author Stephane Eranian <eranian@hpl.hp.com> Mon, 25 Apr 2005 13:08:30 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:08:30 -0700

    [IA64] perfmon: make pfm_sysctl a global, and other cleanup
    
    - make pfm_sysctl a global such that it is possible
      to enable/disable debug printk in sampling formats
      using PFM_DEBUG.
    
    - remove unused pfm_debug_var variable
    
    - fix a bug in pfm_handle_work where an BUG_ON() could
      be triggered. There is a path where pfm_handle_work()
      can be called with interrupts enabled, i.e., when
      TIF_NEED_RESCHED is set. The fix correct the masking
      and unmasking of interrupts in pfm_handle_work() such
      that we restore the interrupt mask as it was upon entry.
    
    signed-off-by: stephane eranian <eranian@hpl.hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 658b32cad9ae087bd34f35a925fd75b76d663d4e
tree b742c5e1e756912fe6f6a81ebb4a9db814c641e7
parent be539c73b54dcc9f54fb2c2b70e204c93b616c9b
author Colin Ngam <cngam@sgi.com> Mon, 25 Apr 2005 13:07:00 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:07:00 -0700

    [IA64-SGI] support variable length nasids in shub2
    
    This patch enables our TIO IO chipset to support variable length nasids in 
    Shub2 chipset.
    
    Signed-off-by: Colin Ngam <cngam@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit be539c73b54dcc9f54fb2c2b70e204c93b616c9b
tree 2416682e77842ccde4301edb9b7a2182b847ce10
parent f1e2a1c8a1fe16db5f4a7c0c1551d6e1b97dcbb2
author Colin Ngam <cngam@sgi.com> Mon, 25 Apr 2005 13:06:28 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:06:28 -0700

    [IA64-SGI] Shub2 provides an addition of 2 External Interrupt events.
    
    Signed-off-by: Colin Ngam <cngam@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit f1e2a1c8a1fe16db5f4a7c0c1551d6e1b97dcbb2
tree b85b5659b94cdb1f656f11f4761fe0836c011076
parent 4a5c13c7eb0d55bfd2cf3100c55f1e3d8df37576
author Mark Goodwin <markgw@sgi.com> Mon, 25 Apr 2005 13:05:08 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:05:08 -0700

    [IA64-SGI] Altix SN topology fix potential infinite loop
    
    Fix infinite loop if sn_hwperf_location_to_bpos() fails.
    
    Signed-off-by: Mark Goodwin <markgw@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 4a5c13c7eb0d55bfd2cf3100c55f1e3d8df37576
tree 400e51f79f9ba6d34c66401e1760a51e792d14aa
parent 30325d17715302a60c9afdaacaafaeb056b7e880
author Mark Goodwin <markgw@sgi.com> Mon, 25 Apr 2005 13:04:22 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:04:22 -0700

    [IA64-SGI] Altix SN topology support for new chipsets and pci topology
    
    please accept this patch to the Altix SN platform topology export
    interface to support new chipsets and to export PCI topology.
    
    This follows on top of Jack Steiner's patch dated March 1st
    ("New chipset support for SN platform").
    
    Signed-off-by: Mark Goodwin <markgw@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 30325d17715302a60c9afdaacaafaeb056b7e880
tree 8872d59f841a5338e04f15c1183b8fd2ad4bfbb3
parent e8d1cb2f280aa53e1c75c8b5fcbf80b3481d0caa
author David Mosberger-Tang <davidm@hpl.hp.com> Mon, 25 Apr 2005 13:03:16 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 13:03:16 -0700

    [IA64] speed up syscall path a bit more
    
    Recently I noticed that clearing ar.ssd/ar.csd right before srlz.d is
    causing significant stalling in the syscall path.  The patch below
    fixes that by moving the register-writes after srlz.d.  On a Madison,
    this drops break-based getpid() from 241 to 226 cycles (-15 cycles).
    
    Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit e8d1cb2f280aa53e1c75c8b5fcbf80b3481d0caa
tree 832d5f4beabfc1c075dd54eebe343ad10c611c73
parent 8297511530b0d2a281c796e738683951a59a020c
author Keith Owens <kaos@sgi.com> Mon, 25 Apr 2005 11:45:26 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 11:45:26 -0700

    [IA64] Tighten up unw_unwind_to_user check
    
    Detect user space by the unwind frame with predicate PRED_USER_STACK
    set, instead of a user space IP.  Tighten up the last ditch check for
    running off the top of the kernel stack.
    
    Based on a suggestion by David Mosberger, reworked to fit the current
    tree.  This survives my stress test which used to break 2.6.9 kernels.
    Unlike 2.6.11, the stress test now unwinds to the correct point, so
    gdb can get the user space registers.
    
    Signed-off-by: Keith Owens <kaos@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 8297511530b0d2a281c796e738683951a59a020c
tree 3ade89d674db6b0791ca72704478214d0bb56ad1
parent bf1cf98fa941fea5e630e341db4a294d531aaa3e
author David Mosberger-Tang <davidm@hpl.hp.com> Mon, 25 Apr 2005 11:44:02 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 11:44:02 -0700

    [IA64] add missing cpu_relax() in ITC syncing code
    
    Call cpu_relax() in busy-waiting loops of the ITC-syncing code.
    
    Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit bf1cf98fa941fea5e630e341db4a294d531aaa3e
tree e6f8872acefbe2360adf9dbeea85b553e02aa557
parent 9c90bdde77f7b7a42f7ebb900275d459ce2bac05
author Jack Steiner <steiner@sgi.com> Mon, 25 Apr 2005 11:42:39 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 11:42:39 -0700

    [IA64-SGI] Change SAL call request code for SN systems
    
    Change the value of the SAL call number for a new SAL request. The
    initial implementation in the PROM did not match what the OS expected. 
    Since the OS can run on PROMs that do not implement the new call, 
    changing the call number avoids the issue. New PROMs will implement
    the new call number. (This avoids problems with the 4.05 PROM).
    
    Signed-off-by: Jack Steiner <steiner@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 9c90bdde77f7b7a42f7ebb900275d459ce2bac05
tree a196bb35cb506d2495748506fdbc9280111dee03
parent 9b08ebd167a3f3812131a54512f92c3c6738ad03
author Mark Maule <maule@sgi.com> Mon, 25 Apr 2005 11:35:54 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 11:35:54 -0700

    [IA64-SGI] altix: tioca chip driver (agp)
    
    Provide a driver for the altix TIOCA AGP chipset.  An agpgart backend will
    be provided as a separate patch.
    
    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit 9b08ebd167a3f3812131a54512f92c3c6738ad03
tree 759d4a02d44d233eb7de4dba4fe4626d5d6d29ac
parent e955d82543fea76b02aa243b182e782f71bda82c
author Mark Maule <maule@sgi.com> Mon, 25 Apr 2005 11:32:16 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 11:32:16 -0700

    [IA64-SGI] sn2-move-pci-headers.patch
    
    Move a couple of headers out of arch/ia64/sn/include/pci and into
    include/asm-ia64/sn.
    
    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

commit e955d82543fea76b02aa243b182e782f71bda82c
tree 58dc9df5161f47bca69c8dc9c819495f15694352
parent 25ee7e3832951cf5896b194f6cd929a44863f419
author Mark Maule <maule@sgi.com> Mon, 25 Apr 2005 11:26:03 -0700
committer Tony Luck <tony.luck@intel.com> Mon, 25 Apr 2005 11:26:03 -0700

    [IA64-SGI] sn2-pci-dma-abstraction.patch
    
    Provide an abstraction of the altix pci dma runtime layer so that multiple
    pci-based bridges can be supported.
    
    Signed-off-by: Mark Maule <maule@sgi.com>
    Signed-off-by: Tony Luck <tony.luck@intel.com>

