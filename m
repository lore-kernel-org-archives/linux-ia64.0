From: horms@tabatha.lab.ultramonkey.org
Date: Thu, 17 Aug 2006 07:07:21 +0000
Subject: [patch 2/5] Miscellaneous updates for kexec/kdump
Message-Id: <20060817071454.951461000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> commit beada884dd437b509c26b39f1a0b0c6b31e6f340
> tree ad7608f34ca8aa9e292e2a863484b3e13250107d
> parent b373e385743597f576b67c423807bbdfe3b862e7
> author Zou Nan hai <nanhai.zou@intel.com> 1150320804 -0700
> committer Tony Luck <tony.luck@intel.com> 1150320804 -0700
>=20
> [IA64] Miscellaneous updates for kexec/kdump
>=20
> Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Up-port from the test branch of Tony Luck's ia64 tree to 2.6.18-rc4

Cc: Zou Nan hai <nanhai.zou@intel.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

 /arch/ia64/Kconfig                  |    8 +
 /arch/ia64/kernel/crash.c           |  113 ++++++++++++++++++++-
 /arch/ia64/kernel/efi.c             |   17 ++-
 /arch/ia64/kernel/machine_kexec.c   |   43 +------
 /arch/ia64/kernel/relocate_kernel.S |   38 ++-----
 /arch/ia64/kernel/setup.c           |   38 +++++++
 /include/asm-ia64/kexec.h           |    4=20
 /include/asm-ia64/meminit.h         |    3=20
 /include/linux/irq.h                |    1=20
 /kernel/irq/manage.c                |   12 ++
 10 files changed, 211 insertions(+), 66 deletions(-)

Index: linux//arch/ia64/Kconfig
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//arch/ia64/Kconfig	2006-08-17 13:14:=
10.000000000 +0900
+++ linux//arch/ia64/Kconfig	2006-08-17 13:13:49.000000000 +0900
@@ -452,7 +452,11 @@
 	  support.  As of this writing the exact hardware interface is
 	  strongly in flux, so no good recommendation can be made.
=20
-source "drivers/sn/Kconfig"
+config CRASH_DUMP
+	  bool "kernel crash dumps (EXPERIMENTAL)"
+	  depends on EXPERIMENTAL
+	  help
+	    Generate crash dump after being started by kexec.
=20
 source "drivers/firmware/Kconfig"
=20
Index: linux//arch/ia64/kernel/crash.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//arch/ia64/kernel/crash.c	2006-08-17=
 13:14:10.000000000 +0900
+++ linux//arch/ia64/kernel/crash.c	2006-08-17 13:13:49.000000000 +0900
@@ -4,8 +4,8 @@
  * Architecture specific (ia64) functions for kexec based crash dumps.
  *
  * Created by: Khalid Aziz <khalid.aziz@hp.com>
- *
  * Copyright (C) 2005 Hewlett-Packard Development Company, L.P.
+ * Copyright (C) 2005 Intel Corp	Zou Nan hai <nanhai.zou@intel.com>
  *
  */
 #include <linux/init.h>
@@ -13,6 +13,7 @@
 #include <linux/kernel.h>
 #include <linux/smp.h>
 #include <linux/irq.h>
+#include <linux/pci.h>
 #include <linux/reboot.h>
 #include <linux/kexec.h>
 #include <linux/irq.h>
@@ -20,6 +21,111 @@
 #include <linux/elf.h>
 #include <linux/elfcore.h>
 #include <linux/device.h>
