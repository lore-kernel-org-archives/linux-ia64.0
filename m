From: Andreas Schwab <schwab@suse.de>
Date: Mon, 05 Jan 2004 18:50:02 +0000
Subject: Cleanup EXPORT_SYMBOL usage
Message-Id: <jer7yemdr9.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

This cleans up the use of EXPORT_SYMBOL in ia64_ksyms.c by moving most of
them to the place where the symbol is defined.  Ideally, only symbols
defined in assembler sources should remain here, but there are some cases
where an EXPORT_SYMBOL is missing outside the arch/ia64 tree.  I did not
change them for now.  Also, EXPORT_SYMBOL_NOVERS is obsolete.

Andreas.

--- linux-2.6.0.prev/arch/ia64/kernel/acpi.c	2004-01-05 16:26:36.000000000 =
+0100
+++ linux-2.6.0/arch/ia64/kernel/acpi.c	2004-01-05 16:48:58.000000000 +0100
@@ -32,6 +32,7 @@
  */
=20
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -53,6 +54,7 @@
 #define PREFIX			"ACPI: "
=20
 void (*pm_idle) (void);
+EXPORT_SYMBOL(pm_idle);
 void (*pm_power_off) (void);
=20
 unsigned char acpi_kbd_controller_present =3D 1;
--- linux-2.6.0.prev/arch/ia64/kernel/efi.c	2004-01-05 16:26:36.000000000 +=
0100
+++ linux-2.6.0/arch/ia64/kernel/efi.c	2004-01-05 16:43:05.000000000 +0100
@@ -19,6 +19,7 @@
  *	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/types.h>
@@ -37,6 +38,7 @@
 extern efi_status_t efi_call_phys (void *, ...);
=20
 struct efi efi;
+EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
=20
 /*
@@ -48,6 +50,7 @@
  */
 #ifdef CONFIG_PROC_FS
 struct proc_dir_entry *efi_dir;
+EXPORT_SYMBOL(efi_dir);
 #endif
=20
 static unsigned long mem_limit =3D ~0UL;
--- linux-2.6.0.prev/arch/ia64/kernel/ia64_ksyms.c	2004-01-05 16:26:36.0000=
00000 +0100
+++ linux-2.6.0/arch/ia64/kernel/ia64_ksyms.c	2004-01-05 16:50:32.000000000=
 +0100
@@ -1,15 +1,18 @@
 /*
  * Architecture-specific kernel symbols
+ *
+ * Don't put any exports here unless it's defined in an assembler file.
+ * All other exports should be put directly after the definition.
  */
=20
 #include <linux/config.h>
 #include <linux/module.h>
=20
 #include <linux/string.h>
-EXPORT_SYMBOL_NOVERS(memset);			/* gcc generates direct calls to memset().=
.. */
+EXPORT_SYMBOL(memset);
 EXPORT_SYMBOL(memchr);
 EXPORT_SYMBOL(memcmp);
-EXPORT_SYMBOL_NOVERS(memcpy);
+EXPORT_SYMBOL(memcpy);
 EXPORT_SYMBOL(memmove);
 EXPORT_SYMBOL(memscan);
 EXPORT_SYMBOL(strcat);
@@ -25,77 +28,28 @@
 EXPORT_SYMBOL(strstr);
 EXPORT_SYMBOL(strpbrk);
=20
-#include <linux/irq.h>
-EXPORT_SYMBOL(isa_irq_to_vector_map);
-EXPORT_SYMBOL(enable_irq);
-EXPORT_SYMBOL(disable_irq);
-EXPORT_SYMBOL(disable_irq_nosync);
-
-#include <linux/interrupt.h>
-EXPORT_SYMBOL(probe_irq_mask);
-
 #include <asm/checksum.h>
 EXPORT_SYMBOL(ip_fast_csum);		/* hand-coded assembly */
=20
-#include <asm/io.h>
-EXPORT_SYMBOL(__ia64_memcpy_fromio);
-EXPORT_SYMBOL(__ia64_memcpy_toio);
-EXPORT_SYMBOL(__ia64_memset_c_io);
-EXPORT_SYMBOL(io_space);
-
 #include <asm/semaphore.h>
-EXPORT_SYMBOL_NOVERS(__down);
-EXPORT_SYMBOL_NOVERS(__down_interruptible);
-EXPORT_SYMBOL_NOVERS(__down_trylock);
-EXPORT_SYMBOL_NOVERS(__up);
+EXPORT_SYMBOL(__down);
+EXPORT_SYMBOL(__down_interruptible);
+EXPORT_SYMBOL(__down_trylock);
+EXPORT_SYMBOL(__up);
=20
 #include <asm/page.h>
 EXPORT_SYMBOL(clear_page);
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-#include <linux/bootmem.h>
 #include <asm/pgtable.h>
