From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 02:47:15 +0000
Subject: [patch] fix per-CPU MCA mess and make UP kernels work again
Message-Id: <16887.1203.470842.161249@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The per-CPU MCA support was in a mess: there was confusion as to
whether ar.k3 points to cpuinfo or the per-CPU area.  Apart from not
allocating the per-CPU MCA area for UP, I _think_ that's the main
reason UP didn't work.  The reason I say _think_ is that once I
started to look at the code more closely, there were so many things
wrong with it that it wasn't even funny.  Attached patch tries to
clean things up.

The patch has been compile- and boot-tested for zx1 UP and SMP.  I
think it should be OK for discontig configs, too, but I haven't tested
that (and if anybody wanted to build discontig for UP, then
discontig.c:per_cpu_init() would have to be updated like the contig.c
version.

Also, I verified that the kernel can still do an INIT dump.  Other
than that, I can't really test the MCA-path.

	--david

This patch cleans up the per-CPU MCA mess with the following changes
(and yields a UP kernel that actually boots again):

 - In percpu.h, make per_cpu_init() a function-call even for the
   UP case.
 - In contig.c, enable per_cpu_init() even for UP since we need to
   allocate the per-CPU MCA data in that case as well.
 - Move the MCA-related stuff out of the cpuinfo structure into
   per-CPU variables defined by mca.c.
 - Rename IA64_KR_PA_CPU_INFO to IA64_KR_PER_CPU_DATA, since it really
   is a per-CPU pointer now.
 - In mca.h, move IA64_MCA_STACK_SIZE early enough so it gets defined
   for assembly-code, too.  Tidy up struct ia64_mca_struct.  Add declaration
   of ia64_mca_cpu_init().
 - In mca_asm.[hS], replace various GET_*() macros with a single
   GET_PERCPU_ADDR() which loads the physical address of an
   arbitrary per-CPU variable.  Remove all dependencies on the
   layout of the cpuinfo structure.  Replace hardcoded stack-size
   with IA64_MCA_STACK_SIZE constant.  Replace hardcoded references
   to ar.k3 with IA64_KR(PER_CPU_DATA).
 - In setup.c:cpu_init(), initialize ar.k3 to be the physical equivalent
   of the per-CPU data pointer.
 - Nuke silly ia64_mca_cpu_t typedef and just use struct ia64_mca_cpu instead.
 - Move __per_cpu_mca[] from setup.c to mca.c.
 - Rename set_mca_pointer() to ia64_mca_cpu_init() and sanitize it.
 - Rename efi.c:pal_code_memdesc() to efi_get_pal_addr() and make it
   return the PAL address, rather than a memory-descriptor.
 - Make efi_map_pal_code() use efi_get_pal_addr().

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/asm-offsets.c 1.9 vs edited ==--- 1.9/arch/ia64/kernel/asm-offsets.c	2005-01-06 16:19:39 -08:00
+++ edited/arch/ia64/kernel/asm-offsets.c	2005-01-25 17:43:43 -08:00
@@ -193,9 +193,17 @@
 	DEFINE(IA64_CLONE_VM, CLONE_VM);
 
 	BLANK();
-	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
-	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
-
+	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET,
+	       offsetof (struct cpuinfo_ia64, nsec_per_cyc));
+	DEFINE(IA64_CPUINFO_PTCE_BASE_OFFSET,
+	       offsetof (struct cpuinfo_ia64, ptce_base));
+	DEFINE(IA64_CPUINFO_PTCE_COUNT_OFFSET,
+	       offsetof (struct cpuinfo_ia64, ptce_count));
+	DEFINE(IA64_CPUINFO_PTCE_STRIDE_OFFSET,
+	       offsetof (struct cpuinfo_ia64, ptce_stride));
+	BLANK();
+	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET,
+	       offsetof (struct timespec, tv_nsec));
 
 	DEFINE(CLONE_SETTLS_BIT, 19);
 #if CLONE_SETTLS != (1<<19)
@@ -203,19 +211,16 @@
 #endif
 
 	BLANK();