+#include <asm/uaccess.h>
+
+size_t copy_oldmem_page(unsigned long pfn, char *buf,
+                               size_t csize, unsigned long offset, int use=
rbuf)
+{
+        void  *vaddr;
+
+        if (!csize)
+                return 0;
+        vaddr =3D page_address(pfn_to_page(pfn));
+
+        if (userbuf) {
+                if (copy_to_user(buf, (vaddr + offset), csize)) {
+                        return -EFAULT;
+                }
+        } else
+                memcpy(buf, (vaddr + offset), csize);
+        return csize;
+}
+
+static void device_shootdown(void)
+{
+       struct pci_dev *dev;
+       irq_desc_t *desc;
+       u16 pci_command;
+
+       list_for_each_entry(dev, &pci_devices, global_list) {
+               desc =3D irq_descp(dev->irq);
+               if (!desc->action)
+                       continue;
+               pci_read_config_word(dev, PCI_COMMAND, &pci_command);
+               if (pci_command & PCI_COMMAND_MASTER) {
+                       pci_command &=3D ~PCI_COMMAND_MASTER;
+                       pci_write_config_word(dev, PCI_COMMAND, pci_command=
);
+               }
+               disable_irq_nosync(dev->irq);
+               desc->handler->end(dev->irq);
+       }
+}
+
+static Elf64_Word
+*append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
+		size_t data_len)
+{
+	struct elf_note *note =3D (struct elf_note *)buf;
+	note->n_namesz =3D strlen(name) + 1;
+	note->n_descsz =3D data_len;
+	note->n_type   =3D type;
+	buf +=3D (sizeof(*note) + 3)/4;
+	memcpy(buf, name, note->n_namesz);
+	buf +=3D (note->n_namesz + 3)/4;
+	memcpy(buf, data, data_len);
+	buf +=3D (data_len + 3)/4;
+	return buf;
+}
+
+static void
+final_note(void *buf)
+{
+	memset(buf, 0, sizeof(struct elf_note));
+}
+
+static void
+crash_save_this_cpu(void)
+{
+	void *buf;
+	struct elf_prstatus prstatus;
+	int cpu =3D smp_processor_id();
+	elf_greg_t *dst =3D (elf_greg_t *)&prstatus.pr_reg;
+
+	memset(&prstatus, 0, sizeof(prstatus));
+	prstatus.pr_pid =3D current->pid;
+
+    	dst[1] =3D ia64_getreg(_IA64_REG_GP);
+    	dst[12] =3D ia64_getreg(_IA64_REG_SP);
+    	dst[13] =3D ia64_getreg(_IA64_REG_TP);
+
+    	dst[42] =3D ia64_getreg(_IA64_REG_IP);
+    	dst[45] =3D ia64_getreg(_IA64_REG_AR_RSC);
+
+	ia64_setreg(_IA64_REG_AR_RSC, 0);
+	ia64_srlz_i();
+
+    	dst[46] =3D ia64_getreg(_IA64_REG_AR_BSP);
+    	dst[47] =3D ia64_getreg(_IA64_REG_AR_BSPSTORE);
+
+    	dst[48] =3D ia64_getreg(_IA64_REG_AR_RNAT);
+    	dst[49] =3D ia64_getreg(_IA64_REG_AR_CCV);
+    	dst[50] =3D ia64_getreg(_IA64_REG_AR_UNAT);
+
+    	dst[51] =3D ia64_getreg(_IA64_REG_AR_FPSR);
+    	dst[52] =3D ia64_getreg(_IA64_REG_AR_PFS);
+    	dst[53] =3D ia64_getreg(_IA64_REG_AR_LC);
+
+    	dst[54] =3D ia64_getreg(_IA64_REG_AR_LC);
+    	dst[55] =3D ia64_getreg(_IA64_REG_AR_CSD);
+    	dst[56] =3D ia64_getreg(_IA64_REG_AR_SSD);
+
+        buf =3D (u64 *) per_cpu_ptr(crash_notes, cpu);
+	if (!buf)
+		return;
+	buf =3D append_elf_note(buf, "CORE", NT_PRSTATUS, &prstatus,
+		sizeof(prstatus));
+	final_note(buf);
+}
=20
 void
 machine_crash_shutdown(struct pt_regs *pt)
@@ -32,8 +138,11 @@
 	 * In practice this means shooting down the other cpus in
 	 * an SMP system.
 	 */
-	if (in_interrupt())
+	if (in_interrupt()) {
 		ia64_eoi();
+	}
+	crash_save_this_cpu();
+	device_shootdown();
 #ifdef CONFIG_SMP
 	smp_send_stop();
 #endif
