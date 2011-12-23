From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Fri, 23 Dec 2011 12:27:32 +0000
Subject: [PATCH 13/14] common: DMA-mapping: add WRITE_COMBINE attribute
Message-Id: <1324643253-3024-14-git-send-email-m.szyprowski@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
In-Reply-To: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

DMA_ATTR_WRITE_COMBINE specifies that writes to the mapping may be
buffered to improve performance. It will be used by the replacement for
ARM/ARV32 specific dma_alloc_writecombine() function.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/DMA-attributes.txt |   10 ++++++++++
 include/linux/dma-attrs.h        |    1 +
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/Documentation/DMA-attributes.txt b/Documentation/DMA-attributes.txt
index b768cc0..811a5d4 100644
--- a/Documentation/DMA-attributes.txt
+++ b/Documentation/DMA-attributes.txt
@@ -31,3 +31,13 @@ may be weakly ordered, that is that reads and writes may pass each other.
 Since it is optional for platforms to implement DMA_ATTR_WEAK_ORDERING,
 those that do not will simply ignore the attribute and exhibit default
 behavior.
+
+DMA_ATTR_WRITE_COMBINE
+----------------------
+
+DMA_ATTR_WRITE_COMBINE specifies that writes to the mapping may be
+buffered to improve performance.
+
+Since it is optional for platforms to implement DMA_ATTR_WRITE_COMBINE,
+those that do not will simply ignore the attribute and exhibit default
+behavior.
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index 71ad34e..ada61e1 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -13,6 +13,7 @@
 enum dma_attr {
 	DMA_ATTR_WRITE_BARRIER,
 	DMA_ATTR_WEAK_ORDERING,
+	DMA_ATTR_WRITE_COMBINE,
 	DMA_ATTR_MAX,
 };
 
-- 
1.7.1.569.g6f426

