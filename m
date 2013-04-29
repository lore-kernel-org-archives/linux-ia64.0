From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 29 Apr 2013 16:06:01 +0000
Subject: [GIT PULL] ia64 fixes for 3.10 merge window
Message-Id: <517e9a69143367f48f@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit a937536b868b8369b98967929045f1df54234323:

  Linux 3.9-rc3 (2013-03-17 15:59:32 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.10

for you to fetch changes up to 797f6a684f28dbb00f9e9719315574e344fcbf53:

  Add size restriction to the kdump documentation (2013-04-02 09:40:03 -0700)

----------------------------------------------------------------
Bundle of miscellaneous ia64 fixes for 3.10 merge window.

----------------------------------------------------------------
Eric W. Biederman (1):
      Fix broken fsys_getppid()

Hanjun Guo (2):
      iosapic: fix a minor typo in comments
      Fix kexec oops when iosapic was removed

Jiri Kosina (1):
      tiocx: check retval from bus_register()

Li, Zhen-Hua (1):
      Add WB/UC check for early_ioremap

Paul Bolle (1):
      Change "select DMAR" to "select INTEL_IOMMU"

Stephan Schreiber (2):
      Wrong asm register contraints in the futex implementation
      Wrong asm register contraints in the kvm implementation

Tony Luck (1):
      Fix initialization of CMCI/CMCP interrupts

Xie XiuQi (1):
      Fix example error_injection_tool

Xishi Qiu (1):
      Add size restriction to the kdump documentation

Yijing Wang (1):
      Fix build error for numa_clear_node() under IA64

Zhang Yanfei (1):
      Remove cast for kmalloc return value

 Documentation/ia64/err_inject.txt |  2 +-
 Documentation/kdump/kdump.txt     |  1 +
 arch/ia64/Kconfig                 |  2 +-
 arch/ia64/include/asm/futex.h     |  5 ++--
 arch/ia64/include/asm/mca.h       |  1 +
 arch/ia64/include/asm/numa.h      |  5 ++--
 arch/ia64/kernel/fsys.S           | 49 +--------------------------------------
 arch/ia64/kernel/iosapic.c        | 34 +++++++++++++++++++++++++--
 arch/ia64/kernel/irq.c            |  8 +++++++
 arch/ia64/kernel/mca.c            | 37 ++++++++++++++++++-----------
 arch/ia64/kernel/mca_drv.c        |  2 +-
 arch/ia64/kvm/vtlb.c              |  2 +-
 arch/ia64/mm/ioremap.c            | 14 +++++++----
 arch/ia64/mm/numa.c               |  5 ++++
 arch/ia64/sn/kernel/tiocx.c       |  5 +++-
 15 files changed, 93 insertions(+), 79 deletions(-)
