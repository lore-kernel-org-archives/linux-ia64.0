From: Sam Ravnborg <sam@ravnborg.org>
Date: Mon, 30 Jul 2007 20:50:13 +0000
Subject: [PATCH v3] ia64: fix a few section mismatch warnings
Message-Id: <20070730205013.GA29894@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070728061551.GA21626@uranus.ravnborg.org> <617E1C2C70743745A92448908E030B2A0209C43A@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2A0209C43A@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Fix the following section mismatch warnings:

WARNING: vmlinux.o(.text+0x41902): Section mismatch: reference to .init.text:__alloc_bootmem (between 'ia64_mca_cpu_init' and 'ia64_do_tlb_purge')
WARNING: vmlinux.o(.text+0x49222): Section mismatch: reference to .init.text:__alloc_bootmem (between 'register_intr' and 'iosapic_register_intr')
WARNING: vmlinux.o(.text+0x62beb2): Section mismatch: reference to .init.text:__alloc_bootmem_node (between 'hubdev_init_node' and 'cnodeid_get_geoid')

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
This should be in line with your latest comments.
Notice I introduce use of ALIGN to make it more readable.
I actually made a smal .c program just to verify that the below
expression and ALIGN agreed on how to calculate the alignment.

	Sam

diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index 91e6dc1..f4bd285 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -560,7 +560,7 @@ iosapic_reassign_vector (int irq)
 	}
 }
 
-static struct iosapic_rte_info *iosapic_alloc_rte (void)
+static struct iosapic_rte_info * __init_refok iosapic_alloc_rte (void)
 {
 	int i;
 	struct iosapic_rte_info *rte;
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 4b5daa3..ff28620 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1750,8 +1750,17 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 	strncpy(p->comm, type, sizeof(p->comm)-1);
 }
 
-/* Do per-CPU MCA-related initialization.  */
+/* Caller prevents this from being called after init */
+static void * __init_refok mca_bootmem(void)
+{
+	void *p;
 
+	p = alloc_bootmem(sizeof(struct ia64_mca_cpu) * NR_CPUS +
+	                  KERNEL_STACK_SIZE);
+	return (void *)ALIGN((unsigned long)p, KERNEL_STACK_SIZE);
+}
+
+/* Do per-CPU MCA-related initialization.  */
 void __cpuinit
 ia64_mca_cpu_init(void *cpu_data)
 {
@@ -1763,11 +1772,7 @@ ia64_mca_cpu_init(void *cpu_data)
 		int cpu;
 
 		first_time = 0;
-		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
-					 * NR_CPUS + KERNEL_STACK_SIZE);
-		mca_data = (void *)(((unsigned long)mca_data +
-					KERNEL_STACK_SIZE - 1) &
-				(-KERNEL_STACK_SIZE));
+		mca_data = mca_bootmem();
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
 			format_mca_init_stack(mca_data,
 					offsetof(struct ia64_mca_cpu, mca_stack),
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