Index: linux//arch/ia64/kernel/efi.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//arch/ia64/kernel/efi.c	2006-08-17 1=
3:14:10.000000000 +0900
+++ linux//arch/ia64/kernel/efi.c	2006-08-17 13:13:50.000000000 +0900
@@ -26,6 +26,7 @@
 #include <linux/types.h>
 #include <linux/time.h>
 #include <linux/efi.h>
+#include <linux/kexec.h>
=20
 #include <asm/io.h>
 #include <asm/kregs.h>
@@ -41,7 +42,7 @@
 struct efi efi;
 EXPORT_SYMBOL(efi);
 static efi_runtime_services_t *runtime;
-static unsigned long mem_limit =3D ~0UL, max_addr =3D ~0UL;
+static unsigned long mem_limit =3D ~0UL, max_addr =3D ~0UL, min_addr =3D 0=
UL;
=20
 #define efi_call_virt(f, args...)	(*(f))(args)
=20
@@ -421,6 +422,8 @@
 			mem_limit =3D memparse(cp + 4, &cp);
 		} else if (memcmp(cp, "max_addr=3D", 9) =3D 0) {
 			max_addr =3D GRANULEROUNDDOWN(memparse(cp + 9, &cp));
+		} else if (memcmp(cp, "min_addr=3D", 9) =3D 0) {
+			min_addr =3D GRANULEROUNDDOWN(memparse(cp + 9, &cp));
 		} else {
 			while (*cp !=3D ' ' && *cp)
 				++cp;
@@ -428,6 +431,8 @@
 				++cp;
 		}
 	}
+	if (min_addr !=3D 0UL)
+		printk(KERN_INFO "Ignoring memory below %luMB\n", min_addr >> 20);
 	if (max_addr !=3D ~0UL)
 		printk(KERN_INFO "Ignoring memory above %luMB\n", max_addr >> 20);
=20
@@ -894,7 +899,8 @@
 		as =3D max(contig_low, md->phys_addr);
 		ae =3D min(contig_high, efi_md_end(md));
=20
-		/* keep within max_addr=3D command line arg */
+		/* keep within max_addr=3D and min_addr=3D command line arg */
+		as =3D max(as, min_addr);
 		ae =3D min(ae, max_addr);
 		if (ae <=3D as)
 			continue;
@@ -1004,7 +1010,8 @@
 		} else
 			ae =3D efi_md_end(md);
=20
-		/* keep within max_addr=3D command line arg */
+		/* keep within max_addr=3D and min_addr=3D command line arg */
+		as =3D max(as, min_addr);
 		ae =3D min(ae, max_addr);
 		if (ae <=3D as)
 			continue;
@@ -1116,6 +1123,10 @@
 			 */
 			insert_resource(res, code_resource);
 			insert_resource(res, data_resource);
+#ifdef CONFIG_KEXEC
+			if (crashk_res.end > crashk_res.start)
+				insert_resource(res, &crashk_res);
+#endif
 		}
 	}
 }
Index: linux//arch/ia64/kernel/machine_kexec.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//arch/ia64/kernel/machine_kexec.c	20=
06-08-17 13:14:10.000000000 +0900
+++ linux//arch/ia64/kernel/machine_kexec.c	2006-08-17 13:13:50.000000000 +=
0900
@@ -1,5 +1,5 @@
 /*
- * arch/ia64/kernel/machine_kexec.c
+ * arch/ia64/kernel/machine_kexec.c=20
  *
  * Handle transition of Linux booting another kernel
  * Copyright (C) 2005 Hewlett-Packard Development Comapny, L.P.
@@ -25,9 +25,7 @@
 #include <asm/delay.h>
 #include <asm/meminit.h>
=20
-extern unsigned long ia64_iobase;
-
-typedef void (*relocate_new_kernel_t)( unsigned long, unsigned long,
+typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
 		struct ia64_boot_param *, unsigned long);
=20
 /*
@@ -43,9 +41,9 @@
 	func =3D (unsigned long *)&relocate_new_kernel;
 	/* Pre-load control code buffer to minimize work in kexec path */
 	control_code_buffer =3D page_address(image->control_code_page);
