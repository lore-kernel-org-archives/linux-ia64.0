From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 06 Jun 2006 16:36:27 +0000
Subject: [PATCH] sanity check reserved region usage
Message-Id: <1149611787.5864.40.camel@lappy>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   One more trivial, stand-alone patch from the Xen/ia64 review.  Sanity
check usage of the reserved region numbers.  Thanks,

	Alex

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
---

diff -r d349717b8dc8 arch/ia64/kernel/setup.c
--- a/arch/ia64/kernel/setup.c	Tue Jun 06 01:00:10 2006 +0000
+++ b/arch/ia64/kernel/setup.c	Tue Jun 06 10:34:18 2006 -0600
@@ -260,6 +260,7 @@ reserve_memory (void)
 	n++;
 
 	num_rsvd_regions = n;
+	BUG_ON(IA64_MAX_RSVD_REGIONS + 1 < n);
 
 	sort_regions(rsvd_region, num_rsvd_regions);
 }


