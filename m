From: Keith Owens <kaos@sgi.com>
Date: Wed, 24 Nov 2004 02:41:44 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <8152.1101264104@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Nov 2004 17:36:41 -0600 (CST), 
Russ Anderson <rja@sgi.com> wrote:
>--- tonyluck2.6.10.new.orig/linux/arch/ia64/kernel/mca_asm.S	2004-11-17 16:22:30.041624520 -0600
>+++ tonyluck2.6.10.new/linux/arch/ia64/kernel/mca_asm.S	2004-11-23 13:49:27.631179608 -0600
>@@ -318,17 +304,21 @@
> done_tlb_purge_and_reload:
> 
> 	// Setup new stack frame for OS_MCA handling
>-	movl	r2=ia64_mca_bspstore;;	// local bspstore area location in r2
>-	DATA_VA_TO_PA(r2);;
>-	movl	r3=ia64_mca_stackframe;; // save stack frame to memory in r3
>-	DATA_VA_TO_PA(r3);;
>+	mov	r3=ar.k3;;		// phys addr of cpuinfo struct
>+	addl	r3=IA64_CPUINFO_PA_MCA_INFO,r3;;	// phys addr pointer to MCA save area
>+	ld8	r2=[r3];;		// phys addr of MCA save area
>+	mov	r12=r2;;		// save phys addr
>+	addl	r3=IA64_MCA_STACKFRAME,r2;; // save stack frame to memory in r3
>+	addl	r2=IA64_MCA_BSPSTORE,r2;;   // local bspstore area location in r2

Nitpick - mov r12=r2 and addl r3=IA64_MCA_STACKFRAME,r2 do not need
stop bits, they can be in the same instruction group as
addl r2=IA64_MCA_BSPSTORE,r2;;.  From ia64 arch volume 1.

"Within an instruction group, every instruction will behave as though
its read of the register state occurred before the update of the
register state by any instruction (prior or later) in that instruction
group, except as noted in the Register dependencies and Memory
dependencies described below."

> 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
>-	movl	r12=ia64_mca_stack
>+
>+	mov	r2=r12;;		// phys addr of MCA save area
>+	addl	r2=IA64_MCA_STACK,r2;;
>+	mov	r12=r2
> 	mov	r2=8*1024;;		// stack size must be same as C array
> 	add	r12=r2,r12;;		// stack base @ bottom of array
> 	adds	r12=-16,r12;;		// allow 16 bytes of scratch
> 					// (C calling convention)

Replace with mov r2=IA64_MCA_STACK+8*1024-16;; add r12=r12,r2;; plus suitable comments.

>Index: tonyluck2.6.10.new/linux/arch/ia64/mm/init.c
>=================================>--- tonyluck2.6.10.new.orig/linux/arch/ia64/mm/init.c	2004-11-17 16:22:30.049436185 -0600
>+++ tonyluck2.6.10.new/linux/arch/ia64/mm/init.c	2004-11-23 10:52:18.601265188 -0600
>@@ -279,7 +279,7 @@
> {
> 	unsigned long psr, pta, impl_va_bits;
> 	extern void __devinit tlb_init (void);
>-	int cpu;
>+	struct cpuinfo_ia64 *cpuinfo;
> 
> #ifdef CONFIG_DISABLE_VHPT
> #	define VHPT_ENABLE_BIT	0
>@@ -345,19 +345,14 @@
> 	ia64_srlz_d();
> #endif
> 
>-	cpu = smp_processor_id();
>-
>-	/* mca handler uses cr.lid as key to pick the right entry */
>-	ia64_mca_tlb_list[cpu].cr_lid = ia64_getreg(_IA64_REG_CR_LID);
>-
>-	/* insert this percpu data information into our list for MCA recovery purposes */
>-	ia64_mca_tlb_list[cpu].percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
>-	/* Also save per-cpu tlb flush recipe for use in physical mode mca handler */
>-	ia64_mca_tlb_list[cpu].ptce_base = local_cpu_data->ptce_base;
>-	ia64_mca_tlb_list[cpu].ptce_count[0] = local_cpu_data->ptce_count[0];
>-	ia64_mca_tlb_list[cpu].ptce_count[1] = local_cpu_data->ptce_count[1];
>-	ia64_mca_tlb_list[cpu].ptce_stride[0] = local_cpu_data->ptce_stride[0];
>-	ia64_mca_tlb_list[cpu].ptce_stride[1] = local_cpu_data->ptce_stride[1];
>+	/*
>+	 * The MCA info structure was allocated earlier and a physical address pointer
>+	 * saved in k3.  Move that pointer into the cpuinfo structure and save
>+	 * the physcial address of the cpuinfo structure in k3.
               ^^^^^^^^
May as well head the spelling police off at the pass ;)

>+	 */
>+	cpuinfo = (struct cpuinfo_ia64 *)my_cpu_data;
>+	cpuinfo->ia64_pa_mca_data = (__u64 *)ia64_get_kr(IA64_KR_PA_CPU_INFO);
>+	ia64_set_kr(IA64_KR_PA_CPU_INFO, __pa(my_cpu_data));

Do we need a stop bit between ia64_get_kr(IA64_KR_PA_CPU_INFO) and
ia64_set_kr(IA64_KR_PA_CPU_INFO)?

