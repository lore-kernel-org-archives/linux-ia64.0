From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 29 Jul 2000 07:41:42 +0000
Subject: [Linux-ia64] kernel update [relative to 2.4.0-test4]
Message-Id: <marc-linux-ia64-105590678205242@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is the latest kernel update.  Before I go on, two major caveats:

 BIG CAVEAT
	To run this kernel on a system with a SCSI controller that
	uses the PCI DMA interface (e.g, adaptec), you'll have to
	specific boot option mem=3D4G to force the kernel to ignore
	memory above 4GB.  This is a temporary issue and will be fixed
	in the next version.

 BIG CAVEAT
	This kernel will work fine with the qla1280 SCSI driver, even
	if there is memory above 4GB.  However, you must make sure
	that "64 bit addressing" is enabled in the Qlogic BIOS setup
	(press "Alt-Q" during system initialization to get into the
	SCSI controller configuration menu).  If your system is unable
	to mount the root filesystem, chances are you forgot to
	do this.

OK, having said that, here are the major goodies:

 - Support for software I/O TLB is in, thanks to Goutham and Asit
   (Intel).  This support allows to DMA from 32-bit PCI devices to any
   place in the physical memory.  However, the transfer size is
   currently limited to one page and this is the reason SCSI drivers
   such as the adaptec drivers do not work yet.

 - Bumped HZ to 1024.  Yeah, I still owe you guys some performance
   measurements, but it's the right thing to do anyhow, trust me. ;-)

 - Thanks to Stephane, /proc/palinfo now sports SMP support and has
   been renamed to /proc/pal.  There are also a couple of new entries,
   such as bus_info and tr_info.

 - GENERIC build fixes from Kanoj and yours truly.  Generic kernels
   should build again.

 - IA-32 fixes from Don and Kanoj.

 - New kernel option "mem=3DMEMLIMIT" to tell the kernel to ignore
   memory above MEMLIMIT.  Note that this option does not set the
   memory _size_ (as is the case on x86), it sets the _limit_ (which
   was easier to implement---render me lazy).  You can use "G", "M"
   or "K" to express the memory limit as giga-, mega-, or kilobytes
   (i.e., mem=3D4G ignore memory above 4gig).

 - Fixed a silly typo in the ITLB handler (thanks to Asit for catching
   this!).  It didn't really hurt much as that handler gets almost
   never used.

 - Removed backwards compatibility for the old system call break
   number (0x80000).  Shame on you if you're still using binaries with
   that very old number (none of the IA-64 Linux distributions ever
   did this).

 - Support for making physical stacked PAL calls is in (also by Stephane).

 - psr.mfh bit is now maintained more accurately, which avoids a
   potential problem on SMP and also should give better performance in
   certain cases.  Dan, if you want to use the fp-based memcpy routine
   for libc, you could now check if psr.mfh is on and, if so, you know
   the fph partition is in use alrady

 - Disabled the "lost timer tick" message; that message always was
   misleading, as no ticks are actually lost; with the newer steppings
   of the CPU, the whole issue of lost timer interrupts is pretty much
   gone anyhow.

 - Some SN1 updated (Kanoj)

 - eepro100 updats to make it _really_ work with the PCI DMA api
   (Ganesh).

 - Stephane Zeisset's fix for fs/buffer.c to avoid data corruption
   when copying to vfat filesystem (this is already in Linus's test5)

 - Added missing __raw_writel (pointed out by Bill, IIRC)

That should be it.  As usual, the relative diff below shows what
changed since the last IA-64 kernel update and is for informational
purposes only.  The full kernel diff is in
linux-2.4.0-test4-ia64-000728.diff.gz at:

	ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

Enjoy,

	--david

diff -urN linux-davidm/Documentation/DMA-mapping.txt
linux-2.4.0-test4-lia/Documentation/DMA-mapping.txt ---
linux-davidm/Documentation/DMA-mapping.txt Tue Apr 25 17:52:05 2000
+++ linux-2.4.0-test4-lia/Documentation/DMA-mapping.txt Fri Jul 28
22:51:03 2000 @@ -341,7 +341,7 @@ struct my_card_header *hp;
=20
 			/* Examine the header to see if we wish
-			 * to except the data.  But synchronize
+			 * to accept the data.  But synchronize
 			 * the DMA transfer with the CPU first
 			 * so that we see updated contents.
 			 */
diff -urN linux-davidm/Makefile linux-2.4.0-test4-lia/Makefile
--- linux-davidm/Makefile	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/Makefile	Fri Jul 14 15:07:13 2000
@@ -365,7 +365,6 @@
 clean:	archclean
 	rm -f kernel/ksyms.lst include/linux/compile.h
 	find . -name '*.[oas]' -type f -print | grep -v lxdialog/ | xargs rm -f
-	rm -f ksym.[ch] dummy_sym.c System.map.sv map map.out
 	rm -f core `find . -type f -name 'core' -print`
 	rm -f core `find . -type f -name '.*.flags' -print`
 	rm -f vmlinux System.map
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-test4-lia/arch/ia64/=
config.in
--- linux-davidm/arch/ia64/config.in	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/config.in	Fri Jul 28 22:53:08 2000
@@ -18,6 +18,7 @@
 comment 'General setup'
=20
 define_bool CONFIG_IA64 y
+define_bool CONFIG_SWIOTLB y	# for now...
=20
 define_bool CONFIG_ISA n
 define_bool CONFIG_SBUS n
@@ -39,15 +40,12 @@
 	define_bool CONFIG_IA64_BRL_EMU y
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
 	bool '  Enable Itanium A1-step specific code' CONFIG_ITANIUM_A1_SPECIFIC
+	bool '  Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECIFIC
 	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable AzusA hacks' CONFIG_IA64_AZUSA_HACKS
 	bool '  Emulate PAL/SAL/EFI firmware' CONFIG_IA64_FW_EMU
 	bool '  Enable IA64 Machine Check Abort' CONFIG_IA64_MCA
-fi
-
-if [ "$CONFIG_IA64_GENERIC" =3D "y" ]; then
-	define_bool CONFIG_IA64_SOFTSDV_HACKS y
 fi
=20
 if [ "$CONFIG_IA64_SGI_SN1_SIM" =3D "y" ]; then
diff -urN linux-davidm/arch/ia64/dig/iosapic.c linux-2.4.0-test4-lia/arch/i=
a64/dig/iosapic.c
--- linux-davidm/arch/ia64/dig/iosapic.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test4-lia/arch/ia64/dig/iosapic.c	Fri Jul 28 22:56:36 2000
@@ -22,12 +22,14 @@
 #include <linux/string.h>
 #include <linux/irq.h>
=20
+#include <asm/acpi-ext.h>
+#include <asm/delay.h>
 #include <asm/io.h>
 #include <asm/iosapic.h>
+#include <asm/machvec.h>
+#include <asm/processor.h>
 #include <asm/ptrace.h>
 #include <asm/system.h>
-#include <asm/delay.h>
-#include <asm/processor.h>
=20
 #undef DEBUG_IRQ_ROUTING
=20
@@ -315,10 +317,6 @@
 	 */
 	outb(0xff, 0xA1);
 	outb(0xff, 0x21);
-
-#ifndef CONFIG_IA64_DIG
-	iosapic_init(IO_SAPIC_DEFAULT_ADDR);
-#endif
 }
=20
 void
@@ -337,15 +335,23 @@
 			if (irq < 0 && dev->bus->parent) { /* go back to the bridge */
 				struct pci_dev * bridge =3D dev->bus->self;
=20
-				/* do the bridge swizzle... */
-				pin =3D (pin + PCI_SLOT(dev->devfn)) % 4;
-				irq =3D iosapic_get_PCI_irq_vector(bridge->bus->number,
-								 PCI_SLOT(bridge->devfn), pin);
+				/* allow for multiple bridges on an adapter */
+				do {
+					/* do the bridge swizzle... */
+					pin =3D (pin + PCI_SLOT(dev->devfn)) % 4;
+					irq =3D iosapic_get_PCI_irq_vector(bridge->bus->number,
+									 PCI_SLOT(bridge->devfn), pin);
+				} while (irq < 0 && (bridge =3D bridge->bus->self));
 				if (irq >=3D 0)
 					printk(KERN_WARNING
 					       "PCI: using PPB(B%d,I%d,P%d) to get irq %02x\n",
 					       bridge->bus->number, PCI_SLOT(bridge->devfn),
 					       pin, irq);
+				else
+					printk(KERN_WARNING
+					       "PCI: Couldn't map irq for B%d,I%d,P%d\n",
+					       bridge->bus->number, PCI_SLOT(bridge->devfn),
+					       pin);
 			}
 			if (irq >=3D 0) {
 				printk("PCI->APIC IRQ transform: (B%d,I%d,P%d) -> %02x\n",
@@ -360,4 +366,35 @@
 		if (dev->irq >=3D NR_IRQS)
 			dev->irq =3D 15;	/* Spurious interrupts */
 	}
+}
+
+/*
+ * Register an IOSAPIC discovered via ACPI.
+ */
+void __init
+dig_register_iosapic (acpi_entry_iosapic_t *iosapic)
+{
+	unsigned int ver, v;
+	int l, max_pin;
+
+	ver =3D iosapic_version(iosapic->address);
+	max_pin =3D (ver >> 16) & 0xff;
+=09
+	printk("IOSAPIC Version %x.%x: address 0x%lx IRQs 0x%x - 0x%x\n",=20
+	       (ver & 0xf0) >> 4, (ver & 0x0f), iosapic->address,=20
+	       iosapic->irq_base, iosapic->irq_base + max_pin);
+=09
+	for (l =3D 0; l <=3D max_pin; l++) {
+		v =3D iosapic->irq_base + l;
+		if (v < 16)
+			v =3D isa_irq_to_vector(v);
+		if (v > IA64_MAX_VECTORED_IRQ) {
+			printk("    !!! bad IOSAPIC interrupt vector: %u\n", v);
+			continue;
+		}
+		/* XXX Check for IOSAPIC collisions */
+		iosapic_addr(v) =3D (unsigned long) ioremap(iosapic->address, 0);
+		iosapic_baseirq(v) =3D iosapic->irq_base;
+	}
+	iosapic_init(iosapic->address, iosapic->irq_base);
 }
diff -urN linux-davidm/arch/ia64/dig/machvec.c linux-2.4.0-test4-lia/arch/i=
a64/dig/machvec.c
--- linux-davidm/arch/ia64/dig/machvec.c	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test4-lia/arch/ia64/dig/machvec.c	Fri Jul 28 22:56:47 2000
@@ -1,4 +1,2 @@
+#define MACHVEC_PLATFORM_NAME	dig
 #include <asm/machvec_init.h>
-#include <asm/machvec_dig.h>
-
-MACHVEC_DEFINE(dig)
diff -urN linux-davidm/arch/ia64/hp/hpsim_machvec.c linux-2.4.0-test4-lia/a=
rch/ia64/hp/hpsim_machvec.c
--- linux-davidm/arch/ia64/hp/hpsim_machvec.c	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test4-lia/arch/ia64/hp/hpsim_machvec.c	Fri Jul 28 22:56:57 =
2000
@@ -1,4 +1,2 @@
+#define MACHVEC_PLATFORM_NAME	hpsim
 #include <asm/machvec_init.h>
-#include <asm/machvec_hpsim.h>
-
-MACHVEC_DEFINE(hpsim)
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.0-test4-lia/ar=
ch/ia64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/ia32/ia32_entry.S	Fri Jul 28 22:57:12 2=
000
@@ -105,7 +105,7 @@
 	.align 8
 	.globl ia32_syscall_table
 ia32_syscall_table:=09
-	data8 sys_ni_syscall	  /* 0	-  old "setup(" system call*/
+	data8 sys32_ni_syscall	  /* 0	-  old "setup(" system call*/
 	data8 sys_exit
 	data8 sys32_fork
 	data8 sys_read
@@ -122,25 +122,25 @@
 	data8 sys_mknod
 	data8 sys_chmod		  /* 15 */
 	data8 sys_lchown
-	data8 sys_ni_syscall	  /* old break syscall holder */
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall	  /* old break syscall holder */
+	data8 sys32_ni_syscall
 	data8 sys_lseek
 	data8 sys_getpid	  /* 20 */
 	data8 sys_mount
 	data8 sys_oldumount
 	data8 sys_setuid
 	data8 sys_getuid
-	data8 sys_ni_syscall /* sys_stime is not supported on IA64 */  /* 25 */
+	data8 sys32_ni_syscall /* sys_stime is not supported on IA64 */  /* 25 */
 	data8 sys32_ptrace
 	data8 sys32_alarm
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall
+	data8 sys32_ni_syscall
 	data8 ia32_utime	  /* 30 */
-	data8 sys_ni_syscall	  /* old stty syscall holder */
-	data8 sys_ni_syscall	  /* old gtty syscall holder */
+	data8 sys32_ni_syscall	  /* old stty syscall holder */
+	data8 sys32_ni_syscall	  /* old gtty syscall holder */
 	data8 sys_access
 	data8 sys_nice
-	data8 sys_ni_syscall	  /* 35 */	  /* old ftime syscall holder */
+	data8 sys32_ni_syscall	  /* 35 */	  /* old ftime syscall holder */
 	data8 sys_sync
 	data8 sys_kill
 	data8 sys_rename
@@ -149,22 +149,22 @@
 	data8 sys_dup
 	data8 sys32_pipe
 	data8 sys32_times
-	data8 sys_ni_syscall	  /* old prof syscall holder */
+	data8 sys32_ni_syscall	  /* old prof syscall holder */
 	data8 sys_brk		  /* 45 */
 	data8 sys_setgid
 	data8 sys_getgid
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall
 	data8 sys_geteuid
 	data8 sys_getegid	  /* 50 */
 	data8 sys_acct
 	data8 sys_umount	  /* recycled never used phys( */
-	data8 sys_ni_syscall	  /* old lock syscall holder */
+	data8 sys32_ni_syscall	  /* old lock syscall holder */
 	data8 ia32_ioctl
-	data8 sys_fcntl		  /* 55 */
-	data8 sys_ni_syscall	  /* old mpx syscall holder */
+	data8 sys32_fcntl	  /* 55 */
+	data8 sys32_ni_syscall	  /* old mpx syscall holder */
 	data8 sys_setpgid
-	data8 sys_ni_syscall	  /* old ulimit syscall holder */
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall	  /* old ulimit syscall holder */
+	data8 sys32_ni_syscall
 	data8 sys_umask		  /* 60 */
 	data8 sys_chroot
 	data8 sys_ustat
@@ -172,12 +172,12 @@
 	data8 sys_getppid
 	data8 sys_getpgrp	  /* 65 */
 	data8 sys_setsid
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
-	data8 sys_ni_syscall
+	data8 sys32_sigaction
+	data8 sys32_ni_syscall
+	data8 sys32_ni_syscall
 	data8 sys_setreuid	  /* 70 */
 	data8 sys_setregid
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall
 	data8 sys_sigpending
 	data8 sys_sethostname
 	data8 sys32_setrlimit	  /* 75 */
@@ -189,7 +189,7 @@
 	data8 sys_setgroups
 	data8 old_select
 	data8 sys_symlink
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall
 	data8 sys_readlink	  /* 85 */
 	data8 sys_uselib
 	data8 sys_swapon
@@ -203,7 +203,7 @@
 	data8 sys_fchown	  /* 95 */
 	data8 sys_getpriority
 	data8 sys_setpriority
-	data8 sys_ni_syscall	  /* old profil syscall holder */
+	data8 sys32_ni_syscall	  /* old profil syscall holder */
 	data8 sys32_statfs
 	data8 sys32_fstatfs	  /* 100 */
 	data8 sys_ioperm
@@ -214,11 +214,11 @@
 	data8 sys32_newstat
 	data8 sys32_newlstat
 	data8 sys32_newfstat
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall
 	data8 sys_iopl		  /* 110 */
 	data8 sys_vhangup
-	data8 sys_ni_syscall		// used to be sys_idle
-	data8 sys_ni_syscall
+	data8 sys32_ni_syscall		// used to be sys_idle
+	data8 sys32_ni_syscall
 	data8 sys32_wait4
 	data8 sys_swapoff	  /* 115 */
 	data8 sys_sysinfo
