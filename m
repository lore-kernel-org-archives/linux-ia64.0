From: Jack Steiner <steiner@sgi.com>
Date: Wed, 05 Jan 2005 15:47:50 +0000
Subject: [PATCH] - Alignment of pernode structures allocated by discontig.c
Message-Id: <20050105154749.GA27451@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Allocation of pernode structures in find_pernode_space() does not
properly stagger the alignment of the pgdats. This causes
aliasing of the structures in the L3 caches, ie. the same fields
in pgdat structures for multiple nodes will index to same cache
index in the L3. 

If a process is allocating a huge amount of space & many nodes must 
be scanned before finding a node with available space, allocation 
of a pages is significantly slowed by excessive cache misses.

By properly staggering the locations of the pgdat structures, allocation
times on insanely large systems is dramatically improved. On a 256 node
512GB system, allocation of 450 GB by a single process was reduced 
from 1510 sec to 220 sec - a 7X improvement.

Aside from wasting a trivial amount of space, I don't see any 
downside to staggering the allocation by 1 cacheline per node.

	wasted space
		bytes = N * (N-1) * 64

	For 64 node system
		wasted bytes = ~256K


The following shows the results of a test that mallocs 450GB, then 
bzeroes each page. Every 10 sec, the test reports the total
number of GB that have been zeroed, and the incremental rate.


            --- BASELINE -----     ----- ALIGNED --------
Elapsed      Total      Rate         Total        Rate
seconds         GB   pages/sec          GB      pages/sec
    10       33875       35258          34850       36785   
    20       60840       33866          63417       36197   
    30       84315       20844          90527       33648   
    40       94480       11931         116366       32447   
    50      103358       10576         140293       29793   
    60      110261        7254         163353       29627   
    70      115774        6919         186100       29050   
    80      121054        6600         208400       28399   
    90      126063        6296         229699       25684   
   100      130858        6032         248927       24181   
...
   210      175312        4525         425059       18261   
   220      178816        4438         439135       17825   
   230      182254        4348 
   240      185631        4302
   250      188945        4205
....
  1480      426872        1740
  1490      428234        1743
  1500      429588        1734
  1510      430939        1724


---
Stagger the addresses of the pernode data structures to minimize
cache aliasing.

	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/arch/ia64/mm/discontig.c
=================================--- linux.orig/arch/ia64/mm/discontig.c	2005-01-03 19:45:55.291943071 -0600
+++ linux/arch/ia64/mm/discontig.c	2005-01-04 08:52:08.993434254 -0600
@@ -296,6 +296,7 @@ static int __init find_pernode_space(uns
 	 */
 	cpus = early_nr_cpus_node(node);
 	pernodesize += PERCPU_PAGE_SIZE * cpus;
+	pernodesize += node * L1_CACHE_BYTES;
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 	pernodesize = PAGE_ALIGN(pernodesize);
@@ -309,6 +310,7 @@ static int __init find_pernode_space(uns
 
 		cpu_data = (void *)pernode;
 		pernode += PERCPU_PAGE_SIZE * cpus;
+		pernode += node * L1_CACHE_BYTES;
 
 		mem_data[node].pgdat = __va(pernode);
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


