From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 22 Feb 2001 01:06:52 +0000
Subject: [Linux-ia64] kernel test patch available
Message-Id: <marc-linux-ia64-105590693005189@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

A test patch is now available at:

  ftp://linux.kernel.org/pub/linux/kernel/ports/ia64/testing/test-010221.di=
ff.gz

This is a *test* patch, so treat it with proper care.  In particular,
please don't make distros based on this patch.

I've got a plane to catch, so I keep this brief: read the source to
see what changed. ;-)

OK, a little more: this patch cleans up various things, but the
interesting stuff is:

	- The local per-CPU data is now mapped at
	  0xa000000000000000+2*PAGE_SIZE.  This allows efficient
	  access to per-CPU variables in an MP environment.

	- On an execve(), the registers are cleared, as they should
          be.  As a heads up, in a next step I'm planning to get rid
          of saving/restoring the scratch registers on a system call.
          This will simplify the execve() register clearing and, not
          to mention, speed up system call execution (of course, the
          kernel will clear the scratch registers upon returning from
          the system call so as to avoid leaking kernel data to user
          space).

	- When returning to user mode, the "invalid" partition of the
	  stacked registers get cleared now (as they should be).  Someone
	  with access to Intel's "visual assembler" might want to double
	  check that code to make sure it really runs at the advertised
	  speed. ;-)

OK, that's it for now.  Note: this patch is known to build and work fine
on Big Sur and HP Ski simulator.  No reason to believe it wouldn't work
on a Lion, but, for lack of time, I wasn't able to test it.

The diff below is relative against the previous IA-64 kernel.  As usual,
it's fyi only.

	--david

PS: Kanoj, sorry, still no percpu irq patch---it'll be the first patch
    I take care of when returning.  I simply didn't have the energy to
    add another potential source errors today...

diff -urN linux-davidm/arch/ia64/boot/bootloader.c linux-2.4.1-lia/arch/ia6=
4/boot/bootloader.c
--- linux-davidm/arch/ia64/boot/bootloader.c	Mon Oct  9 17:54:53 2000
+++ linux-2.4.1-lia/arch/ia64/boot/bootloader.c	Wed Feb 21 16:04:16 2001
@@ -3,8 +3,8 @@
  *
  * Loads an ELF kernel.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998, 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1998, 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
  *
  * 01/07/99 S.Eranian modified to pass command line arguments to kernel
@@ -198,19 +198,22 @@
 	asm volatile ("mov ar.k0=3D%0" :: "r"(0xffffc000000UL));
=20
 	/*
-	 * Install a translation register that identity maps the
-	 * kernel's 256MB page.
+	 * Install a translation register that identity maps the kernel's 256MB p=
age.
 	 */
 	ia64_clear_ic(flags);
 	ia64_set_rr(          0, (0x1000 << 8) | (_PAGE_SIZE_1M << 2));
 	ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) | (_PAGE_SIZE_25=
6M << 2));
 	ia64_srlz_d();
-	ia64_itr(0x3, 0, 1024*1024,
-		 pte_val(mk_pte_phys(1024*1024, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_A=
R_RWX))),
-		 _PAGE_SIZE_1M);
-	ia64_itr(0x3, 1, PAGE_OFFSET,
+	ia64_itr(0x3, IA64_TR_KERNEL, PAGE_OFFSET,
 		 pte_val(mk_pte_phys(0, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
 		 _PAGE_SIZE_256M);
+	/*
+	 * Map the bootloader with itr1 and dtr1; dtr1 will later be re-used for =
other
+	 * purposes, but itr1 will stick.
+	 */
+	ia64_itr(0x3, IA64_TR_PALCODE, 1024*1024,
+		 pte_val(mk_pte_phys(1024*1024, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_A=
R_RWX))),
+		 _PAGE_SIZE_1M);
 	ia64_srlz_i();
=20
 	enter_virtual_mode(flags | IA64_PSR_IT | IA64_PSR_IC | IA64_PSR_DT | IA64=
_PSR_RT
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.1-lia/arch/ia64/config=
.in
--- linux-davidm/arch/ia64/config.in	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/config.in	Wed Feb 21 16:04:42 2001
@@ -63,7 +63,6 @@
=20
 if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
 	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
-	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 	bool '  Enable ACPI 2.0 with errata 1.3' CONFIG_ACPI20
 	bool '  ACPI kernel configuration manager (EXPERIMENTAL)' CONFIG_ACPI_KER=
NEL_CONFIG
@@ -92,7 +91,7 @@
=20
 bool 'SMP support' CONFIG_SMP
 bool 'Performance monitor support' CONFIG_PERFMON
-bool '/proc/pal support' CONFIG_IA64_PALINFO
+tristate  '/proc/pal support' CONFIG_IA64_PALINFO
=20
 bool 'Networking support' CONFIG_NET
 bool 'System V IPC' CONFIG_SYSVIPC
diff -urN linux-davidm/arch/ia64/dig/setup.c linux-2.4.1-lia/arch/ia64/dig/=
setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/dig/setup.c	Wed Feb 21 16:04:57 2001
@@ -1,9 +1,9 @@
 /*
- * Platform dependent support for Intel SoftSDV simulator.
+ * Platform dependent support for DIG64 platforms.
  *
  * Copyright (C) 1999 Intel Corp.
- * Copyright (C) 1999 Hewlett-Packard Co
- * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999 Vijay Chander <vijay@engr.sgi.com>
@@ -47,10 +47,6 @@
 	 * physical disk 1 partition 2.
 	 */
 	ROOT_DEV =3D to_kdev_t(0x0802);		/* default to second partition on first =
drive */
-
-#ifdef	CONFIG_IA64_SOFTSDV_HACKS
-	ROOT_DEV =3D to_kdev_t(0x0302);		/* 2nd partion on 1st IDE */
-#endif /* CONFIG_IA64_SOFTSDV_HACKS */
=20
 #ifdef CONFIG_SMP
 	init_smp_config();
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c linux-2.4.1-lia/arch/i=
a64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/ia32/binfmt_elf32.c	Wed Feb 21 16:05:10 2001
@@ -125,14 +125,8 @@
 		: "r" ((ulong)IA32_FCR_DEFAULT));
 	__asm__("mov ar.fir =3D r0");
 	__asm__("mov ar.fdr =3D r0");
-	__asm__("mov %0=3Dar.k0 ;;" : "=3Dr" (current->thread.old_iob));
-	__asm__("mov ar.k0=3D%0 ;;" :: "r"(IA32_IOBASE));
-	/* TSS */
-	__asm__("mov ar.k1 =3D %0"
-		: /* no outputs */
-		: "r" IA64_SEG_DESCRIPTOR(IA32_PAGE_OFFSET + PAGE_SIZE,
-					  0x1FFFL, 0xBL, 1L,
-					  3L, 1L, 1L, 1L));
+	current->thread.old_iob =3D ia64_get_kr(IA64_KR_IO_BASE);
+	ia64_set_kr(IA64_KR_IO_BASE, IA32_IOBASE);
=20
 	/* Get the segment selectors right */
 	regs->r16 =3D (__USER_DS << 16) |  (__USER_DS); /* ES =3D DS, GS, FS are =
zero */
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.1-lia/arch/ia6=
4/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/ia32/ia32_entry.S	Wed Feb 21 16:05:18 2001
@@ -254,7 +254,7 @@
 	data8 sys32_sigreturn
 	data8 sys_clone		  /* 120 */
 	data8 sys_setdomainname
-	data8 sys_newuname
+	data8 sys32_newuname
 	data8 sys_modify_ldt
 	data8 sys_adjtimex
 	data8 sys32_mprotect	  /* 125 */
@@ -281,7 +281,7 @@
 	data8 sys32_writev
 	data8 sys_getsid
 	data8 sys_fdatasync
-	data8 sys_sysctl
+	data8 sys32_sysctl
 	data8 sys_mlock		  /* 150 */
 	data8 sys_munlock
 	data8 sys_mlockall
diff -urN linux-davidm/arch/ia64/ia32/ia32_support.c linux-2.4.1-lia/arch/i=
a64/ia32/ia32_support.c
--- linux-davidm/arch/ia64/ia32/ia32_support.c	Mon Oct  9 17:54:53 2000
+++ linux-2.4.1-lia/arch/ia64/ia32/ia32_support.c	Wed Feb 21 16:05:28 2001
@@ -2,6 +2,7 @@
  * IA32 helper functions
  *
  * 06/16/00	A. Mallick	added csd/ssd/tssd for ia32 thread context
+ * 02/19/01	D. Mosberger	dropped tssd; it's not needed
  */
=20
 #include <linux/kernel.h>
@@ -22,7 +23,7 @@
 void
 ia32_save_state (struct thread_struct *thread)
 {
-	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd, tssd;
+	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd;
=20
 	asm ("mov %0=3Dar.eflag;"
 	     "mov %1=3Dar.fsr;"
@@ -31,9 +32,7 @@
 	     "mov %4=3Dar.fdr;"
 	     "mov %5=3Dar.csd;"
 	     "mov %6=3Dar.ssd;"
-	     "mov %7=3Dar.k1"
-	     : "=3Dr"(eflag), "=3Dr"(fsr), "=3Dr"(fcr), "=3Dr"(fir), "=3Dr"(fdr),
-	       "=3Dr"(csd), "=3Dr"(ssd), "=3Dr"(tssd));
+	     : "=3Dr"(eflag), "=3Dr"(fsr), "=3Dr"(fcr), "=3Dr"(fir), "=3Dr"(fdr),=
 "=3Dr"(csd), "=3Dr"(ssd));
 	thread->eflag =3D eflag;
 	thread->fsr =3D fsr;
 	thread->fcr =3D fcr;
@@ -41,14 +40,13 @@
 	thread->fdr =3D fdr;
 	thread->csd =3D csd;
 	thread->ssd =3D ssd;
-	thread->tssd =3D tssd;
 	asm ("mov ar.k0=3D%0 ;;" :: "r"(thread->old_iob));
 }
=20
 void
 ia32_load_state (struct thread_struct *thread)
 {
-	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd, tssd;
+	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd;
=20
 	eflag =3D thread->eflag;
 	fsr =3D thread->fsr;
@@ -57,7 +55,6 @@
 	fdr =3D thread->fdr;
 	csd =3D thread->csd;
 	ssd =3D thread->ssd;
-	tssd =3D thread->tssd;
=20
 	asm volatile ("mov ar.eflag=3D%0;"
 		      "mov ar.fsr=3D%1;"
@@ -66,9 +63,7 @@
 		      "mov ar.fdr=3D%4;"
 		      "mov ar.csd=3D%5;"
 		      "mov ar.ssd=3D%6;"
-		      "mov ar.k1=3D%7"
-		      :: "r"(eflag), "r"(fsr), "r"(fcr), "r"(fir), "r"(fdr),
-		         "r"(csd), "r"(ssd), "r"(tssd));
+		      :: "r"(eflag), "r"(fsr), "r"(fcr), "r"(fir), "r"(fdr), "r"(csd), "=
r"(ssd));
 	asm ("mov %0=3Dar.k0 ;;" : "=3Dr"(thread->old_iob));
 	asm ("mov ar.k0=3D%0 ;;" :: "r"(IA32_IOBASE));
 }
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.1-lia/arch/ia64/=
ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/ia32/sys_ia32.c	Wed Feb 21 16:05:39 2001
@@ -16,6 +16,7 @@
=20
 #include <linux/config.h>
 #include <linux/kernel.h>
+#include <linux/sysctl.h>
 #include <linux/sched.h>
 #include <linux/fs.h>=20
 #include <linux/file.h>=20
@@ -2683,6 +2684,72 @@
 	return(sys_msync(addr, len + (start - addr), flags));
 }
=20
+struct sysctl_ia32 {
+	unsigned int	name;
+	int		nlen;
+	unsigned int	oldval;
+	unsigned int	oldlenp;
+	unsigned int	newval;
+	unsigned int	newlen;
+	unsigned int	__unused[4];
+};
+                               =20
+extern asmlinkage long sys_sysctl(struct __sysctl_args *args);
+
+asmlinkage long
+sys32_sysctl(struct sysctl_ia32 *args32)
+{
+	struct sysctl_ia32 a32;
+	mm_segment_t old_fs =3D get_fs ();
+	void *oldvalp, *newvalp;
+	size_t oldlen;
+	int *namep;
+	long ret;
+=09
+	if (copy_from_user(&a32, args32, sizeof (a32)))
+		return -EFAULT;
+
+	/*
+	 * We need to pre-validate these because we have to disable address check=
ing
+	 * before calling do_sysctl() because of OLDLEN but we can't run the risk=
 of the
+	 * user specifying bad addresses here.  Well, since we're dealing with 32=
 bit
+	 * addresses, we KNOW that access_ok() will always succeed, so this is an
+	 * expensive NOP, but so what...
+	 */
+	namep =3D (int *) A(a32.name);
+	oldvalp =3D (void *) A(a32.oldval);
+	newvalp =3D (void *) A(a32.newval);
+
+	if ((oldvalp && get_user(oldlen, (int *) A(a32.oldlenp)))
+	    || !access_ok(VERIFY_WRITE, namep, 0)
+	    || !access_ok(VERIFY_WRITE, oldvalp, 0)
+	    || !access_ok(VERIFY_WRITE, newvalp, 0))
+		return -EFAULT;
+
+	set_fs(KERNEL_DS);
+	lock_kernel();
+	ret =3D do_sysctl(namep, a32.nlen, oldvalp, &oldlen, newvalp, (size_t) a3=
2.newlen);
+	unlock_kernel();
+	set_fs(old_fs);
+
+	if (oldvalp && put_user (oldlen, (int *) A(a32.oldlenp)))
+		return -EFAULT;
+
+	return ret;
+}
+
+asmlinkage long
+sys32_newuname(struct new_utsname * name)
+{
+	extern asmlinkage long sys_newuname(struct new_utsname * name);
+	int ret =3D sys_newuname(name);
+=09
+	if (!ret)
+		if (copy_to_user(name->machine, "i686\0\0\0", 8))
+			ret =3D -EFAULT;
+	return ret;
+}
+
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
=20
 /* In order to reduce some races, while at the same time doing additional
@@ -4796,19 +4863,6 @@
 			 (unsigned long) arg5);
 }
=20
-
-extern asmlinkage long sys_newuname(struct new_utsname * name);
-
-asmlinkage long
-sys32_newuname(struct new_utsname * name)
-{
-	int ret =3D sys_newuname(name);
-=09
-	if (current->personality =3D PER_LINUX32 && !ret) {
-		ret =3D copy_to_user(name->machine, "sparc\0\0", 8);
-	}
-	return ret;
-}
=20
 extern asmlinkage ssize_t sys_pread(unsigned int fd, char * buf,
 				    size_t count, loff_t pos);
diff -urN linux-davidm/arch/ia64/kernel/acpi.c linux-2.4.1-lia/arch/ia64/ke=
rnel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/acpi.c	Wed Feb 21 16:06:10 2001
@@ -116,10 +116,10 @@
 	int add =3D 1;
=20
 	acpi20_entry_lsapic_t *lsapic =3D (acpi20_entry_lsapic_t *) p;
-	printk("      CPU %d (%.04x:%.04x): ", total_cpus, lsapic->eid, lsapic->i=
d);
+	printk("      CPU %.04x:%.04x: ", lsapic->eid, lsapic->id);
=20
 	if ((lsapic->flags & LSAPIC_ENABLED) =3D 0) {
-		printk("Disabled.\n");
+		printk("disabled.\n");
 		add =3D 0;
 	}
=20
@@ -127,11 +127,14 @@
 	smp_boot_data.cpu_phys_id[total_cpus] =3D -1;
 #endif
 	if (add) {
-		printk("Available.\n");
 		available_cpus++;
+		printk("available");
 #ifdef CONFIG_SMP
 		smp_boot_data.cpu_phys_id[total_cpus] =3D (lsapic->id << 8) | lsapic->ei=
d;
-#endif /* CONFIG_SMP */
+		if (hard_smp_processor_id() =3D smp_boot_data.cpu_phys_id[total_cpus])
+			printk(" (BSP)");
+#endif
+		printk(".\n");
 	}
 	total_cpus++;
 }
diff -urN linux-davidm/arch/ia64/kernel/brl_emu.c linux-2.4.1-lia/arch/ia64=
/kernel/brl_emu.c
--- linux-davidm/arch/ia64/kernel/brl_emu.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.1-lia/arch/ia64/kernel/brl_emu.c	Wed Feb 21 16:06:24 2001
@@ -23,9 +23,9 @@
  *  of an and operation with the mask must be all 0's
  *  or all 1's for the address to be valid.
  */
-#define unimplemented_virtual_address(va) (					\
-	((va) & my_cpu_data.unimpl_va_mask) !=3D 0 &&				\
-	((va) & my_cpu_data.unimpl_va_mask) !=3D my_cpu_data.unimpl_va_mask	\
+#define unimplemented_virtual_address(va) (						\
+	((va) & current_cpu_data->unimpl_va_mask) !=3D 0 &&				\
+	((va) & current_cpu_data->unimpl_va_mask) !=3D current_cpu_data->unimpl_v=
a_mask	\
 )
=20
 /*
@@ -35,7 +35,7 @@
  *  address to be valid.
  */
 #define unimplemented_physical_address(pa) (		\
-	((pa) & my_cpu_data.unimpl_pa_mask) !=3D 0	\
+	((pa) & current_cpu_data->unimpl_pa_mask) !=3D 0	\
 )
=20
 /*
diff -urN linux-davidm/arch/ia64/kernel/efi.c linux-2.4.1-lia/arch/ia64/ker=
nel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/efi.c	Wed Feb 21 16:07:02 2001
@@ -5,9 +5,9 @@
  *
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 1999-2000 Hewlett-Packard Co.
+ * Copyright (C) 1999-2001 Hewlett-Packard Co.
  * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999-2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1999-2001 Stephane Eranian <eranian@hpl.hp.com>
  *
  * All EFI Runtime Services are not implemented yet as EFI only
  * supports physical mode addressing on SoftSDV. This is to be fixed
@@ -16,7 +16,7 @@
  * Implemented EFI runtime services and virtual mode calls.  --davidm
  *
  * Goutham Rao: <goutham.rao@intel.com>
- * 	Skip non-WB memory and ignore empty memory ranges.
+ *	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/config.h>
 #include <linux/kernel.h>
@@ -26,6 +26,7 @@
=20
 #include <asm/efi.h>
 #include <asm/io.h>
+#include <asm/kregs.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
=20
@@ -220,7 +221,7 @@
 		/*
 		 * We must use the same page size as the one used
 		 * for the kernel region when we map the PAL code.
-		 * This way, we avoid overlapping TRs if code is=20
+		 * This way, we avoid overlapping TRs if code is
 		 * executed nearby. The Alt I-TLB installs 256MB
 		 * page sizes as defined for region 7.
 		 *
@@ -231,7 +232,7 @@
=20
 		/*
 		 * We must check that the PAL mapping won't overlap
-		 * with the kernel mapping on ITR1.=20
+		 * with the kernel mapping.
 		 *
 		 * PAL code is guaranteed to be aligned on a power of 2
 		 * between 4k and 256KB.
@@ -249,7 +250,7 @@
 			continue;
 		}
=20
-	  	printk("CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
+		printk("CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
 		       smp_processor_id(), md->phys_addr, md->phys_addr + (md->num_pages=
 << 12),
 		       vaddr & mask, (vaddr & mask) + 256*1024*1024);
=20
@@ -257,22 +258,14 @@
 		 * Cannot write to CRx with PSR.ic=3D1
 		 */
 		ia64_clear_ic(flags);
-
-		/*
-		 * ITR0/DTR0: used for kernel code/data
-		 * ITR1/DTR1: used by HP simulator
-		 * ITR2/DTR2: map PAL code
-		 */
-		ia64_itr(0x1, 2, vaddr & mask,
-			 pte_val(mk_pte_phys(md->phys_addr,
-					     __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX))),
-			 _PAGE_SIZE_256M);
+		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
+			 pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL)), _PAGE_SIZE_256M);
 		local_irq_restore(flags);
-		ia64_srlz_i ();
+		ia64_srlz_i();
 	}
 }
=20
-void __init=20
+void __init
 efi_init (void)
 {
 	void *efi_map_start, *efi_map_end;
@@ -305,10 +298,10 @@
=20
 	/*
 	 * Verify the EFI Table
- 	 */
-	if (efi.systab =3D NULL)=20
+	 */
+	if (efi.systab =3D NULL)
 		panic("Woah! Can't find EFI system table.\n");
-	if (efi.systab->hdr.signature !=3D EFI_SYSTEM_TABLE_SIGNATURE)=20
+	if (efi.systab->hdr.signature !=3D EFI_SYSTEM_TABLE_SIGNATURE)
 		panic("Woah! EFI system table signature incorrect\n");
 	if ((efi.systab->hdr.revision ^ EFI_SYSTEM_TABLE_REVISION) >> 16 !=3D 0)
 		printk("Warning: EFI system table major version mismatch: "
@@ -380,15 +373,7 @@
 #endif
=20
 	efi_map_pal_code();
-
-#ifndef CONFIG_IA64_SOFTSDV_HACKS
-	/*
-	 * (Some) SoftSDVs seem to have a problem with this call.
-	 * Since it's mostly a performance optimization, just don't do
-	 * it for now...  --davidm 99/12/6
-	 */
 	efi_enter_virtual_mode();
-#endif
=20
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.1-lia/arch/ia64/k=
ernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/entry.S	Wed Feb 21 16:40:59 2001
@@ -1,3 +1,5 @@
+#define NEW_LEAVE_KERNEL_HEAD	1
+#define CLEAR_INVALID		1
 /*
  * ia64/kernel/entry.S
  *
@@ -15,8 +17,6 @@
  * kernel stack. This allows us to handle interrupts without changing
  * to physical mode.
  *
- * ar.k4 is now used to hold last virtual map address
- *=20
  * Jonathan Nickin	<nicklin@missioncriticallinux.com>
  * Patrick O'Rourke	<orourke@missioncriticallinux.com>
  * 11/07/2000
@@ -25,21 +25,22 @@
  * Global (preserved) predicate usage on syscall entry/exit path:
  *
  *	pKern:		See entry.h.
+ *	pUser:		See entry.h.
  *	pSys:		See entry.h.
  *	pNonSys:	!pSys
- *	p2:		(Alias of pKern!) True if any signals are pending.
  */
=20
 #include <linux/config.h>
=20
 #include <asm/cache.h>
 #include <asm/errno.h>
+#include <asm/kregs.h>
 #include <asm/offsets.h>
 #include <asm/processor.h>
 #include <asm/unistd.h>
 #include <asm/asmmacro.h>
 #include <asm/pgtable.h>
-=09
+
 #include "minstate.h"
=20
 	.text
@@ -62,13 +63,35 @@
 	mov out2=3Din2			// envp
 	add out3=16,sp			// regs
 	br.call.sptk.few rp=3Dsys_execve
-.ret0:	cmp4.ge p6,p0=3Dr8,r0
+.ret0:	cmp4.ge p6,p7=3Dr8,r0
 	mov ar.pfs=3Dloc1			// restore ar.pfs
-	;;
-(p6)	mov ar.pfs=3Dr0			// clear ar.pfs in case of success
 	sxt4 r8=3Dr8			// return 64-bit result
+	;;
+	stf.spill [sp]=F0
+(p6)	cmp.ne pKern,pUser=3Dr0,r0	// a successful execve() lands us in user-=
mode...
 	mov rp=3Dloc0
+(p6)	mov ar.pfs=3Dr0			// clear ar.pfs on success
+(p7)	br.ret.sptk.few rp
=20
+	/*
+	 * In theory, we'd have to zap this state only to prevent leaking of
+	 * security sensitive state (e.g., if current->dumpable is zero).  Howeve=
r,
+	 * this executes in less than 20 cycles even on Itanium, so it's not worth
+	 * optimizing for...).
+	 */
+	mov r4=3D0;		mov f2=F0;		mov b1=3Dr0
+	mov r5=3D0;		mov f3=F0;		mov b2=3Dr0
+	mov r6=3D0;		mov f4=F0;		mov b3=3Dr0
+	mov r7=3D0;		mov f5=F0;		mov b4=3Dr0
+	mov ar.unat=3D0;		mov f10=F0;		mov b5=3Dr0
+	ldf.fill f11=3D[sp];	ldf.fill f12=3D[sp];	mov f13=F0
+	ldf.fill f14=3D[sp];	ldf.fill f15=3D[sp];	mov f16=F0
+	ldf.fill f17=3D[sp];	ldf.fill f18=3D[sp];	mov f19=F0
+	ldf.fill f20=3D[sp];	ldf.fill f21=3D[sp];	mov f22=F0
+	ldf.fill f23=3D[sp];	ldf.fill f24=3D[sp];	mov f25=F0
+	ldf.fill f26=3D[sp];	ldf.fill f27=3D[sp];	mov f28=F0
+	ldf.fill f29=3D[sp];	ldf.fill f30=3D[sp];	mov f31=F0
+	mov ar.lc=3D0
 	br.ret.sptk.few rp
 END(ia64_execve)
=20
@@ -110,8 +133,6 @@
 	br.ret.sptk.many rp
 END(sys_clone)
=20
-#define KSTACK_TR	2
-
 /*
  * prev_task <- ia64_switch_to(struct task_struct *next)
  */
@@ -122,7 +143,7 @@
 	UNW(.body)
=20
 	adds r22=3DIA64_TASK_THREAD_KSP_OFFSET,r13
-	mov r27=3Dar.k4
+	mov r27=3DIA64_KR(CURRENT_STACK)
 	dep r20=3D0,in0,61,3		// physical address of "current"
 	;;
 	st8 [r22]=3Dsp			// save kernel stack pointer of old task
@@ -142,7 +163,7 @@
 (p6)	ssm psr.ic			// if we we had to map, renable the psr.ic bit FIRST!!!
 	;;
 (p6)	srlz.d
-	mov ar.k6=3Dr20			// copy "current" into ar.k6
+	mov IA64_KR(CURRENT)=3Dr20	// update "current" application register
 	mov r8=3Dr13			// return pointer to previously running task
 	mov r13=3Din0			// set "current" pointer
 	;;
@@ -151,7 +172,7 @@
=20
 #ifdef CONFIG_SMP
 	sync.i				// ensure "fc"s done by this CPU are visible on other CPUs
-#endif=20
+#endif
 	br.ret.sptk.few rp		// boogie on out in new context
=20
 .map:
@@ -165,8 +186,8 @@
 	mov cr.itir=3Dr25
 	mov cr.ifa=3Din0			// VA of next task...
 	;;
-	mov r25=3DKSTACK_TR		// use tr entry #2...
-	mov ar.k4=3Dr26			// remember last page we mapped...
+	mov r25=3DIA64_TR_CURRENT_STACK
+	mov IA64_KR(CURRENT_STACK)=3Dr26	// remember last page we mapped...
 	;;
 	itr.d dtr[r25]=3Dr23		// wire in new mapping...
 	br.cond.sptk.many .done
@@ -211,20 +232,23 @@
 	UNW(.save @priunat,r17)
 	mov r17=3Dar.unat		// preserve caller's
 	UNW(.body)
-#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
+      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
 	adds r3=80,sp
 	;;
 	lfetch.fault.excl.nt1 [r3],128
 #endif
 	mov ar.rsc=3D0		// put RSE in mode: enforced lazy, little endian, pl 0
-#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
+      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
 	adds r2=16+128,sp
 	;;
 	lfetch.fault.excl.nt1 [r2],128
 	lfetch.fault.excl.nt1 [r3],128
 #endif
 	adds r14=3DSW(R4)+16,sp
-#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
+      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
 	;;
 	lfetch.fault.excl [r2]
 	lfetch.fault.excl [r3]
@@ -321,7 +345,9 @@
 	UNW(.prologue)
 	UNW(.altrp b7)
 	UNW(.body)
-#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
+      || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_=
SPECIFIC))
+
 	lfetch.fault.nt1 [sp]
 #endif
 	adds r2=3DSW(AR_BSPSTORE)+16,sp
@@ -427,11 +453,11 @@
 	br.ret.sptk.few rp
 END(__ia64_syscall)
=20
-	//
-	// We invoke syscall_trace through this intermediate function to
-	// ensure that the syscall input arguments are not clobbered.  We
-	// also use it to preserve b6, which contains the syscall entry point.
-	//
+	/*
+	 * We invoke syscall_trace through this intermediate function to
+	 * ensure that the syscall input arguments are not clobbered.  We
+	 * also use it to preserve b6, which contains the syscall entry point.
+	 */
 GLOBAL_ENTRY(invoke_syscall_trace)
 #ifdef CONFIG_IA64_NEW_UNWIND
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
@@ -459,19 +485,19 @@
 	mov b6=3Dloc2
 	;;
 	br.ret.sptk.few rp
-#endif /* !CONFIG_IA64_NEW_SYSCALL */
+#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(invoke_syscall_trace)
=20
-	//
-	// Invoke a system call, but do some tracing before and after the call.
-	// We MUST preserve the current register frame throughout this routine
-	// because some system calls (such as ia64_execve) directly
-	// manipulate ar.pfs.
-	//
-	// Input:
-	//	r15 =3D syscall number
-	//	b6  =3D syscall entry point
-	//
+	/*
+	 * Invoke a system call, but do some tracing before and after the call.
+	 * We MUST preserve the current register frame throughout this routine
+	 * because some system calls (such as ia64_execve) directly
+	 * manipulate ar.pfs.
+	 *
+	 * Input:
+	 *	r15 =3D syscall number
+	 *	b6  =3D syscall entry point
+	 */
 	.global ia64_strace_leave_kernel
=20
 GLOBAL_ENTRY(ia64_trace_syscall)
@@ -507,9 +533,11 @@
 GLOBAL_ENTRY(ia64_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
 #ifdef CONFIG_SMP
-	// In SMP mode, we need to call schedule_tail to complete the scheduling =
process.
-	// Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains =
the
-	// address of the previously executing task.
+	/*
+	 * In SMP mode, we need to call invoke_schedule_tail to complete the sche=
duling process.
+	 * Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains =
the
+	 * address of the previously executing task.
+	 */
 	br.call.sptk.few rp=3Dinvoke_schedule_tail
 .ret8:
 #endif
@@ -537,21 +565,9 @@
 END(ia64_ret_from_syscall)
 	// fall through
 GLOBAL_ENTRY(ia64_leave_kernel)
-	// check & deliver software interrupts:
-
 	PT_REGS_UNWIND_INFO(0)
-#ifdef CONFIG_SMP
-	adds r2=3DIA64_TASK_PROCESSOR_OFFSET,r13
-	movl r3=3Dirq_stat		// softirq_active
-	;;
-	ld4 r2=3D[r2]
-	;;
-	shl r2=3Dr2,SMP_CACHE_SHIFT	// can't use shladd here...
-	;;
-	add r3=3Dr2,r3
-#else
-	movl r3=3Dirq_stat		// softirq_active
-#endif
+#if !NEW_LEAVE_KERNEL_HEAD
+	movl r3=3DPERCPU_ADDR+IA64_CPU_SOFTIRQ_ACTIVE_OFFSET		// softirq_active
 	;;
 	ld8 r2=3D[r3]	// r3 (softirq_active+softirq_mask) is guaranteed to be 8-b=
yte aligned!
 	;;
@@ -573,7 +589,7 @@
 	  adds r14=3DIA64_TASK_SIGPENDING_OFFSET,r13
 	}
 #ifdef CONFIG_PERFMON
-	adds r15=3DIA64_TASK_PFM_NOTIFY,r13
+	adds r15=3DIA64_TASK_PFM_NOTIFY_OFFSET,r13
 #endif
 	;;
 #ifdef CONFIG_PERFMON
@@ -583,7 +599,7 @@
 	ld4 r14=3D[r14]
 	mov rp=3Dr3			// arrange for schedule() to return to back_from_resched
 	;;
-	cmp.ne p2,p0=3Dr14,r0		// NOTE: pKern is an alias for p2!!
+	cmp.ne p16,p0=3Dr14,r0
 #ifdef CONFIG_PERFMON
 	cmp.ne p6,p0=3Dr15,r0		// current->task.pfm_notify !=3D 0?
 #endif
@@ -592,32 +608,56 @@
 (p6)	br.call.spnt.many b6=3Dpfm_overflow_notify
 #endif
 (p7)	br.call.spnt.many b7=3Dinvoke_schedule
-(p2)	br.call.spnt.many rp=3Dhandle_signal_delivery	// check & deliver pend=
ing signals
+(p16)	br.call.spnt.many rp=3Dhandle_signal_delivery	// check & deliver pen=
ding signals
 .ret9:
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-	// Check for lost ticks
-	rsm psr.i
-	mov r2 =3D ar.itc
-	movl r14 =3D 1000			// latency tolerance
-	mov r3 =3D cr.itm
-	;;
-	sub r2 =3D r2, r3
-	;;
-	sub r2 =3D r2, r14
-	;;
-	cmp.ge p6,p7 =3D r2, r0
-(p6)	br.call.spnt.few rp=3Dinvoke_ia64_reset_itm
-.ret10:
+restore_all:
+	adds r2=3DPT(R8)+16,r12
+	adds r3=3DPT(R9)+16,r12
 	;;