-	/* used by arch/ia64/kernel/mca_asm.S */
-	DEFINE(IA64_CPUINFO_PERCPU_PADDR, offsetof (struct cpuinfo_ia64, percpu_paddr));
-	DEFINE(IA64_CPUINFO_PAL_PADDR, offsetof (struct cpuinfo_ia64, pal_paddr));
-	DEFINE(IA64_CPUINFO_PA_MCA_INFO, offsetof (struct cpuinfo_ia64, ia64_pa_mca_data));
-	DEFINE(IA64_MCA_PROC_STATE_DUMP, offsetof (struct ia64_mca_cpu_s, ia64_mca_proc_state_dump));
-	DEFINE(IA64_MCA_STACK, offsetof (struct ia64_mca_cpu_s, ia64_mca_stack));
-	DEFINE(IA64_MCA_STACKFRAME, offsetof (struct ia64_mca_cpu_s, ia64_mca_stackframe));
-	DEFINE(IA64_MCA_BSPSTORE, offsetof (struct ia64_mca_cpu_s, ia64_mca_bspstore));
-	DEFINE(IA64_INIT_STACK, offsetof (struct ia64_mca_cpu_s, ia64_init_stack));
-
-	/* used by head.S */
-	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
-
+	DEFINE(IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET,
+	       offsetof (struct ia64_mca_cpu, proc_state_dump));
+	DEFINE(IA64_MCA_CPU_STACK_OFFSET,
+	       offsetof (struct ia64_mca_cpu, stack));
+	DEFINE(IA64_MCA_CPU_STACKFRAME_OFFSET,
+	       offsetof (struct ia64_mca_cpu, stackframe));
+	DEFINE(IA64_MCA_CPU_RBSTORE_OFFSET,
+	       offsetof (struct ia64_mca_cpu, rbstore));
+	DEFINE(IA64_MCA_CPU_INIT_STACK_OFFSET,
+	       offsetof (struct ia64_mca_cpu, init_stack));
 	BLANK();
 	/* used by fsys_gettimeofday in arch/ia64/kernel/fsys.S */
 	DEFINE(IA64_TIME_INTERPOLATOR_ADDRESS_OFFSET, offsetof (struct time_interpolator, addr));
=== arch/ia64/kernel/efi.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/efi.c	2005-01-22 15:59:24 -08:00
+++ edited/arch/ia64/kernel/efi.c	2005-01-25 17:51:59 -08:00
@@ -415,8 +415,8 @@
  * Abstraction Layer chapter 11 in ADAG
  */
 
-static efi_memory_desc_t *
-pal_code_memdesc (void)
+void *
+efi_get_pal_addr (void)
 {
 	void *efi_map_start, *efi_map_end, *p;
 	efi_memory_desc_t *md;
@@ -474,51 +474,31 @@
 			md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
 			vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 #endif
-		return md;
+		return __va(md->phys_addr);
 	}
-
+	printk(KERN_WARNING "%s: no PAL-code memory-descriptor found",
+	       __FUNCTION__);
 	return NULL;
 }
 
 void
-efi_get_pal_addr (void)
-{
-	efi_memory_desc_t *md = pal_code_memdesc();
-	u64 vaddr, mask;
-	struct cpuinfo_ia64 *cpuinfo;
-
-	if (md != NULL) {
-
-		vaddr = PAGE_OFFSET + md->phys_addr;
-		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
-
-		cpuinfo = (struct cpuinfo_ia64 *)__va(ia64_get_kr(IA64_KR_PA_CPU_INFO));
-		cpuinfo->pal_base = vaddr & mask;
-		cpuinfo->pal_paddr = pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL));
-	}
-}
-
-void
 efi_map_pal_code (void)
 {
-	efi_memory_desc_t *md = pal_code_memdesc();
-	u64 vaddr, mask, psr;
-
-	if (md != NULL) {
+	void *pal_vaddr = efi_get_pal_addr ();
+	u64 psr;
 
-		vaddr = PAGE_OFFSET + md->phys_addr;
-		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
+	if (!pal_vaddr)
+		return;
 
-		/*
-		 * Cannot write to CRx with PSR.ic=1
-		 */
-		psr = ia64_clear_ic();
-		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
-			pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
-			IA64_GRANULE_SHIFT);
-		ia64_set_psr(psr);		/* restore psr */
-		ia64_srlz_i();
-	}
+	/*
+	 * Cannot write to CRx with PSR.ic=1
+	 */
+	psr = ia64_clear_ic();
+	ia64_itr(0x1, IA64_TR_PALCODE, GRANULEROUNDDOWN((unsigned long) pal_vaddr),
+		 pte_val(pfn_pte(__pa(pal_vaddr) >> PAGE_SHIFT, PAGE_KERNEL)),
+		 IA64_GRANULE_SHIFT);
+	ia64_set_psr(psr);		/* restore psr */
+	ia64_srlz_i();
 }
 
 void __init
