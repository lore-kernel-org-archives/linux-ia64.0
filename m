From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 14 Jan 2006 13:43:05 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200601141343.k0EDh5Hq005232@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/sn/kernel/xpc.h               | 1274 -------------------------------
 arch/ia64/hp/sim/simserial.c            |   10 
 arch/ia64/kernel/fsys.S                 |    1 
 arch/ia64/kernel/jprobes.S              |   27 
 arch/ia64/kernel/kprobes.c              |   57 +
 arch/ia64/kernel/mca_asm.S              |    2 
 arch/ia64/kernel/salinfo.c              |  170 ++--
 arch/ia64/kernel/traps.c                |   26 
 arch/ia64/mm/tlb.c                      |    2 
 arch/ia64/sn/include/xtalk/hubdev.h     |   16 
 arch/ia64/sn/kernel/bte_error.c         |   58 +
 arch/ia64/sn/kernel/huberror.c          |    9 
 arch/ia64/sn/kernel/io_init.c           |   92 +-
 arch/ia64/sn/kernel/xpc.h               |    3 
 arch/ia64/sn/kernel/xpc_channel.c       |   24 
 arch/ia64/sn/kernel/xpc_main.c          |  189 +++-
 arch/ia64/sn/kernel/xpc_partition.c     |   10 
 arch/ia64/sn/pci/pcibr/pcibr_dma.c      |   34 
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |   20 
 include/asm-ia64/kprobes.h              |    6 
 include/asm-ia64/sn/sn_sal.h            |    5 
 include/asm-ia64/sn/xp.h                |    4 
 include/asm-ia64/sn/xpc.h               | 1282 +++++++++++++++++++++++++++++++-
 include/asm-ia64/thread_info.h          |    4 
 24 files changed, 1817 insertions(+), 1508 deletions(-)

Andreas Schwab:
      [IA64] build broken for ia64 simserial.c

Dean Nelson:
      [IA64-SGI] ensure XPC disengage request is processed
      [IA64-SGI] cleanup XPC disengage related messages
      [IA64-SGI] XPC and unregistering from notifier lists
      [IA64-SGI] ignoring loss of heartbeat while XPC is in kdebug
      [IA64-SGI] move xpc_system_reboot()
      [IA64-SGI] move xpc.h to include/asm-ia64/sn
      [IA64-SGI] move xpc.h to include/asm-ia64/sn (cleanup)

Francois Wellenrieter:
      [IA64] Fix conversion of pal_min_state physical address

Jack Steiner:
      [IA64] Hole in IA64 TLB flushing from system threads

Jason Uhlenkott:
      [IA64] Handle debug traps in fsys mode

Keith Owens:
      [IA64] Add hotplug cpu to salinfo.c, replace semaphore with mutex

Prarit Bhargava:
      [IA64-SGI] Fix sn_flush_device_kernel & spinlock initialization

Russ Anderson:
      [IA64-SGI] Altix BTE error handling fixes

Tony Luck:
      [IA64] Add stub entry to fsys.S for sys_migrate_pages

Zhang Yanmin:
      [IA64] prevent accidental modification of args in jprobe handler