-EXPORT_SYMBOL(vmalloc_end);
-EXPORT_SYMBOL(ia64_pfn_valid);
 EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by g=
eneric code */
 #endif
=20
 #include <asm/processor.h>
 EXPORT_SYMBOL(per_cpu__cpu_info);
 #ifdef CONFIG_SMP
-EXPORT_SYMBOL(__per_cpu_offset);
 EXPORT_SYMBOL(per_cpu__local_per_cpu_offset);
 #endif
-EXPORT_SYMBOL(kernel_thread);
-
-#include <asm/system.h>
-#ifdef CONFIG_IA64_DEBUG_IRQ
-EXPORT_SYMBOL(last_cli_ip);
-#endif
-
-#include <asm/tlbflush.h>
-
-EXPORT_SYMBOL(flush_tlb_range);
-
-#ifdef CONFIG_SMP
-
-EXPORT_SYMBOL(smp_flush_tlb_all);
-
-#include <asm/current.h>
-#include <asm/hardirq.h>
-EXPORT_SYMBOL(synchronize_irq);
-
-#include <asm/smp.h>
-EXPORT_SYMBOL(smp_call_function);
-EXPORT_SYMBOL(smp_call_function_single);
-EXPORT_SYMBOL(cpu_online_map);
-EXPORT_SYMBOL(phys_cpu_present_map);
-EXPORT_SYMBOL(ia64_cpu_to_sapicid);
-#else /* !CONFIG_SMP */
-
-EXPORT_SYMBOL(local_flush_tlb_all);
-
-#endif /* !CONFIG_SMP */
=20
 #include <asm/uaccess.h>
 EXPORT_SYMBOL(__copy_user);
@@ -117,14 +71,14 @@
 extern void __moddi3(void);
 extern void __umoddi3(void);
=20
-EXPORT_SYMBOL_NOVERS(__divsi3);
-EXPORT_SYMBOL_NOVERS(__udivsi3);
-EXPORT_SYMBOL_NOVERS(__modsi3);
-EXPORT_SYMBOL_NOVERS(__umodsi3);
-EXPORT_SYMBOL_NOVERS(__divdi3);
-EXPORT_SYMBOL_NOVERS(__udivdi3);
-EXPORT_SYMBOL_NOVERS(__moddi3);
-EXPORT_SYMBOL_NOVERS(__umoddi3);
+EXPORT_SYMBOL(__divsi3);
+EXPORT_SYMBOL(__udivsi3);
+EXPORT_SYMBOL(__modsi3);
+EXPORT_SYMBOL(__umodsi3);
+EXPORT_SYMBOL(__divdi3);
+EXPORT_SYMBOL(__udivdi3);
+EXPORT_SYMBOL(__moddi3);
+EXPORT_SYMBOL(__umoddi3);
=20
 #if defined(CONFIG_MD_RAID5) || defined(CONFIG_MD_RAID5_MODULE)
 extern void xor_ia64_2(void);
@@ -132,15 +86,12 @@
 extern void xor_ia64_4(void);
 extern void xor_ia64_5(void);
=20
-EXPORT_SYMBOL_NOVERS(xor_ia64_2);
-EXPORT_SYMBOL_NOVERS(xor_ia64_3);
-EXPORT_SYMBOL_NOVERS(xor_ia64_4);
-EXPORT_SYMBOL_NOVERS(xor_ia64_5);
+EXPORT_SYMBOL(xor_ia64_2);
+EXPORT_SYMBOL(xor_ia64_3);
+EXPORT_SYMBOL(xor_ia64_4);
+EXPORT_SYMBOL(xor_ia64_5);
 #endif
=20
-extern unsigned long ia64_iobase;
-EXPORT_SYMBOL(ia64_iobase);
-
 #include <asm/pal.h>
 EXPORT_SYMBOL(ia64_pal_call_phys_stacked);
 EXPORT_SYMBOL(ia64_pal_call_phys_static);
@@ -149,44 +100,8 @@
 EXPORT_SYMBOL(ia64_load_scratch_fpregs);
 EXPORT_SYMBOL(ia64_save_scratch_fpregs);
