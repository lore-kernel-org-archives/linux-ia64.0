From: Russ Anderson <rja@sgi.com>
Date: Tue, 01 Mar 2005 21:31:42 +0000
Subject: [patch] Remove unused cpu_bte_if from pda_s
Message-Id: <200503012131.j21LVgUn8252665@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove unused cpu_bte_if from pda_s.

Signed-off-by: Russ Anderson <rja@sgi.com>

------------------------------------------------------------------
Index: linux/include/asm-ia64/sn/pda.h
=================================--- linux.orig/include/asm-ia64/sn/pda.h	2005-03-01 13:06:42.311437897 -0600
+++ linux/include/asm-ia64/sn/pda.h	2005-03-01 15:14:27.337653828 -0600
@@ -53,8 +53,6 @@
 	unsigned long pio_write_status_val;
 	volatile unsigned long *pio_shub_war_cam_addr;
 
-	struct bteinfo_s *cpu_bte_if[BTES_PER_NODE];	/* cpu interface order */
-
 	unsigned long	sn_soft_irr[4];
 	unsigned long	sn_in_service_ivecs[4];
 	short		cnodeid_to_nasid_table[MAX_NUMNODES];
------------------------------------------------------------------
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
