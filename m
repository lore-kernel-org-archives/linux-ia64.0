From: Russ Anderson <rja@sgi.com>
Date: Tue, 14 Sep 2004 15:30:44 +0000
Subject: Re: [Patch] Per CPU MCA/INIT data save areas
Message-Id: <200409141530.i8EFUiF9028071@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
In-Reply-To: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Thanks for the response.  Some comments below...

Takao Indoh wrote:
> On Tue, 31 Aug 2004 16:12:25 -0500 (CDT), Russ Anderson wrote:
> >
> >This is a patch to create per cpu MCA/INIT data save areas.
> >
> >Signed-off-by: Russ Anderson <rja@sgi.com>
> >
> >High level description:
> >
> >  Linux currently has one MCA & INIT save area for saving
> >  stack and other data.  This patch creates per cpu MCA/INIT 
> >  save areas, so that each cpu can save its own MCA & INIT stack 
> >  data.
> >
> >  The per MCA/INIT save areas replace the global areas defined
> >  in arch/ia64/kernel/mca.c for MCA processor state dump, 
> >  MCA stack, MCA stack frame, INIT stack, and MCA bspstore.
> >
> >  The code to access those save areas is updated to use the
> >  per cpu save areas.
> >
> >  No changes are made to the MCA flow, ie all the old locks
> >  are still in place.  The point of this patch is to establish
> >  the per cpu save areas.  Additional usage of the save areas,
> >  such as enabling concurrent INIT or MCA handling, will be
> >  the subject of other patches.
> >
> 
> 
> I am interested in INIT stack improvement and tried your patch, but
> it didn't work. I reviewed the patch and found some bugs. After I fixed
> them, your patch seemed to work correctly.
> I corrected the following two parts.
> 
> 1) MINSTATE_START_SAVE_MIN_PHYS
> 
> THIS_CPU(cpu_info) is insufficient.

You are correct. 

>                                      We need to find appropriate
> address of cpu_info structure for each cpu using thread_info->cpu

That was my intent...

> and __per_cpu_offset like this:
> 
> 	THIS_CPU(cpu_info) + __per_cpu_offset[cpu];
> 
> BTW, I used tpa to get physical address, but I am not sure TLB is valid 
> in the OS_INIT. tpa is available?

There may not be a valid TLB.  That's why DATA_VA_TO_PA() cannot be used
in the OS_MCA path.  LOAD_PHYSICAL() is used instead (in the original MCA code).  
I'm not sure if LOAD_PHYSICAL() is sufficient either in this context (but that 
may just be my lack of understanding).

> 2) find_pernode_space()
> 
> cpu_data points the address of the top of per_cpu area, not cpuinfo_ia64
> structure. Therefore,
> 
> 	cpuinfo = (struct cpuinfo_ia64 *)cpu_data;
> 
> This has to be fixed as follows.
> 
> 	cpuinfo = (struct cpuinfo_ia64 *)(__va(cpu_data) +
> 	    ((char *)&per_cpu__cpu_info - __per_cpu_start));
> 
> In your patch, ia64_mca_data is set if ((cpu = 0) ||
> (node_cpuid[cpu].phys_id > 0)) is true.
> I don't know what "node_cpuid[cpu].phys_id" is, but I found that it is
> initialized at acpi_boot_init(). find_pernode_space() is called earlier
> than acpi_boot_init(), so this condition always returns false except
> cpu0.

The intent is to allocate MCA save space only for CPUs that physically
exist.  The discontig code currently allocates cpu_info structures for all non-existent
CPUs in the system (with the structures allocated on node 0).  This is because
there is other code that goes from 0 to NR_CPUS.  If there is no cpu_info
structure allocated for no existent CPUs, the kernel will panic.  One could
argue that the other code should get fixed to only access cpu_info structures
for CPUs that actually exists, but that is a fix beyond the scope of my change.

To work around that problem, and avoid allocating MCA save areas for non-existent
CPUS, I added the node_cpuid[cpu].phys_id check.  It works correctly on SGI Altix.

>         Therefore, I remove this condition. (But this may be dependent on kernel
> configuration.)

I suspect that the result is allocating MCA save areas for all NR_CPUS.

