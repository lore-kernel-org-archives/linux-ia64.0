From: David Mosberger <davidm@hpl.hp.com>
Date: Mon, 23 Jul 2001 23:49:32 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.7)
Message-Id: <marc-linux-ia64-105590693005877@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.7-ia64-010723.diff*.

There are no major new features in this patch but mostly bug fixes and
syncing up with 2.4.7.  Note that 2.4.7 introduces a somewhat
non-trivial change in how softirqs are handled: they are now checked
only as a result of a hard irq and not every time the kernel returns
to user mode.  While I'm not particularly happy to see such changes
this late in the 2.4.x series, I do believe it is safe and I have been
running a fairly busy machine since Saturday without any problems.  As
usual your mileage may vary, so test well before you ship with this
kernel.

One big caveat: the ACPI power management does NOT work at the moment.
Do not turn on CONFIG_ACPI_BUSMGR etc. or you may end up with a
non-booting system.  Intel is working on fixing this, so stay tuned.

More detailed change log:

	- more McKinley related updates from Alex
	- get legacy I/O base address from EFI memory map (Alex)
	- mark MMX and FXSR extensions as available in IA-32 mode (Asit)
	- add support for placing per-CPU data in NUMA-node local memory (Jack)
	- perfmon fix from Stephane
	- more error checking in IA-32 subsystem (based on patch from Arnaldo)
	- drop support for A-step CPUs
	- make iosapic_set_affinity() a no-op on UP machines
	- update /proc/cpuinfo to output "CPU family" info in a manner consistent
	  with Intel's interpretation of this field; specifically, the architecture
	  (IA-64) is now listed with tag "arch" and the "family" tag now contains
	  "Itanium", "McKinley", or whatever...
	- fix copy_user() to work properly with PIPE_DEPTH!=3D4 (this patch was al=
ready
	  sent to the list earlier on)
	- fix time conversion in "joydev" driver
	- merge in QLA 2100 driver from Qlogic

As usual the patch below is fyi only.

Note: I'd like to remove support for B0-B2 step CPUs asap.  If you
really need support for such old CPUs, make your case now... ;-)

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/config.in linux-2.4.7-lia/arch/ia64/config=
.in
--- linux-davidm/arch/ia64/config.in	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/config.in	Mon Jul 23 14:00:15 2001
@@ -25,9 +25,12 @@
 define_bool CONFIG_SBUS n
 define_bool CONFIG_RWSEM_GENERIC_SPINLOCK y
 define_bool CONFIG_RWSEM_XCHGADD_ALGORITHM n
-define_bool CONFIG_ACPI y
-define_bool CONFIG_ACPI_INTERPRETER y
-define_bool CONFIG_ACPI_KERNEL_CONFIG y
+
+if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
+  define_bool CONFIG_ACPI y
+  define_bool CONFIG_ACPI_INTERPRETER y
+  define_bool CONFIG_ACPI_KERNEL_CONFIG y
+fi
=20
 choice 'IA-64 processor type' \
 	"Itanium			CONFIG_ITANIUM \
@@ -47,7 +50,6 @@
=20
 if [ "$CONFIG_ITANIUM" =3D "y" ]; then
 	define_bool CONFIG_IA64_BRL_EMU y
-	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
 	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
 	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECIF=
IC
@@ -62,7 +64,7 @@
 	if [ "$CONFIG_ITANIUM_CSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium C0-step specific code' CONFIG_ITANIUM_C0_SPECIF=
IC
 	fi
-	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" =3D "y" -o "$CONFIG_ITANIUM_B0_SPEC=
IFIC" =3D "y" \
+	if [ "$CONFIG_ITANIUM_B0_SPECIFIC" =3D "y" \
 	     -o "$CONFIG_ITANIUM_B1_SPECIFIC" =3D "y" -o "$CONFIG_ITANIUM_B2_SPEC=
IFIC" =3D "y" ]; then
 	  define_bool CONFIG_ITANIUM_PTCG n
 	else
@@ -87,7 +89,6 @@
 if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
 	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
-	bool '  Enable ACPI 2.0 with errata 1.3' CONFIG_ACPI20
 	define_bool CONFIG_PM y
 fi
=20
@@ -121,6 +122,8 @@
=20
 if [ "$CONFIG_IA64_HP_SIM" =3D "n" ]; then
=20
+source drivers/acpi/Config.in
+
 bool 'PCI support' CONFIG_PCI
 source drivers/pci/Config.in
=20
@@ -244,6 +247,10 @@
 endmenu
=20
 source drivers/usb/Config.in
+
+if [ "$CONFIG_EXPERIMENTAL" =3D "y" ]; then
+   source net/bluetooth/Config.in
+fi
=20
 fi # !HP_SIM
=20
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.7-lia/arch/ia64/=
ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/ia32/sys_ia32.c	Mon Jul 23 14:00:32 2001
@@ -232,10 +232,17 @@
 	back =3D NULL;
 	if ((baddr =3D (addr & PAGE_MASK)) !=3D addr && get_user(c, (char *)baddr=
) =3D 0) {
 		front =3D kmalloc(addr - baddr, GFP_KERNEL);
+		if (!front)
+			return -ENOMEM;
 		__copy_user(front, (void *)baddr, addr - baddr);
 	}
 	if (addr && ((addr + len) & ~PAGE_MASK) && get_user(c, (char *)(addr + le=
n)) =3D 0) {
 		back =3D kmalloc(PAGE_SIZE - ((addr + len) & ~PAGE_MASK), GFP_KERNEL);
+		if (!back) {
+			if (front)
+				kfree(front);
+			return -ENOMEM;
+		}
 		__copy_user(back, (char *)addr + len, PAGE_SIZE - ((addr + len) & ~PAGE_=
MASK));
 	}
 	down_write(&current->mm->mmap_sem);
@@ -660,9 +667,11 @@
 	long ret;
=20
 	if (times32) {
-		get_user(tv[0].tv_sec, &times32->atime);
+		if (get_user(tv[0].tv_sec, &times32->atime))
+			return -EFAULT;
 		tv[0].tv_usec =3D 0;
-		get_user(tv[1].tv_sec, &times32->mtime);
+		if (get_user(tv[1].tv_sec, &times32->mtime))
+			return -EFAULT;
 		tv[1].tv_usec =3D 0;
 		set_fs (KERNEL_DS);
 		tvp =3D tv;
@@ -747,15 +756,18 @@
 	buf->error =3D -EINVAL;	/* only used if we fail.. */
 	if (reclen > buf->count)
 		return -EINVAL;
+	buf->error =3D -EFAULT;	/* only used if we fail.. */
 	dirent =3D buf->previous;
 	if (dirent)
-		put_user(offset, &dirent->d_off);
+		if (put_user(offset, &dirent->d_off))
+			return -EFAULT;
 	dirent =3D buf->current_dir;
 	buf->previous =3D dirent;
-	put_user(ino, &dirent->d_ino);
-	put_user(reclen, &dirent->d_reclen);
-	copy_to_user(dirent->d_name, name, namlen);
-	put_user(0, dirent->d_name + namlen);
+	if (put_user(ino, &dirent->d_ino)
+	    || put_user(reclen, &dirent->d_reclen)
+	    || copy_to_user(dirent->d_name, name, namlen)
+	    || put_user(0, dirent->d_name + namlen))
+		return -EFAULT;
 	((char *) dirent) +=3D reclen;
 	buf->current_dir =3D dirent;
 	buf->count -=3D reclen;
@@ -786,7 +798,9 @@
 	error =3D buf.error;
 	lastdirent =3D buf.previous;
 	if (lastdirent) {
-		put_user(file->f_pos, &lastdirent->d_off);
+		error =3D -EINVAL;
+		if (put_user(file->f_pos, &lastdirent->d_off))
+			goto out_putf;
 		error =3D count - buf.count;
 	}
=20
@@ -807,11 +821,12 @@
 		return -EINVAL;
 	buf->count++;
 	dirent =3D buf->dirent;
-	put_user(ino, &dirent->d_ino);
-	put_user(offset, &dirent->d_offset);
-	put_user(namlen, &dirent->d_namlen);
-	copy_to_user(dirent->d_name, name, namlen);
-	put_user(0, dirent->d_name + namlen);
+	if (put_user(ino, &dirent->d_ino)
+	    || put_user(offset, &dirent->d_offset)
+	    || put_user(namlen, &dirent->d_namlen)
+	    || copy_to_user(dirent->d_name, name, namlen)
+	    || put_user(0, dirent->d_name + namlen))
+		return -EFAULT;
 	return 0;
 }
=20
@@ -862,8 +877,10 @@
 	if (tvp32) {
 		time_t sec, usec;
=20
-		get_user(sec, &tvp32->tv_sec);
-		get_user(usec, &tvp32->tv_usec);
+		ret =3D -EFAULT;
+		if (get_user(sec, &tvp32->tv_sec)
+		    || get_user(usec, &tvp32->tv_usec))
+			goto out_nofds;
=20
 		ret =3D -EINVAL;
 		if (sec < 0 || usec < 0)
@@ -916,8 +933,12 @@
 			usec =3D timeout % HZ;
 			usec *=3D (1000000/HZ);
 		}
-		put_user(sec, (int *)&tvp32->tv_sec);
-		put_user(usec, (int *)&tvp32->tv_usec);
+		if (put_user(sec, (int *)&tvp32->tv_sec)
+		    || put_user(usec, (int *)&tvp32->tv_usec))
+		{
+			ret =3D -EFAULT;
+			goto out;
+		}
 	}
=20
 	if (ret < 0)
@@ -1558,16 +1579,15 @@
 {
 	union semun fourth;
 	u32 pad;
-	int err, err2;
+	int err =3D 0, err2;
 	struct semid64_ds s;
 	struct semid_ds32 *usp;
 	mm_segment_t old_fs;
=20
 	if (!uptr)
 		return -EINVAL;
-	err =3D -EFAULT;
-	if (get_user (pad, (u32 *)uptr))
-		return err;
+	if (get_user(pad, (u32 *)uptr))
+		return -EFAULT;
 	if(third =3D SETVAL)
 		fourth.val =3D (int)pad;
 	else
@@ -1749,15 +1769,14 @@
 {
 	unsigned long raddr;
 	u32 *uaddr =3D (u32 *)A((u32)third);
-	int err =3D -EINVAL;
+	int err;
=20
 	if (version =3D 1)
-		return err;
+		return -EINVAL;
 	err =3D sys_shmat (first, uptr, second, &raddr);
 	if (err)
 		return err;
-	err =3D put_user (raddr, uaddr);
-	return err;
+	return put_user(raddr, uaddr);
 }
=20
 static int
@@ -2124,7 +2143,7 @@
 	case PT_CS:
 		return((unsigned int)__USER_CS);
 	default:
-		printk("getregs:unknown register %d\n", regno);
+		printk(KERN_ERR "getregs:unknown register %d\n", regno);
 		break;
=20
 	}
@@ -2176,14 +2195,16 @@
 	case PT_GS:
 	case PT_SS:
 		if (value !=3D __USER_DS)
-			printk("setregs:try to set invalid segment register %d =3D %x\n", regno=
, value);
+			printk(KERN_ERR "setregs:try to set invalid segment register %d =3D %x\=
n",
+			       regno, value);
 		break;
 	case PT_CS:
 		if (value !=3D __USER_CS)
-			printk("setregs:try to set invalid segment register %d =3D %x\n", regno=
, value);
+			printk(KERN_ERR "setregs:try to set invalid segment register %d =3D %x\=
n",
+			       regno, value);
 		break;
 	default:
-		printk("getregs:unknown register %d\n", regno);
+		printk(KERN_ERR "getregs:unknown register %d\n", regno);
 		break;
=20
 	}