@@ -242,7 +242,7 @@
 	data8 sys_bdflush
 	data8 sys_sysfs		  /* 135 */
 	data8 sys_personality
-	data8 sys_ni_syscall	  /* for afs_syscall */
+	data8 sys32_ni_syscall	  /* for afs_syscall */
 	data8 sys_setfsuid
 	data8 sys_setfsgid
 	data8 sys_llseek	  /* 140 */
@@ -293,8 +293,8 @@
 	data8 sys_capset	  /* 185 */
 	data8 sys_sigaltstack
 	data8 sys_sendfile
-	data8 sys_ni_syscall		  /* streams1 */
-	data8 sys_ni_syscall		  /* streams2 */
+	data8 sys32_ni_syscall		  /* streams1 */
+	data8 sys32_ni_syscall		  /* streams2 */
 	data8 sys32_vfork	  /* 190 */
 	/*
 	 *  CAUTION: If any system calls are added beyond this point
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.0-test4-lia/arch=
/ia64/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/ia32/sys_ia32.c	Fri Jul 28 22:57:21 2000
@@ -74,10 +74,14 @@
=20
 	n =3D 0;
 	do {
-		if ((err =3D get_user(addr, (int *)A(arg))) !=3D 0)
-			return(err);
-		if (ap)
-			*ap++ =3D (char *)A(addr);
+		err =3D get_user(addr, (int *)A(arg));
+		if (IS_ERR(err))
+			return err;
+		if (ap) {		/* no access_ok needed, we allocated */
+			err =3D __put_user((char *)A(addr), ap++);
+			if (IS_ERR(err))
+				return err;
+		}
 		arg +=3D sizeof(unsigned int);
 		n++;
 	} while (addr);
@@ -101,7 +105,11 @@
 	int na, ne, r, len;
=20
 	na =3D nargs(argv, NULL);
+	if (IS_ERR(na))
+		return(na);
 	ne =3D nargs(envp, NULL);
+	if (IS_ERR(ne))
+		return(ne);
 	len =3D (na + ne + 2) * sizeof(*av);
 	/*
 	 *  kmalloc won't work because the `sys_exec' code will attempt
@@ -121,12 +129,21 @@
 	if (IS_ERR(av))
 		return (long)av;
 	ae =3D av + na + 1;
-	av[na] =3D (char *)0;
-	ae[ne] =3D (char *)0;
-	(void)nargs(argv, av);
-	(void)nargs(envp, ae);
+	r =3D __put_user(0, (av + na));
+	if (IS_ERR(r))
+		goto out;
+	r =3D __put_user(0, (ae + ne));
+	if (IS_ERR(r))
+		goto out;
+	r =3D nargs(argv, av);
+	if (IS_ERR(r))
+		goto out;
+	r =3D nargs(envp, ae);
+	if (IS_ERR(r))
+		goto out;
 	r =3D sys_execve(filename, av, ae, regs);
 	if (IS_ERR(r))
+out:
 		sys_munmap((unsigned long) av, len);
 	return(r);
 }
@@ -959,150 +976,85 @@
 }
=20
 struct iovec32 { unsigned int iov_base; int iov_len; };
+asmlinkage ssize_t sys_readv(unsigned long,const struct iovec *,unsigned l=
ong);
+asmlinkage ssize_t sys_writev(unsigned long,const struct iovec *,unsigned =
long);
=20
-typedef ssize_t (*IO_fn_t)(struct file *, char *, size_t, loff_t *);
-
-static long
-do_readv_writev32(int type, struct file *file, const struct iovec32 *vecto=
r,
-		  u32 count)
+static struct iovec *
+get_iovec32(struct iovec32 *iov32, struct iovec *iov_buf, u32 count, int t=
ype)
 {
-	unsigned long tot_len;
-	struct iovec iovstack[UIO_FASTIOV];
-	struct iovec *iov=3Diovstack, *ivp;
-	struct inode *inode;
-	long retval, i;
-	IO_fn_t fn;
+	int i;
+	u32 buf, len;
+	struct iovec *ivp, *iov;
+
+	/* Get the "struct iovec" from user memory */
=20
-	/* First get the "struct iovec" from user memory and
-	 * verify all the pointers
-	 */
 	if (!count)
 		return 0;
-	if(verify_area(VERIFY_READ, vector, sizeof(struct iovec32)*count))
-		return -EFAULT;
+	if(verify_area(VERIFY_READ, iov32, sizeof(struct iovec32)*count))
+		return(struct iovec *)0;
 	if (count > UIO_MAXIOV)
-		return -EINVAL;
+		return(struct iovec *)0;
 	if (count > UIO_FASTIOV) {
 		iov =3D kmalloc(count*sizeof(struct iovec), GFP_KERNEL);
 		if (!iov)
-			return -ENOMEM;
-	}
+			return((struct iovec *)0);
+	} else
+		iov =3D iov_buf;
=20
-	tot_len =3D 0;
-	i =3D count;
 	ivp =3D iov;
-	while(i > 0) {
-		u32 len;
-		u32 buf;
-
-		__get_user(len, &vector->iov_len);
-		__get_user(buf, &vector->iov_base);
-		tot_len +=3D len;
+	for (i =3D 0; i < count; i++) {
+		if (__get_user(len, &iov32->iov_len) ||
+		    __get_user(buf, &iov32->iov_base)) {
+			if (iov !=3D iov_buf)
+				kfree(iov);
+			return((struct iovec *)0);
+		}
+		if (verify_area(type, (void *)A(buf), len)) {
+			if (iov !=3D iov_buf)
+				kfree(iov);
+			return((struct iovec *)0);
+		}
 		ivp->iov_base =3D (void *)A(buf);
-		ivp->iov_len =3D (__kernel_size_t) len;
-		vector++;
-		ivp++;
-		i--;
-	}
-
-	inode =3D file->f_dentry->d_inode;
-	/* VERIFY_WRITE actually means a read, as we write to user space */
-	retval =3D locks_verify_area((type =3D VERIFY_WRITE
-				    ? FLOCK_VERIFY_READ : FLOCK_VERIFY_WRITE),
-				   inode, file, file->f_pos, tot_len);
-	if (retval) {
-		if (iov !=3D iovstack)
-			kfree(iov);
-		return retval;
-	}
-
-	/* Then do the actual IO.  Note that sockets need to be handled
-	 * specially as they have atomicity guarantees and can handle
-	 * iovec's natively
-	 */
-	if (inode->i_sock) {
-		int err;
-		err =3D sock_readv_writev(type, inode, file, iov, count, tot_len);
-		if (iov !=3D iovstack)
-			kfree(iov);
-		return err;
-	}
-
-	if (!file->f_op) {
-		if (iov !=3D iovstack)
-			kfree(iov);
-		return -EINVAL;
-	}
-	/* VERIFY_WRITE actually means a read, as we write to user space */
-	fn =3D file->f_op->read;
-	if (type =3D VERIFY_READ)
-		fn =3D (IO_fn_t) file->f_op->write;	=09
-	ivp =3D iov;
-	while (count > 0) {
-		void * base;
-		int len, nr;
-
-		base =3D ivp->iov_base;
-		len =3D ivp->iov_len;
+		ivp->iov_len =3D (__kernel_size_t)len;
+		iov32++;
 		ivp++;
-		count--;
-		nr =3D fn(file, base, len, &file->f_pos);
-		if (nr < 0) {
-			if (retval)
-				break;
-			retval =3D nr;
-			break;
-		}
-		retval +=3D nr;
-		if (nr !=3D len)
-			break;
 	}
-	if (iov !=3D iovstack)
-		kfree(iov);
-	return retval;
+	return(iov);
 }
=20
 asmlinkage long
 sys32_readv(int fd, struct iovec32 *vector, u32 count)
 {
-	struct file *file;
-	long ret =3D -EBADF;
-
-	file =3D fget(fd);
-	if(!file)
-		goto bad_file;
-
-	if(!(file->f_mode & 1))
-		goto out;
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov;
+	int ret;
+	mm_segment_t old_fs =3D get_fs();
=20
-	ret =3D do_readv_writev32(VERIFY_WRITE, file,
-				vector, count);
-out:
-	fput(file);
-bad_file:
+	if ((iov =3D get_iovec32(vector, iovstack, count, VERIFY_WRITE)) =3D (str=
uct iovec *)0)
+		return -EFAULT;
+	set_fs(KERNEL_DS);
+	ret =3D sys_readv(fd, iov, count);
+	set_fs(old_fs);
+	if (iov !=3D iovstack)
+		kfree(iov);
 	return ret;
 }
=20
 asmlinkage long
 sys32_writev(int fd, struct iovec32 *vector, u32 count)
 {
-	struct file *file;
-	int ret =3D -EBADF;
-
-	file =3D fget(fd);
-	if(!file)
-		goto bad_file;
-
-	if(!(file->f_mode & 2))
-		goto out;
+	struct iovec iovstack[UIO_FASTIOV];
+	struct iovec *iov;
+	int ret;
+	mm_segment_t old_fs =3D get_fs();
=20
-	down(&file->f_dentry->d_inode->i_sem);
-	ret =3D do_readv_writev32(VERIFY_READ, file,
-				vector, count);
-	up(&file->f_dentry->d_inode->i_sem);
-out:
-	fput(file);
-bad_file:
+	if ((iov =3D get_iovec32(vector, iovstack, count, VERIFY_READ)) =3D (stru=
ct iovec *)0)
+		return -EFAULT;
+	set_fs(KERNEL_DS);
+	ret =3D sys_writev(fd, iov, count);
+	set_fs(old_fs);
+	if (iov !=3D iovstack)
+		kfree(iov);
 	return ret;
 }
=20
@@ -1173,21 +1125,22 @@
 static inline int
 shape_msg(struct msghdr *mp, struct msghdr32 *mp32)
 {
+	int ret;
 	unsigned int i;
=20
 	if (!access_ok(VERIFY_READ, mp32, sizeof(*mp32)))
 		return(-EFAULT);
-	__get_user(i, &mp32->msg_name);
+	ret =3D __get_user(i, &mp32->msg_name);
 	mp->msg_name =3D (void *)A(i);
-	__get_user(mp->msg_namelen, &mp32->msg_namelen);
-	__get_user(i, &mp32->msg_iov);
+	ret |=3D __get_user(mp->msg_namelen, &mp32->msg_namelen);
+	ret |=3D __get_user(i, &mp32->msg_iov);
 	mp->msg_iov =3D (struct iovec *)A(i);
-	__get_user(mp->msg_iovlen, &mp32->msg_iovlen);
-	__get_user(i, &mp32->msg_control);
+	ret |=3D __get_user(mp->msg_iovlen, &mp32->msg_iovlen);
+	ret |=3D __get_user(i, &mp32->msg_control);
 	mp->msg_control =3D (void *)A(i);
-	__get_user(mp->msg_controllen, &mp32->msg_controllen);
-	__get_user(mp->msg_flags, &mp32->msg_flags);
-	return(0);
+	ret |=3D __get_user(mp->msg_controllen, &mp32->msg_controllen);
+	ret |=3D __get_user(mp->msg_flags, &mp32->msg_flags);
+	return(ret ? -EFAULT : 0);
 }
=20
 /*
@@ -2341,17 +2294,17 @@
 {
 	struct switch_stack *swp;
 	struct pt_regs *ptp;
-	int i, tos;
+	int i, tos, ret;
 	int fsrlo, fsrhi;
=20
 	if (!access_ok(VERIFY_READ, save, sizeof(*save)))
 		return(-EIO);
-	__get_user(tsk->thread.fcr, (unsigned int *)&save->cw);
-	__get_user(fsrlo, (unsigned int *)&save->sw);
-	__get_user(fsrhi, (unsigned int *)&save->tag);
+	ret =3D __get_user(tsk->thread.fcr, (unsigned int *)&save->cw);
+	ret |=3D __get_user(fsrlo, (unsigned int *)&save->sw);
+	ret |=3D __get_user(fsrhi, (unsigned int *)&save->tag);
 	tsk->thread.fsr =3D ((long)fsrhi << 32) | (long)fsrlo;
-	__get_user(tsk->thread.fir, (unsigned int *)&save->ipoff);
-	__get_user(tsk->thread.fdr, (unsigned int *)&save->dataoff);
+	ret |=3D __get_user(tsk->thread.fir, (unsigned int *)&save->ipoff);
+	ret |=3D __get_user(tsk->thread.fdr, (unsigned int *)&save->dataoff);
 	/*
 	 *  Stack frames start with 16-bytes of temp space
 	 */
@@ -2360,7 +2313,7 @@
 	tos =3D (tsk->thread.fsr >> 11) & 3;
 	for (i =3D 0; i < 8; i++)
 		get_fpreg(i, &save->_st[i], ptp, swp, tos);
-	return(0);
+	return(ret ? -EFAULT : 0);
 }
=20
 asmlinkage long sys_ptrace(long, pid_t, unsigned long, unsigned long, long=
, long, long, long, long);
@@ -2492,6 +2445,105 @@
 	return ret;
 }