=== arch/ia64/kernel/mca.c 1.76 vs edited ==--- 1.76/arch/ia64/kernel/mca.c	2005-01-22 13:48:51 -08:00
+++ edited/arch/ia64/kernel/mca.c	2005-01-25 17:40:29 -08:00
@@ -67,6 +67,7 @@
 
 #include <asm/delay.h>
 #include <asm/machvec.h>
+#include <asm/meminit.h>
 #include <asm/page.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
@@ -86,6 +87,12 @@
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
 u64				ia64_mca_serialize;
+DEFINE_PER_CPU(u64, ia64_mca_data); /* = __per_cpu_mca[smp_processor_id()] */
+DEFINE_PER_CPU(u64, ia64_mca_per_cpu_pte); /* PTE to map per-CPU area */
+DEFINE_PER_CPU(u64, ia64_mca_pal_pte);	    /* PTE to map PAL code */
+DEFINE_PER_CPU(u64, ia64_mca_pal_base);    /* vaddr PAL code granule */
+
+unsigned long __per_cpu_mca[NR_CPUS];
 
 /* In mca_asm.S */
 extern void			ia64_monarch_init_handler (void);
@@ -1194,6 +1201,41 @@
 	.name =		"cpe_poll"
 };
 #endif /* CONFIG_ACPI */
