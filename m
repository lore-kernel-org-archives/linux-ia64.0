From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 31 Oct 2005 19:31:35 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200510311931.j9VJVZvi009137@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git swiotlb

This is John Linville's patch series that moves swiotlb.c from
arch/ia64/lib/swiotlb.c to lib/swiotlb.c.

Thanks!

-Tony

 arch/ia64/lib/swiotlb.c          |  759 -------------------------------
 arch/ia64/Kconfig                |    4 
 arch/ia64/lib/Makefile           |    2 
 arch/x86_64/kernel/Makefile      |    2 
 include/asm-x86_64/dma-mapping.h |   31 +
 include/asm-x86_64/swiotlb.h     |    8 
 lib/Makefile                     |    2 
 lib/swiotlb.c                    |  933 ++++++++++++++++++++++++++++++++++++---
 8 files changed, 914 insertions(+), 827 deletions(-)

John W. Linville:
      swiotlb: move from arch/ia64/lib/ to lib/
      swiotlb: cleanup some code duplication cruft
      swiotlb: support syncing sub-ranges of mappings
      swiotlb: support syncing DMA_BIDIRECTIONAL mappings
      swiotlb: file header comments
      x86_64: implement dma_sync_single_range_for_{cpu,device}

Tony Luck:
      Removed remaining PCI specific references from swiotlb.c

