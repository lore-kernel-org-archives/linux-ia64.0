From: Horms <horms@verge.net.au>
Date: Wed, 07 Mar 2007 00:57:35 +0000
Subject: Re: [patch 3/3] IA64: verify the base address of crashkernel
Message-Id: <20070307005733.GF17090@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073756.245032985@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Aron,

thanks for picking up these silly errors. An updated version is below.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

When the crashkernel command line argument is supplied, it may optionally
include the base address at which to locate the region. If this is omitted
then the kernel attempts to locate an appropriate base address and in 
the course of this checks to make sure it is placed in a region that
is writable.

If, however, the base address is supplied on the command line this check is
not made. This patch adds validation code to:

* Warn is the base address is not aligned (to 64Mb)
* Invalidate the crashkernel region if it does not lie with in
  an appropriate EFI region
* Invalidate the crash kernel region if it clashes with a reserved region
  (this was kind of handled already by virtue of the way the resource
   is inserted into /proc/iomem)

It also defined CRASHDUMP_ALIGN rather than just hardcoding it
to 64Mb as needed (previously only in kdump_find_kdump_find_rsvd_region())

The code came out to be a little longer than I had expected.
It could be made more compact, likely at the expense of some readability.
But as its in __init, its not really a big deal IMHO.

An alternative approach would to be add checks at the time the
region is inserted to /proc/iomem. I'm not sure how well this would
work, but I am happy to investigate.

* Updates thanks to Aron Griffis
  - kdump_region_verify_rsvd_region should return 1 (not 0) if its checks 
    succeed
  - Remove duplicate "return 1" from the end of kdump_region_verify

Signed-off-by: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/efi.c   |   84 ++++++++++++++++++++++++++++++++++++++++++++--
 arch/ia64/kernel/setup.c |   10 ++++-
 include/asm-ia64/kexec.h |    2 +
 3 files changed, 91 insertions(+), 5 deletions(-)
Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-03-07 09:39:10.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-03-07 09:51:01.000000000 +0900
@@ -1160,6 +1160,84 @@
 }
 
 #ifdef CONFIG_KEXEC
+
+#define CRASHDUMP_ALIGNMENT (1 << _PAGE_SIZE_64M)
+static int __init
+kdump_region_verify_efi (unsigned long base, unsigned long size)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	unsigned long efi_desc_size;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+		if (base < md->phys_addr || base + size > efi_md_end(md))
+			continue;
+		if (is_memory_available(md))
+			return 1;
+		printk(KERN_WARNING "Kdump: crashkernel region 0x%lx-0x%lx is "
+		       "inside the unusable efi region 0x%lx-0x%lx\n", base,
+		       base + size - 1, md->phys_addr, efi_md_end(md) - 1);
+		return 0;
+	}
+
+	printk(KERN_WARNING "Kdump: crashkernel region 0x%lx-0x%lx does not "
+	       "fit in any efi region\n", base, base + size - 1);
+	return 0;
+}
+
+
+/* find a block of memory aligned to 64M exclude reserved regions
+   rsvd_regions are sorted
+ */
+static int __init
+kdump_region_verify_rsvd_region (unsigned long base, unsigned long size,
+	       			 struct rsvd_region *rsvd_regions, int n)
+{
+	int i;
+
+	for (i = 0; i < n; i++) {
+		if (__pa(rsvd_regions[i].start) < base ||
+		    __pa(rsvd_regions[i].end) >= base + size - 1)
+			continue;
+		printk(KERN_WARNING "Kdump: crashkernel region 0x%lx-0x%lx "
+		       "clashes with reserved region 0x%lx-0x%lx\n", base,
+		       base + size - 1, __pa(rsvd_regions[i].start),
+		       __pa(rsvd_regions[i].end));
+		return 0;
+	}
+	return 1;
+}
+
+
+/* find a block of memory aligned to 64M exclude reserved regions
+   rsvd_regions are sorted
+ */
+int __init
+kdump_region_verify (unsigned long base, unsigned long size,
+		     struct rsvd_region *rsvd_regions, int n)
+{
+	/* This isn't considered to be a failure condition,
+	 * but it isn't desireable either, so log it */
+	if (ALIGN(base, CRASHDUMP_ALIGNMENT) != base)
+		printk(KERN_WARNING "Kdump: warning: crashkernel region "
+		       "0x%lx-0x%lx is not aligned to 0x%x\n",
+		       base, base + size - 1, CRASHDUMP_ALIGNMENT);
+
+	if (!kdump_region_verify_efi(base, size))
+		return 0;
+
+	if (!kdump_region_verify_rsvd_region(base, size, rsvd_regions, n))
+		return 0;
+
+	printk(KERN_INFO "Kdump: crashkernel region verified\n");
+	return 1;
+}
+
 /* find a block of memory aligned to 64M exclude reserved regions
    rsvd_regions are sorted
  */
@@ -1169,7 +1247,6 @@
 {
   int i;
   u64 start, end;
-  u64 alignment = 1UL << _PAGE_SIZE_64M;
   void *efi_map_start, *efi_map_end, *p;
   efi_memory_desc_t *md;
   u64 efi_desc_size;
@@ -1182,13 +1259,13 @@
 	  md = p;
 	  if (!is_memory_available(md))
 		  continue;
-	  start = ALIGN(md->phys_addr, alignment);
+	  start = ALIGN(md->phys_addr, CRASHDUMP_ALIGNMENT);
 	  end = efi_md_end(md);
 	  for (i = 0; i < n; i++) {
 		if (__pa(r[i].start) >= start && __pa(r[i].end) < end) {
 			if (__pa(r[i].start) > start + size)
 				return start;
-			start = ALIGN(__pa(r[i].end), alignment);
+			start = ALIGN(__pa(r[i].end), CRASHDUMP_ALIGNMENT);
 			if (i < n-1 && __pa(r[i+1].start) < start + size)
 				continue;
 			else
Index: linux-2.6/arch/ia64/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/kernel/setup.c	2007-03-07 09:39:10.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/setup.c	2007-03-07 09:39:10.000000000 +0900
@@ -275,11 +275,17 @@
 			else
 				base = 0;
 			if (size) {
+				sort_regions(rsvd_region, n);
 				if (!base) {
-					sort_regions(rsvd_region, n);
 					base = kdump_find_rsvd_region(size,
 							      	rsvd_region, n);
-					}
+				}
+				else {
+					if (!kdump_region_verify(base, size,
+								 rsvd_region,
+								 n))
+						base = ~0UL;
+				}
 				if (base != ~0UL) {
 					rsvd_region[n].start  						(unsigned long)__va(base);
Index: linux-2.6/include/asm-ia64/kexec.h
=================================--- linux-2.6.orig/include/asm-ia64/kexec.h	2007-03-07 09:38:50.000000000 +0900
+++ linux-2.6/include/asm-ia64/kexec.h	2007-03-07 09:39:10.000000000 +0900
@@ -37,6 +37,8 @@
 extern void kexec_disable_iosapic(void);
 extern void crash_save_this_cpu(void);
 struct rsvd_region;
+extern int kdump_region_verify(unsigned long base,
+		unsigned long size, struct rsvd_region *rsvd_regions, int n);
 extern unsigned long kdump_find_rsvd_region(unsigned long size,
 		struct rsvd_region *rsvd_regions, int n);
 extern void kdump_cpu_freeze(struct unw_frame_info *info, void *arg);