@@ -2239,7 +2260,6 @@
=20
 	}
 	__copy_to_user(reg, f, sizeof(*reg));
-	return;
 }
=20
 void
@@ -2546,8 +2566,8 @@
 {
 	struct pt_regs *regs =3D (struct pt_regs *)&stack;
=20
-	printk("IA32 syscall #%d issued, maybe we should implement it\n",
-		(int)regs->r1);
+	printk(KERN_WARNING "IA32 syscall #%d issued, maybe we should implement i=
t\n",
+	       (int)regs->r1);
 	return(sys_ni_syscall());
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/acpi.c linux-2.4.7-lia/arch/ia64/ke=
rnel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/acpi.c	Mon Jul 23 14:00:58 2001
@@ -205,11 +205,16 @@
 		case ACPI20_ENTRY_IO_SAPIC:
 			iosapic =3D (acpi_entry_iosapic_t *) p;
 			if (iosapic_init)
-				iosapic_init(iosapic->address, iosapic->irq_base);
+				/*
+				 * The PCAT_COMPAT flag indicates that the system has a
+				 * dual-8259 compatible setup.
+				 */
+				iosapic_init(iosapic->address, iosapic->irq_base,
+					     (madt->flags & MADT_PCAT_COMPAT));
 			break;
=20
 		case ACPI20_ENTRY_PLATFORM_INT_SOURCE:
-			printk("ACPI 2.0 MADT: PLATFORM INT SOUCE\n");
+			printk("ACPI 2.0 MADT: PLATFORM INT SOURCE\n");
 			acpi20_platform(p);
 			break;
=20
@@ -256,6 +261,7 @@
 int __init
 acpi20_parse (acpi20_rsdp_t *rsdp20)
 {
+# ifdef CONFIG_ACPI
 	acpi_xsdt_t *xsdt;
 	acpi_desc_table_hdr_t *hdrp;
 	int tables, i;
@@ -304,13 +310,14 @@
=20
 	acpi_cf_terminate();
=20
-#ifdef CONFIG_SMP
+#  ifdef CONFIG_SMP
 	if (available_cpus =3D 0) {
 		printk("ACPI: Found 0 CPUS; assuming 1\n");
 		available_cpus =3D 1; /* We've got at least one of these, no? */
 	}
 	smp_boot_data.cpu_count =3D total_cpus;
-#endif
+#  endif
+# endif /* CONFIG_ACPI */
 	return 1;
 }
 /*
@@ -390,7 +397,12 @@
 		      case ACPI_ENTRY_IO_SAPIC:
 			iosapic =3D (acpi_entry_iosapic_t *) p;
 			if (iosapic_init)
-				iosapic_init(iosapic->address, iosapic->irq_base);
+				/*
+				 * The ACPI I/O SAPIC table doesn't have a PCAT_COMPAT
+				 * flag like the MADT table, but we can safely assume that
+				 * ACPI 1.0b systems have a dual-8259 setup.
+				 */
+				iosapic_init(iosapic->address, iosapic->irq_base, 1);
 			break;
=20
 		      case ACPI_ENTRY_INT_SRC_OVERRIDE:
@@ -416,6 +428,7 @@
 int __init
 acpi_parse (acpi_rsdp_t *rsdp)
 {
+# ifdef CONFIG_ACPI
 	acpi_rsdt_t *rsdt;
 	acpi_desc_table_hdr_t *hdrp;
 	long tables, i;
@@ -449,12 +462,13 @@
=20
 	acpi_cf_terminate();
=20
-#ifdef CONFIG_SMP
+#  ifdef CONFIG_SMP
 	if (available_cpus =3D 0) {
 		printk("ACPI: Found 0 CPUS; assuming 1\n");
 		available_cpus =3D 1; /* We've got at least one of these, no? */
 	}
 	smp_boot_data.cpu_count =3D total_cpus;
-#endif
+#  endif
+# endif /* CONFIG_ACPI */
 	return 1;
 }
diff -urN linux-davidm/arch/ia64/kernel/efi.c linux-2.4.7-lia/arch/ia64/ker=
nel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/efi.c	Mon Jul 23 14:01:11 2001
@@ -453,6 +453,32 @@
 	efi.reset_system =3D __va(runtime->reset_system);
 }
=20
+/*
+ * Walk the EFI memory map looking for the I/O port range.  There can only=
 be one entry of
+ * this type, other I/O port ranges should be described via ACPI.
+ */
+u64
+efi_get_iobase (void)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+
+	efi_map_start =3D __va(ia64_boot_param->efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param->efi_memdesc_size;
+
+	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
+		md =3D p;
+		if (md->type =3D EFI_MEMORY_MAPPED_IO_PORT_SPACE) {
+			/* paranoia attribute checking */
+			if (md->attribute =3D (EFI_MEMORY_UC | EFI_MEMORY_RUNTIME))
+				return md->phys_addr;
+		}
+	}
+	return 0;
+}
+
 static void __exit
 efivars_exit(void)
 {
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.7-lia/arch/ia64/k=
ernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/entry.S	Mon Jul 23 14:01:24 2001
@@ -212,23 +212,20 @@
 	.save @priunat,r17
 	mov r17=3Dar.unat		// preserve caller's
 	.body
-#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
-      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
+#if !(defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPE=
CIFIC))
 	adds r3=80,sp
 	;;
 	lfetch.fault.excl.nt1 [r3],128
 #endif
 	mov ar.rsc=3D0		// put RSE in mode: enforced lazy, little endian, pl 0
-#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
-      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
+#if !(defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPE=
CIFIC))
 	adds r2=16+128,sp
 	;;
 	lfetch.fault.excl.nt1 [r2],128
 	lfetch.fault.excl.nt1 [r3],128
 #endif
 	adds r14=3DSW(R4)+16,sp
-#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
-      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
+#if !(defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPE=
CIFIC))
 	;;
 	lfetch.fault.excl [r2]
 	lfetch.fault.excl [r3]
@@ -325,8 +322,7 @@
 	.prologue
 	.altrp b7
 	.body
-#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
-      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
+#if !(defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPE=
CIFIC))
=20
 	lfetch.fault.nt1 [sp]
 #endif
@@ -530,14 +526,9 @@
 	// fall through
 GLOBAL_ENTRY(ia64_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
-	cmp.eq p16,p0=3Dr0,r0			// set the "first_time" flag
-	movl r15=3DPERCPU_ADDR+IA64_CPU_SOFTIRQ_ACTIVE_OFFSET  // r15 =3D &cpu_da=
ta.softirq.active
-	;;
-	ld8 r2=3D[r15]
+	lfetch.fault [sp]
 	movl r14=3D.restart
 	;;
-	lfetch.fault [sp]
-	shr.u r3=3Dr2,32			// r3 =3D cpu_data.softirq.mask
 	MOVBR(.ret.sptk,rp,r14,.restart)
 .restart:
 	adds r17=3DIA64_TASK_NEED_RESCHED_OFFSET,r13
@@ -546,27 +537,20 @@
 	adds r19=3DIA64_TASK_PFM_NOTIFY_OFFSET,r13
 #endif
 	;;
-	ld8 r17=3D[r17]				// load current->need_resched
-	ld4 r18=3D[r18]				// load current->sigpending
-(p16)	and r2=3Dr2,r3				// r2 <- (softirq.active & softirq.mask)
-	;;
 #ifdef CONFIG_PERFMON
 	ld8 r19=3D[r19]				// load current->task.pfm_notify
 #endif
-(p16)	cmp4.ne.unc p6,p0=3Dr2,r0			// p6 <- (softirq.active & softirq.mask)=
 !=3D 0
-(pUser)	cmp.ne.unc p7,p0=3Dr17,r0			// current->need_resched !=3D 0?
+	ld8 r17=3D[r17]				// load current->need_resched
+	ld4 r18=3D[r18]				// load current->sigpending
 	;;
-(pUser)	cmp.ne.unc p8,p0=3Dr18,r0			// current->sigpending !=3D 0?
 #ifdef CONFIG_PERFMON
 	cmp.ne p9,p0=3Dr19,r0			// current->task.pfm_notify !=3D 0?
 #endif
-	cmp.ne p16,p0=3Dr0,r0			// clear the "first_time" flag
+(pUser)	cmp.ne.unc p7,p0=3Dr17,r0			// current->need_resched !=3D 0?
+(pUser)	cmp.ne.unc p8,p0=3Dr18,r0			// current->sigpending !=3D 0?
 	;;
-# if __GNUC__ < 3
-(p6)	br.call.spnt.many b7=3Dinvoke_do_softirq
-# else
-(p6)	br.call.spnt.many b7=3Ddo_softirq
-# endif
+	adds r2=3DPT(R8)+16,r12
+	adds r3=3DPT(R9)+16,r12
 #ifdef CONFIG_PERFMON
 (p9)	br.call.spnt.many b7=3Dpfm_overflow_notify
 #endif
@@ -575,8 +559,6 @@
 #else
 (p7)	br.call.spnt.many b7=3Dschedule
 #endif
-	adds r2=3DPT(R8)+16,r12
-	adds r3=3DPT(R9)+16,r12
 (p8)	br.call.spnt.many b7=3Dhandle_signal_delivery	// check & deliver pend=
ing signals
 	;;
 	// start restoring the state saved on the kernel stack (struct pt_regs):
@@ -634,14 +616,6 @@
 	;;
 	bsw.0			// switch back to bank 0
 	;;
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-	nop.i 0x0
-	;;
-	nop.i 0x0
-	;;
-	nop.i 0x0
-	;;
-#endif
 	adds r16=16,r12
 	adds r17$,r12
 	;;
@@ -811,28 +785,6 @@
=20
 # endif /* CONFIG_SMP */
=20
-#if __GNUC__ < 3
-	/*
-	 * Invoke do_softirq() while preserving in0-in7, which may be needed
-	 * in case a system call gets restarted.  Note that declaring do_softirq()
-	 * with asmlinkage() is NOT enough because that will only preserve as many
-	 * registers as there are formal arguments.
-	 *
-	 * XXX fix me: with gcc 3.0, we won't need this anymore because syscall_l=
inkage
-	 *	renders all eight input registers (in0-in7) as "untouchable".
-	 */
-ENTRY(invoke_do_softirq)
-	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
-	alloc loc1=3Dar.pfs,8,2,0,0
-	mov loc0=3Drp
-	;;
-	.body
-	br.call.sptk.few rp=3Ddo_softirq
-.ret13:	mov ar.pfs=3Dloc1
-	mov rp=3Dloc0
-	br.ret.sptk.many rp
-END(invoke_do_softirq)
-
 	/*
 	 * Invoke schedule() while preserving in0-in7, which may be needed
 	 * in case a system call gets restarted.  Note that declaring schedule()
@@ -853,8 +805,6 @@
 	mov rp=3Dloc0
 	br.ret.sptk.many rp
 END(invoke_schedule)
-
-#endif /* __GNUC__ < 3 */
=20
 	/*
 	 * Setup stack and call ia64_do_signal.  Note that pSys and pNonSys need =
to
diff -urN linux-davidm/arch/ia64/kernel/entry.h linux-2.4.7-lia/arch/ia64/k=
ernel/entry.h
--- linux-davidm/arch/ia64/kernel/entry.h	Sun Apr 29 15:49:25 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/entry.h	Mon Jul 23 14:38:11 2001
@@ -1,7 +1,7 @@
 #include <linux/config.h>
=20
 /* XXX fixme */
-#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SP=
ECIFIC)
+#if defined(CONFIG_ITANIUM_B1_SPECIFIC)
 # define MOVBR(type,br,gr,lbl)	mov br=3Dgr
 #else
 # define MOVBR(type,br,gr,lbl)	mov##type br=3Dgr,lbl
