From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 01 Jun 2005 18:59:50 +0000
Subject: Re: [PATCH] Periodically drain non local pagesets
Message-Id: <Pine.LNX.4.62.0506011155270.9664@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506011047060.9277@schroedinger.engr.sgi.com>
 <1117651618.13600.16.camel@localhost>
In-Reply-To: <1117651618.13600.16.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 1 Jun 2005, Dave Hansen wrote:

> Also, are you sure that you need the local_irq_en/disable()?  

drain_pages() does the same. We would run into trouble if an 
interrupt would use the page allocator.

Fix for the zone comparison:

Index: linux-2.6.12-rc5/mm/page_alloc.c
=================================--- linux-2.6.12-rc5.orig/mm/page_alloc.c	2005-06-01 10:41:25.000000000 -0700
+++ linux-2.6.12-rc5/mm/page_alloc.c	2005-06-01 11:57:55.000000000 -0700
@@ -528,7 +528,7 @@ void drain_remote_pages(void)
 		struct per_cpu_pageset *pset;
 
 		/* Do not drain local pagesets */
-		if (zone = zone_table[numa_node_id()])
+		if (zone->zone_pgdat->node_id = numa_node_id())
 			continue;
 
 		pset = zone->pageset[smp_processor_id()];