-	memcpy((void *)control_code_buffer, (const void *)func[0],
+	memcpy((void *)control_code_buffer, (const void *)func[0],=20
 			relocate_new_kernel_size);
-	flush_icache_range((unsigned long)control_code_buffer,
+	flush_icache_range((unsigned long)control_code_buffer,=20
 			(unsigned long)control_code_buffer + relocate_new_kernel_size);
=20
 	return 0;
@@ -61,7 +59,6 @@
 	struct pci_dev *dev =3D NULL;
 	irq_desc_t *idesc;
 	cpumask_t mask =3D CPU_MASK_NONE;
-
 	/* Disable all PCI devices */
 	while ((dev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) !=3D NULL) {
 		if (!(dev->is_enabled))
@@ -91,7 +88,6 @@
 	smp_call_function(kexec_stop_this_cpu, (void *)image->start, 0, 0);
 #endif
=20
-	ia64_set_itv(1<<16);
=20
 #ifdef CONFIG_IA64_HP_ZX1
 	ioc_iova_disable();
@@ -100,41 +96,20 @@
=20
 /*
  * Do not allocate memory (or fail in any way) in machine_kexec().
- * We are past the point of no return, committed to rebooting now.
+ * We are past the point of no return, committed to rebooting now.=20
  */
+extern void *efi_get_pal_addr(void);
 void machine_kexec(struct kimage *image)
 {
-	unsigned long indirection_page;
 	relocate_new_kernel_t rnk;
-	unsigned long pta, impl_va_bits;
 	void *pal_addr =3D efi_get_pal_addr();
 	unsigned long code_addr =3D (unsigned long)page_address(image->control_co=
de_page);
-
 	/* Interrupts aren't acceptable while we reboot */
+	ia64_set_itv(1<<16);
 	local_irq_disable();
-
-	/* Disable VHPT */
-	impl_va_bits =3D ffz(~(local_cpu_data->unimpl_va_mask | (7UL << 61)));
-	pta =3D POW2(61) - POW2(vmlpt_bits);
-	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | 0);
-
-	/* now execute the control code.
-	 * We will start by executing the control code linked into the
-	 * kernel as opposed to the code we copied in control code buffer		 * pag=
e. When this code switches to physical mode, we will start
-	 * executing the code in control code buffer page. Reason for
-	 * doing this is we start code execution in virtual address space.
-	 * If we were to try to execute the newly copied code in virtual
-	 * address space, we will need to make an ITLB entry to avoid ITLB
-	 * miss. By executing the code linked into kernel, we take advantage
-	 * of the ITLB entry already in place for kernel and avoid making
-	 * a new entry.
-	 */
-	indirection_page =3D image->head & PAGE_MASK;
-
 	rnk =3D (relocate_new_kernel_t)&code_addr;
-	(*rnk)(indirection_page, image->start, ia64_boot_param,
+	(*rnk)(image->head, image->start, ia64_boot_param,
 		     GRANULEROUNDDOWN((unsigned long) pal_addr));
 	BUG();
-	for (;;)
-		;
+	for (;;);
 }
Index: linux//arch/ia64/kernel/relocate_kernel.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//arch/ia64/kernel/relocate_kernel.S	=
2006-08-17 13:14:10.000000000 +0900
+++ linux//arch/ia64/kernel/relocate_kernel.S	2006-08-17 13:13:50.000000000=
 +0900
@@ -1,5 +1,5 @@
 /*
- * arch/ia64/kernel/relocate_kernel.S
+ * arch/ia64/kernel/relocate_kernel.S=20
  *
  * Relocate kexec'able kernel and start it
  *
@@ -17,9 +17,7 @@
 #include <asm/pgtable.h>
 #include <asm/mca_asm.h>
=20
-       /* Must be relocatable PIC code callable as a C function, that once
-        * it starts can not use the previous processes stack.
-        *
+       /* Must be relocatable PIC code callable as a C function
         */
 GLOBAL_ENTRY(relocate_new_kernel)
 	.prologue
@@ -36,22 +34,16 @@
         srlz.i
 }
 	;;
-
+	dep r2=3D0,r2,61,3		//to physical address
+	;;
 	//first switch to physical mode
 	add r3=1F-.reloc_entry, r2
-	movl r16 =3D IA64_PSR_AC|IA64_PSR_BN|IA64_PSR_IC|IA64_PSR_MFL
+	movl r16 =3D IA64_PSR_AC|IA64_PSR_BN|IA64_PSR_IC
 	mov ar.rsc=3D0	          	// put RSE in enforced lazy mode
 	;;
-	add r2=3D(memory_stack-.reloc_entry), r2
-	;;
-	add sp=3D(memory_stack_end - .reloc_entry),r2
+	add sp=3D(memory_stack_end - 16 - .reloc_entry),r2
 	add r8=3D(register_stack - .reloc_entry),r2
 	;;
-	tpa sp=3Dsp
-	tpa r3=3Dr3
-	;;
-	loadrs
-	;;
 	mov r18=3Dar.rnat
 	mov ar.bspstore=3Dr8
 	;;
@@ -66,7 +58,7 @@
 1:
 	//physical mode code begin
 	mov b6=3Din1
-	tpa r28=3Din2			// tpa must before TLB purge
+	dep r28=3D0,in2,61,3	//to physical address
=20
 	// purge all TC entries
 #define O(member)       IA64_CPUINFO_##member##_OFFSET
@@ -145,10 +137,10 @@
         srlz.i
 	;;
=20
-	// copy kexec kernel segments
+	//copy segments
 	movl r16=3DPAGE_MASK
-	ld8  r30=3D[in0],8;;			// in0 is page_list
-	br.sptk.few .dest_page
+        mov  r30=3Din0                    // in0 is page_list
+        br.sptk.few .dest_page
 	;;
 .loop:
 	ld8  r30=3D[in0], 8;;
@@ -188,6 +180,8 @@
 	srlz.d
 	;;
 	br.call.sptk.many b0=B6;;
+
+.align  32
 memory_stack:
 	.fill           8192, 1, 0
 memory_stack_end:
@@ -310,7 +304,7 @@
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr0
 	br.few	call_start
-
+=09
 check_irr1:
 	mov	r8=3Dcr.irr1
 	;;
@@ -319,7 +313,7 @@
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr1
 	br.few	call_start
-
+=09
 check_irr2:
 	mov	r8=3Dcr.irr2
 	;;
@@ -328,7 +322,7 @@
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr2
 	br.few	call_start
-
+=09
 check_irr3:
 	mov	r8=3Dcr.irr3
 	;;
@@ -337,7 +331,7 @@
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr3
 	br.few	call_start
-
+=09
 call_start:
 	mov	cr.eoi=3Dr0
 	;;
Index: linux//arch/ia64/kernel/setup.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//arch/ia64/kernel/setup.c	2006-08-17=
 13:14:10.000000000 +0900
+++ linux//arch/ia64/kernel/setup.c	2006-08-17 13:13:50.000000000 +0900
@@ -43,6 +43,8 @@
 #include <linux/initrd.h>
 #include <linux/pm.h>
 #include <linux/cpufreq.h>
+#include <linux/kexec.h>
+#include <linux/crash_dump.h>
=20
 #include <asm/ia32.h>
 #include <asm/machvec.h>
@@ -250,6 +252,32 @@
 	}
 #endif
=20
+#ifdef CONFIG_KEXEC
+	/* crashkernel=3Dsize@addr specifies the location to reserve for
+	 * a crash kernel.  By reserving this memory we guarantee
+	 * that linux never set's it up as a DMA target.
+	 * Useful for holding code to do something appropriate
+	 * after a kernel panic.
+	 */
+	{
+		char *from =3D strstr(saved_command_line, "crashkernel=3D");
+		if (from) {
+			unsigned long size, base;
+			size =3D memparse(from + 12, &from);
+			if (*from =3D '@') {
+				base =3D memparse(from + 1, &from);
+				rsvd_region[n].start +					(unsigned long)__va(base);
+				rsvd_region[n].end +					(unsigned long)__va(base + size);
+				crashk_res.start =3D base;
+				crashk_res.end =3D base + size - 1;
+				n++;
+			}
+		}
+	}
+#endif
+
 	efi_memmap_init(&rsvd_region[n].start, &rsvd_region[n].end);
 	n++;
=20
@@ -484,6 +512,16 @@
 	if (!nomca)
 		ia64_mca_init();
=20
+#ifdef CONFIG_CRASH_DUMP
+	{
+		char *from =3D strstr(saved_command_line, "elfcorehdr=3D");
+
+		if (from)
+			elfcorehdr_addr =3D memparse(from+11, &from);
+		saved_max_pfn =3D (unsigned long) -1;
+	}
+#endif
+
 	platform_setup(cmdline_p);
 	paging_init();
 }