+
+/* Do per-CPU MCA-related initialization.  */
+
+void __init
+ia64_mca_cpu_init(void *cpu_data)
+{
+	void *pal_vaddr;
+
+        /*
+         * The MCA info structure was allocated earlier and its
+         * physical address saved in __per_cpu_mca[cpu].  Copy that
+         * address * to ia64_mca_data so we can access it as a per-CPU
+         * variable.
+         */
+	__get_cpu_var(ia64_mca_data) = __per_cpu_mca[smp_processor_id()];
+
+	/*
+	 * Stash away a copy of the PTE needed to map the per-CPU page.
+	 * We may need it during MCA recovery.
+	 */
+	__get_cpu_var(ia64_mca_per_cpu_pte) +		pte_val(mk_pte_phys(__pa(cpu_data), PAGE_KERNEL));
+
+        /*
+         * Also, stash away a copy of the PAL address and the PTE
+         * needed to map it.
+         */
+        pal_vaddr = efi_get_pal_addr();
+	if (!pal_vaddr)
+		return;
+	__get_cpu_var(ia64_mca_pal_base) +		GRANULEROUNDDOWN((unsigned long) pal_vaddr);
+	__get_cpu_var(ia64_mca_pal_pte) = pte_val(mk_pte_phys(__pa(pal_vaddr),
+							      PAGE_KERNEL));
+}
 
 /*
  * ia64_mca_init
=== arch/ia64/kernel/mca_asm.S 1.17 vs edited ==--- 1.17/arch/ia64/kernel/mca_asm.S	2005-01-06 16:20:34 -08:00
+++ edited/arch/ia64/kernel/mca_asm.S	2005-01-25 17:29:10 -08:00
@@ -144,24 +144,26 @@
 	// The following code purges TC and TR entries. Then reload all TC entries.
 	// Purge percpu data TC entries.
 begin_tlb_purge_and_reload:
-	GET_PERCPU_PADDR(r2)	// paddr of percpu_paddr in cpuinfo struct
-	;;
-	mov	r17=r2
-	;;
-	adds r17=8,r17
+
+#define O(member)	IA64_CPUINFO_##member##_OFFSET
+
+	GET_THIS_PADDR(r2, cpu_info)	// load phys addr of cpu_info into r2
 	;;
-	ld8 r18=[r17],8		// r18=ptce_base
-  	;;
-	ld4 r19=[r17],4		// r19=ptce_count[0]
+	addl r17=O(PTCE_STRIDE),r2
+	addl r2=O(PTCE_BASE),r2
 	;;
-	ld4 r20=[r17],4		// r20=ptce_count[1]
+	ld8 r18=[r2],(O(PTCE_COUNT)-O(PTCE_BASE));;	// r18=ptce_base
+	ld4 r19=[r2],4					// r19=ptce_count[0]
+	ld4 r21=[r17],4					// r21=ptce_stride[0]
 	;;
-	ld4 r21=[r17],4		// r21=ptce_stride[0]
+	ld4 r20=[r2]					// r20=ptce_count[1]
+	ld4 r22=[r17]					// r22=ptce_stride[1]
 	mov r24=0
 	;;
-	ld4 r22=[r17],4		// r22=ptce_stride[1]
 	adds r20=-1,r20
 	;;
+#undef O
+
 2:
 	cmp.ltu p6,p7=r24,r19
 (p7)	br.cond.dpnt.few 4f
@@ -246,16 +248,15 @@
 	srlz.d
 	;;
 	// 2. Reload DTR register for PERCPU data.
-	GET_PERCPU_PADDR(r2)		// paddr of percpu_paddr in cpuinfo struct
+	GET_THIS_PADDR(r2, ia64_mca_per_cpu_pte)
 	;;
-	mov r17=r2
 	movl r16=PERCPU_ADDR		// vaddr
 	movl r18=PERCPU_PAGE_SHIFT<<2
 	;;
 	mov cr.itir=r18
 	mov cr.ifa=r16
 	;;
-	ld8 r18=[r17]			// pte
+	ld8 r18=[r2]			// load per-CPU PTE
 	mov r16=IA64_TR_PERCPU_DATA;
 	;;
 	itr.d dtr[r16]=r18
@@ -263,13 +264,13 @@
 	srlz.d
 	;;
 	// 3. Reload ITR for PAL code.
-	GET_CPUINFO_PAL_PADDR(r2)	// paddr of pal_paddr in cpuinfo struct
+	GET_THIS_PADDR(r2, ia64_mca_pal_pte)
 	;;
-	mov r17=r2
+	ld8 r18=[r2]			// load PAL PTE
 	;;
-	ld8 r18=[r17],8			// pte
+	GET_THIS_PADDR(r2, ia64_mca_pal_base)
 	;;
-	ld8 r16=[r17]			// vaddr
+	ld8 r16=[r2]			// load PAL vaddr
 	mov r19=IA64_GRANULE_SHIFT<<2
 	;;
 	mov cr.itir=r19
@@ -308,14 +309,18 @@
 done_tlb_purge_and_reload:
 
 	// Setup new stack frame for OS_MCA handling
-	GET_MCA_BSPSTORE(r2)		// paddr of bspstore save area
-	GET_MCA_STACKFRAME(r3);;	// paddr of stack frame save area
+	GET_THIS_PADDR(r2, ia64_mca_data)
+	;;
+	add r3 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
+	add r2 = IA64_MCA_CPU_RBSTORE_OFFSET, r2
+	;;
 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
-	GET_MCA_STACK(r2);;		// paddr of stack save area
-					// stack size must be same as C array
-	addl	r2=8*1024-16,r2;;	// stack base @ bottom of array
-	mov	r12=r2			// allow 16 bytes of scratch
-					// (C calling convention)
+
+	GET_THIS_PADDR(r2, ia64_mca_data)
+	;;
+	add r2 = IA64_MCA_CPU_STACK_OFFSET+IA64_MCA_STACK_SIZE-16, r2
+	;;
+	mov r12=r2		// establish new stack-pointer
 
         // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
@@ -331,7 +336,10 @@
 ia64_os_mca_virtual_end:
 
 	// restore the original stack frame here
-	GET_MCA_STACKFRAME(r2);;	// phys addr of MCA save area
+	GET_THIS_PADDR(r2, ia64_mca_data)
+	;;
+	add r2 = IA64_MCA_CPU_STACKFRAME_OFFSET, r2
+	;;
 	movl    r4=IA64_PSR_MC
 	;;
 	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
@@ -372,8 +380,10 @@
 ia64_os_mca_proc_state_dump:
 // Save bank 1 GRs 16-31 which will be used by c-language code when we switch
 //  to virtual addressing mode.
-	GET_MCA_DUMP_PADDR(r2);;  // phys addr of MCA save area
-
+	GET_THIS_PADDR(r2, ia64_mca_data)
+	;;
+	add r2 = IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
+	;;
 // save ar.NaT
 	mov		r5=ar.unat                  // ar.unat
 
@@ -603,7 +613,9 @@
 ia64_os_mca_proc_state_restore:
 
 // Restore bank1 GR16-31
-	GET_MCA_DUMP_PADDR(r2);;		// phys addr of proc state dump area
+	GET_THIS_PADDR(r2, ia64_mca_data)
+	;;
+	add r2 = IA64_MCA_CPU_PROC_STATE_DUMP_OFFSET, r2
 
 restore_GRs:                                    // restore bank-1 GRs 16-31
 	bsw.1;;
=== arch/ia64/kernel/minstate.h 1.18 vs edited ==--- 1.18/arch/ia64/kernel/minstate.h	2004-12-10 13:31:49 -08:00
+++ edited/arch/ia64/kernel/minstate.h	2005-01-25 17:51:22 -08:00
@@ -37,10 +37,10 @@
  * go virtual and don't want to destroy the iip or ipsr.
  */
 #define MINSTATE_START_SAVE_MIN_PHYS								\
