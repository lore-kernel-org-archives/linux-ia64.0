From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 22 Sep 2006 23:30:20 +0000
Subject: IA64 without ZONE_DMA?
Message-Id: <Pine.LNX.4.64.0609221622170.10232@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There is code in Andrews tree that allows getting rid of ZONE_DMA. I know 
that SGI machines do not use ZONE_DMA. I looked through the arch code and 
I do not see ZONE_DMA or GFP_DMA uses that I cannot account for. However, 
I am not familiar with the code for other IA64 platforms.

This patch will make IA64 have a single zone in each node. As a result
loops are unrolled, various VM macros can be optimized further and the 
memory load balancing code between different zones in one node is no 
longer necessary. Note that having no ZONE_DMA means that GFP_DMA will be 
ignored. If you know of any devices depending on ZONE_DMA (memory returned 
must be below 4GB) then we first need to deal with those possibly by 
modifying dma_alloc_coherent functions to obtain memory in a different 
way than via GFP_DMA.

We are currently working on a new page allocator function

alloc_pages_range()

that will allow the specification of a memory range for devides that have 
other needs. This will allow an allocation for arbitrary address ranges 
without ZONE_DMA.

Would it be possible to check how other platforms work without ZONE_DMA?
I can help to fix things up using alloc_pages_range() if necessary?

Index: linux-2.6.18-rc7-mm1/arch/ia64/Kconfig
=================================--- linux-2.6.18-rc7-mm1.orig/arch/ia64/Kconfig	2006-09-19 09:26:09.000000000 -0500
+++ linux-2.6.18-rc7-mm1/arch/ia64/Kconfig	2006-09-22 18:17:29.150336964 -0500
@@ -22,10 +22,6 @@ config 64BIT
 	bool
 	default y
 
-config ZONE_DMA
-	def_bool y
-	depends on !IA64_SGI_SN2
-
 config MMU
 	bool
 	default y
