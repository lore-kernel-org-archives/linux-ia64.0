From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 22 Mar 2004 22:23:59 +0000
Subject: Re: 2.6.5-rc2 lots of warnings for dma_error
Message-Id: <200403221523.59843.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <5631.1079924674@kao2.melbourne.sgi.com>
In-Reply-To: <5631.1079924674@kao2.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 22 March 2004 2:58 pm, Andrew Morton wrote:
> > Not to prolong the agony, but using the following asm-ia64/dma-mapping.h
> > patch fixes the namespace pollution problem, obviating the need for the
> > ide-cd.c patch:
> 
> OK, updated rollup:

Oops, I meant for my dma-mapping.h patch to be *instead of*
yours.  It's definitely a Monday :-)

OK, 2.5 + your updated rollup + the patch below builds
and boots for me (generic_defconfig):

=== include/asm-ia64/dma-mapping.h 1.4 vs edited ==--- 1.4/include/asm-ia64/dma-mapping.h	Mon Mar 22 15:09:49 2004
+++ edited/include/asm-ia64/dma-mapping.h	Mon Mar 22 15:12:26 2004
@@ -18,7 +18,6 @@
 #define dma_sync_sg_for_cpu	platform_dma_sync_sg_for_cpu
 #define dma_sync_single_for_device platform_dma_sync_single_for_device
 #define dma_sync_sg_for_device	platform_dma_sync_sg_for_device
-#define dma_error		platform_dma_error
 
 /* inline function to avoid namespace pollution */
 static inline int dma_error (dma_addr_t dma_addr)
