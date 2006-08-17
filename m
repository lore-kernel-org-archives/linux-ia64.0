From: horms@tabatha.lab.ultramonkey.org
Date: Thu, 17 Aug 2006 07:07:23 +0000
Subject: [patch 4/5] kexec/kdump update (2006-08-17.00)
Message-Id: <20060817071455.381936000@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> Archived-At: <http://permalink.gmane.org/gmane.linux.ports.ia64/14677>
>=20
> This patch is the kexec-kdump patch re-based to 2.6.18-rc4 kernel.
>=20
> Changes since last patch include:
>=20
> 1. re-base the patch to 2.6.18-rc4
> 2. per-cpu register dumping, so that user space tool can unwind kernel st=
ack.
>    This should really done by INIT event. But unfortunately it seems that=
 the=20
>    firmware on the machine I am using does not handle INIT event correctl=
y...
>    So current I dump per-cpu registers by simple IPI.=20
> =09
> 3. fix on_line_cpu issue,=20
>    previous patch stop APs by smp_send_stop. AP will clear his bit in=20
>    cpu_online_map, then crash tools will see a cpu_online_map which only =

>    contains 1 cpu in vmcore file.
>=20
> 4. reserve efi memmap area and ia64 boot param area for the first kernel.
>=20
> To test crash dump.
>=20
> Compile a kernel with CONFIG_KEXEC CONFIG_CRASH_DUMP=20
> CONFIG_PROC_VMCORE enabled.
>=20
> using this kernel for both host kernel and crash dumping kernel.
>=20
> Boot this kernel with kernel parameter "crashkernel=3DXXX@YYY".
> XXX should be a size big enough for crash kernel to run, YYY should=20
> be a physical address which contains more than XXX memory and aligned to =
64M.
> you can check it in /proc/iomem.
> Be careful of choosing the size and address to reserve.
> The second kernel may hang silently if there is too few memory to use.
>=20
> After the first kernel boots, the "Crash kernel" region will show in /pro=
c/iomem.
> then load the same kernel with command.
>=20
> kexec -p vmlinux.gz --initrd=3Dinitrd --append=3D"root=3D... maxcpus=3D1"
>=20
> trigger a crash with echo c > /proc/sysrq-trigger
>=20
> after the crash kernel boots,=20
> copy /proc/vmcore to disk
>=20
> gdb vmlinux-of-first-kernel vmcore
> then you can check the stack and variables of first kernel.
>=20
> kexec -l + kexec -e may not work.
> That is because of a recent change in mpt-fusion driver=20
> shutdown code.=20
> There was some delay in mptscsih_remove path.=20
> the code was removed in 2.6.17, that cause MPT fusion driver unable to re=
initialize.
> add a delay back to mptscsih_remove can solve this problem.
>=20
>=20
> Signed-off-by:
>  Zou Nan hai <nanhai.zou@intel.com>

Incremental version of the patch posted by Zou Nan hai

Cc: Zou Nan hai <nanhai.zou@intel.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/crash.c           |   77 ++++++------------
 arch/ia64/kernel/efi.c             |    2=20
 arch/ia64/kernel/machine_kexec.c   |   66 ++++++++++------
 arch/ia64/kernel/relocate_kernel.S |  147 ++++++++++++++++++++++++++++++++=
++--
 arch/ia64/kernel/setup.c           |    9 ++
 arch/ia64/kernel/smp.c             |   18 ++++
 include/asm-ia64/kexec.h           |    6 +
 include/linux/irq.h                |    1=20
 kernel/irq/manage.c                |   13 ---
 9 files changed, 243 insertions(+), 96 deletions(-)

