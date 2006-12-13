From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 13 Dec 2006 02:04:00 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200612130204.kBD240VH010983@agluck-lia64.sc.intel.com>
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

 arch/ia64/hp/sim/simserial.c      |    2 
 arch/ia64/kernel/Makefile         |    1 
 arch/ia64/kernel/crash.c          |   22 ---
 arch/ia64/kernel/crash_dump.c     |   48 ++++++++
 arch/ia64/kernel/jprobes.S        |    3 
 arch/ia64/kernel/kprobes.c        |  226 ++++++++++++++++++++++++++------------
 arch/ia64/kernel/machine_kexec.c  |    7 -
 arch/ia64/kernel/mca.c            |    2 
 arch/ia64/kernel/setup.c          |   33 ++++-
 arch/ia64/kernel/smp.c            |    4 
 arch/ia64/kernel/traps.c          |   50 ++++++--
 arch/ia64/mm/contig.c             |    9 +
 arch/ia64/mm/init.c               |    9 -
 arch/ia64/sn/kernel/setup.c       |   12 +-
 arch/ia64/sn/kernel/xpc_channel.c |   15 +-
 arch/ia64/sn/kernel/xpc_main.c    |   64 +++++++---
 include/asm-ia64/break.h          |    4 
 include/asm-ia64/kprobes.h        |    1 
 include/asm-ia64/sn/xpc.h         |    2 
 19 files changed, 362 insertions(+), 152 deletions(-)

bibo,mao:
      [IA64] kprobe clears qp bits for special instructions

Dean Nelson:
      [IA64] fix possible XPC deadlock when disconnecting

Horms:
      [IA64] CONFIG_KEXEC/CONFIG_CRASH_DUMP permutations
      [IA64] Kexec/Kdump: honour non-zero crashkernel offset.
      [IA64] kexec/kdump: tidy up declaration of relocate_new_kernel_t

Jack Steiner:
      [IA64] - Reduce overhead of FP exception logging messages

Jay Lan:
      [IA64] Do not call SN_SAL_SET_CPU_NUMBER twice on cpu 0

Tony Luck:
      [IA64] s/termios/ktermios/ in simserial.c
      [IA64] fix arch/ia64/mm/contig.c:235: warning: unused variable `nid'
      [IA64] Take defensive stance on ia64_pal_get_brand_info()
      [IA64] enable trap code on slot 1