=20
-extern struct efi efi;
-EXPORT_SYMBOL(efi);
-
-#include <linux/proc_fs.h>
-extern struct proc_dir_entry *efi_dir;
-EXPORT_SYMBOL(efi_dir);
-
-#include <asm/machvec.h>
-#ifdef CONFIG_IA64_GENERIC
-EXPORT_SYMBOL(ia64_mv);
-#endif
-EXPORT_SYMBOL(machvec_noop);
-EXPORT_SYMBOL(machvec_memory_fence);
-EXPORT_SYMBOL(zero_page_memmap_ptr);
-#ifdef CONFIG_PERFMON
-#include <asm/perfmon.h>
-EXPORT_SYMBOL(pfm_register_buffer_fmt);
-EXPORT_SYMBOL(pfm_unregister_buffer_fmt);
-EXPORT_SYMBOL(pfm_mod_fast_read_pmds);
-EXPORT_SYMBOL(pfm_mod_read_pmds);
-EXPORT_SYMBOL(pfm_mod_write_pmcs);
-#endif
-
-#ifdef CONFIG_NUMA
-#include <asm/numa.h>
-EXPORT_SYMBOL(cpu_to_node_map);
-#endif
-
 #include <asm/unwind.h>
-EXPORT_SYMBOL(unw_init_from_blocked_task);
 EXPORT_SYMBOL(unw_init_running);
-EXPORT_SYMBOL(unw_unwind);
-EXPORT_SYMBOL(unw_unwind_to_user);
-EXPORT_SYMBOL(unw_access_gr);
-EXPORT_SYMBOL(unw_access_br);
-EXPORT_SYMBOL(unw_access_fr);
-EXPORT_SYMBOL(unw_access_ar);
-EXPORT_SYMBOL(unw_access_pr);
=20
 #ifdef CONFIG_SMP
 # if __GNUC__ < 3 || (__GNUC__ =3D 3 && __GNUC_MINOR__ < 3)
@@ -205,8 +120,3 @@
 EXPORT_SYMBOL(ia64_spinlock_contention);
 # endif
 #endif
-
-EXPORT_SYMBOL(ia64_max_iommu_merge_mask);
-
-#include <linux/pm.h>
-EXPORT_SYMBOL(pm_idle);
--- linux-2.6.0.prev/arch/ia64/kernel/irq.c	2004-01-05 16:26:36.000000000 +=
0100
+++ linux-2.6.0/arch/ia64/kernel/irq.c	2004-01-05 16:38:56.000000000 +0100
@@ -223,6 +223,7 @@
 	while (irq_descp(irq)->status & IRQ_INPROGRESS)
 		cpu_relax();
 }
+EXPORT_SYMBOL(synchronize_irq);
 #endif
=20
 /*
@@ -364,6 +365,7 @@
 	}
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
+EXPORT_SYMBOL(disable_irq_nosync);
=20
 /**
  *	disable_irq - disable an irq and wait for completion
@@ -386,6 +388,7 @@
 	if (desc->action)
 		synchronize_irq(irq);
 }
+EXPORT_SYMBOL(disable_irq);
=20
 /**
  *	enable_irq - enable handling of an irq
@@ -424,6 +427,7 @@
 	}
 	spin_unlock_irqrestore(&desc->lock, flags);
 }
+EXPORT_SYMBOL(enable_irq);
=20
 /*
  * do_IRQ handles all normal device IRQ's (the special
@@ -792,6 +796,7 @@
=20
 	return mask & val;
 }
+EXPORT_SYMBOL(probe_irq_mask);
=20
 /**
  *	probe_irq_off	- end an interrupt autodetect
--- linux-2.6.0.prev/arch/ia64/kernel/irq_ia64.c	2003-12-18 03:58:46.000000=
000 +0100
+++ linux-2.6.0/arch/ia64/kernel/irq_ia64.c	2004-01-05 16:32:35.000000000 +=
0100
@@ -13,6 +13,7 @@
  */
=20
 #include <linux/config.h>
+#include <linux/module.h>
=20
 #include <linux/jiffies.h>
 #include <linux/errno.h>
@@ -54,6 +55,7 @@
 	0x2f, 0x20, 0x2e, 0x2d, 0x2c, 0x2b, 0x2a, 0x29,
 	0x28, 0x27, 0x26, 0x25, 0x24, 0x23, 0x22, 0x21
 };
+EXPORT_SYMBOL(isa_irq_to_vector_map);
=20
 int
 ia64_alloc_vector (void)
