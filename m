From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 19 Jan 2005 18:52:42 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200501191852.j0JIqgP08897@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.11

This will update the files shown below.  Almost all of this has been
in my "test" tree for a while (and thus in "-mm").

I have one tiny generic change in here ... define a function "idle_task"
in kernel/sched.c (and declare it in sched.h) that is part of Keith Owens'
TIF_SIGDELAYED patch that ia64 uses in machine check processing to defer
the sending of a signal from the exception code (where we cannot safely
touch kernel structures) to the next return to userland.

Thanks!

-Tony

 include/asm-ia64/sn/router.h              |  618 ------------------
 arch/ia64/Kconfig                         |   11 
 arch/ia64/kernel/asm-offsets.c            |   11 
 arch/ia64/kernel/efi.c                    |  180 +++--
 arch/ia64/kernel/entry.S                  |   15 
 arch/ia64/kernel/irq.c                    |  986 ------------------------------
 arch/ia64/kernel/irq_ia64.c               |    2 
 arch/ia64/kernel/mca.c                    |   18 
 arch/ia64/kernel/mca_asm.S                |   65 -
 arch/ia64/kernel/minstate.h               |    7 
 arch/ia64/kernel/salinfo.c                |   20 
 arch/ia64/kernel/setup.c                  |    3 
 arch/ia64/kernel/signal.c                 |  101 +++
 arch/ia64/kernel/time.c                   |    2 
 arch/ia64/lib/swiotlb.c                   |    4 
 arch/ia64/mm/contig.c                     |   12 
 arch/ia64/mm/discontig.c                  |   75 +-
 arch/ia64/mm/init.c                       |   65 +
 arch/ia64/sn/kernel/iomv.c                |   21 
 arch/ia64/sn/kernel/irq.c                 |    4 
 arch/ia64/sn/kernel/setup.c               |   55 +
 arch/ia64/sn/kernel/sn2/ptc_deadlock.S    |   24 
 arch/ia64/sn/kernel/sn2/sn2_smp.c         |   98 +-
 arch/ia64/sn/kernel/sn2/timer.c           |    5 
 arch/ia64/sn/kernel/sn2/timer_interrupt.c |    1 
 include/asm-ia64/hardirq.h                |    2 
 include/asm-ia64/hw_irq.h                 |    4 
 include/asm-ia64/kregs.h                  |    1 
 include/asm-ia64/mca.h                    |   36 -
 include/asm-ia64/mca_asm.h                |   35 +
 include/asm-ia64/msi.h                    |    1 
 include/asm-ia64/percpu.h                 |    2 
 include/asm-ia64/processor.h              |    4 
 include/asm-ia64/sal.h                    |    4 
 include/asm-ia64/signal.h                 |    2 
 include/asm-ia64/sn/addrs.h               |  387 ++++-------
 include/asm-ia64/sn/arch.h                |    3 
 include/asm-ia64/sn/klconfig.h            |    2 
 include/asm-ia64/sn/leds.h                |    1 
 include/asm-ia64/sn/nodepda.h             |    2 
 include/asm-ia64/sn/pda.h                 |   13 
 include/asm-ia64/sn/rw_mmr.h              |    9 
 include/asm-ia64/sn/shub_mmr.h            |  221 +++---
 include/asm-ia64/sn/sn_cpuid.h            |    5 
 include/asm-ia64/sn/sn_sal.h              |   53 +
 include/asm-ia64/thread_info.h            |   18 
 include/linux/sched.h                     |    1 
 kernel/sched.c                            |    9 
 48 files changed, 1007 insertions(+), 2211 deletions(-)

through these ChangeSets:

