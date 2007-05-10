From: Simon Horman <horms@verge.net.au>
Date: Thu, 10 May 2007 10:19:46 +0000
Subject: [request-for-test] [patch 1/3] IA64: Remove duplicate range check in call_pernode_memory()
Message-Id: <20070510102032.803148805@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Start is already verified to be less than end a few lines earlier.

From: Simon Horman <horms@verge.net.au>

Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2007-05-10 17:23:34.000000000 +0900
+++ linux-2.6/arch/ia64/mm/discontig.c	2007-05-10 17:23:53.000000000 +0900
@@ -593,8 +593,7 @@ void call_pernode_memory(unsigned long s
 
 	if (!num_node_memblks) {
 		/* No SRAT table, so assume one node (node 0) */
-		if (start < end)
-			(*func)(start, end - start, 0);
+		(*func)(start, end - start, 0);
 		return;
 	}
 

-- 

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