=20
+static inline int
+get_flock32(struct flock *kfl, struct flock32 *ufl)
+{
+	int err;
+=09
+	err =3D get_user(kfl->l_type, &ufl->l_type);
+	err |=3D __get_user(kfl->l_whence, &ufl->l_whence);
+	err |=3D __get_user(kfl->l_start, &ufl->l_start);
+	err |=3D __get_user(kfl->l_len, &ufl->l_len);
+	err |=3D __get_user(kfl->l_pid, &ufl->l_pid);
+	return err;
+}
+
+static inline int
+put_flock32(struct flock *kfl, struct flock32 *ufl)
+{
+	int err;
+=09
+	err =3D __put_user(kfl->l_type, &ufl->l_type);
+	err |=3D __put_user(kfl->l_whence, &ufl->l_whence);
+	err |=3D __put_user(kfl->l_start, &ufl->l_start);
+	err |=3D __put_user(kfl->l_len, &ufl->l_len);
+	err |=3D __put_user(kfl->l_pid, &ufl->l_pid);
+	return err;
+}
+
+extern asmlinkage long sys_fcntl(unsigned int fd, unsigned int cmd,
+				 unsigned long arg);
+
+asmlinkage long
+sys32_fcntl(unsigned int fd, unsigned int cmd, int arg)
+{
+	struct flock f;
+	mm_segment_t old_fs;
+	long ret;
+
+	switch (cmd) {
+	case F_GETLK:
+	case F_SETLK:
+	case F_SETLKW:
+		if(cmd !=3D F_GETLK && get_flock32(&f, (struct flock32 *)((long)arg)))
+			return -EFAULT;
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		ret =3D sys_fcntl(fd, cmd, (unsigned long)&f);
+		set_fs(old_fs);
+		if(cmd =3D F_GETLK && put_flock32(&f, (struct flock32 *)((long)arg)))
+			return -EFAULT;
+		return ret;
+	default:
+		/*
+		 *  `sys_fcntl' lies about arg, for the F_SETOWN
+		 *  sub-function arg can have a negative value.
+		 */
+		return sys_fcntl(fd, cmd, (unsigned long)((long)arg));
+	}
+}
+
+asmlinkage long
+sys32_sigaction (int sig, struct old_sigaction32 *act, struct old_sigactio=
n32 *oact)
+{
+        struct k_sigaction new_ka, old_ka;
+        int ret;
+
+        if (act) {
+		old_sigset32_t mask;
+	=09
+		ret =3D get_user((long)new_ka.sa.sa_handler, &act->sa_handler);
+		ret |=3D __get_user(new_ka.sa.sa_flags, &act->sa_flags);
+		ret |=3D __get_user(mask, &act->sa_mask);
+		if (ret)
+			return ret;
+		siginitset(&new_ka.sa.sa_mask, mask);
+        }
+
+        ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : N=
ULL);
+
+	if (!ret && oact) {
+		ret =3D put_user((long)old_ka.sa.sa_handler, &oact->sa_handler);
+		ret |=3D __put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret |=3D __put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
+        }
+
+	return ret;
+}
+
+asmlinkage long sys_ni_syscall(void);
+
+asmlinkage long
+sys32_ni_syscall(int dummy0, int dummy1, int dummy2, int dummy3,
+	int dummy4, int dummy5, int dummy6, int dummy7, int stack)
+{
+	struct pt_regs *regs =3D (struct pt_regs *)&stack;
+
+	printk("IA32 syscall #%d issued, maybe we should implement it\n",
+		(int)regs->r1);
+	return(sys_ni_syscall());
+}
+
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
=20
 /* In order to reduce some races, while at the same time doing additional
@@ -2545,61 +2597,6 @@
 	return sys_ioperm((unsigned long)from, (unsigned long)num, on);
 }
=20
-static inline int
-get_flock(struct flock *kfl, struct flock32 *ufl)
-{
-	int err;
-=09
-	err =3D get_user(kfl->l_type, &ufl->l_type);
-	err |=3D __get_user(kfl->l_whence, &ufl->l_whence);
-	err |=3D __get_user(kfl->l_start, &ufl->l_start);
-	err |=3D __get_user(kfl->l_len, &ufl->l_len);
-	err |=3D __get_user(kfl->l_pid, &ufl->l_pid);
-	return err;
-}
-
-static inline int
-put_flock(struct flock *kfl, struct flock32 *ufl)
-{
-	int err;
-=09
-	err =3D __put_user(kfl->l_type, &ufl->l_type);
-	err |=3D __put_user(kfl->l_whence, &ufl->l_whence);
-	err |=3D __put_user(kfl->l_start, &ufl->l_start);
-	err |=3D __put_user(kfl->l_len, &ufl->l_len);
-	err |=3D __put_user(kfl->l_pid, &ufl->l_pid);
-	return err;
-}
-
-extern asmlinkage long sys_fcntl(unsigned int fd, unsigned int cmd,
-				 unsigned long arg);
-
-asmlinkage long
-sys32_fcntl(unsigned int fd, unsigned int cmd, unsigned long arg)
-{
-	switch (cmd) {
-	case F_GETLK:
-	case F_SETLK:
-	case F_SETLKW:
-		{
-			struct flock f;
-			mm_segment_t old_fs;
-			long ret;
-		=09
-			if(get_flock(&f, (struct flock32 *)arg))
-				return -EFAULT;
-			old_fs =3D get_fs(); set_fs (KERNEL_DS);
-			ret =3D sys_fcntl(fd, cmd, (unsigned long)&f);
-			set_fs (old_fs);
-			if(put_flock(&f, (struct flock32 *)arg))
-				return -EFAULT;
-			return ret;
-		}
-	default:
-		return sys_fcntl(fd, cmd, (unsigned long)arg);
-	}
-}
-
 struct dqblk32 {
     __u32 dqb_bhardlimit;
     __u32 dqb_bsoftlimit;
@@ -3861,40 +3858,6 @@
 }
=20
 extern void check_pending(int signum);
-
-asmlinkage long
-sys32_sigaction (int sig, struct old_sigaction32 *act,
-		 struct old_sigaction32 *oact)
-{
-        struct k_sigaction new_ka, old_ka;
-        int ret;
-
-	if(sig < 0) {
-		current->tss.new_signal =3D 1;
-		sig =3D -sig;
-	}
-
-        if (act) {
-		old_sigset_t32 mask;
-	=09
-		ret =3D get_user((long)new_ka.sa.sa_handler, &act->sa_handler);
-		ret |=3D __get_user(new_ka.sa.sa_flags, &act->sa_flags);
-		ret |=3D __get_user(mask, &act->sa_mask);
-		if (ret)
-			return ret;
-		siginitset(&new_ka.sa.sa_mask, mask);
-        }
-
-        ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : N=
ULL);
-
-	if (!ret && oact) {
-		ret =3D put_user((long)old_ka.sa.sa_handler, &oact->sa_handler);
-		ret |=3D __put_user(old_ka.sa.sa_flags, &oact->sa_flags);
-		ret |=3D __put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
-        }
-
-	return ret;
-}
=20
 #ifdef CONFIG_MODULES
=20
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.4.0-test4-lia/arch=
/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/Makefile	Fri Jul 28 22:58:05 2000
@@ -9,8 +9,8 @@
=20
 all: kernel.o head.o init_task.o
=20
-obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o irq.o irq_ia64.o irq_sap=
ic.o ivt.o	\
-	 pal.o pci-dma.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.o		\
+obj-y :=3D acpi.o entry.o gate.o efi.o efi_stub.o irq.o irq_ia64.o irq_sap=
ic.o ivt.o		\
+	 machvec.o pal.o pci-dma.o process.o perfmon.o ptrace.o sal.o semaphore.o=
 setup.o	\
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
=20
 obj-$(CONFIG_IA64_GENERIC) +=3D machvec.o
diff -urN linux-davidm/arch/ia64/kernel/acpi.c linux-2.4.0-test4-lia/arch/i=
a64/kernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/acpi.c	Fri Jul 28 22:58:16 2000
@@ -19,10 +19,11 @@
 #include <linux/irq.h>
=20
 #include <asm/acpi-ext.h>
-#include <asm/page.h>
 #include <asm/efi.h>
 #include <asm/io.h>
 #include <asm/iosapic.h>
+#include <asm/machvec.h>
+#include <asm/page.h>
=20
 #undef ACPI_DEBUG		/* Guess what this does? */
=20
@@ -75,47 +76,6 @@
 }
=20
 /*
- * Find all IOSAPICs and tag the iosapic_vector structure with the appropr=
iate=20
- * base addresses.
- */
-static void __init
-acpi_iosapic(char *p)=20
-{
-	/*
-	 * This is not good.  ACPI is not necessarily limited to CONFIG_IA64_SV, =
yet
-	 * ACPI does not necessarily imply IOSAPIC either.  Perhaps there should =
be
-	 * a means for platform_setup() to register ACPI handlers?
-	 */
-#ifdef CONFIG_IA64_DIG
-	acpi_entry_iosapic_t *iosapic =3D (acpi_entry_iosapic_t *) p;
-	unsigned int ver, v;
-	int l, max_pin;
-
-	ver =3D iosapic_version(iosapic->address);
-	max_pin =3D (ver >> 16) & 0xff;
-=09
-	printk("IOSAPIC Version %x.%x: address 0x%lx IRQs 0x%x - 0x%x\n",=20
-	       (ver & 0xf0) >> 4, (ver & 0x0f), iosapic->address,=20
-	       iosapic->irq_base, iosapic->irq_base + max_pin);
-=09
-	for (l =3D 0; l <=3D max_pin; l++) {
-		v =3D iosapic->irq_base + l;
-		if (v < 16)
-			v =3D isa_irq_to_vector(v);
-		if (v > IA64_MAX_VECTORED_IRQ) {
-			printk("    !!! bad IOSAPIC interrupt vector: %u\n", v);
-			continue;
-		}
-		/* XXX Check for IOSAPIC collisions */
-		iosapic_addr(v) =3D (unsigned long) ioremap(iosapic->address, 0);
-		iosapic_baseirq(v) =3D iosapic->irq_base;
-	}
-	iosapic_init(iosapic->address, iosapic->irq_base);
-#endif
-}
-
-
-/*
  * Configure legacy IRQ information in iosapic_vector
  */
 static void __init
@@ -227,7 +187,7 @@
 			break;
 =09
 		case ACPI_ENTRY_IO_SAPIC:
-			acpi_iosapic(p);
+			platform_register_iosapic((acpi_entry_iosapic_t *) p);
 			break;
=20
 		case ACPI_ENTRY_INT_SRC_OVERRIDE:
diff -urN linux-davidm/arch/ia64/kernel/efi.c linux-2.4.0-test4-lia/arch/ia=
64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/efi.c	Fri Jul 28 22:58:24 2000
@@ -33,9 +33,10 @@
 extern efi_status_t efi_call_phys (void *, ...);
=20
 struct efi efi;
-		   =20
 static efi_runtime_services_t *runtime;
=20
+static unsigned long mem_limit =3D ~0UL;
+
 static efi_status_t
 phys_get_time (efi_time_t *tm, efi_time_cap_t *tc)
 {
@@ -169,15 +170,13 @@
 		      case EFI_BOOT_SERVICES_CODE:
 		      case EFI_BOOT_SERVICES_DATA:
 		      case EFI_CONVENTIONAL_MEMORY:
-			if (md->phys_addr > 1024*1024*1024UL) {
-				printk("Warning: ignoring %luMB of memory above 1GB!\n",
-				       md->num_pages >> 8);
-				md->type =3D EFI_UNUSABLE_MEMORY;
-				continue;
-			}
-
 			if (!(md->attribute & EFI_MEMORY_WB))
 				continue;
+			if (md->phys_addr + (md->num_pages << 12) > mem_limit) {
+				if (md->phys_addr > mem_limit)
+					continue;
+				md->num_pages =3D (mem_limit - md->phys_addr) >> 12;
+			}
 			if (md->num_pages =3D 0) {
 				printk("efi_memmap_walk: ignoring empty region at 0x%lx",
 				       md->phys_addr);
@@ -224,8 +223,8 @@
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
  */
-static void
-map_pal_code (void)
+void
+efi_map_pal_code (void)
 {
 	void *efi_map_start, *efi_map_end, *p;
 	efi_memory_desc_t *md;
@@ -240,7 +239,8 @@
=20
 	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
 		md =3D p;
-		if (md->type !=3D EFI_PAL_CODE) continue;
+		if (md->type !=3D EFI_PAL_CODE)
+			continue;
=20
 		if (++pal_code_count > 1) {
 			printk(KERN_ERR "Too many EFI Pal Code memory ranges, dropped @ %lx\n",
@@ -281,9 +281,28 @@
 	efi_config_table_t *config_tables;
 	efi_char16_t *c16;
 	u64 efi_desc_size;
-	char vendor[100] =3D "unknown";
+	char *cp, *end, vendor[100] =3D "unknown";
+	extern char saved_command_line[];
 	int i;
=20
+	/* it's too early to be able to use the standard kernel command line supp=
ort... */
+	for (cp =3D saved_command_line; *cp; ) {
+		if (memcmp(cp, "mem=3D", 4) =3D 0) {
+			cp +=3D 4;
+			mem_limit =3D memparse(cp, &end);
+			if (end !=3D cp)
+				break;
+			cp =3D end;
+		} else {
+			while (*cp !=3D ' ' && *cp)
+				++cp;
+			while (*cp =3D ' ')
+				++cp;
+		}
+	}
+	if (mem_limit !=3D ~0UL)
+		printk("Ignoring memory above %luMB\n", mem_limit >> 20);
+
 	efi.systab =3D __va(ia64_boot_param.efi_systab);
=20
 	/*
@@ -359,7 +378,7 @@
 	}
 #endif
=20
-	map_pal_code();
+	efi_map_pal_code();
 }
=20
 void
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test4-lia/arch/=
ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/entry.S	Fri Jul 28 23:04:23 2000
@@ -106,29 +106,19 @@
 	alloc r16=3Dar.pfs,1,0,0,0
 	DO_SAVE_SWITCH_STACK
 	UNW(.body)
-	// disable interrupts to ensure atomicity for next few instructions:
-	mov r17=3Dpsr		// M-unit
-	;;
-	rsm psr.i		// M-unit
-	dep r18=3D-1,r0,0,61	// build mask 0x1fffffffffffffff
-	;;
-	srlz.d
-	;;
+
 	adds r22=3DIA64_TASK_THREAD_KSP_OFFSET,r13
+	dep r18=3D-1,r0,0,61	// build mask 0x1fffffffffffffff
 	adds r21=3DIA64_TASK_THREAD_KSP_OFFSET,in0
 	;;
 	st8 [r22]=3Dsp		// save kernel stack pointer of old task
 	ld8 sp=3D[r21]		// load kernel stack pointer of new task
 	and r20=3Din0,r18		// physical address of "current"
 	;;
+	mov ar.k6=3Dr20		// copy "current" into ar.k6
 	mov r8=3Dr13		// return pointer to previously running task
 	mov r13=3Din0		// set "current" pointer
-	mov ar.k6=3Dr20		// copy "current" into ar.k6
-	;;
-	// restore interrupts
-	mov psr.l=3Dr17
 	;;
-	srlz.d
 	DO_LOAD_SWITCH_STACK( )
 	br.ret.sptk.few rp
 END(ia64_switch_to)
diff -urN linux-davidm/arch/ia64/kernel/irq_ia64.c linux-2.4.0-test4-lia/ar=
ch/ia64/kernel/irq_ia64.c
--- linux-davidm/arch/ia64/kernel/irq_ia64.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/irq_ia64.c	Fri Jul 28 23:08:34 2=
000
@@ -117,6 +117,13 @@
 	{
 		unsigned long bsp, sp;
=20
+		/*
+		 * Note: if the interrupt happened while executing in
+		 * the context switch routine (ia64_switch_to), we may
+		 * get a spurious stack overflow here.  This is
+		 * because the register and the memory stack are not
+		 * switched atomically.
+		 */
 		asm ("mov %0=3Dar.bsp" : "=3Dr"(bsp));
 		asm ("mov %0=3Dsp" : "=3Dr"(sp));
=20
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-test4-lia/arch/ia=
64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/ivt.S	Fri Jul 28 23:07:09 2000
@@ -170,33 +170,27 @@
 	 * The ITLB basically does the same as the VHPT handler except
 	 * that we always insert exactly one instruction TLB entry.
 	 */
-#if 1
 	/*
 	 * Attempt to lookup PTE through virtual linear page table.
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r31=3Dpr				// save predicates
-	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	mov r16=3Dcr.iha				// get virtual address of L3 PTE
 	;;
-	ld8.s r18=3D[r17]				// try to read L3 PTE
+	ld8.s r16=3D[r16]				// try to read L3 PTE
+	mov r31=3Dpr				// save predicates
 	;;
-	tnat.nz p6,p0=3Dr18			// did read succeed?
+	tnat.nz p6,p0=3Dr16			// did read succeed?
 (p6)	br.cond.spnt.many 1f
 	;;
-	itc.i r18
+	itc.i r16
 	;;
 	mov pr=3Dr31,-1
 	rfi
=20
-1:	rsm psr.dt				// use physical addressing for data
-#else
-	mov r16=3Dcr.ifa				// get address that caused the TLB miss
+1:	mov r16=3Dcr.ifa				// get address that caused the TLB miss
 	;;
 	rsm psr.dt				// use physical addressing for data
-#endif
-	mov r31=3Dpr				// save the predicate registers
 	mov r19=3Dar.k7				// get page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
 	shr.u r17=3Dr16,61			// get the region number into r17
@@ -244,33 +238,27 @@
 	 * The DTLB basically does the same as the VHPT handler except
 	 * that we always insert exactly one data TLB entry.
 	 */
-	mov r16=3Dcr.ifa				// get address that caused the TLB miss
-#if 1
 	/*
 	 * Attempt to lookup PTE through virtual linear page table.
 	 * The speculative access will fail if there is no TLB entry
 	 * for the L3 page table page we're trying to access.
 	 */
-	mov r31=3Dpr				// save predicates
-	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
+	mov r16=3Dcr.iha				// get virtual address of L3 PTE
 	;;
-	ld8.s r18=3D[r17]				// try to read L3 PTE
+	ld8.s r16=3D[r16]				// try to read L3 PTE
+	mov r31=3Dpr				// save predicates
 	;;
-	tnat.nz p6,p0=3Dr18			// did read succeed?
+	tnat.nz p6,p0=3Dr16			// did read succeed?
 (p6)	br.cond.spnt.many 1f
 	;;
-	itc.d r18
+	itc.d r16
 	;;
 	mov pr=3Dr31,-1
 	rfi
=20
-1:	rsm psr.dt				// use physical addressing for data
-#else
-	rsm psr.dt				// use physical addressing for data
-	mov r31=3Dpr				// save the predicate registers
+1:	mov r16=3Dcr.ifa				// get address that caused the TLB miss
 	;;
-#endif
+	rsm psr.dt				// use physical addressing for data
 	mov r19=3Dar.k7				// get page table base address
 	shl r21=3Dr16,3				// shift bit 60 into sign bit
 	shr.u r17=3Dr16,61			// get the region number into r17
@@ -504,7 +492,24 @@
 	mov r29=B0				// save b0 in case of nested fault)
 	;;
 1:	ld8 r18=3D[r17]
-	;;					// avoid raw on r18
+#if defined(CONFIG_IA32_SUPPORT) && \
+    (defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_B0_S=
PECIFIC))
+	//
+	// Erratum 85 (Access bit fault could be reported before page not present=
 fault)
+	//   If the PTE is indicates the page is not present, then just turn this=
 into a
+	//   page fault.
+	//
+	mov r31=3Dpr				// save predicates
+	;;
+	tbit.nz p6,p0=3Dr18,0			// page present bit set?
+(p6)	br.cond.sptk 1f
+	;;					// avoid WAW on p6
+	mov pr=3Dr31,-1
+	br.cond.sptk page_fault			// page wasn't present
+1:	mov pr=3Dr31,-1
+#else
+	;;					// avoid RAW on r18
+#endif
 	or r18=3D_PAGE_A,r18			// set the accessed bit
 	mov b0=3Dr29				// restore b0
 	;;
@@ -541,14 +546,6 @@
 	;;
 	srlz.d			// ensure everyone knows psr.dt is off...
 	cmp.eq p0,p7=3Dr16,r17	// is this a system call? (p7 <- false, if so)
-#if 1
-	// Allow syscalls via the old system call number for the time being.  Thi=
s is
-	// so we can transition to the new syscall number in a relatively smooth
-	// fashion.
-	mov r17=3D0x80000
-	;;
-(p7)	cmp.eq.or.andcm p0,p7=3Dr16,r17		// is this the old syscall number?
-#endif
 (p7)	br.cond.spnt.many non_syscall
=20
 	SAVE_MIN				// uses r31; defines r2:
diff -urN linux-davidm/arch/ia64/kernel/machvec.c linux-2.4.0-test4-lia/arc=
h/ia64/kernel/machvec.c
--- linux-davidm/arch/ia64/kernel/machvec.c	Tue Feb  8 12:01:59 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/machvec.c	Fri Jul 28 23:08:48 20=
00
@@ -3,12 +3,9 @@
 #include <asm/page.h>
 #include <asm/machvec.h>
=20
-struct ia64_machine_vector ia64_mv;
+#ifdef CONFIG_IA64_GENERIC
=20
-void
-machvec_noop (void)
-{
-}
+struct ia64_machine_vector ia64_mv;
=20
 /*
  * Most platforms use this routine for mapping page frame addresses
@@ -45,4 +42,11 @@
 	}
 	ia64_mv =3D *mv;
 	printk("booting generic kernel on platform %s\n", name);
+}
+
+#endif /* CONFIG_IA64_GENERIC */
+
+void
+machvec_noop (void)
+{
 }
diff -urN linux-davidm/arch/ia64/kernel/pal.S linux-2.4.0-test4-lia/arch/ia=
64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/pal.S	Fri Jul 28 23:08:58 2000
@@ -191,3 +191,57 @@
 	srlz.d				// seralize restoration of psr.l
 	br.ret.sptk.few	b0
 END(ia64_pal_call_phys_static)
+
+/*
+ * Make a PAL call using the stacked registers in physical mode.
+ *
+ * Inputs:
+ * 	in0         Index of PAL service
+ * 	in2 - in3   Remaning PAL arguments
+ */
+GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5))
+	alloc	loc1 =3D ar.pfs,5,5,86,0
+	movl	loc2 =3D pal_entry_point
+1:	{
+	  mov r28  =3D in0		// copy procedure index
+	  mov loc0 =3D rp		// save rp
+	}
+	.body
+	;;
+	ld8 loc2 =3D [loc2]		// loc2 <- entry point
+	mov out0 =3D in0		// first argument
+	mov out1 =3D in1		// copy arg2
+	mov out2 =3D in2		// copy arg3
+	mov out3 =3D in3		// copy arg3
+	;;
+	mov loc3 =3D psr		// save psr
+	;;=20
+	mov loc4=3Dar.rsc			// save RSE configuration
+	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
+	;;
+	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	movl r16=3DPAL_PSR_BITS_TO_CLEAR
+	movl r17=3DPAL_PSR_BITS_TO_SET
+	;;
+	or loc3=3Dloc3,r17		// add in psr the bits to set
+	mov b7 =3D loc2			// install target to branch reg
+	;;
+	andcm r16=3Dloc3,r16		// removes bits to clear from psr
+	br.call.sptk.few rp=3Dia64_switch_mode
+.ret6:
+	br.call.sptk.many rp=B7		// now make the call
+.ret7:
+	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	mov r16=3Dloc3			// r16=3D original psr
+	br.call.sptk.few rp=3Dia64_switch_mode	// return to virtual mode
+
+.ret8:	mov psr.l  =3D loc3		// restore init PSR
+	mov ar.pfs =3D loc1
+	mov rp =3D loc0
+	;;
+	mov ar.rsc=3Dloc4			// restore RSE configuration
+	srlz.d				// seralize restoration of psr.l
+	br.ret.sptk.few	b0
+END(ia64_pal_call_phys_stacked)
+
diff -urN linux-davidm/arch/ia64/kernel/palinfo.c linux-2.4.0-test4-lia/arc=
h/ia64/kernel/palinfo.c
--- linux-davidm/arch/ia64/kernel/palinfo.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/palinfo.c	Fri Jul 28 23:09:09 20=
00
@@ -27,13 +27,22 @@
 #include <asm/efi.h>
 #include <asm/page.h>
 #include <asm/processor.h>
+#ifdef CONFIG_SMP
+#include <linux/smp.h>
+#endif
=20
 /*
  * Hope to get rid of these in a near future
 */
 #define IA64_PAL_VERSION_BUG		1
=20
-#define PALINFO_VERSION "0.1"
+#define PALINFO_VERSION "0.2"
+
+#ifdef CONFIG_SMP
+#define cpu_is_online(i) (cpu_online_map & (1UL << i))
+#else
+#define cpu_is_online(i)	1
+#endif
=20
 typedef int (*palinfo_func_t)(char*);
=20
@@ -43,7 +52,6 @@
 	struct proc_dir_entry	*entry;		/* registered entry (removal) */
 } palinfo_entry_t;
