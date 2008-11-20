From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 20 Nov 2008 22:47:08 +0000
Subject: [git pull] ia64 changes
Message-Id: <200811202247.mAKMl8qT029408@agluck-lia64.sc.intel.com>
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

 arch/ia64/include/asm/intrinsics.h      |    2 +-
 arch/ia64/include/asm/paravirt_privop.h |   13 +++++++++++++
 arch/ia64/kernel/entry.S                |    1 +
 arch/ia64/kernel/head.S                 |    2 +-
 arch/ia64/kernel/mca.c                  |    2 +-
 arch/ia64/kernel/paravirt.c             |    2 +-
 arch/ia64/kernel/pci-dma.c              |    1 -
 arch/ia64/xen/hypercall.S               |    2 +-
 8 files changed, 19 insertions(+), 6 deletions(-)

Hidetoshi Seto (1):
      [IA64] use mprintk instead of printk, in ia64_mca_modify_original_stack

Huang Weiyi (1):
      [IA64] remove duplicate include iommu.h

Isaku Yamahata (2):
      [IA64] ia64/pv_ops/pv_cpu_ops: fix _IA64_REG_IP case.
      [IA64] xen: fix xen_get_eflags.

Tony Luck (1):
      [IA64] Rationalize kernel mode alignment checking