-	ssm psr.i
+#else /* NEW_LEAVE_KERNEL_HEAD */
+	cmp.eq p16,p0=3Dr0,r0			// set the "first_time" flag
+	movl r15=3DPERCPU_ADDR+IA64_CPU_SOFTIRQ_ACTIVE_OFFSET  // r15 =3D &cpu_da=
ta.softirq.active
+	;;
+	ld8 r2=3D[r15]
+	movl r14=3D.restart
+	;;
+	lfetch.fault [sp]
+	shr.u r3=3Dr2,32			// r3 =3D cpu_data.softirq.mask
+	MOVBR(.ret.sptk,rp,r14,.restart)
+.restart:
+	adds r17=3DIA64_TASK_NEED_RESCHED_OFFSET,r13
+	adds r18=3DIA64_TASK_SIGPENDING_OFFSET,r13
+#ifdef CONFIG_PERFMON
+	adds r19=3DIA64_TASK_PFM_NOTIFY_OFFSET,r13
 #endif
-restore_all:
-
-	// start restoring the state saved on the kernel stack (struct pt_regs):
-
+	;;
+	ld8 r17=3D[r17]				// load current->need_resched
+	ld4 r18=3D[r18]				// load current->sigpending
+(p16)	and r2=3Dr2,r3				// r2 <- (softirq.active & softirq.mask)
+	;;
+#ifdef CONFIG_PERFMON
+	ld8 r19=3D[r19]				// load current->task.pfm_notify
+#endif
+(p16)	cmp4.ne.unc p6,p0=3Dr2,r0			// p6 <- (softirq.active & softirq.mask)=
 !=3D 0
+(pUser)	cmp.ne.unc p7,p0=3Dr17,r0			// current->need_resched !=3D 0?
+	;;
+(pUser)	cmp.ne.unc p8,p0=3Dr18,r0			// current->sigpending !=3D 0?
+#ifdef CONFIG_PERFMON
+	cmp.ne p9,p0=3Dr19,r0			// current->task.pfm_notify !=3D 0?
+#endif
+	cmp.ne p16,p0=3Dr0,r0			// clear the "first_time" flag
+	;;
+(p6)	br.call.spnt.many b7=3Dinvoke_do_softirq
+#ifdef CONFIG_PERFMON
+(p9)	br.call.spnt.many b7=3Dpfm_overflow_notify
+#endif
+(p7)	br.call.spnt.many b7=3Dinvoke_schedule
 	adds r2=3DPT(R8)+16,r12
 	adds r3=3DPT(R9)+16,r12
+(p8)	br.call.spnt.many b7=3Dhandle_signal_delivery	// check & deliver pend=
ing signals
 	;;
+#endif /* NEW_LEAVE_KERNEL_HEAD */
+	// start restoring the state saved on the kernel stack (struct pt_regs):
 	ld8.fill r8=3D[r2],16
 	ld8.fill r9=3D[r3],16
 	;;
@@ -648,6 +688,9 @@
 	ld8.fill r30=3D[r2],16
 	ld8.fill r31=3D[r3],16
 	;;
+	rsm psr.i | psr.ic	// initiate turning off of interrupts & interruption c=
ollection
+	invala			// invalidate ALAT
+	;;
 	ld8 r1=3D[r2],16		// ar.ccv
 	ld8 r13=3D[r3],16		// ar.fpsr
 	;;
@@ -663,14 +706,11 @@
 	mov ar.ccv=3Dr1
 	mov ar.fpsr=3Dr13
 	mov b0=3Dr14
-	// turn off interrupts, interrupt collection
-	rsm psr.i | psr.ic
 	;;
-	srlz.i			// EAS 2.5
+	srlz.i			// ensure interrupts & interruption collection are off
 	mov b7=3Dr15
 	;;
-	invala			// invalidate ALAT
-	bsw.0;;			// switch back to bank 0 (must be last in insn group)
+	bsw.0			// switch back to bank 0
 	;;
 #ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
 	nop.i 0x0
@@ -699,26 +739,26 @@
 	ld8 rARPR=3D[r16],16	// load predicates
 	ld8 rB6=3D[r17],16	// load b6
 	;;
-	ld8 r18=3D[r16],16	// load ar.rsc value for "loadrs"
+	ld8 r19=3D[r16],16	// load ar.rsc value for "loadrs"
 	ld8.fill r1=3D[r17],16	// load r1
 	;;
 	ld8.fill r2=3D[r16],16
 	ld8.fill r3=3D[r17],16
-	extr.u r19=3DrCRIPSR,32,2	// extract ps.cpl
 	;;
 	ld8.fill r12=3D[r16],16
 	ld8.fill r13=3D[r17],16
-(pSys)	shr.u r18=3Dr18,16	// get size of existing "dirty" partition
 	;;
 	ld8.fill r14=3D[r16]
 	ld8.fill r15=3D[r17]
-	cmp.eq p6,p7=3Dr0,r19	// are we returning to kernel mode? (psr.cpl=3D0)
+	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
 	;;
-	mov r16=3Dar.bsp			// get existing backing store pointer
-	mov b6=3DrB6
-	mov ar.pfs=3DrARPFS
-(p6)	br.cond.dpnt.few skip_rbs_switch
-
+	mov r16=3Dar.bsp		// get existing backing store pointer
+#if CLEAR_INVALID
+	movl r17=3DPERCPU_ADDR+IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET
+	;;
+	ld4 r17=3D[r17]		// r17 =3D cpu_data->phys_stacked_size_p8
+#endif
+(pKern)	br.cond.dpnt.few skip_rbs_switch
 	/*
 	 * Restore user backing store.
 	 *
@@ -727,31 +767,88 @@
 (pNonSys) br.cond.dpnt.few dont_preserve_current_frame
 	cover				// add current frame into dirty partition
 	;;
-	mov r17=3Dar.bsp			// get new backing store pointer
-	sub r18=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
+	mov r19=3Dar.bsp			// get new backing store pointer
+	sub r16=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
 	cmp.ne p9,p0=3Dr0,r0		// clear p9 to skip restore of cr.ifs
 	;;
-	sub r18=3Dr17,r18			// calculate number of bytes that were added to rbs
+	sub r19=3Dr19,r16			// calculate total byte size of dirty partition
+	add r18d,r18			// don't force in0-in7 into memory...
 	;;
-	shl r18=3Dr18,16			// shift size of dirty partition into loadrs position
+	shl r19=3Dr19,16			// shift size of dirty partition into loadrs position
 	;;
 dont_preserve_current_frame:
-	alloc r17=3Dar.pfs,0,0,0,0	// drop the current call frame (noop for sysca=
lls)
-	mov ar.rsc=3Dr18			// load ar.rsc to be used for "loadrs"
- 	;;
+#if CLEAR_INVALID
+	/*
+	 * To prevent leaking bits between the kernel and user-space,
+	 * we must clear the stacked registers in the "invalid" partition here.
+	 * Not pretty, but at least it's fast (3.34 registers/cycle).
+	 * Architecturally, this loop could go at 4.67 registers/cycle, but that =
would
+	 * oversubscribe Itanium.
+	 */
+#	define pRecurse	p6
+#	define pReturn	p7
+#	define Nregs	10
+	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+	shr.u loc1=3Dr18,9		// RNaTslots <=3D dirtySize / (64*8) + 1
+	sub r17=3Dr17,r18			// r17 =3D (physStackedSize + 8) - dirtySize
+	;;
+	mov ar.rsc=3Dr19			// load ar.rsc to be used for "loadrs"
+	shladd in0=3Dloc1,3,r17
+	mov in1=3D0
+	;;
+	.align 32
+rse_clear_invalid:
+	// cycle 0
+ { .mii
+	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs regs left to clear=
, (re)curse
+	add out0=3D-Nregs*8,in0
+}{ .mfb
+	add out1=3D1,in1			// increment recursion count
+	nop.f 0
+	nop.b 0				// can't do br.call here because of alloc (WAW on CFM)
+	;;
+}{ .mfi	// cycle 1
+	mov loc1=3D0
+	nop.f 0
+	mov loc2=3D0
+}{ .mib
+	mov loc3=3D0
+	mov loc4=3D0
+(pRecurse) br.call.sptk.few b6=3Drse_clear_invalid
+
+}{ .mfi	// cycle 2
+	mov loc5=3D0
+	nop.f 0
+	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need to do a =
br.ret
+}{ .mib
+	mov loc6=3D0
+	mov loc7=3D0
+(pReturn) br.ret.sptk.few b6
+}
+#	undef pRecurse
+#	undef pReturn
+#else
+	mov ar.rsc=3Dr19			// load ar.rsc to be used for "loadrs"
+#endif
+
+	alloc r17=3Dar.pfs,0,0,0,0	// drop current register frame
+	;;
 	loadrs
 	;;
 skip_rbs_switch:
-(p7)	mov ar.bspstore=3DrARBSPSTORE
+	mov b6=3DrB6
+	mov ar.pfs=3DrARPFS
+(pUser)	mov ar.bspstore=3DrARBSPSTORE
 (p9)	mov cr.ifs=3DrCRIFS
 	mov cr.ipsr=3DrCRIPSR
 	mov cr.iip=3DrCRIIP
 	;;
-(p7)	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
+(pUser)	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
 	mov ar.rsc=3DrARRSC
 	mov ar.unat=3DrARUNAT
 	mov pr=3DrARPR,-1
-	rfi;;			// must be last instruction in an insn group
+	rfi
 END(ia64_leave_kernel)
=20
 ENTRY(handle_syscall_error)
@@ -782,7 +879,12 @@
 #ifdef CONFIG_SMP
 	/*
 	 * Invoke schedule_tail(task) while preserving in0-in7, which may be need=
ed
-	 * in case a system call gets restarted.
+	 * in case a system call gets restarted.  Note that declaring schedule_ta=
il()
+	 * with asmlinkage() is NOT enough because that will only preserve as many
+	 * registers as there are formal arguments.
+	 *
+	 * XXX fix me: with gcc 3.0, we won't need this anymore because syscall_l=
inkage
+	 *	renders all eight input registers (in0-in7) as "untouchable".
 	 */
 ENTRY(invoke_schedule_tail)
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
@@ -798,26 +900,14 @@
=20
 #endif /* CONFIG_SMP */
=20
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-
-ENTRY(invoke_ia64_reset_itm)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
-	alloc loc1=3Dar.pfs,8,2,0,0
-	mov loc0=3Drp
-	;;
-	UNW(.body)
-	br.call.sptk.many rp=3Dia64_reset_itm
-.ret12:	;;
-	mov ar.pfs=3Dloc1
-	mov rp=3Dloc0
-	br.ret.sptk.many rp
-END(invoke_ia64_reset_itm)
-
-#endif /* CONFIG_IA64_SOFTSDV_HACKS */
-
 	/*
 	 * Invoke do_softirq() while preserving in0-in7, which may be needed
-	 * in case a system call gets restarted.
+	 * in case a system call gets restarted.  Note that declaring do_softirq()
+	 * with asmlinkage() is NOT enough because that will only preserve as many
+	 * registers as there are formal arguments.
+	 *
+	 * XXX fix me: with gcc 3.0, we won't need this anymore because syscall_l=
inkage
+	 *	renders all eight input registers (in0-in7) as "untouchable".
 	 */
 ENTRY(invoke_do_softirq)
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
@@ -833,7 +923,12 @@
=20
 	/*
 	 * Invoke schedule() while preserving in0-in7, which may be needed
-	 * in case a system call gets restarted.
+	 * in case a system call gets restarted.  Note that declaring schedule()
+	 * with asmlinkage() is NOT enough because that will only preserve as many
+	 * registers as there are formal arguments.
+	 *
+	 * XXX fix me: with gcc 3.0, we won't need this anymore because syscall_l=
inkage
+	 *	renders all eight input registers (in0-in7) as "untouchable".
 	 */
 ENTRY(invoke_schedule)
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
@@ -847,11 +942,11 @@
 	br.ret.sptk.many rp
 END(invoke_schedule)
=20
-	//
-	// Setup stack and call ia64_do_signal.  Note that pSys and pNonSys need =
to
-	// be set up by the caller.  We declare 8 input registers so the system c=
all
-	// args get preserved, in case we need to restart a system call.
-	//
+	/*
+	 * Setup stack and call ia64_do_signal.  Note that pSys and pNonSys need =
to
+	 * be set up by the caller.  We declare 8 input registers so the system c=
all
+	 * args get preserved, in case we need to restart a system call.
+	 */
 ENTRY(handle_signal_delivery)
 #ifdef CONFIG_IA64_NEW_UNWIND
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
@@ -985,10 +1080,10 @@
=20
 GLOBAL_ENTRY(ia64_prepare_handle_unaligned)
 	//
-	// r16 =3D fake ar.pfs, we simply need to make sure=20
+	// r16 =3D fake ar.pfs, we simply need to make sure
 	// privilege is still 0
 	//
-	mov r16=3Dr0 			=09
+	mov r16=3Dr0
 	UNW(.prologue)
 	DO_SAVE_SWITCH_STACK
 	br.call.sptk.few rp=3Dia64_handle_unaligned // stack frame setup in ivt
@@ -1223,7 +1318,7 @@
 	data8 sys_accept
 	data8 sys_getsockname			// 1195
 	data8 sys_getpeername
-	data8 sys_socketpair=20
+	data8 sys_socketpair
 	data8 sys_send
 	data8 sys_sendto
 	data8 sys_recv				// 1200
diff -urN linux-davidm/arch/ia64/kernel/entry.h linux-2.4.1-lia/arch/ia64/k=
ernel/entry.h
--- linux-davidm/arch/ia64/kernel/entry.h	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/entry.h	Wed Feb 21 16:43:48 2001
@@ -1,7 +1,7 @@
 #include <linux/config.h>
=20
 /* XXX fixme */
-#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC)
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SP=
ECIFIC)
 # define MOVBR(type,br,gr,lbl)	mov br=3Dgr
 #else
 # define MOVBR(type,br,gr,lbl)	mov##type br=3Dgr,lbl
@@ -12,6 +12,7 @@
  * careful not to step on these!
  */
 #define pKern		p2	/* will leave_kernel return to kernel-mode? */
+#define pUser		p3	/* will leave_kernel return to user-mode? */
 #define pSys		p4	/* are we processing a (synchronous) system call? */
 #define pNonSys		p5	/* complement of pSys */
=20
diff -urN linux-davidm/arch/ia64/kernel/fw-emu.c linux-2.4.1-lia/arch/ia64/=
kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/fw-emu.c	Wed Feb 21 16:07:58 2001
@@ -1,8 +1,8 @@
 /*
  * PAL & SAL emulation.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * For the HP simulator, this file gets include in boot/bootloader.c.
  * For SoftSDV, this file gets included in sys_softsdv.c.
@@ -151,6 +151,14 @@
 	movl r10=3D0x100000100		/* bus_ratio<<32 (1/256) */
 	movl r11=3D0x100000064		/* itc_ratio<<32 (1/100) */
 	;;
+1:	cmp.eq p6,p7=19,r28		/* PAL_RSE_INFO */
+(p7)	br.cond.sptk.few 1f
+	mov r8=3D0			/* status =3D 0 */
+	mov r9=96			/* num phys stacked */
+	mov r10=3D0			/* hints */
+	mov r11=3D0
+	br.cond.sptk.few rp
+
 1:	cmp.eq p6,p7=3D1,r28		/* PAL_CACHE_FLUSH */
 (p7)	br.cond.sptk.few 1f
 	mov r9=3Dar.lc
@@ -168,8 +176,7 @@
 	;;
 	mov ar.lc=3Dr9
 	mov r8=3Dr0
-1:
-	br.cond.sptk.few rp
+1:	br.cond.sptk.few rp
=20
 stacked:
 	br.ret.sptk.few rp
@@ -249,13 +256,7 @@
 			 * or something platform specific?  The SAL
 			 * doc ain't exactly clear on this...
 			 */
-#if defined(CONFIG_IA64_SOFTSDV_HACKS)
-			r9 =3D   4000000;
-#elif defined(CONFIG_IA64_SDV)
-			r9 =3D 300000000;
-#else
 			r9 =3D 700000000;
-#endif
 			break;
=20
 		      case SAL_FREQ_BASE_REALTIME_CLOCK:
@@ -445,10 +446,10 @@
=20
 	/* descriptor for firmware emulator: */
 	md =3D &efi_memmap[1];
-	md->type =3D EFI_RUNTIME_SERVICES_DATA;
+	md->type =3D EFI_PAL_CODE;
 	md->pad =3D 0;
 	md->phys_addr =3D 1*MB;
-	md->virt_addr =3D 0;
+	md->virt_addr =3D 1*MB;
 	md->num_pages =3D (1*MB) >> 12;	/* 1MB (in 4KB pages) */
 	md->attribute =3D EFI_MEMORY_WB;
=20
diff -urN linux-davidm/arch/ia64/kernel/gate.S linux-2.4.1-lia/arch/ia64/ke=
rnel/gate.S
--- linux-davidm/arch/ia64/kernel/gate.S	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/gate.S	Wed Feb 21 16:08:10 2001
@@ -1,10 +1,9 @@
 /*
- * This file contains the code that gets mapped at the upper end of
- * each task's text region.  For now, it contains the signal
- * trampoline code only.
+ * This file contains the code that gets mapped at the upper end of each t=
ask's text
+ * region.  For now, it contains the signal trampoline code only.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <asm/asmmacro.h>
@@ -18,7 +17,7 @@
 	.psr lsb
 	.lsb
=20
-	.section __gate_section,"ax"
+	.section .text.gate,"ax"
=20
 	.align PAGE_SIZE
=20
@@ -51,28 +50,24 @@
 	 *   |            space              |
 	 *   +-------------------------------+ <-- sp
 	 *
-	 * The register stack looks _exactly_ the way it looked at the
-	 * time the signal occurred.  In other words, we're treading
-	 * on a potential mine-field: each incoming general register
-	 * may be a NaT value (includeing sp, in which case the process
-	 * ends up dying with a SIGSEGV).
+	 * The register stack looks _exactly_ the way it looked at the time the s=
ignal
+	 * occurred.  In other words, we're treading on a potential mine-field: e=
ach
+	 * incoming general register may be a NaT value (including sp, in which c=
ase the
+	 * process ends up dying with a SIGSEGV).
 	 *
-	 * The first need to do is a cover to get the registers onto
-	 * the backing store.  Once that is done, we invoke the signal
-	 * handler which may modify some of the machine state.  After
-	 * returning from the signal handler, we return control to the
-	 * previous context by executing a sigreturn system call.  A
-	 * signal handler may call the rt_sigreturn() function to
-	 * directly return to a given sigcontext.  However, the
-	 * user-level sigreturn() needs to do much more than calling
-	 * the rt_sigreturn() system call as it needs to unwind the
-	 * stack to restore preserved registers that may have been
-	 * saved on the signal handler's call stack.
+	 * The first need to do is a cover to get the registers onto the backing =
store.
+	 * Once that is done, we invoke the signal handler which may modify some =
of the
+	 * machine state.  After returning from the signal handler, we return con=
trol to
+	 * the previous context by executing a sigreturn system call.  A signal h=
andler
+	 * may call the rt_sigreturn() function to directly return to a given sig=
context.
+	 * However, the user-level sigreturn() needs to do much more than calling=
 the
+	 * rt_sigreturn() system call as it needs to unwind the stack to restore =
preserved
+	 * registers that may have been saved on the signal handler's call stack.
 	 *
 	 * On entry:
 	 *	r2	=3D signal number
 	 *	r3	=3D plabel of signal handler
-	 *	r15	=3D new register backing store (ignored)
+	 *	r15	=3D new register backing store
 	 *	[sp+16] =3D sigframe
 	 */
=20
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.1-lia/arch/ia64/ke=
rnel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/head.S	Wed Feb 21 16:08:24 2001
@@ -19,6 +19,7 @@
 #include <asm/asmmacro.h>
 #include <asm/fpu.h>
 #include <asm/pal.h>
+#include <asm/pgtable.h>
 #include <asm/offsets.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
@@ -85,11 +86,13 @@
=20
 #define isAP	p2	// are we booting an Application Processor (not the BSP)?
=20
-	// Find the init_task for the currently booting CPU.  At poweron, and in
-	// UP mode, cpu_now_booting is 0
+	/*
+	 * Find the init_task for the currently booting CPU.  At poweron, and in
+	 * UP mode, cpu_now_booting is 0.
+	 */
 	movl r3=3Dcpu_now_booting
  	;;
-	ld4 r3=3D[r3]
+	ld4 r3=3D[r3]		// r3 <- smp_processor_id()
 	movl r2=3Dinit_tasks
 	;;=20
 	shladd r2=3Dr3,3,r2
@@ -103,7 +106,6 @@
 	// load the "current" pointer (r13) and ar.k6 with the current task=20
 	mov r13=3Dr2
 	mov ar.k6=3Dr3		// Physical address
-	;;
 	/*
 	 * Reserve space at the top of the stack for "struct pt_regs".  Kernel th=
reads
 	 * don't store interesting values in that structure, but the space still =
needs
@@ -117,11 +119,8 @@
 	;;
 	mov ar.bspstore=3Dr2	// establish the new RSE stack
 	;;
-	loadrs			// load zero bytes from the register stack
-	;;
 	mov ar.rsc=3D0x3		// place RSE in eager mode
 	;;
-
 #ifdef CONFIG_IA64_EARLY_PRINTK
 	.rodata
 alive_msg:
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.1-lia/arch/i=
a64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/ia64_ksyms.c	Wed Feb 21 16:08:37 2001
@@ -74,6 +74,8 @@
=20
 #include <asm/smp.h>
 EXPORT_SYMBOL(smp_call_function);
+EXPORT_SYMBOL(smp_call_function_single);
+EXPORT_SYMBOL(cpu_online_map);
=20
 #include <linux/smp.h>
 EXPORT_SYMBOL(smp_num_cpus);
@@ -120,3 +122,10 @@
=20
 extern unsigned long ia64_iobase;
 EXPORT_SYMBOL(ia64_iobase);
+
+#include <asm/pal.h>
+EXPORT_SYMBOL(ia64_pal_call_phys_stacked);
+EXPORT_SYMBOL(ia64_pal_call_phys_static);
+EXPORT_SYMBOL(ia64_pal_call_stacked);
+EXPORT_SYMBOL(ia64_pal_call_static);
+
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c linux-2.4.1-lia/arch/ia64=
/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/iosapic.c	Wed Feb 21 16:08:47 2001
@@ -392,7 +392,6 @@
 			set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
 		}
=20
-#ifndef CONFIG_IA64_SOFTSDV_HACKS
 	for (i =3D 0; i < pci_irq.num_routes; i++) {
 		irq =3D pci_irq.route[i].irq;
=20
@@ -433,7 +432,6 @@
 		/* program the IOSAPIC routing table: */
 		set_rte(vector, (ia64_get_lid() >> 16) & 0xffff);
 	}
-#endif /* !CONFIG_IA64_SOFTSDV_HACKS */
 }
=20
 void
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.1-lia/arch/ia64/ker=
nel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/ivt.S	Wed Feb 21 16:11:46 2001
@@ -1,9 +1,9 @@
 /*
  * arch/ia64/kernel/ivt.S
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
  * Copyright (C) 1998, 1999 Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 1998-2000 David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 David Mosberger <davidm@hpl.hp.com>
  *
  * 00/08/23 Asit Mallick <asit.k.mallick@intel.com> TLB handling for SMP
  * 00/12/20 David Mosberger-Tang <davidm@hpl.hp.com> DTLB/ITLB handler now=
 uses virtual PT.
@@ -14,7 +14,7 @@
  *
  * External interrupts only use 1 entry. All others are internal interrupts
  *
- * The first 20 entries of the table contain 64 bundles each while the=20
+ * The first 20 entries of the table contain 64 bundles each while the
  * remaining 48 entries contain only 16 bundles each.
  *
  * The 64 bundles are used to allow inlining the whole handler for critical
@@ -22,7 +22,7 @@
  *
  *  For each entry, the comment is as follows:
  *
- * 		// 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
+ *		// 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
  *  entry offset ----/     /         /                  /          /
  *  entry number ---------/         /                  /          /
  *  size of the entry -------------/                  /          /
@@ -37,7 +37,9 @@
=20
 #include <linux/config.h>
=20
+#include <asm/asmmacro.h>
 #include <asm/break.h>
+#include <asm/kregs.h>
 #include <asm/offsets.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
@@ -63,8 +65,8 @@
  * As we don't (hopefully) use the space available, we need to fill it with
  * nops. the parameter may be used for debugging and is representing the e=
ntry
  * number
- */=20
-#define BREAK_BUNDLE(a) 	break.m (a); \
+ */
+#define BREAK_BUNDLE(a)	break.m (a); \
 				break.i (a); \
 				break.i (a)
 /*
@@ -81,13 +83,14 @@
 	.psr lsb
 	.lsb
=20
-	.section __ivt_section,"ax"
+	.section .text.ivt,"ax"
=20
 	.align 32768	// align on 32KB boundary
 	.global ia64_ivt
 ia64_ivt:
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0000 Entry 0 (size 64 bundles) VHPT Translation (8,20,47)
+ENTRY(vhpt_miss)
 	/*
 	 * The VHPT vector is invoked when the TLB entry for the virtual page tab=
le
 	 * is missing.  This happens only as a result of a previous
@@ -109,7 +112,7 @@
 	;;
 	rsm psr.dt				// use physical addressing for data
 	mov r31=3Dpr				// save the predicate registers
-	mov r19=3Dar.k7				// get page table base address
+	mov r19=3DIA64_KR(PT_BASE)		// get page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
 	shr.u r17=3Dr16,61			// get the region number into r17
 	;;
@@ -152,19 +155,21 @@
 (p6)	br.spnt.many page_fault			// handle bad address/page not present (pag=
e fault)
 	mov cr.ifa=3Dr22
=20
-	// Now compute and insert the TLB entry for the virtual page table.
-	// We never execute in a page table page so there is no need to set
-	// the exception deferral bit.
+	/*
+	 * Now compute and insert the TLB entry for the virtual page table.  We n=
ever
+	 * execute in a page table page so there is no need to set the exception =
deferral
+	 * bit.
+	 */
 	adds r24=3D__DIRTY_BITS_NO_ED|_PAGE_PL_0|_PAGE_AR_RW,r23
 	;;
 (p7)	itc.d r24
 	;;
 #ifdef CONFIG_SMP
-	//
-	// Re-check L2 and L3 pagetable.  If they changed, we may have received
-	// a ptc.g between reading the pagetable and the "itc".  If so,
-	// flush the entry we inserted and retry.
-	//
+	/*
+	 * Re-check L2 and L3 pagetable.  If they changed, we may have received a=
 ptc.g
+	 * between reading the pagetable and the "itc".  If so, flush the entry we
+	 * inserted and retry.
+	 */
 	ld8 r25=3D[r21]				// read L3 PTE again
 	ld8 r26=3D[r17]				// read L2 entry again
 	;;
@@ -179,11 +184,12 @@
=20
 	mov pr=3Dr31,-1				// restore predicate registers
 	rfi
-	;;
+END(vhpt_miss)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0400 Entry 1 (size 64 bundles) ITLB (21)
+ENTRY(itlb_miss)
 	/*
 	 * The ITLB handler accesses the L3 PTE via the virtually mapped linear
 	 * page table.  If a nested TLB miss occurs, we switch into physical
@@ -215,11 +221,12 @@
 #endif
 	mov pr=3Dr31,-1
 	rfi
-	;;
+END(itlb_miss)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0800 Entry 2 (size 64 bundles) DTLB (9,48)
+ENTRY(dtlb_miss)
 	/*
 	 * The DTLB handler accesses the L3 PTE via the virtually mapped linear
 	 * page table.  If a nested TLB miss occurs, we switch into physical
@@ -251,20 +258,21 @@
 #endif
 	mov pr=3Dr31,-1
 	rfi
-	;;
+END(dtlb_miss)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x0c00 Entry 3 (size 64 bundles) Alt ITLB (19)
+ENTRY(alt_itlb_miss)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
-	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX
+	movl r17=3DPAGE_KERNEL
 	mov r21=3Dcr.ipsr
 	mov r31=3Dpr
 	;;
 #ifdef CONFIG_DISABLE_VHPT
 	shr.u r22=3Dr16,61			// get the region number into r21
 	;;
-	cmp.gt p8,p0=3D6,r22			// user mode=20
+	cmp.gt p8,p0=3D6,r22			// user mode
 	;;
 (p8)	thash r17=3Dr16
 	;;
@@ -286,13 +294,14 @@
 	itc.i r19		// insert the TLB entry
 	mov pr=3Dr31,-1
 	rfi
-	;;
+END(alt_itlb_miss)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
+ENTRY(alt_dtlb_miss)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
-	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX
+	movl r17=3DPAGE_KERNEL
 	mov r20=3Dcr.isr
 	mov r21=3Dcr.ipsr
 	mov r31=3Dpr
@@ -326,24 +335,19 @@
 (p7)	itc.d r19		// insert the TLB entry
 	mov pr=3Dr31,-1
 	rfi
-	;;
+END(alt_dtlb_miss)
=20
 	//-----------------------------------------------------------------------=
------------
 	// call do_page_fault (predicates are in r31, psr.dt may be off, r16 is f=
aulting address)
-page_fault:
+ENTRY(page_fault)
 	ssm psr.dt
 	;;
 	srlz.i
 	;;
 	SAVE_MIN_WITH_COVER
-	//
-	// Copy control registers to temporary registers, then turn on psr bits,
-	// then copy the temporary regs to the output regs.  We have to do this
-	// because the "alloc" can cause a mandatory store which could lead to
-	// an "Alt DTLB" fault which we can handle only if psr.ic is on.
-	//
-	mov r8=3Dcr.ifa
-	mov r9=3Dcr.isr
+	alloc r15=3Dar.pfs,0,0,3,0
+	mov out0=3Dcr.ifa
+	mov out1=3Dcr.isr
 	adds r3=3D8,r2				// set up second base pointer
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
@@ -353,43 +357,41 @@
 (p15)	ssm psr.i				// restore psr.i
 	movl r14=3Dia64_leave_kernel
 	;;
-	alloc r15=3Dar.pfs,0,0,3,0		// must be first in insn group
-	mov out0=3Dr8
-	mov out1=3Dr9
-	;;
 	SAVE_REST
 	mov rp=3Dr14
 	;;
 	adds out2=16,r12			// out2 =3D pointer to pt_regs
 	br.call.sptk.many b6=3Dia64_do_page_fault	// ignore return address
-	;;
+END(page_fault)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1400 Entry 5 (size 64 bundles) Data nested TLB (6,45)
-	//
-	// In the absence of kernel bugs, we get here when the virtually mapped l=
inear page
-	// table is accessed non-speculatively (e.g.,  in the Dirty-bit, Instruct=
ion
-	// Access-bit, or Data Access-bit faults).  If the DTLB entry for the vir=
tual page
-	// table is missing, a nested TLB miss fault is triggered and control is =
transferred
-	// to this point.  When this happens, we lookup the pte for the faulting =
address
-	// by walking the page table in physical mode and return to the continuat=
ion point
-	// passed in register r30 (or call page_fault if the address is not mappe=
d).
-	//
-	// Input:	r16:	faulting address
-	//		r29:	saved b0
-	//		r30:	continuation address
-	//		r31:	saved pr
-	//
-	// Output:	r17:	physical address of L3 PTE of faulting address
-	//		r29:	saved b0
-	//		r30:	continuation address
-	//		r31:	saved pr
-	//
-	// Clobbered:	b0, r18, r19, r21, psr.dt (cleared)
-	//
+ENTRY(nested_dtlb_miss)
+	/*
+	 * In the absence of kernel bugs, we get here when the virtually mapped l=
inear
+	 * page table is accessed non-speculatively (e.g., in the Dirty-bit, Inst=
ruction
+	 * Access-bit, or Data Access-bit faults).  If the DTLB entry for the vir=
tual page
+	 * table is missing, a nested TLB miss fault is triggered and control is
+	 * transferred to this point.  When this happens, we lookup the pte for t=
he
+	 * faulting address by walking the page table in physical mode and return=
 to the
+	 * continuation point passed in register r30 (or call page_fault if the a=
ddress is
+	 * not mapped).
+	 *
+	 * Input:	r16:	faulting address
+	 *		r29:	saved b0
+	 *		r30:	continuation address
+	 *		r31:	saved pr
+	 *
+	 * Output:	r17:	physical address of L3 PTE of faulting address
+	 *		r29:	saved b0
+	 *		r30:	continuation address
+	 *		r31:	saved pr
+	 *
+	 * Clobbered:	b0, r18, r19, r21, psr.dt (cleared)
+	 */
 	rsm psr.dt				// switch to using physical data addressing
-	mov r19=3Dar.k7				// get the page table base address
+	mov r19=3DIA64_KR(PT_BASE)		// get the page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
 	;;
 	shr.u r17=3Dr16,61			// get the region number into r17
@@ -421,31 +423,35 @@
 (p6)	br.cond.spnt.many page_fault
 	mov b0=3Dr30
 	br.sptk.many b0				// return to continuation point
-	;;
+END(nested_dtlb_miss)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1800 Entry 6 (size 64 bundles) Instruction Key Miss (24)
+ENTRY(ikey_miss)
 	FAULT(6)
+END(ikey_miss)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x1c00 Entry 7 (size 64 bundles) Data Key Miss (12,51)
+ENTRY(dkey_miss)
 	FAULT(7)
