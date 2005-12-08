From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 08 Dec 2005 21:08:50 +0000
Subject: Re: [PATCH 3/3] Zone reclaim V3: Frequency of failed reclaim attempts
Message-Id: <Pine.LNX.4.62.0512081308360.30567@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051208203707.30456.57439.sendpatchset@schroedinger.engr.sgi.com>
 <20051208203717.30456.17434.sendpatchset@schroedinger.engr.sgi.com>
 <20051208205241.GR11190@wotan.suse.de>
In-Reply-To: <20051208205241.GR11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, steiner@sgi.com, linux-kernel@vger.kernel.org, Wu Fengguang <wfg@mail.ustc.edu.cn>

Patch:

Index: linux-2.6.15-rc4/mm/vmscan.c
=================================--- linux-2.6.15-rc4.orig/mm/vmscan.c	2005-12-08 12:31:56.000000000 -0800
+++ linux-2.6.15-rc4/mm/vmscan.c	2005-12-08 13:07:05.000000000 -0800
@@ -1386,7 +1386,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	 * will be a waste of time. Continue off node allocations for the
 	 * duration of this tick.
 	 */
-	if (zone->last_unsuccessful_zone_reclaim = get_jiffies_64())
+	if (zone->last_unsuccessful_zone_reclaim = jiffies)
 		return 0;
 
 	sc.gfp_mask = gfp_mask;
@@ -1408,7 +1408,7 @@ int zone_reclaim(struct zone *zone, gfp_
 	p->reclaim_state = NULL;
 	current->flags &= ~PF_MEMALLOC;
 	if (sc.nr_reclaimed = 0)
-		zone->last_unsuccessful_zone_reclaim = get_jiffies_64();
+		zone->last_unsuccessful_zone_reclaim = jiffies;
 	cond_resched();
 	return sc.nr_reclaimed >= (1 << order);
 }