-(pKStk) mov r3=ar.k3;;										\
-(pKStk) addl r3=IA64_CPUINFO_PA_MCA_INFO,r3;;							\
+(pKStk) mov r3=IA64_KR(PER_CPU_DATA);;								\
+(pKStk) addl r3=THIS_CPU(ia64_mca_data),r3;;							\
 (pKStk) ld8 r3 = [r3];;										\
-(pKStk) addl r3=IA64_INIT_STACK,r3;;								\
+(pKStk) addl r3=IA64_MCA_CPU_INIT_STACK_OFFSET,r3;;						\
 (pKStk) addl sp=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r3;						\
 (pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
 (pUStk)	addl r22=IA64_RBS_OFFSET,r1;		/* compute base of register backing store */	\
=== arch/ia64/kernel/setup.c 1.86 vs edited ==--- 1.86/arch/ia64/kernel/setup.c	2005-01-24 13:41:13 -08:00
+++ edited/arch/ia64/kernel/setup.c	2005-01-25 18:12:20 -08:00
@@ -60,7 +60,6 @@
 unsigned long __per_cpu_offset[NR_CPUS];
 EXPORT_SYMBOL(__per_cpu_offset);
 #endif
-unsigned long __per_cpu_mca[NR_CPUS];
 
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
@@ -388,7 +387,7 @@
 	/* enable IA-64 Machine Check Abort Handling unless disabled */
 	if (!strstr(saved_command_line, "nomca"))
 		ia64_mca_init();
-	
+
 	platform_setup(cmdline_p);
 	paging_init();
 }
@@ -602,7 +601,6 @@
 cpu_init (void)
 {
 	extern void __devinit ia64_mmu_init (void *);
-	extern void set_mca_pointer (struct cpuinfo_ia64 *, void *);
 	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
@@ -611,6 +609,8 @@
 
 	cpu_data = per_cpu_init();
 
+	ia64_set_kr(IA64_KR_PER_CPU_DATA, __pa(cpu_data - (void *) __per_cpu_start));
+
 	get_max_cacheline_size();
 
 	/*
@@ -657,7 +657,7 @@
 		BUG();
 
 	ia64_mmu_init(ia64_imva(cpu_data));
-	set_mca_pointer(cpu_info, cpu_data);
+	ia64_mca_cpu_init(ia64_imva(cpu_data));
 
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_cpu_init();
=== arch/ia64/mm/contig.c 1.12 vs edited ==--- 1.12/arch/ia64/mm/contig.c	2005-01-18 15:21:57 -08:00
+++ edited/arch/ia64/mm/contig.c	2005-01-25 18:06:34 -08:00
@@ -169,7 +169,6 @@
 	find_initrd();
 }
 
-#ifdef CONFIG_SMP
 /**
  * per_cpu_init - setup per-cpu variables
  *
@@ -178,30 +177,41 @@
 void *
 per_cpu_init (void)
 {
-	void *cpu_data, *mca_data;
+	void *mca_data, *my_data;
 	int cpu;
 
+#ifdef CONFIG_SMP
 	/*
 	 * get_free_pages() cannot be used before cpu_init() done.  BSP
 	 * allocates "NR_CPUS" pages for all CPUs to avoid that AP calls
 	 * get_zeroed_page().
 	 */
 	if (smp_processor_id() = 0) {
+		void *cpu_data;
+
 		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
 					   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
-		mca_data = alloc_bootmem(PERCPU_MCA_SIZE * NR_CPUS);
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
 			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
 			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
 			cpu_data += PERCPU_PAGE_SIZE;
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
-			__per_cpu_mca[cpu] = (unsigned long)__pa(mca_data);
-			mca_data += PERCPU_MCA_SIZE;
 		}
 	}