Index: linux//include/asm-ia64/kexec.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//include/asm-ia64/kexec.h	2006-08-17=
 13:14:10.000000000 +0900
+++ linux//include/asm-ia64/kexec.h	2006-08-17 13:13:50.000000000 +0900
@@ -21,14 +21,12 @@
 #define POW2(n)		(1ULL << (n))
=20
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
-
 const extern unsigned int relocate_new_kernel_size;
 volatile extern long kexec_rendez;
-extern void relocate_new_kernel(unsigned long, unsigned long,
+extern void relocate_new_kernel(unsigned long, unsigned long,=20
 		struct ia64_boot_param *, unsigned long);
 extern void kexec_fake_sal_rendez(void *start, unsigned long wake_up,
 		unsigned long pal_base);
-
 static inline void
 crash_setup_regs(struct pt_regs *newregs, struct pt_regs *oldregs)
 {
Index: linux//include/asm-ia64/meminit.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//include/asm-ia64/meminit.h	2006-08-=
17 13:14:10.000000000 +0900
+++ linux//include/asm-ia64/meminit.h	2006-08-17 13:13:50.000000000 +0900
@@ -15,11 +15,12 @@
  * 	- initrd (optional)
  * 	- command line string
  * 	- kernel code & data
+ * 	- crash dumping code reserved region
  * 	- Kernel memory map built from EFI memory map
  *
  * More could be added if necessary
  */
-#define IA64_MAX_RSVD_REGIONS 6
+#define IA64_MAX_RSVD_REGIONS 7
=20
 struct rsvd_region {
 	unsigned long start;	/* virtual address of beginning of element */
Index: linux//include/linux/irq.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//include/linux/irq.h	2006-08-17 13:1=
4:35.000000000 +0900
+++ linux//include/linux/irq.h	2006-08-17 13:13:50.000000000 +0900
@@ -182,6 +182,7 @@
 #include <asm/hw_irq.h>
=20
 extern int setup_irq(unsigned int irq, struct irqaction *new);
+extern void terminate_irqs(void);
=20
 #ifdef CONFIG_GENERIC_HARDIRQS
=20
Index: linux//kernel/irq/manage.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux.orig//kernel/irq/manage.c	2006-08-17 13:1=
4:10.000000000 +0900
+++ linux//kernel/irq/manage.c	2006-08-17 13:13:50.000000000 +0900
@@ -476,3 +476,22 @@
 }
 EXPORT_SYMBOL(request_irq);
=20
+/*
+ * Terminate any outstanding interrupts
+ */
+void terminate_irqs(void)
+{
+	struct irqaction * action;
+	irq_desc_t *idesc;
+	int i;
+
+	for (i=3D0; i < NR_IRQS; i++) {
+		idesc =3D irq_descp(i);
+		action =3D idesc->action;
+		if (!action)
+			continue;
+		if (idesc->handler->end)
+			idesc->handler->end(i);
+	}
+}
+

--

--=20
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

