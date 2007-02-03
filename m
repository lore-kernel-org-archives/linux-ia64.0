From: Jay Lan <jlan@sgi.com>
Date: Sat, 03 Feb 2007 00:34:39 +0000
Subject: [PATCH] IA64 kexec-tools: memory_ranges arrays scalability issue
Message-Id: <45C3D89F.1060301@sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------020600090007020707030309"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------020600090007020707030309
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

There are two memory_ranges arrays declared in the IA64 kexec code.
One in kexec-ia64.c and the other one in crashdump-ia64.c.

They currently were allocated as a hard-coded size of array. Since
SN systems may scale to hunders of nodes and each node may contain
up to 12 DIMMs, the hard-coded size of 1024 is not enough for very
large systems.

The size of either array can not be greater than the number of
entries in /proc/iomem, which is saved as "max_memory_ranges"
and is used to dynamically allocate the two arrays.


Signed-off-by:  Jay Lan <jlan@sgi.com>


--------------020600090007020707030309
Content-Type: text/plain;
 name="max-memory-ranges"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="max-memory-ranges"

Index: kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.c
===================================================================
--- kexec-tools-1.101.orig/kexec/arch/ia64/kexec-ia64.c	2007-02-02 18:02:44.000000000 -0600
+++ kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.c	2007-02-02 18:11:49.000000000 -0600
@@ -36,7 +36,10 @@
 #include "kexec-ia64.h"
 #include <arch/options.h>
 
-static struct memory_range memory_range[MAX_MEMORY_RANGES];
+/* The number of entries in memory_range array is always smaller than
+   the number of entries in /proc/iomem, stored in max_memory_ranges. */
+static struct memory_range *memory_range;
+int max_memory_ranges;
 static int memory_ranges;
 unsigned long saved_efi_memmap_size;
 
@@ -86,13 +89,21 @@ int get_memory_ranges(struct memory_rang
 		return -1;
 	}
 
+	/* allocate memory_range dynamically */
+	while(fgets(line, sizeof(line), fp) != 0) {
+		max_memory_ranges++;
+	}
+	memory_range = xmalloc(sizeof(struct memory_range) *
+			max_memory_ranges);
+	rewind(fp);
+
 	while(fgets(line, sizeof(line), fp) != 0) {
 		unsigned long start, end;
 		char *str;
 		int type;
 		int consumed;
 		int count;
-		if (memory_ranges >= MAX_MEMORY_RANGES)
+		if (memory_ranges >= max_memory_ranges)
 			break;
 		count = sscanf(line, "%lx-%lx : %n",
 				&start, &end, &consumed);
Index: kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c
===================================================================
--- kexec-tools-1.101.orig/kexec/arch/ia64/crashdump-ia64.c	2007-02-02 18:02:44.000000000 -0600
+++ kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.c	2007-02-02 18:14:57.000000000 -0600
@@ -31,8 +31,10 @@ int memory_ranges = 0;
 #define LOAD_OFFSET 	(0xa000000000000000UL + 0x100000000UL - kernel_code_start)
 #define MAX_LINE        160
 /* Stores a sorted list of RAM memory ranges for which to create elf headers.
- * A separate program header is created for backup region */
-static struct memory_range crash_memory_range[CRASH_MAX_MEMORY_RANGES];
+ * A separate program header is created for backup region.
+ * The number of entries in memory_range array is always smaller than
+ * the number of entries in /proc/iomem, stored in max_memory_ranges. */
+static struct memory_range *crash_memory_range;
 /* Memory region reserved for storing panic kernel and other data. */
 static struct memory_range crash_reserved_mem;
 unsigned long elfcorehdr;
@@ -133,7 +135,7 @@ static int exclude_crash_reserve_region(
 	}
 	/* Insert split memory region, if any. */
 	if (tidx >= 0) {
-		if (*nr_ranges == CRASH_MAX_MEMORY_RANGES) {
+		if (*nr_ranges == max_memory_ranges) {
 			/* No space to insert another element. */
 			fprintf(stderr, "Error: Number of crash memory ranges"
 					" excedeed the max limit\n");
@@ -250,6 +252,8 @@ static int get_crash_memory_ranges(struc
         FILE *fp;
         unsigned long start, end;
 
+	crash_memory_range = xmalloc(sizeof(struct memory_range) *
+				max_memory_ranges);
         fp = fopen(iomem, "r");
         if (!fp) {
                 fprintf(stderr, "Cannot open %s: %s\n",
@@ -259,7 +263,7 @@ static int get_crash_memory_ranges(struc
 	while(fgets(line, sizeof(line), fp) != 0) {
 		char *str;
 		int type, consumed, count;
-		if (memory_ranges >= CRASH_MAX_MEMORY_RANGES)
+		if (memory_ranges >= max_memory_ranges)
 			break;
 		count = sscanf(line, "%lx-%lx : %n",
 				&start, &end, &consumed);
Index: kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.h
===================================================================
--- kexec-tools-1.101.orig/kexec/arch/ia64/kexec-ia64.h	2007-02-02 18:02:44.000000000 -0600
+++ kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.h	2007-02-02 18:03:44.000000000 -0600
@@ -1,8 +1,7 @@
 #ifndef KEXEC_IA64_H
 #define KEXEC_IA64_H
 
-#define MAX_MEMORY_RANGES 1024
-
+extern int max_memory_ranges;
 int elf_ia64_probe(const char *buf, off_t len);
 int elf_ia64_load(int argc, char **argv, const char *buf, off_t len,
 	struct kexec_info *info);
@@ -11,7 +10,6 @@ int update_loaded_segments(struct kexec_
 void move_loaded_segments(struct kexec_info *info, struct mem_ehdr *ehdr,
         unsigned long addr);
 
-#define MAX_MEMORY_RANGES 1024
 #define EFI_PAGE_SIZE	  (1UL<<12)
 #define ELF_PAGE_SIZE	  (1UL<<16)
 #endif /* KEXEC_IA64_H */
Index: kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.h
===================================================================
--- kexec-tools-1.101.orig/kexec/arch/ia64/crashdump-ia64.h	2007-02-02 18:02:44.000000000 -0600
+++ kexec-tools-1.101/kexec/arch/ia64/crashdump-ia64.h	2007-02-02 18:03:44.000000000 -0600
@@ -8,6 +8,5 @@ extern int load_crashdump_segments(struc
 		unsigned long min_base, char **cmdline);
 
 #define CRASH_MAX_MEMMAP_NR     (KEXEC_MAX_SEGMENTS + 1)
-#define CRASH_MAX_MEMORY_RANGES (MAX_MEMORY_RANGES + 2)
 
 #endif

--------------020600090007020707030309--
