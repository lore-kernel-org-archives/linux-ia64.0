From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 07 Mar 2008 00:19:44 +0000
Subject: git pull on ia64 linux tree
Message-Id: <1FE6DD409037234FAB833C420AA843ECC0CD84@orsmsx424.amr.corp.intel.com>
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

 arch/ia64/hp/common/hwsw_iommu.c        |    2 +-
 arch/ia64/hp/common/sba_iommu.c         |   36 ++--
 arch/ia64/hp/sim/simeth.c               |    2 +-
 arch/ia64/hp/sim/simserial.c            |    2 +-
 arch/ia64/ia32/sys_ia32.c               |    7 +-
 arch/ia64/kernel/crash.c                |    2 +-
 arch/ia64/kernel/efi.c                  |   32 +++-
 arch/ia64/kernel/iosapic.c              |   24 ++--
 arch/ia64/kernel/irq_ia64.c             |    8 +-
 arch/ia64/kernel/kprobes.c              |    2 +-
 arch/ia64/kernel/mca.c                  |   73 ++++----
 arch/ia64/kernel/module.c               |   22 +-
 arch/ia64/kernel/perfmon.c              |    4 +-
 arch/ia64/kernel/perfmon_default_smpl.c |    4 +-
 arch/ia64/kernel/ptrace.c               |  327 +++++++------------------------
 arch/ia64/kernel/setup.c                |    8 +-
 arch/ia64/kernel/unaligned.c            |    6 +-
 arch/ia64/kernel/unwind.c               |  102 +++++-----
 arch/ia64/mm/fault.c                    |    2 +-
 arch/ia64/mm/init.c                     |    2 +-
 arch/ia64/pci/fixup.c                   |    2 +-
 arch/ia64/pci/pci.c                     |    4 +-
 arch/ia64/sn/kernel/huberror.c          |    4 +-
 arch/ia64/sn/kernel/io_acpi_init.c      |   36 ++--
 arch/ia64/sn/kernel/io_common.c         |    2 +-
 arch/ia64/sn/kernel/io_init.c           |    4 +-
 arch/ia64/sn/kernel/mca.c               |    2 +-
 arch/ia64/sn/pci/pci_dma.c              |    6 +-
 arch/ia64/sn/pci/tioca_provider.c       |   12 +-
 arch/ia64/sn/pci/tioce_provider.c       |    4 +-
 include/asm-ia64/kprobes.h              |    2 +-
 include/asm-ia64/ptrace.h               |    9 +-
 32 files changed, 289 insertions(+), 465 deletions(-)

Bjorn Helgaas (2):
      [IA64] remove CONFIG_SMP ifdef in ia64_send_ipi()
      [IA64] use dev_printk in video quirk

Harvey Harrison (2):
      [IA64] remove remaining __FUNCTION__ occurrences
      [IA64] kprobes arch consolidation build fix

KOSAKI Motohiro (1):
      [IA64] remove unnecessary nfs includes from sys_ia32.c

Petr Tesarik (6):
      [IA64] access user RBS directly
      [IA64] do not sync RBS when changing PT_AR_BSP or PT_CFM
      [IA64] remove find_thread_for_addr()
      [IA64] convert sys_ptrace to arch_ptrace
      [IA64] remove duplicate code from arch_ptrace()
      [IA64] arch_ptrace() cleanup

Simon Horman (1):
      [IA64] update efi region debugging to use MB, GB and TB as well as KB



