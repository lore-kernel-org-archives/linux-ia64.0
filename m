From: Jack Steiner <steiner@sgi.com>
Date: Sun, 16 Nov 2003 19:30:43 +0000
Subject: [PATCH] - prof_cpu_mask problems
Message-Id: <marc-linux-ia64-106901123527791@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


I ran into several problems with the prof_cpu_mask & other
irq masks.

	- Displaying the profiling mask via "cat /proc/irq/prof_cpu_mask"
	  clears the mask.

	- the IRQ masks are displayed in an unusual format:
		# echo 12345678 >prof_cpu_mask
		# cat prof_cpu_mask
		5678123400000000



--- linux_base/arch/ia64/kernel/irq.c	Sun Nov 16 13:02:56 2003
+++ linux/arch/ia64/kernel/irq.c	Sun Nov 16 13:28:30 2003
@@ -974,18 +974,18 @@
 static int irq_affinity_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
-	int k, len;
-	cpumask_t tmp = irq_affinity[(long)data];
+	cpumask_t mask, irqmask = irq_affinity[(long)data];
+	int i, j, k, len = 0;
 
 	if (count < HEX_DIGITS+1)
 		return -EINVAL;
 
-	len = 0;
-	for (k = 0; k < sizeof(cpumask_t)/sizeof(u16); ++k) {
-		int j = sprintf(page, "%04hx", (u16)cpus_coerce(tmp));
+	i = sizeof(cpumask_t)/sizeof(u16);
+	for (k = 0; k < i; ++k) {
+		cpus_shift_right(mask, irqmask, 16*(i-k-1));
+		j = sprintf(page, "%04hx", (u16)cpus_coerce(mask));
 		len += j;
 		page += j;
-		cpus_shift_right(tmp, tmp, 16);
 	}
 	len += sprintf(page, "\n");
 	return len;
@@ -1033,17 +1033,18 @@
 static int prof_cpu_mask_read_proc (char *page, char **start, off_t off,
 			int count, int *eof, void *data)
 {
-	cpumask_t *mask = (cpumask_t *)data;
-	int k, len = 0;
+	cpumask_t mask, profmask = *(cpumask_t *)data;
+	int i, j, k, len = 0;
 
 	if (count < HEX_DIGITS+1)
 		return -EINVAL;
 
-	for (k = 0; k < sizeof(cpumask_t)/sizeof(u16); ++k) {
-		int j = sprintf(page, "%04hx", (u16)cpus_coerce(*mask));
+	i = sizeof(cpumask_t)/sizeof(u16);
+	for (k = 0; k < i; ++k) {
+		cpus_shift_right(mask, profmask, 16*(i-k-1));
+		j = sprintf(page, "%04hx", (u16)cpus_coerce(mask));
 		len += j;
 		page += j;
-		cpus_shift_right(*mask, *mask, 16);
 	}
 	len += sprintf(page, "\n");
 	return len;
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


