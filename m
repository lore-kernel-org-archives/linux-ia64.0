From: Sam Ravnborg <sam@ravnborg.org>
Date: Fri, 27 Jul 2007 07:44:13 +0000
Subject: Re: [PATCH] ia64: fix a few section mismatch warnings
Message-Id: <20070727074413.GA11424@uranus.ravnborg.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070726210141.GA7266@uranus.ravnborg.org>
In-Reply-To: <20070726210141.GA7266@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Fix the following section mismatch warnings:

WARNING: vmlinux.o(.text+0x41902): Section mismatch: reference to .init.text:__alloc_bootmem (between 'ia64_mca_cpu_init' and 'ia64_do_tlb_purge')
WARNING: vmlinux.o(.text+0x49222): Section mismatch: reference to .init.text:__alloc_bootmem (between 'register_intr' and 'iosapic_register_intr')
WARNING: vmlinux.o(.text+0x62beb2): Section mismatch: reference to .init.text:__alloc_bootmem_node (between 'hubdev_init_node' and 'cnodeid_get_geoid')

For ithe first warning a helper function marked __init_refok was used.
For the last warning a missing __init annotation was added.

Signed-off-by: Sam Ravnborg <sam@ravnborg.org>
---
Updated - inspired by comments from Al Viro.

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
index 4b5daa3..8b7681b 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1751,6 +1751,10 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 }
 
 /* Do per-CPU MCA-related initialization.  */
+static void * __init_refok mca_bootmem(unsigned long size)
+{
+	return alloc_bootmem(size * sizeof(struct ia64_mca_cpu));
+}
 
 void __cpuinit
 ia64_mca_cpu_init(void *cpu_data)
@@ -1763,8 +1767,7 @@ ia64_mca_cpu_init(void *cpu_data)
 		int cpu;
 
 		first_time = 0;
-		mca_data = alloc_bootmem(sizeof(struct ia64_mca_cpu)
-					 * NR_CPUS + KERNEL_STACK_SIZE);
+		mca_data = mca_bootmem(NR_CPUS + KERNEL_STACK_SIZE);
 		mca_data = (void *)(((unsigned long)mca_data +
 					KERNEL_STACK_SIZE - 1) &
 				(-KERNEL_STACK_SIZE));
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