+END(dkey_miss)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2000 Entry 8 (size 64 bundles) Dirty-bit (54)
-	//
-	// What we do here is to simply turn on the dirty bit in the PTE.  We need
-	// to update both the page-table and the TLB entry.  To efficiently access
-	// the PTE, we address it through the virtual page table.  Most likely, t=
he
-	// TLB entry for the relevant virtual page table page is still present in
-	// the TLB so we can normally do this without additional TLB misses.
-	// In case the necessary virtual page table TLB entry isn't present, we t=
ake
-	// a nested TLB miss hit where we look up the physical address of the L3 =
PTE
-	// and then continue at label 1 below.
-	//
+ENTRY(dirty_bit)
+	/*
+	 * What we do here is to simply turn on the dirty bit in the PTE.  We nee=
d to
+	 * update both the page-table and the TLB entry.  To efficiently access t=
he PTE,
+	 * we address it through the virtual page table.  Most likely, the TLB en=
try for
+	 * the relevant virtual page table page is still present in the TLB so we=
 can
+	 * normally do this without additional TLB misses.  In case the necessary=
 virtual
+	 * page table TLB entry isn't present, we take a nested TLB miss hit wher=
e we look
+	 * up the physical address of the L3 PTE and then continue at label 1 bel=
ow.
+	 */
 	mov r16=3Dcr.ifa				// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
 	;;
@@ -486,11 +492,12 @@
 #endif
 	mov pr=3Dr31,-1				// restore pr
 	rfi
-	;;
+END(idirty_bit)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2400 Entry 9 (size 64 bundles) Instruction Access-bit (27)
+ENTRY(iaccess_bit)
 	// Like Entry 8, except for instruction access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
@@ -516,11 +523,11 @@
 	;;
 # if defined(CONFIG_IA32_SUPPORT) && \
     (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC))
-	//
-	// Erratum 85 (Access bit fault could be reported before page not present=
 fault)
-	//   If the PTE is indicates the page is not present, then just turn this=
 into a
-	//   page fault.
-	//
+	/*
+	 * Erratum 85 (Access bit fault could be reported before page not present=
 fault)
+	 *   If the PTE is indicates the page is not present, then just turn this=
 into a
+	 *   page fault.
+	 */
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.sptk page_fault			// page wasn't present
 # endif
@@ -547,11 +554,11 @@
 	;;
 # if defined(CONFIG_IA32_SUPPORT) && \
     (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC))
-	//
-	// Erratum 85 (Access bit fault could be reported before page not present=
 fault)
-	//   If the PTE is indicates the page is not present, then just turn this=
 into a
-	//   page fault.
-	//
+	/*
+	 * Erratum 85 (Access bit fault could be reported before page not present=
 fault)
+	 *   If the PTE is indicates the page is not present, then just turn this=
 into a
+	 *   page fault.
+	 */
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.sptk page_fault			// page wasn't present
 # endif
@@ -563,11 +570,12 @@
 #endif /* !CONFIG_SMP */
 	mov pr=3Dr31,-1
 	rfi
-	;;
+END(iaccess_bit)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2800 Entry 10 (size 64 bundles) Data Access-bit (15,55)
+ENTRY(daccess_bit)
 	// Like Entry 8, except for data access
 	mov r16=3Dcr.ifa				// get the address that caused the fault
 	movl r30=1F				// load continuation point in case of nested fault
@@ -608,11 +616,12 @@
 	mov b0=3Dr29				// restore b0
 	mov pr=3Dr31,-1
 	rfi
-	;;
+END(daccess_bit)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x2c00 Entry 11 (size 64 bundles) Break instruction (33)
+ENTRY(break_fault)
 	mov r16=3Dcr.iim
 	mov r17=3D__IA64_BREAK_SYSCALL
 	mov r31=3Dpr		// prepare to save predicates
@@ -675,12 +684,12 @@
 	;;
 	st8 [r16]=3Dr18				// store new value for cr.isr
=20
-(p8)	br.call.sptk.many b6=B6			// ignore this return addr=20
+(p8)	br.call.sptk.many b6=B6			// ignore this return addr
 	br.call.sptk.many rp=3Dia64_trace_syscall	// rp will be overwritten (igno=
red)
 	// NOT REACHED
+END(break_fault)
=20
-	.proc demine_args
-demine_args:
+ENTRY(demine_args)
 	alloc r2=3Dar.pfs,8,0,0,0
 	tnat.nz p8,p0=3Din0
 	tnat.nz p9,p0=3Din1
@@ -704,12 +713,12 @@
 (p14)	mov in6=3D-1
 (p15)	mov in7=3D-1
 	br.ret.sptk.many rp
-	.endp demine_args
+END(demine_args)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
-interrupt:
+ENTRY(interrupt)
 	mov r31=3Dpr		// prepare to save predicates
 	;;
=20
@@ -730,7 +739,7 @@
 	;;
 	mov rp=3Dr14
 	br.call.sptk.many b6=3Dia64_handle_irq
-	;;
+END(interrupt)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -747,23 +756,17 @@
 // 0x3c00 Entry 15 (size 64 bundles) Reserved
 	FAULT(15)
=20
-//
-//  Squatting in this space ...
-//
-//  This special case dispatcher for illegal operation faults
-//  allows preserved registers to be modified through a=20
-//  callback function (asm only) that is handed back from
-//  the fault handler in r8. Up to three arguments can be
-//  passed to the callback function by returning an aggregate
-//  with the callback as its first element, followed by the
-//  arguments.
-//
-dispatch_illegal_op_fault:
+	/*
+	 * Squatting in this space ...
+	 *
+	 * This special case dispatcher for illegal operation faults allows prese=
rved
+	 * registers to be modified through a callback function (asm only) that i=
s handed
+	 * back from the fault handler in r8. Up to three arguments can be passed=
 to the
+	 * callback function by returning an aggregate with the callback as its f=
irst
+	 * element, followed by the arguments.
+	 */
+ENTRY(dispatch_illegal_op_fault)
 	SAVE_MIN_WITH_COVER
-	//
-	// The "alloc" can cause a mandatory store which could lead to
-	// an "Alt DTLB" fault which we can handle only if psr.ic is on.
-	//
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i		// guarantee that interrupt collection is enabled
@@ -790,7 +793,7 @@
 	cmp.ne p6,p0=3D0,r8
 (p6)	br.call.dpnt b6=B6		// call returns to ia64_leave_kernel
 	br.sptk ia64_leave_kernel
-	;;
+END(dispatch_illegal_op_fault)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -799,14 +802,16 @@
=20
 #ifdef CONFIG_IA32_SUPPORT
=20
-	// There is no particular reason for this code to be here, other than that
-	// there happens to be space here that would go unused otherwise.  If this
-	// fault ever gets "unreserved", simply moved the following code to a more
-	// suitable spot...
+	/*
+	 * There is no particular reason for this code to be here, other than that
+	 * there happens to be space here that would go unused otherwise.  If this
+	 * fault ever gets "unreserved", simply moved the following code to a more
+	 * suitable spot...
+	 */
=20
 	// IA32 interrupt entry point
=20
-dispatch_to_ia32_handler:
+ENTRY(dispatch_to_ia32_handler)
 	SAVE_MIN
 	;;
 	mov r14=3Dcr.isr
@@ -821,7 +826,7 @@
 	;;
 	mov r15=3D0x80
 	shr r14=3Dr14,16          // Get interrupt number
-	;;=20
+	;;
 	cmp.ne p6,p0=3Dr14,r15
 (p6)    br.call.dpnt.many b6=3Dnon_ia32_syscall
=20
@@ -832,7 +837,7 @@
 	st8 [r15]=3Dr8		// save orignal EAX in r1 (IA32 procs don't use the GP)
 	;;
 	alloc r15=3Dar.pfs,0,0,6,0	// must first in an insn group
-	;;=20
+	;;
 	ld4 r8=3D[r14],8          // r8 =3D EAX (syscall number)
 	mov r15"2		// sys_vfork - last implemented system call
 	;;
@@ -851,10 +856,10 @@
 	;;
 	ld4 out4=3D[r14]           // R15 =3D edi
 	movl r16=3Dia32_syscall_table
-	;;=20
+	;;
 (p6)    shladd r16=3Dr8,3,r16     // Force ni_syscall if not valid syscall=
 number
 	ld8 r2=3D[r2]		// r2 =3D current->ptrace
-	;;=20
+	;;
 	ld8 r16=3D[r16]
 	tbit.z p8,p0=3Dr2,PT_TRACESYS_BIT	// (current->ptrace & PT_TRACESYS) =3D =
0?
 	;;
@@ -866,7 +871,7 @@
 	;;
 	br.call.sptk.many rp=3Dia32_trace_syscall	// rp will be overwritten (igno=
red)
=20
-non_ia32_syscall:      =20
+non_ia32_syscall:
 	alloc r15=3Dar.pfs,0,0,2,0
 	mov out0=3Dr14                            // interrupt #
 	add out1=16,sp                          // pointer to pt_regs
@@ -876,7 +881,7 @@
 	;;
 	mov rp=3Dr15
 	br.ret.sptk.many rp
-	;;
+END(dispatch_to_ia32_handler)
=20
 #endif /* CONFIG_IA32_SUPPORT */
=20
@@ -885,7 +890,7 @@
 // 0x4400 Entry 17 (size 64 bundles) Reserved
 	FAULT(17)
=20
-non_syscall:
+ENTRY(non_syscall)
 	SAVE_MIN_WITH_COVER
=20
 	// There is no particular reason for this code to be here, other than that
@@ -893,7 +898,9 @@
 	// fault ever gets "unreserved", simply moved the following code to a more
 	// suitable spot...
=20
-	mov r8=3Dcr.iim			// get break immediate (must be done while psr.ic is of=
f)
+	alloc r14=3Dar.pfs,0,0,2,0
+	mov out0=3Dr8
+	add out1=16,sp
 	adds r3=3D8,r2			// set up second base pointer for SAVE_REST
=20
 	ssm psr.ic | PSR_DEFAULT_BITS
@@ -903,37 +910,31 @@
 (p15)	ssm psr.i			// restore psr.i
 	movl r15=3Dia64_leave_kernel
 	;;
-	alloc r14=3Dar.pfs,0,0,2,0
-	mov out0=3Dr8			// break number
-	add out1=16,sp			// pointer to pt_regs
-	;;
 	SAVE_REST
 	mov rp=3Dr15
 	;;
 	br.call.sptk.many b6=3Dia64_bad_break	// avoid WAW on CFM and ignore retu=
rn addr
-	;;
+END(non_syscall)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4800 Entry 18 (size 64 bundles) Reserved
 	FAULT(18)
=20
-	// There is no particular reason for this code to be here, other than that
-	// there happens to be space here that would go unused otherwise.  If this
-	// fault ever gets "unreserved", simply moved the following code to a more
-	// suitable spot...
+	/*
+	 * There is no particular reason for this code to be here, other than that
+	 * there happens to be space here that would go unused otherwise.  If this
+	 * fault ever gets "unreserved", simply moved the following code to a more
+	 * suitable spot...
+	 */
=20
-dispatch_unaligned_handler:
+ENTRY(dispatch_unaligned_handler)
 	SAVE_MIN_WITH_COVER
 	;;
-	//
-	// we can't have the alloc while psr.ic is cleared because=20
-	// we might get a mandatory RSE (when you reach the end of the=20
-	// rotating partition when doing the alloc) spill which could cause=20
-	// a page fault on the kernel virtual address and the handler=20
-	// wouldn't get the state to recover.
-	//
-	mov r15=3Dcr.ifa
+	alloc r14=3Dar.pfs,0,0,2,0		// now it's safe (must be first in insn group=
!)
+	mov out0=3Dcr.ifa
+	adds out1=16,sp
+
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
@@ -942,45 +943,38 @@
 	adds r3=3D8,r2				// set up second base pointer
 	;;
 	SAVE_REST
-	;;
-	alloc r14=3Dar.pfs,0,0,2,0		// now it's safe (must be first in insn group=
!)
-	;;					// avoid WAW on r14
 	movl r14=3Dia64_leave_kernel
-	mov out0=3Dr15				// out0 =3D faulting address
-	adds out1=16,sp				// out1 =3D pointer to pt_regs
 	;;
 	mov rp=3Dr14
 	br.sptk.many ia64_prepare_handle_unaligned
-	;;
+END(dispatch_unaligned_handler)
=20
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4c00 Entry 19 (size 64 bundles) Reserved
 	FAULT(19)
=20
-	// There is no particular reason for this code to be here, other than that
-	// there happens to be space here that would go unused otherwise.  If this
-	// fault ever gets "unreserved", simply moved the following code to a more
-	// suitable spot...
+	/*
+	 * There is no particular reason for this code to be here, other than that
+	 * there happens to be space here that would go unused otherwise.  If this
+	 * fault ever gets "unreserved", simply moved the following code to a more
+	 * suitable spot...
+	 */
=20
-dispatch_to_fault_handler:
-	//
-	// Input:
-	//	psr.ic:	off
-	//	r19:	fault vector number (e.g., 24 for General Exception)
-	//	r31:	contains saved predicates (pr)
-	//
+ENTRY(dispatch_to_fault_handler)
+	/*
+	 * Input:
+	 *	psr.ic:	off
+	 *	r19:	fault vector number (e.g., 24 for General Exception)
+	 *	r31:	contains saved predicates (pr)
+	 */
 	SAVE_MIN_WITH_COVER_R19
-	//
-	// Copy control registers to temporary registers, then turn on psr bits,
-	// then copy the temporary regs to the output regs.  We have to do this
-	// because the "alloc" can cause a mandatory store which could lead to
-	// an "Alt DTLB" fault which we can handle only if psr.ic is on.
-	//
-	mov r8=3Dcr.isr
-	mov r9=3Dcr.ifa
-	mov r10=3Dcr.iim
-	mov r11=3Dcr.itir
+	alloc r14=3Dar.pfs,0,0,5,0
+	mov out0=3Dr15
+	mov out1=3Dcr.isr
+	mov out2=3Dcr.ifa
+	mov out3=3Dcr.iim
+	mov out4=3Dcr.itir
 	;;
 	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
@@ -989,19 +983,12 @@
 (p15)	ssm psr.i				// restore psr.i
 	adds r3=3D8,r2				// set up second base pointer for SAVE_REST
 	;;
-	alloc r14=3Dar.pfs,0,0,5,0		// must be first in insn group
-	mov out0=3Dr15
-	mov out1=3Dr8
-	mov out2=3Dr9
-	mov out3=3Dr10
-	mov out4=3Dr11
-	;;
 	SAVE_REST
 	movl r14=3Dia64_leave_kernel
 	;;
 	mov rp=3Dr14
 	br.call.sptk.many b6=3Dia64_fault
-	;;
+END(dispatch_to_fault_handler)
=20
 //
 // --- End of long entries, Beginning of short entries
@@ -1010,10 +997,13 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5000 Entry 20 (size 16 bundles) Page Not Present (10,22,49)
+ENTRY(page_not_present)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
-	// The Linux page fault handler doesn't expect non-present pages to be in
-	// the TLB.  Flush the existing entry now, so we meet that expectation.
+	/*
+	 * The Linux page fault handler doesn't expect non-present pages to be in
+	 * the TLB.  Flush the existing entry now, so we meet that expectation.
+	 */
 	mov r17=3D_PAGE_SIZE_4K<<2
 	;;
 	ptc.l r16,r17
@@ -1021,44 +1011,48 @@
 	mov r31=3Dpr
 	srlz.d
 	br.sptk.many page_fault
-	;;
+END(page_not_present)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5100 Entry 21 (size 16 bundles) Key Permission (13,25,52)
+ENTRY(key_permission)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	mov r31=3Dpr
 	;;
 	srlz.d
 	br.sptk.many page_fault
-	;;
+END(key_permission)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5200 Entry 22 (size 16 bundles) Instruction Access Rights (26)
+ENTRY(iaccess_rights)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	mov r31=3Dpr
 	;;
 	srlz.d
 	br.sptk.many page_fault
-	;;
+END(iaccess_rights)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5300 Entry 23 (size 16 bundles) Data Access Rights (14,53)
+ENTRY(daccess_rights)
 	mov r16=3Dcr.ifa
 	rsm psr.dt
 	mov r31=3Dpr
 	;;
 	srlz.d
 	br.sptk.many page_fault
-	;;
+END(daccess_rights)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5400 Entry 24 (size 16 bundles) General Exception (5,32,34,36,38,39)
+ENTRY(general_exception)
 	mov r16=3Dcr.isr
 	mov r31=3Dpr
 	;;
@@ -1067,39 +1061,41 @@
 	;;
 	mov r19$		// fault number
 	br.sptk.many dispatch_to_fault_handler
-	;;
+END(general_exception)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5500 Entry 25 (size 16 bundles) Disabled FP-Register (35)
+ENTRY(disabled_fp_reg)
 	rsm psr.dfh		// ensure we can access fph
 	;;
 	srlz.d
 	mov r31=3Dpr
 	mov r19%
 	br.sptk.many dispatch_to_fault_handler
-	;;
+END(disabled_fp_reg)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5600 Entry 26 (size 16 bundles) Nat Consumption (11,23,37,50)
+ENTRY(nat_consumption)
 	FAULT(26)
+END(nat_consumption)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5700 Entry 27 (size 16 bundles) Speculation (40)
-	//
-	// A [f]chk.[as] instruction needs to take the branch to
-	// the recovery code but this part of the architecture is
-	// not implemented in hardware on some CPUs, such as Itanium.
-	// Thus, in general we need to emulate the behavior.
-	// IIM contains the relative target (not yet sign extended).
-	// So after sign extending it we simply add it to IIP.
-	// We also need to reset the EI field of the IPSR to zero,
-	// i.e., the slot to restart into.
-	//
-	// cr.imm contains zero_ext(imm21)
-	//
+ENTRY(speculation_vector)
+	/*
+	 * A [f]chk.[as] instruction needs to take the branch to the recovery cod=
e but
+	 * this part of the architecture is not implemented in hardware on some C=
PUs, such
+	 * as Itanium.  Thus, in general we need to emulate the behavior.  IIM co=
ntains
+	 * the relative target (not yet sign extended).  So after sign extending =
it we
+	 * simply add it to IIP.  We also need to reset the EI field of the IPSR =
to zero,
+	 * i.e., the slot to restart into.
+	 *
+	 * cr.imm contains zero_ext(imm21)
+	 */
 	mov r18=3Dcr.iim
 	;;
 	mov r17=3Dcr.iip
@@ -1120,7 +1116,7 @@
 	;;
=20
 	rfi				// and go back
-	;;
+END(speculation_vector)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -1130,16 +1126,19 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5900 Entry 29 (size 16 bundles) Debug (16,28,56)
+ENTRY(debug_vector)
 	FAULT(29)
+END(debug_vector)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5a00 Entry 30 (size 16 bundles) Unaligned Reference (57)
+ENTRY(unaligned_access)
 	mov r16=3Dcr.ipsr
 	mov r31=3Dpr		// prepare to save predicates
-	;;								=09
-	br.sptk.many dispatch_unaligned_handler
 	;;
+	br.sptk.many dispatch_unaligned_handler
+END(unaligned_access)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
@@ -1214,11 +1213,14 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6900 Entry 45 (size 16 bundles) IA-32 Exeception (17,18,29,41,42,43,4=
4,58,60,61,62,72,73,75,76,77)
+ENTRY(ia32_exception)
 	FAULT(45)
+END(ia32_exception)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6a00 Entry 46 (size 16 bundles) IA-32 Intercept  (30,31,59,70,71)
+ENTRY(ia32_intercept)
 #ifdef	CONFIG_IA32_SUPPORT
 	mov r31=3Dpr
 	mov r16=3Dcr.isr
@@ -1227,32 +1229,34 @@
 	mov r18=3Dar.eflag
 	mov r19=3Dcr.iim		// old eflag value
 	;;
-	cmp.ne p2,p0=3D2,r17
-(p2)	br.cond.spnt 1f		// not a system flag fault
+	cmp.ne p6,p0=3D2,r17
+(p6)	br.cond.spnt 1f		// not a system flag fault
 	xor r16=3Dr18,r19
 	;;
 	extr.u r17=3Dr16,18,1	// get the eflags.ac bit
 	;;
-	cmp.eq p2,p0=3D0,r17
-(p2)	br.cond.spnt 1f		// eflags.ac bit didn't change
+	cmp.eq p6,p0=3D0,r17
+(p6)	br.cond.spnt 1f		// eflags.ac bit didn't change
 	;;
 	mov pr=3Dr31,-1		// restore predicate registers
 	rfi
-	;;
+
 1:
 #endif	// CONFIG_IA32_SUPPORT
 	FAULT(46)
+END(ia32_intercept)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x6b00 Entry 47 (size 16 bundles) IA-32 Interrupt  (74)
+ENTRY(ia32_interrupt)
 #ifdef CONFIG_IA32_SUPPORT
 	mov r31=3Dpr
 	br.sptk.many dispatch_to_ia32_handler
-	;;
 #else
 	FAULT(47)
 #endif
+END(ia32_interrupt)
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.4.1-lia/arch/ia64=
/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/mca_asm.S	Wed Feb 21 16:09:41 2001
@@ -1,4 +1,4 @@
-//=20
+//
 // assembly portion of the IA64 MCA handling
 //
 // Mods by cfleck to integrate into kernel build
@@ -18,10 +18,10 @@
  * When we get an machine check, the kernel stack pointer is no longer
  * valid, so we need to set a new stack pointer.
  */
-#define	MINSTATE_PHYS	/* Make sure stack access is physical for MINSTATE *=
/=20
+#define	MINSTATE_PHYS	/* Make sure stack access is physical for MINSTATE */
=20
 #include "minstate.h"
-=09
+
 	.psr abi64
 	.psr lsb
 	.lsb
@@ -36,26 +36,26 @@
  *		6. GR12 =3D Return address to location within SAL_CHECK
  */
 #define SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(_tmp)		\
-        movl	_tmp=3Dia64_sal_to_os_handoff_state;;	\
-        st8	[_tmp]=3Dr1,0x08;;			\
-        st8	[_tmp]=3Dr8,0x08;;			\
-        st8	[_tmp]=3Dr9,0x08;;			\
-        st8	[_tmp]=3Dr10,0x08;;			\
-        st8	[_tmp]=3Dr11,0x08;;			\
-        st8	[_tmp]=3Dr12,0x08;;
+	movl	_tmp=3Dia64_sal_to_os_handoff_state;;	\
+	st8	[_tmp]=3Dr1,0x08;;			\
+	st8	[_tmp]=3Dr8,0x08;;			\
+	st8	[_tmp]=3Dr9,0x08;;			\
+	st8	[_tmp]=3Dr10,0x08;;			\
+	st8	[_tmp]=3Dr11,0x08;;			\
+	st8	[_tmp]=3Dr12,0x08;;
=20
 /*
  *	OS_MCA_TO_SAL_HANDOFF_STATE
  *		1. GR8 =3D OS_MCA status
  *		2. GR9 =3D SAL GP (physical)
  *		3. GR22 =3D New min state save area pointer
- */=09
+ */
 #define OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(_tmp)	\
-        movl	_tmp=3Dia64_os_to_sal_handoff_state;;	\
+	movl	_tmp=3Dia64_os_to_sal_handoff_state;;	\
 	DATA_VA_TO_PA(_tmp);;				\
-        ld8	r8=3D[_tmp],0x08;;			\
-        ld8	r9=3D[_tmp],0x08;;			\
-        ld8	r22=3D[_tmp],0x08;;
+	ld8	r8=3D[_tmp],0x08;;			\
+	ld8	r9=3D[_tmp],0x08;;			\
+	ld8	r22=3D[_tmp],0x08;;
=20
 /*
  *	BRANCH
@@ -66,9 +66,9 @@
  *		"ip" is the address of the instruction
  *	located at "from_label".
  *		"temp" is a scratch register like r2
- *		"adjust" needed for HP compiler.=20
+ *		"adjust" needed for HP compiler.
  *	A screwup somewhere with constant arithmetic.
- */=09
+ */
 #define BRANCH(to_label, temp, p, adjust)		\
 100:	(p)	mov		temp=3Dip;		\
 		;;					\
@@ -77,7 +77,7 @@
 	(p)	adds		temp=ADjust,temp;	\
 		;;					\
 	(p)	mov		b1=3Dtemp	;		\
-	(p)	br		b1=09
+	(p)	br		b1
=20
 	.global ia64_os_mca_dispatch
 	.global ia64_os_mca_dispatch_end
@@ -89,11 +89,11 @@
 	.global	ia64_mca_stack
 	.global	ia64_mca_stackframe
 	.global	ia64_mca_bspstore
-	.global ia64_init_stack=09
-		=09
+	.global ia64_init_stack
+
 	.text
 	.align 16
-=09
+
 ia64_os_mca_dispatch:
=20
 #if defined(MCA_TEST)
@@ -115,23 +115,23 @@
 	;;
 begin_os_mca_dump:
 	BRANCH(ia64_os_mca_proc_state_dump, r2, p0, 0x0)
-        ;;
+	;;
 ia64_os_mca_done_dump:
=20
-	// Setup new stack frame for OS_MCA handling=20
-        movl        r2=3Dia64_mca_bspstore		// local bspstore area locatio=
n in r2
-        movl        r3=3Dia64_mca_stackframe		// save stack frame to memor=
y in r3
-        rse_switch_context(r6,r3,r2);;                  // RSC management =
in this new context
-        movl        r12=3Dia64_mca_stack;;
+	// Setup new stack frame for OS_MCA handling
+	movl        r2=3Dia64_mca_bspstore		// local bspstore area location in r2
+	movl        r3=3Dia64_mca_stackframe		// save stack frame to memory in r3
+	rse_switch_context(r6,r3,r2);;                  // RSC management in this=
 new context
+	movl        r12=3Dia64_mca_stack;;
=20
 	// Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
 ia64_os_mca_virtual_begin:
=20
 	// call our handler
-        movl		r2=3Dia64_mca_ucmc_handler;;
-        mov		b6=3Dr2;;
-        br.call.sptk.few	b0=B6
+	movl		r2=3Dia64_mca_ucmc_handler;;
+	mov		b6=3Dr2;;
+	br.call.sptk.few	b0=B6
 .ret0:
 	// Revert back to physical mode before going back to SAL
 	PHYSICAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_end, r4)
@@ -145,42 +145,36 @@
 #endif	/* #if defined(MCA_TEST) */
=20
 	// restore the original stack frame here
-        movl    r2=3Dia64_mca_stackframe               // restore stack fr=
ame from memory at r2
+	movl    r2=3Dia64_mca_stackframe               // restore stack frame fro=
m memory at r2
 	;;
 	DATA_VA_TO_PA(r2)
-        movl    r4=3DIA64_PSR_MC
+	movl    r4=3DIA64_PSR_MC
 	;;
-        rse_return_context(r4,r3,r2)                 // switch from interr=
upt context for RSE
-=09
+	rse_return_context(r4,r3,r2)                 // switch from interrupt con=
text for RSE
+
 	// let us restore all the registers from our PSI structure
-        mov		r8=3Dgp
+	mov		r8=3Dgp
 	;;
 begin_os_mca_restore:
 	BRANCH(ia64_os_mca_proc_state_restore, r2, p0, 0x0)
-        ;;
+	;;
=20
 ia64_os_mca_done_restore:
 	;;
-#ifdef SOFTSDV
-	VIRTUAL_MODE_ENTER(r2,r3, vmode_enter, r4)
-vmode_enter:=09
-	br.ret.sptk.few		b0=09
-#else
 	// branch back to SALE_CHECK
 	OS_MCA_TO_SAL_HANDOFF_STATE_RESTORE(r2)
-        ld8		r3=3D[r2];;             =20
-        mov		b0=3Dr3                       // SAL_CHECK return address
-        br		b0
-        ;;
-#endif /* #ifdef SOFTSDV */
-ia64_os_mca_dispatch_end:=09
+	ld8		r3=3D[r2];;
+	mov		b0=3Dr3                       // SAL_CHECK return address
+	br		b0
+	;;
+ia64_os_mca_dispatch_end:
 //EndMain/////////////////////////////////////////////////////////////////=
/////
=20
=20
 //++
 // Name:
 //      ia64_os_mca_proc_state_dump()
-//=20
+//
 // Stub Description:
 //
 //       This stub dumps the processor state during MCHK to a data area
@@ -189,223 +183,223 @@
=20
 ia64_os_mca_proc_state_dump:
 // Get and save GR0-31 from Proc. Min. State Save Area to SAL PSI
-        movl		r2=3Dia64_mca_proc_state_dump;;           // Os state dump a=
rea
+	movl		r2=3Dia64_mca_proc_state_dump;;           // Os state dump area
=20
-// save ar.NaT=20
-        mov		r5=3Dar.unat                  // ar.unat
+// save ar.NaT
+	mov		r5=3Dar.unat                  // ar.unat
=20
 // save banked GRs 16-31 along with NaT bits
-        bsw.1;;
-        st8.spill	[r2]=3Dr16,8;;
-        st8.spill	[r2]=3Dr17,8;;
-        st8.spill	[r2]=3Dr18,8;;
-        st8.spill	[r2]=3Dr19,8;;
-        st8.spill	[r2]=3Dr20,8;;
-        st8.spill	[r2]=3Dr21,8;;
-        st8.spill	[r2]=3Dr22,8;;
-        st8.spill	[r2]=3Dr23,8;;
-        st8.spill	[r2]=3Dr24,8;;
-        st8.spill	[r2]=3Dr25,8;;
-        st8.spill	[r2]=3Dr26,8;;
-        st8.spill	[r2]=3Dr27,8;;
-        st8.spill	[r2]=3Dr28,8;;
-        st8.spill	[r2]=3Dr29,8;;
-        st8.spill	[r2]=3Dr30,8;;
-        st8.spill	[r2]=3Dr31,8;;
-
-        mov		r4=3Dar.unat;;
-        st8		[r2]=3Dr4,8                // save User NaT bits for r16-r31
-        mov		ar.unat=3Dr5                  // restore original unat
-        bsw.0;;
+	bsw.1;;
+	st8.spill	[r2]=3Dr16,8;;
+	st8.spill	[r2]=3Dr17,8;;
+	st8.spill	[r2]=3Dr18,8;;
+	st8.spill	[r2]=3Dr19,8;;
+	st8.spill	[r2]=3Dr20,8;;
+	st8.spill	[r2]=3Dr21,8;;
+	st8.spill	[r2]=3Dr22,8;;
+	st8.spill	[r2]=3Dr23,8;;
+	st8.spill	[r2]=3Dr24,8;;
+	st8.spill	[r2]=3Dr25,8;;
+	st8.spill	[r2]=3Dr26,8;;
+	st8.spill	[r2]=3Dr27,8;;
+	st8.spill	[r2]=3Dr28,8;;
+	st8.spill	[r2]=3Dr29,8;;
+	st8.spill	[r2]=3Dr30,8;;
+	st8.spill	[r2]=3Dr31,8;;
+
+	mov		r4=3Dar.unat;;
+	st8		[r2]=3Dr4,8                // save User NaT bits for r16-r31
+	mov		ar.unat=3Dr5                  // restore original unat
+	bsw.0;;
=20
 //save BRs
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2                // duplicate r2 in r4
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2                // duplicate r2 in r4
=20
-        mov		r3=B0
-        mov		r5=B1
-        mov		r7=B2;;
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;; =20
-
-        mov		r3=B3
-        mov		r5=B4
-        mov		r7=B5;;
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;; =20
-
-        mov		r3=B6
-        mov		r5=B7;;
-        st8		[r2]=3Dr3,2*8
-        st8		[r4]=3Dr5,2*8;;
+	mov		r3=B0
+	mov		r5=B1
+	mov		r7=B2;;
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
+
+	mov		r3=B3
+	mov		r5=B4
+	mov		r7=B5;;
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
+
+	mov		r3=B6
+	mov		r5=B7;;
+	st8		[r2]=3Dr3,2*8
+	st8		[r4]=3Dr5,2*8;;
=20
 cSaveCRs:
 // save CRs
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2                // duplicate r2 in r4
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2                // duplicate r2 in r4
=20
-        mov		r3=3Dcr0                      // cr.dcr
-        mov		r5=3Dcr1                      // cr.itm
-        mov		r7=3Dcr2;;                    // cr.iva
-
-        st8		[r2]=3Dr3,8*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;;            // 48 byte rements
+	mov		r3=3Dcr0                      // cr.dcr
+	mov		r5=3Dcr1                      // cr.itm
+	mov		r7=3Dcr2;;                    // cr.iva
+
+	st8		[r2]=3Dr3,8*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;            // 48 byte rements
=20
-        mov		r3=3Dcr8;;                    // cr.pta
-        st8		[r2]=3Dr3,8*8;;            // 64 byte rements
+	mov		r3=3Dcr8;;                    // cr.pta
+	st8		[r2]=3Dr3,8*8;;            // 64 byte rements
=20
 // if PSR.ic=3D0, reading interruption registers causes an illegal operati=
