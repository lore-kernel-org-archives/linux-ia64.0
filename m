From: Robin Holt <holt@sgi.com>
Date: Tue, 22 Jun 2004 16:18:40 +0000
Subject: [PATCH] Fixups for the Altix Block Transfer Engine.
Message-Id: <20040622161840.GB16074@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040611203336.GA10896@lnx-holt.americas.sgi.com>
In-Reply-To: <20040611203336.GA10896@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The attached patch contains some cleanups to the bte code and introduces
the ability to excercise bte interfaces on other nodes.  This is an SGI
Altix specific piece of hardware.


Signed-off by: Robin Holt
Signed-off by: Jesse Barnes

diff -Naur tot/arch/ia64/sn/io/sn2/bte_error.c bte-fixups/arch/ia64/sn/io/sn2/bte_error.c
--- tot/arch/ia64/sn/io/sn2/bte_error.c	2004-06-11 13:47:29.000000000 -0500
+++ bte-fixups/arch/ia64/sn/io/sn2/bte_error.c	2004-06-11 14:14:14.000000000 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -199,7 +199,7 @@
 		err_nodepda->bte_if[i].cleanup_active = 0;
 		BTE_PRINTK(("eh:%p:%d Unlocked %d\n", err_nodepda,
 			    smp_processor_id(), i));
-		spin_unlock(&pda->cpu_bte_if[i]->spinlock);
+		spin_unlock(&err_nodepda->bte_if[i].spinlock);
 	}
 
 	del_timer(recovery_timer);
diff -Naur tot/arch/ia64/sn/kernel/bte.c bte-fixups/arch/ia64/sn/kernel/bte.c
--- tot/arch/ia64/sn/kernel/bte.c	2004-06-11 13:47:23.000000000 -0500
+++ bte-fixups/arch/ia64/sn/kernel/bte.c	2004-06-11 14:14:06.000000000 -0500
@@ -7,6 +7,7 @@
  */
 
 #include <linux/config.h>
+#include <linux/module.h>
 #include <asm/sn/sgi.h>
 #include <asm/sn/nodepda.h>
 #include <asm/sn/addrs.h>
@@ -27,10 +28,18 @@
 #define L1_CACHE_MASK (L1_CACHE_BYTES - 1)
 #endif
 
