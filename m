From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 22 Mar 2004 21:37:58 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <200403221437.58991.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 22 March 2004 1:21 pm, Andrew Morton wrote:
> gack, what a fiasco.
> 
> Here's a new patch which includes everyone's 2000 millicents' worth:

Not to prolong the agony, but using the following asm-ia64/dma-mapping.h
patch fixes the namespace pollution problem, obviating the need for the
ide-cd.c patch:

=== include/asm-ia64/dma-mapping.h 1.3 vs edited ==--- 1.3/include/asm-ia64/dma-mapping.h	Sat Mar 13 23:54:58 2004
+++ edited/include/asm-ia64/dma-mapping.h	Mon Mar 22 14:29:43 2004
@@ -19,6 +19,12 @@
 #define dma_sync_single_for_device platform_dma_sync_single_for_device
 #define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
 
+/* inline function to avoid namespace pollution */
+static inline int dma_error (dma_addr_t dma_addr)
+{
+	return platform_dma_error(dma_addr);
+}
+
 #define dma_map_page(dev, pg, off, size, dir)				\
 	dma_map_single(dev, page_address(pg) + (off), (size), (dir))
 #define dma_unmap_page(dev, dma_addr, size, dir)			\
