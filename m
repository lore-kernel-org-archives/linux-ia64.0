From: Shuah Khan <shuah.khan@hp.com>
Date: Fri, 23 Nov 2012 21:29:02 +0000
Subject: [PATCH 0/9] dma_debug: add debug_dma_mapping_error support to architectures that support DMA_DEBUG_A
Message-Id: <1353706142.5270.93.camel@lorien2>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

An earlier patch added dma mapping error debug feature to dma_debug
infrastructure. References:

https://lkml.org/lkml/2012/10/8/296
https://lkml.org/lkml/2012/11/3/219

The following series of patches adds the call to debug_dma_mapping_error() to
architecture specific dma_mapping_error() interfaces on the following
architectures that support CONFIG_DMA_API_DEBUG.

arm64
c6x
ia64
microblaze
mips
powerpc
sh
sparc
tile

arm - Change is already in Marek's dma-mapping tree[1] 
https://patchwork.kernel.org/patch/1625601/

microblaze - Change is already in linux-next. Including it for completeness
linux-next commit f229605441030bcd315c21d97b25889d63ed0130

x86 - done in the first patch that added the feature.

ARM64: dma_debug: add debug_dma_mapping_error support
c6x: dma_debug: add debug_dma_mapping_error support
ia64: dma_debug: add debug_dma_mapping_error support
microblaze: dma-mapping: support debug_dma_mapping_error
mips: dma_debug: add debug_dma_mapping_error support
powerpc: dma_debug: add debug_dma_mapping_error support
sh: dma_debug: add debug_dma_mapping_error support
sparc: dma_debug: add debug_dma_mapping_error support
tile: dma_debug: add debug_dma_mapping_error support

Thanks,
-- Shuah