-/*
- * The base address of for each set of bte registers.
- */
-static int bte_offsets[] = { IIO_IBLS0, IIO_IBLS1 };
+/* two interfaces on two btes */
+#define MAX_INTERFACES_TO_TRY		4
+
+static struct bteinfo_s *
+bte_if_on_node(nasid_t nasid, int interface)
+{
+	nodepda_t *tmp_nodepda;
+
+	tmp_nodepda = NODEPDA(nasid_to_cnodeid(nasid));
+	return &tmp_nodepda->bte_if[interface];
+
+}
 
 
 /************************************************************************
@@ -61,11 +70,12 @@
 bte_result_t
 bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
 {
-	int bte_to_use;
 	u64 transfer_size;
 	struct bteinfo_s *bte;
 	bte_result_t bte_status;
 	unsigned long irq_flags;
+	struct bteinfo_s *btes_to_try[MAX_INTERFACES_TO_TRY];
+	int bte_if_index;
 
 
 	BTE_PRINTK(("bte_copy(0x%lx, 0x%lx, 0x%lx, 0x%lx, 0x%p)\n",
@@ -79,17 +89,57 @@
 		 (src & L1_CACHE_MASK) || (dest & L1_CACHE_MASK)));
 	ASSERT(len < ((BTE_LEN_MASK + 1) << L1_CACHE_SHIFT));
 
+	if (mode & BTE_USE_DEST) {
+		/* try remote then local */
+		btes_to_try[0] = bte_if_on_node(NASID_GET(dest), 0);
+		btes_to_try[1] = bte_if_on_node(NASID_GET(dest), 1);
+		if (mode & BTE_USE_ANY) {
+			btes_to_try[2] = bte_if_on_node(get_nasid(), 0);
+			btes_to_try[3] = bte_if_on_node(get_nasid(), 1);
+		} else {
+			btes_to_try[2] = NULL;
+			btes_to_try[3] = NULL;
+		}
+	} else {
+		/* try local then remote */
+		btes_to_try[0] = bte_if_on_node(get_nasid(), 0);
+		btes_to_try[1] = bte_if_on_node(get_nasid(), 1);
+		if (mode & BTE_USE_ANY) {
+			btes_to_try[2] = bte_if_on_node(NASID_GET(dest), 0);
+			btes_to_try[3] = bte_if_on_node(NASID_GET(dest), 1);
+		} else {
+			btes_to_try[2] = NULL;
+			btes_to_try[3] = NULL;
+		}
+	}
+
 	do {
 		local_irq_save(irq_flags);
 
-		bte_to_use = 0;
+		bte_if_index = 0;
+
 		/* Attempt to lock one of the BTE interfaces. */
-		while ((bte_to_use < BTES_PER_NODE) &&
-		       BTE_LOCK_IF_AVAIL(bte_to_use)) {
-			bte_to_use++;
+		while (bte_if_index < MAX_INTERFACES_TO_TRY) {
+			bte = btes_to_try[bte_if_index++];
+
+			if (bte = NULL) {
+				continue;
+			}
+
+			if (spin_trylock(&bte->spinlock)) {
+				if ((*bte->most_rcnt_na & BTE_ACTIVE) ||
+				    (BTE_LNSTAT_LOAD(bte) & BTE_ACTIVE)) {
+					/* Got the lock but BTE still busy */
+					spin_unlock(&bte->spinlock);
+					bte = NULL;
+				} else {
+					/* we got the lock and it's not busy */
+					break;
+				}
+			}
 		}
 
-		if (bte_to_use < BTES_PER_NODE) {
+		if (bte != NULL) {
 			break;
 		}
 
@@ -100,12 +150,9 @@
 		}
 
 		/* Wait until a bte is available. */
-		udelay(10);
+		udelay(1);
 	} while (1);
 
-	bte = pda->cpu_bte_if[bte_to_use];
-	BTE_PRINTKV(("Got a lock on bte %d\n", bte_to_use));
-
 
 	if (notification = NULL) {
 		/* User does not want to be notified. */
@@ -121,28 +168,24 @@
 	*bte->most_rcnt_na = -1L;
 
 	/* Set the status reg busy bit and transfer length */
-	BTE_PRINTKV(("IBLS - HUB_S(0x%p, 0x%lx)\n",
-		     BTEREG_LNSTAT_ADDR, IBLS_BUSY | transfer_size));
-	HUB_S(BTEREG_LNSTAT_ADDR, (IBLS_BUSY | transfer_size));
+	BTE_PRINTKV(("IBLS = 0x%lx\n", IBLS_BUSY | transfer_size));
+	BTE_LNSTAT_STORE(bte, IBLS_BUSY | transfer_size);
 
 	/* Set the source and destination registers */
-	BTE_PRINTKV(("IBSA - HUB_S(0x%p, 0x%lx)\n", BTEREG_SRC_ADDR,
-		     (TO_PHYS(src))));
-	HUB_S(BTEREG_SRC_ADDR, (TO_PHYS(src)));
-	BTE_PRINTKV(("IBDA - HUB_S(0x%p, 0x%lx)\n", BTEREG_DEST_ADDR,
-		     (TO_PHYS(dest))));
-	HUB_S(BTEREG_DEST_ADDR, (TO_PHYS(dest)));
+	BTE_PRINTKV(("IBSA = 0x%lx)\n", (TO_PHYS(src))));
+	BTE_SRC_STORE(bte, TO_PHYS(src));
+	BTE_PRINTKV(("IBDA = 0x%lx)\n", (TO_PHYS(dest))));
+	BTE_DEST_STORE(bte, TO_PHYS(dest));
 
 	/* Set the notification register */
-	BTE_PRINTKV(("IBNA - HUB_S(0x%p, 0x%lx)\n", BTEREG_NOTIF_ADDR,
-		     (TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na)))));
-	HUB_S(BTEREG_NOTIF_ADDR, (TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na))));
+	BTE_PRINTKV(("IBNA = 0x%lx)\n", 
+		     TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na))));
+	BTE_NOTIF_STORE(bte, TO_PHYS(ia64_tpa((unsigned long)bte->most_rcnt_na)));
 
 
 	/* Initiate the transfer */
