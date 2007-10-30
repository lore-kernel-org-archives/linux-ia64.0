From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 30 Oct 2007 18:46:44 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A02D20B29@scsmsx411.amr.corp.intel.com>
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

 arch/ia64/configs/sn2_defconfig    |  106 ++++++++++++++++++-------------------
 arch/ia64/kernel/efi.c             |    2 
 arch/ia64/kernel/gate.lds.S        |    3 +
 arch/ia64/kernel/msi_ia64.c        |    2 
 arch/ia64/kernel/setup.c           |   49 ++---------------
 arch/ia64/kernel/smpboot.c         |   21 ++++---
 arch/ia64/mm/init.c                |    4 -
 arch/ia64/scripts/check-segrel.lds |    1 
 arch/ia64/sn/kernel/mca.c          |    1 
 include/asm-ia64/percpu.h          |    2 
 include/asm-ia64/smp.h             |    1 
 11 files changed, 86 insertions(+), 106 deletions(-)

Adrian Bunk (1):
      [IA64] ia64/mm/init.c: fix section mismatches

Alex Chiang (1):
      [IA64] /proc/cpuinfo "physical id" field cleanups

Jes Sorensen (1):
      [IA64] update sn2 defconfig to 64kb pages

Kenji Kaneshige (1):
      [IA64] Fix incorrect return value from ia64_setup_msi_irq()

Roel Kluin (1):
      [IA64] arch/ia64/sn/kernel/mca.c: undo lock when sn_oemdata can't be extended

Roland McGrath (2):
      [IA64] check-segrel.lds vs --build-id
      [IA64] vDSO vs --build-id

Simon Horman (1):
      [IA64] vmcore_find_descriptor_size should be in __init

Yu Luming (1):
      [IA64] fix typo in per_cpu_offset