=20
-static struct proc_dir_entry *palinfo_dir;
=20
 /*
  *  A bunch of string array to get pretty printing
@@ -95,7 +103,7 @@
 #define RSE_HINTS_COUNT (sizeof(rse_hints)/sizeof(const char *))
=20
 /*
- * The current resvision of the Volume 2 of=20
+ * The current revision of the Volume 2 of=20
  * IA-64 Architecture Software Developer's Manual is wrong.
  * Table 4-10 has invalid information concerning the ma field:
  * Correct table is:
@@ -564,7 +572,6 @@
 	int i;
 	s64 ret;
=20
-	/* must be in physical mode */
 	if ((ret=3Dia64_pal_proc_get_features(&avail, &status, &control)) !=3D 0)=
 return 0;
=20
 	for(i=3D0; i < 64; i++, v++,avail >>=3D1, status >>=3D1, control >>=3D1) {
@@ -577,6 +584,57 @@
 	return p - page;
 }
=20
+static const char *bus_features[]=3D{
+	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
+	NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,
+	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
+	NULL,NULL,
+	"Request  Bus Parking",
+	"Bus Lock Mask",
+	"Enable Half Transfer",
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	NULL, NULL, NULL, NULL, NULL, NULL,
+	"Disable Transaction Queuing",
+	"Disable Reponse Error Checking",
+	"Disable Bus Error Checking",
+	"Disable Bus Requester Internal Error Signalling",
+	"Disable Bus Requester Error Signalling",
+	"Disable Bus Initialization Event Checking",
+	"Disable Bus Initialization Event Signalling",
+	"Disable Bus Address Error Checking",
+	"Disable Bus Address Error Signalling",
+	"Disable Bus Data Error Checking"
+};
+
+=09
+static int
+bus_info(char *page)
+{
+	char *p =3D page;
+	const char **v =3D bus_features;
+	pal_bus_features_u_t av, st, ct;
+	u64 avail, status, control;
+	int i;
+	s64 ret;
+
+	if ((ret=3Dia64_pal_bus_get_features(&av, &st, &ct)) !=3D 0) return 0;
+
+	avail   =3D av.pal_bus_features_val;
+	status  =3D st.pal_bus_features_val;
+	control =3D ct.pal_bus_features_val;
+
+	for(i=3D0; i < 64; i++, v++, avail >>=3D1, status >>=3D1, control >>=3D1)=
 {
+		if ( ! *v ) continue;
+		p +=3D sprintf(p, "%-48s : %s%s %s\n", *v,=20
+				avail & 0x1 ? "" : "NotImpl",
+				avail & 0x1 ? (status  & 0x1 ? "On" : "Off"): "",
+				avail & 0x1 ? (control & 0x1 ? "Ctrl" : "NoCtrl"): "");
+	}
+	return p - page;
+}
+
+
 /*
  * physical mode call for PAL_VERSION is working fine.
  * This function is meant to go away once PAL get fixed.
@@ -613,21 +671,19 @@
 #endif
 	if (status !=3D 0) return 0;
=20
-	p +=3D sprintf(p, "PAL_vendor     : 0x%x (min=3D0x%x)\n" \
-			"PAL_A revision : 0x%x (min=3D0x%x)\n" \
-			"PAL_A model    : 0x%x (min=3D0x%x)\n" \
-			"PAL_B mode     : 0x%x (min=3D0x%x)\n" \
-			"PAL_B revision : 0x%x (min=3D0x%x)\n",
+	p +=3D sprintf(p, "PAL_vendor : 0x%02x (min=3D0x%02x)\n" \
+			"PAL_A      : %02x.%02x (min=3D%02x.%02x)\n" \
+			"PAL_B      : %02x.%02x (min=3D%02x.%02x)\n",
 	     		cur_ver.pal_version_s.pv_pal_vendor,
 	     		min_ver.pal_version_s.pv_pal_vendor,
-	     		cur_ver.pal_version_s.pv_pal_a_rev,
-	     		cur_ver.pal_version_s.pv_pal_a_rev,
 	     		cur_ver.pal_version_s.pv_pal_a_model,
+	     		cur_ver.pal_version_s.pv_pal_a_rev,
 	     		min_ver.pal_version_s.pv_pal_a_model,
-	     		cur_ver.pal_version_s.pv_pal_b_rev,
-	     		min_ver.pal_version_s.pv_pal_b_rev,
+	     		min_ver.pal_version_s.pv_pal_a_rev,
 	     		cur_ver.pal_version_s.pv_pal_b_model,
-	     		min_ver.pal_version_s.pv_pal_b_model);
+	     		cur_ver.pal_version_s.pv_pal_b_rev,
+	     		min_ver.pal_version_s.pv_pal_b_model,
+	     		min_ver.pal_version_s.pv_pal_b_rev);
=20
 	return p - page;
 }
@@ -708,30 +764,111 @@
 	return p - page;
 }
=20
-
-/*
- * Entry point routine: all calls go trhough this function
- */
 static int
-palinfo_read_entry(char *page, char **start, off_t off, int count, int *eo=
f, void *data)
+tr_info(char *page)
 {
-	palinfo_func_t info =3D (palinfo_func_t)data;
-        int len =3D info(page);
+	char *p =3D page;
+	s64 status;
+	pal_tr_valid_u_t tr_valid;
+	u64 tr_buffer[4];
+	pal_vm_info_1_u_t vm_info_1;
+	pal_vm_info_2_u_t vm_info_2;
+	int i, j;
+	u64 max[3], pgm;
+	struct ifa_reg {
+		u64 valid:1;
+		u64 ig:11;
+		u64 vpn:52;
+	} *ifa_reg;
+	struct itir_reg {
+		u64 rv1:2;
+		u64 ps:6;
+		u64 key:24;
+		u64 rv2:32;
+	} *itir_reg;
+	struct gr_reg {
+		u64 p:1;
+		u64 rv1:1;
+		u64 ma:3;
+		u64 a:1;
+		u64 d:1;
+		u64 pl:2;
+		u64 ar:3;
+		u64 ppn:38;
+		u64 rv2:2;
+		u64 ed:1;
+		u64 ig:11;
+	} *gr_reg;
+	struct rid_reg {
+		u64 ig1:1;
+		u64 rv1:1;
+		u64 ig2:6;
+		u64 rid:24;
+		u64 rv2:32;
+	} *rid_reg;
=20
-        if (len <=3D off+count) *eof =3D 1;
+	if ((status=3Dia64_pal_vm_summary(&vm_info_1, &vm_info_2)) !=3D0) {
+		printk("ia64_pal_vm_summary=3D%ld\n", status);
+		return 0;
+	}
+	max[0] =3D vm_info_1.pal_vm_info_1_s.max_itr_entry+1;
+	max[1] =3D vm_info_1.pal_vm_info_1_s.max_dtr_entry+1;
=20
-        *start =3D page + off;
-        len   -=3D off;
+	for (i=3D0; i < 2; i++ ) {
+		for (j=3D0; j < max[i]; j++) {
=20
-        if (len>count) len =3D count;
-        if (len<0) len =3D 0;
+		status =3D ia64_pal_tr_read(j, i, tr_buffer, &tr_valid);
+		if (status !=3D 0) {
+			printk(__FUNCTION__ " pal call failed on tr[%d:%d]=3D%ld\n", i, j, stat=
us);
+			continue;
+		}
=20
-        return len;
+		ifa_reg  =3D (struct ifa_reg *)&tr_buffer[2];
+
+		if (ifa_reg->valid =3D 0) continue;
+
+		gr_reg   =3D (struct gr_reg *)tr_buffer;=09
+		itir_reg =3D (struct itir_reg *)&tr_buffer[1];
+		rid_reg  =3D (struct rid_reg *)&tr_buffer[3];
+
+		pgm	 =3D -1 << (itir_reg->ps - 12);
+		p +=3D sprintf(p, "%cTR%d: av=3D%d pv=3D%d dv=3D%d mv=3D%d\n" \
+				"\tppn  : 0x%lx\n" \
+				"\tvpn  : 0x%lx\n" \
+				"\tps   : ",
+
+				"ID"[i],
+				j,
+				tr_valid.pal_tr_valid_s.access_rights_valid,
+				tr_valid.pal_tr_valid_s.priv_level_valid,
+				tr_valid.pal_tr_valid_s.dirty_bit_valid,
+				tr_valid.pal_tr_valid_s.mem_attr_valid,
+				(gr_reg->ppn & pgm)<< 12,
+				(ifa_reg->vpn & pgm)<< 12);
+
+		p =3D bitvector_process(p, 1<< itir_reg->ps);
+
+		p +=3D sprintf(p, "\n\tpl   : %d\n" \
+				"\tar   : %d\n" \
+				"\trid  : %x\n" \
+				"\tp    : %d\n" \
+				"\tma   : %d\n" \
+				"\td    : %d\n",=20
+				gr_reg->pl,
+				gr_reg->ar,
+				rid_reg->rid,
+				gr_reg->p,
+				gr_reg->ma,
+				gr_reg->d);
+		}
+	}
+	return p - page;
 }
=20
+
+
 /*
- * List names,function pairs for every entry in /proc/palinfo
- * Must be terminated with the NULL,NULL entry.
+ * List {name,function} pairs for every entry in /proc/palinfo/cpu*
  */
 static palinfo_entry_t palinfo_entries[]=3D{
 	{ "version_info",	version_info, },
@@ -742,23 +879,175 @@
 	{ "processor_info",	processor_info, },
 	{ "perfmon_info",	perfmon_info, },
 	{ "frequency_info",	frequency_info, },
-	{ NULL,			NULL,}
+	{ "bus_info",		bus_info },
+	{ "tr_info",		tr_info, }
 };