-	BTE_PRINTK(("IBCT - HUB_S(0x%p, 0x%lx)\n", BTEREG_CTRL_ADDR,
-		     BTE_VALID_MODE(mode)));
-	HUB_S(BTEREG_CTRL_ADDR, BTE_VALID_MODE(mode));
+	BTE_PRINTK(("IBCT = 0x%lx)\n", BTE_VALID_MODE(mode)));
+	BTE_CTRL_STORE(bte, BTE_VALID_MODE(mode));
 
 	spin_unlock_irqrestore(&bte->spinlock, irq_flags);
 
@@ -156,7 +199,7 @@
 
 
 	BTE_PRINTKV((" Delay Done.  IBLS = 0x%lx, most_rcnt_na = 0x%lx\n",
-				HUB_L(BTEREG_LNSTAT_ADDR), *bte->most_rcnt_na));
+				BTE_LNSTAT_LOAD(bte), *bte->most_rcnt_na));
 
 	if (*bte->most_rcnt_na & IBLS_ERROR) {
 		bte_status = *bte->most_rcnt_na & ~IBLS_ERROR;
@@ -165,10 +208,11 @@
 		bte_status = BTE_SUCCESS;
 	}
 	BTE_PRINTK(("Returning status is 0x%lx and most_rcnt_na is 0x%lx\n",
-				HUB_L(BTEREG_LNSTAT_ADDR), *bte->most_rcnt_na));
+				BTE_LNSTAT_LOAD(bte), *bte->most_rcnt_na));
 
 	return bte_status;
 }
+EXPORT_SYMBOL(bte_copy);
 
 
 /*
@@ -201,14 +245,19 @@
 	u64 footBcopyDest;
 	u64 footBcopyLen;
 	bte_result_t rv;
-	char *bteBlock;
+	char *bteBlock, *bteBlock_unaligned;
 
 	if (len = 0) {
 		return BTE_SUCCESS;
 	}
 
 	/* temporary buffer used during unaligned transfers */
-	bteBlock = pda->cpu_bte_if[0]->scratch_buf;
+	bteBlock_unaligned = kmalloc(len + 3 * L1_CACHE_BYTES,
+				     GFP_KERNEL | GFP_DMA);
+	if (bteBlock_unaligned = NULL) {
+		return BTEFAIL_NOTAVAIL;
+	}
+	bteBlock = (char *) L1_CACHE_ALIGN((u64) bteBlock_unaligned);
 
 	headBcopySrcOffset = src & L1_CACHE_MASK;
 	destFirstCacheOffset = dest & L1_CACHE_MASK;
@@ -276,6 +325,7 @@
 					      ia64_tpa((unsigned long)bteBlock),
 					      footBteLen, mode, NULL);
 				if (rv != BTE_SUCCESS) {
+					kfree(bteBlock_unaligned);
 					return rv;
 				}
 
@@ -296,6 +346,7 @@
 				      (len - headBcopyLen -
 				       footBcopyLen), mode, NULL);
 			if (rv != BTE_SUCCESS) {
+				kfree(bteBlock_unaligned);
 				return rv;
 			}
 
@@ -325,6 +376,7 @@
 		rv = bte_copy(headBteSource,
 			      ia64_tpa((unsigned long)bteBlock), headBteLen, mode, NULL);
 		if (rv != BTE_SUCCESS) {
+			kfree(bteBlock_unaligned);
 			return rv;
 		}
 
@@ -332,8 +384,10 @@
 					     headBcopySrcOffset),
 		       headBcopyLen);
 	}
+	kfree(bteBlock_unaligned);
 	return BTE_SUCCESS;
 }