on fault
-        mov		r3=3Dpsr;;
-        tbit.nz.unc	p2,p0=3Dr3,PSR_IC;;           // PSI Valid Log bit pos=
. test
-(p2)    st8		[r2]=3Dr0,9*8+160             // increment by 168 byte inc.
-begin_skip_intr_regs:=09
-	BRANCH(SkipIntrRegs,  r9, p2, 0x0)
-	;;=20
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2                // duplicate r2 in r6
-       =20
-        mov		r3=3Dcr16                     // cr.ipsr
-        mov		r5=3Dcr17                     // cr.isr
-        mov		r7=3Dr0;;                     // cr.ida =3D> cr18
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;;                                     =20
-
-        mov		r3=3Dcr19                     // cr.iip
-        mov		r5=3Dcr20                     // cr.idtr
-        mov		r7=3Dcr21;;                   // cr.iitr
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;;                                     =20
-
-        mov		r3=3Dcr22                     // cr.iipa
-        mov		r5=3Dcr23                     // cr.ifs
-        mov		r7=3Dcr24;;                   // cr.iim
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;;   =20
-                                         =20
-        mov		r3=3Dcr25;;                   // cr.iha
-        st8		[r2]=3Dr3,160;;               // 160 byte rement
+	mov		r3=3Dpsr;;
+	tbit.nz.unc	p6,p0=3Dr3,PSR_IC;;           // PSI Valid Log bit pos. test
+(p6)    st8		[r2]=3Dr0,9*8+160             // increment by 168 byte inc.
+begin_skip_intr_regs:
+	BRANCH(SkipIntrRegs,  r9, p6, 0x0)
+	;;
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2                // duplicate r2 in r6
+
+	mov		r3=3Dcr16                     // cr.ipsr
+	mov		r5=3Dcr17                     // cr.isr
+	mov		r7=3Dr0;;                     // cr.ida =3D> cr18
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
+
+	mov		r3=3Dcr19                     // cr.iip
+	mov		r5=3Dcr20                     // cr.idtr
+	mov		r7=3Dcr21;;                   // cr.iitr
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
+
+	mov		r3=3Dcr22                     // cr.iipa
+	mov		r5=3Dcr23                     // cr.ifs
+	mov		r7=3Dcr24;;                   // cr.iim
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
+
+	mov		r3=3Dcr25;;                   // cr.iha
+	st8		[r2]=3Dr3,160;;               // 160 byte rement
=20
 SkipIntrRegs:
-        st8		[r2]=3Dr0,168                 // another 168 byte .
+	st8		[r2]=3Dr0,168                 // another 168 byte .
=20
-        mov		r3=3Dcr66;;                   // cr.lid
-        st8		[r2]=3Dr3,40                  // 40 byte rement
+	mov		r3=3Dcr66;;                   // cr.lid
+	st8		[r2]=3Dr3,40                  // 40 byte rement
=20
-        mov		r3=3Dcr71;;                   // cr.ivr
-        st8		[r2]=3Dr3,8
+	mov		r3=3Dcr71;;                   // cr.ivr
+	st8		[r2]=3Dr3,8
=20
-        mov		r3=3Dcr72;;                   // cr.tpr
-        st8		[r2]=3Dr3,24                  // 24 byte increment
-   =20
-        mov		r3=3Dr0;;                     // cr.eoi =3D> cr75
-        st8		[r2]=3Dr3,168                 // 168 byte inc.
-   =20
-        mov		r3=3Dr0;;                     // cr.irr0 =3D> cr96
-        st8		[r2]=3Dr3,16               // 16 byte inc.
+	mov		r3=3Dcr72;;                   // cr.tpr
+	st8		[r2]=3Dr3,24                  // 24 byte increment
=20
-        mov		r3=3Dr0;;                     // cr.irr1 =3D> cr98
-        st8		[r2]=3Dr3,16               // 16 byte inc.
+	mov		r3=3Dr0;;                     // cr.eoi =3D> cr75
+	st8		[r2]=3Dr3,168                 // 168 byte inc.
=20
-        mov		r3=3Dr0;;                     // cr.irr2 =3D> cr100
-        st8		[r2]=3Dr3,16               // 16 byte inc
+	mov		r3=3Dr0;;                     // cr.irr0 =3D> cr96
+	st8		[r2]=3Dr3,16               // 16 byte inc.
=20
-        mov		r3=3Dr0;;                     // cr.irr3 =3D> cr100
-        st8		[r2]=3Dr3,16               // 16b inc.
+	mov		r3=3Dr0;;                     // cr.irr1 =3D> cr98
+	st8		[r2]=3Dr3,16               // 16 byte inc.
=20
-        mov		r3=3Dr0;;                     // cr.itv =3D> cr114
-        st8		[r2]=3Dr3,16               // 16 byte inc.
+	mov		r3=3Dr0;;                     // cr.irr2 =3D> cr100
+	st8		[r2]=3Dr3,16               // 16 byte inc
=20
-        mov		r3=3Dr0;;                     // cr.pmv =3D> cr116
-        st8		[r2]=3Dr3,8
+	mov		r3=3Dr0;;                     // cr.irr3 =3D> cr100
+	st8		[r2]=3Dr3,16               // 16b inc.
=20
-        mov		r3=3Dr0;;                     // cr.lrr0 =3D> cr117
-        st8		[r2]=3Dr3,8
+	mov		r3=3Dr0;;                     // cr.itv =3D> cr114
+	st8		[r2]=3Dr3,16               // 16 byte inc.
=20
-        mov		r3=3Dr0;;                     // cr.lrr1 =3D> cr118
-        st8		[r2]=3Dr3,8
+	mov		r3=3Dr0;;                     // cr.pmv =3D> cr116
+	st8		[r2]=3Dr3,8
=20
-        mov		r3=3Dr0;;                     // cr.cmcv =3D> cr119
-        st8		[r2]=3Dr3,8*10;;
+	mov		r3=3Dr0;;                     // cr.lrr0 =3D> cr117
+	st8		[r2]=3Dr3,8
+
+	mov		r3=3Dr0;;                     // cr.lrr1 =3D> cr118
+	st8		[r2]=3Dr3,8
+
+	mov		r3=3Dr0;;                     // cr.cmcv =3D> cr119
+	st8		[r2]=3Dr3,8*10;;
=20
 cSaveARs:
 // save ARs
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2                // duplicate r2 in r6
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2                // duplicate r2 in r6
=20
-        mov		r3=3Dar0                      // ar.kro
-        mov		r5=3Dar1                      // ar.kr1
-        mov		r7=3Dar2;;                    // ar.kr2
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;;
-
-        mov		r3=3Dar3                      // ar.kr3                      =
        =20
-        mov		r5=3Dar4                      // ar.kr4
-        mov		r7=3Dar5;;                    // ar.kr5
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;;
-
-        mov		r3=3Dar6                      // ar.kr6
-        mov		r5=3Dar7                      // ar.kr7
-        mov		r7=3Dr0;;                     // ar.kr8
-        st8		[r2]=3Dr3,10*8
-        st8		[r4]=3Dr5,10*8
-        st8		[r6]=3Dr7,10*8;;           // rement by 72 bytes
+	mov		r3=3Dar0                      // ar.kro
+	mov		r5=3Dar1                      // ar.kr1
+	mov		r7=3Dar2;;                    // ar.kr2
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
+
+	mov		r3=3Dar3                      // ar.kr3
+	mov		r5=3Dar4                      // ar.kr4
+	mov		r7=3Dar5;;                    // ar.kr5
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
+
+	mov		r3=3Dar6                      // ar.kr6
+	mov		r5=3Dar7                      // ar.kr7
+	mov		r7=3Dr0;;                     // ar.kr8
+	st8		[r2]=3Dr3,10*8
+	st8		[r4]=3Dr5,10*8
+	st8		[r6]=3Dr7,10*8;;           // rement by 72 bytes
=20
-        mov		r3=3Dar16                     // ar.rsc
+	mov		r3=3Dar16                     // ar.rsc
 	mov		ar16=3Dr0			    // put RSE in enforced lazy mode
-        mov		r5=3Dar17                     // ar.bsp
+	mov		r5=3Dar17                     // ar.bsp
 	;;
-        mov		r7=3Dar18;;                   // ar.bspstore
-        st8		[r2]=3Dr3,3*8
-        st8		[r4]=3Dr5,3*8
-        st8		[r6]=3Dr7,3*8;;
+	mov		r7=3Dar18;;                   // ar.bspstore
+	st8		[r2]=3Dr3,3*8
+	st8		[r4]=3Dr5,3*8
+	st8		[r6]=3Dr7,3*8;;
=20
-        mov		r3=3Dar19;;                   // ar.rnat
-        st8		[r2]=3Dr3,8*13             // increment by 13x8 bytes
+	mov		r3=3Dar19;;                   // ar.rnat
+	st8		[r2]=3Dr3,8*13             // increment by 13x8 bytes
=20
-        mov		r3=3Dar32;;                   // ar.ccv
-        st8		[r2]=3Dr3,8*4
+	mov		r3=3Dar32;;                   // ar.ccv
+	st8		[r2]=3Dr3,8*4
=20
-        mov		r3=3Dar36;;                   // ar.unat
-        st8		[r2]=3Dr3,8*4
+	mov		r3=3Dar36;;                   // ar.unat
+	st8		[r2]=3Dr3,8*4
=20
-        mov		r3=3Dar40;;                   // ar.fpsr
-        st8		[r2]=3Dr3,8*4
+	mov		r3=3Dar40;;                   // ar.fpsr
+	st8		[r2]=3Dr3,8*4
=20
-        mov		r3=3Dar44;;                   // ar.itc
-        st8		[r2]=3Dr3,160                 // 160
+	mov		r3=3Dar44;;                   // ar.itc
+	st8		[r2]=3Dr3,160                 // 160
=20
-        mov		r3=3Dar64;;                   // ar.pfs
-        st8		[r2]=3Dr3,8
+	mov		r3=3Dar64;;                   // ar.pfs
+	st8		[r2]=3Dr3,8
=20
-        mov		r3=3Dar65;;                   // ar.lc
-        st8		[r2]=3Dr3,8
+	mov		r3=3Dar65;;                   // ar.lc
+	st8		[r2]=3Dr3,8
+
+	mov		r3=3Dar66;;                   // ar.ec
+	st8		[r2]=3Dr3
+	add		r2=3D8*62,r2               //padding
=20
-        mov		r3=3Dar66;;                   // ar.ec
-        st8		[r2]=3Dr3
-        add		r2=3D8*62,r2               //padding
-   =20
 // save RRs
-        mov		ar.lc=3D0x08-1
-        movl		r4=3D0x00;;
+	mov		ar.lc=3D0x08-1
+	movl		r4=3D0x00;;
=20
 cStRR:
-        mov		r3=3Drr[r4];;
-        st8		[r2]=3Dr3,8
-        add		r4=3D1,r4
-        br.cloop.sptk.few	cStRR
-        ;;
+	mov		r3=3Drr[r4];;
+	st8		[r2]=3Dr3,8
+	add		r4=3D1,r4
+	br.cloop.sptk.few	cStRR
+	;;
 end_os_mca_dump:
 	BRANCH(ia64_os_mca_done_dump, r2, p0, -0x10)
-        ;;
+	;;
=20
 //EndStub/////////////////////////////////////////////////////////////////=
/////
=20
@@ -413,7 +407,7 @@
 //++
 // Name:
 //       ia64_os_mca_proc_state_restore()
-//=20
+//
 // Stub Description:
 //
 //       This is a stub to restore the saved processor state during MCHK
@@ -422,225 +416,225 @@
=20
 ia64_os_mca_proc_state_restore:
=20
-// Restore bank1 GR16-31=20
+// Restore bank1 GR16-31
 	movl		r2=3Dia64_mca_proc_state_dump	// Convert virtual address
 	;;						// of OS state dump area
 	DATA_VA_TO_PA(r2)				// to physical address
 	;;
 restore_GRs:                                    // restore bank-1 GRs 16-31
-        bsw.1;;
-        add		r3=16*8,r2;;                // to get to NaT of GR 16-31
-        ld8		r3=3D[r3];;
-        mov		ar.unat=3Dr3;;                // first restore NaT
-
-        ld8.fill	r16=3D[r2],8;;
-        ld8.fill	r17=3D[r2],8;;
-        ld8.fill	r18=3D[r2],8;;
-        ld8.fill	r19=3D[r2],8;;
-        ld8.fill	r20=3D[r2],8;;
-        ld8.fill	r21=3D[r2],8;;
-        ld8.fill	r22=3D[r2],8;;
-        ld8.fill	r23=3D[r2],8;;
-        ld8.fill	r24=3D[r2],8;;
-        ld8.fill	r25=3D[r2],8;;
-        ld8.fill	r26=3D[r2],8;;
-        ld8.fill	r27=3D[r2],8;;
-        ld8.fill	r28=3D[r2],8;;
-        ld8.fill	r29=3D[r2],8;;
-        ld8.fill	r30=3D[r2],8;;
-        ld8.fill	r31=3D[r2],8;;
+	bsw.1;;
+	add		r3=16*8,r2;;                // to get to NaT of GR 16-31
+	ld8		r3=3D[r3];;
+	mov		ar.unat=3Dr3;;                // first restore NaT
+
+	ld8.fill	r16=3D[r2],8;;
+	ld8.fill	r17=3D[r2],8;;
+	ld8.fill	r18=3D[r2],8;;
+	ld8.fill	r19=3D[r2],8;;
+	ld8.fill	r20=3D[r2],8;;
+	ld8.fill	r21=3D[r2],8;;
+	ld8.fill	r22=3D[r2],8;;
+	ld8.fill	r23=3D[r2],8;;
+	ld8.fill	r24=3D[r2],8;;
+	ld8.fill	r25=3D[r2],8;;
+	ld8.fill	r26=3D[r2],8;;
+	ld8.fill	r27=3D[r2],8;;
+	ld8.fill	r28=3D[r2],8;;
+	ld8.fill	r29=3D[r2],8;;
+	ld8.fill	r30=3D[r2],8;;
+	ld8.fill	r31=3D[r2],8;;
=20
-        ld8		r3=3D[r2],8;;              // increment to skip NaT
-        bsw.0;;
+	ld8		r3=3D[r2],8;;              // increment to skip NaT
+	bsw.0;;
=20
 restore_BRs:
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2;;              // duplicate r2 in r4
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2;;              // duplicate r2 in r4
=20
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;; =20
-        mov		b0=3Dr3
-        mov		b1=3Dr5
-        mov		b2=3Dr7;;
-
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;; =20
-        mov		b3=3Dr3
-        mov		b4=3Dr5
-        mov		b5=3Dr7;;
-
-        ld8		r3=3D[r2],2*8
-        ld8		r5=3D[r4],2*8;; =20
-        mov		b6=3Dr3
-        mov		b7=3Dr5;;
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
+	mov		b0=3Dr3
+	mov		b1=3Dr5
+	mov		b2=3Dr7;;
+
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
+	mov		b3=3Dr3
+	mov		b4=3Dr5
+	mov		b5=3Dr7;;
+
+	ld8		r3=3D[r2],2*8
+	ld8		r5=3D[r4],2*8;;
+	mov		b6=3Dr3
+	mov		b7=3Dr5;;
=20
 restore_CRs:
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2;;              // duplicate r2 in r4
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2;;              // duplicate r2 in r4
=20
-        ld8		r3=3D[r2],8*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;;            // 48 byte increments
-        mov		cr0=3Dr3                      // cr.dcr
-        mov		cr1=3Dr5                      // cr.itm
-        mov		cr2=3Dr7;;                    // cr.iva
+	ld8		r3=3D[r2],8*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;            // 48 byte increments
+	mov		cr0=3Dr3                      // cr.dcr
+	mov		cr1=3Dr5                      // cr.itm
+	mov		cr2=3Dr7;;                    // cr.iva
=20
-        ld8		r3=3D[r2],8*8;;            // 64 byte increments
+	ld8		r3=3D[r2],8*8;;            // 64 byte increments
 //      mov		cr8=3Dr3                      // cr.pta
=20
=20
 // if PSR.ic=3D1, reading interruption registers causes an illegal operati=
on fault
-        mov		r3=3Dpsr;;
-        tbit.nz.unc	p2,p0=3Dr3,PSR_IC;;           // PSI Valid Log bit pos=
. test
-(p2)    st8		[r2]=3Dr0,9*8+160             // increment by 160 byte inc.
-
-begin_rskip_intr_regs:=09
-	BRANCH(rSkipIntrRegs, r9, p2, 0x0)
-	;;=20
-
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2;;              // duplicate r2 in r4
-
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;;
-        mov		cr16=3Dr3                     // cr.ipsr
-        mov		cr17=3Dr5                     // cr.isr is read only
+	mov		r3=3Dpsr;;
+	tbit.nz.unc	p6,p0=3Dr3,PSR_IC;;           // PSI Valid Log bit pos. test
+(p6)    st8		[r2]=3Dr0,9*8+160             // increment by 160 byte inc.
+
+begin_rskip_intr_regs:
+	BRANCH(rSkipIntrRegs, r9, p6, 0x0)
+	;;
+
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2;;              // duplicate r2 in r4
+
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
+	mov		cr16=3Dr3                     // cr.ipsr
+	mov		cr17=3Dr5                     // cr.isr is read only
 //      mov		cr18=3Dr7;;                   // cr.ida
=20
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;;
-        mov		cr19=3Dr3                     // cr.iip
-        mov		cr20=3Dr5                     // cr.idtr
-        mov		cr21=3Dr7;;                   // cr.iitr
-
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;;
-        mov		cr22=3Dr3                     // cr.iipa
-        mov		cr23=3Dr5                     // cr.ifs
-        mov		cr24=3Dr7                     // cr.iim
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
+	mov		cr19=3Dr3                     // cr.iip
+	mov		cr20=3Dr5                     // cr.idtr
+	mov		cr21=3Dr7;;                   // cr.iitr
+
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
+	mov		cr22=3Dr3                     // cr.iipa
+	mov		cr23=3Dr5                     // cr.ifs
+	mov		cr24=3Dr7                     // cr.iim
=20
-        ld8		r3=3D[r2],160;;               // 160 byte increment
-        mov		cr25=3Dr3                     // cr.iha=20
+	ld8		r3=3D[r2],160;;               // 160 byte increment
+	mov		cr25=3Dr3                     // cr.iha
=20
 rSkipIntrRegs:
-        ld8		r3=3D[r2],168;;               // another 168 byte inc.
+	ld8		r3=3D[r2],168;;               // another 168 byte inc.
=20
-        ld8		r3=3D[r2],40;;                // 40 byte increment
-        mov		cr66=3Dr3                     // cr.lid
+	ld8		r3=3D[r2],40;;                // 40 byte increment
+	mov		cr66=3Dr3                     // cr.lid
=20
-        ld8		r3=3D[r2],8;;
+	ld8		r3=3D[r2],8;;
 //      mov		cr71=3Dr3                     // cr.ivr is read only
-        ld8		r3=3D[r2],24;;                // 24 byte increment
-        mov		cr72=3Dr3                     // cr.tpr
-  =20
-        ld8		r3=3D[r2],168;;               // 168 byte inc.
+	ld8		r3=3D[r2],24;;                // 24 byte increment
+	mov		cr72=3Dr3                     // cr.tpr
+
+	ld8		r3=3D[r2],168;;               // 168 byte inc.
 //      mov		cr75=3Dr3                     // cr.eoi
-  =20
-        ld8		r3=3D[r2],16;;             // 16 byte inc.
+
+	ld8		r3=3D[r2],16;;             // 16 byte inc.
 //      mov		cr96=3Dr3                     // cr.irr0 is read only
=20
-        ld8		r3=3D[r2],16;;             // 16 byte inc.
+	ld8		r3=3D[r2],16;;             // 16 byte inc.
 //      mov		cr98=3Dr3                     // cr.irr1 is read only
=20
-        ld8		r3=3D[r2],16;;             // 16 byte inc
+	ld8		r3=3D[r2],16;;             // 16 byte inc
 //      mov		cr100=3Dr3                    // cr.irr2 is read only
=20
-        ld8		r3=3D[r2],16;;             // 16b inc.
+	ld8		r3=3D[r2],16;;             // 16b inc.
 //      mov		cr102=3Dr3                    // cr.irr3 is read only
=20
-        ld8		r3=3D[r2],16;;             // 16 byte inc.
+	ld8		r3=3D[r2],16;;             // 16 byte inc.
 //      mov		cr114=3Dr3                    // cr.itv
=20
-        ld8		r3=3D[r2],8;;
+	ld8		r3=3D[r2],8;;
 //      mov		cr116=3Dr3                    // cr.pmv
-        ld8		r3=3D[r2],8;;
+	ld8		r3=3D[r2],8;;
 //      mov		cr117=3Dr3                    // cr.lrr0
-        ld8		r3=3D[r2],8;;
+	ld8		r3=3D[r2],8;;
 //      mov		cr118=3Dr3                    // cr.lrr1
-        ld8		r3=3D[r2],8*10;;
+	ld8		r3=3D[r2],8*10;;
 //      mov		cr119=3Dr3                    // cr.cmcv
=20
 restore_ARs:
-        add		r4=3D8,r2                  // duplicate r2 in r4
-        add		r6=3D2*8,r2;;              // duplicate r2 in r4
+	add		r4=3D8,r2                  // duplicate r2 in r4
+	add		r6=3D2*8,r2;;              // duplicate r2 in r4
=20
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;;
-        mov		ar0=3Dr3                      // ar.kro
-        mov		ar1=3Dr5                      // ar.kr1
-        mov		ar2=3Dr7;;                    // ar.kr2
-
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;;
-        mov		ar3=3Dr3                      // ar.kr3                      =
        =20
-        mov		ar4=3Dr5                      // ar.kr4
-        mov		ar5=3Dr7;;                    // ar.kr5
-
-        ld8		r3=3D[r2],10*8
-        ld8		r5=3D[r4],10*8
-        ld8		r7=3D[r6],10*8;;
-        mov		ar6=3Dr3                      // ar.kr6
-        mov		ar7=3Dr5                      // ar.kr7
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
+	mov		ar0=3Dr3                      // ar.kro
+	mov		ar1=3Dr5                      // ar.kr1
+	mov		ar2=3Dr7;;                    // ar.kr2
+
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
+	mov		ar3=3Dr3                      // ar.kr3
+	mov		ar4=3Dr5                      // ar.kr4
+	mov		ar5=3Dr7;;                    // ar.kr5
+
+	ld8		r3=3D[r2],10*8
+	ld8		r5=3D[r4],10*8
+	ld8		r7=3D[r6],10*8;;
+	mov		ar6=3Dr3                      // ar.kr6
+	mov		ar7=3Dr5                      // ar.kr7
 //      mov		ar8=3Dr6                      // ar.kr8
-        ;;
+	;;
=20
-        ld8		r3=3D[r2],3*8
-        ld8		r5=3D[r4],3*8
-        ld8		r7=3D[r6],3*8;;
+	ld8		r3=3D[r2],3*8
+	ld8		r5=3D[r4],3*8
+	ld8		r7=3D[r6],3*8;;
 //      mov		ar16=3Dr3                     // ar.rsc
 //      mov		ar17=3Dr5                     // ar.bsp is read only
 	mov		ar16=3Dr0			    // make sure that RSE is in enforced lazy mode
 	;;
-        mov		ar18=3Dr7;;                   // ar.bspstore
+	mov		ar18=3Dr7;;                   // ar.bspstore
=20
-        ld8		r9=3D[r2],8*13;;
-        mov		ar19=3Dr9                     // ar.rnat
+	ld8		r9=3D[r2],8*13;;
+	mov		ar19=3Dr9                     // ar.rnat
=20
 	mov		ar16=3Dr3			    // ar.rsc
-        ld8		r3=3D[r2],8*4;;
-        mov		ar32=3Dr3                     // ar.ccv
+	ld8		r3=3D[r2],8*4;;
+	mov		ar32=3Dr3                     // ar.ccv
=20
-        ld8		r3=3D[r2],8*4;;
-        mov		ar36=3Dr3                     // ar.unat
+	ld8		r3=3D[r2],8*4;;
+	mov		ar36=3Dr3                     // ar.unat
=20
-        ld8		r3=3D[r2],8*4;;
-        mov		ar40=3Dr3                     // ar.fpsr
+	ld8		r3=3D[r2],8*4;;
+	mov		ar40=3Dr3                     // ar.fpsr
=20
-        ld8		r3=3D[r2],160;;               // 160
+	ld8		r3=3D[r2],160;;               // 160
 //      mov		ar44=3Dr3                     // ar.itc
=20
-        ld8		r3=3D[r2],8;;
-        mov		ar64=3Dr3                     // ar.pfs
+	ld8		r3=3D[r2],8;;
+	mov		ar64=3Dr3                     // ar.pfs
+
+	ld8		r3=3D[r2],8;;
+	mov		ar65=3Dr3                     // ar.lc
=20
-        ld8		r3=3D[r2],8;;
-        mov		ar65=3Dr3                     // ar.lc
+	ld8		r3=3D[r2];;
+	mov		ar66=3Dr3                     // ar.ec
+	add		r2=3D8*62,r2;;             // padding
=20
-        ld8		r3=3D[r2];;
-        mov		ar66=3Dr3                     // ar.ec
-        add		r2=3D8*62,r2;;             // padding=20
-   =20
 restore_RRs:
-        mov		r5=3Dar.lc
-        mov		ar.lc=3D0x08-1
-        movl		r4=3D0x00
+	mov		r5=3Dar.lc
+	mov		ar.lc=3D0x08-1
+	movl		r4=3D0x00
 cStRRr:
-        ld8		r3=3D[r2],8;;
+	ld8		r3=3D[r2],8;;
 //      mov		rr[r4]=3Dr3                   // what are its access previled=
ges?
-        add		r4=3D1,r4
-        br.cloop.sptk.few	cStRRr
-        ;;
-        mov		ar.lc=3Dr5
+	add		r4=3D1,r4
+	br.cloop.sptk.few	cStRRr
+	;;
+	mov		ar.lc=3Dr5
 	;;
 end_os_mca_restore:
 	BRANCH(ia64_os_mca_done_restore, r2, p0, -0x20)
-	;;=20
+	;;
 //EndStub/////////////////////////////////////////////////////////////////=
/////
=20
 // ok, the issue here is that we need to save state information so
@@ -648,16 +642,16 @@
 // In order to do this, our best bet is save the current state (plus
 // the state information obtain from the MIN_STATE_AREA) into a pt_regs
 // format.  This way we can pass it on in a useable format.
-//			=09
+//
=20
 //
 // SAL to OS entry point for INIT on the monarch processor
-// This has been defined for registration purposes with SAL=20
+// This has been defined for registration purposes with SAL
 // as a part of ia64_mca_init.
 //
 // When we get here, the follow registers have been
 // set by the SAL for our use
-//	=09
+//
 //		1. GR1 =3D OS INIT GP
 //		2. GR8 =3D PAL_PROC physical address
 //		3. GR9 =3D SAL_PROC physical address
@@ -666,14 +660,14 @@
 //			0 =3D Received INIT for event other than crash dump switch
 //			1 =3D Received wakeup at the end of an OS_MCA corrected machine check
 //			2 =3D Received INIT dude to CrashDump switch assertion
-//=09
+//
 //		6. GR12 =3D Return address to location within SAL_INIT procedure
=20
-			=09
+
 	.text
 	.align 16
-.global ia64_monarch_init_handler      =20
-.proc ia64_monarch_init_handler      =20
+.global ia64_monarch_init_handler
+.proc ia64_monarch_init_handler
 ia64_monarch_init_handler:
=20
 #if defined(CONFIG_SMP) && defined(SAL_MPINIT_WORKAROUND)
@@ -681,6 +675,7 @@
 	// work around SAL bug that sends all processors to monarch entry
 	//
 	mov	r17=3Dcr.lid
+	// XXX fix me: this is wrong: hard_smp_processor_id() is a pair of lid/eid
 	movl	r18=3D__cpu_physical_id
 	;;
 	dep	r18=3D0,r18,61,3		// convert to physical address
@@ -695,7 +690,7 @@
 	;;
 #endif
=20
-=09
+
 //
 // ok, the first thing we do is stash the information
 // the SAL passed to os
@@ -707,8 +702,8 @@
 	;;
 	st8	[_tmp]=3Dr1,0x08;;
 	st8	[_tmp]=3Dr8,0x08;;
-	st8	[_tmp]=3Dr9,0x08;;		=09
-	st8	[_tmp]=3Dr10,0x08;;		=09
+	st8	[_tmp]=3Dr9,0x08;;
+	st8	[_tmp]=3Dr10,0x08;;
 	st8	[_tmp]=3Dr11,0x08;;
 	st8	[_tmp]=3Dr12,0x08;;
=20
@@ -720,12 +715,12 @@
 	adds r3=3D8,r2				// set up second base pointer
 	;;
 	SAVE_REST
-=09
+
 // ok, enough should be saved at this point to be dangerous, and  supply
 // information for a dump
 // We need to switch to Virtual mode before hitting the C functions.
 //
-//=20
+//
 //
 	movl	r2=3DIA64_PSR_IT|IA64_PSR_IC|IA64_PSR_DT|IA64_PSR_RT|IA64_PSR_DFH|IA=
64_PSR_BN
 	mov	r3=3Dpsr	// get the current psr, minimum enabled at this point
@@ -740,7 +735,7 @@
 	rfi
 	;;
 IVirtual_Switch:
-	//=09
+	//
 	// We should now be running virtual
 	//
 	// Lets call the C handler to get the rest of the state info
@@ -760,7 +755,7 @@
=20
 //
 // SAL to OS entry point for INIT on the slave processor
-// This has been defined for registration purposes with SAL=20
+// This has been defined for registration purposes with SAL
 // as a part of ia64_mca_init.
 //
=20
@@ -768,10 +763,10 @@
 	.align 16
 .global ia64_slave_init_handler
 .proc ia64_slave_init_handler
-ia64_slave_init_handler:	=09
+ia64_slave_init_handler:
=20
=20
-slave_init_spin_me:=09
+slave_init_spin_me:
 	br.sptk slave_init_spin_me
 	;;
 	.endp
diff -urN linux-davidm/arch/ia64/kernel/minstate.h linux-2.4.1-lia/arch/ia6=
4/kernel/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/minstate.h	Wed Feb 21 16:43:48 2001
@@ -29,20 +29,20 @@
  */
 #define MINSTATE_START_SAVE_MIN_VIRT								\
 	dep r1=3D-1,r1,61,3;				/* r1 =3D current (virtual) */		\
-(p7)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, load=
rs=3D0 */	\
+(pUser)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
 	;;											\
-(p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
-(p7)	mov rARRNAT=3Dar.rnat;									\
+(pUser)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
+(pUser)	mov rARRNAT=3Dar.rnat;									\
 (pKern) mov r1=3Dsp;					/* get sp  */				\
 	;;											\
-(p7)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of me=
mory stack */	\
-(p7)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
+(pUser)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUser)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
 	;;											\
 (pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r=
12) */	\
-(p7)	mov ar.bspstore=3DrKRBS;				/* switch to kernel RBS */		\
+(pUser)	mov ar.bspstore=3DrKRBS;				/* switch to kernel RBS */		\
 	;;											\
-(p7)	mov r18=3Dar.bsp;										\
-(p7)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=3D0=
 */		\
+(pUser)	mov r18=3Dar.bsp;										\
+(pUser)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
=20
 #define MINSTATE_END_SAVE_MIN_VIRT								\
 	or r13=3Dr13,r14;		/* make `current' a kernel virtual address */			\
@@ -55,20 +55,20 @@
  */
 #define MINSTATE_START_SAVE_MIN_PHYS								\
 (pKern) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
