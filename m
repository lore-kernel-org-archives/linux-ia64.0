From: Keith Owens <kaos@sgi.com>
Date: Mon, 22 Mar 2004 03:04:34 +0000
Subject: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <5631.1079924674@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.6.5-rc2 generic build, lots of warnings for dma_error.  Latest patch from
http://www.kernel.org/pub/linux/kernel/ports/ia64/v2.6/testing/cset/cset-1.1661.1.156-to-1.1668.txt.gz
makes no difference.

In file included from include/asm/pci.h:58,
                 from include/linux/pci.h:720,
                 from fs/compat_ioctl.c:58,
                 from arch/ia64/ia32/ia32_ioctl.c:15:
include/asm-generic/pci-dma-compat.h: In function `pci_dma_error':
include/asm-generic/pci-dma-compat.h:104: warning: implicit declaration of function `dma_error'

# grep DMA /build/kaos/2.6.5-rc2-kdb-v4.3-ia64/.config
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
CONFIG_IDEDMA_PCI_AUTO=y
# CONFIG_IDEDMA_ONLYDISK is not set
CONFIG_BLK_DEV_ADMA=y
CONFIG_HPT34X_AUTODMA=y
CONFIG_BLK_DEV_IDEDMA=y
# CONFIG_IDEDMA_IVB is not set
CONFIG_IDEDMA_AUTO=y
# CONFIG_DMA_NONPCI is not set

