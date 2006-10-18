From: Jack Steiner <steiner@sgi.com>
Date: Wed, 18 Oct 2006 21:25:59 +0000
Subject: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061018212559.GA2965@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


If a system consists of mixed processor types, kmalloc()
can be called before the per-cpu data page is initialized. 
If the slab contains sufficient memory, then kmalloc() works
ok. However, if the slabs are empty, slab calls the memory
allocator. This requires per-cpu data (NODE_DATA()) & the
cpu dies.

	Signed-off-by: Jack Steiner <steiner@sgi.com>




Index: linux/arch/ia64/kernel/setup.c
=================================--- linux.orig/arch/ia64/kernel/setup.c	2006-10-18 15:49:49.000000000 -0500
+++ linux/arch/ia64/kernel/setup.c	2006-10-18 16:19:18.261790796 -0500
@@ -643,12 +643,14 @@ struct seq_operations cpuinfo_op = {
 	.show =		show_cpuinfo
 };
 
-static char brandname[128];
+#define MAX_BRANDS	4
+static char brandname[MAX_BRANDS][128];
 
 static char * __cpuinit
 get_model_name(__u8 family, __u8 model)
 {
 	char brand[128];
+	int i;
 
 	if (ia64_pal_get_brand_info(brand)) {
 		if (family = 0x7)
@@ -660,12 +662,14 @@ get_model_name(__u8 family, __u8 model)
 		} else
 			memcpy(brand, "Unknown", 8);
 	}
-	if (brandname[0] = '\0')
-		return strcpy(brandname, brand);
-	else if (strcmp(brandname, brand) = 0)
-		return brandname;
-	else
-		return kstrdup(brand, GFP_KERNEL);
+	for (i = 0; i < MAX_BRANDS; i++)
+		if (strcmp(brandname[i], brand) = 0)
+			return brandname[i];
+	for (i = 0; i < MAX_BRANDS; i++)
+		if (brandname[i][0] = '\0')
+			return strcpy(brandname[i], brand);
+	BUG();
+	return NULL;	/* quiet compiler */
 }
 
 static void __cpuinit