-(p7)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, load=
rs=3D0 */	\
-(p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register backing=
 store */	\
+(pUser)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, l=
oadrs=3D0 */	\
+(pUser)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register back=
ing store */	\
 	;;											\
-(p7)	mov rARRNAT=3Dar.rnat;									\
+(pUser)	mov rARRNAT=3Dar.rnat;									\
 (pKern) dep r1=3D0,sp,61,3;				/* compute physical addr of sp	*/	\
-(p7)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of me=
mory stack */	\
-(p7)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
-(p7)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS */\
+(pUser)	addl r1=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of=
 memory stack */	\
+(pUser)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			\
+(pUser)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS=
 */\
 	;;											\
 (pKern) addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		\
-(p7)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			\
+(pUser)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			\
 	;;											\
-(p7)	mov r18=3Dar.bsp;										\
-(p7)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=3D0=
 */		\
+(pUser)	mov r18=3Dar.bsp;										\
+(pUser)	mov ar.rsc=3D0x3;		/* set eager mode, pl 0, little-endian, loadrs=
=3D0 */		\
=20
 #define MINSTATE_END_SAVE_MIN_PHYS								\
 	or r12=3Dr12,r14;		/* make sp a kernel virtual address */				\
@@ -101,7 +101,7 @@
  *	r12 =3D kernel sp (kernel virtual address)
  *	r13 =3D points to current task_struct (kernel virtual address)
  *	p15 =3D TRUE if psr.i is set in cr.ipsr
- *	predicate registers (other than p6, p7, and p15), b6, r3, r8, r9, r10, =
r11, r14, r15:
+ *	predicate registers (other than p2, p3, and p15), b6, r3, r8, r9, r10, =
r11, r14, r15:
  *		preserved
  *
  * Note that psr.ic is NOT turned on by this macro.  This is so that
@@ -113,15 +113,15 @@
 	mov rR1=3Dr1;										  \
 	mov rARUNAT=3Dar.unat;									  \
 	mov rCRIPSR=3Dcr.ipsr;									  \
-	mov rB6=B6;		/* rB6 =3D branch reg 6 */					  \
+	mov rB6=B6;				/* rB6 =3D branch reg 6 */			  \
 	mov rCRIIP=3Dcr.iip;									  \
-	mov r1=3Dar.k6;		/* r1 =3D current (physical) */					  \
+	mov r1=3DIA64_KR(CURRENT);		/* r1 =3D current (physical) */			  \
 	COVER;											  \
 	;;											  \
 	invala;											  \
 	extr.u r16=3DrCRIPSR,32,2;		/* extract psr.cpl */				  \
 	;;											  \
-	cmp.eq pKern,p7=3Dr0,r16;			/* are we in kernel mode already? (psr.cpl=3D=
0) */ \
+	cmp.eq pKern,pUser=3Dr0,r16;		/* are we in kernel mode already? (psr.cpl=
=3D0) */ \
 	/* switch from user to kernel RBS: */							  \
 	;;											  \
 	SAVE_IFS;										  \
@@ -136,7 +136,7 @@
 	;;											  \
 	st8 [r16]=3DrCRIFS,16;	/* save cr.ifs */						  \
 	st8 [r17]=3DrARUNAT,16;	/* save ar.unat */						  \
-(p7)	sub r18=3Dr18,rKRBS;	/* r18=3DRSE.ndirty*8 */						  \
+(pUser)	sub r18=3Dr18,rKRBS;	/* r18=3DRSE.ndirty*8 */						  \
 	;;											  \
 	st8 [r16]=3DrARPFS,16;	/* save ar.pfs */						  \
 	st8 [r17]=3DrARRSC,16;	/* save ar.rsc */						  \
@@ -144,8 +144,8 @@
 	;;			/* avoid RAW on r16 & r17 */					  \
 (pKern)	adds r16=16,r16;	/* skip over ar_rnat field */					  \
 (pKern)	adds r17=16,r17;	/* skip over ar_bspstore field */				  \
-(p7)	st8 [r16]=3DrARRNAT,16;	/* save ar.rnat */						  \
-(p7)	st8 [r17]=3DrARBSPSTORE,16;	/* save ar.bspstore */					  \
+(pUser)	st8 [r16]=3DrARRNAT,16;	/* save ar.rnat */						  \
+(pUser)	st8 [r17]=3DrARBSPSTORE,16;	/* save ar.bspstore */					  \
 	;;											  \
 	st8 [r16]=3DrARPR,16;	/* save predicates */						  \
 	st8 [r17]=3DrB6,16;	/* save b6 */							  \
@@ -172,7 +172,7 @@
 	;;											  \
 .mem.offset 0,0;		st8.spill [r16]=3Dr10,16;						  \
 .mem.offset 8,0;		st8.spill [r17]=3Dr11,16;						  \
-	mov r13=3Dar.k6;		/* establish `current' */					  \
+	mov r13=3DIA64_KR(CURRENT);	/* establish `current' */				  \
 	;;											  \
 	EXTRA;											  \
 	movl r1=3D__gp;		/* establish kernel global pointer */				  \
diff -urN linux-davidm/arch/ia64/kernel/palinfo.c linux-2.4.1-lia/arch/ia64=
/kernel/palinfo.c
--- linux-davidm/arch/ia64/kernel/palinfo.c	Fri Oct 13 12:05:29 2000
+++ linux-2.4.1-lia/arch/ia64/kernel/palinfo.c	Wed Feb 21 16:10:20 2001
@@ -11,10 +11,7 @@
  *=20
  * 05/26/2000	S.Eranian	initial release
  * 08/21/2000	S.Eranian	updated to July 2000 PAL specs
- *
- * ISSUES:
- *	- as of 2.2.9/2.2.12, the following values are still wrong
- *		PAL_VM_SUMMARY: key & rid sizes
+ * 02/05/2001   S.Eranian	fixed module support
  */
 #include <linux/config.h>
 #include <linux/types.h>
@@ -23,9 +20,6 @@
 #include <linux/proc_fs.h>
 #include <linux/mm.h>
 #include <linux/module.h>
-#if defined(MODVERSIONS)
-#include <linux/modversions.h>
-#endif
=20
 #include <asm/pal.h>
 #include <asm/sal.h>
@@ -39,12 +33,7 @@
 MODULE_AUTHOR("Stephane Eranian <eranian@hpl.hp.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 PAL");
=20
-/*
- * Hope to get rid of this one in a near future
-*/
-#define IA64_PAL_VERSION_BUG		1
-
-#define PALINFO_VERSION "0.3"
+#define PALINFO_VERSION "0.4"
=20
 #ifdef CONFIG_SMP
 #define cpu_is_online(i) (cpu_online_map & (1UL << i))
@@ -571,42 +560,19 @@
 	return p - page;
 }
=20
-
-/*
- * physical mode call for PAL_VERSION is working fine.
- * This function is meant to go away once PAL get fixed.
- */
-static inline s64=20
-ia64_pal_version_phys(pal_version_u_t *pal_min_version, pal_version_u_t *p=
al_cur_version)=20
-{=09
-	struct ia64_pal_retval iprv;
-	PAL_CALL_PHYS(iprv, PAL_VERSION, 0, 0, 0);
-	if (pal_min_version)
-		pal_min_version->pal_version_val =3D iprv.v0;
-	if (pal_cur_version)
-		pal_cur_version->pal_version_val =3D iprv.v1;
-	return iprv.status;=20
-}
-
 static int
 version_info(char *page)
 {
-	s64 status;
 	pal_version_u_t min_ver, cur_ver;
 	char *p =3D page;
=20
-#ifdef IA64_PAL_VERSION_BUG
-	/* The virtual mode call is buggy. But the physical mode call seems
-	 * to be ok. Until they fix virtual mode, we do physical.
+	/* The PAL_VERSION call is advertised as being able to support
+	 * both physical and virtual mode calls. This seems to be a documentation
+	 * bug rather than firmware bug. In fact, it does only support physical m=
ode.=20
+	 * So now the code reflects this fact and the pal_version() has been upda=
ted=20
+	 * accordingly.
 	 */
-	status =3D ia64_pal_version_phys(&min_ver, &cur_ver);
-#else
-	/* The system crashes if you enable this code with the wrong PAL=20
-	 * code
-	 */
-	status =3D ia64_pal_version(&min_ver, &cur_ver);
-#endif
-	if (status !=3D 0) return 0;
+	if (ia64_pal_version(&min_ver, &cur_ver) !=3D 0) return 0;
=20
 	p +=3D sprintf(p, "PAL_vendor : 0x%02x (min=3D0x%02x)\n" \
 			"PAL_A      : %x.%x.%x (min=3D%x.%x.%x)\n" \
@@ -997,9 +963,10 @@
 {
 	int i =3D 0;
=20
-	/* remove all nodes: depth first pass */
+	/* remove all nodes: depth first pass. Could optimize this  */
 	for (i=3D0; i< NR_PALINFO_PROC_ENTRIES ; i++) {
-		remove_proc_entry (palinfo_proc_entries[i]->name, NULL);
+		if (palinfo_proc_entries[i])=20
+			remove_proc_entry (palinfo_proc_entries[i]->name, NULL);
 	}
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.1-lia/arch/ia64/k=
ernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/setup.c	Wed Feb 21 16:10:43 2001
@@ -42,16 +42,20 @@
 # include <linux/blk.h>
 #endif
=20
+#if defined(CONFIG_SMP) && (IA64_CPU_SIZE > PAGE_SIZE)
+# error "struct cpuinfo_ia64 too big!"
+#endif
+
 extern char _end;
=20
 /* cpu_data[0] is data for the bootstrap processor: */
-struct cpuinfo_ia64 cpu_data[NR_CPUS];
+struct cpuinfo_ia64 cpu_data[NR_CPUS] __attribute__ ((section ("__special_=
page_section")));
=20
 unsigned long ia64_cycles_per_usec;
 struct ia64_boot_param ia64_boot_param;
 struct screen_info screen_info;
 /* This tells _start which CPU is booting.  */
-int cpu_now_booting =3D 0;
+int cpu_now_booting;
=20
 #ifdef CONFIG_SMP
 volatile unsigned long cpu_online_map;
@@ -163,7 +167,7 @@
 			       "for initrd, please upgrade the loader\n");
 		else
 #endif
-			/*=20
+			/*
 			 * The loader ONLY passes physical addresses
 			 */
 			initrd_start =3D (unsigned long)__va(initrd_start);
@@ -218,19 +222,19 @@
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
=20
-#ifdef CONFIG_SMP
-	current->processor =3D 0;
-	cpu_physical_id(0) =3D hard_smp_processor_id();
-#endif
 	/*
 	 *  Set `iobase' to the appropriate address in region 6
 	 *    (uncached access range)
 	 */
-	__asm__ ("mov %0=3Dar.k0;;" : "=3Dr"(ia64_iobase));
+	ia64_iobase =3D ia64_get_kr(IA64_KR_IO_BASE);
 	ia64_iobase =3D __IA64_UNCACHED_OFFSET | (ia64_iobase & ~PAGE_OFFSET);
=20
 	cpu_init();	/* initialize the bootstrap CPU */
=20
+#ifdef CONFIG_SMP
+	cpu_physical_id(0) =3D hard_smp_processor_id();
+#endif
+
 #ifdef CONFIG_IA64_GENERIC
 	machvec_init(acpi_get_sysname());
 #endif
@@ -239,7 +243,7 @@
 	if (efi.acpi20) {
 		/* Parse the ACPI 2.0 tables */
 		acpi20_parse(efi.acpi20);
-	} else=20
+	} else
 #endif
 	if (efi.acpi) {
 		/* Parse the ACPI tables */
@@ -325,7 +329,7 @@
 			     c->ppn, c->number, c->proc_freq / 1000000, c->proc_freq % 1000000,
 			     c->itc_freq / 1000000, c->itc_freq % 1000000,
 			     lpj*HZ/500000, (lpj*HZ/5000) % 100);
-        }
+	}
 	return p - buffer;
 }
=20
@@ -362,8 +366,6 @@
 	for (i =3D 0; i < 5; ++i)
 		cpuid.bits[i] =3D ia64_get_cpuid(i);
=20
-	memset(c, 0, sizeof(struct cpuinfo_ia64));
-
 	memcpy(c->vendor, cpuid.field.vendor, 16);
 	c->ppn =3D cpuid.field.ppn;
 	c->number =3D cpuid.field.number;
@@ -382,12 +384,6 @@
 	       smp_processor_id(), impl_va_msb + 1, phys_addr_size);
 	c->unimpl_va_mask =3D ~((7L<<61) | ((1L << (impl_va_msb + 1)) - 1));
 	c->unimpl_pa_mask =3D ~((1L<<63) | ((1L << phys_addr_size) - 1));
-
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-	/* BUG: SoftSDV doesn't support the cpuid registers. */
-	if (c->vendor[0] =3D '\0')=20
-		memcpy(c->vendor, "Intel", 6);
-#endif
 }
=20
 /*
@@ -397,13 +393,11 @@
 void
 cpu_init (void)
 {
-	extern void __init ia64_rid_init (void);
-	extern void __init ia64_tlb_init (void);
+	extern void __init ia64_mmu_init (void);
+	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
=20
-	identify_cpu(&my_cpu_data);
-
 	/* Clear the stack memory reserved for pt_regs: */
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
=20
@@ -415,14 +409,15 @@
 	ia64_set_dcr(  IA64_DCR_DM | IA64_DCR_DP | IA64_DCR_DK | IA64_DCR_DX | IA=
64_DCR_DR
 		     | IA64_DCR_DA | IA64_DCR_DD);
 #ifndef CONFIG_SMP
-	ia64_set_fpu_owner(0);		/* initialize ar.k5 */
+	ia64_set_fpu_owner(0);
 #endif
=20
 	atomic_inc(&init_mm.mm_count);
 	current->active_mm =3D &init_mm;
=20
-	ia64_rid_init();
-	ia64_tlb_init();
+	ia64_mmu_init();
+
+	identify_cpu(current_cpu_data);
=20
 #ifdef	CONFIG_IA32_SUPPORT
 	/* initialize global ia32 state - CR0 and CR4 */
@@ -448,7 +443,7 @@
 	if (ia64_pal_vm_summary(NULL, &vmi) =3D 0)
 		max_ctx =3D (1U << (vmi.pal_vm_info_2_s.rid_size - 3)) - 1;
 	else {
-		printk("ia64_rid_init: PAL VM summary failed, assuming 18 RID bits\n");
+		printk("cpu_init: PAL VM summary failed, assuming 18 RID bits\n");
 		max_ctx =3D (1U << 15) - 1;	/* use architected minimum */
 	}
 	while (max_ctx < ia64_ctx.max_ctx) {
@@ -456,4 +451,10 @@
 		if (cmpxchg(&ia64_ctx.max_ctx, old, max_ctx) =3D old)
 			break;
 	}
+
+	if (ia64_pal_rse_info(&num_phys_stacked, 0) !=3D 0) {
+		printk ("cpu_init: PAL RSE info failed, assuming 96 physical stacked reg=
s\n");
+		num_phys_stacked =3D 96;
+	}
+	current_cpu_data->phys_stacked_size_p8 =3D num_phys_stacked*8 + 8;
 }
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.4.1-lia/arch/ia64/=
kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/signal.c	Wed Feb 21 16:11:12 2001
@@ -1,8 +1,8 @@
 /*
  * Architecture-specific signal handling support.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Derived from i386 and Alpha versions.
  */
@@ -216,19 +216,17 @@
 	sc =3D &((struct sigframe *) (scr->pt.r12 + 16))->sc;
=20
 	/*
-	 * When we return to the previously executing context, r8 and
-	 * r10 have already been setup the way we want them.  Indeed,
-	 * if the signal wasn't delivered while in a system call, we
-	 * must not touch r8 or r10 as otherwise user-level stat could
-	 * be corrupted.
+	 * When we return to the previously executing context, r8 and r10 have al=
ready
+	 * been setup the way we want them.  Indeed, if the signal wasn't deliver=
ed while
+	 * in a system call, we must not touch r8 or r10 as otherwise user-level =
state
+	 * could be corrupted.
 	 */
 	retval =3D (long) &ia64_leave_kernel;
 	if (current->ptrace & PT_TRACESYS)
 		/*
-		 * strace expects to be notified after sigreturn
-		 * returns even though the context to which we return
-		 * may not be in the middle of a syscall.  Thus, the
-		 * return-value that strace displays for sigreturn is
+		 * strace expects to be notified after sigreturn returns even though the
+		 * context to which we return may not be in the middle of a syscall.
+		 * Thus, the return-value that strace displays for sigreturn is
 		 * meaningless.
 		 */
 		retval =3D (long) &ia64_strace_leave_kernel;
@@ -441,13 +439,8 @@
 }
=20
 /*
- * Note that `init' is a special process: it doesn't get signals it
- * doesn't want to handle.  Thus you cannot kill init even with a
- * SIGKILL even by mistake.
- *
- * Note that we go through the signals twice: once to check the
- * signals that the kernel can handle, and then we build all the
- * user-level signal handling stack-frames in one go after that.
+ * Note that `init' is a special process: it doesn't get signals it doesn'=
t want to
+ * handle.  Thus you cannot kill init even with a SIGKILL even by mistake.
  */
 long
 ia64_do_signal (sigset_t *oldset, struct sigscratch *scr, long in_syscall)
@@ -458,9 +451,9 @@
 	long errno =3D scr->pt.r8;
=20
 	/*
-	 * In the ia64_leave_kernel code path, we want the common case
-	 * to go fast, which is why we may in certain cases get here
-	 * from kernel mode. Just return without doing anything if so.
+	 * In the ia64_leave_kernel code path, we want the common case to go fast=
, which
+	 * is why we may in certain cases get here from kernel mode. Just return =
without
+	 * doing anything if so.
 	 */
 	if (!user_mode(&scr->pt))
 		return 0;
@@ -480,11 +473,10 @@
 #endif
 	if (scr->pt.r10 !=3D -1) {
 		/*
-		 * A system calls has to be restarted only if one of
-		 * the error codes ERESTARTNOHAND, ERESTARTSYS, or
-		 * ERESTARTNOINTR is returned.  If r10 isn't -1 then
-		 * r8 doesn't hold an error code and we don't need to
-		 * restart the syscall, so we set in_syscall to zero.
+		 * A system calls has to be restarted only if one of the error codes
+		 * ERESTARTNOHAND, ERESTARTSYS, or ERESTARTNOINTR is returned.  If r10
+		 * isn't -1 then r8 doesn't hold an error code and we don't need to
+		 * restart the syscall, so we can clear the "restart" flag here.
 		 */
 		restart =3D 0;
 	}
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.1-lia/arch/ia64/ker=
nel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/smp.c	Wed Feb 21 16:12:15 2001
@@ -2,8 +2,8 @@
  * SMP Support
  *
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- *=20
+ * Copyright (C) 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
  * Lots of stuff stolen from arch/alpha/kernel/smp.c
  *
  *  00/09/11 David Mosberger <davidm@hpl.hp.com> Do loops_per_jiffy calibr=
ation on each CPU.
@@ -37,8 +37,8 @@
 #include <asm/io.h>
 #include <asm/irq.h>
 #include <asm/page.h>
-#include <asm/pgtable.h>
 #include <asm/pgalloc.h>
+#include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/ptrace.h>
 #include <asm/sal.h>
@@ -50,9 +50,8 @@
 extern void machine_halt(void);
 extern void start_ap(void);
=20
-extern int cpu_now_booting;			     /* Used by head.S to find idle task */
-extern volatile unsigned long cpu_online_map;	     /* Bitmap of available =
cpu's */
-extern struct cpuinfo_ia64 cpu_data[NR_CPUS];	     /* Duh... */
+extern int cpu_now_booting;			/* used by head.S to find idle task */
+extern volatile unsigned long cpu_online_map;	/* bitmap of available cpu's=
 */
=20
 struct smp_boot_data smp_boot_data __initdata;
=20
@@ -60,16 +59,18 @@
=20
 char __initdata no_int_routing;
=20
+/* don't make this a CPU-local variable: it's used for IPIs, mostly...  */
+int __cpu_physical_id[NR_CPUS];			/* logical ID -> physical CPU ID map */
+
 unsigned char smp_int_redirect;			/* are INT and IPI redirectable by the c=
hipset? */
-volatile int __cpu_physical_id[NR_CPUS] =3D { -1, };    /* Logical ID -> S=
APIC ID */
-int smp_num_cpus =3D 1;	=09
-volatile int smp_threads_ready;			     /* Set when the idlers are all fork=
ed */
-unsigned long ap_wakeup_vector =3D -1;		     /* External Int to use to wak=
eup AP's */
+int smp_num_cpus =3D 1;
+volatile int smp_threads_ready;			/* set when the idlers are all forked */
+unsigned long ap_wakeup_vector;			/* external Int to use to wakeup AP's */
=20
 static volatile unsigned long cpu_callin_map;
 static volatile int smp_commenced;
