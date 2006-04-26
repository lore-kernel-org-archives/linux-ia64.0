From: Mike Habeck <habeck@sgi.com>
Date: Wed, 26 Apr 2006 17:05:50 +0000
Subject: [PATCH] fix SGI Altix tioce_reserve_m32() bug
Message-Id: <20060426170550.10184.26271.95617@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The following patch fixes a bug in the SGI Altix tioce_reserve_m32()
code.  The bug was that we could walking past the end of the CE ASIC
32/40bit PMU ATE Buffer, resulting in a PIO Reply Error.

This patch is based off the aegl/linux-2.6.git tree

Signed-off-by: Mike Habeck <habeck@sgi.com>


Index: ce_dev/arch/ia64/sn/pci/tioce_provider.c
=================================--- ce_dev.orig/arch/ia64/sn/pci/tioce_provider.c	2006-04-25 16:30:54.000000000 -0500
+++ ce_dev/arch/ia64/sn/pci/tioce_provider.c	2006-04-25 16:59:39.305931828 -0500
@@ -682,9 +682,6 @@
 	int ate_index, last_ate, ps;
 	struct tioce *ce_mmr;
 
-	if (!TIOCE_M32_ADDR(base))
-		return;
-
 	ce_mmr = (struct tioce *)ce_kern->ce_common->ce_pcibus.bs_base;
 	ps = ce_kern->ce_ate3240_pagesize;
 	ate_index = ATE_PAGE(base, ps);
@@ -692,6 +689,9 @@
 
 	if (ate_index < 64)
 		ate_index = 64;
+
+	if (last_ate >= TIOCE_NUM_M3240_ATES)
+		last_ate = TIOCE_NUM_M3240_ATES - 1;
 
 	while (ate_index <= last_ate) {
 		u64 ate;
