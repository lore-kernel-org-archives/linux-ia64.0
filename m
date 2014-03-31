From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 31 Mar 2014 16:00:08 +0000
Subject: [GIT PULL] Miscellaneous ia64 fixes
Message-Id: <5339910820500464fb@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit cfbf8d4857c26a8a307fb7cd258074c9dcd8c691:

  Linux 3.14-rc4 (2014-02-23 17:40:03 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.15

for you to fetch changes up to 4c332c3238ab41fa9bc18d6ccb8e8aec1c87a426:

  [IA64] Keep format strings from leaking into printk (2014-03-28 15:49:04 -0700)

----------------------------------------------------------------
Miscellaneous ia64 fixes for 3.15 merge window

----------------------------------------------------------------
Jiang Liu (2):
      [IA64] sba_iommu: fix section mismatch     To: linux-kernel@vger.kernel.org
      Fix warning in make defconfig

Kees Cook (1):
      [IA64] Keep format strings from leaking into printk

 arch/ia64/configs/generic_defconfig | 4 ++--
 arch/ia64/hp/common/sba_iommu.c     | 6 +++---
 arch/ia64/kernel/mca.c              | 4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)