<rja@sgi.com> (05/01/18 1.1984)
   [IA64] contig.c save physical address of MCA save area
   
   Ashok Raj uncovered a problem while testing the MCA code
   on a tiger box with contig memory.  The virtual address
   was getting saved instead of the physical address of the
   MCA save area.  This patch fixes that problem.
    
   Signed-off-by: Russ Anderson <rja@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<rddunlap@osdl.org> (05/01/14 1.1975.48.1)
   [IA64/X86_64] swiotlb.c: fix gcc printk warning
   
   swiotlb: Fix gcc printk format warning on x86_64, OK for ia64:
   arch/ia64/lib/swiotlb.c:351: warning: long unsigned int format, long
   long unsigned int arg (arg 2)
   
   Signed-off-by: Randy Dunlap <rddunlap@osdl.org>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (05/01/11 1.1982)
   [IA64-SGI] Delete unneeded SN2 header file router.h
   
   Delete unused header file. The file became obsolete after the
   IO reorg code was completed.
    
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (05/01/11 1.1981)
   [IA64-SGI] Update SN2 code for running on simulator
      
   Update the hack in sn_io_addr() that is used when running on the
   system simulator. The change is needed for running on systems with
   the new shub2 chipset.
   
   Note that this change affects simulator runs only.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<rja@sgi.com> (05/01/07 1.1980)
   [IA64] correct PERCPU_MCA_SIZE and ia64_init_stack size
   
     * PERCPU_MCA_SIZE was the size of the wrong structure.
     * ia64_init_stack was larger than necessary.
   
   Signed-off-by: Russ Anderson <rja@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (05/01/07 1.1979)
   [IA64] Use alloc_bootmem() to get the space for mca_data.
   
   PERCPU_MCA_SIZE is not a power of two, so is unsuited to be used as the 'align'
   argument to __alloc_bootmem().  In fact we don't need any special alignment for
   this structure, so we can use the simpler alloc_bootmem() macro interface to the
   allocator.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<rja@sgi.com> (05/01/06 1.1978)
   [IA64] Fix problems in per cpu MCA code.
   
   * K.3 was not getting set on all cpus.
   
   * The pointer to each cpu's mca save area was getting incremented
     before being set, with the result that the last cpu's pointer
     was wrong.
   
   * Made contig.c changes corresponding to earlier discontig.c changes.
   
   * An offset into cpuinfo_ia64 structure was wrong in mca_asm.S.
   
   Special thanks to Keith Owens for helping test and identify problems.
   
   Signed-off-by: Russ Anderson <rja@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (05/01/06 1.1977)
   [IA64] Stagger the addresses of the pernode data structures to minimize cache aliasing.
   
   Allocation of pernode structures in find_pernode_space() does not
   properly stagger the alignment of the pgdats. This causes
   aliasing of the structures in the L3 caches, ie. the same fields
   in pgdat structures for multiple nodes will index to same cache
   index in the L3. 
   
   If a process is allocating a huge amount of space & many nodes must 
   be scanned before finding a node with available space, allocation 
   of a pages is significantly slowed by excessive cache misses.
   
   By properly staggering the locations of the pgdat structures, allocation
   times on insanely large systems is dramatically improved. On a 256 node
   512GB system, allocation of 450 GB by a single process was reduced 
   from 1510 sec to 220 sec - a 7X improvement.
   
   Aside from wasting a trivial amount of space, I don't see any 
   downside to staggering the allocation by 1 cacheline per node.
   
   	wasted space
   		bytes = N * (N-1) * 64
   
   	For 64 node system
   		wasted bytes = ~256K
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (04/12/13 1.1938.435.11)
   [IA64] Drop SALINFO_TIMER_DELAY from 5 minutes to 1 minute
   
   Experience with recoverable MCA events shows that a poll interval of 5
   minutes for new MCA/INIT records is a bit too long.  Drop the poll
   interval to one minute.
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (04/12/13 1.1938.435.10)
   [IA64] Clear all corrected records as they occur
   
   Because MCA events are not irq safe, they cannot be logged via
   salinfo_decode at the time that they occur.  Instead kernel salinfo.c
   runs a timer every few minutes to check for and to clear corrected MCA
   records.  If a second recoverable MCA occurs on the same cpu before
   salinfo_decode has cleared the first record then OS_MCA reads the
   record for the first MCA from SAL, which passes invalid data to the MCA
   recovery routines.
   
   This patch treats all corrected records the same way, by clearing the
   records from SAL as soon as they occur.  CMC and CPE records are
   cleared as they are read.  Recoverable MCA records are cleared at the
   time that we decide they can be corrected.  If salinfo_decode is not
   running or is backlogged then we lose some logging, but that has always
   been the case for corrected errors.
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<kaos@sgi.com> (04/12/13 1.1938.435.9)
   [IA64] Add TIF_SIGDELAYED, delay a signal until it is safe
   
   Some of the work on recoverable MCA events has a requirement to send a
   signal to a user process.  But it is not safe to send signals from
   MCA/INIT/NMI/PMI, because the rest of the kernel is an unknown state.
   This patch adds set_sigdelayed() which is called from the problem
   contexts to set the delayed signal.  The delayed signal will be
   delivered from the right context on the next transition from kernel to
   user space.
   
   If TIF_SIGDELAYED is set when we run ia64_leave_kernel or
   ia64_leave_syscall then the delayed signal is delivered and cleared.
   All code for sigdelayed processing is on the slow paths.
   
   A recoverable MCA handler that wants to kill a user task just does
   
     set_sigdelayed(pid, signo, code, addr);
   
   Signed-off-by: Keith Owens <kaos@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<tony.luck@intel.com> (04/12/10 1.1938.435.8)
   [IA64] hardirq.h: Add declaration for ack_bad_irq().
   
   Cleanup a warning from my irq merge.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<rja@sgi.com> (04/12/10 1.1938.435.7)
   [IA64] per cpu MCA/INIT save areas
   
     Linux currently has one MCA & INIT save area for saving
     stack and other data.  This patch creates per cpu MCA 
     save areas, so that each cpu can save its own MCA stack 
     data.  CPU register ar.k3 is used to hold a physical 
     address pointer to the cpuinfo structure.  The cpuinfo
     structure has a physical address pointer to the MCA save 
     area.  The MCA handler runs in physical mode and the 
     physical address pointer avoids the problems associated
     with doing the virtual to physical translation.
   
     The per MCA save areas replace the global areas defined
     in arch/ia64/kernel/mca.c for MCA processor state dump, 
     MCA stack, MCA stack frame, and MCA bspstore.
   
     The code to access those save areas is updated to use the
     per cpu save areas.
   
     No changes are made to the MCA flow, ie all the old locks
     are still in place.  The point of this patch is to establish
     the per cpu save areas.  Additional usage of the save areas,
     such as enabling concurrent INIT or MCA handling, will be
     the subject of other patches.
   
   Signed-off-by: Russ Anderson <rja@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (04/12/10 1.1938.435.6)
   [IA64] Cachealign jiffies_64 to prevent unexpected aliasing in the caches.
   
   On large systems, system overhead on cpu 0 is higher than on other
   cpus. On a completely idle 512p system, the average amount of system time 
   on cpu 0 is 2.4%  and .15% on cpu 1-511.
   
   A second interesting data point is that if I run a busy-loop
   program on cpus 1-511, the system overhead on cpu 0 drops 
   significantly.
   
   I moved the timekeeper to cpu 1. The excessive system time moved
   to cpu 1 and the system time on cpu 0 dropped to .2%.
   
   Further investigation showed that the problem was caused by false
   sharing of the cacheline containing jiffies_64. On the kernel that
   I was running, both jiffies_64 & pal_halt share the same cacheline.
   Idle cpus are frequently accessing pal_halt. Minor kernel
   changes (including some of the debugging code that I used to find the 
   problem :-(  ) can cause variables to move & change the false sharing - the
   symptoms of the problem can change or disappear.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<steiner@sgi.com> (04/12/10 1.1938.435.4)
   [IA64-SGI] Add support for a future SGI chipset (shub2) 4of4
   
   Change the code that manages the LEDs so that it
   works on both shub1 & shub2.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>

<steiner@sgi.com> (04/12/10 1.1938.435.3)
   [IA64-SGI] Add support for a future SGI chipset (shub2) 3of4
   
   Change the IPI & TLB flushing code so that it works on
   both shub1 & shub2.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>

<steiner@sgi.com> (04/12/10 1.1938.435.2)
   [IA64-SGI] Add support for a future SGI chipset (shub2) 2of4
   
   This patch adds the addresses of shub2 MMRS to the shub_mmr
   header file. During boot, a SAL call is made to determine the
   type of the shub. Platform initialization sets the appropriate
   MMR addresses for the platform.
   
   A new macro (is_shub1() & is_shub2()) can be used at runtime to
   determine the type of the shub.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>

<steiner@sgi.com> (04/12/10 1.1938.435.1)
   [IA64-SGI] Add support for a future SGI chipset (shub2) 1of4
   
   This patch changes the SN macros for calulating the addresses
   of shub MMRs. Functionally, shub1 (current chipset) and shub2
   are very similar. The primary differences are in the addresses
   of MMRs and in the location of the NASID (node number) in
   a physical address. This patch adds the basic infrastructure
   for running a single binary kernel image on either shub1 or shub2.
   
   Signed-off-by: Jack Steiner <steiner@sgi.com>

<tony.luck@intel.com> (04/11/23 1.1938.391.1)
   [IA64] convert to use CONFIG_GENERIC_HARDIRQS
   
   Convert ia64 to use generic irq handling code.
   
   sn2 fixes and testing by Jesse Barnes
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

