From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 10 Mar 2007 01:02:33 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200703100102.l2A12XGj004469@agluck-lia64.sc.intel.com>
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

 arch/ia64/configs/tiger_defconfig |  263 ++++++++++++++++++++++-------
 arch/ia64/configs/zx1_defconfig   |  344 +++++++++++++++++++++++++++++---------
 arch/ia64/defconfig               |  321 ++++++++++++++++++++++++++---------
 arch/ia64/kernel/crash.c          |   10 -
 arch/ia64/kernel/efi.c            |    2 
 arch/ia64/kernel/mca.c            |    8 
 arch/ia64/kernel/mca_drv.c        |   65 ++++---
 arch/ia64/kernel/ptrace.c         |    1 
 include/asm-ia64/kexec.h          |    1 
 include/asm-ia64/mca.h            |    2 
 include/asm-ia64/pal.h            |    1 
 include/asm-ia64/pci.h            |    3 
 include/asm-ia64/sal.h            |    5 
 include/asm-ia64/unwind.h         |    2 
 14 files changed, 783 insertions(+), 245 deletions(-)

Akiyama, Nobuyuki (1):
      [IA64] add missing syscall trace clear

Horms (2):
      [IA64] whitespace fixes for include/asm-ia64/sal.h
      [IA64] put kdump_find_rsvd_region in __init

Keith Owens (1):
      [IA64] Remove sparse warning from unwind code

Russ Anderson (2):
      [IA64] Proper handling of TLB errors from duplicate itr.d dropins
      [IA64] Cache error recovery

Simon Horman (2):
      [IA64] kexec: declare ia64_mca_pal_base in mca.h rather than kexec.h
      [IA64] Cleanup in crash.c

Tony Luck (1):
      [IA64] refresh config files

Zhang, Yanmin (1):
      [IA64] pci_get_legacy_ide_irq should return irq (not GSI)
