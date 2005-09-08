From: Jack Steiner <steiner@sgi.com>
Date: Thu, 08 Sep 2005 20:28:28 +0000
Subject: [PATCH] - Increase max physical address for SN platforms
Message-Id: <20050908202828.GA6009@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Increase the value for the maximum physical address on SN systems.


	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-09-08 15:17:08.581816534 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2005-09-08 15:25:26.002687196 -0500
@@ -57,7 +57,7 @@
 
 DEFINE_PER_CPU(struct pda_s, pda_percpu);
 
-#define MAX_PHYS_MEMORY		(1UL << 49)	/* 1 TB */
+#define MAX_PHYS_MEMORY		(1UL << IA64_MAX_PHYS_BITS)	/* Max physical address supported */
 
 lboard_t *root_lboard[MAX_COMPACT_NODES];
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