-	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+	my_data = __per_cpu_start + __per_cpu_offset[smp_processor_id()];
+#else
+	my_data = (void *) __phys_per_cpu_start;
+#endif
+
+	if (smp_processor_id() = 0) {
+		mca_data = alloc_bootmem(sizeof (struct ia64_mca_cpu) * NR_CPUS);
+		for (cpu = 0; cpu < NR_CPUS; cpu++) {
+			__per_cpu_mca[cpu] = __pa(mca_data);
+			mca_data += sizeof (struct ia64_mca_cpu);
+		}
+	}
+	return my_data;
 }
-#endif /* CONFIG_SMP */
 
 static int
 count_pages (u64 start, u64 end, void *arg)
=== arch/ia64/mm/discontig.c 1.28 vs edited ==--- 1.28/arch/ia64/mm/discontig.c	2005-01-18 12:06:18 -08:00
+++ edited/arch/ia64/mm/discontig.c	2005-01-25 16:06:58 -08:00
@@ -339,7 +339,7 @@
 	pernodesize += node * L1_CACHE_BYTES;
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
-	pernodesize += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
+	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_mca_cpu)) * phys_cpus;
 	pernodesize = PAGE_ALIGN(pernodesize);
 	pernode = NODEDATA_ALIGN(start, node);
 
@@ -363,7 +363,7 @@
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
 		mca_data_phys = (void *)pernode;
-		pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
+		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_mca_cpu)) * phys_cpus;
 
 		/*
 		 * Copy the static per-cpu data into the region we
@@ -384,7 +384,7 @@
 					 * will be put in the cpuinfo structure.
 					 */
 					__per_cpu_mca[cpu] = __pa(mca_data_phys);
-					mca_data_phys += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t));
+					mca_data_phys += L1_CACHE_ALIGN(sizeof(struct ia64_mca_cpu));
 				}
 				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
 					__per_cpu_start;
=== arch/ia64/mm/init.c 1.76 vs edited ==--- 1.76/arch/ia64/mm/init.c	2005-01-18 12:06:18 -08:00
+++ edited/arch/ia64/mm/init.c	2005-01-25 15:52:22 -08:00
@@ -40,7 +40,6 @@
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
 extern void ia64_tlb_init (void);
-extern void efi_get_pal_addr (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
@@ -290,27 +289,6 @@
 	put_kernel_page(page, GATE_ADDR + PERCPU_PAGE_SIZE, PAGE_GATE);
 #endif
 	ia64_patch_gate();
-}
-
-void
-set_mca_pointer(struct cpuinfo_ia64 *cpuinfo, void *cpu_data)
-{
-	void *my_cpu_data = ia64_imva(cpu_data);
-
-        /*
-         * The MCA info structure was allocated earlier and a physical address pointer
-         * saved in __per_cpu_mca[cpu].  Move that pointer into the cpuinfo structure.
-         */
-
-        cpuinfo->ia64_pa_mca_data = (__u64 *)__per_cpu_mca[smp_processor_id()];
-
-        cpuinfo->percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
-        ia64_set_kr(IA64_KR_PA_CPU_INFO, __pa(cpuinfo));
-
-        /*
-         * Set pal_base and pal_paddr in cpuinfo structure.
-         */
-        efi_get_pal_addr();
 }
 
 void __devinit
