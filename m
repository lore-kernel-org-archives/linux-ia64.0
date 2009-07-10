From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 10 Jul 2009 01:04:49 +0000
Subject: [00/15] swiotlb cleanup
Message-Id: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, fujita.tomonori@lab.ntt.co.jp, beckyb@kernel.crashing.org

- removes unused (and unnecessary) hooks in swiotlb.

- adds dma_capable() and converts swiotlb to use it. It can be used to
know if a memory area is dma capable or not. I added
is_buffer_dma_capable() for the same purpose long ago but it turned
out that the function doesn't work on POWERPC.

This can be applied cleanly to linux-next, -mm, and mainline. This
patchset touches multiple architectures (ia64, powerpc, x86) so I
guess that -mm is appropriate for this patchset (I don't care much
what tree would merge this though).

This is tested on x86 but only compile tested on POWERPC and IA64.

Thanks,

 arch/ia64/include/asm/dma-mapping.h    |   18 ++++++
 arch/powerpc/include/asm/dma-mapping.h |   23 +++++++
 arch/powerpc/kernel/dma-swiotlb.c      |   48 +---------------
 arch/x86/include/asm/dma-mapping.h     |   18 ++++++
 arch/x86/kernel/pci-dma.c              |    2 +-
 arch/x86/kernel/pci-gart_64.c          |    5 +-
 arch/x86/kernel/pci-nommu.c            |    2 +-
 arch/x86/kernel/pci-swiotlb.c          |   25 --------
 include/linux/dma-mapping.h            |    5 --
 include/linux/swiotlb.h                |   11 ----
 lib/swiotlb.c                          |  102 +++++++++-----------------------
 11 files changed, 92 insertions(+), 167 deletions(-)



