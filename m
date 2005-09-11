From: "Luck, Tony" <tony.luck@intel.com>
Date: Sun, 11 Sep 2005 22:43:46 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200509112243.j8BMhkLD016675@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/sim/boot/boot_head.S     |   31 
 arch/ia64/kernel/asm-offsets.c        |   40 -
 arch/ia64/kernel/ivt.S                |    1 
 arch/ia64/kernel/mca.c                |  823 ++++++++++++--------
 arch/ia64/kernel/mca_asm.S            | 1352 +++++++++++++++++-----------------
 arch/ia64/kernel/mca_drv.c            |   37 
 arch/ia64/kernel/minstate.h           |   88 --
 arch/ia64/kernel/palinfo.c            |  123 +--
 arch/ia64/kernel/salinfo.c            |   62 -
 arch/ia64/kernel/unwind.c             |   22 
 arch/ia64/mm/init.c                   |   15 
 arch/ia64/sn/kernel/setup.c           |   30 
 include/asm-ia64/mca.h                |  102 +-
 include/asm-ia64/mca_asm.h            |  131 ---
 include/asm-ia64/ptrace.h             |    2 
 include/asm-ia64/sn/sn_feature_sets.h |   57 +
 include/asm-ia64/sn/sn_sal.h          |   36 
 include/asm-ia64/thread_info.h        |    2 
 include/asm-ia64/unwind.h             |    7 
 include/linux/sched.h                 |    2 
 kernel/sched.c                        |   26 
 21 files changed, 1651 insertions(+), 1338 deletions(-)

Jack Steiner:
  [IA64-SGI] Add new vendor-specific SAL calls for:

Keith Owens:
  MCA/INIT: scheduler hooks
  [IA64] MCA/INIT: add an extra thread_info flag
  [IA64] MCA/INIT: avoid reading INIT record during INIT event
  MCA/INIT: use per cpu stacks
  [IA64] MCA/INIT: remove the physical mode path from minstate.h
  [IA64] MCA/INIT: remove obsolete unwind code

Peter Chubb:
  [IA64] Add PAL_VM_SUMMARY/PAL_MEM_ATTRIB to bootloader for SKI
  [IA64] Allow /proc/pal/cpu0/vm_info under the simulator
  [IA64] Fix nasty VMLPT problem...