> This is a patch I updated. I reviewed only the INIT code, so there may be
> some bugs in MCA code.
> 
> Best Regards,
> Takao Indoh
> 
> 
> diff -Nur linux-2.6.8.1.org/arch/ia64/kernel/asm-offsets.c linux-2.6.8.1/arch/ia64/kernel/asm-offsets.c
> --- linux-2.6.8.1.org/arch/ia64/kernel/asm-offsets.c	2004-09-14 15:15:40.878796742 +0900
> +++ linux-2.6.8.1/arch/ia64/kernel/asm-offsets.c	2004-09-13 16:29:04.000000000 +0900
> @@ -45,6 +45,7 @@
>  	DEFINE(IA64_TASK_TGID_OFFSET, offsetof (struct task_struct, tgid));
>  	DEFINE(IA64_TASK_THREAD_KSP_OFFSET, offsetof (struct task_struct, thread.ksp));
>  	DEFINE(IA64_TASK_THREAD_ON_USTACK_OFFSET, offsetof (struct task_struct, thread.on_ustack));
> +	DEFINE(IA64_THREAD_INFO_CPU_OFFSET, offsetof (struct thread_info, cpu));
>  
>  	BLANK();
>  
> @@ -194,6 +195,13 @@
>  	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
>  	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
>  
> +    /* used by arch/ia64/kernel/mca_asm.S */
> +	DEFINE(IA64_CPUINFO_MCA_DATA, offsetof (struct cpuinfo_ia64, ia64_mca_data));
> +	DEFINE(IA64_MCA_PROC_STATE_DUMP, offsetof (struct ia64_mca_cpu_s, ia64_mca_proc_state_dump));
> +	DEFINE(IA64_MCA_STACK, offsetof (struct ia64_mca_cpu_s, ia64_mca_stack));
> +	DEFINE(IA64_MCA_STACKFRAME, offsetof (struct ia64_mca_cpu_s, ia64_mca_stackframe));
> +	DEFINE(IA64_MCA_BSPSTORE, offsetof (struct ia64_mca_cpu_s, ia64_mca_bspstore));
> +	DEFINE(IA64_INIT_STACK, offsetof (struct ia64_mca_cpu_s, ia64_init_stack));
>  
>  	DEFINE(CLONE_IDLETASK_BIT, 12);
>  #if CLONE_IDLETASK != (1 << 12)
> diff -Nur linux-2.6.8.1.org/arch/ia64/kernel/mca.c linux-2.6.8.1/arch/ia64/kernel/mca.c
> --- linux-2.6.8.1.org/arch/ia64/kernel/mca.c	2004-09-14 15:15:40.875867055 +0900
> +++ linux-2.6.8.1/arch/ia64/kernel/mca.c	2004-09-14 14:50:29.537018381 +0900
> @@ -3,6 +3,9 @@
>   * Purpose:	Generic MCA handling layer
>   *
>   * Updated for latest kernel
> + * Copyright (C) 2004 Silicon Graphics, Inc
> + *	Russ Anderson <rja@sgi.com>
> + *
>   * Copyright (C) 2003 Hewlett-Packard Co
>   *	David Mosberger-Tang <davidm@hpl.hp.com>
>   *
> @@ -90,11 +93,6 @@
>  /* Used by mca_asm.S */
>  ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
>  ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
> -u64				ia64_mca_proc_state_dump[512];
> -u64				ia64_mca_stack[1024] __attribute__((aligned(16)));
> -u64				ia64_mca_stackframe[32];
> -u64				ia64_mca_bspstore[1024];
> -u64				ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
>  u64				ia64_mca_serialize;
>  
>  /* In mca_asm.S */
> diff -Nur linux-2.6.8.1.org/arch/ia64/kernel/mca_asm.S linux-2.6.8.1/arch/ia64/kernel/mca_asm.S
> --- linux-2.6.8.1.org/arch/ia64/kernel/mca_asm.S	2004-09-14 15:15:40.877820180 +0900
> +++ linux-2.6.8.1/arch/ia64/kernel/mca_asm.S	2004-09-13 14:08:18.000000000 +0900
> @@ -1,6 +1,9 @@
>  //
>  // assembly portion of the IA64 MCA handling
>  //
> +// 04/08/27 Russ Anderson <rja@sgi.com>
> +//		   Added per cpu MCA/INIT stack save areas.
> +//
>  // Mods by cfleck to integrate into kernel build
>  // 00/03/15 davidm Added various stop bits to get a clean compile
>  //
> @@ -102,11 +105,6 @@
>  	.global ia64_os_mca_dispatch_end
>  	.global ia64_sal_to_os_handoff_state
>  	.global	ia64_os_to_sal_handoff_state
> -	.global	ia64_mca_proc_state_dump
> -	.global	ia64_mca_stack
> -	.global	ia64_mca_stackframe
> -	.global	ia64_mca_bspstore
> -	.global ia64_init_stack
>  
>  	.text
>  	.align 16
> @@ -318,17 +316,17 @@
>  done_tlb_purge_and_reload:
>  
>  	// Setup new stack frame for OS_MCA handling
> -	movl	r2=ia64_mca_bspstore;;	// local bspstore area location in r2
> -	DATA_VA_TO_PA(r2);;
> -	movl	r3=ia64_mca_stackframe;; // save stack frame to memory in r3
> -	DATA_VA_TO_PA(r3);;
> +	addl	r2 = THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA,r0;;
> +	ld8	r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
> +	addl	r3 = IA64_MCA_STACKFRAME, r2
> +	addl	r12 = IA64_MCA_STACK, r2
> +	addl	r2 = IA64_MCA_BSPSTORE, r2;;
> +
>  	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
> -	movl	r12=ia64_mca_stack
>  	mov	r2=8*1024;;		// stack size must be same as C array
>  	add	r12=r2,r12;;		// stack base @ bottom of array
>  	adds	r12=-16,r12;;		// allow 16 bytes of scratch
>  					// (C calling convention)
> -	DATA_VA_TO_PA(r12);;
>  
>          // Enter virtual mode from physical mode
>  	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
> @@ -344,9 +342,9 @@
>  ia64_os_mca_virtual_end:
>  
>  	// restore the original stack frame here
> -	movl    r2=ia64_mca_stackframe	// restore stack frame from memory at r2
> -	;;
> -	DATA_VA_TO_PA(r2)
> +	addl	r2 = THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA,r0;;
> +	ld8	r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
> +	addl	r2 = IA64_MCA_STACKFRAME, r2;;
>  	movl    r4=IA64_PSR_MC
>  	;;
>  	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
> @@ -387,8 +385,10 @@
>  ia64_os_mca_proc_state_dump:
>  // Save bank 1 GRs 16-31 which will be used by c-language code when we switch
>  //  to virtual addressing mode.
> -	LOAD_PHYSICAL(p0,r2,ia64_mca_proc_state_dump)// convert OS state dump area to physical address
> -
> +	addl		r2 = THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA,r0;;
> +	ld8		r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
> +	addl		r2 = IA64_MCA_PROC_STATE_DUMP, r2;;
> +					// r2 now points at ia64_mca_proc_state_dump area
>  // save ar.NaT
>  	mov		r5=ar.unat                  // ar.unat
>  
> @@ -618,9 +618,10 @@
>  ia64_os_mca_proc_state_restore:
>  
>  // Restore bank1 GR16-31
> -	movl		r2=ia64_mca_proc_state_dump	// Convert virtual address
> -	;;						// of OS state dump area
> -	DATA_VA_TO_PA(r2)				// to physical address
> +	addl		r2=THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA, r0;;
> +	ld8		r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
> +	addl		r2 = IA64_MCA_PROC_STATE_DUMP, r2;;
> +					// r2 now points at ia64_mca_proc_state_dump area
>  
>  restore_GRs:                                    // restore bank-1 GRs 16-31
>  	bsw.1;;
> diff -Nur linux-2.6.8.1.org/arch/ia64/kernel/minstate.h linux-2.6.8.1/arch/ia64/kernel/minstate.h
> --- linux-2.6.8.1.org/arch/ia64/kernel/minstate.h	2004-09-14 15:15:40.876843617 +0900
> +++ linux-2.6.8.1/arch/ia64/kernel/minstate.h	2004-09-14 15:14:39.406141245 +0900
> @@ -37,7 +37,18 @@
>   * go virtual and don't want to destroy the iip or ipsr.
>   */
>  #define MINSTATE_START_SAVE_MIN_PHYS								\
> -(pKStk) movl sp=ia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
> +(pKStk) adds r16=IA64_TASK_SIZE+IA64_THREAD_INFO_CPU_OFFSET,r1;;	/* thread_info->cpu */	\
> +(pKStk) ld4 r16=[r16];				/* smp_processor_id */				\
> +(pKStk) movl r2=__per_cpu_offset;;								\
> +(pKStk) shladd r2=r16,3,r2;;									\
> +(pKStk) tpa r2=r2;;				/* compute physical addr */			\
> +(pKStk) ld8 r2=[r2];				/* __per_cpu_offset[cpu] */			\
> +(pKStk) movl r17=THIS_CPU(cpu_info);;								\
> +(pKStk) add r2=r17,r2;;				/*  cpu_info structure  */			\
> +(pKStk) adds r2=IA64_CPUINFO_MCA_DATA,r2;;							\
> +(pKStk) tpa r2=r2;;				/* compute physical addr */			\
> +(pKStk) ld8 r2=[r2];;				/* Address of local cpu MCA/INIT save area */	\
> +(pKStk) addl sp=IA64_INIT_STACK+IA64_STK_OFFSET-IA64_PT_REGS_SIZE, r2;				\
>  (pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
>  (pUStk)	addl r22=IA64_RBS_OFFSET,r1;		/* compute base of register backing store */	\
>  	;;											\
> diff -Nur linux-2.6.8.1.org/arch/ia64/mm/discontig.c linux-2.6.8.1/arch/ia64/mm/discontig.c
> --- linux-2.6.8.1.org/arch/ia64/mm/discontig.c	2004-09-14 15:15:40.874890492 +0900
> +++ linux-2.6.8.1/arch/ia64/mm/discontig.c	2004-09-14 14:46:57.596591290 +0900
> @@ -4,6 +4,10 @@
>   * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
>   * Copyright (c) 2002 NEC Corp.
>   * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
> + * Copyright (c) 2003-2004 Silicon Graphics, Inc
> + *      Russ Anderson <rja@sgi.com>
> + *      Jesse Barnes <jbarnes@sgi.com>
> + *      Jack Steiner <steiner@sgi.com>
>   */
>  
>  /*
> @@ -21,6 +25,7 @@
>  #include <asm/meminit.h>
>  #include <asm/numa.h>
>  #include <asm/sections.h>
> +#include <asm/mca.h>
>  
>  /*
>   * Track per-node information needed to setup the boot memory allocator, the
> @@ -206,12 +211,33 @@
>  }
>  
>  /**
> + * early_nr_phys_cpus_node - return number of physical cpus on a given node
> + * @node: node to check
> + *
> + * Count the number of physical cpus on @node.  These are cpus that actually
> + * exist.  We can't use nr_cpus_node() yet because
> + * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
> + * called yet.
> + */
> +static int early_nr_phys_cpus_node(int node)
> +{
> +	int cpu, n = 0;
> +
> +	for (cpu = 0; cpu < NR_CPUS; cpu++)
> +		if (node = node_cpuid[cpu].nid)
> +			if ((cpu = 0) || node_cpuid[cpu].phys_id)
> +				n++;
> +
> +	return n;
> +}
> +
> +/**
>   * early_nr_cpus_node - return number of cpus on a given node
>   * @node: node to check
>   *
>   * Count the number of cpus on @node.  We can't use nr_cpus_node() yet because
>   * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
> - * called yet.
> + * called yet.  Note that node 0 will also count all non-existent cpus.
>   */
>  static int early_nr_cpus_node(int node)
>  {
> @@ -238,12 +264,15 @@
>   *   |                        |
>   *   |~~~~~~~~~~~~~~~~~~~~~~~~| <-- NODEDATA_ALIGN(start, node) for the first
>   *   |    PERCPU_PAGE_SIZE *  |     start and length big enough
> - *   |        NR_CPUS         |
> + *   |    cpus_on_this_node   | Node 0 will also have entries for all non-existent cpus.
>   *   |------------------------|
>   *   |   local pg_data_t *    |
>   *   |------------------------|
>   *   |  local ia64_node_data  |
>   *   |------------------------|
> + *   |    MCA/INIT data *     |
> + *   |    cpus_on_this_node   |
> + *   |------------------------|
>   *   |          ???           |
>   *   |________________________|
>   *
> @@ -255,10 +284,11 @@
>  static int __init find_pernode_space(unsigned long start, unsigned long len,
>  				     int node)
>  {
> -	unsigned long epfn, cpu, cpus;
> +	unsigned long epfn, cpu, cpus, phys_cpus;
>  	unsigned long pernodesize = 0, pernode, pages, mapsize;
> -	void *cpu_data;
> +	void *cpu_data, *mca_data_phys;
>  	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
> +	struct cpuinfo_ia64 *cpuinfo;
>  
>  	epfn = (start + len) >> PAGE_SHIFT;
>  
> @@ -281,9 +311,11 @@
>  	 * for good alignment and alias prevention.
>  	 */
>  	cpus = early_nr_cpus_node(node);
> +	phys_cpus = early_nr_phys_cpus_node(node);
>  	pernodesize += PERCPU_PAGE_SIZE * cpus;
>  	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
>  	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
> +	pernodesize += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
>  	pernodesize = PAGE_ALIGN(pernodesize);
>  	pernode = NODEDATA_ALIGN(start, node);
>  
> @@ -302,6 +334,9 @@
>  		mem_data[node].node_data = __va(pernode);
>  		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
>  
> +		mca_data_phys = (void *)pernode;
> +		pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
> +
>  		mem_data[node].pgdat->bdata = bdp;
>  		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
>  
> @@ -314,6 +349,9 @@
>  			if (node = node_cpuid[cpu].nid) {
>  				memcpy(__va(cpu_data), __phys_per_cpu_start,
>  				       __per_cpu_end - __per_cpu_start);
> +				cpuinfo = (struct cpuinfo_ia64 *)(__va(cpu_data) + ((char *) &per_cpu__cpu_info - __per_cpu_start));
> +				cpuinfo->ia64_mca_data = __va(mca_data_phys);
> +				mca_data_phys += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t));
>  				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
>  					__per_cpu_start;
>  				cpu_data += PERCPU_PAGE_SIZE;
> diff -Nur linux-2.6.8.1.org/include/asm-ia64/mca.h linux-2.6.8.1/include/asm-ia64/mca.h
> --- linux-2.6.8.1.org/include/asm-ia64/mca.h	2004-09-14 15:15:40.870007680 +0900
> +++ linux-2.6.8.1/include/asm-ia64/mca.h	2004-09-13 14:08:18.000000000 +0900
> @@ -5,6 +5,7 @@
>   * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
>   * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
>   * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
> + * Copyright (C) Russ Anderson <rja@sgi.com>
>   */
>  
>  #ifndef _ASM_IA64_MCA_H
> @@ -107,6 +108,14 @@
>  						 */
>  } ia64_mca_os_to_sal_state_t;
>  
> +typedef struct ia64_mca_cpu_s {
> +	u64		ia64_mca_proc_state_dump[512];
> +	u64		ia64_mca_stack[1024] __attribute__((aligned(16)));
> +	u64		ia64_mca_stackframe[32];
> +	u64		ia64_mca_bspstore[1024];
> +	u64		ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
> +} ia64_mca_cpu_t;
> +
>  extern void ia64_mca_init(void);
>  extern void ia64_os_mca_dispatch(void);
>  extern void ia64_os_mca_dispatch_end(void);
> diff -Nur linux-2.6.8.1.org/include/asm-ia64/processor.h linux-2.6.8.1/include/asm-ia64/processor.h
> --- linux-2.6.8.1.org/include/asm-ia64/processor.h	2004-09-14 15:15:40.876843617 +0900
> +++ linux-2.6.8.1/include/asm-ia64/processor.h	2004-09-13 14:08:18.000000000 +0900
> @@ -2,6 +2,8 @@
>  #define _ASM_IA64_PROCESSOR_H
>  
>  /*
> + * Copyright (C) 2004 Silicon Graphics, Inc
> + *      Russ Anderson <rja@sgi.com>
>   * Copyright (C) 1998-2004 Hewlett-Packard Co
>   *	David Mosberger-Tang <davidm@hpl.hp.com>
>   *	Stephane Eranian <eranian@hpl.hp.com>
> @@ -171,6 +173,7 @@
>  #ifdef CONFIG_NUMA
>  	struct ia64_node_data *node_data;
>  #endif
> +	__u64 *ia64_mca_data;	/* prt to MCA/INIT processor state */
>  };
>  
>  DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
> 


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