--- linux-2.6.0.prev/arch/ia64/kernel/machvec.c	2003-12-18 03:58:49.0000000=
00 +0100
+++ linux-2.6.0/arch/ia64/kernel/machvec.c	2004-01-05 16:44:04.000000000 +0=
100
@@ -1,4 +1,5 @@
 #include <linux/config.h>
+#include <linux/module.h>
=20
 #include <asm/system.h>
=20
@@ -11,6 +12,7 @@
 #include <asm/page.h>
=20
 struct ia64_machine_vector ia64_mv;
+EXPORT_SYMBOL(ia64_mv);
=20
 static struct ia64_machine_vector *
 lookup_machvec (const char *name)
@@ -45,9 +47,11 @@
 machvec_noop (void)
 {
 }
+EXPORT_SYMBOL(machvec_noop);
=20
 void
 machvec_memory_fence (void)
 {
 	mb();
 }
+EXPORT_SYMBOL(machvec_memory_fence);
--- linux-2.6.0.prev/arch/ia64/kernel/perfmon.c	2004-01-05 16:26:36.0000000=
00 +0100
+++ linux-2.6.0/arch/ia64/kernel/perfmon.c	2004-01-05 16:45:37.000000000 +0=
100
@@ -20,6 +20,7 @@
  */
=20
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/interrupt.h>
@@ -1259,6 +1260,7 @@
 	spin_unlock(&pfm_buffer_fmt_lock);
  	return ret;
 }
+EXPORT_SYMBOL(pfm_register_buffer_fmt);
=20
 int
 pfm_unregister_buffer_fmt(pfm_uuid_t uuid)
@@ -1282,6 +1284,7 @@
 	return ret;
=20
 }
+EXPORT_SYMBOL(pfm_unregister_buffer_fmt);
=20
 static int
 pfm_reserve_session(struct task_struct *task, int is_syswide, unsigned int=
 cpu)
@@ -3421,6 +3424,7 @@
=20
 	return pfm_write_pmcs(ctx, req, nreq, regs);
 }
+EXPORT_SYMBOL(pfm_mod_write_pmcs);
=20
 long
 pfm_mod_read_pmds(struct task_struct *task, pfarg_reg_t *req, unsigned int=
 nreq, struct pt_regs *regs)
@@ -3442,6 +3446,7 @@
=20
 	return pfm_read_pmds(ctx, req, nreq, regs);
 }
+EXPORT_SYMBOL(pfm_mod_read_pmds);
=20
 long
 pfm_mod_fast_read_pmds(struct task_struct *task, unsigned long mask[4], un=
signed long *addr, struct pt_regs *regs)
@@ -3483,6 +3488,7 @@
 	}
 	return 0;
 }
+EXPORT_SYMBOL(pfm_mod_fast_read_pmds);
=20
 /*
  * Only call this function when a process it trying to
--- linux-2.6.0.prev/arch/ia64/kernel/process.c	2003-12-18 03:58:49.0000000=
00 +0100
+++ linux-2.6.0/arch/ia64/kernel/process.c	2004-01-05 16:37:12.000000000 +0=
100
@@ -598,6 +598,7 @@
 	}
 	return tid;
 }
+EXPORT_SYMBOL(kernel_thread);
=20
 /*
  * Flush thread state.  This is called when a thread does an execve().
--- linux-2.6.0.prev/arch/ia64/kernel/setup.c	2003-12-18 03:58:15.000000000=
 +0100
+++ linux-2.6.0/arch/ia64/kernel/setup.c	2004-01-05 16:48:37.000000000 +0100
@@ -17,6 +17,7 @@
  * 06/24/99 W.Drummond	added boot_cpu_data.
  */
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/init.h>
=20
 #include <linux/acpi.h>
@@ -56,6 +57,7 @@
=20
 #ifdef CONFIG_SMP
 unsigned long __per_cpu_offset[NR_CPUS];
+EXPORT_SYMBOL(__per_cpu_offset);
 #endif
=20
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
@@ -67,7 +69,9 @@
=20
 unsigned long ia64_max_cacheline_size;
 unsigned long ia64_iobase;	/* virtual address for I/O accesses */
+EXPORT_SYMBOL(ia64_iobase);
 struct io_space io_space[MAX_IO_SPACES];
+EXPORT_SYMBOL(io_space);
 unsigned int num_io_spaces;
=20
 unsigned char aux_device_present =3D 0xaa;        /* XXX remove this when =
legacy I/O is gone */
@@ -82,6 +86,7 @@
  * page-size of 2^64.
  */
 unsigned long ia64_max_iommu_merge_mask =3D ~0UL;