=== include/asm-ia64/kregs.h 1.7 vs edited ==--- 1.7/include/asm-ia64/kregs.h	2004-12-10 13:25:43 -08:00
+++ edited/include/asm-ia64/kregs.h	2005-01-25 16:52:05 -08:00
@@ -14,7 +14,7 @@
  */
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
-#define IA64_KR_PA_CPU_INFO	3	/* ar.k3: phys addr of this cpu's cpu_info struct */
+#define IA64_KR_PER_CPU_DATA	3	/* ar.k3: physical per-CPU base */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
 #define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
 #define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
=== include/asm-ia64/mca.h 1.22 vs edited ==--- 1.22/include/asm-ia64/mca.h	2005-01-07 13:54:29 -08:00
+++ edited/include/asm-ia64/mca.h	2005-01-25 17:23:08 -08:00
@@ -11,6 +11,8 @@
 #ifndef _ASM_IA64_MCA_H
 #define _ASM_IA64_MCA_H
 
+#define IA64_MCA_STACK_SIZE	8192
+
 #if !defined(__ASSEMBLY__)
 
 #include <linux/interrupt.h>
@@ -102,21 +104,21 @@
 						 */
 } ia64_mca_os_to_sal_state_t;
 
-#define IA64_MCA_STACK_SIZE 	1024
-#define IA64_MCA_STACK_SIZE_BYTES 	(1024 * 8)
-#define IA64_MCA_BSPSTORE_SIZE 	1024
-
-typedef struct ia64_mca_cpu_s {
-	u64	ia64_mca_stack[IA64_MCA_STACK_SIZE] 		__attribute__((aligned(16)));
-	u64	ia64_mca_proc_state_dump[512]			__attribute__((aligned(16)));
-	u64	ia64_mca_stackframe[32]				__attribute__((aligned(16)));
-	u64	ia64_mca_bspstore[IA64_MCA_BSPSTORE_SIZE]	__attribute__((aligned(16)));
-	u64	ia64_init_stack[KERNEL_STACK_SIZE/8] 		__attribute__((aligned(16)));
-} ia64_mca_cpu_t;
+/* Per-CPU MCA state that is too big for normal per-CPU variables.  */
+
+struct ia64_mca_cpu {
+	u64 stack[IA64_MCA_STACK_SIZE/8];	/* MCA memory-stack */
+	u64 proc_state_dump[512];
+	u64 stackframe[32];
+	u64 rbstore[IA64_MCA_STACK_SIZE/8];	/* MCA reg.-backing store */
+	u64 init_stack[KERNEL_STACK_SIZE/8];
+} __attribute__ ((aligned(16)));
 
-#define PERCPU_MCA_SIZE sizeof(ia64_mca_cpu_t)
+/* Array of physical addresses of each CPU's MCA area.  */
+extern unsigned long __per_cpu_mca[NR_CPUS];
 
 extern void ia64_mca_init(void);
+extern void ia64_mca_cpu_init(void *);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);
 extern void ia64_mca_ucmc_handler(void);
=== include/asm-ia64/mca_asm.h 1.11 vs edited ==--- 1.11/include/asm-ia64/mca_asm.h	2005-01-06 16:22:36 -08:00
+++ edited/include/asm-ia64/mca_asm.h	2005-01-25 17:42:30 -08:00
@@ -46,40 +46,9 @@
 	mov	temp	= 0x7	;;							\
 	dep	addr	= temp, addr, 61, 3
 
