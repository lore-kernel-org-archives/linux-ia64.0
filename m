From: Zou Nan hai <nanhai.zou@intel.com>
Date: Mon, 14 Aug 2006 06:53:10 +0000
Subject: IA64 Kdump Patch, reserve efi memmap and boot param region
Message-Id: <1155538390.2585.51.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch is against kexec-tools-1.101 with kdump10 patch.

This patch reserve efi memmap and boot param area for the first kernel
so that they will not be overlapped.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

diff -Nraup kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.c kexec-tools-1.101-ia64-kdump/kexec/arch/ia64/kexec-ia64.c
--- kexec-tools-1.101/kexec/arch/ia64/kexec-ia64.c	2006-08-15 06:08:39.000000000 +0800
+++ kexec-tools-1.101-ia64-kdump/kexec/arch/ia64/kexec-ia64.c	2006-08-15 09:45:20.000000000 +0800
@@ -36,6 +36,38 @@
 
 static struct memory_range memory_range[MAX_MEMORY_RANGES];
 
+/* Reserve range for EFI memmap and Boot parameter */
+static int split_range(int range, unsigned long start, unsigned long end)
+{
+	unsigned long ram_end = memory_range[range - 1].end;
+	unsigned int type = memory_range[range - 1].type;
+	int i;
+	//align end and start to page size of EFI
+	start = start & ~((1UL<<12) - 1);
+	end = (end + (1UL<<12) - 1)& ~((1UL<<12) - 1);
+	for (i = 0; i < range; i++) 
+		if(memory_range[i].start <= start && memory_range[i].end >=end)
+			break;
+	if (i >= range)
+		return range;
+	range = i;
+	if (memory_range[range].start < start) {
+		memory_range[range].end = start;
+		range++;
+	}
+	memory_range[range].start = start;
+	memory_range[range].end = end;
+	memory_range[range].type = RANGE_RESERVED;
+	range++;
+	if (end < ram_end) {
+		memory_range[range].start = end;
+		memory_range[range].end = ram_end;
+		memory_range[range].type = type;
+		range++;
+	}
+	return range;
+}
+
 /* Return a sorted list of available memory ranges. */
 int get_memory_ranges(struct memory_range **range, int *ranges,
 				unsigned long kexec_flags)
@@ -85,6 +117,12 @@ int get_memory_ranges(struct memory_rang
 					mem_max = end;
 			}
 			continue;
+		} else if (memcmp(str, "Boot parameter\n", 14) = 0) {
+			memory_ranges = split_range(memory_ranges, start, end);
+			continue;
+		} else if (memcmp(str, "EFI Memory Map\n", 14) = 0) {
+			memory_ranges = split_range(memory_ranges, start, end);
+			continue;
 		} else
 			continue;
 		/*
@@ -125,7 +163,7 @@ int arch_process_options(int argc, char 
 {
 	static const struct option options[] = {
 		KEXEC_ARCH_OPTIONS
-		{ 0, 			0, NULL, 0 },
+		{ 0, 0, NULL, 0 },
 	};
 	static const char short_options[] = KEXEC_ARCH_OPT_STR;
 	int opt;

