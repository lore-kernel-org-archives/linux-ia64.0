From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 15 Mar 2004 22:27:19 +0000
Subject: Re: killing CONFIG_IA64_MCA
Message-Id: <20040315222719.GA23929@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 15, 2004 at 01:40:05PM -0800, David Mosberger wrote:
> >>>>> On Mon, 15 Mar 2004 08:59:39 -0800, jbarnes@sgi.com (Jesse Barnes) said:
> 
>   Jesse> The patch looks fine, but I wonder if we really need
>   Jesse> CONFIG_IA64_MCA anymore, does anyone really want to run
>   Jesse> without it?
> 
> Good point.  MCA used to be rather big because of all the
> decoding-crap, but now that's cleaned up, so perhaps there is no
> reason to keep CONFIG_IA64_MCA anymore (even the usual Ski simulator
> config has CONFIG_IA64_MCA turned on, even though the supporting
> firmware-emulator doesn't really do anything about MCAs at the
> moment).

Here's a patch to kill it.  Builds and boots on sn2.

 Kconfig           |    7 -------
 kernel/Makefile   |    3 +--
 kernel/efi.c      |    4 ----
 kernel/setup.c    |    2 --
 kernel/smpboot.c  |    2 --
 mm/init.c         |    4 ----
 sn/kernel/setup.c |    3 ---
 7 files changed, 1 insertion(+), 24 deletions(-)

Jesse

=== arch/ia64/Kconfig 1.63 vs edited ==--- 1.63/arch/ia64/Kconfig	Thu Mar 11 12:58:54 2004
+++ edited/arch/ia64/Kconfig	Mon Mar 15 14:21:32 2004
@@ -238,13 +238,6 @@
 	  or have huge holes in the physical address space for other reasons.
 	  See <file:Documentation/vm/numa> for more.
 
-config IA64_MCA
-	bool "Machine Check Abort"
-	default y if !IA64_HP_SIM
-	help
-	  Say Y here to enable machine check support for IA-64.  If you're
-	  unsure, answer Y.
-
 config IA64_CYCLONE
 	bool "Support Cyclone(EXA) Time Source"
 	help
=== arch/ia64/kernel/Makefile 1.29 vs edited ==--- 1.29/arch/ia64/kernel/Makefile	Mon Feb 23 17:44:56 2004
+++ edited/arch/ia64/kernel/Makefile	Mon Mar 15 14:17:01 2004
@@ -6,13 +6,12 @@
 
 obj-y := acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o sal.o		\
-	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o unwind.o
+	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o unwind.o mca.o mca_asm.o
 
 obj-$(CONFIG_EFI_VARS)		+= efivars.o
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
-obj-$(CONFIG_IA64_MCA)		+= mca.o mca_asm.o
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
=== arch/ia64/kernel/efi.c 1.29 vs edited ==--- 1.29/arch/ia64/kernel/efi.c	Mon Jan  5 07:43:05 2004
+++ edited/arch/ia64/kernel/efi.c	Mon Mar 15 14:20:10 2004
@@ -399,9 +399,7 @@
 	int pal_code_count = 0;
 	u64 mask, psr;
 	u64 vaddr;
-#ifdef CONFIG_IA64_MCA
 	int cpu;
-#endif
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -463,13 +461,11 @@
 		ia64_set_psr(psr);		/* restore psr */
 		ia64_srlz_i();
 
-#ifdef CONFIG_IA64_MCA
 		cpu = smp_processor_id();
 
 		/* insert this TR into our list for MCA recovery purposes */
 		ia64_mca_tlb_list[cpu].pal_base = vaddr & mask;
 		ia64_mca_tlb_list[cpu].pal_paddr = pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL));
-#endif
 	}
 }
 
=== arch/ia64/kernel/setup.c 1.68 vs edited ==--- 1.68/arch/ia64/kernel/setup.c	Mon Jan 19 15:38:10 2004
+++ edited/arch/ia64/kernel/setup.c	Mon Mar 15 14:20:19 2004
@@ -355,10 +355,8 @@
 # endif
 #endif
 
-#ifdef CONFIG_IA64_MCA
 	/* enable IA-64 Machine Check Abort Handling */
 	ia64_mca_init();
-#endif
 
 	platform_setup(cmdline_p);
 	paging_init();
=== arch/ia64/kernel/smpboot.c 1.47 vs edited ==--- 1.47/arch/ia64/kernel/smpboot.c	Thu Feb 12 16:54:17 2004
+++ edited/arch/ia64/kernel/smpboot.c	Mon Mar 15 14:20:27 2004
@@ -300,9 +300,7 @@
 	 */
 	ia64_set_kr(IA64_KR_IO_BASE, __pa(ia64_iobase));
 
-#ifdef CONFIG_IA64_MCA
 	ia64_mca_cmc_vector_setup();	/* Setup vector on AP & enable */
-#endif
 
 #ifdef CONFIG_PERFMON
 	pfm_init_percpu();
=== arch/ia64/mm/init.c 1.56 vs edited ==--- 1.56/arch/ia64/mm/init.c	Thu Feb 26 12:18:51 2004
+++ edited/arch/ia64/mm/init.c	Mon Mar 15 14:20:43 2004
@@ -279,9 +279,7 @@
 {
 	unsigned long psr, pta, impl_va_bits;
 	extern void __init tlb_init (void);
-#ifdef CONFIG_IA64_MCA
 	int cpu;
-#endif
 
 #ifdef CONFIG_DISABLE_VHPT
 #	define VHPT_ENABLE_BIT	0
@@ -346,7 +344,6 @@
 	ia64_set_rr(HPAGE_REGION_BASE, HPAGE_SHIFT << 2);
 #endif
 
-#ifdef	CONFIG_IA64_MCA
 	cpu = smp_processor_id();
 
 	/* mca handler uses cr.lid as key to pick the right entry */
@@ -360,7 +357,6 @@
 	ia64_mca_tlb_list[cpu].ptce_count[1] = local_cpu_data->ptce_count[1];
 	ia64_mca_tlb_list[cpu].ptce_stride[0] = local_cpu_data->ptce_stride[0];
 	ia64_mca_tlb_list[cpu].ptce_stride[1] = local_cpu_data->ptce_stride[1];
-#endif
 }
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
=== arch/ia64/sn/kernel/setup.c 1.33 vs edited ==--- 1.33/arch/ia64/sn/kernel/setup.c	Sat Feb 14 23:22:40 2004
+++ edited/arch/ia64/sn/kernel/setup.c	Mon Mar 15 14:19:50 2004
@@ -194,10 +194,7 @@
 	}
 }
 
-#ifdef CONFIG_IA64_MCA
 extern int platform_intr_list[];
-#endif
-
 extern nasid_t master_nasid;
 static int shub_1_1_found __initdata;
 