=20
-static int max_cpus =3D -1;			     /* Command line */
+static int max_cpus =3D -1;			/* command line */
=20
 struct smp_call_struct {
 	void (*func) (void *info);
@@ -98,7 +99,8 @@
  *	SMP mode to <NUM>.
  */
=20
-static int __init nosmp(char *str)
+static int __init
+nosmp (char *str)
 {
 	max_cpus =3D 0;
 	return 1;
@@ -106,7 +108,8 @@
=20
 __setup("nosmp", nosmp);
=20
-static int __init maxcpus(char *str)
+static int __init
+maxcpus (char *str)
 {
 	get_option(&str, &max_cpus);
 	return 1;
@@ -115,7 +118,7 @@
 __setup("maxcpus=3D", maxcpus);
=20
 static int __init
-nointroute(char *str)
+nointroute (char *str)
 {
 	no_int_routing =3D 1;
 	return 1;
@@ -124,21 +127,20 @@
 __setup("nointroute", nointroute);
=20
 /*
- * Yoink this CPU from the runnable list...=20
+ * Yoink this CPU from the runnable list...
  */
 void
-halt_processor(void)=20
+halt_processor (void)
 {
-        clear_bit(smp_processor_id(), &cpu_online_map);
+	clear_bit(smp_processor_id(), &cpu_online_map);
 	max_xtp();
 	__cli();
-        for (;;)
+	for (;;)
 		;
-
 }
=20
 static inline int
-pointer_lock(void *lock, void *data, int retry)
+pointer_lock (void *lock, void *data, int retry)
 {
 	volatile long *ptr =3D lock;
  again:
@@ -155,14 +157,13 @@
 }
=20
 void
-handle_IPI(int irq, void *dev_id, struct pt_regs *regs)=20
+handle_IPI (int irq, void *dev_id, struct pt_regs *regs)
 {
-	int this_cpu =3D smp_processor_id();
-	unsigned long *pending_ipis =3D &cpu_data[this_cpu].ipi_operation;
+	unsigned long *pending_ipis =3D &current_cpu_data->ipi_operation;
 	unsigned long ops;
=20
 	/* Count this now; we may make a call that never returns. */
-	cpu_data[this_cpu].ipi_count++;
+	current_cpu_data->ipi_count++;
=20
 	mb();	/* Order interrupt and bit testing. */
 	while ((ops =3D xchg(pending_ipis, 0)) !=3D 0) {
@@ -172,16 +173,16 @@
=20
 		which =3D ffz(~ops);
 		ops &=3D ~(1 << which);
-	=09
+
 		switch (which) {
 		case IPI_RESCHEDULE:
-			/*=20
-			 * Reschedule callback.  Everything to be done is done by the=20
-			 * interrupt return path. =20
+			/*
+			 * Reschedule callback.  Everything to be done is done by the
+			 * interrupt return path.
 			 */
 			break;
-		=09
-		case IPI_CALL_FUNC:=20
+
+		case IPI_CALL_FUNC:
 			{
 				struct smp_call_struct *data;
 				void (*func)(void *info);
@@ -202,7 +203,7 @@
=20
 				/* Notify the sending CPU that the task is done.  */
 				mb();
-				if (wait)=20
+				if (wait)
 					atomic_dec(&data->unfinished_count);
 			}
 			break;
@@ -213,7 +214,7 @@
=20
 #ifndef CONFIG_ITANIUM_PTCG
 		case IPI_FLUSH_TLB:
-                {
+		{
 			extern unsigned long flush_start, flush_end, flush_nbits, flush_rid;
 			extern atomic_t flush_cpu_count;
 			unsigned long saved_rid =3D ia64_get_rr(flush_start);
@@ -222,6 +223,8 @@
 			unsigned long nbits =3D flush_nbits;
=20
 			/*
+			 * Current CPU may be running with different RID so we need to
+			 * reload the RID of flushed address.
 			 * Current CPU may be running with different
 			 * RID so we need to reload the RID of flushed
 			 * address.  Purging the translation also
@@ -234,7 +237,7 @@
 				ia64_set_rr(flush_start, flush_rid);
 				ia64_srlz_d();
 			}
-		=09
+
 			do {
 				/*
 				 * Purge local TLB entries.
@@ -257,7 +260,8 @@
 #endif	/* !CONFIG_ITANIUM_PTCG */
=20
 		default:
-			printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n", this_cpu, which);
+			printk(KERN_CRIT "Unknown IPI on CPU %d: %lu\n",
+			       smp_processor_id(), which);
 			break;
 		} /* Switch */
 	  } while (ops);
@@ -267,21 +271,21 @@
 }
=20
 static inline void
-send_IPI_single (int dest_cpu, int op)=20
+send_IPI_single (int dest_cpu, int op)
 {
-=09
-	if (dest_cpu =3D -1)=20
-                return;
-       =20
+
+	if (dest_cpu =3D -1)
+		return;
+
 	set_bit(op, &cpu_data[dest_cpu].ipi_operation);
 	platform_send_ipi(dest_cpu, IPI_IRQ, IA64_IPI_DM_INT, 0);
 }
=20
 static inline void
-send_IPI_allbutself(int op)
+send_IPI_allbutself (int op)
 {
 	int i;
-=09
+
 	for (i =3D 0; i < smp_num_cpus; i++) {
 		if (i !=3D smp_processor_id())
 			send_IPI_single(i, op);
@@ -289,7 +293,7 @@
 }
=20
 static inline void
-send_IPI_all(int op)
+send_IPI_all (int op)
 {
 	int i;
=20
@@ -298,30 +302,30 @@
 }
=20
 static inline void
-send_IPI_self(int op)
+send_IPI_self (int op)
 {
 	send_IPI_single(smp_processor_id(), op);
 }
=20
 void
-smp_send_reschedule(int cpu)
+smp_send_reschedule (int cpu)
 {
 	send_IPI_single(cpu, IPI_RESCHEDULE);
 }
=20
 void
-smp_send_stop(void)
+smp_send_stop (void)
 {
 	send_IPI_allbutself(IPI_CPU_STOP);
 }
=20
 #ifndef CONFIG_ITANIUM_PTCG
 void
-smp_send_flush_tlb(void)
+smp_send_flush_tlb (void)
 {
 	send_IPI_allbutself(IPI_FLUSH_TLB);
 }
-#endif	/* !CONFIG_ITANIUM_PTCG */
+#endif /* !CONFIG_ITANIUM_PTCG */
=20
 /*
  * Run a function on another CPU
@@ -346,7 +350,7 @@
 		printk(__FUNCTION__" trying to call self\n");
 		return -EBUSY;
 	}
-=09
+
 	data.func =3D func;
 	data.info =3D info;
 	data.wait =3D wait;
@@ -391,7 +395,6 @@
  * Does not return until remote CPUs are nearly ready to execute <func>
  * or are or have executed.
  */
-
 int
 smp_call_function (void (*func) (void *info), void *info, int retry, int w=
ait)
 {
@@ -401,7 +404,7 @@
=20
 	if (cpus =3D 0)
 		return 0;
-=09
+
 	data.func =3D func;
 	data.info =3D info;
 	data.wait =3D wait;
@@ -445,7 +448,7 @@
  * want to ensure all TLB's flushed before proceeding.
  */
 void
-smp_flush_tlb_all(void)
+smp_flush_tlb_all (void)
 {
 	smp_call_function((void (*)(void *))__flush_tlb_all, NULL, 1, 1);
 	__flush_tlb_all();
@@ -455,21 +458,19 @@
  * Ideally sets up per-cpu profiling hooks.  Doesn't do much now...
  */
 static inline void __init
-smp_setup_percpu_timer(int cpuid)
+smp_setup_percpu_timer(void)
 {
-        cpu_data[cpuid].prof_counter =3D 1;
-        cpu_data[cpuid].prof_multiplier =3D 1;
+	current_cpu_data->prof_counter =3D 1;
+	current_cpu_data->prof_multiplier =3D 1;
 }
=20
-void=20
-smp_do_timer(struct pt_regs *regs)
+void
+smp_do_timer (struct pt_regs *regs)
 {
-        int cpu =3D smp_processor_id();
-        int user =3D user_mode(regs);
-	struct cpuinfo_ia64 *data =3D &cpu_data[cpu];
+	int user =3D user_mode(regs);
=20
-        if (--data->prof_counter <=3D 0) {
-		data->prof_counter =3D data->prof_multiplier;
+	if (--current_cpu_data->prof_counter <=3D 0) {
+		current_cpu_data->prof_counter =3D current_cpu_data->prof_multiplier;
 		update_process_times(user);
 	}
 }
@@ -479,7 +480,7 @@
  * AP's start using C here.
  */
 void __init
-smp_callin (void)=20
+smp_callin (void)
 {
 	extern void ia64_rid_init(void);
 	extern void ia64_init_itm(void);
@@ -492,12 +493,12 @@
 	if (test_and_set_bit(cpu, &cpu_online_map)) {
 		printk("CPU#%d already initialized!\n", cpu);
 		machine_halt();
-	} =20
+	}
=20
 	efi_map_pal_code();
 	cpu_init();
=20
-	smp_setup_percpu_timer(cpu);
+	smp_setup_percpu_timer();
=20
 	/* setup the CPU local timer tick */
 	ia64_init_itm();
@@ -509,7 +510,7 @@
 	local_irq_enable();		/* Interrupts have been off until now */
=20
 	calibrate_delay();
-	my_cpu_data.loops_per_jiffy =3D loops_per_jiffy;
+	current_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
=20
 	/* allow the master to continue */
 	set_bit(cpu, &cpu_callin_map);
@@ -526,8 +527,8 @@
  * path in which case the new idle task could get scheduled before we
  * had a chance to remove it from the run-queue...
  */
-static int __init=20
-fork_by_hand(void)
+static int __init
+fork_by_hand (void)
 {
 	/*
 	 * Don't care about the usp and regs settings since we'll never
@@ -540,22 +541,22 @@
  * Bring one cpu online.  Return 0 if this fails for any reason.
  */
 static int __init
-smp_boot_one_cpu(int cpu)
+smp_boot_one_cpu (int cpu)
 {
 	struct task_struct *idle;
 	int cpu_phys_id =3D cpu_physical_id(cpu);
 	long timeout;
=20
-	/*=20
+	/*
 	 * Create an idle task for this CPU.  Note that the address we
 	 * give to kernel_thread is irrelevant -- it's going to start
 	 * where OS_BOOT_RENDEVZ vector in SAL says to start.  But
 	 * this gets all the other task-y sort of data structures set
-	 * up like we wish.   We need to pull the just created idle task=20
-	 * off the run queue and stuff it into the init_tasks[] array. =20
+	 * up like we wish.   We need to pull the just created idle task
+	 * off the run queue and stuff it into the init_tasks[] array.
 	 * Sheesh . . .
 	 */
-	if (fork_by_hand() < 0)=20
+	if (fork_by_hand() < 0)
 		panic("failed fork for CPU 0x%x", cpu_phys_id);
 	/*
 	 * We remove it from the pidhash and the runqueue
@@ -566,7 +567,7 @@
 		panic("No idle process for CPU 0x%x", cpu_phys_id);
 	init_tasks[cpu] =3D idle;
 	del_from_runqueue(idle);
-        unhash_process(idle);
+	unhash_process(idle);
=20
 	/* Schedule the first task manually.  */
 	idle->processor =3D cpu;
@@ -585,49 +586,41 @@
 		udelay(100);
 	}
=20
-	printk(KERN_ERR "SMP: Processor 0x%x is stuck.\n", cpu_phys_id);
+	printk(KERN_ERR "SMP: CPU 0x%x is stuck\n", cpu_phys_id);
 	return 0;
 }
=20
=20
=20
 /*
- * Called by smp_init bring all the secondaries online and hold them. =20
- * XXX: this is ACPI specific; it uses "magic" variables exported from acp=
i.c=20
- *      to 'discover' the AP's.  Blech.
+ * Called by smp_init bring all the secondaries online and hold them.
  */
 void __init
-smp_boot_cpus(void)
+smp_boot_cpus (void)
 {
 	int i, cpu_count =3D 1;
 	unsigned long bogosum;
=20
-	/* Take care of some initial bookkeeping.  */
-	memset(&__cpu_physical_id, -1, sizeof(__cpu_physical_id));
-
-	/* Setup BP mappings */
-	__cpu_physical_id[0] =3D hard_smp_processor_id();
-
 	/* on the BP, the kernel already called calibrate_delay_loop() in init/ma=
in.c */
-	my_cpu_data.loops_per_jiffy =3D loops_per_jiffy;
+	current_cpu_data->loops_per_jiffy =3D loops_per_jiffy;
 #if 0
 	smp_tune_scheduling();
 #endif
- 	smp_setup_percpu_timer(0);
+	smp_setup_percpu_timer();
=20
 	if (test_and_set_bit(0, &cpu_online_map)) {
 		printk("CPU#%d already initialized!\n", smp_processor_id());
 		machine_halt();
-	} =20
+	}
 	init_idle();
=20
 	/* Nothing to do when told not to.  */
 	if (max_cpus =3D 0) {
-	        printk(KERN_INFO "SMP mode deactivated.\n");
+		printk(KERN_INFO "SMP mode deactivated.\n");
 		return;
 	}
=20
-	if (max_cpus !=3D -1)=20
+	if (max_cpus !=3D -1)
 		printk("Limiting CPUs to %d\n", max_cpus);
=20
 	if (smp_boot_data.cpu_count > 1) {
@@ -644,7 +637,7 @@
 				continue;	/* failed */
=20
 			cpu_count++; /* Count good CPUs only... */
-			/*=20
+			/*
 			 * Bail if we've started as many CPUS as we've been told to.
 			 */
 			if (cpu_count =3D max_cpus)
@@ -657,10 +650,10 @@
 	}
=20
 	bogosum =3D 0;
-        for (i =3D 0; i < NR_CPUS; i++) {
+	for (i =3D 0; i < NR_CPUS; i++) {
 		if (cpu_online_map & (1L << i))
 			bogosum +=3D cpu_data[i].loops_per_jiffy;
-        }
+	}
=20
 	printk(KERN_INFO "SMP: Total of %d processors activated (%lu.%02lu BogoMI=
PS).\n",
 	       cpu_count, bogosum*HZ/500000, (bogosum*HZ/5000) % 100);
@@ -668,19 +661,19 @@
 	smp_num_cpus =3D cpu_count;
 }
=20
-/*=20
+/*
  * Called when the BP is just about to fire off init.
  */
-void __init=20
-smp_commence(void)
+void __init
+smp_commence (void)
 {
 	smp_commenced =3D 1;
 }
=20
 int __init
-setup_profiling_timer(unsigned int multiplier)
+setup_profiling_timer (unsigned int multiplier)
 {
-        return -EINVAL;
+	return -EINVAL;
 }
=20
 /*
@@ -692,7 +685,7 @@
  * This also registers the AP OS_MC_REDVEZ address with SAL.
  */
 void __init
-init_smp_config(void)
+init_smp_config (void)
 {
 	struct fptr {
 		unsigned long fp;
@@ -702,14 +695,13 @@
=20
 	/* Tell SAL where to drop the AP's.  */
 	ap_startup =3D (struct fptr *) start_ap;
-	sal_ret =3D ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ,
-				       __pa(ap_startup->fp), __pa(ap_startup->gp), 0,=20
-				       0, 0, 0);
+	sal_ret =3D ia64_sal_set_vectors(SAL_VECTOR_OS_BOOT_RENDEZ, __pa(ap_start=
up->fp),
+				       __pa(ap_startup->gp), 0, 0, 0, 0);
 	if (sal_ret < 0) {
 		printk("SMP: Can't set SAL AP Boot Rendezvous: %s\n", ia64_sal_strerror(=
sal_ret));
 		printk("     Forcing UP mode\n");
 		max_cpus =3D 0;
-		smp_num_cpus =3D 1;=20
+		smp_num_cpus =3D 1;
 	}
=20
 }
diff -urN linux-davidm/arch/ia64/kernel/smpboot.c linux-2.4.1-lia/arch/ia64=
/kernel/smpboot.c
--- linux-davidm/arch/ia64/kernel/smpboot.c	Fri Oct 13 12:05:29 2000
+++ linux-2.4.1-lia/arch/ia64/kernel/smpboot.c	Wed Feb 21 16:12:27 2001
@@ -1,34 +1,14 @@
 /*
- * SMP Support
- *
  * Application processor startup code, moved from smp.c to better support =
kernel profile
+ *
+ * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
+ * Copyright (C) 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000 Asit Mallick <Asit.K.Mallick@intel.com>
  */
=20
-#include <linux/kernel.h>
-#include <linux/sched.h>
-#include <linux/init.h>
-#include <linux/interrupt.h>
-#include <linux/smp.h>
-#include <linux/kernel_stat.h>
-#include <linux/mm.h>
-#include <linux/delay.h>
-
-#include <asm/atomic.h>
-#include <asm/bitops.h>
-#include <asm/current.h>
-#include <asm/delay.h>
-#include <asm/efi.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/page.h>
+#include <asm/kregs.h>
 #include <asm/pgtable.h>
-#include <asm/pgalloc.h>
 #include <asm/processor.h>
-#include <asm/ptrace.h>
-#include <asm/sal.h>
-#include <asm/system.h>
-#include <asm/unistd.h>
=20
 /*=20
  * SAL shoves the AP's here when we start them.  Physical mode, no kernel =
TR,=20
@@ -38,20 +18,18 @@
  * Stolen from lilo_start.c.  Thanks David!=20
  */
 void
-start_ap(void)
+start_ap (void)
 {
 	extern void _start (void);
 	unsigned long flags;
=20
 	/*
-	 * Install a translation register that identity maps the
-	 * kernel's 256MB page(s).
+	 * Install a translation register that identity maps the kernel's 256MB p=
age(s).
 	 */
 	ia64_clear_ic(flags);
-	ia64_set_rr(          0, (0x1000 << 8) | (_PAGE_SIZE_1M << 2));
 	ia64_set_rr(PAGE_OFFSET, (ia64_rid(0, PAGE_OFFSET) << 8) | (_PAGE_SIZE_25=
6M << 2));
 	ia64_srlz_d();
-	ia64_itr(0x3, 1, PAGE_OFFSET,
+	ia64_itr(0x3, IA64_TR_KERNEL, PAGE_OFFSET,
 		 pte_val(mk_pte_phys(0, __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RWX))),
 		 _PAGE_SIZE_256M);
 	ia64_srlz_i();
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.1-lia/arch/ia64/ke=
rnel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/time.c	Wed Feb 21 16:13:17 2001
@@ -53,7 +53,7 @@
 			ip =3D prof_len - 1;
=20
 		atomic_inc((atomic_t *) &prof_buffer[ip]);
-	}=20
+	}
 }
=20
 /*
@@ -74,7 +74,7 @@
 	unsigned long now =3D ia64_get_itc(), last_tick;
 	unsigned long elapsed_cycles, lost =3D jiffies - wall_jiffies;
=20
-	last_tick =3D (my_cpu_data.itm_next - (lost+1)*my_cpu_data.itm_delta);
+	last_tick =3D (current_cpu_data->itm_next - (lost+1)*current_cpu_data->it=
m_delta);
 # if 1
 	if ((long) (now - last_tick) < 0) {
 		printk("Yikes: now < last_tick (now=3D0x%lx,last_tick=3D%lx)!  No can do=
.\n",
@@ -83,7 +83,7 @@
 	}
 # endif
 	elapsed_cycles =3D now - last_tick;
-	return (elapsed_cycles*my_cpu_data.usec_per_cyc) >> IA64_USEC_PER_CYC_SHI=
FT;
+	return (elapsed_cycles*current_cpu_data->usec_per_cyc) >> IA64_USEC_PER_C=
YC_SHIFT;
 #endif
 }
=20
@@ -124,7 +124,7 @@
 	read_lock_irqsave(&xtime_lock, flags);
 	{
 		usec =3D gettimeoffset();
-=09
+
 		sec =3D xtime.tv_sec;
 		usec +=3D xtime.tv_usec;
 	}
@@ -142,10 +142,9 @@
 static void
 timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
-	int cpu =3D smp_processor_id();
 	unsigned long new_itm;
=20
-	new_itm =3D cpu_data[cpu].itm_next;
+	new_itm =3D current_cpu_data->itm_next;
=20
 	if (!time_after(ia64_get_itc(), new_itm))
 		printk("Oops: timer tick before it's due (itc=3D%lx,itm=3D%lx)\n",
@@ -157,7 +156,7 @@
 		 * four so that we can use a prof_shift of 2 to get instruction-level
 		 * instead of just bundle-level accuracy.
 		 */
-		if (!user_mode(regs))=20
+		if (!user_mode(regs))
 			do_profile(regs->cr_iip + 4*ia64_psr(regs)->ri);
=20
 #ifdef CONFIG_SMP
@@ -175,38 +174,27 @@
 			write_unlock(&xtime_lock);
 		}
=20
-		new_itm +=3D cpu_data[cpu].itm_delta;
-		cpu_data[cpu].itm_next =3D new_itm;
+		new_itm +=3D current_cpu_data->itm_delta;
+		current_cpu_data->itm_next =3D new_itm;
 		if (time_after(new_itm, ia64_get_itc()))
 			break;
 	}
=20
-	/*
-	 * If we're too close to the next clock tick for comfort, we
-	 * increase the saftey margin by intentionally dropping the
-	 * next tick(s).  We do NOT update itm.next accordingly
-	 * because that would force us to call do_timer() which in
-	 * turn would let our clock run too fast (with the potentially
-	 * devastating effect of losing monotony of time).
-	 */
-	while (!time_after(new_itm, ia64_get_itc() + cpu_data[cpu].itm_delta/2))
-		new_itm +=3D cpu_data[cpu].itm_delta;
-	ia64_set_itm(new_itm);
+	do {
+	    /*
+	     * If we're too close to the next clock tick for comfort, we increase=
 the
+	     * saftey margin by intentionally dropping the next tick(s).  We do N=
OT update
+	     * itm.next because that would force us to call do_timer() which in t=
urn would
+	     * let our clock run too fast (with the potentially devastating effec=
t of
+	     * losing monotony of time).
+	     */
+	    while (!time_after(new_itm, ia64_get_itc() + current_cpu_data->itm_de=
lta/2))
+	      new_itm +=3D current_cpu_data->itm_delta;
+	    ia64_set_itm(new_itm);
+	    /* double check, in case we got hit by a (slow) PMI: */
+	} while (time_after_eq(ia64_get_itc(), new_itm));
 }
=20
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-
-/*
- * Interrupts must be disabled before calling this routine.
- */
-void
-ia64_reset_itm (void)
-{
-	timer_interrupt(0, 0, ia64_task_regs(current));
-}
-
-#endif
-
 /*
  * Encapsulate access to the itm structure for SMP.
  */
@@ -216,14 +204,10 @@
 	int cpu =3D smp_processor_id();
 	unsigned long shift =3D 0, delta;
=20
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-	ia64_set_itc(0);
-#endif
-
 	/* arrange for the cycle counter to generate a timer interrupt: */
 	ia64_set_itv(TIMER_IRQ);
=20
-	delta =3D cpu_data[cpu].itm_delta;
+	delta =3D current_cpu_data->itm_delta;
 	/*
 	 * Stagger the timer tick for each CPU so they don't occur all at (almost=
) the
 	 * same time:
@@ -232,8 +216,8 @@
 		unsigned long hi =3D 1UL << ia64_fls(cpu);
 		shift =3D (2*(cpu - hi) + 1) * delta/hi/2;
 	}
-	cpu_data[cpu].itm_next =3D ia64_get_itc() + delta + shift;
-	ia64_set_itm(cpu_data[cpu].itm_next);
+	current_cpu_data->itm_next =3D ia64_get_itc() + delta + shift;
+	ia64_set_itm(current_cpu_data->itm_next);
 }
=20
 void __init
@@ -241,7 +225,6 @@
 {
 	unsigned long platform_base_freq, itc_freq, drift;
 	struct pal_freq_ratio itc_ratio, proc_ratio;
-	int cpu =3D smp_processor_id();
 	long status;
=20
 	/*
@@ -264,33 +247,28 @@
 		itc_ratio.num =3D 3;
 		itc_ratio.den =3D 1;
 	}
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-	platform_base_freq =3D 10000000;
-	proc_ratio.num =3D 4; proc_ratio.den =3D 1;
-	itc_ratio.num  =3D 4; itc_ratio.den  =3D 1;
-#else
 	if (platform_base_freq < 40000000) {
 		printk("Platform base frequency %lu bogus---resetting to 75MHz!\n",
 		       platform_base_freq);
 		platform_base_freq =3D 75000000;
 	}
-#endif
 	if (!proc_ratio.den)
-		proc_ratio.num =3D 1;	/* avoid division by zero */
+		proc_ratio.den =3D 1;	/* avoid division by zero */
 	if (!itc_ratio.den)
-		itc_ratio.num =3D 1;	/* avoid division by zero */
+		itc_ratio.den =3D 1;	/* avoid division by zero */
=20
-        itc_freq =3D (platform_base_freq*itc_ratio.num)/itc_ratio.den;
-        cpu_data[cpu].itm_delta =3D (itc_freq + HZ/2) / HZ;
-        printk("CPU %d: base freq=3D%lu.%03luMHz, ITC ratio=3D%lu/%lu, ITC=
 freq=3D%lu.%03luMHz\n",
+	itc_freq =3D (platform_base_freq*itc_ratio.num)/itc_ratio.den;
+	current_cpu_data->itm_delta =3D (itc_freq + HZ/2) / HZ;
+	printk("CPU %d: base freq=3D%lu.%03luMHz, ITC ratio=3D%lu/%lu, ITC freq=
=3D%lu.%03luMHz\n",
 	       smp_processor_id(),
 	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
-               itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq=
 / 1000) % 1000);
+	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000=
) % 1000);
=20
-	cpu_data[cpu].proc_freq =3D (platform_base_freq*proc_ratio.num)/proc_rati=
o.den;
-	cpu_data[cpu].itc_freq =3D itc_freq;
-	cpu_data[cpu].cyc_per_usec =3D (itc_freq + 500000) / 1000000;
-	cpu_data[cpu].usec_per_cyc =3D ((1000000UL<<IA64_USEC_PER_CYC_SHIFT) + it=
c_freq/2)/itc_freq;
+	current_cpu_data->proc_freq =3D (platform_base_freq*proc_ratio.num)/proc_=
ratio.den;
+	current_cpu_data->itc_freq =3D itc_freq;
+	current_cpu_data->cyc_per_usec =3D (itc_freq + 500000) / 1000000;
+	current_cpu_data->usec_per_cyc =3D ((1000000UL<<IA64_USEC_PER_CYC_SHIFT)
+					  + itc_freq/2)/itc_freq;
=20
 	/* Setup the CPU local timer tick */
 	ia64_cpu_local_tick();
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.1-lia/arch/ia64/k=
ernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/traps.c	Wed Feb 21 16:41:17 2001
@@ -7,8 +7,6 @@
  * 05/12/00 grao <goutham.rao@intel.com> : added isr in siginfo for SIGFPE
  */
=20
-#define FPSWA_DEBUG	1
-
 /*
  * The fpu_fault() handler needs to be able to access and update all
  * floating point registers.  Those saved in pt_regs can be accessed
@@ -250,7 +248,7 @@
 	memset(&fp_state, 0, sizeof(fp_state_t));
=20
 	/*
-	 * compute fp_state.  only FP registers f6 - f11 are used by the=20
+	 * compute fp_state.  only FP registers f6 - f11 are used by the
 	 * kernel, so set those bits in the mask and set the low volatile
 	 * pointer to point to these registers.
 	 */
@@ -263,15 +261,15 @@
 	f6_15[1] =3D regs->f7;
 	f6_15[2] =3D regs->f8;
 	f6_15[3] =3D regs->f9;
- 	__asm__ ("stf.spill %0=F10%P0" : "=3Dm"(f6_15[4]));
- 	__asm__ ("stf.spill %0=F11%P0" : "=3Dm"(f6_15[5]));
- 	__asm__ ("stf.spill %0=F12%P0" : "=3Dm"(f6_15[6]));
- 	__asm__ ("stf.spill %0=F13%P0" : "=3Dm"(f6_15[7]));
- 	__asm__ ("stf.spill %0=F14%P0" : "=3Dm"(f6_15[8]));
- 	__asm__ ("stf.spill %0=F15%P0" : "=3Dm"(f6_15[9]));
+	__asm__ ("stf.spill %0=F10%P0" : "=3Dm"(f6_15[4]));
+	__asm__ ("stf.spill %0=F11%P0" : "=3Dm"(f6_15[5]));
+	__asm__ ("stf.spill %0=F12%P0" : "=3Dm"(f6_15[6]));
+	__asm__ ("stf.spill %0=F13%P0" : "=3Dm"(f6_15[7]));
+	__asm__ ("stf.spill %0=F14%P0" : "=3Dm"(f6_15[8]));
+	__asm__ ("stf.spill %0=F15%P0" : "=3Dm"(f6_15[9]));
 	fp_state.fp_state_low_volatile =3D (fp_state_low_volatile_t *) f6_15;
 #endif
-        /*
+	/*
 	 * unsigned long (*EFI_FPSWA) (
 	 *      unsigned long    trap_type,
 	 *	void             *Bundle,
@@ -287,12 +285,12 @@
 					(unsigned long *) isr, (unsigned long *) pr,
 					(unsigned long *) ifs, &fp_state);
 #ifdef FPSWA_BUG
- 	__asm__ ("ldf.fill f10=3D%0%P0" :: "m"(f6_15[4]));
- 	__asm__ ("ldf.fill f11=3D%0%P0" :: "m"(f6_15[5]));
- 	__asm__ ("ldf.fill f12=3D%0%P0" :: "m"(f6_15[6]));
- 	__asm__ ("ldf.fill f13=3D%0%P0" :: "m"(f6_15[7]));
- 	__asm__ ("ldf.fill f14=3D%0%P0" :: "m"(f6_15[8]));
- 	__asm__ ("ldf.fill f15=3D%0%P0" :: "m"(f6_15[9]));
+	__asm__ ("ldf.fill f10=3D%0%P0" :: "m"(f6_15[4]));
+	__asm__ ("ldf.fill f11=3D%0%P0" :: "m"(f6_15[5]));
+	__asm__ ("ldf.fill f12=3D%0%P0" :: "m"(f6_15[6]));
+	__asm__ ("ldf.fill f13=3D%0%P0" :: "m"(f6_15[7]));
+	__asm__ ("ldf.fill f14=3D%0%P0" :: "m"(f6_15[8]));
+	__asm__ ("ldf.fill f15=3D%0%P0" :: "m"(f6_15[9]));
 	regs->f6 =3D f6_15[0];
 	regs->f7 =3D f6_15[1];
 	regs->f8 =3D f6_15[2];
@@ -328,11 +326,11 @@
 	}
=20
 	exception =3D fp_emulate(fp_fault, bundle, &regs->cr_ipsr, &regs->ar_fpsr=
, &isr, &regs->pr,
- 			       &regs->cr_ifs, regs);
+			       &regs->cr_ifs, regs);
 	if (fp_fault) {
 		if (exception =3D 0) {
 			/* emulation was successful */
- 			ia64_increment_ip(regs);
+			ia64_increment_ip(regs);
 		} else if (exception =3D -1) {
 			printk("handle_fpu_swa: fp_emulate() returned -1\n");
 			return -1;
@@ -391,7 +389,7 @@
 	struct siginfo si;
 	char buf[128];
=20
-#ifdef CONFIG_IA64_BRL_EMU=09
+#ifdef CONFIG_IA64_BRL_EMU
 	{
 		extern struct illegal_op_return ia64_emulate_brl (struct pt_regs *, unsi=
gned long);
=20
@@ -430,7 +428,7 @@
 		"IA-64 Reserved Register/Field fault",
 		"Disabled Instruction Set Transition fault",
 		"Unknown fault 5", "Unknown fault 6", "Unknown fault 7", "Illegal Hazard=
 fault",
-		"Unknown fault 9", "Unknown fault 10", "Unknown fault 11", "Unknown faul=
t 12",=20
+		"Unknown fault 9", "Unknown fault 10", "Unknown fault 11", "Unknown faul=
t 12",
 		"Unknown fault 13", "Unknown fault 14", "Unknown fault 15"
 	};
=20
@@ -501,7 +499,7 @@
 	      case 35: /* Taken Branch Trap */
 	      case 36: /* Single Step Trap */
 		switch (vector) {
-		      case 29:=20
+		      case 29:
 			siginfo.si_code =3D TRAP_HWBKPT;
 #ifdef CONFIG_ITANIUM
 			/*
@@ -512,7 +510,7 @@
 			  ifa =3D regs->cr_iip;
 #endif
 			siginfo.si_addr =3D (void *) ifa;
-		        break;
+			break;
 		      case 35: siginfo.si_code =3D TRAP_BRANCH; break;
 		      case 36: siginfo.si_code =3D TRAP_TRACE; break;
 		}
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c linux-2.4.1-lia/arch/ia=
64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/unaligned.c	Wed Feb 21 16:13:53 2001
@@ -1293,11 +1293,11 @@
 				      ifa, regs->cr_iip + ipsr->ri);
 			tty_write_message(current->tty, buf);
 			buf[len-1] =3D '\0';	/* drop '\r' */
-			printk("%s", buf);	/* watch for command names containing %s */
+			printk(KERN_WARNING "%s", buf);	/* watch for command names containing %=
s */
 		}
 	} else {
 		if (within_logging_rate_limit())
-			printk("kernel unaligned access to 0x%016lx, ip=3D0x%016lx\n",
+			printk(KERN_WARNING "kernel unaligned access to 0x%016lx, ip=3D0x%016lx=
\n",
 			       ifa, regs->cr_iip + ipsr->ri);
 		set_fs(KERNEL_DS);
 	}
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.1-lia/arch/ia64/=
kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/unwind.c	Wed Feb 21 16:14:01 2001
@@ -1,6 +1,6 @@
 /*
- * Copyright (C) 1999-2000 Hewlett-Packard Co
- * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 /*
  * This file implements call frame unwind support for the Linux
@@ -660,7 +660,7 @@
 	 */
 	if (sr->any_spills) {
 		off =3D sr->spill_offset;
-		alloc_spill_area(&off, 16, sr->curr.reg + UNW_REG_F2, sr->curr.reg + UNW=
_REG_F31);=20
+		alloc_spill_area(&off, 16, sr->curr.reg + UNW_REG_F2, sr->curr.reg + UNW=
_REG_F31);
 		alloc_spill_area(&off,  8, sr->curr.reg + UNW_REG_B1, sr->curr.reg + UNW=
_REG_B5);
 		alloc_spill_area(&off,  8, sr->curr.reg + UNW_REG_R4, sr->curr.reg + UNW=
_REG_R7);
 	}
@@ -911,6 +911,10 @@
 	struct unw_reg_state *rs;
=20
 	rs =3D alloc_reg_state();
+	if (!rs) {
+		printk("unwind: cannot stack!\n");
+		return;
+	}
 	memcpy(rs, &sr->curr, sizeof(*rs));
 	rs->label =3D label;
 	rs->next =3D sr->reg_state_list;
@@ -927,7 +931,7 @@
 	if (sr->when_target <=3D sr->region_start + MIN((int)t, sr->region_len - =
1))
 		return 0;
 	if (qp > 0) {
-		if ((sr->pr_val & (1UL << qp)) =3D 0)=20
+		if ((sr->pr_val & (1UL << qp)) =3D 0)
 			return 0;
 		sr->pr_mask |=3D (1UL << qp);
 	}
@@ -944,7 +948,7 @@
=20
 	r =3D sr->curr.reg + decode_abreg(abreg, 0);
 	r->where =3D UNW_WHERE_NONE;
-	r->when =3D sr->region_start + MIN((int)t, sr->region_len - 1);
+	r->when =3D UNW_WHEN_NEVER;
 	r->val =3D 0;
 }
=20
@@ -1443,12 +1447,17 @@
 		 * sp has been restored and all values on the memory stack below
 		 * psp also have been restored.
 		 */
-		sr.curr.reg[UNW_REG_PSP].where =3D UNW_WHERE_NONE;
 		sr.curr.reg[UNW_REG_PSP].val =3D 0;
+		sr.curr.reg[UNW_REG_PSP].where =3D UNW_WHERE_NONE;
+		sr.curr.reg[UNW_REG_PSP].when =3D UNW_WHEN_NEVER;
 		for (r =3D sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r)
 			if ((r->where =3D UNW_WHERE_PSPREL && r->val <=3D 0x10)
 			    || r->where =3D UNW_WHERE_SPREL)
+			{
+				r->val =3D 0;
 				r->where =3D UNW_WHERE_NONE;
+				r->when =3D UNW_WHEN_NEVER;
+			}
 	}
=20
 	script->flags =3D sr.flags;
@@ -1477,7 +1486,7 @@
 			      case UNW_WHERE_PSPREL: printk("[psp+0x%lx]", r->val); break;
 			      case UNW_WHERE_NONE:
 				printk("%s+0x%lx", unw.preg_name[r - sr.curr.reg], r->val);
-				break;=20
+				break;
 			      default:		     printk("BADWHERE(%d)", r->where); break;
 			}
 			printk("\t\t%d\n", r->when);
@@ -1604,7 +1613,9 @@
=20
 		      case UNW_INSN_LOAD:
 #if UNW_DEBUG
-			if ((s[val] & (my_cpu_data.unimpl_va_mask | 0x7)) || s[val] < TASK_SIZE=
) {
+			if ((s[val] & (current_cpu_data->unimpl_va_mask | 0x7)) !=3D 0
+			    || s[val] < TASK_SIZE)
+			{
 				debug(1, "unwind: rejecting bad psp=3D0x%lx\n", s[val]);
 				break;
 			}
@@ -1636,7 +1647,7 @@
 	int have_write_lock =3D 0;
 	struct unw_script *scr;
=20
-	if ((info->ip & (my_cpu_data.unimpl_va_mask | 0xf)) || info->ip < TASK_SI=
ZE) {
+	if ((info->ip & (current_cpu_data->unimpl_va_mask | 0xf)) || info->ip < T=
ASK_SIZE) {
 		/* don't let obviously bad addresses pollute the cache */
 		debug(1, "unwind: rejecting bad ip=3D0x%lx\n", info->ip);
 		info->rp_loc =3D 0;
@@ -1672,7 +1683,7 @@
 	unsigned long ip, pr, num_regs;
 	STAT(unsigned long start, flags;)
 	int retval;
-=09
+
 	STAT(local_irq_save(flags); ++unw.stat.api.unwinds; start =3D ia64_get_it=
c());
=20
 	prev_ip =3D info->ip;
@@ -1934,7 +1945,7 @@
 		return -1;
=20
 	info->ip =3D read_reg(info, sol - 2, &is_nat);
-	if (is_nat || (info->ip & (my_cpu_data.unimpl_va_mask | 0xf)))
+	if (is_nat || (info->ip & (current_cpu_data->unimpl_va_mask | 0xf)))
 		/* reject let obviously bad addresses */
 		return -1;
=20
@@ -1979,7 +1990,7 @@
 		dprintk("unwind: ignoring attempt to insert empty unwind table\n");
 		return 0;
 	}
-=09
+
 	table =3D kmalloc(sizeof(*table), GFP_USER);
 	if (!table)
 		return 0;
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.1-lia/arch/ia64/mm/ini=
t.c
--- linux-davidm/arch/ia64/mm/init.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/mm/init.c	Wed Feb 21 16:14:18 2001
@@ -125,17 +125,17 @@
 {
 	int freed =3D 0;
=20
-        if (pgtable_cache_size > high) {
-                do {
-                        if (pgd_quicklist)
-                                free_page((unsigned long)get_pgd_fast()), =
++freed;
-                        if (pmd_quicklist)
-                                free_page((unsigned long)get_pmd_fast()), =
++freed;
-                        if (pte_quicklist)
-                                free_page((unsigned long)get_pte_fast()), =
++freed;
-                } while (pgtable_cache_size > low);
-        }
-        return freed;
+	if (pgtable_cache_size > high) {
+		do {
+			if (pgd_quicklist)
+				free_page((unsigned long)get_pgd_fast()), ++freed;
+			if (pmd_quicklist)
+				free_page((unsigned long)get_pmd_fast()), ++freed;
+			if (pte_quicklist)
+				free_page((unsigned long)get_pte_fast()), ++freed;
+		} while (pgtable_cache_size > low);
+	}
+	return freed;
 }
=20
 /*
@@ -191,12 +191,12 @@
 {
 	/*
 	 * EFI uses 4KB pages while the kernel can use 4KB  or bigger.
-	 * Thus EFI and the kernel may have different page sizes. It is=20
-	 * therefore possible to have the initrd share the same page as=20
-	 * the end of the kernel (given current setup).=20
+	 * Thus EFI and the kernel may have different page sizes. It is
+	 * therefore possible to have the initrd share the same page as
+	 * the end of the kernel (given current setup).
 	 *
 	 * To avoid freeing/using the wrong page (kernel sized) we:
-	 * 	- align up the beginning of initrd
+	 *	- align up the beginning of initrd
 	 *	- keep the end untouched
 	 *
 	 *  |             |
@@ -204,8 +204,8 @@
 	 *  |             |
 	 *  |             |
 	 *  |             | 9000
-	 *  |/////////////|=20
-	 *  |/////////////|=20
+	 *  |/////////////|
+	 *  |/////////////|
 	 *  |=3D=3D=3D=3D=3D=3D=3D| 8000
 	 *  |///INITRD////|
 	 *  |/////////////|
@@ -214,9 +214,9 @@
 	 *  |KKKKKKKKKKKKK|
 	 *  |=3D=3D=3D=3D=3D=3D=3D| 6000
 	 *  |KKKKKKKKKKKKK|
-	 *  |KKKKKKKKKKKKK|=20
+	 *  |KKKKKKKKKKKKK|
 	 *  K=3Dkernel using 8KB pages
-	 *=20
+	 *
 	 * In this example, we must free page 8000 ONLY. So we must align up
 	 * initrd_start and keep initrd_end as is.
 	 */
@@ -313,9 +313,10 @@
 }
=20
 void __init
-ia64_rid_init (void)
+ia64_mmu_init (void)
 {
 	unsigned long flags, rid, pta, impl_va_bits;
+	extern void __init tlb_init (void);
 #ifdef CONFIG_DISABLE_VHPT
 #	define VHPT_ENABLE_BIT	0
 #else
@@ -334,7 +335,15 @@
 	rid =3D ia64_rid(IA64_REGION_ID_KERNEL, VMALLOC_START);
 	ia64_set_rr(VMALLOC_START, (rid << 8) | (PAGE_SHIFT << 2) | 1);
=20
+	/* ensure rr6 is up-to-date before inserting the PERCPU_ADDR translation:=
 */
+	ia64_srlz_d();
+
+	ia64_itr(0x2, IA64_TR_PERCPU_DATA, PERCPU_ADDR,
+		 pte_val(mk_pte_phys(__pa(&cpu_data[smp_processor_id()]), PAGE_KERNEL)),
+		 PAGE_SHIFT);
+
 	__restore_flags(flags);
+	ia64_srlz_i();
=20
 	/*
 	 * Check if the virtually mapped linear page table (VMLPT) overlaps with =
a mapped
@@ -359,7 +368,7 @@
 #	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
 #	define POW2(n)			(1ULL << (n))
=20
-	impl_va_bits =3D ffz(~(my_cpu_data.unimpl_va_mask | (7UL << 61)));
+	impl_va_bits =3D ffz(~(current_cpu_data->unimpl_va_mask | (7UL << 61)));
=20
 	if (impl_va_bits < 51 || impl_va_bits > 61)
 		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
@@ -377,6 +386,8 @@
 	 * enabled.
 	 */
 	ia64_set_pta(pta | (0 << 8) | (vmlpt_bits << 2) | VHPT_ENABLE_BIT);
+
+	ia64_tlb_init();
 }
=20
 /*
@@ -393,7 +404,7 @@
=20
 	memset(zones_size, 0, sizeof(zones_size));
=20
-	max_dma =3D virt_to_phys(MAX_DMA_ADDRESS) >> PAGE_SHIFT;
+	max_dma =3D virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	if (max_low_pfn < max_dma)
 		zones_size[ZONE_DMA] =3D max_low_pfn;
 	else {
diff -urN linux-davidm/arch/ia64/mm/tlb.c linux-2.4.1-lia/arch/ia64/mm/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/mm/tlb.c	Wed Feb 21 16:14:46 2001
@@ -1,8 +1,8 @@
 /*
  * TLB support routines.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * 08/02/00 A. Mallick <asit.k.mallick@intel.com>=09
  *		Modified RID allocation for SMP=20
@@ -166,11 +166,11 @@
 {
 	unsigned long i, j, flags, count0, count1, stride0, stride1, addr;
=20
-	addr    =3D my_cpu_data.ptce_base;
-	count0  =3D my_cpu_data.ptce_count[0];
-	count1  =3D my_cpu_data.ptce_count[1];
-	stride0 =3D my_cpu_data.ptce_stride[0];
-	stride1 =3D my_cpu_data.ptce_stride[1];
+	addr    =3D current_cpu_data->ptce_base;
+	count0  =3D current_cpu_data->ptce_count[0];
+	count1  =3D current_cpu_data->ptce_count[1];
+	stride0 =3D current_cpu_data->ptce_stride[0];
+	stride1 =3D current_cpu_data->ptce_stride[1];
=20
 	local_irq_save(flags);
 	for (i =3D 0; i < count0; ++i) {
@@ -249,11 +249,11 @@
 	ia64_ptce_info_t ptce_info;
=20
 	ia64_get_ptce(&ptce_info);
-	my_cpu_data.ptce_base =3D ptce_info.base;
-	my_cpu_data.ptce_count[0] =3D ptce_info.count[0];
-	my_cpu_data.ptce_count[1] =3D ptce_info.count[1];
-	my_cpu_data.ptce_stride[0] =3D ptce_info.stride[0];
-	my_cpu_data.ptce_stride[1] =3D ptce_info.stride[1];
+	current_cpu_data->ptce_base =3D ptce_info.base;
+	current_cpu_data->ptce_count[0] =3D ptce_info.count[0];
+	current_cpu_data->ptce_count[1] =3D ptce_info.count[1];
+	current_cpu_data->ptce_stride[0] =3D ptce_info.stride[0];
+	current_cpu_data->ptce_stride[1] =3D ptce_info.stride[1];
=20
 	__flush_tlb_all();		/* nuke left overs from bootstrapping... */
 }
diff -urN linux-davidm/arch/ia64/tools/print_offsets.awk linux-2.4.1-lia/ar=
ch/ia64/tools/print_offsets.awk
--- linux-davidm/arch/ia64/tools/print_offsets.awk	Fri Jul 14 16:08:12 2000
+++ linux-2.4.1-lia/arch/ia64/tools/print_offsets.awk	Wed Feb 21 16:14:55 2=
001
@@ -28,6 +28,10 @@
 	inside_table =3D 0
 }
=20
+/.*[.]rodata/ {
+	inside_table =3D 0
+}
+
 {
 	if (inside_table) {
 		if ($1 =3D "//") getline;
@@ -61,7 +65,7 @@
 	inside_table =3D 1
 }
=20
-/tab#:/ {
+/tab\#:/ {
 	inside_table =3D 1
 }
=20
diff -urN linux-davidm/arch/ia64/tools/print_offsets.c linux-2.4.1-lia/arch=
/ia64/tools/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/arch/ia64/tools/print_offsets.c	Wed Feb 21 16:15:04 2001
@@ -45,6 +45,7 @@
     { "IA64_PT_REGS_SIZE",		sizeof (struct pt_regs) },
     { "IA64_SWITCH_STACK_SIZE",		sizeof (struct switch_stack) },
     { "IA64_SIGINFO_SIZE",		sizeof (struct siginfo) },
+    { "IA64_CPU_SIZE",			sizeof (struct cpuinfo_ia64) },
 #ifdef CONFIG_IA64_NEW_UNWIND
     { "UNW_FRAME_INFO_SIZE",		sizeof (struct unw_frame_info) },
 #endif
@@ -59,7 +60,7 @@
     { "IA64_TASK_THREAD_SIGMASK_OFFSET",offsetof (struct task_struct, thre=
ad.un.sigmask) },
 #endif
 #ifdef CONFIG_PERFMON
-    { "IA64_TASK_PFM_NOTIFY", offsetof(struct task_struct, thread.pfm_pend=
_notify) },
+    { "IA64_TASK_PFM_NOTIFY_OFFSET",	offsetof(struct task_struct, thread.p=
fm_pend_notify) },
 #endif
     { "IA64_TASK_PID_OFFSET",		offsetof (struct task_struct, pid) },
     { "IA64_TASK_MM_OFFSET",		offsetof (struct task_struct, mm) },
