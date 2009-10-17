From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 17 Oct 2009 22:10:08 +0000
Subject: [PATCH] ia64: Fix tests on unsigned
Message-Id: <4ADA40C0.4010806@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

struct ate_resource member lowest_free_index is unsigned,
the test was invalid.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/arch/ia64/sn/pci/pcibr/pcibr_ate.c b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
index 5bc34ea..12a5a9c 100644
--- a/arch/ia64/sn/pci/pcibr/pcibr_ate.c
+++ b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
@@ -70,8 +70,7 @@ static inline void free_ate_resource(struct ate_resource *ate_resource,
 				     int start)
 {
 	mark_ate(ate_resource, start, ate_resource->ate[start], 0);
-	if ((ate_resource->lowest_free_index > start) ||
-	    (ate_resource->lowest_free_index < 0))
+	if (ate_resource->lowest_free_index > start)
 		ate_resource->lowest_free_index = start;
 }
 
@@ -86,7 +85,7 @@ static inline int alloc_ate_resource(struct ate_resource *ate_resource,
 	/*
 	 * Check for ate exhaustion.
 	 */
-	if (ate_resource->lowest_free_index < 0)
+	if (ate_resource->lowest_free_index = -1)
 		return -1;
 
 	/*