+EXPORT_SYMBOL(bte_unaligned_copy);
 
 
 /************************************************************************
@@ -370,9 +424,9 @@
 	mynodepda->bte_recovery_timer.data = (unsigned long) mynodepda;
 
 	for (i = 0; i < BTES_PER_NODE; i++) {
-		/* >>> Don't know why the 0x1800000L is here.  Robin */
-		mynodepda->bte_if[i].bte_base_addr -		    (char *) LOCAL_MMR_ADDR(bte_offsets[i] | 0x1800000L);
+		(u64) mynodepda->bte_if[i].bte_base_addr +		    REMOTE_HUB_ADDR(cnodeid_to_nasid(cnode),
+			(i = 0 ? IIO_IBLS0 : IIO_IBLS1));
 
 		/*
 		 * Initialize the notification and spinlock
@@ -383,8 +437,6 @@
 		mynodepda->bte_if[i].notify = 0L;
 		spin_lock_init(&mynodepda->bte_if[i].spinlock);
 
-		mynodepda->bte_if[i].scratch_buf -		    alloc_bootmem_node(NODE_DATA(cnode), BTE_MAX_XFER);
 		mynodepda->bte_if[i].bte_cnode = cnode;
 		mynodepda->bte_if[i].bte_error_count = 0;
 		mynodepda->bte_if[i].bte_num = i;
@@ -393,23 +445,3 @@
 	}
 
 }
-
-/*
- * bte_init_cpu()
- *
- * Initialize the cpupda structure with pointers to the
- * nodepda bte blocks.
- *
- */
-void
-bte_init_cpu(void)
-{
-	/* Called by setup.c as each cpu is being added to the nodepda */
-	if (local_node_data->active_cpu_count & 0x1) {
-		pda->cpu_bte_if[0] = &(nodepda->bte_if[0]);
-		pda->cpu_bte_if[1] = &(nodepda->bte_if[1]);
-	} else {
-		pda->cpu_bte_if[0] = &(nodepda->bte_if[1]);
-		pda->cpu_bte_if[1] = &(nodepda->bte_if[0]);
-	}
-}
diff -Naur tot/arch/ia64/sn/kernel/setup.c bte-fixups/arch/ia64/sn/kernel/setup.c
--- tot/arch/ia64/sn/kernel/setup.c	2004-06-11 13:47:12.000000000 -0500
+++ bte-fixups/arch/ia64/sn/kernel/setup.c	2004-06-11 14:13:57.000000000 -0500
@@ -54,7 +54,6 @@
 #define MAX_PHYS_MEMORY		(1UL << 49)     /* 1 TB */
 
 extern void bte_init_node (nodepda_t *, cnodeid_t);
-extern void bte_init_cpu (void);
 extern void sn_timer_init(void);
 extern unsigned long last_time_offset;
 extern void init_platform_hubinfo(nodepda_t **nodepdaindr);
@@ -475,8 +474,6 @@
 		buddy_nasid = cnodeid_to_nasid(numa_node_id() = numnodes-1 ? 0 : numa_node_id()+ 1);
 		pda->pio_shub_war_cam_addr = (volatile unsigned long*)GLOBAL_MMR_ADDR(nasid, SH_PI_CAM_CONTROL);
 	}
-
-	bte_init_cpu();
 }
 
 /*
diff -Naur tot/include/asm-ia64/sn/bte.h bte-fixups/include/asm-ia64/sn/bte.h
--- tot/include/asm-ia64/sn/bte.h	2004-06-11 13:47:22.000000000 -0500
+++ bte-fixups/include/asm-ia64/sn/bte.h	2004-06-11 14:14:04.000000000 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2003 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2000-2004 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -48,35 +48,31 @@
 #define BTE_ZERO_FILL (BTE_NOTIFY | IBCT_ZFIL_MODE)
 /* Use a reserved bit to let the caller specify a wait for any BTE */
 #define BTE_WACQUIRE (0x4000)
+/* Use the BTE on the node with the destination memory */
+#define BTE_USE_DEST (BTE_WACQUIRE << 1)
+/* Use any available BTE interface on any node for the transfer */
+#define BTE_USE_ANY (BTE_USE_DEST << 1)
 /* macro to force the IBCT0 value valid */
 #define BTE_VALID_MODE(x) ((x) & (IBCT_NOTIFY | IBCT_ZFIL_MODE))
 
