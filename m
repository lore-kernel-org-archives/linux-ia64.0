From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 10 Jul 2009 01:04:57 +0000
Subject: [PATCH 08/15] powerpc: add dma_capable() to replace is_buffer_dma_capable()
Message-Id: <1247187904-31999-9-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1247187904-31999-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org, benh@kernel.crashing.org, tony.luck@intel.com, x86@kernel.org, fujita.tomonori@lab.ntt.co.jp, beckyb@kernel.crashing.org

dma_capable() eventually replaces is_buffer_dma_capable(), which tells
if a memory area is dma-capable or not. The problem of
is_buffer_dma_capable() is that it doesn't take a pointer to struct
device so it doesn't work for POWERPC.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/powerpc/include/asm/dma-mapping.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/arch/powerpc/include/asm/dma-mapping.h b/arch/powerpc/include/asm/dma-mapping.h
index b44aaab..6ff1f85 100644
--- a/arch/powerpc/include/asm/dma-mapping.h
+++ b/arch/powerpc/include/asm/dma-mapping.h
@@ -424,6 +424,19 @@ static inline int dma_mapping_error(struct device *dev, dma_addr_t dma_addr)
 #endif
 }
 
+static inline bool dma_capable(struct device *dev, dma_addr_t addr, size_t size)
+{
+	struct dma_mapping_ops *ops = get_dma_ops(dev);
+
+	if (ops->addr_needs_map && ops->addr_needs_map(dev, addr, size))
+		return 0;
+
+	if (!dev->dma_mask)
+		return 0;
+
+	return addr + size <= *dev->dma_mask;
+}
+
 #define dma_alloc_noncoherent(d, s, h, f) dma_alloc_coherent(d, s, h, f)
 #define dma_free_noncoherent(d, s, v, h) dma_free_coherent(d, s, v, h)
 #ifdef CONFIG_NOT_COHERENT_CACHE
-- 
1.6.0.6

