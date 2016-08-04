From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 04 Aug 2016 05:38:23 +0000
Subject: [patch] [IA64] pci_br: fix a signedness bug
Message-Id: <20160804053823.GO775@mwanda>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org

ate_resource->lowest_free_index is unsigned so it's never less than
zero.  I've changed it to test for = -1.  This happens when there
aren't any free ates left.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I can't compile this actually...

diff --git a/arch/ia64/sn/pci/pcibr/pcibr_ate.c b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
index 5bc34ea..024ae9b 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_ate.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
@@ -71,7 +71,7 @@ static inline void free_ate_resource(struct ate_resource *ate_resource,
 {
 	mark_ate(ate_resource, start, ate_resource->ate[start], 0);
 	if ((ate_resource->lowest_free_index > start) ||
-	    (ate_resource->lowest_free_index < 0))
+	    (ate_resource->lowest_free_index = -1))
 		ate_resource->lowest_free_index = start;
 }
 
@@ -86,7 +86,7 @@ static inline int alloc_ate_resource(struct ate_resource *ate_resource,
 	/*
 	 * Check for ate exhaustion.
 	 */
-	if (ate_resource->lowest_free_index < 0)
+	if (ate_resource->lowest_free_index = -1)
 		return -1;
 
 	/*
