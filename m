From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 15 Dec 2009 22:33:04 +0000
Subject: [git pull] ia64 changes
Message-Id: <4b280ea0198591ace0@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
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

 arch/ia64/hp/common/sba_iommu.c |   38 +++++++++++++++++++++++++++++---------
 arch/ia64/include/asm/hw_irq.h  |    6 ++++++
 arch/ia64/include/asm/io.h      |    2 ++
 arch/ia64/include/asm/mca.h     |    5 +++++
 arch/ia64/include/asm/rwsem.h   |    2 +-
 arch/ia64/kernel/irq_ia64.c     |    6 +-----
 arch/ia64/kernel/mca.c          |   11 ++++++++---
 arch/ia64/mm/ioremap.c          |   11 +++++++++++
 8 files changed, 63 insertions(+), 18 deletions(-)

FUJITA Tomonori (1):
      [IA64] fix SBA IOMMU to handle allocation failure properly

Kenji Kaneshige (1):
      [IA64] preallocate IA64_IRQ_MOVE_VECTOR

Takao Indoh (1):
      [IA64] Save I-resources to ia64_sal_os_state

Thomas Gleixner (1):
      [IA64] Replace old style lock initializer

Tony Luck (1):
      [IA64] implement early_io{re,un}map for ia64

