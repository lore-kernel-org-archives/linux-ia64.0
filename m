From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 15 May 2009 03:55:00 +0000
Subject: [PATCH -tip v2 0/5] add common functions for struct dma_map_ops
Message-Id: <1242359705-2117-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: mingo@elte.hu, tony.luck@intel.com, linux-ia64@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp, arnd@arndb.de, joerg.roedel@amd.com

We unified x86 and IA64's handling of multiple dma mapping operations
(struct dma_map_ops in linux/dma-mapping.h) so we can remove
duplication in their arch/include/asm/dma-mapping.h.

This patchset adds include/asm-generic/dma-mapping-common.h that
provides some generic dma mapping function definitions for the users
of struct dma_map_ops. This enables us to remove about 100 lines. This
also enables us to easily add CONFIG_DMA_API_DEBUG support, which only
x86 supports for now. The 4th patch adds CONFIG_DMA_API_DEBUG support
to IA64 by adding only 8 lines.

This is against tip/master since tip has some changes to
arch/x86/include/asm/dma-mapping.h.

The changes since the first version are

- fixed a bug that dma_attrs is not passed properly (thanks to Arnd
Bergmann).

- used a new name, dma-mapping-common.h, instead of dma-mapping.h
(suggested by Arnd Bergmann).

- added Joerg's Acked-by

 arch/ia64/Kconfig                        |    1 +
 arch/ia64/include/asm/dma-mapping.h      |  110 ++----------------
 arch/x86/Kconfig                         |    1 +
 arch/x86/include/asm/dma-mapping.h       |  174 +---------------------------
 include/asm-generic/dma-mapping-common.h |  190 ++++++++++++++++++++++++++++++
 lib/dma-debug.c                          |   82 ++++++++------
 6 files changed, 252 insertions(+), 306 deletions(-)



