From: Simon Horman <horms@verge.net.au>
Date: Tue, 05 Aug 2008 09:57:41 +0000
Subject: [patch] IA64: make rsvd_region and num_rsvd_regions static
Message-Id: <20080805095739.GA12078@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>

rsvd_region and num_rsvd_regions are only accessed in
arch/ia64/kernel/setup.c, so they should be static.

Signed-off-by: Simon Horman <horms@verge.net.au>


Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2008-08-02 17:38:02.000000000 +1000
+++ linux-2.6/arch/ia64/kernel/setup.c	2008-08-02 17:38:20.000000000 +1000
@@ -132,8 +132,8 @@ EXPORT_SYMBOL(ia64_max_iommu_merge_mask)
 /*
  * We use a special marker for the end of memory and it uses the extra (+1) slot
  */
-struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1] __initdata;
-int num_rsvd_regions __initdata;
+static struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1] __initdata;
+static int num_rsvd_regions __initdata;
 
 
 /*
