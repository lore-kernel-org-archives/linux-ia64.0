From: Robert Picco <Robert.Picco@hp.com>
Date: Thu, 10 Jun 2004 15:23:28 +0000
Subject: [PATCH] discontig.c
Message-Id: <40C87CF0.7070206@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi David and Andrew:

I found a problem with HP NUMA configuration in 2.6.7-rc3-mm1.  The 
node_online_map is incorrect
because of actions taken by reassign_cpu_only_nodes in 
arch/ia64/mm/discontig.c.  The mm1 patch
which changes the mempolicy for the init_task uses this invalid 
node_online_map and eventually uses a
non-existent node's zonelist when calling __alloc_pages. 

The patch below takes care of this issue.  It puts the non-existent 
nodes offline.

thanks,

Bob

diff -ruN -X /home/picco/losl/dontdiff linux-2.6.7-rc3-m1.orig/arch/ia64/mm/discontig.c linux-2.6.7-rc3-m1.hpet/arch/ia64/mm/discontig.c
--- linux-2.6.7-rc3-m1.orig/arch/ia64/mm/discontig.c	2004-06-07 15:14:58.000000000 -0400
+++ linux-2.6.7-rc3-m1.hpet/arch/ia64/mm/discontig.c	2004-06-09 18:44:02.000000000 -0400
@@ -154,6 +154,9 @@
 
 	memcpy(numa_slit, numa_slit_fix, sizeof (numa_slit));
 
+	for (i = nnode; i < numnodes; i++)
+		node_set_offline(i);
+
 	numnodes = nnode;
 
 	return;



