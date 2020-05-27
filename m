From: Nathan Chancellor <natechancellor@gmail.com>
Date: Wed, 27 May 2020 04:34:27 +0000
Subject: [PATCH] media: omap3isp: Shuffle cacheflush.h and include mm.h
Message-Id: <20200527043426.3242439-1-natechancellor@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200515143646.3857579-7-hch@lst.de>
In-Reply-To: <20200515143646.3857579-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: hch@lst.de
Cc: akpm@linux-foundation.org, arnd@arndb.de, jeyu@kernel.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-fsdevel@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, monstr@monstr.eu, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, x86@kernel.org, zippel@linux-m68k.org, Nathan Chancellor <natechancellor@gmail.com>

After mm.h was removed from the asm-generic version of cacheflush.h,
s390 allyesconfig shows several warnings of the following nature:

In file included from ./arch/s390/include/generated/asm/cacheflush.h:1,
                 from drivers/media/platform/omap3isp/isp.c:42:
./include/asm-generic/cacheflush.h:16:42: warning: 'struct mm_struct'
declared inside parameter list will not be visible outside of this
definition or declaration

cacheflush.h does not include mm.h nor does it include any forward
declaration of these structures hence the warning. To avoid this,
include mm.h explicitly in this file and shuffle cacheflush.h below it.

Fixes: 19c0054597a0 ("asm-generic: don't include <linux/mm.h> in cacheflush.h")
Signed-off-by: Nathan Chancellor <natechancellor@gmail.com>
---

I am aware the fixes tag is kind of irrelevant because that SHA will
change in the next linux-next revision and this will probably get folded
into the original patch anyways but still.

The other solution would be to add forward declarations of these structs
to the top of cacheflush.h, I just chose to do what Christoph did in the
original patch. I am happy to do that instead if you all feel that is
better.

 drivers/media/platform/omap3isp/isp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/media/platform/omap3isp/isp.c b/drivers/media/platform/omap3isp/isp.c
index a4ee6b86663e..54106a768e54 100644
--- a/drivers/media/platform/omap3isp/isp.c
+++ b/drivers/media/platform/omap3isp/isp.c
@@ -39,8 +39,6 @@
  *	Troy Laramy <t-laramy@ti.com>
  */
 
-#include <asm/cacheflush.h>
-
 #include <linux/clk.h>
 #include <linux/clkdev.h>
 #include <linux/delay.h>
@@ -49,6 +47,7 @@
 #include <linux/i2c.h>
 #include <linux/interrupt.h>
 #include <linux/mfd/syscon.h>
+#include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/omap-iommu.h>
 #include <linux/platform_device.h>
@@ -58,6 +57,8 @@
 #include <linux/sched.h>
 #include <linux/vmalloc.h>
 
+#include <asm/cacheflush.h>
+
 #ifdef CONFIG_ARM_DMA_USE_IOMMU
 #include <asm/dma-iommu.h>
 #endif
-- 
2.27.0.rc0
