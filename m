From: Fenghua Yu <fenghua.yu@intel.com>
Date: Tue, 11 Aug 2009 23:40:50 +0000
Subject: [git pull] ia64 changes
Message-Id: <20090811234050.GA19468@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/fyu/linux-2.6.git release

This will update the files shown below.

Thanks!

-Fenghua

 arch/ia64/Makefile              |    5 -----
 arch/ia64/include/asm/bitops.h  |    2 +-
 arch/ia64/include/asm/pgtable.h |    1 -
 arch/ia64/kernel/ia64_ksyms.c   |    4 +---
 arch/ia64/kernel/iosapic.c      |    4 ++++
 arch/ia64/kernel/pci-dma.c      |    5 -----
 arch/ia64/kernel/topology.c     |    6 +++++-
 7 files changed, 11 insertions(+), 16 deletions(-)

Fenghua Yu (3):
      Bug Fix arch/ia64/kernel/pci-dma.c: fix recursive dma_supported() call in iommu_dma_supported()
      arch/ia64/Makefile: Remove -mtune=merced in IA64 kernel build
      ia64/topology.c: exit cache_add_dev when kobject_init_and_add fails

Jaswinder Singh Rajput (2):
      IA64: includecheck fix: ia64, ia64_ksyms.c
      IA64: includecheck fix: ia64, pgtable.h

Johannes Weiner (1):
      ia64: boolean __test_and_clear_bit

Roel Kluin (1):
      arch/ia64/kernel/iosapic: missing test after ioremap()

