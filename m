From: Russ Anderson <rja@sgi.com>
Date: Sat, 10 Mar 2007 23:25:15 +0000
Subject: [patch] Avoid duplicate string allocations for the same cpu type
Message-Id: <200703102325.l2ANPFal4403267@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Avoid duplicate string allocations for the same cpu type

If a system has more than one cpu type, get_model_name() will 
allocate a unique "model name" string for each cpu different than
the boot cpu.  (See "model name" in /proc/cpuinfo for an example.)

What compounds this is Intel's decision to give different steppings
different model names.  Montecito C1 is 
"Dual-Core Intel(R) Itanium(R) 2 Processor 9040" while Montecito C2 is 
"Dual-Core Intel(R) Itanium(R) 2 Processor 9050".  That increases the
likelyhood of having different cpu types.

Model names are also getting longer, such as 
"Intel(r) Itanium(r) 2 Processor 1.6GHz with 18M L3 Cache for 533MHz Platforms".
Each thread is treated as a different "cpu", further compounding the problem.

This patch makes get_model_name() smarter.  It allocates one string
for each unique "model name" and returns a pointer to the appropriate
string.  It handles up to 8 different cpu types.  Above that number 
it reverts to the previous behavior of allocating a unque string for each
thread.  Since all threads in a socket have the same "model name", there
needs to be more than 8 different socket types to revert to the old behavior.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/setup.c |   27 +++++++++++++++++++++------
 1 file changed, 21 insertions(+), 6 deletions(-)

Index: test/arch/ia64/kernel/setup.c
=================================--- test.orig/arch/ia64/kernel/setup.c	2007-03-09 17:32:27.000000000 -0600
+++ test/arch/ia64/kernel/setup.c	2007-03-10 16:06:04.313548208 -0600
@@ -665,11 +665,14 @@ struct seq_operations cpuinfo_op = {
 };
 
 static char brandname[128];
+#define BRAND_SIZE	8
+static char * brands[BRAND_SIZE];
 
 static char * __cpuinit
 get_model_name(__u8 family, __u8 model)
 {
 	char brand[128];
+	int i;
 
 	memcpy(brand, "Unknown", 8);
 	if (ia64_pal_get_brand_info(brand)) {
@@ -681,12 +684,24 @@ get_model_name(__u8 family, __u8 model)
 			case 2: memcpy(brand, "Madison up to 9M cache", 23); break;
 		}
 	}
-	if (brandname[0] = '\0')
-		return strcpy(brandname, brand);
-	else if (strcmp(brandname, brand) = 0)
-		return brandname;
-	else
-		return kstrdup(brand, GFP_KERNEL);
+	/*
+	 * kstrdup() cannot be called early in the boot process,
+	 * so use a static buffer for the first cpu.
+	 */
+	if (!brands[0]) {
+		strcpy(brandname, brand);
+		brands[0] = brandname;
+		return brands[0];
+	}
+	for (i = 0; i < BRAND_SIZE; i++) {
+		if (!brands[i]) {
+			brands[i] = kstrdup(brand, GFP_KERNEL);
+			return brands[i];
+		} else if (strcmp(brands[i], brand) = 0) {
+			return brands[i];
+		}
+	}
+	return kstrdup(brand, GFP_KERNEL);
 }
 
 static void __cpuinit
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
