From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 29 Nov 2011 14:01:51 +0000
Subject: Overlapping reserved regions at boot
Message-Id: <201111291501.51657.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Hello,

while working on the upcoming SLES11 SP2, I ran into an issue with booting the 
panic kernel on a kernel crash. In the first iteration I found out that the 
initial register backing store gets overwritten with zeroes, causing a kernel 
crash shortly afterwards.

Further investigation revealed that rsvd_region[] contains overlapping 
entries: find_memmap_space() returns a pointer which lies between KERNEL_START 
and _end. This is correct with the EFI memmap as patched by the kexec 
purgatory code. That code removes vmlinux LOAD segments from the usable map, 
but there is a pretty large hole between the gate section and the per-cpu 
section.

With the following patch, the panic kernel can boot and save the crash dump.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -225,6 +225,23 @@
 	}
 }
 
+/* merge overlaps */
+static int __init
+merge_regions (struct rsvd_region *rsvd_region, int max)
+{
+	int i;
+	for (i = 1; i < max; ++i) {
+		if (rsvd_region[i].start >= rsvd_region[i-1].end)
+			continue;
+		if (rsvd_region[i].end > rsvd_region[i-1].end)
+			rsvd_region[i-1].end = rsvd_region[i].end;
+		--max;
+		memmove(&rsvd_region[i], &rsvd_region[i+1],
+			(max - i) * sizeof(struct rsvd_region));
+	}
+	return max;
+}
+
 /*
  * Request address space for all standard resources
  */
@@ -275,6 +292,7 @@
 	if (ret = 0 && size > 0) {
 		if (!base) {
 			sort_regions(rsvd_region, *n);
+			*n = merge_regions(rsvd_region, *n);
 			base = kdump_find_rsvd_region(size,
 					rsvd_region, *n);
 		}
@@ -392,6 +410,7 @@
 	BUG_ON(IA64_MAX_RSVD_REGIONS + 1 < n);
 
 	sort_regions(rsvd_region, num_rsvd_regions);
+	num_rsvd_regions = merge_regions(rsvd_region, num_rsvd_regions);
 }
 
 