=20
+#define NR_PALINFO_ENTRIES	(sizeof(palinfo_entries)/sizeof(palinfo_entry_t=
))
+
+/*
+ * this array is used to keep track of the proc entries we create. This is=
=20
+ * required in the module mode when we need to remove all entries. The pro=
cfs code
+ * does not do recursion of deletion
+ *
+ * Notes:
+ *	- first +1 accounts for the cpuN entry
+ *	- second +1 account for toplevel palinfo
+ *=20
+ */
+#define NR_PALINFO_PROC_ENTRIES	(NR_CPUS*(NR_PALINFO_ENTRIES+1)+1)
+
+static struct proc_dir_entry *palinfo_proc_entries[NR_PALINFO_PROC_ENTRIES=
];
+
+/*
+ * This data structure is used to pass which cpu,function is being request=
ed
+ * It must fit in a 64bit quantity to be passed to the proc callback routi=
ne
+ *
+ * In SMP mode, when we get a request for another CPU, we must call that
+ * other CPU using IPI and wait for the result before returning.
+ */
+typedef union {
+	u64 value;
+	struct {
+		unsigned	req_cpu: 32;	/* for which CPU this info is */
+		unsigned	func_id: 32;	/* which function is requested */
+	} pal_func_cpu;
+} pal_func_cpu_u_t;
+
+#define req_cpu	pal_func_cpu.req_cpu
+#define func_id pal_func_cpu.func_id
+
+#ifdef CONFIG_SMP
+
+/*
+ * used to hold information about final function to call=20
+ */
+typedef struct {
+	palinfo_func_t	func;	/* pointer to function to call */
+	char		*page;	/* buffer to store results */
+	int		ret;	/* return value from call */
+} palinfo_smp_data_t;
+
+
+/*
+ * this function does the actual final call and he called
+ * from the smp code, i.e., this is the palinfo callback routine
+ */
+static void
+palinfo_smp_call(void *info)
+{
+	palinfo_smp_data_t *data =3D (palinfo_smp_data_t *)info;
+	/* printk(__FUNCTION__" called on CPU %d\n", smp_processor_id());*/
+	if (data =3D NULL) {
+		printk(KERN_ERR __FUNCTION__" data pointer is NULL\n");
+		data->ret =3D 0; /* no output */
+		return;
+	}
+	/* does this actual call */
+	data->ret =3D (*data->func)(data->page);
+}
+
+/*
+ * function called to trigger the IPI, we need to access a remote CPU
+ * Return:
+ *	0 : error or nothing to output
+ *	otherwise how many bytes in the "page" buffer were written
+ */
+static=20
+int palinfo_handle_smp(pal_func_cpu_u_t *f, char *page)
+{
+	palinfo_smp_data_t ptr;
+	int ret;
+
+	ptr.func =3D palinfo_entries[f->func_id].proc_read;
+	ptr.page =3D page;
+	ptr.ret  =3D 0; /* just in case */
+
+	/*printk(__FUNCTION__" calling CPU %d from CPU %d for function %d\n", f->=
req_cpu,smp_processor_id(), f->func_id);*/
+
+	/* will send IPI to other CPU and wait for completion of remote call */
+	if ((ret=3Dsmp_call_function_single(f->req_cpu, palinfo_smp_call, &ptr, 0=
, 1))) {
+		printk(__FUNCTION__" remote CPU call from %d to %d on function %d: error=
 %d\n", smp_processor_id(), f->req_cpu, f->func_id, ret);
+		return 0;
+	}
+	return ptr.ret;
+}
+#else /* ! CONFIG_SMP */
+static=20
+int palinfo_handle_smp(pal_func_cpu_u_t *f, char *page)
+{
+	printk(__FUNCTION__" should not be called with non SMP kernel\n");
+	return 0;
+}
+#endif /* CONFIG_SMP */
+
+/*
+ * Entry point routine: all calls go through this function
+ */
+static int
+palinfo_read_entry(char *page, char **start, off_t off, int count, int *eo=
f, void *data)
+{
+	int len=3D0;
+	pal_func_cpu_u_t *f =3D (pal_func_cpu_u_t *)&data;
+
+	/*
+	 * in SMP mode, we may need to call another CPU to get correct
+	 * information. PAL, by definition, is processor specific
+	 */
+	if (f->req_cpu =3D smp_processor_id())=20
+		len =3D (*palinfo_entries[f->func_id].proc_read)(page);
+	else
+		len =3D palinfo_handle_smp(f, page);
+
+        if (len <=3D off+count) *eof =3D 1;
+
+        *start =3D page + off;
+        len   -=3D off;
+
+        if (len>count) len =3D count;
+        if (len<0) len =3D 0;
+
+        return len;
+}
=20
 static int __init=20
 palinfo_init(void)
 {
+#	define CPUSTR	"cpu%d"
+
 	palinfo_entry_t *p;
+	pal_func_cpu_u_t f;
+	struct proc_dir_entry **pdir =3D palinfo_proc_entries;
+	struct proc_dir_entry *palinfo_dir, *cpu_dir;
+	int i, j;
+	char cpustr[sizeof(CPUSTR)];
=20
 	printk(KERN_INFO "PAL Information Facility v%s\n", PALINFO_VERSION);
=20
-	palinfo_dir =3D create_proc_entry("palinfo",  S_IFDIR | S_IRUGO | S_IXUGO=
, NULL);
+	palinfo_dir =3D proc_mkdir("pal", NULL);
=20
-	for (p =3D palinfo_entries; p->name ; p++){
-		p->entry =3D create_proc_read_entry (p->name, 0, palinfo_dir,=20
-						   palinfo_read_entry, p->proc_read);
+	/*
+	 * we keep track of created entries in a depth-first order for
+	 * cleanup purposes. Each entry is stored into palinfo_proc_entries
+	 */
+	for (i=3D0; i < NR_CPUS; i++) {
+
+		if (!cpu_is_online(i)) continue;
+
+		sprintf(cpustr,CPUSTR, i);
+
+		cpu_dir =3D proc_mkdir(cpustr, palinfo_dir);
+
+		f.req_cpu =3D i;
+
+		for (j=3D0; j < NR_PALINFO_ENTRIES; j++) {
+			f.func_id =3D j;
+			*pdir++ =3D create_proc_read_entry (palinfo_entries[j].name, 0, cpu_dir=
,=20
+						palinfo_read_entry, (void *)f.value);
+		}
+		*pdir++ =3D cpu_dir;
 	}
+	*pdir =3D palinfo_dir;
=20
 	return 0;
 }
@@ -766,12 +1055,12 @@
 static int __exit
 palinfo_exit(void)
 {
-	palinfo_entry_t *p;
+	int i =3D 0;
=20
-	for (p =3D palinfo_entries; p->name ; p++){
-		remove_proc_entry (p->name, palinfo_dir);
+	/* remove all nodes: depth first pass */
+	for (i=3D0; i< NR_PALINFO_PROC_ENTRIES ; i++) {
+		remove_proc_entry (palinfo_proc_entries[i]->name, NULL);
 	}
-	remove_proc_entry ("palinfo", 0);
=20
 	return 0;
 }
diff -urN linux-davidm/arch/ia64/kernel/pci-dma.c linux-2.4.0-test4-lia/arc=
h/ia64/kernel/pci-dma.c
--- linux-davidm/arch/ia64/kernel/pci-dma.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/pci-dma.c	Fri Jul 28 23:10:22 20=
00
@@ -3,34 +3,424 @@
  *
  * This implementation is for IA-64 platforms that do not support
  * I/O TLBs (aka DMA address translation hardware).
- *
- * XXX This doesn't do the right thing yet.  It appears we would have
- * to add additional zones so we can implement the various address
- * mask constraints that we might encounter.  A zone for memory < 32
- * bits is obviously necessary...
+ * Goutham Rao <goutham.rao@intel.com>: Implemented the PCI DMA mapping AP=
I.
  */
=20
-#include <linux/types.h>
+#include <linux/config.h>
+
 #include <linux/mm.h>
-#include <linux/string.h>
 #include <linux/pci.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/types.h>
=20
 #include <asm/io.h>
+#include <asm/pci.h>
+#include <asm/dma.h>
+
+#ifdef CONFIG_SWIOTLB
+
+#include <linux/init.h>
+#include <linux/bootmem.h>
+
+#define ALIGN(val, align) ((void *) (((unsigned long) (val) + ((align) - 1=
)) & ~((align) - 1)))
+
+typedef struct io_tlb_sizes {
+	size_t		size;
+	int		log_size;
+	int		n_buffers;
+	int		curr_index;
+	spinlock_t	lock;
+	char		*base;
+	unsigned long	*orig_addr;
+	unsigned int	*free_list;
+} io_tlb_sizes_t;
+
+/*
+ * List entries in order of size (low to high)
+ */
+static io_tlb_sizes_t io_tlb[] =3D {
+	{2048, 11, 128, 127, SPIN_LOCK_UNLOCKED, 0, 0, 0},
+	{PAGE_SIZE, PAGE_SHIFT, 128, 127, SPIN_LOCK_UNLOCKED, 0, 0, 0},
+	/*
+	 * Indicated end of entries
+	 */=09
+	{0, 0, 0, 0, SPIN_LOCK_UNLOCKED, 0, 0, 0}
+};
+
+/*
+ * Used to do a quick range check in pci_unmap_single and pci_sync_single
+ */
+static char *io_tlb_start, *io_tlb_end;
+
+static unsigned long swiotlb_buf_count;
+
+static int __init
+setup_swiotlb_buf_count (char *str)
+{
+	swiotlb_buf_count =3D simple_strtoul(str, NULL, 0);
+	return 1;
+}
+
+__setup("swiotlb=3D", setup_swiotlb_buf_count);
+
+/*
+ * Statically reserve bounce buffer space and initialize bounce buffer
+ * data structures for the software IO TLB used to implement the PCI DMA A=
PI
+ */
+void
+setup_swiotlb (void)
+{
+	unsigned long entry_size, size =3D 0;
+	struct io_tlb_sizes *itp;
+
+	for (itp =3D io_tlb; itp->size; ++itp) {
+		/*
+		 * Let user override number of buffers needed
+		 */
+		if (swiotlb_buf_count)
+			itp->n_buffers =3D swiotlb_buf_count;
+		itp->curr_index =3D itp->n_buffers - 1;
+		/*
+		 * size needed for buffers + size needed for offset
+		 * table + size needed for mapping:
+		 */
+		entry_size =3D itp->size + sizeof(int) + sizeof(long);
+		/* the +1 makes room for the worst-case alignment... */
+		size +=3D (itp->n_buffers + 1)*entry_size;
+	}
+
+	/*
+	 * Now get IO TLB memory from the low pages
+	 */
+	io_tlb_start =3D io_tlb_end =3D alloc_bootmem_low_pages(size);
+	if (!io_tlb_start)
+		BUG();
+
+	/*
+	 * For every io tlb size entry, allocate the required amount of memory
+	 * and initialize the free list array to mark all entries as available
+	 */
+	for (itp =3D io_tlb; itp->size; ++itp) {
+		int j;
+
+		/*
+		 * Reserve memory for the IO TLB buffers and the
+		 * offsets array for these size chunks
+		 */
+		itp->base =3D ALIGN(io_tlb_end, itp->size);
+		io_tlb_end =3D itp->base + itp->size * itp->n_buffers;
+
+		itp->orig_addr =3D ALIGN(io_tlb_end, sizeof(long));
+		io_tlb_end =3D ((char *)itp->orig_addr) + itp->n_buffers * sizeof(long);
+
+		itp->free_list =3D (unsigned int *)io_tlb_end;
+		io_tlb_end =3D ((char *)itp->free_list) + itp->n_buffers * sizeof(int);
+
+		/*=20
+		 * Initialize free list array, marking all entries available
+		 */=09
+		for (j =3D 0; j < itp->n_buffers; j++)
+			itp->free_list[j] =3D (unsigned int)(j * itp->size);
+	}
+	printk("Placing software IO TLB between 0x%p - 0x%p\n", io_tlb_start, io_=
tlb_end);
+}
+
+/*
+ * Allocates bounce buffer and returns its kernel virtual address.
+ */
+static void *
+__pci_map_single (struct pci_dev *hwdev, char *buffer, size_t size, int di=
rection)
+{
+	struct io_tlb_sizes *itp;
+	char *dma_addr =3D 0;
+	int index;
+
+	/*
+	 * Find a IO TLB size that will fit this request and allocate a buffer
+	 * from that IO TLB pool.
+	 */
+	for (itp =3D io_tlb; itp->size; ++itp) {
+		if (size <=3D itp->size) {
+			unsigned long flags;
+
+			spin_lock_irqsave(&itp->lock, flags);
+			{
+				if (!itp->curr_index) {
+					/*
+					 * Get buffer from next IO TLB... this will
+					 * waste memory though.
+					 */
+					spin_unlock_irqrestore(&itp->lock, flags);
+					continue;
+				}
+				dma_addr =3D (itp->base + itp->free_list[itp->curr_index--]);
+			}
+			spin_unlock_irqrestore(&itp->lock, flags);
+			/*
+			 * Save the mapping from original address to DMA address
+			 * because the map_single API doesen't have a mapping=20
+			 * like the map_sg API.
+			 */
+			index =3D (dma_addr - itp->base) >> itp->log_size;
+			itp->orig_addr[index] =3D (unsigned long) buffer;
+
+			if (direction =3D PCI_DMA_TODEVICE || direction =3D PCI_DMA_BIDIRECTION=
AL)
+				memcpy(dma_addr, buffer, size);
+
+			return dma_addr;
+		}
+	}
+
+	/*
+	 * XXX What is a suitable recovery mechanism here?  We cannot=20
+	 * sleep because we are called from with in interrupts!
+	 */
+	panic("__pci_map_single: could not allocate software IO TLB (%ld bytes)",=
 size);
+}
+
+/*
+ * dma_addr is the kernel virtual address of the bounce buffer to unmap.
+ */
+static void
+__pci_unmap_single (struct pci_dev *hwdev, char *dma_addr, size_t size, in=
t direction)
+{
+	struct io_tlb_sizes *itp;
+
+	/*
+	 * Return the buffer to the free list
+	 */
+	for (itp =3D io_tlb; itp->size; ++itp) {
+		if (size <=3D itp->size) {
+			unsigned long flags;
+			char *buffer;
+			int index;
+
+			/*
+	 	 	 * Get the mapping (IO address to original address)...=20
+		 	 */
+			index =3D (dma_addr - itp->base) >> itp->log_size;
+			buffer =3D (char *) itp->orig_addr[index];
+			if ((direction =3D PCI_DMA_FROMDEVICE)
+			    || (direction =3D PCI_DMA_BIDIRECTIONAL))
+				/*
+ 	 	 		 * bounce... copy the data back into the original buffer
+	 	 		 * and delete the bounce buffer.
+ 	 	 		 */
+				memcpy(buffer, dma_addr, size);
+
+			/*
+			 * Return the entry to the list
+			 */
+			spin_lock_irqsave(&itp->lock, flags);
+			{
+				itp->free_list[++itp->curr_index] =3D (dma_addr - itp->base);
+			}
+			spin_unlock_irqrestore(&itp->lock, flags);
+			return;
+		}
+	}
+	BUG();
+}
+
+static void
+__pci_sync_single (struct pci_dev *hwdev, char *dma_addr, size_t size, int=
 direction)
+{
+	struct io_tlb_sizes *itp;
+	char *buffer;
+	int index;
+
+	/*
+  	 * bounce... copy the data back into/from the original buffer
+	 * XXX How do you handle PCI_DMA_BIDIRECTIONAL here ?
+ 	 */
+	for (itp =3D io_tlb; itp->size; ++itp) {
+		if (size <=3D itp->size) {
+			/*
+	 	 	 * Get the mapping (IO address to original address)...=20
+		 	 */
+			index =3D (dma_addr - itp->base) >> itp->log_size;
+			buffer =3D (char *) itp->orig_addr[index];
+			if (direction =3D PCI_DMA_FROMDEVICE)
+				memcpy(buffer, dma_addr, size);
+			else if (direction =3D PCI_DMA_TODEVICE)
+				memcpy(dma_addr, buffer, size);
+			else
+				BUG();
+			break;
+		}
+	}
+}
+
+/*
+ * Map a single buffer of the indicated size for DMA in streaming mode.
+ * The PCI address to use is returned.
+ *
+ * Once the device is given the dma address, the device owns this memory
+ * until either pci_unmap_single or pci_dma_sync_single is performed.
+ */
+dma_addr_t
+pci_map_single (struct pci_dev *hwdev, void *ptr, size_t size, int directi=
on)
+{
+	unsigned long pci_addr =3D virt_to_phys(ptr);
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+	/*
+	 * Check if the PCI device can DMA to ptr... if so, just return ptr
+	 */
+	if ((pci_addr & ~hwdev->dma_mask) =3D 0)
+		/*
+		 * Device is bit capable of DMA'ing to the
+		 * buffer... just return the PCI address of ptr
+		 */
+		return pci_addr;
+
+	/* get a bounce buffer: */
+
+	pci_addr =3D virt_to_phys(__pci_map_single(hwdev, ptr, size, direction));
+	/*
+	 * Ensure that the address returned is DMA'ble:
+	 */
+	if ((pci_addr & ~hwdev->dma_mask) !=3D 0)
+		panic("__pci_map_single: bounce buffer is not DMA'ble");
+
+	return pci_addr;
+}
+
+/*
+ * Unmap a single streaming mode DMA translation.  The dma_addr and size
+ * must match what was provided for in a previous pci_map_single call.  All
+ * other usages are undefined.
+ *
+ * After this call, reads by the cpu to the buffer are guarenteed to see
+ * whatever the device wrote there.
+ */
+void
+pci_unmap_single (struct pci_dev *hwdev, dma_addr_t pci_addr, size_t size,=
 int direction)
