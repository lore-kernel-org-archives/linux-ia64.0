From: Russ Anderson <rja@sgi.com>
Date: Tue, 05 Oct 2004 19:20:59 +0000
Subject: Re: RFC - freeing up ar.k5
Message-Id: <200410051920.i95JKxi1064241@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
In-Reply-To: <200409162152.i8GLqwG01566@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> 
> >> Still not sure where to take this.  One suggestion I did get 
> >> was to use this as a proof of concept that ar.k5 could be freed
> >> up if some super wonderful application for a ar.k register comes
> >> along, so it's ok to use our last completely free register
> >> (ar.k3) for the INIT/MCA code.
> >
> >So which way should I go?
> >
> >I could build on the current ia64_mca_tlb_info structure and avoid
> >the cpu reg issue, or use ar.k3 for the INIT/MCA code.
> >
> >At this point I'm just interested in make some forward progress, so
> >either way is fine.
> 
> Luckily Linus just added "Documentation/ManagementStyle" to the source
> tree to help me through this.  Read it, it's pretty funny.
> 
> This looks like a decision that could be undone without too much
> pain later ... so I'll say "yes", let's use ar.k3 for the physical
> address of the percpu area as a "preliminary decision" ... if it turns
> out to be bad, then I'll admit to being a "nincompoop", and we'll add
> more loops looking for cr.lid in the ia64_mca_tlb_list[] to get ar.k3
> free again.

Instead of using ar.k3 for a pointer to MCA/INIT information,
does it make more sense to have ar.k3 be a pointer to the cpu_info
structure, and add to the cpu_info structure a pointer to the mca_cpu
structure?  The pointers would be physical addresses, so the assember
code could add offsets to get the correct fields.  This would add
only a little more complexity to access the mca data, but would
make it easier for other assembler code access to the cpu_info
structure.

The following patch shows the basic infrastructure:

------------------------------------------------------------------------
Index: linux/arch/ia64/kernel/setup.c
=================================--- linux.orig/arch/ia64/kernel/setup.c	2004-10-04 14:52:52.000000000 -0500
+++ linux/arch/ia64/kernel/setup.c	2004-10-04 14:55:39.000000000 -0500
@@ -610,6 +610,7 @@
 	 */
 	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info) - __per_cpu_start);
 	identify_cpu(cpu_info);
+	ia64_set_kr(IA64_KR_CPU_INFO, __pa(cpu_info));
 
 #ifdef CONFIG_MCKINLEY
 	{
Index: linux/include/asm-ia64/kregs.h
=================================--- linux.orig/include/asm-ia64/kregs.h	2004-10-04 14:53:01.000000000 -0500
+++ linux/include/asm-ia64/kregs.h	2004-10-04 14:55:45.000000000 -0500
@@ -14,6 +14,7 @@
  */
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
+#define IA64_KR_CPU_INFO	3	/* ar.k3: physical address of cpu_info struct  */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
 #define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
 #define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
Index: linux/include/asm-ia64/mca.h
=================================--- linux.orig/include/asm-ia64/mca.h	2004-10-04 10:01:39.000000000 -0500
+++ linux/include/asm-ia64/mca.h	2004-10-05 11:16:47.000000000 -0500
@@ -59,6 +59,19 @@
 	u64	pal_base;
 } ia64_mca_tlb_list[NR_CPUS];
 
+typedef struct ia64_mca_cpu_s {
+	u64	ptce_base;
+	u32	ptce_count[2];
+	u32	ptce_stride[2];
+	u64	pal_paddr;
+	u64	pal_base;
+	u64	ia64_mca_stack[1024] __attribute__((aligned(16)));
+	u64	ia64_mca_proc_state_dump[512];
+	u64	ia64_mca_bspstore[1024];
+	u64	ia64_mca_stackframe[32];
+	u64	ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
+} ia64_mca_cpu_t;
+
 /* Information maintained by the MC infrastructure */
 typedef struct ia64_mc_info_s {
 	u64		imi_mca_handler;
Index: linux/include/asm-ia64/processor.h
=================================--- linux.orig/include/asm-ia64/processor.h	2004-10-04 10:01:39.000000000 -0500
+++ linux/include/asm-ia64/processor.h	2004-10-05 11:12:49.000000000 -0500
@@ -171,6 +171,7 @@
 #ifdef CONFIG_NUMA
 	struct ia64_node_data *node_data;
 #endif
+	struct ia64_mca_cpu_s *ia64_mca_data;	/* prt to MCA/INIT handling info */
 };
 
 DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
Index: linux/arch/ia64/kernel/asm-offsets.c
=================================--- linux.orig/arch/ia64/kernel/asm-offsets.c	2004-10-04 10:01:25.000000000 -0500
+++ linux/arch/ia64/kernel/asm-offsets.c	2004-10-05 11:27:42.000000000 -0500
@@ -198,7 +198,15 @@
 #endif
 
 	BLANK();
+	/* used by arch/ia64/kernel/mca_asm.S */
 	DEFINE(IA64_MCA_TLB_INFO_SIZE, sizeof (struct ia64_mca_tlb_info));
+	DEFINE(IA64_CPUINFO_MCA_DATA, offsetof (struct cpuinfo_ia64, ia64_mca_data));
+	DEFINE(IA64_MCA_PROC_STATE_DUMP, offsetof (struct ia64_mca_cpu_s, ia64_mca_proc_state_dump));
+	DEFINE(IA64_MCA_STACK, offsetof (struct ia64_mca_cpu_s, ia64_mca_stack));
+	DEFINE(IA64_MCA_STACKFRAME, offsetof (struct ia64_mca_cpu_s, ia64_mca_stackframe));
+	DEFINE(IA64_MCA_BSPSTORE, offsetof (struct ia64_mca_cpu_s, ia64_mca_bspstore));
+	DEFINE(IA64_INIT_STACK, offsetof (struct ia64_mca_cpu_s, ia64_init_stack));
+
 	/* used by head.S */
 	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
 
------------------------------------------------------------------------


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