diff -urN linux-davidm/arch/ia64/kernel/fw-emu.c linux-2.4.7-lia/arch/ia64/=
kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/fw-emu.c	Mon Jul 23 14:25:16 2001
@@ -123,8 +123,8 @@
=20
 asm (
 "	.proc pal_emulator_static\n"
-"pal_emulator_static:
-	mov r8=3D-1\n"
+"pal_emulator_static:"
+"	mov r8=3D-1\n"
 "	mov r9%6\n"
 "	;;\n"
 "	cmp.gtu p6,p7=3Dr9,r28		/* r28 <=3D 255? */\n"
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.7-lia/arch/ia64/ke=
rnel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/head.S	Mon Jul 23 14:01:58 2001
@@ -218,8 +218,7 @@
 	add r19=3DIA64_NUM_DBG_REGS*8,in0
 	;;
 1:	mov r16=DBr[r18]
-#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC) \
-    || defined(CONFIG_ITANIUM_C0_SPECIFIC)
+#if defined(CONFIG_ITANIUM_C0_SPECIFIC)
 	;;
 	srlz.d
 #endif
@@ -236,8 +235,7 @@
=20
 GLOBAL_ENTRY(ia64_load_debug_regs)
 	alloc r16=3Dar.pfs,1,0,0,0
-#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
-   || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPE=
CIFIC))
+#if !(defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPE=
CIFIC))
 	lfetch.nta [in0]
 #endif
 	mov r20=3Dar.lc			// preserve ar.lc
@@ -250,8 +248,7 @@
 	add r18=3D1,r18
 	;;
 	mov dbr[r18]=3Dr16
-#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC) \
-    || defined(CONFIG_ITANIUM_C0_SPECIFIC)
+#if defined(CONFIG_ITANIUM_BSTEP_SPECIFIC) || defined(CONFIG_ITANIUM_C0_SP=
ECIFIC)
 	;;
 	srlz.d
 #endif
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.7-lia/arch/i=
a64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/ia64_ksyms.c	Mon Jul 23 14:02:07 2001
@@ -31,6 +31,9 @@
 EXPORT_SYMBOL(disable_irq);
 EXPORT_SYMBOL(disable_irq_nosync);
=20
+#include <linux/interrupt.h>
+EXPORT_SYMBOL(probe_irq_mask);
+
 #include <linux/in6.h>
 #include <asm/checksum.h>
 /* not coded yet?? EXPORT_SYMBOL(csum_ipv6_magic); */
@@ -54,7 +57,9 @@
 EXPORT_SYMBOL(clear_page);
=20
 #include <asm/processor.h>
-EXPORT_SYMBOL(cpu_data);
+# ifndef CONFIG_NUMA
+EXPORT_SYMBOL(_cpu_data);
+# endif
 EXPORT_SYMBOL(kernel_thread);
=20
 #include <asm/system.h>
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c linux-2.4.7-lia/arch/ia64=
/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/iosapic.c	Mon Jul 23 15:49:13 2001
@@ -205,6 +205,7 @@
 static void
 iosapic_set_affinity (unsigned int irq, unsigned long mask)
 {
+#ifdef CONFIG_SMP
 	unsigned long flags;
 	u32 high32, low32;
 	int dest, pin;
@@ -215,7 +216,7 @@
 	if (!mask || irq >=3D IA64_NUM_VECTORS)
 		return;
=20
-	dest =3D ffz(~mask);
+	dest =3D cpu_physical_id(ffz(~mask));
=20
 	pin =3D iosapic_irq[irq].pin;
 	addr =3D iosapic_irq[irq].addr;
@@ -242,6 +243,7 @@
 		writel(low32, addr + IOSAPIC_WINDOW);
 	}
 	spin_unlock_irqrestore(&iosapic_lock, flags);
+#endif
 }
=20
 /*
@@ -364,7 +366,7 @@
 }
=20
 void __init
-iosapic_init (unsigned long phys_addr, unsigned int base_irq)
+iosapic_init (unsigned long phys_addr, unsigned int base_irq, int pcat_com=
pat)
 {
 	struct hw_interrupt_type *irq_type;
 	int i, irq, max_pin, vector;
@@ -393,7 +395,7 @@
 	printk("IOSAPIC: version %x.%x, address 0x%lx, IRQs 0x%02x-0x%02x\n",
 	       (ver & 0xf0) >> 4, (ver & 0x0f), phys_addr, base_irq, base_irq + m=
ax_pin);
=20
-	if (base_irq =3D 0)
+	if ((base_irq =3D 0) && pcat_compat)
 		/*
 		 * Map the legacy ISA devices into the IOSAPIC data.  Some of these may
 		 * get reprogrammed later on with data from the ACPI Interrupt Source
diff -urN linux-davidm/arch/ia64/kernel/irq.c linux-2.4.7-lia/arch/ia64/ker=
nel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Sun Apr 29 15:49:25 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/irq.c	Mon Jul 23 14:02:40 2001
@@ -626,6 +626,8 @@
 		desc->handler->end(irq);
 		spin_unlock(&desc->lock);
 	}
+	if (local_softirq_pending())
+		do_softirq();
 	return 1;
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.7-lia/arch/ia64/ker=
nel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/ivt.S	Mon Jul 23 14:02:50 2001
@@ -534,8 +534,7 @@
 	;;
 1:	ld8 r18=3D[r17]
 	;;
-# if defined(CONFIG_IA32_SUPPORT) && \
-    (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC))
+# if defined(CONFIG_IA32_SUPPORT) && defined(CONFIG_ITANIUM_B0_SPECIFIC)
 	/*
 	 * Erratum 85 (Access bit fault could be reported before page not present=
 fault)
 	 *   If the PTE is indicates the page is not present, then just turn this=
 into a
@@ -565,8 +564,7 @@
 	;;
 1:	ld8 r18=3D[r17]
 	;;
-# if defined(CONFIG_IA32_SUPPORT) && \
-    (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC))
+# if defined(CONFIG_IA32_SUPPORT) && defined(CONFIG_ITANIUM_B0_SPECIFIC)
 	/*
 	 * Erratum 85 (Access bit fault could be reported before page not present=
 fault)
 	 *   If the PTE is indicates the page is not present, then just turn this=
 into a
diff -urN linux-davidm/arch/ia64/kernel/minstate.h linux-2.4.7-lia/arch/ia6=
4/kernel/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Sun Apr 29 15:49:25 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/minstate.h	Mon Jul 23 14:38:11 2001
@@ -235,12 +235,6 @@
 	stf.spill [r2]=F8,32;			\
 	stf.spill [r3]=F9,32
=20
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
-# define STOPS	nop.i 0x0;; nop.i 0x0;; nop.i 0x0;;
-#else
-# define STOPS
-#endif
-
-#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover, mov rCRIFS=3Dcr.ifs,) STOPS
-#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover, mov rCRIFS=3Dcr.ifs, mo=
v r15=3Dr19) STOPS
-#define SAVE_MIN		DO_SAVE_MIN(     , mov rCRIFS=3Dr0, ) STOPS
+#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover, mov rCRIFS=3Dcr.ifs,)
+#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover, mov rCRIFS=3Dcr.ifs, mo=
v r15=3Dr19)
+#define SAVE_MIN		DO_SAVE_MIN(     , mov rCRIFS=3Dr0, )
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c linux-2.4.7-lia/arch/ia64=
/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/perfmon.c	Mon Jul 23 14:14:59 2001
@@ -574,11 +574,7 @@
 	/* cannot send to process 1, 0 means do not notify */
 	if (pfx->notify_pid < 0 || pfx->notify_pid =3D 1) return 0;
=20
-	/* asked for sampling, but nothing to record ! */
-	if (pfx->smpl_entries > 0 && pfm_smpl_entry_size(&pfx->smpl_regs, 1) =3D =
0) return 0;
-
 	/* probably more to add here */
-
=20
 	return 1;
 }
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.7-lia/arch/ia64/k=
ernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/setup.c	Mon Jul 23 14:03:13 2001
@@ -51,8 +51,11 @@
=20
 extern char _end;