+{
+	char *dma_addr =3D phys_to_virt(pci_addr);
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+	if (dma_addr >=3D io_tlb_start && dma_addr < io_tlb_end)
+		__pci_unmap_single(hwdev, dma_addr, size, direction);
+}
+
+/*
+ * Make physical memory consistent for a single
+ * streaming mode DMA translation after a transfer.
+ *
+ * If you perform a pci_map_single() but wish to interrogate the
+ * buffer using the cpu, yet do not wish to teardown the PCI dma
+ * mapping, you must call this function before doing so.  At the
+ * next point you give the PCI dma address back to the card, the
+ * device again owns the buffer.
+ */
+void
+pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t pci_addr, size_t si=
ze, int direction)
+{
+	char *dma_addr =3D phys_to_virt(pci_addr);
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+	if (dma_addr >=3D io_tlb_start && dma_addr < io_tlb_end)
+		__pci_sync_single(hwdev, dma_addr, size, direction);
+}
+
+/*
+ * Map a set of buffers described by scatterlist in streaming
+ * mode for DMA.  This is the scather-gather version of the
+ * above pci_map_single interface.  Here the scatter gather list
+ * elements are each tagged with the appropriate dma address
+ * and length.  They are obtained via sg_dma_{address,length}(SG).
+ *
+ * NOTE: An implementation may be able to use a smaller number of
+ *       DMA address/length pairs than there are SG table elements.
+ *       (for example via virtual mapping capabilities)
+ *       The routine returns the number of addr/length pairs actually
+ *       used, at most nents.
+ *
+ * Device ownership issues as mentioned above for pci_map_single are
+ * the same here.
+ */
+int
+pci_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, int=
 direction)
+{
+	int i;
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	for (i =3D 0; i < nelems; i++, sg++) {
+		sg->orig_address =3D sg->address;
+		if ((virt_to_phys(sg->address) & ~hwdev->dma_mask) !=3D 0) {
+			sg->address =3D __pci_map_single(hwdev, sg->address, sg->length, direct=
ion);
+		}
+	}
+	return nelems;
+}
+
+/*
+ * Unmap a set of streaming mode DMA translations.
+ * Again, cpu read rules concerning calls here are the same as for
+ * pci_unmap_single() above.
+ */
+void
+pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, i=
nt direction)
+{
+	int i;
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	for (i =3D 0; i < nelems; i++, sg++)
+		if (sg->orig_address !=3D sg->address) {
+			__pci_unmap_single(hwdev, sg->address, sg->length, direction);
+			sg->address =3D sg->orig_address;
+		}
+}
+
+/*
+ * Make physical memory consistent for a set of streaming mode DMA
+ * translations after a transfer.
+ *
+ * The same as pci_dma_sync_single but for a scatter-gather list,
+ * same rules and usage.
+ */
+void
+pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems=
, int direction)
+{
+	int i;
+
+	if (direction =3D PCI_DMA_NONE)
+		BUG();
+
+	for (i =3D 0; i < nelems; i++, sg++)
+		if (sg->orig_address !=3D sg->address)
+			__pci_sync_single(hwdev, sg->address, sg->length, direction);
+}
+
+#endif /* CONFIG_SWIOTLB */
=20
 void *
 pci_alloc_consistent (struct pci_dev *hwdev, size_t size, dma_addr_t *dma_=
handle)
 {
-	void *ret;
+	unsigned long pci_addr;
 	int gfp =3D GFP_ATOMIC;
+	void *ret;
=20
-	if (!hwdev || hwdev->dma_mask =3D 0xffffffff)
-		gfp |=3D GFP_DMA;	/* XXX fix me: should change this to GFP_32BIT or ZONE=
_32BIT */
+	if (!hwdev || hwdev->dma_mask <=3D 0xffffffff)
+		gfp |=3D GFP_DMA; /* XXX fix me: should change this to GFP_32BIT or ZONE=
_32BIT */
 	ret =3D (void *)__get_free_pages(gfp, get_order(size));
+	if (!ret)
+		return NULL;
=20
-	if (ret) {
-		memset(ret, 0, size);
-		*dma_handle =3D virt_to_bus(ret);
-	}
+	memset(ret, 0, size);
+	pci_addr =3D virt_to_phys(ret);
+	if ((pci_addr & ~hwdev->dma_mask) !=3D 0)
+		panic("pci_alloc_consistent: allocated memory is out of range for PCI de=
vice");
+	*dma_handle =3D pci_addr;
 	return ret;
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.0-test4-lia/arc=
h/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/process.c	Fri Jul 28 23:10:40 20=
00
@@ -532,17 +532,6 @@
 	}
 }
=20
-/*
- * Free remaining state associated with DEAD_TASK.  This is called
- * after the parent of DEAD_TASK has collected the exist status of the
- * task via wait().
- */
-void
-release_thread (struct task_struct *dead_task)
-{
-	/* nothing to do */
-}
-
 unsigned long
 get_wchan (struct task_struct *p)
 {
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.0-test4-lia/arch=
/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/ptrace.c	Fri Jul 28 23:10:52 2000
@@ -549,6 +549,7 @@
 ia64_sync_fph (struct task_struct *child)
 {
 	if (ia64_psr(ia64_task_regs(child))->mfh && ia64_get_fpu_owner() =3D chil=
d) {
+		ia64_psr(ia64_task_regs(child))->mfh =3D 0;
 		ia64_set_fpu_owner(0);
 		ia64_save_fpu(&child->thread.fph[0]);
 		child->thread.flags |=3D IA64_THREAD_FPH_VALID;
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test4-lia/arch/=
ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/setup.c	Fri Jul 28 23:11:03 2000
@@ -122,6 +122,10 @@
 	 */
 	memcpy(&ia64_boot_param, (void *) ZERO_PAGE_ADDR, sizeof(ia64_boot_param)=
);
=20
+	*cmdline_p =3D __va(ia64_boot_param.command_line);
+	strncpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
+	saved_command_line[COMMAND_LINE_SIZE-1] =3D '\0';		/* for safety */
+
 	efi_init();
=20
 	max_pfn =3D 0;
@@ -164,27 +168,21 @@
 	/* process SAL system table: */
 	ia64_sal_init(efi.sal_systab);
=20
-	*cmdline_p =3D __va(ia64_boot_param.command_line);
-	strncpy(saved_command_line, *cmdline_p, sizeof(saved_command_line));
-	saved_command_line[COMMAND_LINE_SIZE-1] =3D '\0';		/* for safety */
-
-	printk("args to kernel: %s\n", *cmdline_p);
-
 #ifdef CONFIG_SMP
 	bootstrap_processor =3D hard_smp_processor_id();
 	current->processor =3D bootstrap_processor;
 #endif
 	cpu_init();	/* initialize the bootstrap CPU */
=20
+#ifdef CONFIG_IA64_GENERIC
+	machvec_init(acpi_get_sysname());
+#endif
+
 	if (efi.acpi) {
 		/* Parse the ACPI tables */
 		acpi_parse(efi.acpi);
 	}
=20
-#ifdef CONFIG_IA64_GENERIC
-	machvec_init(acpi_get_sysname());
-#endif
-
 #ifdef CONFIG_VT
 # if defined(CONFIG_VGA_CONSOLE)
 	conswitchp =3D &vga_con;
@@ -197,8 +195,16 @@
 	/* enable IA-64 Machine Check Abort Handling */
 	ia64_mca_init();
 #endif
+
 	paging_init();
 	platform_setup(cmdline_p);
+
+#ifdef CONFIG_SWIOTLB
+	{
+		extern void setup_swiotlb (void);
+		setup_swiotlb();
+	}
+#endif
 }
=20
 /*
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-test4-lia/arch/ia=
64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/smp.c	Fri Jul 28 23:11:44 2000
@@ -320,6 +320,58 @@
 #endif	/* !CONFIG_ITANIUM_PTCG */
=20
 /*
+ * Run a function on another CPU
+ *  <func>	The function to run. This must be fast and non-blocking.
+ *  <info>	An arbitrary pointer to pass to the function.
+ *  <retry>	If true, keep retrying until ready.
+ *  <wait>	If true, wait until function has completed on other CPUs.
+ *  [RETURNS]   0 on success, else a negative status code.
+ *
+ * Does not return until the remote CPU is nearly ready to execute <func>
+ * or is or has executed.
+ */
+
+int
+smp_call_function_single (int cpuid, void (*func) (void *info), void *info=
, int retry, int wait)
+{
+	struct smp_call_struct data;
+	long timeout;
+	int cpus =3D 1;
+
+	if (cpuid =3D smp_processor_id()) {
+		printk(__FUNCTION__" trying to call self\n");
+		return -EBUSY;
+	}
+=09
+	data.func =3D func;
+	data.info =3D info;
+	data.wait =3D wait;
+	atomic_set(&data.unstarted_count, cpus);
+	atomic_set(&data.unfinished_count, cpus);
+
+	if (pointer_lock(&smp_call_function_data, &data, retry))
+		return -EBUSY;
+
+	/*  Send a message to all other CPUs and wait for them to respond  */
+	send_IPI_single(cpuid, IPI_CALL_FUNC);
+
+	/*  Wait for response  */
+	timeout =3D jiffies + HZ;
+	while ((atomic_read(&data.unstarted_count) > 0) && time_before(jiffies, t=
imeout))
+		barrier();
+	if (atomic_read(&data.unstarted_count) > 0) {
+		smp_call_function_data =3D NULL;
+		return -ETIMEDOUT;
+	}
+	if (wait)
+		while (atomic_read(&data.unfinished_count) > 0)
+			barrier();
+	/* unlock pointer */
+	smp_call_function_data =3D NULL;
+	return 0;
+}
+
+/*
  * Run a function on all other CPUs.
  *  <func>	The function to run. This must be fast and non-blocking.
  *  <info>	An arbitrary pointer to pass to the function.
@@ -497,6 +549,8 @@
 	extern void ia64_rid_init(void);
 	extern void ia64_init_itm(void);
 	extern void ia64_cpu_local_tick(void);
+
+	efi_map_pal_code();
=20
 	cpu_init();
=20
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.0-test4-lia/arch/i=
a64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/time.c	Fri Jul 28 23:12:00 2000
@@ -150,11 +150,13 @@
 static void
 timer_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
-	static unsigned long last_time;
-	static unsigned char count;
 	int cpu =3D smp_processor_id();
 	unsigned long new_itm;
+#if 0
+	static unsigned long last_time;
+	static unsigned char count;
 	int printed =3D 0;
+#endif
=20
 	/*
 	 * Here we are in the timer irq handler. We have irqs locally
@@ -192,7 +194,7 @@
 		if (time_after(new_itm, ia64_get_itc()))
 			break;
=20
-#if !(defined(CONFIG_IA64_SOFTSDV_HACKS) && defined(CONFIG_SMP))
+#if 0
 		/*
 		 * SoftSDV in SMP mode is _slow_, so we do "lose" ticks,=20
 		 * but it's really OK...
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.0-test4-lia/arch/=
ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-test4-lia/arch/ia64/kernel/traps.c	Fri Jul 28 23:12:31 2000
@@ -204,11 +204,13 @@
 {
 	struct task_struct *fpu_owner =3D ia64_get_fpu_owner();
=20
+	/* first, clear psr.dfh and psr.mfh: */
 	regs->cr_ipsr &=3D ~(IA64_PSR_DFH | IA64_PSR_MFH);
 	if (fpu_owner !=3D current) {
 		ia64_set_fpu_owner(current);
=20
 		if (fpu_owner && ia64_psr(ia64_task_regs(fpu_owner))->mfh) {
+			ia64_psr(ia64_task_regs(fpu_owner))->mfh =3D 0;
 			fpu_owner->thread.flags |=3D IA64_THREAD_FPH_VALID;
 			__ia64_save_fpu(fpu_owner->thread.fph);
 		}
@@ -216,6 +218,11 @@
 			__ia64_load_fpu(current->thread.fph);
 		} else {
 			__ia64_init_fpu();
+			/*
+			 * Set mfh because the state in thread.fph does not match
+			 * the state in the fph partition.
+			 */
+			ia64_psr(regs)->mfh =3D 1;
 		}
 	}
 }
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test4-lia/arch/ia64/=
mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test4-lia/arch/ia64/mm/init.c	Fri Jul 28 23:13:48 2000
@@ -423,5 +423,4 @@
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_gdt_init();
 #endif
-	return;
 }
diff -urN linux-davidm/arch/ia64/sn/sn1/irq.c linux-2.4.0-test4-lia/arch/ia=
64/sn/sn1/irq.c
--- linux-davidm/arch/ia64/sn/sn1/irq.c	Tue Feb  8 12:01:59 2000
+++ linux-2.4.0-test4-lia/arch/ia64/sn/sn1/irq.c	Fri Jul 28 23:13:59 2000
@@ -1,9 +1,10 @@
 #include <linux/kernel.h>
+#include <linux/irq.h>
+#include <linux/sched.h>
=20
-#include <asm/irq.h>
 #include <asm/ptrace.h>