-
-/*
- * Handle locking of the bte interfaces.
- *
- * All transfers spinlock the interface before setting up the SHUB
- * registers.  Sync transfers hold the lock until all processing is
- * complete.  Async transfers release the lock as soon as the transfer
- * is initiated.
- *
- * To determine if an interface is available, we must check both the
- * busy bit and the spinlock for that interface.
- */
-#define BTE_LOCK_IF_AVAIL(_x) (\
-	(*pda->cpu_bte_if[_x]->most_rcnt_na & (IBLS_BUSY | IBLS_ERROR)) && \
-	(!(spin_trylock(&(pda->cpu_bte_if[_x]->spinlock)))) \
-	)
+#define BTE_ACTIVE	(IBLS_BUSY | IBLS_ERROR)
 
 /*
  * Some macros to simplify reading.
  * Start with macros to locate the BTE control registers.
  */
-#define BTEREG_LNSTAT_ADDR ((u64 *)(bte->bte_base_addr))
-#define BTEREG_SRC_ADDR ((u64 *)(bte->bte_base_addr + BTEOFF_SRC))
-#define BTEREG_DEST_ADDR ((u64 *)(bte->bte_base_addr + BTEOFF_DEST))
-#define BTEREG_CTRL_ADDR ((u64 *)(bte->bte_base_addr + BTEOFF_CTRL))
-#define BTEREG_NOTIF_ADDR ((u64 *)(bte->bte_base_addr + BTEOFF_NOTIFY))
+#define BTE_LNSTAT_LOAD(_bte)						\
+			HUB_L(_bte->bte_base_addr)
+#define BTE_LNSTAT_STORE(_bte, _x)					\
+			HUB_S(_bte->bte_base_addr, (_x))
+#define BTE_SRC_STORE(_bte, _x)						\
+			HUB_S(_bte->bte_base_addr + (BTEOFF_SRC/8), (_x))
+#define BTE_DEST_STORE(_bte, _x)					\
+			HUB_S(_bte->bte_base_addr + (BTEOFF_DEST/8), (_x))
+#define BTE_CTRL_STORE(_bte, _x)					\
+			HUB_S(_bte->bte_base_addr + (BTEOFF_CTRL/8), (_x))
+#define BTE_NOTIF_STORE(_bte, _x)					\
+			HUB_S(_bte->bte_base_addr + (BTEOFF_NOTIFY/8), (_x))
 
 
 /* Possible results from bte_copy and bte_unaligned_copy */
@@ -111,15 +107,14 @@
  */
 struct bteinfo_s {
-	u64 volatile notify ____cacheline_aligned;
-	char *bte_base_addr ____cacheline_aligned;
+	volatile u64 notify ____cacheline_aligned;
+	u64 *bte_base_addr ____cacheline_aligned;
 	spinlock_t spinlock;
 	cnodeid_t bte_cnode;	/* cnode                            */
 	int bte_error_count;	/* Number of errors encountered     */
 	int bte_num;		/* 0 --> BTE0, 1 --> BTE1           */
 	int cleanup_active;	/* Interface is locked for cleanup  */
 	volatile bte_result_t bh_error;	/* error while processing   */
-	u64 volatile *most_rcnt_na;
-	void *scratch_buf;	/* Node local scratch buffer        */
+	volatile u64 *most_rcnt_na;
 };
 
 
@@ -130,6 +125,8 @@
 extern bte_result_t bte_unaligned_copy(u64, u64, u64, u64);
 extern void bte_error_handler(unsigned long);
 
+#define bte_zero(dest, len, mode, notification) \
+	bte_copy(0, dest, len, ((mode) | BTE_ZERO_FILL), notification)
 
 /*
  * The following is the prefered way of calling bte_unaligned_copy
diff -Naur tot/include/asm-ia64/sn/pda.h bte-fixups/include/asm-ia64/sn/pda.h
--- tot/include/asm-ia64/sn/pda.h	2004-06-11 13:47:37.000000000 -0500
+++ bte-fixups/include/asm-ia64/sn/pda.h	2004-06-11 14:14:23.000000000 -0500
@@ -49,8 +49,6 @@
 	volatile unsigned long *pio_shub_war_cam_addr;
 	volatile unsigned long *mem_write_status_addr;
 
-	struct bteinfo_s *cpu_bte_if[BTES_PER_NODE];	/* cpu interface order */
-
 	unsigned long	sn_soft_irr[4];
 	unsigned long	sn_in_service_ivecs[4];
 	short		cnodeid_to_nasid_table[MAX_NUMNODES];