=20
-/* cpu_data[0] is data for the bootstrap processor: */
-struct cpuinfo_ia64 cpu_data[NR_CPUS] __attribute__ ((section ("__special_=
page_section")));
+#ifdef CONFIG_NUMA
+ struct cpuinfo_ia64 *boot_cpu_data;
+#else
+ struct cpuinfo_ia64 _cpu_data[NR_CPUS] __attribute__ ((section ("__specia=
l_page_section")));
+#endif
=20
 unsigned long ia64_cycles_per_usec;
 struct ia64_boot_param *ia64_boot_param;
@@ -304,27 +307,37 @@
 	/*
 	 *  Set `iobase' to the appropriate address in region 6
 	 *    (uncached access range)
+	 *
+	 *  The EFI memory map is the "prefered" location to get the I/O port
+	 *  space base, rather the relying on AR.KR0. This should become more
+	 *  clear in future SAL specs. We'll fall back to getting it out of
+	 *  AR.KR0 if no appropriate entry is found in the memory map.
 	 */
-	ia64_iobase =3D ia64_get_kr(IA64_KR_IO_BASE);
+	ia64_iobase =3D efi_get_iobase();
+	if (ia64_iobase)
+		/* set AR.KR0 since this is all we use it for anyway */
+		ia64_set_kr(IA64_KR_IO_BASE, ia64_iobase);
+	else {
+		ia64_iobase =3D ia64_get_kr(IA64_KR_IO_BASE);
+		printk("No I/O port range found in EFI memory map, falling back to AR.KR=
0\n");
+		printk("I/O port base =3D 0x%lx\n", ia64_iobase);
+	}
 	ia64_iobase =3D __IA64_UNCACHED_OFFSET | (ia64_iobase & ~PAGE_OFFSET);
=20
-	cpu_init();	/* initialize the bootstrap CPU */
-
 #ifdef CONFIG_SMP
 	cpu_physical_id(0) =3D hard_smp_processor_id();
 #endif
=20
+	cpu_init();	/* initialize the bootstrap CPU */
+
 #ifdef CONFIG_IA64_GENERIC
 	machvec_init(acpi_get_sysname());
 #endif
=20
-#ifdef	CONFIG_ACPI20
 	if (efi.acpi20) {
 		/* Parse the ACPI 2.0 tables */
 		acpi20_parse(efi.acpi20);
-	} else
-#endif
-	if (efi.acpi) {
+	} else if (efi.acpi) {
 		/* Parse the ACPI tables */
 		acpi_parse(efi.acpi);
 	}
@@ -359,26 +372,18 @@
 #else
 #	define lpj	loops_per_jiffy
 #endif
-	char family[32], model[32], features[128], *cp, *p =3D buffer;
+	char family[32], features[128], *cp, *p =3D buffer;
 	struct cpuinfo_ia64 *c;
-	unsigned long mask;
-
-	for (c =3D cpu_data; c < cpu_data + NR_CPUS; ++c) {
-#ifdef CONFIG_SMP
-		if (!(cpu_online_map & (1UL << (c - cpu_data))))
-			continue;
-#endif
+	unsigned long mask, cpu;
=20
+	for (cpu =3D 0; cpu < smp_num_cpus; ++cpu) {
+		c =3D cpu_data(cpu);
 		mask =3D c->features;
=20
-		if (c->family =3D 7)
-			memcpy(family, "IA-64", 6);
-		else
-			sprintf(family, "%u", c->family);
-
-		switch (c->model) {
-		      case 0:	strcpy(model, "Itanium"); break;
-		      default:	sprintf(model, "%u", c->model); break;
+		switch (c->family) {
+		      case 0x07:	memcpy(family, "Itanium", 8); break;
+		      case 0x1f:	memcpy(family, "McKinley", 9); break;
+		      default:		sprintf(family, "%u", c->family); break;
 		}
=20
 		/* build the feature string: */
@@ -395,8 +400,9 @@
 		p +=3D sprintf(p,
 			     "processor  : %lu\n"
 			     "vendor     : %s\n"
+			     "arch       : IA-64\n"
 			     "family     : %s\n"
-			     "model      : %s\n"
+			     "model      : %u\n"
 			     "revision   : %u\n"
 			     "archrev    : %u\n"
 			     "features   :%s\n"	/* don't change this---it _is_ right! */
@@ -405,8 +411,7 @@
 			     "cpu MHz    : %lu.%06lu\n"
 			     "itc MHz    : %lu.%06lu\n"
 			     "BogoMIPS   : %lu.%02lu\n\n",
-			     c - cpu_data, c->vendor, family, model, c->revision, c->archrev,
-			     features,
+			     cpu, c->vendor, family, c->model, c->revision, c->archrev, feature=
s,
 			     c->ppn, c->number, c->proc_freq / 1000000, c->proc_freq % 1000000,
 			     c->itc_freq / 1000000, c->itc_freq % 1000000,
 			     lpj*HZ/500000, (lpj*HZ/5000) % 100);
@@ -474,18 +479,54 @@
 void
 cpu_init (void)
 {
-	extern void __init ia64_mmu_init (void);
+	extern void __init ia64_mmu_init (void *);
 	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
+	struct cpuinfo_ia64 *my_cpu_data;
+#ifdef CONFIG_NUMA
+	int cpu, order;
+
+	/*
+	 * If NUMA is configured, the cpu_data array is not preallocated. The boo=
t cpu
+	 * allocates entries for every possible cpu. As the remaining cpus come o=
nline,
+	 * they reallocate a new cpu_data structure on their local node. This ext=
ra work
+	 * is required because some boot code references all cpu_data structures
+	 * before the cpus are actually started.
+	 */
+	if (!boot_cpu_data) {
+		my_cpu_data =3D alloc_bootmem_pages_node(NODE_DATA(numa_node_id()),
+						       sizeof(struct cpuinfo_ia64));
+		boot_cpu_data =3D my_cpu_data;
+		my_cpu_data->cpu_data[0] =3D my_cpu_data;
+		for (cpu =3D 1; cpu < NR_CPUS; ++cpu)
+			my_cpu_data->cpu_data[cpu]
+				=3D alloc_bootmem_pages_node(NODE_DATA(numa_node_id()),
+							   sizeof(struct cpuinfo_ia64));
+		for (cpu =3D 1; cpu < NR_CPUS; ++cpu)
+			memcpy(my_cpu_data->cpu_data[cpu]->cpu_data_ptrs,
+			       my_cpu_data->cpu_data, sizeof(my_cpu_data->cpu_data));
+	} else {
+		order =3D get_order(sizeof(struct cpuinfo_ia64));
+		my_cpu_data =3D page_address(alloc_pages_node(numa_node_id(), GFP_KERNEL=
, order));
+		memcpy(my_cpu_data, boot_cpu_data->cpu_data[smp_processor_id()],
+		       sizeof(struct cpuinfo_ia64));
+		__free_pages(virt_to_page(boot_cpu_data->cpu_data[smp_processor_id()]),
+			     order);
+		for (cpu =3D 0; cpu < NR_CPUS; ++cpu)
+			boot_cpu_data->cpu_data[cpu]->cpu_data[smp_processor_id()] =3D my_cpu_d=
ata;
+	}
+#else
+	my_cpu_data =3D cpu_data(smp_processor_id());
+#endif
=20
 	/*
-	 * We can't pass "local_cpu_data" do identify_cpu() because we haven't ca=
lled
+	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't ca=
lled
 	 * ia64_mmu_init() yet.  And we can't call ia64_mmu_init() first because =
it
 	 * depends on the data returned by identify_cpu().  We break the dependen=
cy by
-	 * accessing cpu_data[] the old way, through identity mapped space.
+	 * accessing cpu_data() the old way, through identity mapped space.
 	 */
-	identify_cpu(&cpu_data[smp_processor_id()]);
+	identify_cpu(my_cpu_data);
=20
 	/* Clear the stack memory reserved for pt_regs: */
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
@@ -504,7 +545,7 @@
 	atomic_inc(&init_mm.mm_count);
 	current->active_mm =3D &init_mm;
=20
-	ia64_mmu_init();
+	ia64_mmu_init(my_cpu_data);
=20
 #ifdef CONFIG_IA32_SUPPORT
 	/* initialize global ia32 state - CR0 and CR4 */
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.7-lia/arch/ia64/ker=
nel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/smp.c	Mon Jul 23 14:03:54 2001
@@ -192,7 +192,7 @@
 static inline void
 send_IPI_single (int dest_cpu, int op)
 {
-	set_bit(op, &cpu_data[dest_cpu].ipi_operation);
+	set_bit(op, &cpu_data(dest_cpu)->ipi_operation);
 	platform_send_ipi(dest_cpu, IA64_IPI_VECTOR, IA64_IPI_DM_INT, 0);
 }
=20
@@ -239,11 +239,13 @@
 void
 smp_resend_flush_tlb (void)
 {
+	int i;
+
 	/*
 	 * Really need a null IPI but since this rarely should happen & since thi=
s code
 	 * will go away, lets not add one.
 	 */
-	for (i =3D 0; i < smp_num_cpus; ++i) {
+	for (i =3D 0; i < smp_num_cpus; ++i)
 		if (i !=3D smp_processor_id())
 			smp_send_reschedule(i);
 }
@@ -275,7 +277,7 @@
 {
 	struct call_data_struct data;
 	int cpus =3D 1;
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
+#if (defined(CONFIG_ITANIUM_B0_SPECIFIC) \
      || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	unsigned long timeout;
 #endif
@@ -295,11 +297,11 @@
 	spin_lock_bh(&call_lock);
 	call_data =3D &data;
=20
+#if (defined(CONFIG_ITANIUM_B0_SPECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
   resend:
   	send_IPI_single(cpuid, IPI_CALL_FUNC);
=20
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
-     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	/*  Wait for response */
 	timeout =3D jiffies + HZ;
 	while ((atomic_read(&data.started) !=3D cpus) && time_before(jiffies, tim=
eout))
@@ -307,6 +309,8 @@
 	if (atomic_read(&data.started) !=3D cpus)
 		goto resend;
 #else
+  	send_IPI_single(cpuid, IPI_CALL_FUNC);
+
 	/* Wait for response */
 	while (atomic_read(&data.started) !=3D cpus)
 		barrier();
@@ -344,7 +348,7 @@
 {
 	struct call_data_struct data;
 	int cpus =3D smp_num_cpus-1;
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
+#if (defined(CONFIG_ITANIUM_B0_SPECIFIC) \
      || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	unsigned long timeout;
 #endif
@@ -362,12 +366,12 @@
 	spin_lock_bh(&call_lock);
 	call_data =3D &data;
=20
+#if (defined(CONFIG_ITANIUM_B0_SPECIFIC) \
+     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
   resend:
 	/*  Send a message to all other CPUs and wait for them to respond */
 	send_IPI_allbutself(IPI_CALL_FUNC);
=20
-#if (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC) \
-     || defined(CONFIG_ITANIUM_B1_SPECIFIC) || defined(CONFIG_ITANIUM_B2_S=
PECIFIC))
 	/* Wait for response */
 	timeout =3D jiffies + HZ;
 	while ((atomic_read(&data.started) !=3D cpus) && time_before(jiffies, tim=
eout))
@@ -375,6 +379,8 @@
 	if (atomic_read(&data.started) !=3D cpus)
 		goto resend;
 #else
+	send_IPI_allbutself(IPI_CALL_FUNC);
+
 	/* Wait for response */
 	while (atomic_read(&data.started) !=3D cpus)
 		barrier();
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c linux-2.4.7-lia/arch/ia64=
/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/smpboot.c	Mon Jul 23 14:04:10 2001
@@ -467,8 +467,6 @@
 	set_bit(0, &cpu_online_map);
 	set_bit(0, &cpu_callin_map);
=20
-	printk("Loops_per_jiffy for BOOT CPU =3D 0x%lx\n", loops_per_jiffy);
-
 	local_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
 	ia64_cpu_to_sapicid[0] =3D boot_cpu_id;
=20
@@ -481,7 +479,7 @@
 	/*
 	 * If SMP should be disabled, then really disable it!
 	 */
-	if ((!max_cpus) || (max_cpus < -1)) {
+	if (!max_cpus || (max_cpus < -1)) {
 		printk(KERN_INFO "SMP mode deactivated.\n");
 		cpu_online_map =3D  1;
 		smp_num_cpus =3D 1;
@@ -502,7 +500,7 @@
 			if ((sapicid =3D -1) || (sapicid =3D hard_smp_processor_id()))
 				continue;
=20
-			if ((max_cpus > 0) && (max_cpus =3D cpucount+1))
+			if ((max_cpus > 0) && (cpucount + 1 >=3D max_cpus))
 				break;
=20
 			do_boot_cpu(sapicid);
@@ -527,7 +525,7 @@
 			unsigned long bogosum =3D 0;
   			for (cpu =3D 0; cpu < NR_CPUS; cpu++)
 				if (cpu_online_map & (1<<cpu))
-					bogosum +=3D cpu_data[cpu].loops_per_jiffy;
+					bogosum +=3D cpu_data(cpu)->loops_per_jiffy;
=20
 			printk(KERN_INFO"Total of %d processors activated (%lu.%02lu BogoMIPS).=
\n",
 			       cpucount + 1, bogosum/(500000/HZ), (bogosum/(5000/HZ))%100);
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.7-lia/arch/ia64/ke=
rnel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/time.c	Mon Jul 23 14:05:17 2001
@@ -67,8 +67,8 @@
 	unsigned long now, last_tick;
 #	define time_keeper_id	0	/* smp_processor_id() of time-keeper */
=20
-	last_tick =3D (cpu_data[time_keeper_id].itm_next
-		     - (lost + 1)*cpu_data[time_keeper_id].itm_delta);
+	last_tick =3D (cpu_data(time_keeper_id)->itm_next
+		     - (lost + 1)*cpu_data(time_keeper_id)->itm_delta);
=20
 	now =3D ia64_get_itc();
 	if ((long) (now - last_tick) < 0) {
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.7-lia/arch/ia64/k=
ernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/kernel/traps.c	Mon Jul 23 14:05:03 2001
@@ -421,14 +421,12 @@
 		sprintf(buf, "General Exception: %s%s", reason[code],
 			(code =3D 3) ? ((isr & (1UL << 37))
 				       ? " (RSE access)" : " (data access)") : "");
-#ifndef CONFIG_ITANIUM_ASTEP_SPECIFIC
 		if (code =3D 8) {
 # ifdef CONFIG_IA64_PRINT_HAZARDS
 			printk("%016lx:possible hazard, pr =3D %016lx\n", regs->cr_iip, regs->p=
r);
 # endif
 			return;
 		}
-#endif
 		break;
=20
 	      case 25: /* Disabled FP-Register */
diff -urN linux-davidm/arch/ia64/lib/copy_user.S linux-2.4.7-lia/arch/ia64/=
lib/copy_user.S
--- linux-davidm/arch/ia64/lib/copy_user.S	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/lib/copy_user.S	Mon Jul 23 14:05:31 2001
@@ -37,7 +37,7 @@
 #define COPY_BREAK	16	// we do byte copy below (must be >=16)
 #define PIPE_DEPTH	21	// pipe depth
=20
-#define EPI		p[PIPE_DEPTH-1] // PASTE(p,16+PIPE_DEPTH-1)
+#define EPI		p[PIPE_DEPTH-1]
=20
 //
 // arguments
@@ -148,8 +148,8 @@
 	//
=20
 	//
-	// Optimization. If dst1 is 8-byte aligned (not rarely), we don't need
-	// to copy the head to dst1, to start 8-byte copy software pipleline.
+	// Optimization. If dst1 is 8-byte aligned (quite common), we don't need
+	// to copy the head to dst1, to start 8-byte copy software pipeline.
 	// We know src1 is not 8-byte aligned in this case.
 	//
 	cmp.eq p14,p15=3Dr0,dst2
@@ -233,15 +233,23 @@
 #define SWITCH(pred, shift)	cmp.eq pred,p0=3Dshift,rshift
 #define CASE(pred, shift)	\
 	(pred)	br.cond.spnt.few copy_user_bit##shift
-#define BODY(rshift)							\
-copy_user_bit##rshift:							\
-1:									\
-	EX(failure_out,(EPI) st8 [dst1]=3Dtmp,8);				\
-(EPI_1) shrp tmp=3Dval1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;		\
-	EX(failure_in2,(p16) ld8 val1[0]=3D[src1],8);			\
-	br.ctop.dptk.few 1b;						\
-	;;								\
-	br.cond.spnt.few .diff_align_do_tail
+#define BODY(rshift)						\
+copy_user_bit##rshift:						\
+1:								\
+	EX(failure_out,(EPI) st8 [dst1]=3Dtmp,8);			\
+(EPI_1) shrp tmp=3Dval1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
+	EX(3f,(p16) ld8 val1[0]=3D[src1],8);			\
+	br.ctop.dptk.few 1b;					\
+	;;							\
+	br.cond.sptk.few .diff_align_do_tail;			\
+2:								\
+(EPI)	st8 [dst1]=3Dtmp,8;					\
+(EPI_1)	shrp tmp=3Dval1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
+3:								\
+(p16)	mov val1[0]=3Dr0;						\
+	br.ctop.dptk.few 2b;					\
+	;;							\
+	br.cond.sptk.few failure_in2
=20
 	//
 	// Since the instruction 'shrp' requires a fixed 128-bit value
@@ -581,13 +589,7 @@
 	br.ret.dptk.few rp
=20
 failure_in2:
-	sub ret0=3Dendsrc,src1	// number of bytes to zero, i.e. not copied
-	;;
-3:
-(p16)	mov val1[0]=3Dr0
-(EPI)	st8 [dst1]=3Dval1[PIPE_DEPTH-1],8
-	br.ctop.dptk.few 3b
-	;;
+	sub ret0=3Dendsrc,src1
 	cmp.ne p6,p0=3Ddst1,enddst	// Do we need to finish the tail ?
 	sub len=3Denddst,dst1,1		// precompute len
 (p6)	br.cond.dptk.few failure_in1bis
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.7-lia/arch/ia64/mm/ini=
t.c
--- linux-davidm/arch/ia64/mm/init.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/mm/init.c	Mon Jul 23 14:07:33 2001
@@ -140,6 +140,8 @@
 		printk ("Freeing initrd memory: %ldkB freed\n", (end - start) >> 10);
=20
 	for (; start < end; start +=3D PAGE_SIZE) {
+		if (!VALID_PAGE(virt_to_page(start)))
+			continue;
 		clear_bit(PG_reserved, &virt_to_page(start)->flags);
 		set_page_count(virt_to_page(start), 1);
 		free_page(start);
@@ -225,7 +227,7 @@
 }
=20
 void __init
-ia64_mmu_init (void)
+ia64_mmu_init (void *my_cpu_data)
 {
 	unsigned long flags, rid, pta, impl_va_bits;
 	extern void __init tlb_init (void);
@@ -251,8 +253,7 @@
 	ia64_srlz_d();
=20
 	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
-		 pte_val(mk_pte_phys(__pa(&cpu_data[smp_processor_id()]), PAGE_KERNEL)),
-		 PAGE_SHIFT);
+		 pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL)), PAGE_SHIFT);
=20
 	__restore_flags(flags);
 	ia64_srlz_i();
diff -urN linux-davidm/arch/ia64/mm/tlb.c linux-2.4.7-lia/arch/ia64/mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Sun Apr 29 15:49:26 2001
+++ linux-2.4.7-lia/arch/ia64/mm/tlb.c	Mon Jul 23 14:07:44 2001
@@ -97,7 +97,7 @@
 	/*
 	 * Wait for other CPUs to finish purging entries.
 	 */
-#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC)
+#if defined(CONFIG_ITANIUM_BSTEP_SPECIFIC)
 	{
 		extern void smp_resend_flush_tlb (void);
 		unsigned long start =3D ia64_get_itc();
diff -urN linux-davidm/arch/ia64/tools/print_offsets.c linux-2.4.7-lia/arch=
/ia64/tools/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Mon Jul 23 16:14:58 2001
+++ linux-2.4.7-lia/arch/ia64/tools/print_offsets.c	Mon Jul 23 14:07:54 2001
@@ -175,8 +175,6 @@
     { "IA64_CLONE_VM",			CLONE_VM },
     { "IA64_CPU_IRQ_COUNT_OFFSET",	offsetof (struct cpuinfo_ia64, irq_stat=
.f.irq_count) },
     { "IA64_CPU_BH_COUNT_OFFSET",	offsetof (struct cpuinfo_ia64, irq_stat.=
f.bh_count) },
-    { "IA64_CPU_SOFTIRQ_ACTIVE_OFFSET",		offsetof (struct cpuinfo_ia64, so=
ftirq.active) },
-    { "IA64_CPU_SOFTIRQ_MASK_OFFSET",		offsetof (struct cpuinfo_ia64, soft=
irq.mask) },
     { "IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET",	offsetof (struct cpuinfo_ia6=
4, phys_stacked_size_p8) },
 };
=20
diff -urN linux-davidm/drivers/acpi/Makefile linux-2.4.7-lia/drivers/acpi/M=
akefile
--- linux-davidm/drivers/acpi/Makefile	Fri Jul 20 22:52:44 2001
+++ linux-2.4.7-lia/drivers/acpi/Makefile	Mon Jul 23 14:08:02 2001
@@ -37,7 +37,7 @@
 obj-$(CONFIG_ACPI)	+=3D os.o acpi_ksyms.o
 obj-$(CONFIG_ACPI)	+=3D $(foreach dir,$(acpi-subdirs),$(dir)/$(dir).o)=20
 ifdef CONFIG_ACPI_KERNEL_CONFIG
-   obj-$(CONFIG_ACPI) 	+=3D acpiconf.o osconf.o
+   obj-$(CONFIG_ACPI) 	+=3D acpiconf.o osconf.o driver.o
 else
    obj-$(CONFIG_ACPI)	+=3D driver.o
 endif
diff -urN linux-davidm/drivers/acpi/driver.c linux-2.4.7-lia/drivers/acpi/d=
river.c
--- linux-davidm/drivers/acpi/driver.c	Fri Jul 20 22:52:45 2001
+++ linux-2.4.7-lia/drivers/acpi/driver.c	Mon Jul 23 14:08:21 2001
@@ -128,7 +128,9 @@
=20
 	printk(KERN_INFO "ACPI: Subsystem enabled\n");
=20
+#ifdef CONFIG_PM
 	pm_active =3D 1;
+#endif
=20
 	return 0;
 }
@@ -141,7 +143,9 @@
 {
 	acpi_terminate();
=20
+#ifdef CONFIG_PM
 	pm_active =3D 0;
+#endif
=20
 	printk(KERN_ERR "ACPI: Subsystem disabled\n");
 }
diff -urN linux-davidm/drivers/acpi/os.c linux-2.4.7-lia/drivers/acpi/os.c
--- linux-davidm/drivers/acpi/os.c	Mon Jul 23 16:15:03 2001
+++ linux-2.4.7-lia/drivers/acpi/os.c	Mon Jul 23 14:08:30 2001
@@ -1,15 +1,9 @@
-/*************************************************************************=
*****
- *=20
- * Module Name: os.c - Linux OSL functions
- *		$Revision: 28 $
- *
- *************************************************************************=
****/
-
 /*
  *  os.c - OS-dependent functions
  *
  *  Copyright (C) 2000 Andrew Henroid
- *  Copyright (C) 2001 Andrew Grover
+ *  Copyright (C) 2000 Intel Corp.
+ *  Copyright (C) 2000 J.I. Lee <jung-ik.lee@intel.com>
  *
  *  This program is free software; you can redistribute it and/or modify
  *  it under the terms of the GNU General Public License as published by
@@ -31,16 +25,21 @@
  * - Fixed improper kernel_thread parameters=20
  */
=20
+#include <linux/config.h>
+
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/pci.h>
 #include <linux/interrupt.h>
 #include <linux/kmod.h>
+#include <linux/irq.h>
 #include <linux/delay.h>
 #include <asm/io.h>
 #include <acpi.h>
+#ifndef	CONFIG_ACPI_KERNEL_CONFIG_ONLY
 #include "driver.h"
+#endif
=20
 #define _COMPONENT	ACPI_OS_SERVICES
 	MODULE_NAME	("os")
@@ -56,6 +55,35 @@
  *			       Debugger Stuff
  *************************************************************************=
****/
=20
+#ifdef	CONFIG_ACPI_KERNEL_CONFIG
+#include "osconf.h"
+
+struct acpi_osd acpi_osd_rt =3D {
+	/* these are runtime osd entries that differ from boottime entries */
+	acpi_os_allocate_rt,
+	acpi_os_callocate_rt,
+	acpi_os_free_rt,
+	acpi_os_queue_for_execution_rt,
+	acpi_os_read_pci_cfg_byte_rt,
+	acpi_os_read_pci_cfg_word_rt,
+	acpi_os_read_pci_cfg_dword_rt,
+	acpi_os_write_pci_cfg_byte_rt,
+	acpi_os_write_pci_cfg_word_rt,
+	acpi_os_write_pci_cfg_dword_rt
+};
+#else
+#define	acpi_os_allocate_rt		acpi_os_allocate
+#define	acpi_os_callocate_rt		acpi_os_callocate
+#define	acpi_os_free_rt			acpi_os_free
+#define acpi_os_queue_for_execution_rt	acpi_os_queue_for_execution
+#define acpi_os_read_pci_cfg_byte_rt	acpi_os_read_pci_cfg_byte
+#define acpi_os_read_pci_cfg_word_rt	acpi_os_read_pci_cfg_word
+#define acpi_os_read_pci_cfg_dword_rt	acpi_os_read_pci_cfg_dword
+#define acpi_os_write_pci_cfg_byte_rt	acpi_os_write_pci_cfg_byte
+#define acpi_os_write_pci_cfg_word_rt	acpi_os_write_pci_cfg_word
+#define acpi_os_write_pci_cfg_dword_rt	acpi_os_write_pci_cfg_dword
+#endif
+
 #ifdef ENABLE_DEBUGGER
=20
 #include <linux/kdb.h>
@@ -371,19 +399,19 @@
 UINT8
 acpi_os_mem_in8 (ACPI_PHYSICAL_ADDRESS phys_addr)
 {
-	return (*(u8*) (u32) phys_addr);
+	return (*(u8*) phys_addr);
 }
=20
 UINT16
 acpi_os_mem_in16 (ACPI_PHYSICAL_ADDRESS phys_addr)
 {
-	return (*(u16*) (u32) phys_addr);
+	return (*(u16*) phys_addr);
 }
=20
 UINT32
 acpi_os_mem_in32 (ACPI_PHYSICAL_ADDRESS phys_addr)
 {
-	return (*(u32*) (u32) phys_addr);
+	return (*(u32*) phys_addr);
 }
=20
 void
@@ -405,7 +433,7 @@
 }
=20
 ACPI_STATUS
-acpi_os_read_pci_cfg_byte(
+acpi_os_read_pci_cfg_byte_rt(
 	u32 bus,
 	u32 func,
 	u32 addr,
@@ -419,7 +447,7 @@
 }
=20
 ACPI_STATUS
-acpi_os_read_pci_cfg_word(
+acpi_os_read_pci_cfg_word_rt(
 	u32 bus,
 	u32 func,
 	u32 addr,
@@ -433,7 +461,7 @@
 }
=20
 ACPI_STATUS
-acpi_os_read_pci_cfg_dword(
+acpi_os_read_pci_cfg_dword_rt(
 	u32 bus,
 	u32 func,
 	u32 addr,
@@ -447,7 +475,7 @@
 }
=20
 ACPI_STATUS
-acpi_os_write_pci_cfg_byte(
+acpi_os_write_pci_cfg_byte_rt(
 	u32 bus,
 	u32 func,
 	u32 addr,
@@ -461,7 +489,7 @@
 }
=20
 ACPI_STATUS
-acpi_os_write_pci_cfg_word(
+acpi_os_write_pci_cfg_word_rt(
 	u32 bus,
 	u32 func,
 	u32 addr,
@@ -475,7 +503,7 @@
 }
=20
 ACPI_STATUS
-acpi_os_write_pci_cfg_dword(
+acpi_os_write_pci_cfg_dword_rt(
 	u32 bus,
 	u32 func,
 	u32 addr,
@@ -487,6 +515,27 @@
 		return AE_ERROR;
 	return AE_OK;
 }
+
+#ifdef CONFIG_ACPI_KERNEL_CONFIG
+/*
+ * Queue for interpreter thread
+ */
+
+ACPI_STATUS
+acpi_os_queue_for_execution_rt(
+			    u32 priority,
+			    OSD_EXECUTION_CALLBACK callback,
+			    void *context)
+{
+# ifndef CONFIG_ACPI_KERNEL_CONFIG_ONLY
+	if (acpi_run(callback, context))
+		return AE_ERROR;
+# else
+	(*callback)(context);
+# endif
+	return AE_OK;
+}
+#endif
=20
 ACPI_STATUS
 acpi_os_load_module (
diff -urN linux-davidm/drivers/acpi/osconf.c linux-2.4.7-lia/drivers/acpi/o=
sconf.c
--- linux-davidm/drivers/acpi/osconf.c	Mon Jul 23 16:15:03 2001
+++ linux-2.4.7-lia/drivers/acpi/osconf.c	Mon Jul 23 14:10:17 2001
@@ -112,15 +112,6 @@
=20
=20
 ACPI_STATUS
-acpi_os_queue_for_execution(
-	u32			priority,
-	OSD_EXECUTION_CALLBACK	callback,
-	void			*context)
-{
-	return acpi_osd->queue_for_exec(priority, callback, context);
-}
-
-ACPI_STATUS
 acpi_os_read_pci_cfg_byte( u32 segbus, u32 func, u32 addr, u8 * val)
 {
 	return acpi_osd->read_pci_cfg_byte(segbus, func, addr, val);
@@ -251,6 +242,7 @@
 	(*callback)(context);
 	return AE_OK;
 }
+
=20
 static ACPI_STATUS __init
 acpi_os_read_pci_cfg_byte_bt( u32 segbus, u32 func, u32 addr, u8 * val)
diff -urN linux-davidm/drivers/acpi/osconf.h linux-2.4.7-lia/drivers/acpi/o=
sconf.h
--- linux-davidm/drivers/acpi/osconf.h	Mon Jul 23 16:15:03 2001
+++ linux-2.4.7-lia/drivers/acpi/osconf.h	Mon Jul 23 14:10:27 2001
@@ -34,13 +34,6 @@
=20
=20
 ACPI_STATUS
-acpi_os_queue_for_execution(
-	u32			priority,
-	OSD_EXECUTION_CALLBACK	callback,
-	void			*context
-	);
-
-ACPI_STATUS
 acpi_os_read_pci_cfg_byte( u32 segbus, u32 func, u32 addr, u8 * val);
=20
 ACPI_STATUS
diff -urN linux-davidm/drivers/char/Config.in linux-2.4.7-lia/drivers/char/=
Config.in
--- linux-davidm/drivers/char/Config.in	Mon Jul 23 16:15:03 2001
+++ linux-2.4.7-lia/drivers/char/Config.in	Mon Jul 23 14:10:47 2001
@@ -188,12 +188,17 @@
 dep_tristate '/dev/agpgart (AGP Support)' CONFIG_AGP $CONFIG_DRM_AGP
 if [ "$CONFIG_AGP" !=3D "n" ]; then
    bool '  Intel 440LX/BX/GX and I815/I840/I850 support' CONFIG_AGP_INTEL
+   dep_bool '  Intel 460GX support (EXPERIMENTAL)' CONFIG_AGP_I460 $CONFIG=
_AGP_PTE_FIXUPS
+   if [ "$CONFIG_AGP_I460" !=3D "n" ]; then
+	bool '    Enable Full AGP RQ (Requires BigSur BIOS 99 or Newer)' CONFIG_A=
GP_I460_FULLRQ
+   fi
    bool '  Intel I810/I815 (on-board) support' CONFIG_AGP_I810
    bool '  VIA chipset support' CONFIG_AGP_VIA
    bool '  AMD Irongate support' CONFIG_AGP_AMD
    bool '  Generic SiS support' CONFIG_AGP_SIS
    bool '  ALI chipset support' CONFIG_AGP_ALI
    bool '  Serverworks LE/HE support' CONFIG_AGP_SWORKS
+   bool 'AGPGART PTE Fixups (Required by 460GX)' CONFIG_AGP_PTE_FIXUPS
 fi
=20
 source drivers/char/drm/Config.in
diff -urN linux-davidm/drivers/input/joydev.c linux-2.4.7-lia/drivers/input=
/joydev.c
--- linux-davidm/drivers/input/joydev.c	Sun Apr 29 15:49:45 2001
+++ linux-2.4.7-lia/drivers/input/joydev.c	Mon Jul 23 14:11:15 2001
@@ -86,6 +86,12 @@
 MODULE_DESCRIPTION("Joystick device driver");
 MODULE_SUPPORTED_DEVICE("input/js");
=20
+static inline unsigned long
+jiffies_to_msec (unsigned long t)
+{
+	return 1000*(t / HZ) + 1000*(t % HZ)/HZ;
+}
+
 static int joydev_correct(int value, struct js_corr *corr)
 {
 	switch (corr->type) {
@@ -133,7 +139,7 @@
 			return;
 	} =20
=20
-	event.time =3D jiffies * (1000 / HZ);
+	event.time =3D jiffies_to_msec(jiffies);
=20
 	while (list) {
=20
@@ -278,7 +284,7 @@
=20
 		struct js_event event;
=20
-		event.time =3D jiffies * (1000/HZ);
+		event.time =3D jiffies_to_msec(jiffies);
=20
 		if (list->startup < joydev->nkey) {
 			event.type =3D JS_EVENT_BUTTON | JS_EVENT_INIT;
diff -urN linux-davidm/drivers/net/eepro100.c linux-2.4.7-lia/drivers/net/e=
epro100.c
--- linux-davidm/drivers/net/eepro100.c	Mon Jul 23 16:15:07 2001
+++ linux-2.4.7-lia/drivers/net/eepro100.c	Mon Jul 23 14:11:25 2001
@@ -43,13 +43,17 @@
 static int txdmacount =3D 128;
 static int rxdmacount /* =3D 0 */;
=20
+#if defined(__ia64__) || defined(__alpha__) || defined(__sparc__) || defin=
ed(__arm__)
+  /* align rx buffers to 2 bytes so that IP header is aligned */
+# define RX_ALIGN
+# define RxFD_ALIGNMENT		__attribute__ ((aligned (2), packed))
+#else
+# define RxFD_ALIGNMENT
+#endif
+
 /* Set the copy breakpoint for the copy-only-tiny-buffer Rx method.
    Lower values use more memory, but are faster. */
-#if defined(__alpha__) || defined(__sparc__) || defined(__arm__)
-static int rx_copybreak =3D 1518;
-#else
 static int rx_copybreak =3D 200;
-#endif
=20
 /* Maximum events (Rx packets, etc.) to handle at each interrupt. */
 static int max_interrupt_work =3D 20;
diff -urN linux-davidm/drivers/scsi/Config.in linux-2.4.7-lia/drivers/scsi/=
Config.in
--- linux-davidm/drivers/scsi/Config.in	Sat Jul 21 20:18:38 2001
+++ linux-2.4.7-lia/drivers/scsi/Config.in	Mon Jul 23 14:11:36 2001
@@ -152,6 +152,7 @@
    dep_tristate 'Qlogic ISP SCSI support' CONFIG_SCSI_QLOGIC_ISP $CONFIG_S=
CSI
    dep_tristate 'Qlogic ISP FC SCSI support' CONFIG_SCSI_QLOGIC_FC $CONFIG=
_SCSI
    dep_tristate 'Qlogic QLA 1280 SCSI support' CONFIG_SCSI_QLOGIC_1280 $CO=
NFIG_SCSI
+   dep_tristate 'Qlogic QLA 2100 driver support' CONFIG_SCSI_QLOGIC_QLA210=
0 $CONFIG_SCSI
 fi
 if [ "$CONFIG_X86" =3D "y" ]; then
    dep_tristate 'Seagate ST-02 and Future Domain TMC-8xx SCSI support' CON=
FIG_SCSI_SEAGATE $CONFIG_SCSI
diff -urN linux-davidm/drivers/scsi/Makefile linux-2.4.7-lia/drivers/scsi/M=
akefile
--- linux-davidm/drivers/scsi/Makefile	Mon Jul 23 16:15:07 2001
+++ linux-2.4.7-lia/drivers/scsi/Makefile	Mon Jul 23 14:11:45 2001
@@ -86,6 +86,7 @@
 obj-$(CONFIG_SCSI_QLOGIC_ISP)	+=3D qlogicisp.o=20
 obj-$(CONFIG_SCSI_QLOGIC_FC)	+=3D qlogicfc.o=20
 obj-$(CONFIG_SCSI_QLOGIC_1280)	+=3D qla1280.o=20
+obj-$(CONFIG_SCSI_QLOGIC_QLA2100) +=3D qla2x00.o
 obj-$(CONFIG_SCSI_PAS16)	+=3D pas16.o
 obj-$(CONFIG_SCSI_SEAGATE)	+=3D seagate.o
 obj-$(CONFIG_SCSI_FD_8xx)	+=3D seagate.o
diff -urN linux-davidm/drivers/scsi/qla1280.c linux-2.4.7-lia/drivers/scsi/=
qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Mon Jul 23 16:15:07 2001
+++ linux-2.4.7-lia/drivers/scsi/qla1280.c	Sun Apr 29 15:56:25 2001
@@ -1624,7 +1624,6 @@
     {
         printk(KERN_INFO "scsi(): Interrupt with NULL host ptr\n");
         COMTRACE('X')
-        spin_unlock_irqrestore(&io_request_lock, cpu_flags);
         return;
     }
 #if LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,1,95)
diff -urN linux-davidm/fs/devfs/base.c linux-2.4.7-lia/fs/devfs/base.c
--- linux-davidm/fs/devfs/base.c	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/fs/devfs/base.c	Mon Jul 23 14:15:21 2001
@@ -2143,6 +2143,9 @@
 EXPORT_SYMBOL(devfs_register_blkdev);
 EXPORT_SYMBOL(devfs_unregister_chrdev);
 EXPORT_SYMBOL(devfs_unregister_blkdev);
+#ifdef CONFIG_DEVFS_GUID
+EXPORT_SYMBOL(devfs_unregister_slave);
+#endif
=20
=20
 /**
diff -urN linux-davidm/fs/partitions/check.c linux-2.4.7-lia/fs/partitions/=
check.c
--- linux-davidm/fs/partitions/check.c	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/fs/partitions/check.c	Mon Jul 23 14:16:33 2001
@@ -46,6 +46,9 @@
 #ifdef CONFIG_ACORN_PARTITION
 	acorn_partition,
 #endif
+#ifdef CONFIG_EFI_PARTITION
+	efi_partition,
+#endif
 #ifdef CONFIG_MSDOS_PARTITION
 	msdos_partition,
 #endif
@@ -73,9 +76,6 @@
 #ifdef CONFIG_IBM_PARTITION
 	ibm_partition,
 #endif
-#ifdef CONFIG_EFI_PARTITION
-	efi_partition,
-#endif
 	NULL
 };
=20
@@ -523,6 +523,9 @@
 		dev->part[minor].de =3D NULL;
 		devfs_dealloc_unique_number (&disc_numspace,
 					     dev->part[minor].number);
+# ifdef CONFIG_DEVFS_GUID
+		free_disk_guids (dev, minor);
+# endif
 	}
 #endif  /*  CONFIG_DEVFS_FS  */
 }
@@ -572,6 +575,13 @@
 	if (!size || minors =3D 1)
 		return;
=20
+#ifdef CONFIG_DEVFS_GUID
+	/* In case this is a revalidation, free GUID memory.
+	   On the first call for this device,
+	   register_disk has set all entries to NULL,
+	   and nothing will happen. */
+	free_disk_guids (dev, first_minor);
+#endif
 	check_partition(dev, MKDEV(dev->major, first_minor), 1 + first_minor);
=20
  	/*
diff -urN linux-davidm/include/asm-ia64/acpi-ext.h linux-2.4.7-lia/include/=
asm-ia64/acpi-ext.h
--- linux-davidm/include/asm-ia64/acpi-ext.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.7-lia/include/asm-ia64/acpi-ext.h	Mon Jul 23 14:16:42 2001
@@ -5,12 +5,12 @@
  * Advanced Configuration and Power Infterface
  * Based on 'ACPI Specification 1.0b' Febryary 2, 1999
  * and 'IA-64 Extensions to the ACPI Specification' Rev 0.6
- *=20
+ *
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 2000 Intel Corp.
  * Copyright (C) 2000 J.I. Lee <jung-ik.lee@intel.com>
- *	ACPI 2.0 specification=20
+ *	ACPI 2.0 specification
  */
=20
 #include <linux/types.h>
@@ -146,6 +146,9 @@
 	u32 lapic_address;
 	u32 flags;
 } acpi_madt_t;
+
+/* acpi 2.0 MADT flags */
+#define MADT_PCAT_COMPAT	(1<<0)
=20
 /* acpi 2.0 MADT structure types */
 #define ACPI20_ENTRY_LOCAL_APIC                 0
diff -urN linux-davidm/include/asm-ia64/efi.h linux-2.4.7-lia/include/asm-i=
a64/efi.h
--- linux-davidm/include/asm-ia64/efi.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/asm-ia64/efi.h	Mon Jul 23 14:38:28 2001
@@ -238,7 +238,7 @@
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
 extern void efi_gettimeofday (struct timeval *tv);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, =
if possible */
-
+extern u64  efi_get_iobase (void);
=20
 /*
  * Variable Attributes
diff -urN linux-davidm/include/asm-ia64/hardirq.h linux-2.4.7-lia/include/a=
sm-ia64/hardirq.h
--- linux-davidm/include/asm-ia64/hardirq.h	Sun Apr 29 15:50:41 2001
+++ linux-2.4.7-lia/include/asm-ia64/hardirq.h	Mon Jul 23 14:38:18 2001
@@ -16,15 +16,15 @@
 /*
  * No irq_cpustat_t for IA-64.  The data is held in the per-CPU data struc=
ture.
  */
-#define softirq_active(cpu)		(cpu_data[cpu].softirq.active)
-#define softirq_mask(cpu)		(cpu_data[cpu].softirq.mask)
-#define irq_count(cpu)			(cpu_data[cpu].irq_stat.f.irq_count)
-#define bh_count(cpu)			(cpu_data[cpu].irq_stat.f.bh_count)
+#define softirq_pending(cpu)		(cpu_data(cpu)->softirq_pending)
+#define ksoftirqd_task(cpu)		(cpu_data(cpu)->ksoftirqd)
+#define irq_count(cpu)			(cpu_data(cpu)->irq_stat.f.irq_count)
+#define bh_count(cpu)			(cpu_data(cpu)->irq_stat.f.bh_count)
 #define syscall_count(cpu)		/* unused on IA-64 */
 #define nmi_count(cpu)			0
=20
-#define local_softirq_active()		(local_cpu_data->softirq.active)
-#define local_softirq_mask()		(local_cpu_data->softirq.mask)
+#define local_softirq_pending()		(local_cpu_data->softirq_pending)
+#define local_ksoftirqd()		(local_cpu_data->ksoftirqd);
 #define local_irq_count()		(local_cpu_data->irq_stat.f.irq_count)
 #define local_bh_count()		(local_cpu_data->irq_stat.f.bh_count)
 #define local_syscall_count()		/* unused on IA-64 */
diff -urN linux-davidm/include/asm-ia64/ia32.h linux-2.4.7-lia/include/asm-=
ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/asm-ia64/ia32.h	Mon Jul 23 14:38:14 2001
@@ -367,10 +367,10 @@
 	 | ((((sd) >> IA32_SEG_DB) & 0x1) << SEG_DB)						 \
 	 | ((((sd) >> IA32_SEG_G) & 0x1) << SEG_G))
=20
-#define IA32_IOBASE    0x2000000000000000 /* Virtual address for I/O space=
 */
+#define IA32_IOBASE	0x2000000000000000 /* Virtual address for I/O space */
=20
-#define IA32_CR0       0x80000001      /* Enable PG and PE bits */
-#define IA32_CR4       0	       /* No architectural extensions */
+#define IA32_CR0	0x80000001	/* Enable PG and PE bits */
+#define IA32_CR4	0x600		/* MMXEX and FXSR on */
=20
 /*
  *  IA32 floating point control registers starting values
diff -urN linux-davidm/include/asm-ia64/io.h linux-2.4.7-lia/include/asm-ia=
64/io.h
--- linux-davidm/include/asm-ia64/io.h	Sun Apr 29 15:50:41 2001
+++ linux-2.4.7-lia/include/asm-ia64/io.h	Mon Jul 23 14:38:11 2001
@@ -333,7 +333,7 @@
 #define readb(a)	__readb((void *)(a))
 #define readw(a)	__readw((void *)(a))
 #define readl(a)	__readl((void *)(a))
-#define readq(a)	__readqq((void *)(a))
+#define readq(a)	__readq((void *)(a))
 #define __raw_readb	readb
 #define __raw_readw	readw
 #define __raw_readl	readl
diff -urN linux-davidm/include/asm-ia64/iosapic.h linux-2.4.7-lia/include/a=
sm-ia64/iosapic.h
--- linux-davidm/include/asm-ia64/iosapic.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.7-lia/include/asm-ia64/iosapic.h	Mon Jul 23 14:18:00 2001
@@ -51,7 +51,8 @@
=20
 #ifndef __ASSEMBLY__
=20
-extern void __init iosapic_init (unsigned long address, unsigned int base_=
irq);
+extern void __init iosapic_init (unsigned long address, unsigned int base_=
irq,
+                                 int pcat_compat);
 extern void iosapic_register_legacy_irq (unsigned long irq, unsigned long =
pin,
 					 unsigned long polarity, unsigned long trigger);
 extern void iosapic_pci_fixup (int);
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.7-lia/include/a=
sm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/asm-ia64/offsets.h	Mon Jul 23 14:18:19 2001
@@ -1,16 +1,13 @@
 #ifndef _ASM_IA64_OFFSETS_H
 #define _ASM_IA64_OFFSETS_H
-
 /*
  * DO NOT MODIFY
  *
- * This file was generated by arch/ia64/tools/print_offsets.
+ * This file was generated by arch/ia64/tools/print_offsets.awk.
  *
  */
-
-#define PT_PTRACED_BIT			0
-#define PT_TRACESYS_BIT			1
-
+#define PT_PTRACED_BIT		0
+#define PT_TRACESYS_BIT		1
 #define IA64_TASK_SIZE			3904	/* 0xf40 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
@@ -76,7 +73,7 @@
 #define IA64_PT_REGS_F8_OFFSET		368	/* 0x170 */
 #define IA64_PT_REGS_F9_OFFSET		384	/* 0x180 */
 #define IA64_SWITCH_STACK_CALLER_UNAT_OFFSET 0	/* 0x0 */
-#define IA64_SWITCH_STACK_AR_FPSR_OFFSET	8	/* 0x8 */
+#define IA64_SWITCH_STACK_AR_FPSR_OFFSET 8	/* 0x8 */
 #define IA64_SWITCH_STACK_F2_OFFSET	16	/* 0x10 */
 #define IA64_SWITCH_STACK_F3_OFFSET	32	/* 0x20 */
 #define IA64_SWITCH_STACK_F4_OFFSET	48	/* 0x30 */
@@ -115,8 +112,8 @@
 #define IA64_SWITCH_STACK_B5_OFFSET	504	/* 0x1f8 */
 #define IA64_SWITCH_STACK_AR_PFS_OFFSET	512	/* 0x200 */
 #define IA64_SWITCH_STACK_AR_LC_OFFSET	520	/* 0x208 */
-#define IA64_SWITCH_STACK_AR_UNAT_OFFSET	528	/* 0x210 */
-#define IA64_SWITCH_STACK_AR_RNAT_OFFSET	536	/* 0x218 */
+#define IA64_SWITCH_STACK_AR_UNAT_OFFSET 528	/* 0x210 */
+#define IA64_SWITCH_STACK_AR_RNAT_OFFSET 536	/* 0x218 */
 #define IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET 544	/* 0x220 */
 #define IA64_SWITCH_STACK_PR_OFFSET	552	/* 0x228 */
 #define IA64_SIGCONTEXT_AR_BSP_OFFSET	72	/* 0x48 */
@@ -135,12 +132,10 @@
 #define IA64_SIGFRAME_RBS_BASE_OFFSET	24	/* 0x18 */
 #define IA64_SIGFRAME_HANDLER_OFFSET	32	/* 0x20 */
 #define IA64_SIGFRAME_SIGCONTEXT_OFFSET	176	/* 0xb0 */
-#define IA64_CLONE_VFORK			16384	/* 0x4000 */
+#define IA64_CLONE_VFORK		16384	/* 0x4000 */
 #define IA64_CLONE_VM			256	/* 0x100 */
-#define IA64_CPU_IRQ_COUNT_OFFSET	8	/* 0x8 */
-#define IA64_CPU_BH_COUNT_OFFSET		12	/* 0xc */
-#define IA64_CPU_SOFTIRQ_ACTIVE_OFFSET	0	/* 0x0 */
-#define IA64_CPU_SOFTIRQ_MASK_OFFSET	4	/* 0x4 */
-#define IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET 16	/* 0x10 */
+#define IA64_CPU_IRQ_COUNT_OFFSET	0	/* 0x0 */
+#define IA64_CPU_BH_COUNT_OFFSET	4	/* 0x4 */
+#define IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET 12	/* 0xc */
=20
 #endif /* _ASM_IA64_OFFSETS_H */
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.7-lia/include=
/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/asm-ia64/processor.h	Mon Jul 23 14:38:11 2001
@@ -235,11 +235,7 @@
  * state comes earlier:
  */
 struct cpuinfo_ia64 {
-	/* irq_stat and softirq should be 64-bit aligned */
-	struct {
-		__u32 active;
-		__u32 mask;
-	} softirq;
+	/* irq_stat must be 64-bit aligned */
 	union {
 		struct {
 			__u32 irq_count;
@@ -247,8 +243,8 @@
 		} f;
 		__u64 irq_and_bh_counts;
 	} irq_stat;
+	__u32 softirq_pending;
 	__u32 phys_stacked_size_p8;	/* size of physical stacked registers + 8 */
-	__u32 pad0;
 	__u64 itm_delta;	/* # of clock cycles between clock ticks */
 	__u64 itm_next;		/* interval timer mask value to use for next clock tick =
*/
 	__u64 *pgd_quick;
@@ -273,6 +269,7 @@
 	__u64 ptce_base;
 	__u32 ptce_count[2];
 	__u32 ptce_stride[2];
+	struct task_struct *ksoftirqd;	/* kernel softirq daemon for this CPU */
 #ifdef CONFIG_SMP
 	__u64 loops_per_jiffy;
 	__u64 ipi_count;
@@ -280,6 +277,9 @@
 	__u64 prof_multiplier;
 	__u64 ipi_operation;
 #endif
+#ifdef CONFIG_NUMA
+	struct cpuinfo_ia64 *cpu_data[NR_CPUS];
+#endif
 } __attribute__ ((aligned (PAGE_SIZE))) ;
=20
 /*
@@ -288,7 +288,22 @@
  */
 #define local_cpu_data		((struct cpuinfo_ia64 *) PERCPU_ADDR)
=20
-extern struct cpuinfo_ia64 cpu_data[NR_CPUS];
+/*
+ * On NUMA systems, cpu_data for each cpu is allocated during cpu_init() &=
 is allocated on
+ * the node that contains the cpu. This minimizes off-node memory referenc=
es.  cpu_data
+ * for each cpu contains an array of pointers to the cpu_data structures o=
f each of the
+ * other cpus.
+ *
+ * On non-NUMA systems, cpu_data is a static array allocated at compile ti=
me.  References
+ * to the cpu_data of another cpu is done by direct references to the appr=
opriate entry of
+ * the array.
+ */
+#ifdef CONFIG_NUMA
+# define cpu_data(cpu)		local_cpu_data->cpu_data_ptrs[cpu]
+#else
+  extern struct cpuinfo_ia64 _cpu_data[NR_CPUS];
+# define cpu_data(cpu)		(&_cpu_data[cpu])
+#endif
=20
 extern void identify_cpu (struct cpuinfo_ia64 *);
 extern void print_cpu_info (struct cpuinfo_ia64 *);
diff -urN linux-davidm/include/asm-ia64/smp.h linux-2.4.7-lia/include/asm-i=
a64/smp.h
--- linux-davidm/include/asm-ia64/smp.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/asm-ia64/smp.h	Mon Jul 23 14:38:11 2001
@@ -40,7 +40,7 @@
 extern unsigned char smp_int_redirect;
 extern int smp_num_cpus;
=20
-extern  volatile int ia64_cpu_to_sapicid[];
+extern volatile int ia64_cpu_to_sapicid[];
 #define cpu_physical_id(i)	ia64_cpu_to_sapicid[i]
 #define cpu_number_map(i)	(i)
 #define cpu_logical_map(i)	(i)
diff -urN linux-davidm/include/asm-ia64/softirq.h linux-2.4.7-lia/include/a=
sm-ia64/softirq.h
--- linux-davidm/include/asm-ia64/softirq.h	Sun Apr 29 15:50:45 2001
+++ linux-2.4.7-lia/include/asm-ia64/softirq.h	Mon Jul 23 14:38:20 2001
@@ -7,8 +7,18 @@
  */
 #include <asm/hardirq.h>
=20
+#define __local_bh_enable()	do { barrier(); local_bh_count()--; } while (0)
+
 #define local_bh_disable()	do { local_bh_count()++; barrier(); } while (0)
-#define local_bh_enable()	do { barrier(); local_bh_count()--; } while (0)
+#define local_bh_enable()								\
+do {											\
+	__local_bh_enable();								\
+	if (__builtin_expect(local_softirq_pending(), 0) && local_bh_count() =3D =
0)	\
+		do_softirq();								\
+} while (0)
+
+
+#define __cpu_raise_softirq(cpu,nr)	set_bit((nr), &softirq_pending(cpu))
=20
 #define in_softirq()		(local_bh_count() !=3D 0)
=20
diff -urN linux-davidm/include/asm-ia64/string.h linux-2.4.7-lia/include/as=
m-ia64/string.h
--- linux-davidm/include/asm-ia64/string.h	Mon Oct  9 17:55:00 2000
+++ linux-2.4.7-lia/include/asm-ia64/string.h	Mon Jul 23 14:19:48 2001
@@ -10,7 +10,6 @@
  */
=20
 #include <linux/config.h>	/* remove this once we remove the A-step workaro=
und... */
-#ifndef CONFIG_ITANIUM_ASTEP_SPECIFIC
=20
 #define __HAVE_ARCH_STRLEN	1 /* see arch/ia64/lib/strlen.S */
 #define __HAVE_ARCH_MEMSET	1 /* see arch/ia64/lib/memset.S */
@@ -20,7 +19,5 @@
 extern __kernel_size_t strlen (const char *);
 extern void *memset (void *, int, __kernel_size_t);
 extern void *memcpy (void *, const void *, __kernel_size_t);
-
-#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC */
=20
 #endif /* _ASM_IA64_STRING_H */
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.7-lia/include/as=
m-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Sun Apr 29 15:50:45 2001
+++ linux-2.4.7-lia/include/asm-ia64/system.h	Mon Jul 23 14:38:11 2001
@@ -29,8 +29,7 @@
 #define GATE_ADDR		(0xa000000000000000 + PAGE_SIZE)
 #define PERCPU_ADDR		(0xa000000000000000 + 2*PAGE_SIZE)
=20
-#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
-    || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SP=
ECIFIC)
+#if defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SPECI=
FIC)
   /* Workaround for Errata 97.  */
 # define IA64_SEMFIX_INSN	mf;
 # define IA64_SEMFIX	"mf;"
diff -urN linux-davidm/include/linux/agp_backend.h linux-2.4.7-lia/include/=
linux/agp_backend.h
--- linux-davidm/include/linux/agp_backend.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/linux/agp_backend.h	Mon Jul 23 14:39:37 2001
@@ -50,6 +50,7 @@
 	INTEL_I815,
 	INTEL_I840,
 	INTEL_I850,
+	INTEL_460GX,
 	VIA_GENERIC,
 	VIA_VP3,
 	VIA_MVP3,
diff -urN linux-davidm/include/linux/genhd.h linux-2.4.7-lia/include/linux/=
genhd.h
--- linux-davidm/include/linux/genhd.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/linux/genhd.h	Mon Jul 23 14:39:21 2001
@@ -56,6 +56,9 @@
 	long nr_sects;
 	devfs_handle_t de;              /* primary (master) devfs entry  */
 	int number;                     /* stupid old code wastes space  */
+#ifdef CONFIG_DEVFS_GUID
+	efi_guid_t *guid;
+#endif
 };
=20
 #define GENHD_FL_REMOVABLE  1
diff -urN linux-davidm/include/linux/irq_cpustat.h linux-2.4.7-lia/include/=
linux/irq_cpustat.h
--- linux-davidm/include/linux/irq_cpustat.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/linux/irq_cpustat.h	Mon Jul 23 14:21:12 2001
@@ -23,12 +23,12 @@
 #define __IRQ_STAT(cpu, member)	(irq_stat[cpu].member)
 #else
 #define __IRQ_STAT(cpu, member)	((void)(cpu), irq_stat[0].member)
-#endif=09
+#endif
=20
   /* arch independent irq_stat fields */
 #define softirq_pending(cpu)	__IRQ_STAT((cpu), __softirq_pending)
-#define local_irq_count(cpu)	__IRQ_STAT((cpu), __local_irq_count)
-#define local_bh_count(cpu)	__IRQ_STAT((cpu), __local_bh_count)
+#define irq_count(cpu)		__IRQ_STAT((cpu), __irq_count)
+#define bh_count(cpu)		__IRQ_STAT((cpu), __bh_count)
 #define syscall_count(cpu)	__IRQ_STAT((cpu), __syscall_count)
 #define ksoftirqd_task(cpu)	__IRQ_STAT((cpu), __ksoftirqd_task)
   /* arch dependent irq_stat fields */
diff -urN linux-davidm/include/linux/sched.h linux-2.4.7-lia/include/linux/=
sched.h
--- linux-davidm/include/linux/sched.h	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/include/linux/sched.h	Mon Jul 23 14:38:12 2001
@@ -539,7 +539,7 @@
 extern unsigned long volatile jiffies;
 extern unsigned long itimer_ticks;
 extern unsigned long itimer_next;
-extern volatile struct timeval xtime;
+extern struct timeval xtime;
 extern void do_timer(struct pt_regs *);
=20
 extern unsigned int * prof_buffer;
diff -urN linux-davidm/include/linux/string.h linux-2.4.7-lia/include/linux=
/string.h
--- linux-davidm/include/linux/string.h	Sun Apr 29 15:50:56 2001
+++ linux-2.4.7-lia/include/linux/string.h	Mon Jul 23 14:21:49 2001
@@ -79,6 +79,7 @@
 #ifndef __HAVE_ARCH_MEMCHR
 extern void * memchr(const void *,int,__kernel_size_t);
 #endif
+extern char * kstrdup(const char *,int);
=20
 #ifdef __cplusplus
 }
diff -urN linux-davidm/kernel/pm.c linux-2.4.7-lia/kernel/pm.c
--- linux-davidm/kernel/pm.c	Sun Apr 29 15:50:57 2001
+++ linux-2.4.7-lia/kernel/pm.c	Mon Jul 23 14:22:24 2001
@@ -162,7 +162,7 @@
 	case PM_SUSPEND:
 	case PM_RESUME:
 		prev_state =3D dev->state;
-		next_state =3D (int) data;
+		next_state =3D (long) data;
 		if (prev_state !=3D next_state) {
 			if (dev->callback)
 				status =3D (*dev->callback)(dev, rqst, data);
@@ -197,7 +197,7 @@
 			 */
 			pm_request_t undo =3D (dev->prev_state
 					     ? PM_SUSPEND:PM_RESUME);
-			pm_send(dev, undo, (void*) dev->prev_state);
+			pm_send(dev, undo, (void*) (long) dev->prev_state);
 		}
 		entry =3D entry->prev;
 	}
diff -urN linux-davidm/kernel/softirq.c linux-2.4.7-lia/kernel/softirq.c
--- linux-davidm/kernel/softirq.c	Mon Jul 23 16:15:10 2001
+++ linux-2.4.7-lia/kernel/softirq.c	Mon Jul 23 14:22:33 2001
@@ -40,10 +40,10 @@
    - Bottom halves: globally serialized, grr...
  */
=20
-/* No separate irq_stat for s390, it is part of PSA */
+/* No separate irq_stat for s390 and ia64, it is part of PSA */
 #if !defined(CONFIG_ARCH_S390) && !defined(CONFIG_IA64)
 irq_cpustat_t irq_stat[NR_CPUS];
-#endif
+#endif	/* CONFIG_ARCH_S390 || CONFIG_IA64 */
=20
 static struct softirq_action softirq_vec[32] __cacheline_aligned;
=20
@@ -124,7 +124,7 @@
 	 * Otherwise we wake up ksoftirqd to make sure we
 	 * schedule the softirq soon.
 	 */
-	if (!(local_irq_count(cpu) | local_bh_count(cpu)))
+	if (!(irq_count(cpu) | bh_count(cpu)))
 		wakeup_softirqd(cpu);
 }
=20

