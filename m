From: Christoph Hellwig <hch@lst.de>
Date: Fri, 12 Jan 2018 08:41:59 +0000
Subject: [PATCH 01/34] alpha: mark jensen as broken
Message-Id: <20180112084232.2857-2-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180112084232.2857-1-hch@lst.de>
In-Reply-To: <20180112084232.2857-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, x86@kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-snps-arc@lists.infradead.org, linux-m68k@lists.linux-m68k.org, patches@groups.riscv.org, linux-metag@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-cris-kernel@axis.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

CONFIG_ALPHA_JENSEN has failed to compile since commit 6aca0503
("alpha/dma: use common noop dma ops"), so mark it as broken.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/alpha/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index b31b974a03cb..e96adcbcab41 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -209,6 +209,7 @@ config ALPHA_EIGER
 
 config ALPHA_JENSEN
 	bool "Jensen"
+	depends on BROKEN
 	help
 	  DEC PC 150 AXP (aka Jensen): This is a very old Digital system - one
 	  of the first-generation Alpha systems. A number of these systems
-- 
2.14.2

