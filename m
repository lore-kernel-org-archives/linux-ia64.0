From: Fenghua Yu <fenghua.yu@intel.com>
Date: Fri, 02 May 2008 22:26:45 +0000
Subject: [PATCH] Handle invalid ACPI SLIT table
Message-Id: <20080502222645.GA25167@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com> <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Luck, Tony" <tony.luck@intel.com>, Len Brown <lenb@kernel.org>, Arjan van de Ven <arjan@lin>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org


This is a SLIT sanity checking patch. It moves slit_valid() function to
generic ACPI code and does sanity checking for both x86 and ia64. It sets up
node_distance with LOCAL_DISTANCE and REMOTE_DISTANCE when hitting invalid SLIT
table on ia64. It also cleans up unused variable localities in acpi_parse_slit()
on x86. 

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

---

 arch/ia64/kernel/acpi.c |    9 +++++++--
 arch/x86/mm/srat_64.c   |   27 ---------------------------
 drivers/acpi/numa.c     |   31 +++++++++++++++++++++++++++----
 3 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index c7467f8..4f156f4 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -460,7 +460,6 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 		printk(KERN_ERR
 		       "ACPI 2.0 SLIT: size mismatch: %d expected, %d actual\n",
 		       len, slit->header.length);
-		memset(numa_slit, 10, sizeof(numa_slit));
 		return;
 	}
 	slit_table = slit;
@@ -569,8 +568,14 @@ void __init acpi_numa_arch_fixup(void)
 	printk(KERN_INFO "Number of memory chunks in system = %d\n",
 	       num_node_memblks);
 
-	if (!slit_table)
+	if (!slit_table) {
+		for (i = 0; i < MAX_NUMNODES; i++)
+			for (j = 0; j < MAX_NUMNODES; j++)
+				node_distance(i, j) = i = j ? LOCAL_DISTANCE :
+							REMOTE_DISTANCE;
 		return;
+	}
+
 	memset(numa_slit, -1, sizeof(numa_slit));
 	for (i = 0; i < slit_table->locality_count; i++) {
 		if (!pxm_bit_test(i))
diff --git a/arch/x86/mm/srat_64.c b/arch/x86/mm/srat_64.c
index 3890234..99649dc 100644
--- a/arch/x86/mm/srat_64.c
+++ b/arch/x86/mm/srat_64.c
@@ -97,36 +97,9 @@ static __init inline int srat_disabled(void)
 	return numa_off || acpi_numa < 0;
 }
 
-/*
- * A lot of BIOS fill in 10 (= no distance) everywhere. This messes
- * up the NUMA heuristics which wants the local node to have a smaller
- * distance than the others.
- * Do some quick checks here and only use the SLIT if it passes.
- */
-static __init int slit_valid(struct acpi_table_slit *slit)
-{
-	int i, j;
-	int d = slit->locality_count;
-	for (i = 0; i < d; i++) {
-		for (j = 0; j < d; j++)  {
-			u8 val = slit->entry[d*i + j];
-			if (i = j) {
-				if (val != LOCAL_DISTANCE)
-					return 0;
-			} else if (val <= LOCAL_DISTANCE)
-				return 0;
-		}
-	}
-	return 1;
-}
-
 /* Callback for SLIT parsing */
 void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 {
-	if (!slit_valid(slit)) {
-		printk(KERN_INFO "ACPI: SLIT table looks invalid. Not used.\n");
-		return;
-	}
 	acpi_slit = slit;
 }
 
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 5d59cb3..658e5f3 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -140,19 +140,42 @@ acpi_table_print_srat_entry(struct acpi_subtable_header *header)
 	}
 }
 
+/*
+ * A lot of BIOS fill in 10 (= no distance) everywhere. This messes
+ * up the NUMA heuristics which wants the local node to have a smaller
+ * distance than the others.
+ * Do some quick checks here and only use the SLIT if it passes.
+ */
+static __init int slit_valid(struct acpi_table_slit *slit)
+{
+	int i, j;
+	int d = slit->locality_count;
+	for (i = 0; i < d; i++) {
+		for (j = 0; j < d; j++)  {
+			u8 val = slit->entry[d*i + j];
+			if (i = j) {
+				if (val != LOCAL_DISTANCE)
+					return 0;
+			} else if (val <= LOCAL_DISTANCE)
+				return 0;
+		}
+	}
+	return 1;
+}
+
 static int __init acpi_parse_slit(struct acpi_table_header *table)
 {
 	struct acpi_table_slit *slit;
-	u32 localities;
 
 	if (!table)
 		return -EINVAL;
 
 	slit = (struct acpi_table_slit *)table;
 
-	/* downcast just for %llu vs %lu for i386/ia64  */
-	localities = (u32) slit->locality_count;
-
+	if (!slit_valid(slit)) {
+		printk(KERN_INFO "ACPI: SLIT table looks invalid. Not used.\n");
+		return -EINVAL;
+	}
 	acpi_numa_slit_init(slit);
 
 	return 0;
