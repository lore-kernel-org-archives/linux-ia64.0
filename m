From: edwardsg@sgi.com (Greg Edwards)
Date: Mon, 26 Apr 2004 18:42:50 +0000
Subject: [PATCH] Remove SN PDA page overflow check
Message-Id: <20040426184250.GH5165@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

There's an obsolete check in sn_init_pdas() left over from the 2.4
days that panics if the cpu PDA and cpu_data area span more than a page.
With 2.6, we're not limited to a page, so remove the check entirely.

Patch against linux-2.5 bk.

Regards,
Greg Edwards


=== arch/ia64/sn/kernel/setup.c 1.34 vs edited ==--- 1.34/arch/ia64/sn/kernel/setup.c	Mon Mar 15 08:19:50 2004
+++ edited/arch/ia64/sn/kernel/setup.c	Mon Apr 26 13:20:38 2004
@@ -361,13 +361,6 @@
 {
 	cnodeid_t	cnode;
 
-	/*
-	 * Make sure that the PDA fits entirely in the same page as the 
-	 * cpu_data area.
-	 */
-	if ((((unsigned long)pda & (~PAGE_MASK)) + sizeof(pda_t)) > PAGE_SIZE)
-		panic("overflow of cpu_data page");
-
 	memset(pda->cnodeid_to_nasid_table, -1, sizeof(pda->cnodeid_to_nasid_table));
 	for (cnode=0; cnode<numnodes; cnode++)
 		pda->cnodeid_to_nasid_table[cnode] = pxm_to_nasid(nid_to_pxm_map[cnode]);
