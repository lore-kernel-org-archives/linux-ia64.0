From: Bernhard Walle <bwalle@suse.de>
Date: Sun, 09 Sep 2007 08:39:18 +0000
Subject: [patch 4/5] Use extended crashkernel command line on IA64
Message-Id: <20070909083915.165288618@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070909083914.065380136@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org

This patch adapts IA64 to use the generic parse_crashkernel() function
instead of its own parsing for the crashkernel command line.

Because the total amount of System RAM must be known when calling this
function, efi_memmap_init() is modified to return its comulated 
total_memory variable in a pointer value. IMO that's better than making the
variable global.

Also, the crashkernel handling is moved in an own function in
arch/ia64/kernel/setup.c to make the code more readable.


Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 arch/ia64/kernel/efi.c     |    5 ++
 arch/ia64/kernel/setup.c   |   88 +++++++++++++++++++++++----------------------
 include/asm-ia64/meminit.h |    3 +
 3 files changed, 52 insertions(+), 44 deletions(-)

--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -968,7 +968,7 @@ find_memmap_space (void)
  * parts exist, and are WB.
  */
 void
-efi_memmap_init(unsigned long *s, unsigned long *e)
+efi_memmap_init(unsigned long *s, unsigned long *e, unsigned long *total_memory)
 {
 	struct kern_memdesc *k, *prev = NULL;
 	u64	contig_low=0, contig_high=0;
@@ -1084,6 +1084,9 @@ efi_memmap_init(unsigned long *s, unsign
 	/* reserve the memory we are using for kern_memmap */
 	*s = (u64)kern_memmap;
 	*e = (u64)++k;
+
+	if (total_memory)
+		*total_memory = total_mem;
 }
 
 void
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -208,6 +208,48 @@ static int __init register_memory(void)
 
 __initcall(register_memory);
 
+
+#ifdef CONFIG_KEXEC
+static void setup_crashkernel(unsigned long total, int *n)
+{
+	unsigned long long base = 0, size = 0;
+	int ret;
+
+	ret = parse_crashkernel(boot_command_line, total,
+			&size, &base);
+	if (ret = 0 && size > 0) {
+		if (!base) {
+			sort_regions(rsvd_region, *n);
+			base = kdump_find_rsvd_region(size,
+					rsvd_region, *n);
+		}
+		if (base != ~0UL) {
+			printk(KERN_INFO "Reserving %ldMB of memory at %ldMB "
+					"for crashkernel (System RAM: %ldMB)\n",
+					(unsigned long)(size >> 20),
+					(unsigned long)(base >> 20),
+					(unsigned long)(total >> 20));
+			rsvd_region[*n].start +				(unsigned long)__va(base);
+			rsvd_region[*n].end +				(unsigned long)__va(base + size);
+			(*n)++;
+			crashk_res.start = base;
+			crashk_res.end = base + size - 1;
+		}
+	}
+	efi_memmap_res.start = ia64_boot_param->efi_memmap;
+	efi_memmap_res.end = efi_memmap_res.start +
+		ia64_boot_param->efi_memmap_size;
+	boot_param_res.start = __pa(ia64_boot_param);
+	boot_param_res.end = boot_param_res.start +
+		sizeof(*ia64_boot_param);
+}
+#else
+static inline void setup_crashkernel(unsigned long total, int *n)
+{}
+#endif
+
 /**
  * reserve_memory - setup reserved memory areas
  *
@@ -219,6 +261,7 @@ void __init
 reserve_memory (void)
 {
 	int n = 0;
+	unsigned long total_memory = 0;
 
 	/*
 	 * none of the entries in this table overlap
@@ -254,50 +297,11 @@ reserve_memory (void)
 		n++;
 #endif
 
-	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
+	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end, &total_memory);
 	n++;
 
-#ifdef CONFIG_KEXEC
-	/* crashkernel=size@offset specifies the size to reserve for a crash
-	 * kernel. If offset is 0, then it is determined automatically.
-	 * By reserving this memory we guarantee that linux never set's it
-	 * up as a DMA target.Useful for holding code to do something
-	 * appropriate after a kernel panic.
-	 */
-	{
-		char *from = strstr(boot_command_line, "crashkernel=");
-		unsigned long base, size;
-		if (from) {
-			size = memparse(from + 12, &from);
-			if (*from = '@')
-				base = memparse(from+1, &from);
-			else
-				base = 0;
-			if (size) {
-				if (!base) {
-					sort_regions(rsvd_region, n);
-					base = kdump_find_rsvd_region(size,
-							      	rsvd_region, n);
-					}
-				if (base != ~0UL) {
-					rsvd_region[n].start -						(unsigned long)__va(base);
-					rsvd_region[n].end -						(unsigned long)__va(base + size);
-					n++;
-					crashk_res.start = base;
-					crashk_res.end = base + size - 1;
-				}
-			}
-		}
-		efi_memmap_res.start = ia64_boot_param->efi_memmap;
-                efi_memmap_res.end = efi_memmap_res.start +
-                        ia64_boot_param->efi_memmap_size;
-                boot_param_res.start = __pa(ia64_boot_param);
-                boot_param_res.end = boot_param_res.start +
-                        sizeof(*ia64_boot_param);
-	}
-#endif
+	setup_crashkernel(total_memory, &n);
+
 	/* end of memory marker */
 	rsvd_region[n].start = ~0UL;
 	rsvd_region[n].end   = ~0UL;
--- a/include/asm-ia64/meminit.h
+++ b/include/asm-ia64/meminit.h
@@ -35,7 +35,8 @@ extern void find_memory (void);
 extern void reserve_memory (void);
 extern void find_initrd (void);
 extern int filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
-extern void efi_memmap_init(unsigned long *, unsigned long *);
+extern void efi_memmap_init(unsigned long *s, unsigned long *e,
+		unsigned long *total_memory);
 extern int find_max_min_low_pfn (unsigned long , unsigned long, void *);
 
 extern unsigned long vmcore_find_descriptor_size(unsigned long address);

-- 
