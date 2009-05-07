From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 07 May 2009 04:35:43 +0000
Subject: [PATCH -tip 0/5] add generic dma-mappig.h
Message-Id: <1241670948-5818-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@elte.hu, tony.luck@intel.com, linux-ia64@vger.kernel.org

We unified x86 and IA64's handling of multiple dma mapping operations
(struct dma_map_ops in linux/dma-mapping.h) so we can remove
duplication in their arch/include/asm/dma-mapping.h.

This patchset adds include/asm-generic/dma-mapping.h that provides
some generic dma mapping function definitions for the users of struct
dma_map_ops. This enables us to remove about 100 lines. This also
enables us to easily add CONFIG_DMA_API_DEBUG support, which only x86
supports for now. The 4th patch adds CONFIG_DMA_API_DEBUG support to
IA64 by adding only 8 lines.

This is against tip/master since tip has some changes to
arch/x86/include/asm/dma-mapping.h.

 arch/ia64/Kconfig                   |    1 +
 arch/ia64/include/asm/dma-mapping.h |  110 ++------------------
 arch/x86/Kconfig                    |    1 +
 arch/x86/include/asm/dma-mapping.h  |  174 +-------------------------------
 include/asm-generic/dma-mapping.h   |  190 +++++++++++++++++++++++++++++++++++
 lib/dma-debug.c                     |   82 +++++++++------
 6 files changed, 252 insertions(+), 306 deletions(-)


