From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Jul 2013 16:47:14 +0000
Subject: [GIT PULL] IOH hotplug in ia64 for 3.11 merge window
Message-Id: <51d1b29216985ae61@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 7d132055814ef17a6c7b69f342244c410a5e000f:

  Linux 3.10-rc6 (2013-06-15 11:51:07 -1000)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-root_bus_hotplug

for you to fetch changes up to c4cbf6b96100bbcd5da6e38b3334901b2eaa25bf:

  PCI: Replace printks with appropriate pr_*() (2013-06-18 09:49:23 -0700)

----------------------------------------------------------------
Series to fix IOH hotplug in ia64

----------------------------------------------------------------
Jiang Liu (1):
      PCI/IA64: fix memleak for create pci root bus fail

Yijing Wang (7):
      PCI/IA64: SN: remove sn_pci_window_fixup()
      PCI/IA64: SN: use normal resource instead of pci_window
      PCI/IA64: embed pci hostbridge resources into pci_root_info
      PCI/IA64: Allocate pci_root_info instead of using stack
      PCI/IA64: Add host bridge resource release for _CRS path
      PCI/IA64: introduce probe_pci_root_info() to manage _CRS resource
      PCI: Replace printks with appropriate pr_*()

 arch/ia64/include/asm/pci.h   |  10 +-
 arch/ia64/pci/pci.c           | 239 +++++++++++++++++++++++++++++-------------
 arch/ia64/sn/kernel/io_init.c | 109 +++++--------------
 3 files changed, 195 insertions(+), 163 deletions(-)
