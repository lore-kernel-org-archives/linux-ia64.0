From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 05 Dec 2005 19:01:14 +0000
Subject: [PATCH 3/3] Remove debris from old zone reclaim
Message-Id: <20051205190114.12037.18860.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051205190104.12037.69672.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051205190104.12037.69672.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, torvalds@osdl.org
Cc: linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org

Remove debris of old zone reclaim

Removes the leftovers from prior attempts to implement Zone reclaim.

sys_set_zone_reclaim is not reachable in 2.6.14.

The reclaim_pages field in struct zone is only used by sys_set_zone_reclaim.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.15-rc4/include/linux/mmzone.h
=================================--- linux-2.6.15-rc4.orig/include/linux/mmzone.h	2005-11-30 22:25:15.000000000 -0800
+++ linux-2.6.15-rc4/include/linux/mmzone.h	2005-12-05 09:57:36.000000000 -0800
@@ -150,11 +150,6 @@ struct zone {
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	int			all_unreclaimable; /* All pages pinned */
 
-	/*
-	 * Does the allocator try to reclaim pages from the zone as soon
-	 * as it fails a watermark_ok() in __alloc_pages?
-	 */
-	int			reclaim_pages;
 	/* A count of how many reclaimers are scanning this zone */
 	atomic_t		reclaim_in_progress;
 
Index: linux-2.6.15-rc4/mm/vmscan.c
=================================--- linux-2.6.15-rc4.orig/mm/vmscan.c	2005-12-03 13:34:59.000000000 -0800
+++ linux-2.6.15-rc4/mm/vmscan.c	2005-12-05 09:57:36.000000000 -0800
@@ -1394,33 +1394,3 @@ int zone_reclaim(struct zone *z, gfp_t g
 }
 #endif
 
-asmlinkage long sys_set_zone_reclaim(unsigned int node, unsigned int zone,
-				     unsigned int state)
-{
-	struct zone *z;
-	int i;
-
-	if (!capable(CAP_SYS_ADMIN))
-		return -EACCES;
-
-	if (node >= MAX_NUMNODES || !node_online(node))
-		return -EINVAL;
-
-	/* This will break if we ever add more zones */
-	if (!(zone & (1<<ZONE_DMA|1<<ZONE_NORMAL|1<<ZONE_HIGHMEM)))
-		return -EINVAL;
-
-	for (i = 0; i < MAX_NR_ZONES; i++) {
-		if (!(zone & 1<<i))
-			continue;
-
-		z = &NODE_DATA(node)->node_zones[i];
-
-		if (state)
-			z->reclaim_pages = 1;
-		else
-			z->reclaim_pages = 0;
-	}
-
-	return 0;
-}

