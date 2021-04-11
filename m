From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 11 Apr 2021 00:12:01 +0000
Subject: [PATCH] ia64: fix discontig.c section mismatches
Message-Id: <20210411001201.3069-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Mike Rapoport <rppt@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org

Fix IA64 discontig.c Section mismatch warnings.

When CONFIG_SPARSEMEM=y and CONFIG_MEMORY_HOTPLUG=y, the functions
computer_pernodesize() and scatter_node_data() should not be marked
as __meminit because they are needed after init, on any memory
hotplug event. Also, early_nr_cpus_node() is called by
compute_pernodesize(), so early_nr_cpus_node() cannot be __meminit either.

WARNING: modpost: vmlinux.o(.text.unlikely+0x1612): Section mismatch in reference from the function arch_alloc_nodedata() to the function .meminit.text:compute_pernodesize()
The function arch_alloc_nodedata() references
the function __meminit compute_pernodesize().
This is often because arch_alloc_nodedata lacks a __meminit
annotation or the annotation of compute_pernodesize is wrong.

WARNING: modpost: vmlinux.o(.text.unlikely+0x1692): Section mismatch in reference from the function arch_refresh_nodedata() to the function .meminit.text:scatter_node_data()
The function arch_refresh_nodedata() references
the function __meminit scatter_node_data().
This is often because arch_refresh_nodedata lacks a __meminit
annotation or the annotation of scatter_node_data is wrong.

WARNING: modpost: vmlinux.o(.text.unlikely+0x1502): Section mismatch in reference from the function compute_pernodesize() to the function .meminit.text:early_nr_cpus_node()
The function compute_pernodesize() references
the function __meminit early_nr_cpus_node().
This is often because compute_pernodesize lacks a __meminit 
annotation or the annotation of early_nr_cpus_node is wrong.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Mike Rapoport <rppt@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/mm/discontig.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- linux-next-20210409.orig/arch/ia64/mm/discontig.c
+++ linux-next-20210409/arch/ia64/mm/discontig.c
@@ -95,7 +95,7 @@ static int __init build_node_maps(unsign
  * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
  * called yet.  Note that node 0 will also count all non-existent cpus.
  */
-static int __meminit early_nr_cpus_node(int node)
+static int early_nr_cpus_node(int node)
 {
 	int cpu, n = 0;
 
@@ -110,7 +110,7 @@ static int __meminit early_nr_cpus_node(
  * compute_pernodesize - compute size of pernode data
  * @node: the node id.
  */
-static unsigned long __meminit compute_pernodesize(int node)
+static unsigned long compute_pernodesize(int node)
 {
 	unsigned long pernodesize = 0, cpus;
 
@@ -367,7 +367,7 @@ static void __init reserve_pernode_space
 	}
 }
 
-static void __meminit scatter_node_data(void)
+static void scatter_node_data(void)
 {
 	pg_data_t **dst;
 	int node;