+EXPORT_SYMBOL(ia64_max_iommu_merge_mask);
=20
 #define COMMAND_LINE_SIZE	512
=20
--- linux-2.6.0.prev/arch/ia64/kernel/smp.c	2003-12-18 03:59:55.000000000 +=
0100
+++ linux-2.6.0/arch/ia64/kernel/smp.c	2004-01-05 16:39:26.000000000 +0100
@@ -22,6 +22,7 @@
=20
 #include <linux/config.h>
=20
+#include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/init.h>
@@ -210,6 +211,7 @@
 {
 	on_each_cpu((void (*)(void *))local_flush_tlb_all, 0, 1, 1);
 }
+EXPORT_SYMBOL(smp_flush_tlb_all);
=20
 void
 smp_flush_tlb_mm (struct mm_struct *mm)
@@ -283,6 +285,7 @@
 	put_cpu();
 	return 0;
 }
+EXPORT_SYMBOL(smp_call_function_single);
=20
 /*
  * this function sends a 'generic call function' IPI to all other CPUs
@@ -337,6 +340,7 @@
 	spin_unlock(&call_lock);
 	return 0;
 }
+EXPORT_SYMBOL(smp_call_function);
=20
 void
 smp_do_timer (struct pt_regs *regs)
--- linux-2.6.0.prev/arch/ia64/kernel/smpboot.c	2004-01-05 16:26:36.0000000=
00 +0100
+++ linux-2.6.0/arch/ia64/kernel/smpboot.c	2004-01-05 16:46:04.000000000 +0=
100
@@ -16,6 +16,7 @@
=20
 #include <linux/config.h>
=20
+#include <linux/module.h>
 #include <linux/acpi.h>
 #include <linux/bootmem.h>
 #include <linux/delay.h>
@@ -81,10 +82,13 @@
=20
 /* Bitmask of currently online CPUs */
 cpumask_t cpu_online_map;
+EXPORT_SYMBOL(cpu_online_map);
 cpumask_t phys_cpu_present_map;
+EXPORT_SYMBOL(phys_cpu_present_map);
=20
 /* which logical CPU number maps to which CPU (physical APIC ID) */
 volatile int ia64_cpu_to_sapicid[NR_CPUS];
+EXPORT_SYMBOL(ia64_cpu_to_sapicid);
=20
 static volatile cpumask_t cpu_callin_map;
=20
@@ -467,6 +471,7 @@
=20
 /* on which node is each logical CPU (one cacheline even for 64 CPUs) */
 volatile u8 cpu_to_node_map[NR_CPUS] __cacheline_aligned;
+EXPORT_SYMBOL(cpu_to_node_map);
 /* which logical CPUs are on which nodes */
 volatile cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
=20
--- linux-2.6.0.prev/arch/ia64/kernel/time.c	2003-12-18 03:58:18.000000000 =
+0100
+++ linux-2.6.0/arch/ia64/kernel/time.c	2004-01-05 16:37:35.000000000 +0100
@@ -39,6 +39,7 @@
 #ifdef CONFIG_IA64_DEBUG_IRQ
=20
 unsigned long last_cli_ip;
+EXPORT_SYMBOL(last_cli_ip);
=20
 #endif
=20
--- linux-2.6.0.prev/arch/ia64/kernel/unwind.c	2003-12-18 04:00:02.00000000=
0 +0100
+++ linux-2.6.0/arch/ia64/kernel/unwind.c	2004-01-05 16:47:54.000000000 +01=
00
@@ -26,6 +26,7 @@
  *	o if both the unw.lock spinlock and a script's read-write lock must be
  *	  acquired, then the read-write lock must be acquired first.
  */
+#include <linux/module.h>
 #include <linux/bootmem.h>
 #include <linux/elf.h>
 #include <linux/kernel.h>
@@ -392,6 +393,7 @@
 	}
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_gr);
=20
 int
 unw_access_br (struct unw_frame_info *info, int regnum, unsigned long *val=
, int write)
@@ -423,6 +425,7 @@
 		*val =3D *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_br);
=20
 int
 unw_access_fr (struct unw_frame_info *info, int regnum, struct ia64_fpreg =
*val, int write)
@@ -467,6 +470,7 @@
 		*val =3D *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_fr);
=20
 int
 unw_access_ar (struct unw_frame_info *info, int regnum, unsigned long *val=
, int write)
@@ -559,6 +563,7 @@
 		*val =3D *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_ar);
=20
 int
 unw_access_pr (struct unw_frame_info *info, unsigned long *val, int write)