=20
-static int
+static unsigned int
 sn1_startup_irq(unsigned int irq)
 {
         return(0);
@@ -24,23 +25,16 @@
 {
 }
=20
-static int
-sn1_handle_irq(unsigned int irq, struct pt_regs *regs)
-{
-       return(0);
-}
-
 struct hw_interrupt_type irq_type_sn1 =3D {
         "sn1_irq",
         sn1_startup_irq,
         sn1_shutdown_irq,
-        sn1_handle_irq,
         sn1_enable_irq,
         sn1_disable_irq
 };
=20
 void
-sn1_irq_init (struct irq_desc desc[NR_IRQS])
+sn1_irq_init (void)
 {
 	int i;
=20
diff -urN linux-davidm/arch/ia64/sn/sn1/machvec.c linux-2.4.0-test4-lia/arc=
h/ia64/sn/sn1/machvec.c
--- linux-davidm/arch/ia64/sn/sn1/machvec.c	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test4-lia/arch/ia64/sn/sn1/machvec.c	Fri Jul 28 23:14:09 20=
00
@@ -1,4 +1,2 @@
+#define MACHVEC_PLATFORM_NAME	sn1
 #include <asm/machvec_init.h>
-#include <asm/machvec_sn1.h>
-
-MACHVEC_DEFINE(sn1)
diff -urN linux-davidm/arch/ia64/sn/sn1/setup.c linux-2.4.0-test4-lia/arch/=
ia64/sn/sn1/setup.c
--- linux-davidm/arch/ia64/sn/sn1/setup.c	Mon May  8 22:00:01 2000
+++ linux-2.4.0-test4-lia/arch/ia64/sn/sn1/setup.c	Fri Jul 28 23:25:02 2000
@@ -13,6 +13,7 @@
 #include <linux/console.h>
 #include <linux/timex.h>
 #include <linux/sched.h>
+#include <linux/ioport.h>
=20
 #include <asm/io.h>
 #include <asm/machvec.h>
diff -urN linux-davidm/arch/ia64/vmlinux.lds.S linux-2.4.0-test4-lia/arch/i=
a64/vmlinux.lds.S
--- linux-davidm/arch/ia64/vmlinux.lds.S	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/arch/ia64/vmlinux.lds.S	Fri Jul 28 23:15:14 2000
@@ -46,6 +46,15 @@
 	{ *(__ex_table) }
   __stop___ex_table =3D .;
=20
+#if defined(CONFIG_IA64_GENERIC)
+  /* Machine Vector */
+  . =3D ALIGN(16);
+  machvec_start =3D .;
+  .machvec : AT(ADDR(.machvec) - PAGE_OFFSET)
+	{ *(.machvec) }
+  machvec_end =3D .;
+#endif
+
   __start___ksymtab =3D .;	/* Kernel symbol table */
   __ksymtab : AT(ADDR(__ksymtab) - PAGE_OFFSET)
 	{ *(__ksymtab) }
diff -urN linux-davidm/drivers/net/eepro100.c linux-2.4.0-test4-lia/drivers=
/net/eepro100.c
--- linux-davidm/drivers/net/eepro100.c	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/drivers/net/eepro100.c	Fri Jul 28 23:15:43 2000
@@ -23,6 +23,8 @@
 		Convert to new PCI driver interface
 	2000 Mar 24  Dragan Stancevic <visitor@valinux.com>
 		Disabled FC and ER, to avoid lockups when when we get FCP interrupts.
+	2000 Jul 17 Goutham Rao <goutham.rao@intel.com>
+		PCI DMA API fixes, adding pci_dma_sync_single calls where neccesary
 */
=20
 static const char *version @@ -524,6 +526,7 @@
 	spinlock_t lock;					/* Group with Tx control cache line. */
 	u32 tx_threshold;					/* The value for txdesc.count. */
 	struct RxFD *last_rxf;				/* Last filled RX buffer. */
+	dma_addr_t last_rxf_dma;
 	unsigned int cur_rx, dirty_rx;		/* The next free ring entry */
 	long last_rx_time;			/* Last Rx, in jiffies, to handle Rx hang. */
 	const char *product_name;
@@ -1219,19 +1222,24 @@
 		sp->rx_ring_dma[i]  			pci_map_single(sp->pdev, rxf, PKT_BUF_SZ + sizeof=
(struct RxFD), PCI_DMA_FROMDEVICE);
 		skb_reserve(skb, sizeof(struct RxFD));
-		if (last_rxf)
+		if (last_rxf) {
 			last_rxf->link =3D cpu_to_le32(sp->rx_ring_dma[i]);
+			pci_dma_sync_single(sp->pdev, sp->rx_ring_dma[i-1], sizeof(struct RxFD)=
, PCI_DMA_TODEVICE);
+		}
 		last_rxf =3D rxf;
 		rxf->status =3D cpu_to_le32(0x00000001);	/* '1' is flag value only. */
 		rxf->link =3D 0;						/* None yet. */
 		/* This field unused by i82557. */
 		rxf->rx_buf_addr =3D 0xffffffff;
 		rxf->count =3D cpu_to_le32(PKT_BUF_SZ << 16);
+		pci_dma_sync_single(sp->pdev, sp->rx_ring_dma[i], sizeof(struct RxFD), P=
CI_DMA_TODEVICE);
 	}
 	sp->dirty_rx =3D (unsigned int)(i - RX_RING_SIZE);
 	/* Mark the last entry as end-of-list. */
 	last_rxf->status =3D cpu_to_le32(0xC0000002);	/* '2' is flag value only. =
*/
+	pci_dma_sync_single(sp->pdev, sp->rx_ring_dma[RX_RING_SIZE-1], sizeof(str=
uct RxFD), PCI_DMA_TODEVICE);
 	sp->last_rxf =3D last_rxf;
+	sp->last_rxf_dma =3D sp->rx_ring_dma[RX_RING_SIZE-1];
 }
=20
 static void speedo_purge_tx(struct net_device *dev)
@@ -1666,6 +1674,7 @@
 	skb->dev =3D dev;
 	skb_reserve(skb, sizeof(struct RxFD));
 	rxf->rx_buf_addr =3D 0xffffffff;
+	pci_dma_sync_single(sp->pdev, sp->rx_ring_dma[entry], sizeof(struct RxFD)=
, PCI_DMA_TODEVICE);
 	return rxf;
 }
=20
@@ -1678,7 +1687,9 @@
 	rxf->count =3D cpu_to_le32(PKT_BUF_SZ << 16);
 	sp->last_rxf->link =3D cpu_to_le32(rxf_dma);
 	sp->last_rxf->status &=3D cpu_to_le32(~0xC0000000);
+	pci_dma_sync_single(sp->pdev, sp->last_rxf_dma, sizeof(struct RxFD), PCI_=
DMA_TODEVICE);
 	sp->last_rxf =3D rxf;
+	sp->last_rxf_dma =3D rxf_dma;
 }
=20
 static int speedo_refill_rx_buf(struct net_device *dev, int force)
@@ -1744,9 +1755,17 @@
 	if (speedo_debug > 4)
 		printk(KERN_DEBUG " In speedo_rx().\n");
 	/* If we own the next entry, it's a new packet. Send it up. */
-	while (sp->rx_ringp[entry] !=3D NULL &&
-		   (status =3D le32_to_cpu(sp->rx_ringp[entry]->status)) & RxComplete) {
-		int pkt_len =3D le32_to_cpu(sp->rx_ringp[entry]->count) & 0x3fff;
+	while (sp->rx_ringp[entry] !=3D NULL) {
+		int pkt_len;
+
+		pci_dma_sync_single(sp->pdev, sp->rx_ring_dma[entry],
+			sizeof(struct RxFD), PCI_DMA_FROMDEVICE);
+
+		if(!((status =3D le32_to_cpu(sp->rx_ringp[entry]->status)) & RxComplete)=
) {
+			break;
+		}
+
+		pkt_len =3D le32_to_cpu(sp->rx_ringp[entry]->count) & 0x3fff;
=20
 		if (--rx_work_limit < 0)
 			break;
@@ -1788,7 +1807,8 @@
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 				/* 'skb_put()' points to the start of sk_buff data area. */
 				pci_dma_sync_single(sp->pdev, sp->rx_ring_dma[entry],
-						PKT_BUF_SZ + sizeof(struct RxFD), PCI_DMA_FROMDEVICE);
+					sizeof(struct RxFD) + pkt_len, PCI_DMA_FROMDEVICE);
+
 #if 1 || USE_IP_CSUM
 				/* Packet is in one chunk -- we can copy + cksum. */
 				eth_copy_and_sum(skb, sp->rx_skbuff[entry]->tail, pkt_len, 0);
@@ -2171,6 +2191,8 @@
 		/* Set the link in the setup frame. */
 		mc_setup_frm->link  			cpu_to_le32(TX_RING_ELEM_DMA(sp, (entry + 1) % TX=
_RING_SIZE));
+
+		pci_dma_sync_single(sp->pdev, mc_blk->frame_dma, mc_blk->len, PCI_DMA_TO=
DEVICE);
=20
 		wait_for_cmd_done(ioaddr + SCBCmd);
 		clear_suspend(last_cmd);
diff -urN linux-davidm/drivers/scsi/qla1280.c linux-2.4.0-test4-lia/drivers=
/scsi/qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Mon Jun 19 13:42:40 2000
+++ linux-2.4.0-test4-lia/drivers/scsi/qla1280.c	Fri Jul 28 23:15:55 2000
@@ -809,6 +809,7 @@
 			index++, &pci_bus, &pci_devfn)) )  {
 #endif
                 /* found a adapter */
+		template->unchecked_isa_dma =3D 1;
 		host =3D scsi_register(template, sizeof(scsi_qla_host_t));
 		ha =3D (scsi_qla_host_t *) host->hostdata;
 		/* Clear our data area */
diff -urN linux-davidm/fs/buffer.c linux-2.4.0-test4-lia/fs/buffer.c
--- linux-davidm/fs/buffer.c	Tue Jul 11 14:29:02 2000
+++ linux-2.4.0-test4-lia/fs/buffer.c	Fri Jul 28 23:16:06 2000
@@ -1620,9 +1620,9 @@
 						PAGE_CACHE_SIZE, get_block);
 		if (status)
 			goto out_unmap;
-		kaddr =3D (char*)page_address(page);
+		kaddr =3D (char*)page_address(new_page);
 		memset(kaddr+zerofrom, 0, PAGE_CACHE_SIZE-zerofrom);
-		__block_commit_write(inode, new_page, zerofrom, to);
+		__block_commit_write(inode, new_page, zerofrom, PAGE_CACHE_SIZE);
 		kunmap(new_page);
 		UnlockPage(new_page);
 		page_cache_release(new_page);
diff -urN linux-davidm/include/asm-ia64/acpi-ext.h linux-2.4.0-test4-lia/in=
clude/asm-ia64/acpi-ext.h
--- linux-davidm/include/asm-ia64/acpi-ext.h	Tue Feb  8 12:01:59 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/acpi-ext.h	Fri Jul 28 23:16:20 2=
000
@@ -69,7 +69,7 @@
 	u8 eid;
 } acpi_entry_lsapic_t;
=20
-typedef struct {
+typedef struct acpi_entry_iosapic {
 	u8 type;
 	u8 length;
 	u16 reserved;
diff -urN linux-davidm/include/asm-ia64/efi.h linux-2.4.0-test4-lia/include=
/asm-ia64/efi.h
--- linux-davidm/include/asm-ia64/efi.h	Fri Mar 10 15:24:02 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/efi.h	Fri Jul 28 23:40:25 2000
@@ -226,6 +226,7 @@
 }
=20
 extern void efi_init (void);
+extern void efi_map_pal_code (void);
 extern void efi_memmap_walk (efi_freemem_callback_t callback, void *arg);
 extern void efi_gettimeofday (struct timeval *tv);
 extern void efi_enter_virtual_mode (void);	/* switch EFI to virtual mode, =
if possible */
diff -urN linux-davidm/include/asm-ia64/ia32.h linux-2.4.0-test4-lia/includ=
e/asm-ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/ia32.h	Fri Jul 28 23:16:34 2000
@@ -40,7 +40,6 @@
        __kernel_off_t32 l_start;
        __kernel_off_t32 l_len;
        __kernel_pid_t32 l_pid;
-       short __unused;
 };
=20
=20
@@ -105,11 +104,21 @@
 } sigset32_t;
=20
 struct sigaction32 {
-       unsigned int  sa_handler;       /* Really a pointer, but need to de=
al=20
-					  with 32 bits */
+       unsigned int  sa_handler;	/* Really a pointer, but need to deal=20
+					     with 32 bits */
        unsigned int sa_flags;
-       unsigned int sa_restorer;       /* Another 32 bit pointer */
-       sigset32_t sa_mask;     /* A 32 bit mask */
+       unsigned int sa_restorer;	/* Another 32 bit pointer */
+       sigset32_t sa_mask;		/* A 32 bit mask */
+};
+
+typedef unsigned int old_sigset32_t;	/* at least 32 bits */
+
+struct old_sigaction32 {
+       unsigned int  sa_handler;	/* Really a pointer, but need to deal=20
+					     with 32 bits */
+       old_sigset32_t sa_mask;		/* A 32 bit mask */
+       unsigned int sa_flags;
+       unsigned int sa_restorer;	/* Another 32 bit pointer */
 };
=20
 typedef struct sigaltstack_ia32 {
diff -urN linux-davidm/include/asm-ia64/io.h linux-2.4.0-test4-lia/include/=
asm-ia64/io.h
--- linux-davidm/include/asm-ia64/io.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/io.h	Fri Jul 28 23:37:15 2000
@@ -47,6 +47,10 @@
 	return (void *) (address + PAGE_OFFSET);
 }
=20
+/*
+ * The following two macros are deprecated and scheduled for removal.
+ * Please use the PCI-DMA interface defined in <asm/pci.h> instead.
+ */
 #define bus_to_virt	phys_to_virt
 #define virt_to_bus	virt_to_phys
=20
@@ -315,6 +319,7 @@
 #define writeq(v,a)	__writeq((v), (void *) (a))
 #define __raw_writeb	writeb
 #define __raw_writew	writew
+#define __raw_writel	writel
 #define __raw_writeq	writeq
=20
 #ifndef inb_p
diff -urN linux-davidm/include/asm-ia64/machvec.h linux-2.4.0-test4-lia/inc=
lude/asm-ia64/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Fri Mar 10 15:24:02 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/machvec.h	Fri Jul 28 23:37:15 20=
00
@@ -4,8 +4,8 @@
  * Copyright (C) 1999 Silicon Graphics, Inc.
  * Copyright (C) Srinivasa Thirumalachar <sprasad@engr.sgi.com>
  * Copyright (C) Vijay Chander <vijay@engr.sgi.com>
- * Copyright (C) 1999 Hewlett-Packard Co.
- * Copyright (C) David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2000 Hewlett-Packard Co.
+ * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #ifndef _ASM_IA64_MACHVEC_H
 #define _ASM_IA64_MACHVEC_H
@@ -21,6 +21,7 @@
 struct task_struct;
 struct timeval;
 struct vm_area_struct;
+struct acpi_entry_iosapic;
=20
 typedef void ia64_mv_setup_t (char **);
 typedef void ia64_mv_irq_init_t (void);
@@ -30,15 +31,33 @@
 typedef void ia64_mv_mca_handler_t (void);
 typedef void ia64_mv_cmci_handler_t (int, void *, struct pt_regs *);
 typedef void ia64_mv_log_print_t (void);
+typedef void ia64_mv_register_iosapic_t (struct acpi_entry_iosapic *);
+
+extern void machvec_noop (void);
=20
 # if defined (CONFIG_IA64_HP_SIM)
 #  include <asm/machvec_hpsim.h>
 # elif defined (CONFIG_IA64_DIG)
 #  include <asm/machvec_dig.h>
 # elif defined (CONFIG_IA64_SGI_SN1_SIM)
-#  include <asm/machvec_sgi_sn1_SIM.h>
+#  include <asm/machvec_sgi_sn1.h>
 # elif defined (CONFIG_IA64_GENERIC)
=20
+# ifdef MACHVEC_PLATFORM_HEADER
+#  include MACHVEC_PLATFORM_HEADER
+# else
+#  define platform_name		ia64_mv.name
+#  define platform_setup	ia64_mv.setup
+#  define platform_irq_init	ia64_mv.irq_init
+#  define platform_map_nr	ia64_mv.map_nr
+#  define platform_mca_init	ia64_mv.mca_init
+#  define platform_mca_handler	ia64_mv.mca_handler
+#  define platform_cmci_handler	ia64_mv.cmci_handler
+#  define platform_log_print	ia64_mv.log_print
+#  define platform_pci_fixup	ia64_mv.pci_fixup
+#  define platform_register_iosapic	ia64_mv.register_iosapic
+# endif
+
 struct ia64_machine_vector {
 	const char *name;
 	ia64_mv_setup_t *setup;
@@ -49,6 +68,7 @@
 	ia64_mv_mca_handler_t *mca_handler;
 	ia64_mv_cmci_handler_t *cmci_handler;
 	ia64_mv_log_print_t *log_print;
+	ia64_mv_register_iosapic_t *register_iosapic;
 };
=20
 #define MACHVEC_INIT(name)			\
@@ -61,22 +81,12 @@
 	platform_mca_init,			\
 	platform_mca_handler,			\
 	platform_cmci_handler,			\
-	platform_log_print			\
+	platform_log_print,			\
+	platform_register_iosapic			\
 }
=20
-# ifndef MACHVEC_INHIBIT_RENAMING
-#  define platform_name		ia64_mv.name
-#  define platform_setup	ia64_mv.setup
-#  define platform_irq_init	ia64_mv.irq_init
-#  define platform_map_nr	ia64_mv.map_nr
-#  define platform_mca_init	ia64_mv.mca_init
-#  define platform_mca_handler	ia64_mv.mca_handler
-#  define platform_cmci_handler	ia64_mv.cmci_handler
-#  define platform_log_print	ia64_mv.log_print
-# endif
-
 extern struct ia64_machine_vector ia64_mv;
-extern void machvec_noop (void);
+extern void machvec_init (const char *name);
=20
 # else
 #  error Unknown configuration.  Update asm-ia64/machvec.h.
@@ -103,6 +113,12 @@
 #endif
 #ifndef platform_log_print
 # define platform_log_print	((ia64_mv_log_print_t *) machvec_noop)