@@ -160,6 +161,11 @@
     { "IA64_SIGCONTEXT_FR6_OFFSET",	offsetof (struct sigcontext, sc_fr[6])=
 },
     { "IA64_CLONE_VFORK",		CLONE_VFORK },
     { "IA64_CLONE_VM",			CLONE_VM },
+    { "IA64_CPU_IRQ_COUNT_OFFSET",	offsetof (struct cpuinfo_ia64, irq_stat=
.f.irq_count) },
+    { "IA64_CPU_BH_COUNT_OFFSET",	offsetof (struct cpuinfo_ia64, irq_stat.=
f.bh_count) },
+    { "IA64_CPU_SOFTIRQ_ACTIVE_OFFSET",		offsetof (struct cpuinfo_ia64, so=
ftirq.active) },
+    { "IA64_CPU_SOFTIRQ_MASK_OFFSET",		offsetof (struct cpuinfo_ia64, soft=
irq.mask) },
+    { "IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET",	offsetof (struct cpuinfo_ia6=
4, phys_stacked_size_p8) },
 };
=20
 static const char *tabs =3D "\t\t\t\t\t\t\t\t\t\t";
diff -urN linux-davidm/arch/ia64/vmlinux.lds.S linux-2.4.1-lia/arch/ia64/vm=
linux.lds.S
--- linux-davidm/arch/ia64/vmlinux.lds.S	Fri Aug 11 19:09:06 2000
+++ linux-2.4.1-lia/arch/ia64/vmlinux.lds.S	Wed Feb 21 16:15:35 2001
@@ -8,6 +8,13 @@
 ENTRY(_start)
 SECTIONS
 {
+  /* Sections to be discarded */
+  /DISCARD/ : {
+	*(.text.exit)
+	*(.data.exit)
+	*(.exitcall.exit)
+	}
+
   v =3D PAGE_OFFSET;	/* this symbol is here to make debugging easier... */
=20
   . =3D KERNEL_START;
@@ -16,11 +23,11 @@
   _stext =3D .;
   .text : AT(ADDR(.text) - PAGE_OFFSET)
     {
-	*(__ivt_section)
+	*(.text.ivt)
 	/* these are not really text pages, but the zero page needs to be in a fi=
xed location: */
 	*(__special_page_section)
 	__start_gate_section =3D .;
-	*(__gate_section)
+	*(.text.gate)
 	__stop_gate_section =3D .;
 	*(.text)
     }
@@ -60,13 +67,13 @@
 	{ *(__ksymtab) }
   __stop___ksymtab =3D .;
=20
-  /* Unwind table */
+  /* Unwind info & table: */
+  .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - PAGE_OFFSET)
+	{ *(.IA_64.unwind_info*) }
   ia64_unw_start =3D .;
   .IA_64.unwind : AT(ADDR(.IA_64.unwind) - PAGE_OFFSET)
-	{ *(.IA_64.unwind) }
+	{ *(.IA_64.unwind*) }
   ia64_unw_end =3D .;
-  .IA_64.unwind_info : AT(ADDR(.IA_64.unwind_info) - PAGE_OFFSET)
-	{ *(.IA_64.unwind_info) }
=20
   .rodata : AT(ADDR(.rodata) - PAGE_OFFSET)
 	{ *(.rodata) }
@@ -129,13 +136,6 @@
 	{ *(.bss) *(COMMON) }
   . =3D ALIGN(64 / 8);
   _end =3D .;
-
-  /* Sections to be discarded */
-  /DISCARD/ : {
-	*(.text.exit)
-	*(.data.exit)
-	*(.exitcall.exit)
-	}
=20
   /* Stabs debugging sections.  */
   .stab 0 : { *(.stab) }
diff -urN linux-davidm/drivers/char/mem.c linux-2.4.1-lia/drivers/char/mem.c
--- linux-davidm/drivers/char/mem.c	Wed Feb 21 16:44:23 2001
+++ linux-2.4.1-lia/drivers/char/mem.c	Wed Feb 21 16:30:05 2001
@@ -484,8 +484,10 @@
 	switch (orig) {
 		case 0:
 			file->f_pos =3D offset;
+			break;
 		case 1:
 			file->f_pos +=3D offset;
+			break;
 		default:
 			return -EINVAL;
 	}
diff -urN linux-davidm/drivers/scsi/simscsi.c linux-2.4.1-lia/drivers/scsi/=
simscsi.c
--- linux-davidm/drivers/scsi/simscsi.c	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/drivers/scsi/simscsi.c	Wed Feb 21 16:30:57 2001
@@ -1,15 +1,16 @@
 /*
  * Simulated SCSI driver.
  *
- * Copyright (C) 1999 Hewlett-Packard Co
- * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999, 2001 Hewlett-Packard Co
+ * Copyright (C) 1999, 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
  *
  * 99/12/18 David Mosberger	Added support for READ10/WRITE10 needed by lin=
ux v2.3.33
  */
 #include <linux/config.h>
-#include <linux/init.h>
 #include <linux/blk.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
 #include <linux/kernel.h>
 #include <linux/timer.h>
=20
@@ -22,7 +23,7 @@
 #include "hosts.h"
 #include "simscsi.h"
=20
-#define DEBUG_SIMSCSI	0
+#define DEBUG_SIMSCSI	1
=20
 /* Simulator system calls: */
=20
@@ -36,7 +37,19 @@
 #define SSC_WRITE_ACCESS		2
 #define SSC_READ_ACCESS			1
=20
+#ifdef DEBUG_SIMSCSI
+  int simscsi_debug;
+# define DBG	simscsi_debug
+#else
+# define DBG	0
+#endif
+
+#if 0
 struct timer_list disk_timer;
+#else
+static void simscsi_interrupt (unsigned long val);
+DECLARE_TASKLET(simscsi_tasklet, simscsi_interrupt, 0);
+#endif
=20
 struct disk_req {
 	unsigned long addr;
@@ -93,9 +106,8 @@
 		while ((sc =3D queue[rd].sc) !=3D 0) {
 			atomic_dec(&num_reqs);
 			queue[rd].sc =3D 0;
-#if DEBUG_SIMSCSI
-			printk("simscsi_interrupt: done with %ld\n", sc->serial_number);
-#endif
+			if (DBG)
+				printk("simscsi_interrupt: done with %ld\n", sc->serial_number);
 			(*sc->scsi_done)(sc);
 			rd =3D (rd + 1) % SIMSCSI_REQ_QUEUE_LEN;
 		}
@@ -107,8 +119,10 @@
 simscsi_detect (Scsi_Host_Template *templ)
 {
 	templ->proc_name =3D "simscsi";
+#if 0
 	init_timer(&disk_timer);
 	disk_timer.function =3D simscsi_interrupt;
+#endif
 	return 1;	/* fake one SCSI host adapter */
 }
=20
@@ -162,10 +176,9 @@
 		return;
=20
 	stat.fd =3D desc[sc->target];
-#if DEBUG_SIMSCSI
-	printk("simscsi_%s @ %lx (off %lx)\n",
-	       mode =3D SSC_READ ? "read":"write", req.addr, offset);
-#endif
+	if (DBG)
+		printk("simscsi_%s @ %lx (off %lx)\n",
+		       mode =3D SSC_READ ? "read":"write", req.addr, offset);
 	ia64_ssc(stat.fd, 1, __pa(&req), offset, mode);
 	ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
=20
@@ -189,10 +202,10 @@
 	while (list_len) {
 		req.addr =3D __pa(sl->address);
 		req.len  =3D sl->length;
-#if DEBUG_SIMSCSI
-		printk("simscsi_sg_%s @ %lx (off %lx) use_sg=3D%d len=3D%d\n",
-		       mode =3D SSC_READ ? "read":"write", req.addr, offset, list_len, s=
l->length);
-#endif
+		if (DBG)
+			printk("simscsi_sg_%s @ %lx (off %lx) use_sg=3D%d len=3D%d\n",
+			       mode =3D SSC_READ ? "read":"write", req.addr, offset,
+			       list_len, sl->length);
 		ia64_ssc(stat.fd, 1, __pa(&req), offset, mode);
 		ia64_ssc(__pa(&stat), 0, 0, 0, SSC_WAIT_COMPLETION);
=20
@@ -244,11 +257,12 @@
 {
 	char fname[MAX_ROOT_LEN+16];
 	char *buf;
-
 #if DEBUG_SIMSCSI
 	register long sp asm ("sp");
-	printk("simscsi_queuecommand: target=3D%d,cmnd=3D%u,sc=3D%lu,sp=3D%lx,don=
e=3D%p\n",
-	       sc->target, sc->cmnd[0], sc->serial_number, sp, done);
+
+	if (DBG)
+		printk("simscsi_queuecommand: target=3D%d,cmnd=3D%u,sc=3D%lu,sp=3D%lx,do=
ne=3D%p\n",
+		       sc->target, sc->cmnd[0], sc->serial_number, sp, done);
 #endif
=20
 	sc->result =3D DID_BAD_TARGET << 16;
@@ -351,10 +365,14 @@
 	queue[wr].sc =3D sc;
 	wr =3D (wr + 1) % SIMSCSI_REQ_QUEUE_LEN;
=20
+#if 0
 	if (!timer_pending(&disk_timer)) {
-		disk_timer.expires =3D jiffies + HZ/20;
+		disk_timer.expires =3D jiffies;
 		add_timer(&disk_timer);
 	}
+#else
+	tasklet_schedule(&simscsi_tasklet);
+#endif
 	return 0;
 }
=20
diff -urN linux-davidm/drivers/scsi/simscsi.h linux-2.4.1-lia/drivers/scsi/=
simscsi.h
--- linux-davidm/drivers/scsi/simscsi.h	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/drivers/scsi/simscsi.h	Wed Feb 21 16:31:25 2001
@@ -29,7 +29,7 @@
 	bios_param:		simscsi_biosparam,	\
 	can_queue:		SIMSCSI_REQ_QUEUE_LEN,	\
 	this_id:		-1,			\
-	sg_tablesize:		32,			\
+	sg_tablesize:		SG_ALL,			\
 	cmd_per_lun:		SIMSCSI_REQ_QUEUE_LEN,	\
 	present:		0,			\
 	unchecked_isa_dma:	0,			\
diff -urN linux-davidm/drivers/video/vgacon.c linux-2.4.1-lia/drivers/video=
/vgacon.c
--- linux-davidm/drivers/video/vgacon.c	Tue Nov 28 22:34:31 2000
+++ linux-2.4.1-lia/drivers/video/vgacon.c	Wed Feb 21 16:31:34 2001
@@ -108,14 +108,7 @@
 static unsigned int    vga_default_font_height;	/* Height of default scree=
n font */
 static unsigned char   vga_video_type;		/* Card type */
 static unsigned char   vga_hardscroll_enabled;
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-/*
- * SoftSDV doesn't have hardware assist VGA scrolling=20
- */
-static unsigned char   vga_hardscroll_user_enable =3D 0;
-#else
 static unsigned char   vga_hardscroll_user_enable =3D 1;
-#endif
 static unsigned char   vga_font_is_default =3D 1;
 static int	       vga_vesa_blanked;
 static int	       vga_palette_blanked;
diff -urN linux-davidm/include/asm-ia64/delay.h linux-2.4.1-lia/include/asm=
-ia64/delay.h
--- linux-davidm/include/asm-ia64/delay.h	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/include/asm-ia64/delay.h	Wed Feb 21 16:43:49 2001
@@ -75,16 +75,11 @@
 static __inline__ void
 udelay (unsigned long usecs)
 {
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-	while (usecs--)
-		;
-#else
 	unsigned long start =3D ia64_get_itc();
-	unsigned long cycles =3D usecs*my_cpu_data.cyc_per_usec;
+	unsigned long cycles =3D usecs*current_cpu_data->cyc_per_usec;
=20
 	while (ia64_get_itc() - start < cycles)
 		/* skip */;
-#endif	/* CONFIG_IA64_SOFTSDV_HACKS */
 }
=20
 #endif /* _ASM_IA64_DELAY_H */
diff -urN linux-davidm/include/asm-ia64/efi.h linux-2.4.1-lia/include/asm-i=
a64/efi.h
--- linux-davidm/include/asm-ia64/efi.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.1-lia/include/asm-ia64/efi.h	Wed Feb 21 16:43:48 2001
@@ -183,7 +183,7 @@
 } efi_config_table_t;
=20
 #define EFI_SYSTEM_TABLE_SIGNATURE 0x5453595320494249
-#define EFI_SYSTEM_TABLE_REVISION  ((0 << 16) | (92))
+#define EFI_SYSTEM_TABLE_REVISION  ((1 << 16) | 00)
=20
 typedef struct {
 	efi_table_hdr_t hdr;
diff -urN linux-davidm/include/asm-ia64/hardirq.h linux-2.4.1-lia/include/a=
sm-ia64/hardirq.h
--- linux-davidm/include/asm-ia64/hardirq.h	Sun Dec  3 17:45:23 2000
+++ linux-2.4.1-lia/include/asm-ia64/hardirq.h	Wed Feb 21 16:43:58 2001
@@ -2,8 +2,8 @@
 #define _ASM_IA64_HARDIRQ_H
=20
 /*
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/config.h>
@@ -11,29 +11,24 @@
 #include <linux/threads.h>
 #include <linux/irq.h>
=20
-/* entry.S is sensitive to the offsets of these fields */
-typedef struct {
-	unsigned int __softirq_active;
-	unsigned int __softirq_mask;
-	unsigned int __local_irq_count;
-	unsigned int __local_bh_count;
-	unsigned int __syscall_count;
-	unsigned int __nmi_count;	/* arch dependent */
-} ____cacheline_aligned irq_cpustat_t;
-
-#include <linux/irq_cpustat.h>	/* Standard mappings for irq_cpustat_t abov=
e */
+#include <asm/processor.h>
=20
 /*
- * Are we in an interrupt context? Either doing bottom half
- * or hardware interrupt processing?
+ * No irq_cpustat_t for IA-64.  The data is held in the per-CPU data struc=
ture.
  */
-#define in_interrupt()						\
-({								\
-	int __cpu =3D smp_processor_id();				\
-	(local_irq_count(__cpu) + local_bh_count(__cpu)) !=3D 0;	\
-})
+#define softirq_active(cpu)	(cpu_data[cpu].softirq.active)
+#define softirq_mask(cpu)	(cpu_data[cpu].softirq.mask)
+#define local_irq_count(cpu)	(cpu_data[cpu].irq_stat.f.irq_count)
+#define local_bh_count(cpu)	(cpu_data[cpu].irq_stat.f.bh_count)
+#define syscall_count(cpu)	/* unused on IA-64 */
+#define nmi_count(cpu)		0
=20
-#define in_irq() (local_irq_count(smp_processor_id()) !=3D 0)
+/*
+ * Are we in an interrupt context? Either doing bottom half or hardware in=
terrupt
+ * processing?
+ */
+#define in_interrupt()		(current_cpu_data->irq_stat.irq_and_bh_counts !=3D=
 0)
+#define in_irq()		(current_cpu_data->irq_stat.f.irq_count !=3D 0)
=20
 #ifndef CONFIG_SMP
 # define hardirq_trylock(cpu)		(local_irq_count(cpu) =3D 0)
@@ -51,7 +46,8 @@
 extern unsigned int global_irq_holder;
 extern volatile unsigned long global_irq_lock;
=20
-static inline int irqs_running (void)
+static inline int
+irqs_running (void)
 {
 	int i;
=20
@@ -61,7 +57,8 @@
 	return 0;
 }
=20
-static inline void release_irqlock(int cpu)
+static inline void
+release_irqlock (int cpu)
 {
 	/* if we didn't own the irq lock, just ignore.. */
 	if (global_irq_holder =3D cpu) {
@@ -70,7 +67,8 @@
         }
 }
=20
-static inline void irq_enter(int cpu, int irq)
+static inline void
+irq_enter (int cpu, int irq)
 {
 	local_irq_count(cpu)++;
=20
@@ -79,19 +77,21 @@
 	}
 }
=20
-static inline void irq_exit(int cpu, int irq)
+static inline void
+irq_exit (int cpu, int irq)
 {
 	local_irq_count(cpu)--;
 }
=20
-static inline int hardirq_trylock(int cpu)
+static inline int
+hardirq_trylock (int cpu)
 {
 	return !local_irq_count(cpu) && !test_bit(0,&global_irq_lock);
 }
=20
 #define hardirq_endlock(cpu)	do { } while (0)
=20
-extern void synchronize_irq(void);
+extern void synchronize_irq (void);
=20
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_HARDIRQ_H */
diff -urN linux-davidm/include/asm-ia64/hw_irq.h linux-2.4.1-lia/include/as=
m-ia64/hw_irq.h
--- linux-davidm/include/asm-ia64/hw_irq.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.1-lia/include/asm-ia64/hw_irq.h	Wed Feb 21 16:43:49 2001
@@ -2,8 +2,8 @@
 #define _ASM_IA64_HW_IRQ_H
=20
 /*
- * Copyright (C) 2000 Hewlett-Packard Co
- * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2001 Hewlett-Packard Co
+ * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/sched.h>
@@ -45,7 +45,7 @@
 #define MCA_RENDEZ_IRQ		0xe8	/* MCA rendez interrupt */
 #define PERFMON_IRQ		0xee	/* performanc monitor interrupt vector */
 #define TIMER_IRQ		0xef	/* use highest-prio group 15 interrupt for timer */
-#define	MCA_WAKEUP_IRQ		0xf0	/* MCA wakeup interrupt (must be higher than =
MCA_RENDEZ_IRQ) */
+#define	MCA_WAKEUP_IRQ		0xf0	/* MCA wakeup interrupt (must be >MCA_RENDEZ_=
IRQ) */
 #define IPI_IRQ			0xfe	/* inter-processor interrupt vector */
=20
 /* IA64 inter-cpu interrupt related definitions */
@@ -60,9 +60,6 @@
         IA64_IPI_DM_INIT =3D      0x5,    /* pend an INIT interrupt */
         IA64_IPI_DM_EXTINT =3D    0x7,    /* pend an 8259-compatible inter=
rupt. */
 };
-
-#define IA64_BUS_ID(cpu)        (cpu >> 8)
-#define IA64_LOCAL_ID(cpu)      (cpu & 0xff)
=20
 extern __u8 isa_irq_to_vector_map[16];
 #define isa_irq_to_vector(x)	isa_irq_to_vector_map[(x)]
diff -urN linux-davidm/include/asm-ia64/kregs.h linux-2.4.1-lia/include/asm=
-ia64/kregs.h
--- linux-davidm/include/asm-ia64/kregs.h	Wed Dec 31 16:00:00 1969
+++ linux-2.4.1-lia/include/asm-ia64/kregs.h	Wed Feb 21 16:32:51 2001
@@ -0,0 +1,33 @@
+#ifndef _ASM_IA64_KREGS_H
+#define _ASM_IA64_KREGS_H
+
+/*
+ * Copyright (C) 2001 Hewlett-Packard Co
+ * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+/*
+ * This file defines the kernel register usage convention used by Linux/ia=
64.
+ */
+
+/*
+ * Kernel registers:
+ */
+#define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
+#define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT=
_STACK */
+#define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
+#define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
+#define IA64_KR_PT_BASE		7	/* ar.k7: page table base address (physical) */
+
+#define _IA64_KR_PASTE(x,y)	x##y
+#define _IA64_KR_PREFIX(n)	_IA64_KR_PASTE(ar.k, n)
+#define IA64_KR(n)		_IA64_KR_PREFIX(IA64_KR_##n)
+
+/*
+ * Translation registers:
+ */
+#define IA64_TR_KERNEL		0	/* itr0, dtr0: maps kernel image (code & data) */
+#define IA64_TR_PALCODE		1	/* itr1: maps PALcode as required by EFI */
+#define IA64_TR_PERCPU_DATA	1	/* dtr1: percpu data */
+#define IA64_TR_CURRENT_STACK	2	/* dtr2: maps kernel memory & register sta=
cks */
+
+#endif /* _ASM_IA64_kREGS_H */
diff -urN linux-davidm/include/asm-ia64/mmu_context.h linux-2.4.1-lia/inclu=
de/asm-ia64/mmu_context.h
--- linux-davidm/include/asm-ia64/mmu_context.h	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/include/asm-ia64/mmu_context.h	Wed Feb 21 16:43:49 2001
@@ -2,8 +2,8 @@
 #define _ASM_IA64_MMU_CONTEXT_H
=20
 /*
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/sched.h>
@@ -116,7 +116,7 @@
 	 * We may get interrupts here, but that's OK because interrupt
 	 * handlers cannot touch user-space.
 	 */
-	__asm__ __volatile__ ("mov ar.k7=3D%0" :: "r"(__pa(next->pgd)));
+	ia64_set_kr(IA64_KR_PT_BASE, __pa(next->pgd));
 	get_mmu_context(next);
 	reload_context(next);
 }
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.1-lia/include/a=
sm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.1-lia/include/asm-ia64/offsets.h	Wed Feb 21 16:37:46 2001
@@ -15,6 +15,7 @@
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
+#define IA64_CPU_SIZE			16384	/* 0x4000 */
 #define UNW_FRAME_INFO_SIZE		448	/* 0x1c0 */
=20
 #define IA64_TASK_PTRACE_OFFSET		48	/* 0x30 */
@@ -123,5 +124,10 @@
 #define IA64_SIGCONTEXT_FR6_OFFSET	560	/* 0x230 */
 #define IA64_CLONE_VFORK			16384	/* 0x4000 */
 #define IA64_CLONE_VM			256	/* 0x100 */
+#define IA64_CPU_IRQ_COUNT_OFFSET	8	/* 0x8 */
+#define IA64_CPU_BH_COUNT_OFFSET		12	/* 0xc */
+#define IA64_CPU_SOFTIRQ_ACTIVE_OFFSET	0	/* 0x0 */
+#define IA64_CPU_SOFTIRQ_MASK_OFFSET	4	/* 0x4 */
+#define IA64_CPU_PHYS_STACKED_SIZE_P8_OFFSET 16	/* 0x10 */
=20
 #endif /* _ASM_IA64_OFFSETS_H */
diff -urN linux-davidm/include/asm-ia64/page.h linux-2.4.1-lia/include/asm-=
ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.1-lia/include/asm-ia64/page.h	Wed Feb 21 16:43:48 2001
@@ -40,43 +40,6 @@
 extern void clear_page (void *page);
 extern void copy_page (void *to, void *from);
=20
-#  ifdef STRICT_MM_TYPECHECKS
-/*
- * These are used to make use of C type-checking..
- */
-typedef struct { unsigned long pte; } pte_t;
-typedef struct { unsigned long pmd; } pmd_t;
-typedef struct { unsigned long pgd; } pgd_t;
-typedef struct { unsigned long pgprot; } pgprot_t;
-
-#define pte_val(x)	((x).pte)
-#define pmd_val(x)	((x).pmd)
-#define pgd_val(x)	((x).pgd)
-#define pgprot_val(x)	((x).pgprot)
-
-#define __pte(x)	((pte_t) { (x) } )
-#define __pgprot(x)	((pgprot_t) { (x) } )
-
-#  else /* !STRICT_MM_TYPECHECKS */
-/*
- * .. while these make it easier on the compiler
- */
-typedef unsigned long pte_t;
-typedef unsigned long pmd_t;
-typedef unsigned long pgd_t;
-typedef unsigned long pgprot_t;
-
-#define pte_val(x)	(x)
-#define pmd_val(x)	(x)
-#define pgd_val(x)	(x)
-#define pgprot_val(x)	(x)
-
-#define __pte(x)	(x)
-#define __pgd(x)	(x)
-#define __pgprot(x)	(x)
-
-#  endif /* !STRICT_MM_TYPECHECKS */
-
 /*
  * Note: the MAP_NR_*() macro can't use __pa() because MAP_NR_*(X) MUST
  * map to something >=3D max_mapnr if X is outside the identity mapped
@@ -142,7 +105,45 @@
 }
=20
 # endif /* __KERNEL__ */
-#endif /* !ASSEMBLY */
+#endif /* !__ASSEMBLY__ */
+
+#ifdef STRICT_MM_TYPECHECKS
+  /*
+   * These are used to make use of C type-checking..
+   */
+  typedef struct { unsigned long pte; } pte_t;
+  typedef struct { unsigned long pmd; } pmd_t;
+  typedef struct { unsigned long pgd; } pgd_t;
+  typedef struct { unsigned long pgprot; } pgprot_t;
+
+# define pte_val(x)	((x).pte)
+# define pmd_val(x)	((x).pmd)
+# define pgd_val(x)	((x).pgd)
+# define pgprot_val(x)	((x).pgprot)
+
+# define __pte(x)	((pte_t) { (x) } )
+# define __pgprot(x)	((pgprot_t) { (x) } )
+
+#else /* !STRICT_MM_TYPECHECKS */
+  /*
+   * .. while these make it easier on the compiler
+   */
+# ifndef __ASSEMBLY__
+    typedef unsigned long pte_t;
+    typedef unsigned long pmd_t;
+    typedef unsigned long pgd_t;
+    typedef unsigned long pgprot_t;
+# endif
+
+# define pte_val(x)	(x)
+# define pmd_val(x)	(x)
+# define pgd_val(x)	(x)
+# define pgprot_val(x)	(x)
+
+# define __pte(x)	(x)
+# define __pgd(x)	(x)
+# define __pgprot(x)	(x)
+#endif /* !STRICT_MM_TYPECHECKS */
=20
 #define PAGE_OFFSET		0xe000000000000000
=20
diff -urN linux-davidm/include/asm-ia64/pal.h linux-2.4.1-lia/include/asm-i=
a64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Mon Oct  9 17:54:59 2000
+++ linux-2.4.1-lia/include/asm-ia64/pal.h	Wed Feb 21 16:33:30 2001
@@ -1267,7 +1267,7 @@
 ia64_pal_version (pal_version_u_t *pal_min_version, pal_version_u_t *pal_c=
ur_version)=20
 {=09
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_VERSION, 0, 0, 0);
+	PAL_CALL_PHYS(iprv, PAL_VERSION, 0, 0, 0);
 	if (pal_min_version)
 		pal_min_version->pal_version_val =3D iprv.v0;
=20
diff -urN linux-davidm/include/asm-ia64/param.h linux-2.4.1-lia/include/asm=
-ia64/param.h
--- linux-davidm/include/asm-ia64/param.h	Fri Oct 27 11:04:43 2000
+++ linux-2.4.1-lia/include/asm-ia64/param.h	Wed Feb 21 16:43:47 2001
@@ -10,7 +10,7 @@
=20
 #include <linux/config.h>
=20
-#if defined(CONFIG_IA64_HP_SIM) || defined(CONFIG_IA64_SOFTSDV_HACKS)
+#ifdef CONFIG_IA64_HP_SIM
 /*
  * Yeah, simulating stuff is slow, so let us catch some breath between
  * timer interrupts...
diff -urN linux-davidm/include/asm-ia64/pgalloc.h linux-2.4.1-lia/include/a=
sm-ia64/pgalloc.h
--- linux-davidm/include/asm-ia64/pgalloc.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.1-lia/include/asm-ia64/pgalloc.h	Wed Feb 21 16:44:11 2001
@@ -28,10 +28,10 @@
  * a lot of work and caused unnecessary memory traffic.  How broken...
  * We fix this by caching them.
  */
-#define pgd_quicklist		(my_cpu_data.pgd_quick)
-#define pmd_quicklist		(my_cpu_data.pmd_quick)
-#define pte_quicklist		(my_cpu_data.pte_quick)
-#define pgtable_cache_size	(my_cpu_data.pgtable_cache_sz)
+#define pgd_quicklist		(current_cpu_data->pgd_quick)
+#define pmd_quicklist		(current_cpu_data->pmd_quick)
+#define pte_quicklist		(current_cpu_data->pte_quick)
+#define pgtable_cache_size	(current_cpu_data->pgtable_cache_sz)
=20
 static __inline__ pgd_t*
 get_pgd_slow (void)
@@ -300,20 +300,22 @@
  * that may be necessary.
  */
 static inline void
-update_mmu_cache (struct vm_area_struct *vma, unsigned long address, pte_t=
 pte)
+update_mmu_cache (struct vm_area_struct *vma, unsigned long vaddr, pte_t p=
te)
 {
+	unsigned long addr;
 	struct page *page;
=20
 	if (!pte_exec(pte))
 		return;				/* not an executable page... */
=20
 	page =3D pte_page(pte);
-	address &=3D PAGE_MASK;
+	/* don't use VADDR: it may not be mapped on this CPU (or may have just be=
en flushed): */
+	addr =3D (unsigned long) page_address(page);
=20
 	if (test_bit(PG_arch_1, &page->flags))
 		return;				/* i-cache is already coherent with d-cache */
=20
-	flush_icache_range(address, address + PAGE_SIZE);
+	flush_icache_range(addr, addr + PAGE_SIZE);
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
=20
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.1-lia/include/a=
sm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/include/asm-ia64/pgtable.h	Wed Feb 21 16:43:58 2001
@@ -104,13 +104,6 @@
  */
 #define PTRS_PER_PTE	(__IA64_UL(1) << (PAGE_SHIFT-3))
=20
-# ifndef __ASSEMBLY__
-
-#include <asm/bitops.h>
-#include <asm/mmu_context.h>
-#include <asm/processor.h>
-#include <asm/system.h>
-
 /*
  * All the normal masks have the "page accessed" bits on, as any time
  * they are used, the page is accessed. They are cleared only by the
@@ -128,6 +121,13 @@
 #define PAGE_GATE	__pgprot(__ACCESS_BITS | _PAGE_PL_0 | _PAGE_AR_X_RX)
 #define PAGE_KERNEL	__pgprot(__DIRTY_BITS  | _PAGE_PL_0 | _PAGE_AR_RWX)
=20
+# ifndef __ASSEMBLY__
+
+#include <asm/bitops.h>
+#include <asm/mmu_context.h>
+#include <asm/processor.h>
+#include <asm/system.h>
+
 /*
  * Next come the mappings that determine how mmap() protection bits
  * (PROT_EXEC, PROT_READ, PROT_WRITE, PROT_NONE) get implemented.  The
@@ -175,7 +175,7 @@
 static inline long
 ia64_phys_addr_valid (unsigned long addr)
 {
-	return (addr & (my_cpu_data.unimpl_pa_mask)) =3D 0;
+	return (addr & (current_cpu_data->unimpl_pa_mask)) =3D 0;
 }
=20
 /*
@@ -208,7 +208,7 @@
 #define RGN_MAP_LIMIT	(1UL << (4*PAGE_SHIFT - 12))	/* limit of mappable ar=
ea in region */
 #define RGN_KERNEL	7
=20
-#define VMALLOC_START		(0xa000000000000000 + 2*PAGE_SIZE)
+#define VMALLOC_START		(0xa000000000000000 + 3*PAGE_SIZE)
 #define VMALLOC_VMADDR(x)	((unsigned long)(x))
 #define VMALLOC_END		(0xa000000000000000 + RGN_MAP_LIMIT)
=20
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.1-lia/include=
/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/include/asm-ia64/processor.h	Wed Feb 21 16:43:48 2001
@@ -16,6 +16,8 @@
 #include <linux/config.h>
=20
 #include <asm/ptrace.h>
+#include <asm/kregs.h>
+#include <asm/system.h>
 #include <asm/types.h>
=20
 #define IA64_NUM_DBG_REGS	8
@@ -172,9 +174,16 @@
 #define IA64_THREAD_UAC_SHIFT	3
 #define IA64_THREAD_UAC_MASK	(IA64_THREAD_UAC_NOPRINT | IA64_THREAD_UAC_SI=
GBUS)
=20
+
+/*
+ * This shift should be large enough to be able to represent
+ * 1000000/itc_freq with good accuracy while being small enough to fit
+ * 1000000<<IA64_USEC_PER_CYC_SHIFT in 64 bits.
+ */
+#define IA64_USEC_PER_CYC_SHIFT	41
+
 #ifndef __ASSEMBLY__
=20
-#include <linux/smp.h>
 #include <linux/threads.h>
=20
 #include <asm/fpu.h>
@@ -223,17 +232,24 @@
 };
=20
 /*
- * This shift should be large enough to be able to represent
- * 1000000/itc_freq with good accuracy while being small enough to fit
- * 1000000<<IA64_USEC_PER_CYC_SHIFT in 64 bits.
- */
-#define IA64_USEC_PER_CYC_SHIFT	41
-
-/*
  * CPU type, hardware bug flags, and per-CPU state.  Frequently used
  * state comes earlier:
  */
 struct cpuinfo_ia64 {
+	/* irq_stat and softirq should be 64-bit aligned */
+	struct {
+		__u32 active;
+		__u32 mask;
+	} softirq;
+	union {
+		struct {
+			__u32 irq_count;
+			__u32 bh_count;
+		} f;
+		__u64 irq_and_bh_counts;
+	} irq_stat;
+	__u32 phys_stacked_size_p8;	/* size of physical stacked registers + 8 */
+	__u32 pad0;
 	__u64 itm_delta;	/* # of clock cycles between clock ticks */
 	__u64 itm_next;		/* interval timer mask value to use for next clock tick =
*/
 	__u64 *pgd_quick;
@@ -265,9 +281,9 @@
 	__u64 prof_multiplier;
 	__u64 ipi_operation;
 #endif
-};
+} __attribute__ ((aligned (PAGE_SIZE))) ;
=20
-#define my_cpu_data		cpu_data[smp_processor_id()]
+#define current_cpu_data		((struct cpuinfo_ia64 *) PERCPU_ADDR)
=20
 extern struct cpuinfo_ia64 cpu_data[NR_CPUS];