@@ -575,6 +580,7 @@
 		*val =3D *addr;
 	return 0;
 }
+EXPORT_SYMBOL(unw_access_pr);
=20
 =0C
 /* Routines to manipulate the state stack.  */
@@ -1897,6 +1903,7 @@
 	STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_rest=
ore(flags));
 	return retval;
 }
+EXPORT_SYMBOL(unw_unwind);
=20
 int
 unw_unwind_to_user (struct unw_frame_info *info)
@@ -1917,6 +1924,7 @@
 	UNW_DPRINT(0, "unwind.%s: failed to unwind to user-level (ip=3D0x%lx)\n",=
 __FUNCTION__, ip);
 	return -1;
 }
+EXPORT_SYMBOL(unw_unwind_to_user);
=20
 static void
 init_frame_info (struct unw_frame_info *info, struct task_struct *t,
@@ -2014,6 +2022,7 @@
 	UNW_DPRINT(1, "unwind.%s\n", __FUNCTION__);
 	unw_init_frame_info(info, t, sw);
 }
+EXPORT_SYMBOL(unw_init_from_blocked_task);
=20
 static void
 init_unwind_table (struct unw_table *table, const char *name, unsigned lon=
g segment_base,
--- linux-2.6.0.prev/arch/ia64/lib/io.c	2003-12-18 03:57:58.000000000 +0100
+++ linux-2.6.0/arch/ia64/lib/io.c	2004-01-05 16:30:22.000000000 +0100
@@ -1,4 +1,5 @@
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/types.h>
=20
 #include <asm/io.h>
@@ -17,6 +18,7 @@
 		from++;
 	}
 }
+EXPORT_SYMBOL(__ia64_memcpy_fromio);
=20
 /*
  * Copy data from "real" memory space to IO memory space.
@@ -32,6 +34,7 @@
 		to++;
 	}
 }
+EXPORT_SYMBOL(__ia64_memcpy_toio);
=20
 /*
  * "memset" on IO memory space.
@@ -48,6 +51,7 @@
 		dst++;
 	}
 }
+EXPORT_SYMBOL(__ia64_memset_c_io);
=20
 #ifdef CONFIG_IA64_GENERIC
=20
--- linux-2.6.0.prev/arch/ia64/mm/init.c	2004-01-05 16:26:36.000000000 +0100
+++ linux-2.6.0/arch/ia64/mm/init.c	2004-01-05 16:44:22.000000000 +0100
@@ -43,15 +43,16 @@
 unsigned long MAX_DMA_ADDRESS =3D PAGE_OFFSET + 0x100000000UL;
=20
 #ifdef CONFIG_VIRTUAL_MEM_MAP
-  unsigned long vmalloc_end =3D VMALLOC_END_INIT;
-  struct page *vmem_map;
-
-  EXPORT_SYMBOL(vmem_map);
+unsigned long vmalloc_end =3D VMALLOC_END_INIT;
+EXPORT_SYMBOL(vmalloc_end);
+struct page *vmem_map;
+EXPORT_SYMBOL(vmem_map);
 #endif
=20
 static int pgt_cache_water[2] =3D { 25, 50 };
=20
 struct page *zero_page_memmap_ptr;		/* map entry for zero page */
+EXPORT_SYMBOL(zero_page_memmap_ptr);
=20
 void
 check_pgt_cache (void)
@@ -457,6 +458,7 @@
=20
 	return __get_user(byte, (char *) pfn_to_page(pfn)) =3D 0;
 }
+EXPORT_SYMBOL(ia64_pfn_valid);
=20
 int
 find_largest_hole (u64 start, u64 end, void *arg)
--- linux-2.6.0.prev/arch/ia64/mm/tlb.c	2003-12-18 03:59:06.000000000 +0100
+++ linux-2.6.0/arch/ia64/mm/tlb.c	2004-01-05 16:40:36.000000000 +0100
@@ -10,6 +10,7 @@
  *              IPI based ptc implementation and A-step IPI implementation.
  */
 #include <linux/config.h>
+#include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -126,6 +127,7 @@
 	local_irq_restore(flags);
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
+EXPORT_SYMBOL(local_flush_tlb_all);
=20
 void
 flush_tlb_range (struct vm_area_struct *vma, unsigned long start, unsigned=
 long end)
@@ -162,6 +164,7 @@
=20
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
+EXPORT_SYMBOL(flush_tlb_range);
=20
 void __init
 ia64_tlb_init (void)

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
