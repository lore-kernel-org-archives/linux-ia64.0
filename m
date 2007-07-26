From: Sam Ravnborg <sam@ravnborg.org>
Date: Thu, 26 Jul 2007 21:01:41 +0000
Subject: [PATCH] ia64: fix a few section mismatch warnings
Message-Id: <20070726210141.GA7266@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Fix the following section mismatch warnings:

WARNING: vmlinux.o(.text+0x41902): Section mismatch: reference to .init.text:__alloc_bootmem (between 'ia64_mca_cpu_init' and 'ia64_do_tlb_purge')
WARNING: vmlinux.o(.text+0x49222): Section mismatch: reference to .init.text:__alloc_bootmem (between 'register_intr' and 'iosapic_register_intr')
WARNING: vmlinux.o(.text+0x62beb2): Section mismatch: reference to .init.text:__alloc_bootmem_node (between 'hubdev_init_node' and 'cnodeid_get_geoid')

For two of the warnings a helper function marked __init_refok was used.
For the last warning a missing __init annotation was added.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
The two remaning warnings in the defconfig build I could not fix:
WARNING: vmlinux.o(.text+0x5b0e2): Section mismatch: reference to .init.text:memmap_init_zone (between 'virtual_memmap_init' and 'memmap_init')
WARNING: vmlinux.o(.text+0x5b182): Section mismatch: reference to .init.text:memmap_init_zone (between 'memmap_init' and 'find_max_min_low_pfn')

I was not sure about the right way to do it since I did not understand
the code in mm/init.c deeply enough.

	Sam

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 91e6dc1..92ac2b0 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -560,6 +560,11 @@ iosapic_reassign_vector (int irq)
 	}
 }
 
+static void *__init_refok alloc_rte(unsigned long size)
+{
+	return alloc_bootmem(size);
+}
+
 static struct iosapic_rte_info *iosapic_alloc_rte (void)
 {
 	int i;
@@ -567,7 +572,7 @@ static struct iosapic_rte_info *iosapic_alloc_rte (void)
 	int preallocated = 0;
 
 	if (!iosapic_kmalloc_ok && list_empty(&free_rte_list)) {
-		rte = alloc_bootmem(sizeof(struct iosapic_rte_info) *
+		rte = alloc_rte(sizeof(struct iosapic_rte_info) *
 				    NR_PREALLOCATE_RTE_ENTRIES);
 		if (!rte)
 			return NULL;
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 4b5daa3..e17bf97 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1751,6 +1751,10 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 }
 
 /* Do per-CPU MCA-related initialization.  */
+static void * __init_refok mca_bootmem(unsigned long size)
+{
+	return alloc_bootmem(size);
+}
 
 void __cpuinit
 ia64_mca_cpu_init(void *cpu_data)
@@ -1763,7 +1767,7 @@ ia64_mca_cpu_init(void *cpu_data)
 		int cpu;
 
 		first_time = 0;
-		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
+		mca_data = mca_bootmem(sizeof(struct ia64_mca_cpu)
 					 * NR_CPUS + KERNEL_STACK_SIZE);
 		mca_data = (void *)(((unsigned long)mca_data +
 					KERNEL_STACK_SIZE - 1) &
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 787ed64..4594770 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -391,7 +391,7 @@ void sn_bus_free_sysdata(void)
  * hubdev_init_node() - Creates the HUB data structure and link them to it's
  *			own NODE specific data area.
  */
-void hubdev_init_node(nodepda_t * npda, cnodeid_t node)
+void __init hubdev_init_node(nodepda_t * npda, cnodeid_t node)
 {
 	struct hubdev_info *hubdev_info;
 	int size;