=20
@@ -347,19 +363,47 @@
 	0				/* siginfo */	\
 }
=20
-#define start_thread(regs,new_ip,new_sp) do {					\
-	set_fs(USER_DS);							\
-	ia64_psr(regs)->dfh =3D 1;	/* disable fph */			\
-	ia64_psr(regs)->mfh =3D 0;	/* clear mfh */				\
-	ia64_psr(regs)->cpl =3D 3;	/* set user mode */			\
-	ia64_psr(regs)->ri =3D 0;		/* clear return slot number */		\
-	ia64_psr(regs)->is =3D 0;		/* IA-64 instruction set */		\
-	regs->cr_iip =3D new_ip;							\
-	regs->ar_rsc =3D 0xf;		/* eager mode, privilege level 3 */	\
-	regs->ar_rnat =3D 0;							\
-	regs->ar_bspstore =3D IA64_RBS_BOT;					\
-	regs->loadrs =3D 0;							\
-	regs->r12 =3D new_sp - 16;	/* allocate 16 byte scratch area */	\
+#define start_thread(regs,new_ip,new_sp) do {							\
+	set_fs(USER_DS);									\
+	ia64_psr(regs)->dfh =3D 1;	/* disable fph */					\
+	ia64_psr(regs)->mfh =3D 0;	/* clear mfh */						\
+	ia64_psr(regs)->cpl =3D 3;	/* set user mode */					\
+	ia64_psr(regs)->ri =3D 0;		/* clear return slot number */				\
+	ia64_psr(regs)->is =3D 0;		/* IA-64 instruction set */				\
+	regs->cr_iip =3D new_ip;									\
+	regs->ar_rsc =3D 0xf;		/* eager mode, privilege level 3 */			\
+	regs->ar_rnat =3D 0;									\
+	regs->ar_bspstore =3D IA64_RBS_BOT;							\
+	regs->ar_fpsr =3D FPSR_DEFAULT;								\
+	regs->loadrs =3D 0;									\
+	regs->r8 =3D current->dumpable;	/* set "don't zap registers" flag */			\
+	regs->r12 =3D new_sp - 16;	/* allocate 16 byte scratch area */			\
+	if (!__builtin_expect (current->dumpable, 1)) {						\
+		/*										\
+		 * Zap scratch regs to avoid leaking bits between processes with differe=
nt	\
+		 * uid/privileges.								\
+		 */										\
+		regs->ar_pfs =3D 0;								\
+		regs->pr =3D 0;									\
+		/*										\
+		 * XXX fix me: everything below can go away once we stop preserving scra=
tch	\
+		 * regs on a system call.							\
+		 */										\
+		regs->b6 =3D 0;									\
+		regs->r1 =3D 0; regs->r2 =3D 0; regs->r3 =3D 0;					\
+		regs->r13 =3D 0; regs->r14 =3D 0; regs->r15 =3D 0;					\
+		regs->r9  =3D 0; regs->r11 =3D 0;							\
+		regs->r16 =3D 0; regs->r17 =3D 0; regs->r18 =3D 0; regs->r19 =3D 0;			\
+		regs->r20 =3D 0; regs->r21 =3D 0; regs->r22 =3D 0; regs->r23 =3D 0;			\
+		regs->r24 =3D 0; regs->r25 =3D 0; regs->r26 =3D 0; regs->r27 =3D 0;			\
+		regs->r28 =3D 0; regs->r29 =3D 0; regs->r30 =3D 0; regs->r31 =3D 0;			\
+		regs->ar_ccv =3D 0;								\
+		regs->b0 =3D 0; regs->b7 =3D 0;							\
+		regs->f6.u.bits[0] =3D 0; regs->f6.u.bits[1] =3D 0;					\
+		regs->f7.u.bits[0] =3D 0; regs->f7.u.bits[1] =3D 0;					\
+		regs->f8.u.bits[0] =3D 0; regs->f8.u.bits[1] =3D 0;					\
+		regs->f9.u.bits[0] =3D 0; regs->f9.u.bits[1] =3D 0;					\
+	}											\
 } while (0)
=20
 /* Forward declarations, a strange C thing... */
@@ -410,20 +454,51 @@
 /* Return stack pointer of blocked task TSK.  */
 #define KSTK_ESP(tsk)  ((tsk)->thread.ksp)
=20
+static inline unsigned long
+ia64_get_kr (unsigned long regnum)
+{
+	unsigned long r;
+
+	switch (regnum) {
+	      case 0: asm volatile ("mov %0=3Dar.k0" : "=3Dr"(r)); break;
+	      case 1: asm volatile ("mov %0=3Dar.k1" : "=3Dr"(r)); break;
+	      case 2: asm volatile ("mov %0=3Dar.k2" : "=3Dr"(r)); break;
+	      case 3: asm volatile ("mov %0=3Dar.k3" : "=3Dr"(r)); break;
+	      case 4: asm volatile ("mov %0=3Dar.k4" : "=3Dr"(r)); break;
+	      case 5: asm volatile ("mov %0=3Dar.k5" : "=3Dr"(r)); break;
+	      case 6: asm volatile ("mov %0=3Dar.k6" : "=3Dr"(r)); break;
+	      case 7: asm volatile ("mov %0=3Dar.k7" : "=3Dr"(r)); break;
+	}
+	return r;
+}
+
+static inline void
+ia64_set_kr (unsigned long regnum, unsigned long r)
+{
+	switch (regnum) {
+	      case 0: asm volatile ("mov ar.k0=3D%0" :: "r"(r)); break;
+	      case 1: asm volatile ("mov ar.k1=3D%0" :: "r"(r)); break;
+	      case 2: asm volatile ("mov ar.k2=3D%0" :: "r"(r)); break;
+	      case 3: asm volatile ("mov ar.k3=3D%0" :: "r"(r)); break;
+	      case 4: asm volatile ("mov ar.k4=3D%0" :: "r"(r)); break;
+	      case 5: asm volatile ("mov ar.k5=3D%0" :: "r"(r)); break;
+	      case 6: asm volatile ("mov ar.k6=3D%0" :: "r"(r)); break;
+	      case 7: asm volatile ("mov ar.k7=3D%0" :: "r"(r)); break;
+	}
+}
+
 #ifndef CONFIG_SMP
=20
 static inline struct task_struct *
 ia64_get_fpu_owner (void)
 {
-	struct task_struct *t;
-	__asm__ ("mov %0=3Dar.k5" : "=3Dr"(t));
-	return t;
+	return (struct task_struct *) ia64_get_kr(IA64_KR_FPU_OWNER);
 }
=20
 static inline void
 ia64_set_fpu_owner (struct task_struct *t)
 {
-	__asm__ __volatile__ ("mov ar.k5=3D%0" :: "r"(t));
+	ia64_set_kr(IA64_KR_FPU_OWNER, (unsigned long) t);
 }
=20
 #endif /* !CONFIG_SMP */
@@ -444,8 +519,8 @@
 extern void ia64_load_pm_regs (struct task_struct *task);
 #endif
=20
-#define ia64_fph_enable()	__asm__ __volatile__ (";; rsm psr.dfh;; srlz.d;;=
" ::: "memory");
-#define ia64_fph_disable()	__asm__ __volatile__ (";; ssm psr.dfh;; srlz.d;=
;" ::: "memory");
+#define ia64_fph_enable()	asm volatile (";; rsm psr.dfh;; srlz.d;;" ::: "m=
emory");
+#define ia64_fph_disable()	asm volatile (";; ssm psr.dfh;; srlz.d;;" ::: "=
memory");
=20
 /* load fp 0.0 into fph */
 static inline void
@@ -474,53 +549,53 @@
 static inline void
 ia64_fc (void *addr)
 {
-	__asm__ __volatile__ ("fc %0" :: "r"(addr) : "memory");
+	asm volatile ("fc %0" :: "r"(addr) : "memory");
 }
=20
 static inline void
 ia64_sync_i (void)
 {
-	__asm__ __volatile__ (";; sync.i" ::: "memory");
+	asm volatile (";; sync.i" ::: "memory");
 }
=20
 static inline void
 ia64_srlz_i (void)
 {
-	__asm__ __volatile__ (";; srlz.i ;;" ::: "memory");
+	asm volatile (";; srlz.i ;;" ::: "memory");
 }
=20
 static inline void
 ia64_srlz_d (void)
 {
-	__asm__ __volatile__ (";; srlz.d" ::: "memory");
+	asm volatile (";; srlz.d" ::: "memory");
 }
=20
 static inline __u64
 ia64_get_rr (__u64 reg_bits)
 {
 	__u64 r;
-	__asm__ __volatile__ ("mov %0=3Drr[%1]" : "=3Dr"(r) : "r"(reg_bits) : "me=
mory");
+	asm volatile ("mov %0=3Drr[%1]" : "=3Dr"(r) : "r"(reg_bits) : "memory");
 	return r;
 }
=20
 static inline void
 ia64_set_rr (__u64 reg_bits, __u64 rr_val)
 {
-	__asm__ __volatile__ ("mov rr[%0]=3D%1" :: "r"(reg_bits), "r"(rr_val) : "=
memory");
+	asm volatile ("mov rr[%0]=3D%1" :: "r"(reg_bits), "r"(rr_val) : "memory");
 }
=20
 static inline __u64
 ia64_get_dcr (void)
 {
 	__u64 r;
-	__asm__ ("mov %0=3Dcr.dcr" : "=3Dr"(r));
+	asm volatile ("mov %0=3Dcr.dcr" : "=3Dr"(r));
 	return r;
 }
=20
 static inline void
 ia64_set_dcr (__u64 val)
 {
-	__asm__ __volatile__ ("mov cr.dcr=3D%0;;" :: "r"(val) : "memory");
+	asm volatile ("mov cr.dcr=3D%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
=20
@@ -528,14 +603,14 @@
 ia64_get_lid (void)
 {
 	__u64 r;
-	__asm__ ("mov %0=3Dcr.lid" : "=3Dr"(r));
+	asm volatile ("mov %0=3Dcr.lid" : "=3Dr"(r));
 	return r;
 }
=20
 static inline void
 ia64_invala (void)
 {
-	__asm__ __volatile__ ("invala" ::: "memory");
+	asm volatile ("invala" ::: "memory");
 }
=20
 /*
@@ -543,7 +618,7 @@
  * interrupt collection and interrupt enable bits.
  */
 #define ia64_clear_ic(flags)							\
-	__asm__ __volatile__ ("mov %0=3Dpsr;; rsm psr.i | psr.ic;; srlz.i;;"	\
+	asm volatile ("mov %0=3Dpsr;; rsm psr.i | psr.ic;; srlz.i;;"	\
 			      : "=3Dr"(flags) :: "memory");
=20
 /*
@@ -555,13 +630,13 @@
 	  __u64 vmaddr, __u64 pte,
 	  __u64 log_page_size)
 {
-	__asm__ __volatile__ ("mov cr.itir=3D%0" :: "r"(log_page_size << 2) : "me=
mory");
-	__asm__ __volatile__ ("mov cr.ifa=3D%0;;" :: "r"(vmaddr) : "memory");
+	asm volatile ("mov cr.itir=3D%0" :: "r"(log_page_size << 2) : "memory");
+	asm volatile ("mov cr.ifa=3D%0;;" :: "r"(vmaddr) : "memory");
 	if (target_mask & 0x1)
-		__asm__ __volatile__ ("itr.i itr[%0]=3D%1"
+		asm volatile ("itr.i itr[%0]=3D%1"
 				      :: "r"(tr_num), "r"(pte) : "memory");
 	if (target_mask & 0x2)
-		__asm__ __volatile__ (";;itr.d dtr[%0]=3D%1"
+		asm volatile (";;itr.d dtr[%0]=3D%1"
 				      :: "r"(tr_num), "r"(pte) : "memory");
 }
=20
@@ -573,13 +648,13 @@
 ia64_itc (__u64 target_mask, __u64 vmaddr, __u64 pte,
 	  __u64 log_page_size)
 {
-	__asm__ __volatile__ ("mov cr.itir=3D%0" :: "r"(log_page_size << 2) : "me=
mory");
-	__asm__ __volatile__ ("mov cr.ifa=3D%0;;" :: "r"(vmaddr) : "memory");
+	asm volatile ("mov cr.itir=3D%0" :: "r"(log_page_size << 2) : "memory");
+	asm volatile ("mov cr.ifa=3D%0;;" :: "r"(vmaddr) : "memory");
 	/* as per EAS2.6, itc must be the last instruction in an instruction grou=
p */
 	if (target_mask & 0x1)
-		__asm__ __volatile__ ("itc.i %0;;" :: "r"(pte) : "memory");
+		asm volatile ("itc.i %0;;" :: "r"(pte) : "memory");
 	if (target_mask & 0x2)
-		__asm__ __volatile__ (";;itc.d %0;;" :: "r"(pte) : "memory");
+		asm volatile (";;itc.d %0;;" :: "r"(pte) : "memory");
 }
=20
 /*
@@ -590,16 +665,16 @@
 ia64_ptr (__u64 target_mask, __u64 vmaddr, __u64 log_size)
 {
 	if (target_mask & 0x1)
-		__asm__ __volatile__ ("ptr.i %0,%1" :: "r"(vmaddr), "r"(log_size << 2));
+		asm volatile ("ptr.i %0,%1" :: "r"(vmaddr), "r"(log_size << 2));
 	if (target_mask & 0x2)
-		__asm__ __volatile__ ("ptr.d %0,%1" :: "r"(vmaddr), "r"(log_size << 2));
+		asm volatile ("ptr.d %0,%1" :: "r"(vmaddr), "r"(log_size << 2));
 }
=20
 /* Set the interrupt vector address.  The address must be suitably aligned=
 (32KB).  */
 static inline void
 ia64_set_iva (void *ivt_addr)
 {
-	__asm__ __volatile__ ("mov cr.iva=3D%0;; srlz.i;;" :: "r"(ivt_addr) : "me=
mory");
+	asm volatile ("mov cr.iva=3D%0;; srlz.i;;" :: "r"(ivt_addr) : "memory");
 }
=20
 /* Set the page table address and control bits.  */
@@ -607,7 +682,7 @@
 ia64_set_pta (__u64 pta)
 {
 	/* Note: srlz.i implies srlz.d */
-	__asm__ __volatile__ ("mov cr.pta=3D%0;; srlz.i;;" :: "r"(pta) : "memory"=
);
+	asm volatile ("mov cr.pta=3D%0;; srlz.i;;" :: "r"(pta) : "memory");
 }
=20
 static inline __u64
@@ -615,33 +690,33 @@
 {
 	__u64 r;
=20
-	__asm__ ("mov %0=3Dcpuid[%r1]" : "=3Dr"(r) : "rO"(regnum));
+	asm ("mov %0=3Dcpuid[%r1]" : "=3Dr"(r) : "rO"(regnum));
 	return r;
 }
=20
 static inline void
 ia64_eoi (void)
 {
-	__asm__ ("mov cr.eoi=3Dr0;; srlz.d;;" ::: "memory");
+	asm ("mov cr.eoi=3Dr0;; srlz.d;;" ::: "memory");
 }
=20
 static inline void
 ia64_set_lrr0 (unsigned long val)
 {
-	__asm__ __volatile__ ("mov cr.lrr0=3D%0;; srlz.d" :: "r"(val) : "memory");
+	asm volatile ("mov cr.lrr0=3D%0;; srlz.d" :: "r"(val) : "memory");
 }
=20
=20
 static inline void
 ia64_set_lrr1 (unsigned long val)
 {
-	__asm__ __volatile__ ("mov cr.lrr1=3D%0;; srlz.d" :: "r"(val) : "memory");
+	asm volatile ("mov cr.lrr1=3D%0;; srlz.d" :: "r"(val) : "memory");
 }
=20
 static inline void
 ia64_set_pmv (__u64 val)
 {
-	__asm__ __volatile__ ("mov cr.pmv=3D%0" :: "r"(val) : "memory");
+	asm volatile ("mov cr.pmv=3D%0" :: "r"(val) : "memory");
 }
=20
 static inline __u64
@@ -649,14 +724,14 @@
 {
 	__u64 retval;
=20
-	__asm__ __volatile__ ("mov %0=3Dpmc[%1]" : "=3Dr"(retval) : "r"(regnum));
+	asm volatile ("mov %0=3Dpmc[%1]" : "=3Dr"(retval) : "r"(regnum));
 	return retval;
 }
=20
 static inline void
 ia64_set_pmc (__u64 regnum, __u64 value)
 {
-	__asm__ __volatile__ ("mov pmc[%0]=3D%1" :: "r"(regnum), "r"(value));
+	asm volatile ("mov pmc[%0]=3D%1" :: "r"(regnum), "r"(value));
 }
=20
 static inline __u64
@@ -664,14 +739,14 @@
 {
 	__u64 retval;
=20
-	__asm__ __volatile__ ("mov %0=3Dpmd[%1]" : "=3Dr"(retval) : "r"(regnum));
+	asm volatile ("mov %0=3Dpmd[%1]" : "=3Dr"(retval) : "r"(regnum));
 	return retval;
 }
=20
 static inline void
 ia64_set_pmd (__u64 regnum, __u64 value)
 {
-	__asm__ __volatile__ ("mov pmd[%0]=3D%1" :: "r"(regnum), "r"(value));
+	asm volatile ("mov pmd[%0]=3D%1" :: "r"(regnum), "r"(value));
 }
=20
 /*
@@ -721,7 +796,7 @@
  * Get the current instruction/program counter value.
  */
 #define current_text_addr() \
-	({ void *_pc; __asm__ ("mov %0=3Dip" : "=3Dr" (_pc)); _pc; })
+	({ void *_pc; asm volatile ("mov %0=3Dip" : "=3Dr" (_pc)); _pc; })
=20
 #define THREAD_SIZE	IA64_STK_OFFSET
 /* NOTE: The task struct and the stacks are allocated together.  */
@@ -739,7 +814,7 @@
 static inline void
 ia64_set_cmcv (__u64 val)
 {
-	__asm__ __volatile__ ("mov cr.cmcv=3D%0" :: "r"(val) : "memory");
+	asm volatile ("mov cr.cmcv=3D%0" :: "r"(val) : "memory");
 }
=20
 /*
@@ -750,7 +825,7 @@
 {
 	__u64 val;
=20
-	__asm__ ("mov %0=3Dcr.cmcv" : "=3Dr"(val) :: "memory");
+	asm volatile ("mov %0=3Dcr.cmcv" : "=3Dr"(val) :: "memory");
 	return val;
 }
=20
@@ -758,28 +833,28 @@
 ia64_get_ivr (void)
 {
 	__u64 r;
-	__asm__ __volatile__ ("srlz.d;; mov %0=3Dcr.ivr;; srlz.d;;" : "=3Dr"(r));
+	asm volatile ("srlz.d;; mov %0=3Dcr.ivr;; srlz.d;;" : "=3Dr"(r));
 	return r;
 }
=20
 static inline void
 ia64_set_tpr (__u64 val)
 {
-	__asm__ __volatile__ ("mov cr.tpr=3D%0" :: "r"(val));
+	asm volatile ("mov cr.tpr=3D%0" :: "r"(val));
 }
=20
 static inline __u64
 ia64_get_tpr (void)
 {
 	__u64 r;
-	__asm__ ("mov %0=3Dcr.tpr" : "=3Dr"(r));
+	asm volatile ("mov %0=3Dcr.tpr" : "=3Dr"(r));
 	return r;
 }
=20
 static inline void
 ia64_set_irr0 (__u64 val)
 {
-	__asm__ __volatile__("mov cr.irr0=3D%0;;" :: "r"(val) : "memory");
+	asm volatile("mov cr.irr0=3D%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
=20
@@ -789,14 +864,14 @@
 	__u64 val;
=20
 	/* this is volatile because irr may change unbeknownst to gcc... */
-	__asm__ __volatile__("mov %0=3Dcr.irr0" : "=3Dr"(val));
+	asm volatile("mov %0=3Dcr.irr0" : "=3Dr"(val));
 	return val;
 }
=20
 static inline void
 ia64_set_irr1 (__u64 val)
 {
-	__asm__ __volatile__("mov cr.irr1=3D%0;;" :: "r"(val) : "memory");
+	asm volatile("mov cr.irr1=3D%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
=20
@@ -806,14 +881,14 @@
 	__u64 val;
=20
 	/* this is volatile because irr may change unbeknownst to gcc... */
-	__asm__ __volatile__("mov %0=3Dcr.irr1" : "=3Dr"(val));
+	asm volatile("mov %0=3Dcr.irr1" : "=3Dr"(val));
 	return val;
 }
=20
 static inline void
 ia64_set_irr2 (__u64 val)
 {
-	__asm__ __volatile__("mov cr.irr2=3D%0;;" :: "r"(val) : "memory");
+	asm volatile("mov cr.irr2=3D%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
=20
@@ -823,14 +898,14 @@
 	__u64 val;
=20
 	/* this is volatile because irr may change unbeknownst to gcc... */
-	__asm__ __volatile__("mov %0=3Dcr.irr2" : "=3Dr"(val));
+	asm volatile("mov %0=3Dcr.irr2" : "=3Dr"(val));
 	return val;
 }
=20
 static inline void
 ia64_set_irr3 (__u64 val)
 {
-	__asm__ __volatile__("mov cr.irr3=3D%0;;" :: "r"(val) : "memory");
+	asm volatile("mov cr.irr3=3D%0;;" :: "r"(val) : "memory");
 	ia64_srlz_d();
 }
=20
@@ -840,7 +915,7 @@
 	__u64 val;
=20
 	/* this is volatile because irr may change unbeknownst to gcc... */
-	__asm__ __volatile__("mov %0=3Dcr.irr3" : "=3Dr"(val));
+	asm volatile ("mov %0=3Dcr.irr3" : "=3Dr"(val));
 	return val;
 }
=20
@@ -849,7 +924,7 @@
 {
 	__u64 val;
=20
-	__asm__ ("mov %0=3Dgp" : "=3Dr"(val));
+	asm ("mov %0=3Dgp" : "=3Dr"(val));
 	return val;
 }
=20
diff -urN linux-davidm/include/asm-ia64/smp.h linux-2.4.1-lia/include/asm-i=
a64/smp.h
--- linux-davidm/include/asm-ia64/smp.h	Mon Oct  9 17:55:00 2000
+++ linux-2.4.1-lia/include/asm-ia64/smp.h	Wed Feb 21 16:43:48 2001
@@ -3,6 +3,8 @@
  *
  * Copyright (C) 1999 VA Linux Systems=20
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
+ * Copyright (C) 2001 Hewlett-Packard Co
+ * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #ifndef _ASM_IA64_SMP_H
 #define _ASM_IA64_SMP_H
@@ -15,13 +17,14 @@
 #include <linux/threads.h>
 #include <linux/kernel.h>
=20
-#include <asm/ptrace.h>
 #include <asm/io.h>
+#include <asm/processor.h>
+#include <asm/ptrace.h>
=20
 #define XTP_OFFSET		0x1e0008
=20
-#define SMP_IRQ_REDIRECTION     (1 << 0)
-#define SMP_IPI_REDIRECTION     (1 << 1)
+#define SMP_IRQ_REDIRECTION	(1 << 0)
+#define SMP_IPI_REDIRECTION	(1 << 1)
=20
 #define smp_processor_id()	(current->processor)
=20
@@ -30,15 +33,15 @@
 	int cpu_phys_id[NR_CPUS];
 } smp_boot_data __initdata;
=20
+extern char no_int_routing __initdata;
+
 extern unsigned long cpu_present_map;
 extern unsigned long cpu_online_map;
 extern unsigned long ipi_base_addr;
-extern int bootstrap_processor;
-extern volatile int __cpu_physical_id[NR_CPUS];
+extern int __cpu_physical_id[NR_CPUS];
 extern unsigned char smp_int_redirect;
-extern char no_int_routing;
 extern int smp_num_cpus;
- =20
+
 #define cpu_physical_id(i)	__cpu_physical_id[i]
 #define cpu_number_map(i)	(i)
 #define cpu_logical_map(i)	(i)
@@ -54,54 +57,55 @@
 {
 	int i;
=20
-	for (i=3D0; i<smp_num_cpus; i++) {
-		if (cpu_physical_id(i) =3D cpuid)
+	for (i =3D 0; i < smp_num_cpus; ++i)
+		if (cpu_physical_id(i) =3D (__u32) cpuid)
 			break;
-	}
 	return i;
 }
=20
 /*
  * XTP control functions:
- *    min_xtp   :  route all interrupts to this CPU
- *    normal_xtp:  nominal XTP value
- *    max_xtp   :  never deliver interrupts to this CPU.
+ *	min_xtp   : route all interrupts to this CPU
+ *	normal_xtp: nominal XTP value
+ *	max_xtp   : never deliver interrupts to this CPU.
  */
=20
 static inline void=20
-min_xtp(void)
+min_xtp (void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
 		writeb(0x00, ipi_base_addr | XTP_OFFSET); /* XTP to min */
 }
=20
 static inline void
-normal_xtp(void)
+normal_xtp (void)
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
 		writeb(0x08, ipi_base_addr | XTP_OFFSET); /* XTP normal */
 }
=20
 static inline void
-max_xtp(void)=20
+max_xtp (void)=20
 {
 	if (smp_int_redirect & SMP_IRQ_REDIRECTION)
 		writeb(0x0f, ipi_base_addr | XTP_OFFSET); /* Set XTP to max */
 }
=20
 static inline unsigned int=20
-hard_smp_processor_id(void)
+hard_smp_processor_id (void)
 {
-	struct {
-		unsigned long reserved : 16;
-		unsigned long eid : 8;
-		unsigned long id  : 8;
-		unsigned long ignored : 32;
+	union {
+		struct {
+			unsigned long reserved : 16;
+			unsigned long eid : 8;
+			unsigned long id : 8;
+			unsigned long ignored : 32;
+		} f;
+		unsigned long bits;
 	} lid;
=20
-	__asm__ ("mov %0=3Dcr.lid" : "=3Dr" (lid));
-
-	return lid.id << 8 | lid.eid;
+	lid.bits =3D ia64_get_lid();
+	return lid.f.id << 8 | lid.f.eid;
 }
=20
 #define NO_PROC_ID		(-1)
@@ -111,7 +115,7 @@
 extern void smp_do_timer (struct pt_regs *regs);
=20
 extern int smp_call_function_single (int cpuid, void (*func) (void *info),=
 void *info,
-			      int retry, int wait);
+				     int retry, int wait);
=20
=20
 #endif /* CONFIG_SMP */
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.1-lia/include/as=
m-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/include/asm-ia64/system.h	Wed Feb 21 16:43:48 2001
@@ -7,8 +7,8 @@
  * on information published in the Processor Abstraction Layer
  * and the System Abstraction Layer manual.
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999 Asit Mallick <asit.k.mallick@intel.com>
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  */
@@ -26,6 +26,7 @@
 #define SWAPPER_PGD_ADDR	(IVT_END_ADDR + 1*PAGE_SIZE)
=20
 #define GATE_ADDR		(0xa000000000000000 + PAGE_SIZE)
+#define PERCPU_ADDR		(0xa000000000000000 + 2*PAGE_SIZE)
=20
 #if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) \
     || defined(CONFIG_ITANIUM_B0_SPECIFIC) || defined(CONFIG_ITANIUM_B1_SP=
ECIFIC)
@@ -181,49 +182,8 @@
 #define __save_flags(flags)	__asm__ __volatile__ ("mov %0=3Dpsr" : "=3Dr" =
(flags) :: "memory")
 #define __save_and_cli(flags)	local_irq_save(flags)
 #define save_and_cli(flags)	__save_and_cli(flags)
-
-
-#ifdef CONFIG_IA64_SOFTSDV_HACKS
-/*
- * Yech.  SoftSDV has a slight probem with psr.i and itc/itm.  If
- * PSR.i =3D 0 and ITC =3D ITM, you don't get the timer tick posted.  So,
- * I'll check if ITC is larger than ITM here and reset if neccessary.
- * I may miss a tick to two.
- *=20
- * Don't include asm/delay.h; it causes include loops that are
- * mind-numbingly hard to follow.
- */
-
-#define get_itc(x) __asm__ __volatile__("mov %0=3Dar.itc" : "=3Dr"((x)) ::=
 "memory")
-#define get_itm(x) __asm__ __volatile__("mov %0=3Dcr.itm" : "=3Dr"((x)) ::=
 "memory")
-#define set_itm(x) __asm__ __volatile__("mov cr.itm=3D%0" :: "r"((x)) : "m=
emory")
-
-#define __restore_flags(x)			\
-do {						\
-        unsigned long itc, itm;			\
-	local_irq_restore(x);			\
-        get_itc(itc);				\
-        get_itm(itm);				\
-        if (itc > itm)				\
-		set_itm(itc + 10);		\
-} while (0)
-
-#define __sti()					\
-do {						\
-	unsigned long itc, itm;			\
-	local_irq_enable();			\
-	get_itc(itc);				\
-	get_itm(itm);				\
-	if (itc > itm)				\
-		set_itm(itc + 10);		\
-} while (0)
-
-#else /* !CONFIG_IA64_SOFTSDV_HACKS */
-
 #define __sti()			local_irq_enable ()
 #define __restore_flags(flags)	local_irq_restore(flags)
-
-#endif /* !CONFIG_IA64_SOFTSDV_HACKS */
=20
 #ifdef CONFIG_SMP
   extern void __global_cli (void);
diff -urN linux-davidm/include/linux/pci.h linux-2.4.1-lia/include/linux/pc=
i.h
--- linux-davidm/include/linux/pci.h	Sun Dec 31 11:10:59 2000
+++ linux-2.4.1-lia/include/linux/pci.h	Wed Feb 21 16:44:20 2001
@@ -565,9 +565,9 @@
 { 	return PCIBIOS_DEVICE_NOT_FOUND; }
=20
 #define _PCI_NOP(o,s,t) \
-	static inline int pcibios_##o##_config_##s## (u8 bus, u8 dfn, u8 where, t=
 val) \
+	static inline int pcibios_##o##_config_##s (u8 bus, u8 dfn, u8 where, t v=
al) \
 		{ return PCIBIOS_FUNC_NOT_SUPPORTED; } \
-	static inline int pci_##o##_config_##s## (struct pci_dev *dev, int where,=
 t val) \
+	static inline int pci_##o##_config_##s (struct pci_dev *dev, int where, t=
 val) \
 		{ return PCIBIOS_FUNC_NOT_SUPPORTED; }
 #define _PCI_NOP_ALL(o,x)	_PCI_NOP(o,byte,u8 x) \
 				_PCI_NOP(o,word,u16 x) \
diff -urN linux-davidm/kernel/ksyms.c linux-2.4.1-lia/kernel/ksyms.c
--- linux-davidm/kernel/ksyms.c	Tue Jan 30 10:43:43 2001
+++ linux-2.4.1-lia/kernel/ksyms.c	Wed Feb 21 16:36:23 2001
@@ -347,7 +347,7 @@
 EXPORT_SYMBOL(del_timer);
 EXPORT_SYMBOL(request_irq);
 EXPORT_SYMBOL(free_irq);
-#if !defined(CONFIG_ARCH_S390)
+#if !defined(CONFIG_ARCH_S390) && !defined(CONFIG_IA64)
 EXPORT_SYMBOL(irq_stat);	/* No separate irq_stat for s390, it is part of P=
SA */
 #endif
=20
diff -urN linux-davidm/kernel/softirq.c linux-2.4.1-lia/kernel/softirq.c
--- linux-davidm/kernel/softirq.c	Fri Dec 29 14:07:24 2000
+++ linux-2.4.1-lia/kernel/softirq.c	Wed Feb 21 16:36:37 2001
@@ -41,9 +41,9 @@
  */
=20
 /* No separate irq_stat for s390, it is part of PSA */
-#if !defined(CONFIG_ARCH_S390)
+#if !defined(CONFIG_ARCH_S390) && !defined(CONFIG_IA64)
 irq_cpustat_t irq_stat[NR_CPUS];
-#endif	/* CONFIG_ARCH_S390 */
+#endif
=20
 static struct softirq_action softirq_vec[32] __cacheline_aligned;
=20
@@ -90,7 +90,7 @@
 	local_bh_enable();
=20
 	/* Leave with locally disabled hard irqs. It is critical to close
-	 * window for infinite recursion, while we help local bh count,
+	 * window for infinite recursion, while we held local bh count,
 	 * it protected us. Now we are defenceless.
 	 */
 	return;
diff -urN linux-davidm/kernel/timer.c linux-2.4.1-lia/kernel/timer.c
--- linux-davidm/kernel/timer.c	Wed Feb 21 16:44:24 2001
+++ linux-2.4.1-lia/kernel/timer.c	Wed Feb 21 16:36:49 2001
@@ -805,7 +805,7 @@
 	if (t.tv_nsec >=3D 1000000000L || t.tv_nsec < 0 || t.tv_sec < 0)
 		return -EINVAL;
=20
-
+#if !defined(__ia64__)
 	if (t.tv_sec =3D 0 && t.tv_nsec <=3D 2000000L &&
 	    current->policy !=3D SCHED_OTHER)
 	{
@@ -818,6 +818,7 @@
 		udelay((t.tv_nsec + 999) / 1000);
 		return 0;
 	}
+#endif
=20
 	expire =3D timespec_to_jiffies(&t) + (t.tv_sec || t.tv_nsec);
=20

