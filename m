From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 Jan 2005 00:06:22 +0000
Subject: [PATCH] long line & codingstyle cleanups for contig.c
Message-Id: <200501061606.22753.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_+Jd3B3ejtbmUmRH"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_+Jd3B3ejtbmUmRH
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This small patch cleans up long lines in contig.c and makes the function 
declarations adhere to Documentation/CodingStyle.  Whitespace only changes.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse & the 80 column brigade

--Boundary-00=_+Jd3B3ejtbmUmRH
Content-Type: text/plain;
  charset="us-ascii";
  name="contig-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="contig-cleanup.patch"

===== arch/ia64/mm/contig.c 1.10 vs edited =====
--- 1.10/arch/ia64/mm/contig.c	2004-12-28 13:38:55 -08:00
+++ edited/arch/ia64/mm/contig.c	2005-01-06 15:51:33 -08:00
@@ -34,8 +34,7 @@
  *
  * Just walks the pages in the system and describes where they're allocated.
  */
-void
-show_mem (void)
+void show_mem(void)
 {
 	int i, total = 0, reserved = 0;
 	int shared = 0, cached = 0;
@@ -75,8 +74,7 @@
  * Passed as a callback function to efi_memmap_walk() to determine the highest
  * available page frame number in the system.
  */
-int
-find_max_pfn (unsigned long start, unsigned long end, void *arg)
+int find_max_pfn(unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long *max_pfnp = arg, pfn;
 
@@ -95,8 +93,7 @@
  * Find a place to put the bootmap and return its starting address in
  * bootmap_start.  This address must be page-aligned.
  */
-int
-find_bootmap_location (unsigned long start, unsigned long end, void *arg)
+int find_bootmap_location(unsigned long start, unsigned long end, void *arg)
 {
 	unsigned long needed = *(unsigned long *)arg;
 	unsigned long range_start, range_end, free_start;
@@ -139,8 +136,7 @@
  * Walk the EFI memory map and find usable memory for the system, taking
  * into account reserved areas.
  */
-void
-find_memory (void)
+void find_memory(void)
 {
 	unsigned long bootmap_size;
 
@@ -174,8 +170,7 @@
  *
  * Allocate and setup per-cpu data areas.
  */
-void *
-per_cpu_init (void)
+void *per_cpu_init(void)
 {
 	void *cpu_data;
 	int cpu;
@@ -187,20 +182,23 @@
 	 */
 	if (smp_processor_id() == 0) {
 		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
-					   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+					   PERCPU_PAGE_SIZE,
+					   __pa(MAX_DMA_ADDRESS));
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
-			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
+			memcpy(cpu_data, __phys_per_cpu_start,
+			       __per_cpu_end - __per_cpu_start);
+			__per_cpu_offset[cpu] = (char *) cpu_data -
+				__per_cpu_start;
 			cpu_data += PERCPU_PAGE_SIZE;
-			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
+			per_cpu(local_per_cpu_offset, cpu) =
+				__per_cpu_offset[cpu];
 		}
 	}
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
 }
 #endif /* CONFIG_SMP */
 
-static int
-count_pages (u64 start, u64 end, void *arg)
+static int count_pages(u64 start, u64 end, void *arg)
 {
 	unsigned long *count = arg;
 
@@ -209,8 +207,7 @@
 }
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-static int
-count_dma_pages (u64 start, u64 end, void *arg)
+static int count_dma_pages(u64 start, u64 end, void *arg)
 {
 	unsigned long *count = arg;
 
@@ -224,8 +221,7 @@
  * Set up the page tables.
  */
 
-void
-paging_init (void)
+void paging_init(void)
 {
 	unsigned long max_dma;
 	unsigned long zones_size[MAX_NR_ZONES];

--Boundary-00=_+Jd3B3ejtbmUmRH--

