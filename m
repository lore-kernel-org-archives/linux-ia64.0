From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Sep 2006 00:15:47 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200609270015.k8R0FlAh007185@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

first batch of ia64 patches for 2.6.19

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig              |    8 +
 arch/ia64/kernel/Makefile      |    5 
 arch/ia64/kernel/entry.S       |    4 
 arch/ia64/kernel/esi.c         |  205 +++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/esi_stub.S    |   96 ++++++++++++++++
 arch/ia64/kernel/ia64_ksyms.c  |    4 
 arch/ia64/kernel/kprobes.c     |   61 ++++++----
 arch/ia64/kernel/mca.c         |  234 ++++++++++++++++++++++++++++++++++++-----
 arch/ia64/kernel/mca_asm.S     |    9 -
 arch/ia64/kernel/mca_drv.c     |   54 ++++++---
 arch/ia64/kernel/mca_drv.h     |    4 
 arch/ia64/kernel/perfmon.c     |  113 ++++++++-----------
 arch/ia64/kernel/salinfo.c     |    4 
 arch/ia64/kernel/setup.c       |   41 +++++--
 arch/ia64/kernel/smpboot.c     |   24 ++++
 arch/ia64/kernel/vmlinux.lds.S |    8 +
 arch/ia64/mm/contig.c          |   17 +-
 arch/ia64/mm/discontig.c       |   38 +++---
 arch/ia64/sn/kernel/bte.c      |    3 
 include/asm-ia64/esi.h         |   30 +++++
 include/asm-ia64/futex.h       |  122 +++++++++++++++++++++
 include/asm-ia64/kprobes.h     |    9 -
 include/asm-ia64/mca_asm.h     |    2 
 include/asm-ia64/pal.h         |   16 ++
 include/asm-ia64/processor.h   |   13 --
 include/asm-ia64/smp.h         |    1 
 include/asm-ia64/unistd.h      |    3 
 27 files changed, 925 insertions(+), 203 deletions(-)

Al Stone:
      [IA64] minor reformatting to vmlinux.lds.S

bibo mao:
      [IA64] kprobe opcode 16 bytes alignment on IA64

Christoph Lameter:
      [IA64-SGI] Do not request DMA memory for BTE

David Mosberger-Tang:
      [IA64] esi-support

Hidetoshi Seto:
      [IA64] printing support for MCA/INIT
      [IA64] CMC/CPE: Reverse the order of fetching log and checking poll threshold

Jakub Jelinek:
      [IA64] Implement futex primitives

Jes Sorensen:
      [IA64] show_mem() printk levels
      [IA64] trim output of show_mem()

Keshavamurthy Anil S:
      [IA64] kprobes: fixup the pagefault exception caused by probehandlers
      [IA64] Move perfmon tables from thread_struct to pfm_context

Russ Anderson:
      [IA64] ar.fpsr not set on MCA/INIT kernel entry
      [IA64] PAL calls need physical mode, stacked

Stephane Eranian:
      [IA64] Add interface so modules can discover whether multithreading is on.

Tony Luck:
      [IA64] Add "model name" to /proc/cpuinfo
      Revert "[IA64] Unwire set/get_robust_list"

Zou Nan hai:
      [IA64] Make gp value point to Region 5 in mca handler
