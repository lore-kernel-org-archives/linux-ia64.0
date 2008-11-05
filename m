From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 05 Nov 2008 00:43:27 +0000
Subject: [git pull] ia64 changes
Message-Id: <200811050043.mA50hRhd009070@agluck-lia64.sc.intel.com>
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

 arch/ia64/Kconfig                 |    1 +
 arch/ia64/hp/common/hwsw_iommu.c  |    9 +------
 arch/ia64/include/asm/io.h        |   24 -------------------
 arch/ia64/include/asm/machvec.h   |   22 +-----------------
 arch/ia64/include/asm/meminit.h   |    1 -
 arch/ia64/include/asm/sal.h       |   15 +++++++++++-
 arch/ia64/include/asm/sn/sn_sal.h |   45 +++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/pci-dma.c        |    2 -
 arch/ia64/mm/discontig.c          |    1 -
 arch/ia64/uv/kernel/setup.c       |    6 +++++
 10 files changed, 68 insertions(+), 58 deletions(-)

FUJITA Tomonori (1):
      [IA64] remove dead BIO_VMERGE_BOUNDARY definition

Huang Weiyi (1):
      [IA64] remove duplicated #include from pci-dma.c

Joerg Roedel (1):
      [IA64] use common header for software IO/TLB

Ken'ichi Ohmichi (1):
      [IA64] fix the difference between node_mem_map and node_start_pfn

Russ Anderson (3):
      [IA64] Simplify SGI uv vs. sn2 driver issues
      [IA64] Add UV watchlist support.
      [IA64] Add error_recovery_info field to SAL section header

Tony Luck (1):
      [IA64] Build VT-D iommu support into generic kernel

