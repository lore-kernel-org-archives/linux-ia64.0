From: Jack Steiner <steiner@sgi.com>
Date: Thu, 11 Aug 2005 17:27:14 +0000
Subject: [PATCH 5/7] - New SN hardware support - bte_fixes
Message-Id: <20050811172714.GA18526@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Change the BTE driver so that it works for both shub1 and
shub2. Most of the changes are related to the number of cores
that use the BTE engine, to the MMR addresses of various
shub registers, and to using the correct processor or network
physical address.


	Signed-off-by: Russ Anderson <rja@sgi.com>
	Signed-off-by: Jack Steiner <steiner@sgi.com>


 bte.c |   82 +++++++++++++++++++++++++++++++++++++++++-------------------------




Index: linux/arch/ia64/sn/kernel/bte.c
=================================--- linux.orig/arch/ia64/sn/kernel/bte.c	2005-08-09 16:01:51.322579975 -0500
+++ linux/arch/ia64/sn/kernel/bte.c	2005-08-10 15:06:59.540714442 -0500
@@ -29,16 +29,30 @@
 
 /* two interfaces on two btes */
 #define MAX_INTERFACES_TO_TRY		4
+#define MAX_NODES_TO_TRY		2
 
 static struct bteinfo_s *bte_if_on_node(nasid_t nasid, int interface)
 {
 	nodepda_t *tmp_nodepda;
 
+	if (nasid_to_cnodeid(nasid) = -1)
+		return (struct bteinfo_s *)NULL;;
+
 	tmp_nodepda = NODEPDA(nasid_to_cnodeid(nasid));
 	return &tmp_nodepda->bte_if[interface];
 
 }
 
+static inline void bte_start_transfer(struct bteinfo_s *bte, u64 len, u64 mode)
+{
+	if (is_shub2()) {
+		BTE_CTRL_STORE(bte, (IBLS_BUSY | ((len) | (mode) << 24)));
+	} else {
+		BTE_LNSTAT_STORE(bte, len);
+		BTE_CTRL_STORE(bte, mode);
+	}
+}
+
 /************************************************************************
  * Block Transfer Engine copy related functions.
  *
@@ -67,13 +81,15 @@ bte_result_t bte_copy(u64 src, u64 dest,
 {
 	u64 transfer_size;
 	u64 transfer_stat;
+	u64 notif_phys_addr;
 	struct bteinfo_s *bte;
 	bte_result_t bte_status;
 	unsigned long irq_flags;
 	unsigned long itc_end = 0;
-	struct bteinfo_s *btes_to_try[MAX_INTERFACES_TO_TRY];
-	int bte_if_index;
-	int bte_pri, bte_sec;
+	int nasid_to_try[MAX_NODES_TO_TRY];
+	int my_nasid = get_nasid();
+	int bte_if_index, nasid_index;
+	int bte_first, btes_per_node = BTES_PER_NODE;
 
 	BTE_PRINTK(("bte_copy(0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%p)\n",
 		    src, dest, len, mode, notification));
@@ -86,36 +102,26 @@ bte_result_t bte_copy(u64 src, u64 dest,
 		 (src & L1_CACHE_MASK) || (dest & L1_CACHE_MASK));
 	BUG_ON(!(len < ((BTE_LEN_MASK + 1) << L1_CACHE_SHIFT)));
 
-	/* CPU 0 (per node) tries bte0 first, CPU 1 try bte1 first */
-	if (cpuid_to_subnode(smp_processor_id()) = 0) {
-		bte_pri = 0;
-		bte_sec = 1;
-	} else {
-		bte_pri = 1;
-		bte_sec = 0;
-	}
+	/*
+	 * Start with interface corresponding to cpu number
+	 */
+	bte_first = get_cpu() % btes_per_node;
 
 	if (mode & BTE_USE_DEST) {
 		/* try remote then local */
-		btes_to_try[0] = bte_if_on_node(NASID_GET(dest), bte_pri);
-		btes_to_try[1] = bte_if_on_node(NASID_GET(dest), bte_sec);
+		nasid_to_try[0] = NASID_GET(dest);
 		if (mode & BTE_USE_ANY) {
-			btes_to_try[2] = bte_if_on_node(get_nasid(), bte_pri);
-			btes_to_try[3] = bte_if_on_node(get_nasid(), bte_sec);
+			nasid_to_try[1] = my_nasid;
 		} else {
-			btes_to_try[2] = NULL;
-			btes_to_try[3] = NULL;
+			nasid_to_try[1] = (int)NULL;
 		}
 	} else {
 		/* try local then remote */
-		btes_to_try[0] = bte_if_on_node(get_nasid(), bte_pri);
-		btes_to_try[1] = bte_if_on_node(get_nasid(), bte_sec);
+		nasid_to_try[0] = my_nasid;
 		if (mode & BTE_USE_ANY) {
-			btes_to_try[2] = bte_if_on_node(NASID_GET(dest), bte_pri);
-			btes_to_try[3] = bte_if_on_node(NASID_GET(dest), bte_sec);
+			nasid_to_try[1] = NASID_GET(dest);
 		} else {
-			btes_to_try[2] = NULL;
-			btes_to_try[3] = NULL;
+			nasid_to_try[1] = (int)NULL;
 		}
 	}
 