-/*
- * This macro gets the physical address of this cpu's cpuinfo structure.
- */
-#define GET_PERCPU_PADDR(reg)							\
-	mov	reg	= ar.k3;;						\
-	addl	reg	= IA64_CPUINFO_PERCPU_PADDR,reg
-
-#define GET_CPUINFO_PAL_PADDR(reg)						\
-	mov	reg	= ar.k3;;						\
-	addl	reg	= IA64_CPUINFO_PAL_PADDR,reg
-
-/*
- * This macro gets the physical address of this cpu's MCA save structure.
- */
-#define GET_CPUINFO_MCA_PADDR(reg)						\
-	mov	reg	= ar.k3;;						\
-	addl	reg	= IA64_CPUINFO_PA_MCA_INFO,reg;;			\
-	ld8	reg	= [reg]
-
-#define	GET_MCA_BSPSTORE(reg)							\
-	GET_CPUINFO_MCA_PADDR(reg);;						\
-	addl	reg	= IA64_MCA_BSPSTORE,reg
-
-#define	GET_MCA_STACKFRAME(reg)							\
-	GET_CPUINFO_MCA_PADDR(reg);;						\
-	addl	reg	= IA64_MCA_STACKFRAME,reg
-
-#define	GET_MCA_STACK(reg)							\
-	GET_CPUINFO_MCA_PADDR(reg);;						\
-	addl	reg	= IA64_MCA_STACK,reg
-
-#define	GET_MCA_DUMP_PADDR(reg)							\
-	GET_CPUINFO_MCA_PADDR(reg);;						\
-	addl	reg	= IA64_MCA_PROC_STATE_DUMP,reg
+#define GET_THIS_PADDR(reg, var)		\
+	mov	reg = IA64_KR(PER_CPU_DATA);;	\
+        addl	reg = THIS_CPU(var), reg
 
 /*
  * This macro jumps to the instruction at the given virtual address
=== include/asm-ia64/percpu.h 1.15 vs edited ==--- 1.15/include/asm-ia64/percpu.h	2005-01-06 16:23:02 -08:00
+++ edited/include/asm-ia64/percpu.h	2005-01-25 16:34:57 -08:00
@@ -46,18 +46,14 @@
 
 extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
 extern void setup_per_cpu_areas (void);
-extern void *per_cpu_init(void);
 
 #else /* ! SMP */
 
 #define per_cpu(var, cpu)			(*((void)cpu, &per_cpu__##var))
 #define __get_cpu_var(var)			per_cpu__##var
-#define per_cpu_init()				(__phys_per_cpu_start)
 
 #endif	/* SMP */
 
-extern unsigned long __per_cpu_mca[NR_CPUS];
-
 #define EXPORT_PER_CPU_SYMBOL(var)		EXPORT_SYMBOL(per_cpu__##var)
 #define EXPORT_PER_CPU_SYMBOL_GPL(var)		EXPORT_SYMBOL_GPL(per_cpu__##var)
 
@@ -68,6 +64,8 @@
  * more efficient.
  */
 #define __ia64_per_cpu_var(var)	(per_cpu__##var)
+
+extern void *per_cpu_init(void);
 
 #endif /* !__ASSEMBLY__ */
 
=== include/asm-ia64/processor.h 1.71 vs edited ==--- 1.71/include/asm-ia64/processor.h	2004-12-10 13:24:20 -08:00
+++ edited/include/asm-ia64/processor.h	2005-01-25 17:10:56 -08:00
@@ -151,12 +151,9 @@
 	__u64 itc_freq;		/* frequency of ITC counter */
 	__u64 proc_freq;	/* frequency of processor */
 	__u64 cyc_per_usec;	/* itc_freq/1000000 */
-	__u64 percpu_paddr;
 	__u64 ptce_base;
 	__u32 ptce_count[2];
 	__u32 ptce_stride[2];
-	__u64 pal_paddr;
-	__u64 pal_base;
 	struct task_struct *ksoftirqd;	/* kernel softirq daemon for this CPU */
 
 #ifdef CONFIG_SMP
@@ -177,7 +174,6 @@
 #ifdef CONFIG_NUMA
 	struct ia64_node_data *node_data;
 #endif
-	__u64 *ia64_pa_mca_data;	/* prt to MCA/INIT processor state */
 };
 
 DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
=== include/linux/efi.h 1.13 vs edited ==--- 1.13/include/linux/efi.h	2005-01-22 14:43:57 -08:00
+++ edited/include/linux/efi.h	2005-01-25 15:51:11 -08:00
@@ -289,6 +289,7 @@
 }
 
 extern void efi_init (void);
+extern void *efi_get_pal_addr (void);
 extern void efi_map_pal_code (void);
 extern void efi_map_memmap(void);
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
