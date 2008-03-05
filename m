From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Mar 2008 00:12:53 +0000
Subject: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843ECBC35AA@orsmsx424.amr.corp.intel.com>
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

 arch/ia64/Kconfig                                  |    2 +
 arch/ia64/Makefile                                 |    2 +
 arch/ia64/{defconfig => configs/generic_defconfig} |    0 
 arch/ia64/ia32/ia32_signal.c                       |   13 ++-
 arch/ia64/kernel/iosapic.c                         |    4 +-
 arch/ia64/kernel/irq_ia64.c                        |  134 +++++++++++++++-----
 arch/ia64/kernel/kprobes.c                         |    5 +
 arch/ia64/kernel/msi_ia64.c                        |    3 +-
 arch/ia64/kernel/sal.c                             |    7 +
 arch/ia64/kernel/signal.c                          |   36 ++++--
 include/asm-ia64/Kbuild                            |    2 +-
 include/asm-ia64/hw_irq.h                          |   12 ++-
 include/asm-ia64/kprobes.h                         |    4 -
 include/asm-ia64/sal.h                             |    4 +
 14 files changed, 180 insertions(+), 48 deletions(-)
 rename arch/ia64/{defconfig => configs/generic_defconfig} (100%)

Adrian Bunk (2):
      [IA64] move defconfig to arch/ia64/configs/
      [IA64] fix ia64 kprobes compilation

Alex Chiang (1):
      [IA64] workaround tiger ia64_sal_get_physical_id_info hang

Doug Chapman (1):
      [IA64] move gcc_intrin.h from header-y to unifdef-y

Jes Sorensen (1):
      [IA64] CONFIG_SGI_SN2 - auto select NUMA and ACPI_NUMA

Kenji Kaneshige (1):
      [IA64] Fix irq migration in multiple vector domain

Shi Weihua (2):
      [IA64] signal(ia64): add a signal stack overflow check
      [IA64] signal(ia64_ia32): add a signal stack overflow check