@@ -123,11 +129,12 @@ retry_bteop:
 	do {
 		local_irq_save(irq_flags);
 
-		bte_if_index = 0;
+		bte_if_index = bte_first;
+		nasid_index = 0;
 
 		/* Attempt to lock one of the BTE interfaces. */
-		while (bte_if_index < MAX_INTERFACES_TO_TRY) {
-			bte = btes_to_try[bte_if_index++];
+		while (nasid_index < MAX_NODES_TO_TRY) {
+			bte = bte_if_on_node(nasid_to_try[nasid_index],bte_if_index);
 
 			if (bte = NULL) {
 				continue;
@@ -143,6 +150,15 @@ retry_bteop:
 					break;
 				}
 			}
+
+			bte_if_index = (bte_if_index + 1) % btes_per_node; /* Next interface */
+			if (bte_if_index = bte_first) {
+				/*
+				 * We've tried all interfaces on this node
+				 */
+				nasid_index++;
+			}
+
 			bte = NULL;
 		}
 
@@ -169,7 +185,13 @@ retry_bteop:
 
 	/* Initialize the notification to a known value. */
 	*bte->most_rcnt_na = BTE_WORD_BUSY;
+	notif_phys_addr = TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na));
 
+	if (is_shub2()) {
+		src = SH2_TIO_PHYS_TO_DMA(src);
+		dest = SH2_TIO_PHYS_TO_DMA(dest);
+		notif_phys_addr = SH2_TIO_PHYS_TO_DMA(notif_phys_addr);
+	}
 	/* Set the source and destination registers */
 	BTE_PRINTKV(("IBSA = 0x%lx)\n", (TO_PHYS(src))));
 	BTE_SRC_STORE(bte, TO_PHYS(src));
@@ -177,14 +199,12 @@ retry_bteop:
 	BTE_DEST_STORE(bte, TO_PHYS(dest));
 
 	/* Set the notification register */
-	BTE_PRINTKV(("IBNA = 0x%lx)\n",
-		     TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na))));
-	BTE_NOTIF_STORE(bte,
-			TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na)));
+	BTE_PRINTKV(("IBNA = 0x%lx)\n", notif_phys_addr));
+	BTE_NOTIF_STORE(bte, notif_phys_addr);
 
 	/* Initiate the transfer */
 	BTE_PRINTK(("IBCT = 0x%lx)\n", BTE_VALID_MODE(mode)));
-	BTE_START_TRANSFER(bte, transfer_size, BTE_VALID_MODE(mode));
+	bte_start_transfer(bte, transfer_size, BTE_VALID_MODE(mode));
 
 	itc_end = ia64_get_itc() + (40000000 * local_cpu_data->cyc_per_usec);
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


