From: tony.luck@intel.com
Date: Fri, 03 Sep 2004 06:05:07 +0000
Subject: bk pull on ia64 linux tree
Message-Id: <200409030605.i83657703878@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please do a

	bk pull http://lia64.bkbits.net/linux-ia64-release-2.6.9

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/configs/generic_defconfig     |   28 +++++---
 arch/ia64/configs/sn2_defconfig         |   37 +++++++----
 arch/ia64/kernel/efi.c                  |    4 -
 arch/ia64/kernel/palinfo.c              |    2 
 arch/ia64/kernel/perfmon.c              |   35 +++++++---
 arch/ia64/kernel/sal.c                  |   38 +++++++++++
 arch/ia64/mm/contig.c                   |    8 +-
 arch/ia64/oprofile/Kconfig              |    4 +
 arch/ia64/oprofile/Makefile             |    1 
 arch/ia64/oprofile/init.c               |    9 ++
 arch/ia64/oprofile/perfmon.c            |  105 ++++++++++++++++++++++++++++++++
 arch/ia64/sn/kernel/sn2/prominfo_proc.c |   74 ++++++++++++++++++----
 include/asm-ia64/mmu_context.h          |   39 -----------
 include/asm-ia64/page.h                 |    7 ++
 include/asm-ia64/sal.h                  |   10 +++
 include/asm-ia64/tlb.h                  |    1 
 include/asm-ia64/tlbflush.h             |    7 --
 17 files changed, 314 insertions(+), 95 deletions(-)

through these ChangeSets:

<ianw@gelato.unsw.edu.au> (04/09/03 1.1803.109.2)
   [IA64] VIRTUAL_MEM_MAP can be set when DISCONTIGMEM isn't; handle it
   
   Patch developed by Ian Wienand under advice from Bill Irwin.
   
   Signed-off-by: William Irwin <wli@holomorphy.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<eranian@hpl.hp.com> (04/08/30 1.1803.114.2)
   [IA64] perfmon.c: cleanup system-wide context when closed from another cpu
   
   - fix pfm_stop() and pfm_flush_pmds() to correctly cleanup
     in case of a system-wide context which is closed while running
     from another processor. This was leading to an assertion failure
     in pfm_loads_regs() for the next user of the PMU on the monitored
     CPU.
   
   signed-off-by: stephane eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<eranian@hpl.hp.com> (04/08/30 1.1803.114.1)
   [IA64] palinfo.c: typo s/BEER/BERR/
   
   - fix a typo in the file /proc/pal/CPU*/processor_info w.r.t.
     to BERR promotion. Initially reported by Danny Kwong from HP.
   
   Signed-off-by: stephane eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/30 1.1803.113.1)
   [IA64-SGI] sn2_defconfig: Enable preempt, CPU hotplug, ext2 and IDE.
   
   o enable preempt per Andrew's request for testing
   o enable CPU hotplug for testing
   o add EXT2 and IDE disk support to make simulation easy
   
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<eranian@hpl.hp.com> (04/08/27 1.1803.112.1)
   [IA64] perfmon.c: file descriptor fixes
   
     - fix pfm_free_fd() to clear current->files->fd[fd] in
       case of error during PFM_CONTEXT_CREATE, i.e., undo
       the effect of fd_install(). This could cause kernel
       panic if the file descriptor gets used by error through
       perfmon.
     - fix pfm_context_create() to correctly propagate the
       return value of pfm_alloc_fd().
   
   signed-off-by: stephane eranian <eranian@hpl.hp.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<levon@movementarian.org> (04/08/25 1.1803.111.1)
   [IA64] support for IA64 hardware performance counters via the perfmon interface
    
      This patch provides support for IA64 hardware performance counters via
      the perfmon interface. Please consider applying.
   
   Signed-off-by: John Levon <levon@movementarian.org>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<dcn@sgi.com> (04/08/25 1.1803.110.1)
   [IA64] allow OEM written modules to make calls to ia64 OEM SAL functions.
   
   Add wrapper functions for SAL_CALL(), SAL_CALL_NOLOCK(), and
   SAL_CALL_REENTRANT() that allow OEM written modules to make
   calls to ia64 OEM SAL functions.
   
   Signed-off-by: Dean Nelson <dcn@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<ianw@gelato.unsw.edu.au> (04/08/25 1.1803.109.1)
   [IA64] Remove extraneous MMU_TRACE debugging macros
   
   Patch created by Ian Wienand.
   
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<yanmin.zhang@intel.com> (04/08/25 1.1803.108.2)
   [IA64] contig.c: Function find_bootmap_location has 2 bugs.
   
   Firstly, if it's done successfully, it should return -1 instead of 1
   because its caller, efi_memmap_walk, will end when find_bootmap_location
   returns a value smaller than 0.
   
   Secondly, statement "free_start = PAGE_ALIGN(rsvd_region[i].end)" should
   been moved forward. free_start needs to be initialized for every loop
   iteration.  Current implementation is buggy where initialization is
   skipped if range_end <= range_start.  Skipping initializing will leads
   to overlapping bootmap with one of the rsvd_regions and subsequently
   kernel hang at boot time.
   
   Singed-off-by:(sic) Zhang Yanmin <yanmin.zhang@intel.com>
   Signed-off-by:      Yao Jun      <junx.yao@intel.com>
   Signed-off-by:      Tony Luck    <tony.luck@intel.com>

<yanmin.zhang@intel.com> (04/08/25 1.1803.108.1)
   [IA64] Fix boot problems when using "mem=" boot parameter.
   
   My tiger-4 machine has 16GB memory. Kernel 2.6.8 fails to boot on it
   when command line parameter mem=8G, and it also fails when mem being
   set to other value, such as 7G, 10G.
   
   Basically, in function efi_memmap_walk, md->num_pages might be decreased
   if mem_limit is set, and then at the next time when efi_memmap_walk is
   called, trim_top might trim the md again because of IA64_GRANULE_SIZE
   alignment, then another md which is beyond mem_limit at the beginning
   will be chosen, and its physical page number is larger than max_pfn. Then,
   a BUG check is triggered.
   
   Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
   Signed-off-by: Yao Jun      <junx.yao@intel.com>
   Signed-off-by: Tony Luck    <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/25 1.1803.90.19)
   [IA64] generic_defconfig: Enable codepage/iocharset for VFAT filesystems.
   
   VFAT filesystems need to have codepages and iocharsets specified these days,
   so build some into the kernel to make it easier to mount /boot/efi on ia64
   systems.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<jbarnes@sgi.com> (04/08/25 1.1803.90.18)
   [IA64] Add include pagemap.h to tlb.h to fix warnings when CONFIG_SWAP=n.
   
   I noticed when building with CONFIG_SWAP=n that tlb.h gave a warning about
   some undefined symbols.  This is because it was pulling them in through
   swap.h, but when CONFIG_SWAP=n, they're no longer pulled in.  Adding
   pagemap.h to tlb.h fixes the problem.
    
   Signed-off-by: Jesse Barnes <jbarnes@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

<bjohnson@sgi.com> (04/08/25 1.1803.90.17)
   [IA64-SGI] Add full PROM version banner to /proc/sgi_prominfo/nodeXX/version.
   
   Signed-off-by: Brian J. Johnson <bjohnson@sgi.com>
   Signed-off-by: Tony Luck <tony.luck@intel.com>