+#endif
+#ifndef platform_pci_fixup
+# define platform_pci_fixup	((ia64_mv_pci_fixup_t *) machvec_noop)
+#endif
+#ifndef platform_register_iosapic
+# define platform_register_iosapic	((ia64_mv_register_iosapic_t *) machvec=
_noop)
 #endif
=20
 #endif /* _ASM_IA64_MACHVEC_H */
diff -urN linux-davidm/include/asm-ia64/machvec_dig.h linux-2.4.0-test4-lia=
/include/asm-ia64/machvec_dig.h
--- linux-davidm/include/asm-ia64/machvec_dig.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/machvec_dig.h	Fri Jul 28 23:16:5=
9 2000
@@ -5,6 +5,7 @@
 extern ia64_mv_irq_init_t dig_irq_init;
 extern ia64_mv_pci_fixup_t dig_pci_fixup;
 extern ia64_mv_map_nr_t map_nr_dense;
+extern ia64_mv_register_iosapic_t dig_register_iosapic;
=20
 /*
  * This stuff has dual use!
@@ -18,5 +19,6 @@
 #define platform_irq_init	dig_irq_init
 #define platform_pci_fixup	dig_pci_fixup
 #define platform_map_nr		map_nr_dense
+#define platform_register_iosapic dig_register_iosapic
=20
 #endif /* _ASM_IA64_MACHVEC_DIG_h */
diff -urN linux-davidm/include/asm-ia64/machvec_hpsim.h linux-2.4.0-test4-l=
ia/include/asm-ia64/machvec_hpsim.h
--- linux-davidm/include/asm-ia64/machvec_hpsim.h	Fri Jul 28 23:48:24 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/machvec_hpsim.h	Fri Jul 28 23:37=
:15 2000
@@ -15,7 +15,6 @@
 #define platform_name		"hpsim"
 #define platform_setup		hpsim_setup
 #define platform_irq_init	hpsim_irq_init
-#define platform_pci_fixup	hpsim_pci_fixup
 #define platform_map_nr		map_nr_dense
=20
 #endif /* _ASM_IA64_MACHVEC_HPSIM_h */
diff -urN linux-davidm/include/asm-ia64/machvec_init.h linux-2.4.0-test4-li=
a/include/asm-ia64/machvec_init.h
--- linux-davidm/include/asm-ia64/machvec_init.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/machvec_init.h	Fri Jul 28 23:17:=
05 2000
@@ -1,4 +1,6 @@
-#define MACHVEC_INHIBIT_RENAMING
+#define __MACHVEC_HDR(n)		<asm/machvec_##n##.h>
+#define __MACHVEC_EXPAND(n)		__MACHVEC_HDR(n)
+#define MACHVEC_PLATFORM_HEADER		__MACHVEC_EXPAND(MACHVEC_PLATFORM_NAME)
=20
 #include <asm/machvec.h>
=20
@@ -7,3 +9,5 @@
 	=3D MACHVEC_INIT(name);
=20
 #define MACHVEC_DEFINE(name)	MACHVEC_HELPER(name)
+
+MACHVEC_DEFINE(MACHVEC_PLATFORM_NAME)
diff -urN linux-davidm/include/asm-ia64/page.h linux-2.4.0-test4-lia/includ=
e/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/page.h	Fri Jul 28 23:37:15 2000
@@ -100,6 +100,7 @@
 #define MAP_NR_SN1(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE_S=
HIFT)
=20
 #ifdef CONFIG_IA64_GENERIC
+# include <asm/machvec.h>
 # define MAP_NR(addr)	platform_map_nr(addr)
 #elif defined (CONFIG_IA64_SN_SN1_SIM)
 # define MAP_NR(addr)	MAP_NR_SN1(addr)
diff -urN linux-davidm/include/asm-ia64/pal.h linux-2.4.0-test4-lia/include=
/asm-ia64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/pal.h	Fri Jul 28 23:17:20 2000
@@ -18,7 +18,8 @@
  * 00/03/07	davidm	Updated pal_cache_flush() to be in sync with PAL v2.6.
  * 00/03/23     cfleck  Modified processor min-state save area to match up=
dated PAL & SAL info
  * 00/05/24     eranian Updated to latest PAL spec, fix structures bugs, a=
dded=20
- * 00/05/25	eranian Support for stack calls, and statis physical calls
+ * 00/05/25	eranian Support for stack calls, and static physical calls
+ * 00/06/18	eranian Support for stacked physical calls
  */
=20
 /*
@@ -646,10 +647,12 @@
 extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64);=20
 extern struct ia64_pal_retval ia64_pal_call_stacked (u64, u64, u64, u64); =

 extern struct ia64_pal_retval ia64_pal_call_phys_static (u64, u64, u64, u6=
4);=20
+extern struct ia64_pal_retval ia64_pal_call_phys_stacked (u64, u64, u64, u=
64);=20
=20
 #define PAL_CALL(iprv,a0,a1,a2,a3)	iprv =3D ia64_pal_call_static(a0, a1, a=
2, a3)
 #define PAL_CALL_STK(iprv,a0,a1,a2,a3)	iprv =3D ia64_pal_call_stacked(a0, =
a1, a2, a3)
 #define PAL_CALL_PHYS(iprv,a0,a1,a2,a3) iprv =3D ia64_pal_call_phys_static=
(a0, a1, a2, a3)
+#define PAL_CALL_PHYS_STK(iprv,a0,a1,a2,a3) iprv =3D ia64_pal_call_phys_st=
acked(a0, a1, a2, a3)
=20
 typedef int (*ia64_pal_handler) (u64, ...);
 extern ia64_pal_handler ia64_pal;
@@ -951,7 +954,7 @@
 /* Return information about processor's optional power management capabili=
ties. */
 extern inline s64=20
 ia64_pal_halt_info (pal_power_mgmt_info_u_t *power_buf)=20
-{
+{=09
 	struct ia64_pal_retval iprv;
 	PAL_CALL_STK(iprv, PAL_HALT_INFO, (unsigned long) power_buf, 0, 0);
 	return iprv.status;=20
@@ -1370,17 +1373,17 @@
 				dirty_bit_valid		: 1,
 				mem_attr_valid		: 1,
 				reserved		: 60;
-	} pal_itr_valid_s;
-} pal_itr_valid_u_t;
+	} pal_tr_valid_s;
+} pal_tr_valid_u_t;
=20
 /* Read a translation register */
 extern inline s64=20
-ia64_pal_vm_tr_read (u64 reg_num, u64 tr_type, u64 tr_buffer, pal_itr_vali=
d_u_t *itr_valid)=20
-{=09
+ia64_pal_tr_read (u64 reg_num, u64 tr_type, u64 *tr_buffer, pal_tr_valid_u=
_t *tr_valid)
+{
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_VM_TR_READ, reg_num, tr_type, tr_buffer);
-	if (itr_valid)
-		itr_valid->piv_val =3D iprv.v0;
+	PAL_CALL_PHYS_STK(iprv, PAL_VM_TR_READ, reg_num, tr_type,(u64)__pa(tr_buf=
fer));
+	if (tr_valid)
+		tr_valid->piv_val =3D iprv.v0;
 	return iprv.status;=20
 }
=20
diff -urN linux-davidm/include/asm-ia64/param.h linux-2.4.0-test4-lia/inclu=
de/asm-ia64/param.h
--- linux-davidm/include/asm-ia64/param.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/param.h	Fri Jul 28 23:37:15 2000
@@ -10,23 +10,13 @@
=20
 #include <linux/config.h>
=20
-#ifdef CONFIG_IA64_HP_SIM
+#if defined(CONFIG_IA64_HP_SIM) || defined(CONFIG_IA64_SOFTSDV_HACKS)
 /*
  * Yeah, simulating stuff is slow, so let us catch some breath between
  * timer interrupts...
  */
 # define HZ 20
-#endif
-
-#ifdef CONFIG_IA64_DIG
-# ifdef CONFIG_IA64_SOFTSDV_HACKS
-#  define HZ 20
-# else
-#  define HZ 100
-# endif
-#endif
-
-#ifndef HZ
+#else
 # define HZ	1024
 #endif
=20
diff -urN linux-davidm/include/asm-ia64/pci.h linux-2.4.0-test4-lia/include=
/asm-ia64/pci.h
--- linux-davidm/include/asm-ia64/pci.h	Thu Jun 22 07:17:16 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/pci.h	Fri Jul 28 23:39:07 2000
@@ -1,6 +1,15 @@
 #ifndef _ASM_IA64_PCI_H
 #define _ASM_IA64_PCI_H
=20
+#include <linux/config.h>
+#include <linux/slab.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/spinlock.h>
+
+#include <asm/io.h>
+#include <asm/scatterlist.h>
+
 /*
  * Can be used to override the logic in pci_scan_bus for skipping
  * already-configured bus numbers - to be used for buggy BIOSes or
@@ -11,6 +20,8 @@
 #define PCIBIOS_MIN_IO		0x1000
 #define PCIBIOS_MIN_MEM		0x10000000
=20
+struct pci_dev;
+
 extern inline void pcibios_set_master(struct pci_dev *dev)
 {
 	/* No special bus mastering setup handling */
@@ -23,18 +34,8 @@
=20
 /*
  * Dynamic DMA mapping API.
- * IA-64 has everything mapped statically.
  */
=20
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/types.h>
-
-#include <asm/io.h>
-#include <asm/scatterlist.h>
-
-struct pci_dev;
-
 /*
  * Allocate and map kernel buffer using consistent mode DMA for a device.
  * hwdev should be valid struct pci_dev pointer for PCI devices,
@@ -64,13 +65,7 @@
  * Once the device is given the dma address, the device owns this memory
  * until either pci_unmap_single or pci_dma_sync_single is performed.
  */
-extern inline dma_addr_t
-pci_map_single (struct pci_dev *hwdev, void *ptr, size_t size, int directi=
on)
-{
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	return virt_to_bus(ptr);
-}
+extern dma_addr_t pci_map_single(struct pci_dev *hwdev, void *ptr, size_t =
size, int direction);
=20
 /*
  * Unmap a single streaming mode DMA translation.  The dma_addr and size
@@ -80,13 +75,7 @@
  * After this call, reads by the cpu to the buffer are guarenteed to see
  * whatever the device wrote there.
  */
-extern inline void
-pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, size_t size,=
 int direction)
-{
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	/* Nothing to do */
-}
+extern void pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, =
size_t size, int direction);
=20
 /*
  * Map a set of buffers described by scatterlist in streaming
@@ -104,26 +93,14 @@
  * Device ownership issues as mentioned above for pci_map_single are
  * the same here.
  */
-extern inline int
-pci_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, int =
direction)
-{
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	return nents;
-}
+extern int pci_map_sg(struct pci_dev *hwdev, struct scatterlist *sg, int n=
ents, int direction);
=20
 /*
  * Unmap a set of streaming mode DMA translations.
  * Again, cpu read rules concerning calls here are the same as for
  * pci_unmap_single() above.
  */
-extern inline void
-pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, in=
t direction)
-{
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	/* Nothing to do */
-}
+extern void pci_unmap_sg(struct pci_dev *hwdev, struct scatterlist *sg, in=
t nents, int direction);
=20
 /*
  * Make physical memory consistent for a single
@@ -135,13 +112,7 @@
  * next point you give the PCI dma address back to the card, the
  * device again owns the buffer.
  */
-extern inline void
-pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_handle, size_t =
size, int direction)
-{
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	/* Nothing to do */
-}
+extern void pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_han=
dle, size_t size, int direction);
=20
 /*
  * Make physical memory consistent for a set of streaming mode DMA
@@ -150,20 +121,15 @@
  * The same as pci_dma_sync_single but for a scatter-gather list,
  * same rules and usage.
  */
-extern inline void
-pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems=
, int direction)
-{
-	if (direction =3D PCI_DMA_NONE)
-		BUG();
-	/* Nothing to do */
-}
+extern void pci_dma_sync_sg(struct pci_dev *hwdev, struct scatterlist *sg,=
 int nelems, int direction);
=20
 /* Return whether the given PCI device DMA address mask can
  * be supported properly.  For example, if your device can
  * only drive the low 24-bits during PCI bus mastering, then
  * you would pass 0x00ffffff as the mask to this function.
  */
-extern inline int pci_dma_supported(struct pci_dev *hwdev, dma_addr_t mask)
+extern inline int
+pci_dma_supported(struct pci_dev *hwdev, dma_addr_t mask)
 {
 	return 1;
 }
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-test4-lia/i=
nclude/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/processor.h	Fri Jul 28 23:39:06 =
2000
@@ -338,8 +338,12 @@
 struct mm_struct;
 struct task_struct;
=20
-/* Free all resources held by a thread. */
-extern void release_thread (struct task_struct *);
+/*
+ * Free all resources held by a thread. This is called after the
+ * parent of DEAD_TASK has collected the exist status of the task via
+ * wait().  This is a no-op on IA-64.
+ */
+#define release_thread(dead_task)
=20
 /*
  * This is the mechanism for creating a new kernel thread.
diff -urN linux-davidm/include/asm-ia64/scatterlist.h linux-2.4.0-test4-lia=
/include/asm-ia64/scatterlist.h
--- linux-davidm/include/asm-ia64/scatterlist.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/scatterlist.h	Fri Jul 28 23:18:1=
3 2000
@@ -13,6 +13,7 @@
 	 * indirection buffer, NULL otherwise:
 	 */
 	char *alt_address;
+	char *orig_address;	/* Save away the original buffer address (used by pci=
-dma.c) */
 	unsigned int length;	/* buffer length */
 };
=20
diff -urN linux-davidm/include/asm-ia64/smp.h linux-2.4.0-test4-lia/include=
/asm-ia64/smp.h
--- linux-davidm/include/asm-ia64/smp.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/smp.h	Fri Jul 28 23:39:06 2000
@@ -99,5 +99,9 @@
 extern void __init init_smp_config (void);
 extern void smp_do_timer (struct pt_regs *regs);
=20
+extern int smp_call_function_single (int cpuid, void (*func) (void *info),=
 void *info,
+			      int retry, int wait);
+
+
 #endif /* CONFIG_SMP */
 #endif /* _ASM_IA64_SMP_H */
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.0-test4-lia/incl=
ude/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test4-lia/include/asm-ia64/system.h	Fri Jul 28 23:37:15 2000
@@ -445,6 +445,7 @@
    */
 # define switch_to(prev,next,last) do {							\
 	if (ia64_get_fpu_owner() =3D (prev) && ia64_psr(ia64_task_regs(prev))->mf=
h) {	\
+		ia64_psr(ia64_task_regs(prev))->mfh =3D 0;				\
 		(prev)->thread.flags |=3D IA64_THREAD_FPH_VALID;				\
 		__ia64_save_fpu((prev)->thread.fph);					\
 	}										\
diff -urN linux-davidm/lib/cmdline.c linux-2.4.0-test4-lia/lib/cmdline.c
--- linux-davidm/lib/cmdline.c	Tue Jun 20 07:52:36 2000
+++ linux-2.4.0-test4-lia/lib/cmdline.c	Fri Jul 28 23:19:54 2000
@@ -85,12 +85,12 @@
  *	@ptr: Where parse begins
  *	@retptr: (output) Pointer to next char after parse completes
  *
- *	Parses a string into a number.  The number stored
- *	at @ptr is potentially suffixed with %K (for
- *	kilobytes, or 1024 bytes) or suffixed with %M (for
- *	megabytes, or 1048576 bytes).  If the number is suffixed
- *	with K or M, then the return value is the number
- *	multiplied by one kilobyte, or one megabyte, respectively.
+ *	Parses a string into a number.  The number stored at @ptr is
+ *	potentially suffixed with %K (for kilobytes, or 1024 bytes),
+ *	%M (for megabytes, or 1048576 bytes), or %G (for gigabytes, or
+ *	1073741824).  If the number is suffixed with K, M, or G, then
+ *	the return value is the number multiplied by one kilobyte, one
+ *	megabyte, or one gigabyte, respectively.
  */
=20
 unsigned long memparse (char *ptr, char **retptr)
@@ -98,6 +98,9 @@
 	unsigned long ret =3D simple_strtoul (ptr, retptr, 0);
=20
 	switch (**retptr) {
+	case 'G':
+	case 'g':
+		ret <<=3D 10;
 	case 'M':
 	case 'm':
 		ret <<=3D 10;