diff --git a/arch/ia64/kernel/crash.c b/arch/ia64/kernel/crash.c
index a1a192c..5b7514c 100644
--- a/arch/ia64/kernel/crash.c
+++ b/arch/ia64/kernel/crash.c
@@ -43,25 +43,23 @@ size_t copy_oldmem_page(unsigned long pf
=20
 static void device_shootdown(void)
 {
-       struct pci_dev *dev;
-       irq_desc_t *desc;
-       u16 pci_command;
+	irq_desc_t *idesc;
+	int irq;
+	for (irq =3D 0; irq < NR_IRQS; irq++) {
+		idesc =3D irq_desc + irq;
+		if (!idesc || !idesc->action)
+			continue;
+		disable_irq_nosync(irq);
+		idesc->chip->end(irq);
+		idesc->chip->shutdown(irq);
+	}
=20
-       list_for_each_entry(dev, &pci_devices, global_list) {
-	       desc =3D irq_desc + dev->irq;
-               if (!desc->action)
-                       continue;
-               pci_read_config_word(dev, PCI_COMMAND, &pci_command);
-               if (pci_command & PCI_COMMAND_MASTER) {
-                       pci_command &=3D ~PCI_COMMAND_MASTER;
-                       pci_write_config_word(dev, PCI_COMMAND, pci_command=
);
-               }
-               disable_irq_nosync(dev->irq);
-               desc->chip->end(dev->irq);
-       }
+#ifdef CONFIG_IA64_HP_ZX1
+	ioc_iova_disable();
+#endif
 }
=20
-static Elf64_Word
+static inline Elf64_Word
 *append_elf_note(Elf64_Word *buf, char *name, unsigned type, void *data,
 		size_t data_len)
 {
@@ -83,41 +81,25 @@ final_note(void *buf)
 	memset(buf, 0, sizeof(struct elf_note));
 }
=20
-static void
-crash_save_this_cpu(void)
+extern void ia64_dump_cpu_regs(void *);
+
+void
+crash_save_this_cpu()
 {
 	void *buf;
 	struct elf_prstatus prstatus;
 	int cpu =3D smp_processor_id();
+	unsigned long cfm, sof, sol;
 	elf_greg_t *dst =3D (elf_greg_t *)&prstatus.pr_reg;
-
 	memset(&prstatus, 0, sizeof(prstatus));
 	prstatus.pr_pid =3D current->pid;
=20
-    	dst[1] =3D ia64_getreg(_IA64_REG_GP);
-    	dst[12] =3D ia64_getreg(_IA64_REG_SP);
-    	dst[13] =3D ia64_getreg(_IA64_REG_TP);
-
-    	dst[42] =3D ia64_getreg(_IA64_REG_IP);
-    	dst[45] =3D ia64_getreg(_IA64_REG_AR_RSC);
-
-	ia64_setreg(_IA64_REG_AR_RSC, 0);
-	ia64_srlz_i();
-
-    	dst[46] =3D ia64_getreg(_IA64_REG_AR_BSP);
-    	dst[47] =3D ia64_getreg(_IA64_REG_AR_BSPSTORE);
-
-    	dst[48] =3D ia64_getreg(_IA64_REG_AR_RNAT);
-    	dst[49] =3D ia64_getreg(_IA64_REG_AR_CCV);
-    	dst[50] =3D ia64_getreg(_IA64_REG_AR_UNAT);
-
-    	dst[51] =3D ia64_getreg(_IA64_REG_AR_FPSR);
-    	dst[52] =3D ia64_getreg(_IA64_REG_AR_PFS);
-    	dst[53] =3D ia64_getreg(_IA64_REG_AR_LC);
-
-    	dst[54] =3D ia64_getreg(_IA64_REG_AR_LC);
-    	dst[55] =3D ia64_getreg(_IA64_REG_AR_CSD);
-    	dst[56] =3D ia64_getreg(_IA64_REG_AR_SSD);
+	ia64_dump_cpu_regs(dst);
+        cfm =3D dst[43];
+        sol =3D (cfm >> 7) & 0x7f;
+        sof =3D cfm & 0x7f;
+        dst[46] =3D (unsigned long)ia64_rse_skip_regs((unsigned long *)dst=
[46],
+                        sof - sol);
=20
         buf =3D (u64 *) per_cpu_ptr(crash_notes, cpu);
 	if (!buf)
@@ -138,15 +120,10 @@ machine_crash_shutdown(struct pt_regs *p
 	 * In practice this means shooting down the other cpus in
 	 * an SMP system.
 	 */
-	if (in_interrupt()) {
+	if (in_interrupt())
 		ia64_eoi();
-	}
-	crash_save_this_cpu();
 	device_shootdown();
 #ifdef CONFIG_SMP
-	smp_send_stop();
-#endif
-#ifdef CONFIG_IA64_HP_ZX1
-	ioc_iova_disable();
+	kdump_smp_send_stop();
 #endif
 }
diff --git a/arch/ia64/kernel/efi.c b/arch/ia64/kernel/efi.c
index 52729a9..6935452 100644
--- a/arch/ia64/kernel/efi.c
+++ b/arch/ia64/kernel/efi.c
@@ -1124,6 +1124,8 @@ efi_initialize_iomem_resources(struct re
 			insert_resource(res, code_resource);
 			insert_resource(res, data_resource);
 #ifdef CONFIG_KEXEC
+                        insert_resource(res, &efi_memmap_res);
+                        insert_resource(res, &boot_param_res);
 			if (crashk_res.end > crashk_res.start)
 				insert_resource(res, &crashk_res);
 #endif
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
diff --git a/arch/ia64/kernel/machine_kexec.c b/arch/ia64/kernel/machine_ke=
xec.c
index 573a6b8..2073a3d 100644
--- a/arch/ia64/kernel/machine_kexec.c
+++ b/arch/ia64/kernel/machine_kexec.c
@@ -1,5 +1,5 @@
 /*
- * arch/ia64/kernel/machine_kexec.c=20
+ * arch/ia64/kernel/machine_kexec.c
  *
  * Handle transition of Linux booting another kernel
  * Copyright (C) 2005 Hewlett-Packard Development Comapny, L.P.
@@ -27,6 +27,21 @@ #include <asm/meminit.h>
=20
 typedef void (*relocate_new_kernel_t)(unsigned long, unsigned long,
 		struct ia64_boot_param *, unsigned long);
+static struct kimage *ia64_kimage;
+struct resource efi_memmap_res =3D {
+        .name  =3D "EFI Memory Map",
+        .start =3D 0,
+        .end   =3D 0,
+        .flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
+};
+
+struct resource boot_param_res =3D {
+        .name  =3D "Boot parameter",
+        .start =3D 0,
+        .end   =3D 0,
+        .flags =3D IORESOURCE_BUSY | IORESOURCE_MEM
+};
+
=20
 /*
  * Do what every setup is needed on image and the
@@ -41,10 +56,11 @@ int machine_kexec_prepare(struct kimage=20
 	func =3D (unsigned long *)&relocate_new_kernel;
 	/* Pre-load control code buffer to minimize work in kexec path */
 	control_code_buffer =3D page_address(image->control_code_page);
-	memcpy((void *)control_code_buffer, (const void *)func[0],=20
+	memcpy((void *)control_code_buffer, (const void *)func[0],
 			relocate_new_kernel_size);
-	flush_icache_range((unsigned long)control_code_buffer,=20
+	flush_icache_range((unsigned long)control_code_buffer,
 			(unsigned long)control_code_buffer + relocate_new_kernel_size);
+	ia64_kimage =3D image;
=20
 	return 0;
 }
@@ -55,26 +71,6 @@ void machine_kexec_cleanup(struct kimage
=20
 void machine_shutdown(void)
 {
-#ifdef CONFIG_PCI
-	struct pci_dev *dev =3D NULL;
-	irq_desc_t *idesc;
-	cpumask_t mask =3D CPU_MASK_NONE;
-	/* Disable all PCI devices */
-	while ((dev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) !=3D NULL) {
-		if (!(dev->is_enabled))
-			continue;
-		idesc =3D irq_desc + dev->irq;
-		if (!idesc)
-			continue;
-		cpu_set(0, mask);
-		disable_irq_nosync(dev->irq);
-		idesc->chip->end(dev->irq);
-		idesc->chip->set_affinity(dev->irq, mask);
-		idesc->action =3D NULL;
-		pci_disable_device(dev);
-	}
-#endif
-
 #ifdef CONFIG_HOTPLUG_CPU
 	{
 		int cpu;
@@ -85,7 +81,25 @@ #ifdef CONFIG_HOTPLUG_CPU
 		}
 	}
 #elif defined(CONFIG_SMP)
-	smp_call_function(kexec_stop_this_cpu, (void *)image->start, 0, 0);
+	smp_call_function(kexec_stop_this_cpu, (void *)ia64_kimage->start, 0, 0);
+#endif
+#ifdef CONFIG_PCI
+	{
+		struct pci_dev *dev =3D NULL;
+		irq_desc_t *idesc;
+		/* Disable all PCI devices */
+		while ((dev =3D pci_get_device(PCI_ANY_ID, PCI_ANY_ID, dev)) !=3D NULL) {
+			if (!(dev->is_enabled))
+				continue;
+			idesc =3D irq_desc + dev->irq;
+			if (!idesc||!idesc->chip)
+				continue;
+			disable_irq_nosync(dev->irq);
+			idesc->chip->end(dev->irq);
+			idesc->action =3D NULL;
+			pci_disable_device(dev);
+		}
+	}
 #endif
=20
=20
@@ -96,7 +110,7 @@ #endif
=20
 /*
  * Do not allocate memory (or fail in any way) in machine_kexec().
- * We are past the point of no return, committed to rebooting now.=20
+ * We are past the point of no return, committed to rebooting now.
  */
 extern void *efi_get_pal_addr(void);
 void machine_kexec(struct kimage *image)
@@ -104,6 +118,8 @@ void machine_kexec(struct kimage *image)
 	relocate_new_kernel_t rnk;
 	void *pal_addr =3D efi_get_pal_addr();
 	unsigned long code_addr =3D (unsigned long)page_address(image->control_co=
de_page);
+	if (image->type =3D KEXEC_TYPE_CRASH)
+		crash_save_this_cpu();
 	/* Interrupts aren't acceptable while we reboot */
 	ia64_set_itv(1<<16);
 	local_irq_disable();
diff --git a/arch/ia64/kernel/relocate_kernel.S b/arch/ia64/kernel/relocate=
_kernel.S
index 09bd041..ffc1bde 100644
--- a/arch/ia64/kernel/relocate_kernel.S
+++ b/arch/ia64/kernel/relocate_kernel.S
@@ -1,5 +1,5 @@
 /*
- * arch/ia64/kernel/relocate_kernel.S=20
+ * arch/ia64/kernel/relocate_kernel.S
  *
  * Relocate kexec'able kernel and start it
  *
@@ -304,7 +304,7 @@ check_irr0:
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr0
 	br.few	call_start
-=09
+
 check_irr1:
 	mov	r8=3Dcr.irr1
 	;;
@@ -313,7 +313,7 @@ check_irr1:
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr1
 	br.few	call_start
-=09
+
 check_irr2:
 	mov	r8=3Dcr.irr2
 	;;
@@ -322,7 +322,7 @@ check_irr2:
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr2
 	br.few	call_start
-=09
+
 check_irr3:
 	mov	r8=3Dcr.irr3
 	;;
@@ -331,7 +331,7 @@ check_irr3:
 	cmp.eq	p6,p0=3D0,r8
 (p6)	br.cond.sptk.few	check_irr3
 	br.few	call_start
-=09
+
 call_start:
 	mov	cr.eoi=3Dr0
 	;;
@@ -351,3 +351,140 @@ END(kexec_fake_sal_rendez)
 relocate_new_kernel_size:
 	data8	kexec_fake_sal_rendez_end - relocate_new_kernel
=20
+GLOBAL_ENTRY(ia64_dump_cpu_regs)
+        .prologue
+        alloc loc0=3Dar.pfs,1,2,0,0
+        .body
+        mov     ar.rsc=3D0                // put RSE in enforced lazy mode
+        add     loc1=3D4*8, in0           // save r4 and r5 first
+        ;;
+{
+        flushrs                         // flush dirty regs to backing sto=
re
+        srlz.i
+}
+        st8 [loc1]=3Dr4, 8
+        ;;
+        st8 [loc1]=3Dr5, 8
+        ;;
+        add loc12*8, in0
+        mov r4=3Dar.rnat
+        ;;
+        st8 [in0]=3Dr0, 8			// r0
+        st8 [loc1]=3Dr4, 8		// rnat
+        mov r5=3Dpr
+        ;;
+        st8 [in0]=3Dr1, 8			// r1
+        st8 [loc1]=3Dr5, 8		// pr
+        mov r4=B0
+        ;;
+        st8 [in0]=3Dr2, 8			// r2
+        st8 [loc1]=3Dr4, 8		// b0
+        mov r5=B1;
+        ;;
+        st8 [in0]=3Dr3, 24		// r3
+        st8 [loc1]=3Dr5, 8		// b1
+        mov r4=B2
+        ;;
+        st8 [in0]=3Dr6, 8			// r6
+        st8 [loc1]=3Dr4, 8		// b2
+	mov r5=B3
+        ;;
+        st8 [in0]=3Dr7, 8			// r7
+        st8 [loc1]=3Dr5, 8		// b3
+        mov r4=B4
+        ;;
+        st8 [in0]=3Dr8, 8			// r8
+        st8 [loc1]=3Dr4, 8		// b4
+        mov r5=B5
+        ;;
+        st8 [in0]=3Dr9, 8			// r9
+        st8 [loc1]=3Dr5, 8		// b5
+        mov r4=B6
+        ;;
+        st8 [in0]=3Dr10, 8		// r10
+        st8 [loc1]=3Dr5, 8		// b6
+        mov r5=B7
+        ;;
+        st8 [in0]=3Dr11, 8		// r11
+        st8 [loc1]=3Dr5, 8		// b7
+        mov r4=B0
+        ;;
+        st8 [in0]=3Dr12, 8		// r12
+        st8 [loc1]=3Dr4, 8		// ip
+        mov r5=3Dloc0
+	;;
+        st8 [in0]=3Dr13, 8		// r13
+        extr.u r5=3Dr5, 0, 38		// ar.pfs.pfm
+	mov r4=3Dr0			// user mask
+        ;;
+        st8 [in0]=3Dr14, 8		// r14
+        st8 [loc1]=3Dr5, 8		// cfm
+        ;;
+        st8 [in0]=3Dr15, 8		// r15
+        st8 [loc1]=3Dr4, 8        	// user mask
+	mov r5=3Dar.rsc
+        ;;
+        st8 [in0]=3Dr16, 8		// r16
+        st8 [loc1]=3Dr5, 8        	// ar.rsc
+        mov r4=3Dar.bsp
+        ;;
+        st8 [in0]=3Dr17, 8		// r17
+        st8 [loc1]=3Dr4, 8        	// ar.bsp
+        mov r5=3Dar.bspstore
+        ;;
+        st8 [in0]=3Dr18, 8		// r18
+        st8 [loc1]=3Dr5, 8        	// ar.bspstore
+        mov r4=3Dar.rnat
+        ;;
+        st8 [in0]=3Dr19, 8		// r19
+        st8 [loc1]=3Dr4, 8        	// ar.rnat
+        mov r5=3Dar.ccv
+        ;;
+        st8 [in0]=3Dr20, 8		// r20
+	st8 [loc1]=3Dr5, 8        	// ar.ccv
+        mov r4=3Dar.unat
+        ;;
+        st8 [in0]=3Dr21, 8		// r21
+        st8 [loc1]=3Dr4, 8        	// ar.unat
+        mov r5 =3D ar.fpsr
+        ;;
+        st8 [in0]=3Dr22, 8		// r22
+        st8 [loc1]=3Dr5, 8        	// ar.fpsr
+        mov r4 =3D ar.unat
+        ;;
+        st8 [in0]=3Dr23, 8		// r23
+        st8 [loc1]=3Dr4, 8        	// unat
+        mov r5 =3D ar.fpsr
+        ;;
+        st8 [in0]=3Dr24, 8		// r24
+        st8 [loc1]=3Dr5, 8        	// fpsr
+        mov r4 =3D ar.pfs
+        ;;
+        st8 [in0]=3Dr25, 8		// r25
+        st8 [loc1]=3Dr4, 8        	// ar.pfs
+        mov r5 =3D ar.lc
+        ;;
+        st8 [in0]=3Dr26, 8		// r26
+        st8 [loc1]=3Dr5, 8        	// ar.lc
+        mov r4 =3D ar.ec
+        ;;
+        st8 [in0]=3Dr27, 8		// r27
+        st8 [loc1]=3Dr4, 8        	// ar.ec
+        mov r5 =3D ar.csd
+        ;;
+        st8 [in0]=3Dr28, 8		// r28
+        st8 [loc1]=3Dr5, 8        	// ar.csd
+        mov r4 =3D ar.ssd
+        ;;
+        st8 [in0]=3Dr29, 8		// r29
+        st8 [loc1]=3Dr4, 8        	// ar.ssd
+        ;;
+        st8 [in0]=3Dr30, 8		// r30
+        ;;
+	st8 [in0]=3Dr31, 8		// r31
+        mov ar.pfs=3Dloc0
+        ;;
+        br.ret.sptk.many rp
+END(ia64_dump_cpu_regs)
+
+
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 74821be..14ee171 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -275,6 +275,15 @@ #ifdef CONFIG_KEXEC
 				n++;
 			}
 		}
+		efi_memmap_res.start =3D ia64_boot_param->efi_memmap;
+                efi_memmap_res.end =3D efi_memmap_res.start +
+                        ia64_boot_param->efi_memmap_size;
+                printk("efi_memmap start %lx %lx\n",
+                        efi_memmap_res.start,
+                        efi_memmap_res.end);
+                boot_param_res.start =3D __pa(ia64_boot_param);
+                boot_param_res.end =3D boot_param_res.start +
+                        sizeof(*ia64_boot_param);
 	}
 #endif
=20
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 6337278..dee9fd7 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -67,6 +67,7 @@ static volatile struct call_data_struct=20
=20
 #define IPI_CALL_FUNC		0
 #define IPI_CPU_STOP		1
+#define IPI_KDUMP_CPU_STOP	3
=20
 /* This needs to be cacheline aligned because it is written to by *other* =
CPUs.  */
 static DEFINE_PER_CPU(u64, ipi_operation) ____cacheline_aligned;
@@ -184,7 +185,15 @@ handle_IPI (int irq, void *dev_id, struc
 			      case IPI_CPU_STOP:
 				stop_this_cpu();
 				break;
-
+#ifdef CONFIG_CRASH_DUMP
+			      case IPI_KDUMP_CPU_STOP:
+				{
+					local_irq_disable();
+					crash_save_this_cpu();
+					cpu_halt();
+				}
+				break;
+#endif
 			      default:
 				printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
 				break;
@@ -400,6 +409,13 @@ smp_send_stop (void)
 {
 	send_IPI_allbutself(IPI_CPU_STOP);
 }
+#ifdef CONFIG_CRASH_DUMP
+void
+kdump_smp_send_stop()
+{
+ 	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
+}
+#endif
=20
 int __init
 setup_profiling_timer (unsigned int multiplier)
diff --git a/include/asm-ia64/kexec.h b/include/asm-ia64/kexec.h
index d45c03f..a035136 100644
--- a/include/asm-ia64/kexec.h
+++ b/include/asm-ia64/kexec.h
@@ -23,7 +23,7 @@ #define POW2(n)		(1ULL << (n))
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
 const extern unsigned int relocate_new_kernel_size;
 volatile extern long kexec_rendez;
-extern void relocate_new_kernel(unsigned long, unsigned long,=20
+extern void relocate_new_kernel(unsigned long, unsigned long,
 		struct ia64_boot_param *, unsigned long);
 extern void kexec_fake_sal_rendez(void *start, unsigned long wake_up,
 		unsigned long pal_base);
@@ -31,4 +31,8 @@ static inline void
 crash_setup_regs(struct pt_regs *newregs, struct pt_regs *oldregs)
 {
 }
+extern struct resource efi_memmap_res;
+extern struct resource boot_param_res;
+extern void kdump_smp_send_stop(void);
+extern void crash_save_this_cpu(void);
 #endif /* _ASM_IA64_KEXEC_H */
diff --git a/include/asm-ia64/machvec_hpzx1.h b/include/asm-ia64/machvec_hp=
zx1.h
diff --git a/include/asm-ia64/meminit.h b/include/asm-ia64/meminit.h
diff --git a/include/asm-ia64/smp.h b/include/asm-ia64/smp.h
diff --git a/include/linux/irq.h b/include/linux/irq.h
index 9b5349f..fbf6d90 100644
--- a/include/linux/irq.h
+++ b/include/linux/irq.h
@@ -182,7 +182,6 @@ typedef struct irq_desc		irq_desc_t;
 #include <asm/hw_irq.h>
=20
 extern int setup_irq(unsigned int irq, struct irqaction *new);
-extern void terminate_irqs(void);
=20
 #ifdef CONFIG_GENERIC_HARDIRQS
=20
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index e058bad..a795d6f 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -475,16 +475,3 @@ #endif
 	return retval;
 }
 EXPORT_SYMBOL(request_irq);
-
-/*
- * Terminate any outstanding interrupts
- */
-void terminate_irqs(void)
-{
-	irq_desc_t *desc =3D irq_desc;
-	int i;
-
-	for (i =3D 0; i < NR_IRQS; i++, desc++)
-		if (desc->action && desc->chip->end)
-			desc->chip->end(i);
-}

--

--=20
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

