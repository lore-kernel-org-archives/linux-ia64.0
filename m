From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 12 Aug 2000 05:02:07 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.0-test6)
Message-Id: <marc-linux-ia64-105590678205323@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 kernel diff is now available at:

 ftp.kernel.org:/pub/linux/kernel/ports/ia64/

in file linux-2.4.0-test6-ia64-000811.diff*.

This update features:

 - Stephane's PAL call and /proc/palinfo updates.

 - Asit's updates to the sw I/O TLB.

 - Perfmon updates from NEC.  Per-process performance monitoring
   should work now.

 - Stephane's fixes for initrd.  The current version tolerates older
   version of eli, but if you're seeing a warning message of the form:

	Warning: boot loader passed virtual address for initrd

   you should consider updating your bootloader.

 - A fix from Goutham that avoids pointer_lock() getting into an
   endless loop

 - Finished optimizing memcpy.

 - Asit's new SMP-safe region-id allocation code.

 - Couple of small fixes to the AGP and DRM code.

 - Added PCI ids for the 460gx chipset.

 - Asit/Jes's siginfo and sigevent padding fixes.  Note: this could
   break certain applications (though I don't know of any that
   actually do break).

 - Documentation for Configure.help (yeah, nobody else volunteered, so
   I figured I had to bite the bullet; however, I'd still appreciate
   if someone else could keep an eye on this to make sure it doesn't
   fall behind the code too much...)

 - Cleaned up (simplified?) the configuration a little.  In
   particular, I dropped the CONFIG_IA64_FW_EMU option.  I don't think
   anybody was using that anymore.  Don, holler if I'm wrong... ;-)

 - Small fix to make IA-32 version of vfork() work again (acrobat
   didn't like it otherwise...).

 - Don/Kanoj's IA-32 fixes to readv/writev and other stuff.

 - Implement workarounds for lfetch and semaphore erratas.

 - Started a new spinlock implementation.  It's currently commented
   out (#ifdef NEW_LOCK), not the least because it doesn't work yet.
   The idea behind this new version is to have a tiny amount of code
   inline for each spinlock and if there is contention, a branch to
   out-of-line code is done.  What is different compared to other
   platforms is that the out-of-line handler is shared, which keeps
   code-size inflation down and also allows to use a fairly
   sophisticated handler for the contention case.  The current handler
   is using an exponential backoff to try to keep the load on the bus
   low.  The reason I believe we can make this work on IA-64 is
   because there are enough scratch registers so that stealing two or
   three of them for the spinlock won't hurt much.

As usual, the relative diff below is only for your convenience.  Get
the full diff from kernel.org for the real thing.

This kernel has been compiled and tested on the HP simulator, UP
BigSur and 4-way Lions.  It feels to me like the best kernel ever.  I
compiled the kernel 5 times from scratch in raw with "make -j16" and
didn't get a single failure.  Of course, YMMV.

Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help linux-2.4.0-test6-lia/D=
ocumentation/Configure.help
--- linux-davidm/Documentation/Configure.help	Thu Aug 10 19:56:17 2000
+++ linux-2.4.0-test6-lia/Documentation/Configure.help	Fri Aug 11 17:13:35 =
2000
@@ -16466,6 +16466,108 @@
   another UltraSPARC-IIi-cEngine boardset with a 7-segment display,
   you should say N to this option.=20
=20
+IA-64 system type
+CONFIG_IA64_GENERIC
+  This selects the system type of your hardware.  A "generic" kernel
+  will run on any supported IA-64 system.  However, if you configure
+  a kernel for your specific system, it will be faster and smaller.
+
+  To find out what type of IA-64 system you have, you may want to
+  check the IA-64 Linux web site at http://www.linux-ia64.org/.
+  As of the time of this writing, most hardware is DIG compliant,
+  so the "DIG-compliant" option is usually the right choice.
+
+  HP-simulator   For the HP simulator (http://software.hp.com/ia64linux/).
+  SN1-simulator  For the SGI SN1 simulator.
+  DIG-compliant  For DIG ("Developer's Interface Guide") compliant system.
+
+  If you don't know what to do, choose "generic".
+
+Kernel page size
+CONFIG_IA64_PAGE_SIZE_4KB
+
+  This lets you select the page size of the kernel.  For best IA-64
+  performance, a page size of 8KB or 16KB is recommended.  For best
+  IA-32 compatibility, a page size of 4KB should be selected (the vast
+  majority of IA-32 binaries work perfectly fine with a larger page
+  size).  For Itanium systems, do NOT chose a page size larger than
+  16KB.
+
+  4KB                For best IA-32 compatibility
+  8KB                For best IA-64 performance
+  16KB               For best IA-64 performance
+  64KB               Not for Itanium.
+
+  If you don't know what to do, choose 8KB.
+
+Enable Itanium A-step specific code
+CONFIG_ITANIUM_ASTEP_SPECIFIC
+  Select this option to build a kernel for an Itanium prototype system
+  with an A-step CPU.  You have an A-step CPU if the "revision" field in
+  /proc/cpuinfo is 0.
+
+Enable Itanium A1-step specific code
+CONFIG_ITANIUM_A1_SPECIFIC
+  Select this option to build a kernel for an Itanium prototype system
+  with an A1-step CPU.  If you don't know whether you have an A1-step CPU,
+  you probably don't and you can answer "no" here.
+
+Enable Itanium B-step specific code
+CONFIG_ITANIUM_BSTEP_SPECIFIC
+  Select this option to build a kernel for an Itanium prototype system
+  with a B-step CPU.  You have a B-step CPU if the "revision" field in
+  /proc/cpuinfo has a value in the range from 1 to 4.
+
+Enable Itanium B0-step specific code
+CONFIG_ITANIUM_B0_SPECIFIC
+  Select this option to bild a kernel for an Itanium prototype system
+  with a B0-step CPU.  You have a B0-step CPU if the "revision" field in
+  /proc/cpuinfo is 1.
+
+Force interrupt redirection
+CONFIG_IA64_HAVE_IRQREDIR
+  Select this option if you know that your system has the ability to
+  redirect interrupts to different CPUs.  Select N here if you're
+  unsure.
+
+Enable use of global TLB purge instruction (ptc.g)
+CONFIG_ITANIUM_PTCG
+  Say Y here if you want the kernel to use the IA-64 "ptc.g"
+  instruction to flush the TLB on all CPUs.  Select N here if
+  you're unsure.
+
+Enable SoftSDV hacks
+CONFIG_IA64_SOFTSDV_HACKS
+  Say Y here to enable hacks to make the kernel work on the Intel
+  SoftSDV simulator.  Select N here if you're unsure.
+
+Enable AzusA hacks
+CONFIG_IA64_AZUSA_HACKS
+  Say Y here to enable hacks to make the kernel work on the NEC
+  AzusA platform.  Select N here if you're unsure.
+
+Enable IA-64 Machine Check Abort
+CONFIG_IA64_MCA
+  Say Y here to enable machine check support for IA-64.  If you're
+  unsure, answer Y.
+
+Performance monitor support
+CONFIG_PERFMON
+  Selects whether support for the IA-64 performance monitor hardware
+  is included in the kernel.  This makes some kernel data-structures a
+  little bigger and slows down execution a bit, but it is still
+  usually a good idea to turn this on.  If you're unsure, say N.
+
+/proc/pal support
+CONFIG_IA64_PALINFO
+  If you say Y here, you are able to get PAL (Processor Abstraction
+  Layer) information in /proc/pal.  This contains useful information
+  about the processors in your systems, such as cache and TLB sizes
+  and the PAL firmware version in use.
+
+  To use this option, you have to check that the "/proc file system
+  support" (CONFIG_PROC_FS) is enabled, too.
+
 #
 # A couple of things I keep forgetting:
 #   capitalize: AppleTalk, Ethernet, DOS, DMA, FAT, FTP, Internet,=20
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-test6-lia/arch/ia64/=
config.in
--- linux-davidm/arch/ia64/config.in	Wed Aug  2 18:54:01 2000
+++ linux-2.4.0-test6-lia/arch/ia64/config.in	Fri Aug 11 16:59:01 2000
@@ -18,15 +18,16 @@
 comment 'General setup'
=20
 define_bool CONFIG_IA64 y
+define_bool CONFIG_SWIOTLB y	# for now...
=20
 define_bool CONFIG_ISA n
 define_bool CONFIG_SBUS n
=20
 choice 'IA-64 system type'					\
-	"Generic		CONFIG_IA64_GENERIC		\
+	"generic		CONFIG_IA64_GENERIC		\
+	 DIG-compliant		CONFIG_IA64_DIG			\
 	 HP-simulator		CONFIG_IA64_HP_SIM		\
-	 SN1-simulator		CONFIG_IA64_SGI_SN1_SIM		\
-	 DIG-compliant		CONFIG_IA64_DIG" Generic
+	 SN1-simulator		CONFIG_IA64_SGI_SN1_SIM" generic
=20
 choice 'Kernel page size'						\
 	"4KB			CONFIG_IA64_PAGE_SIZE_4KB		\
@@ -38,16 +39,18 @@
 	define_bool CONFIG_ITANIUM y
 	define_bool CONFIG_IA64_BRL_EMU y
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
-	bool '  Enable Itanium A1-step specific code' CONFIG_ITANIUM_A1_SPECIFIC
+	if [ "$CONFIG_ITANIUM_ASTEP_SPECIFIC" =3D "y" ]; then
+	  bool '   Enable Itanium A1-step specific code' CONFIG_ITANIUM_A1_SPECIF=
IC
+	fi
+	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
+	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
+	  bool '   Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECIF=
IC
+	fi
+	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
 	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable AzusA hacks' CONFIG_IA64_AZUSA_HACKS
-	bool '  Emulate PAL/SAL/EFI firmware' CONFIG_IA64_FW_EMU
-	bool '  Enable IA64 Machine Check Abort' CONFIG_IA64_MCA
-fi
-
-if [ "$CONFIG_IA64_GENERIC" =3D "y" ]; then
-	define_bool CONFIG_IA64_SOFTSDV_HACKS y
+	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 fi
=20
 if [ "$CONFIG_IA64_SGI_SN1_SIM" =3D "y" ]; then
@@ -59,7 +62,7 @@
=20
 bool 'SMP support' CONFIG_SMP
 bool 'Performance monitor support' CONFIG_PERFMON
-bool '/proc/palinfo support' CONFIG_IA64_PALINFO
+bool '/proc/pal support' CONFIG_IA64_PALINFO
=20
 bool 'Networking support' CONFIG_NET
 bool 'System V IPC' CONFIG_SYSVIPC
@@ -162,8 +165,6 @@
 #source drivers/misc/Config.in
=20
 source fs/Config.in
-
-source fs/nls/Config.in
=20
 if [ "$CONFIG_VT" =3D "y" ]; then
   mainmenu_option next_comment
diff -urN linux-davidm/arch/ia64/dig/setup.c linux-2.4.0-test6-lia/arch/ia6=
4/dig/setup.c
--- linux-davidm/arch/ia64/dig/setup.c	Wed Aug  2 18:54:01 2000
+++ linux-2.4.0-test6-lia/arch/ia64/dig/setup.c	Fri Aug 11 16:58:37 2000
@@ -24,10 +24,6 @@
 #include <asm/machvec.h>
 #include <asm/system.h>
=20
-#ifdef CONFIG_IA64_FW_EMU
-# include "../../kernel/fw-emu.c"
-#endif
-
 /*
  * This is here so we can use the CMOS detection in ide-probe.c to
  * determine what drives are present.  In theory, we don't need this
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.0-test6-lia/ar=
ch/ia64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Wed Aug  2 18:54:01 2000
+++ linux-2.4.0-test6-lia/arch/ia64/ia32/ia32_entry.S	Wed Aug  2 12:32:26 2=
000
@@ -73,7 +73,7 @@
 END(ia32_trace_syscall)
=20
 GLOBAL_ENTRY(sys32_vfork)
-	alloc r16=3Dar.pfs,2,2,3,0;;
+	alloc r16=3Dar.pfs,2,2,4,0;;
 	mov out0=3DIA64_CLONE_VFORK|IA64_CLONE_VM|SIGCHLD	// out0 =3D clone_flags
 	br.cond.sptk.few .fork1			// do the work
 END(sys32_vfork)
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
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.0-test6-lia/arch=
/ia64/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Wed Aug  2 18:54:01 2000
+++ linux-2.4.0-test6-lia/arch/ia64/ia32/sys_ia32.c	Mon Jul 31 14:01:22 2000
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
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.4.0-test6-lia/arch=
/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Fri Aug 11 19:01:13 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/Makefile	Wed Aug  2 18:57:03 2000
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
diff -urN linux-davidm/arch/ia64/kernel/efi.c linux-2.4.0-test6-lia/arch/ia=
64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Fri Aug 11 19:01:13 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/efi.c	Fri Aug 11 18:01:55 2000
@@ -246,7 +246,7 @@
 			printk(KERN_ERR "Too many EFI Pal Code memory ranges, dropped @ %lx\n",
 			       md->phys_addr);
 			continue;
-		}=20
+		}
 		mask  =3D ~((1 << _PAGE_SIZE_4M)-1);	/* XXX should be dynamic? */
 		vaddr =3D PAGE_OFFSET + md->phys_addr;
=20
@@ -289,7 +289,7 @@
 	for (cp =3D saved_command_line; *cp; ) {
 		if (memcmp(cp, "mem=3D", 4) =3D 0) {
 			cp +=3D 4;
-			mem_limit =3D memparse(cp, &end);
+			mem_limit =3D memparse(cp, &end) - 1;
 			if (end !=3D cp)
 				break;
 			cp =3D end;
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test6-lia/arch/=
ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Thu Aug 10 19:56:18 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/entry.S	Fri Aug 11 14:56:27 2000
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
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.0-test6-lia/arch/i=
a64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Wed Aug  2 18:54:01 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/head.S	Sat Aug  5 19:27:13 2000
@@ -181,7 +181,9 @@
=20
 GLOBAL_ENTRY(ia64_load_debug_regs)
 	alloc r16=3Dar.pfs,1,0,0,0
+#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BST=
EP_SPECIFIC))
 	lfetch.nta [in0]
+#endif
 	mov r20=3Dar.lc			// preserve ar.lc
 	add r19=3DIA64_NUM_DBG_REGS*8,in0
 	mov ar.lc=3DIA64_NUM_DBG_REGS-1
@@ -702,3 +704,74 @@
 SET_REG(b5);
=20
 #endif /* CONFIG_IA64_BRL_EMU */
+
+#ifdef CONFIG_SMP
+
+	/*
+	 * This routine handles spinlock contention.  It uses a simple exponentia=
l backoff
+	 * algorithm to reduce unnecessary bus traffic.  The initial delay is sel=
ected from
+	 * the low-order bits of the cycle counter (a cheap "randomizer").  I'm s=
ure this
+	 * could use additional tuning, especially on systems with a large number=
 of CPUs.
+	 * Also, I think the maximum delay should be made a function of the numbe=
r of CPUs in
+	 * the system. --davidm 00/08/05
+	 *
+	 * WARNING: This is not a normal procedure.  It gets called from C code w=
ithout
+	 * the compiler knowing about it.  Thus, we must not use any scratch regi=
sters
+	 * beyond those that were declared "clobbered" at the call-site (see spin=
_lock()
+	 * macro).  We may not even use the stacked registers, because that could=
 overwrite
+	 * output registers.  Similarly, we can't use the scratch stack area as i=
t may be
+	 * in use, too.
+	 *
+	 * Inputs:
+	 *	ar.ccv =3D 0 (and available for use)
+	 *	r28 =3D available for use
+	 *	r29 =3D available for use
+	 *	r30 =3D non-zero (and available for use)
+	 *	r31 =3D address of lock we're trying to acquire
+	 *	p15 =3D available for use
+	 */
+
+#	define delay	r28
+#	define timeout	r29
+#	define tmp	r30
+
+GLOBAL_ENTRY(ia64_spinlock_contention)
+	mov tmp=3Dar.itc
+	;;
+	and delay=3D0x3f,tmp
+	;;
+
+.retry:	add timeout=3Dtmp,delay
+	shl delay=DElay,1
+	;;
+	dep delay=DElay,r0,0,13	// limit delay to 8192 cycles
+	;;
+	// delay a little...
+.wait:	sub tmp=3Dtmp,timeout
+	or delay=3D0xf,delay	// make sure delay is non-zero (otherwise we get stu=
ck with 0)
+	;;
+	cmp.lt p15,p0=3Dtmp,r0
+	mov tmp=3Dar.itc
+(p15)	br.cond.sptk .wait
+	;;
+	ld1 tmp=3D[r31]
+	;;
+	cmp.ne p15,p0=3Dtmp,r0
+	mov tmp=3Dar.itc
+(p15)	br.cond.sptk.few .retry	// lock is still busy
+	;;
+	// try acquiring lock (we know ar.ccv is still zero!):
+	mov tmp=3D1
+	;;
+	IA64_SEMFIX_INSN
+	cmpxchg1.acq tmp=3D[r31],tmp,ar.ccv
+	;;
+	cmp.eq p15,p0=3Dtmp,r0
+
+	mov tmp=3Dar.itc
+(p15)	br.ret.sptk.many b7	// got lock -> return
+	br .retry		// still no luck, retry
+
+END(ia64_spinlock_contention)
+
+#endif
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.0-test6-lia/=
arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Thu Aug 10 19:56:18 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/ia64_ksyms.c	Mon Jul 31 14:01:22=
 2000
@@ -18,6 +18,7 @@
 EXPORT_SYMBOL(strncat);
 EXPORT_SYMBOL(strncmp);
 EXPORT_SYMBOL(strncpy);
+EXPORT_SYMBOL(strstr);
 EXPORT_SYMBOL(strtok);
=20
 #include <linux/pci.h>
@@ -37,6 +38,7 @@
 EXPORT_SYMBOL(kernel_thread);
=20
 #ifdef CONFIG_SMP
+#include <asm/hardirq.h>
 EXPORT_SYMBOL(synchronize_irq);
=20
 #include <asm/smplock.h>
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-test6-lia/arch/ia=
64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Fri Aug 11 19:01:13 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/ivt.S	Fri Aug 11 14:55:22 2000
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
+	mov r16=3Dcr.iha				// get virtual address of L3 PTE
 	;;
-	thash r17=3Dr16				// compute virtual address of L3 PTE
-	;;
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
diff -urN linux-davidm/arch/ia64/kernel/pal.S linux-2.4.0-test6-lia/arch/ia=
64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/pal.S	Fri Jul 28 09:04:50 2000
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
diff -urN linux-davidm/arch/ia64/kernel/palinfo.c linux-2.4.0-test6-lia/arc=
h/ia64/kernel/palinfo.c
--- linux-davidm/arch/ia64/kernel/palinfo.c	Fri Aug 11 19:01:14 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/palinfo.c	Fri Aug 11 18:12:58 20=
00
@@ -21,6 +21,10 @@
 #include <linux/init.h>
 #include <linux/proc_fs.h>
 #include <linux/mm.h>
+#include <linux/module.h>
+#if defined(MODVERSIONS)
+#include <linux/modversions.h>
+#endif
=20
 #include <asm/pal.h>
 #include <asm/sal.h>
@@ -31,12 +35,15 @@
 #include <linux/smp.h>
 #endif
=20
+MODULE_AUTHOR("Stephane Eranian <eranian@hpl.hp.com>");
+MODULE_DESCRIPTION("/proc interface to IA-64 PAL");
+
 /*
- * Hope to get rid of these in a near future
+ * Hope to get rid of this one in a near future
 */
 #define IA64_PAL_VERSION_BUG		1
=20
-#define PALINFO_VERSION "0.2"
+#define PALINFO_VERSION "0.3"
=20
 #ifdef CONFIG_SMP
 #define cpu_is_online(i) (cpu_online_map & (1UL << i))
@@ -129,64 +136,31 @@
 /*
  * Allocate a buffer suitable for calling PAL code in Virtual mode
  *
- * The documentation (PAL2.6) requires thius buffer to have a pinned
- * translation to avoid any DTLB faults. For this reason we allocate
- * a page (large enough to hold any possible reply) and use a DTC
- * to hold the translation during the call. A call the free_palbuffer()
- * is required to release ALL resources (page + translation).
+ * The documentation (PAL2.6) allows DTLB misses on the buffer. So=20
+ * using the TC is enough, no need to pin the entry.
  *
- * The size of the page allocated is based on the PAGE_SIZE defined
- * at compile time for the kernel, i.e.  >=3D 4Kb.
- *
- * Return: a pointer to the newly allocated page (virtual address)
+ * We allocate a kernel-sized page (at least 4KB). This is enough to
+ * hold any possible reply.
  */
-static void *
+static inline void *
 get_palcall_buffer(void)
 {
 	void *tmp;
=20
 	tmp =3D (void *)__get_free_page(GFP_KERNEL);
 	if (tmp =3D 0) {
-		printk(KERN_ERR "%s: can't get a buffer page\n", __FUNCTION__);
-	} else if ( ((u64)tmp - PAGE_OFFSET) > (1<<_PAGE_SIZE_256M) )  { /* XXX: =
temporary hack */
-		unsigned long flags;
-
-		/* PSR.ic must be zero to insert new DTR */
-		ia64_clear_ic(flags);
-
-		/*
-		 * we  only insert of DTR
-		 *
-		 * XXX: we need to figure out a way to "allocate" TR(s) to avoid
-		 * conflicts. Maybe something in an include file like pgtable.h
-		 * page.h or processor.h
-		 *
-		 * ITR0/DTR0: used for kernel code/data
-		 * ITR1/DTR1: used by HP simulator
-		 * ITR2/DTR2: used to map PAL code
-		 */
-		ia64_itr(0x2, 3, (u64)tmp,
-			 pte_val(mk_pte_phys(__pa(tmp), __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_=
AR_RW))), PAGE_SHIFT);
-
-		ia64_srlz_d ();
-
-		__restore_flags(flags);=09
-	}
-
+		printk(KERN_ERR __FUNCTION__" : can't get a buffer page\n");=20
+	}=20
 	return tmp;
 }
=20
 /*
  * Free a palcall buffer allocated with the previous call
- *
- * The translation is also purged.
  */
-static void
+static inline void
 free_palcall_buffer(void *addr)
 {
 	__free_page(addr);
-	ia64_ptr(0x2, (u64)addr, PAGE_SHIFT);
-	ia64_srlz_d ();
 }
=20
 /*
@@ -672,17 +646,23 @@
 	if (status !=3D 0) return 0;
=20
 	p +=3D sprintf(p, "PAL_vendor : 0x%02x (min=3D0x%02x)\n" \
-			"PAL_A      : %02x.%02x (min=3D%02x.%02x)\n" \
-			"PAL_B      : %02x.%02x (min=3D%02x.%02x)\n",
+			"PAL_A      : %x.%x.%x (min=3D%x.%x.%x)\n" \
+			"PAL_B      : %x.%x.%x (min=3D%x.%x.%x)\n",
 	     		cur_ver.pal_version_s.pv_pal_vendor,
 	     		min_ver.pal_version_s.pv_pal_vendor,
-	     		cur_ver.pal_version_s.pv_pal_a_model,
+
+	     		cur_ver.pal_version_s.pv_pal_a_model>>4,
+	     		cur_ver.pal_version_s.pv_pal_a_model&0xf,
 	     		cur_ver.pal_version_s.pv_pal_a_rev,
-	     		min_ver.pal_version_s.pv_pal_a_model,
+	     		min_ver.pal_version_s.pv_pal_a_model>>4,
+	     		min_ver.pal_version_s.pv_pal_a_model&0xf,
 	     		min_ver.pal_version_s.pv_pal_a_rev,
-	     		cur_ver.pal_version_s.pv_pal_b_model,
+
+	     		cur_ver.pal_version_s.pv_pal_b_model>>4,
+	     		cur_ver.pal_version_s.pv_pal_b_model&0xf,
 	     		cur_ver.pal_version_s.pv_pal_b_rev,
-	     		min_ver.pal_version_s.pv_pal_b_model,
+	     		min_ver.pal_version_s.pv_pal_b_model>>4,
+	     		min_ver.pal_version_s.pv_pal_b_model&0xf,
 	     		min_ver.pal_version_s.pv_pal_b_rev);
=20
 	return p - page;
@@ -704,6 +684,9 @@
 	}
=20
 #ifdef IA64_PAL_PERF_MON_INFO_BUG
+	/*
+	 * This bug has been fixed in PAL 2.2.9 and higher
+	 */
 	pm_buffer[5]=3D0x3;
 	pm_info.pal_perf_mon_info_s.cycles  =3D 0x12;
 	pm_info.pal_perf_mon_info_s.retired =3D 0x08;
@@ -990,6 +973,7 @@
 	int len=3D0;
 	pal_func_cpu_u_t *f =3D (pal_func_cpu_u_t *)&data;
=20
+	MOD_INC_USE_COUNT;
 	/*
 	 * in SMP mode, we may need to call another CPU to get correct
 	 * information. PAL, by definition, is processor specific
@@ -1007,6 +991,8 @@
         if (len>count) len =3D count;
         if (len<0) len =3D 0;
=20
+	MOD_DEC_USE_COUNT;
+
         return len;
 }
=20
@@ -1015,7 +1001,6 @@
 {
 #	define CPUSTR	"cpu%d"
=20
-	palinfo_entry_t *p;
 	pal_func_cpu_u_t f;
 	struct proc_dir_entry **pdir =3D palinfo_proc_entries;
 	struct proc_dir_entry *palinfo_dir, *cpu_dir;
@@ -1052,7 +1037,7 @@
 	return 0;
 }
=20
-static int __exit
+static void __exit
 palinfo_exit(void)
 {
 	int i =3D 0;
@@ -1061,8 +1046,6 @@
 	for (i=3D0; i< NR_PALINFO_PROC_ENTRIES ; i++) {
 		remove_proc_entry (palinfo_proc_entries[i]->name, NULL);
 	}
-
-	return 0;
 }
=20
 module_init(palinfo_init);
diff -urN linux-davidm/arch/ia64/kernel/pci-dma.c linux-2.4.0-test6-lia/arc=
h/ia64/kernel/pci-dma.c
--- linux-davidm/arch/ia64/kernel/pci-dma.c	Fri Aug 11 19:01:14 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/pci-dma.c	Mon Jul 31 14:01:22 20=
00
@@ -3,7 +3,8 @@
  *
  * This implementation is for IA-64 platforms that do not support
  * I/O TLBs (aka DMA address translation hardware).
- * Goutham Rao <goutham.rao@intel.com>: Implemented the PCI DMA mapping AP=
I.
+ * Copyright (C) 2000 Asit Mallick <Asit.K.Mallick@intel.com>
+ * Copyright (C) 2000 Goutham Rao <goutham.rao@intel.com>
  */
=20
 #include <linux/config.h>
@@ -23,46 +24,50 @@
 #include <linux/init.h>
 #include <linux/bootmem.h>
=20
-#define ALIGN(val, align) ((void *) (((unsigned long) (val) + ((align) - 1=
)) & ~((align) - 1)))
+#define ALIGN(val, align) ((unsigned long) (((unsigned long) (val) + ((ali=
gn) - 1)) & ~((align) - 1)))
=20
-typedef struct io_tlb_sizes {
-	size_t		size;
-	int		log_size;
-	int		n_buffers;
-	int		curr_index;
-	spinlock_t	lock;
-	char		*base;
-	unsigned long	*orig_addr;
-	unsigned int	*free_list;
-} io_tlb_sizes_t;
-
-/*
- * List entries in order of size (low to high)
- */
-static io_tlb_sizes_t io_tlb[] =3D {
-	{2048, 11, 128, 127, SPIN_LOCK_UNLOCKED, 0, 0, 0},
-	{PAGE_SIZE, PAGE_SHIFT, 128, 127, SPIN_LOCK_UNLOCKED, 0, 0, 0},
-	/*
-	 * Indicated end of entries
-	 */=09
-	{0, 0, 0, 0, SPIN_LOCK_UNLOCKED, 0, 0, 0}
-};
+/*
+ * log of the size of each IO TLB slab.  The number of slabs is command li=
ne
+ * controllable.
+ */
+#define IO_TLB_SHIFT 11
=20
 /*
- * Used to do a quick range check in pci_unmap_single and pci_sync_single
+ * Used to do a quick range check in pci_unmap_single and pci_sync_single,=
 to see if the=20
+ * memory was in fact allocated by this API.
  */
 static char *io_tlb_start, *io_tlb_end;
=20
-static unsigned long swiotlb_buf_count;
+/*
+ * The number of IO TLB blocks (in groups of 64) betweeen io_tlb_start and=
 io_tlb_end.
+ * This is command line adjustable via setup_io_tlb_npages.
+ */
+unsigned long io_tlb_nslabs =3D 1024;
+
+/*
+ * This is a free list describing the number of free entries available fro=
m each index
+ */
+static unsigned int *io_tlb_list;
+static unsigned int io_tlb_index;
+
+/*
+ * We need to save away the original address corresponding to a mapped ent=
ry for the sync=20
+ * operations.
+ */
+static unsigned char **io_tlb_orig_addr;
+
+/*
+ * Protect the above data structures in the map and unmap calls
+ */=20
+spinlock_t io_tlb_lock =3D SPIN_LOCK_UNLOCKED;
=20
 static int __init
-setup_swiotlb_buf_count (char *str)
+setup_io_tlb_npages (char *str)
 {
-	swiotlb_buf_count =3D simple_strtoul(str, NULL, 0);
+	io_tlb_nslabs =3D simple_strtoul(str, NULL, 0) << (PAGE_SHIFT - IO_TLB_SH=
IFT);
 	return 1;
 }
-
-__setup("swiotlb=3D", setup_swiotlb_buf_count);
+__setup("swiotlb=3D", setup_io_tlb_npages);
=20
 /*
  * Statically reserve bounce buffer space and initialize bounce buffer
@@ -71,58 +76,27 @@
 void
 setup_swiotlb (void)
 {
-	unsigned long entry_size, size =3D 0;
-	struct io_tlb_sizes *itp;
-
-	for (itp =3D io_tlb; itp->size; ++itp) {
-		/*
-		 * Let user override number of buffers needed
-		 */
-		if (swiotlb_buf_count)
-			itp->n_buffers =3D swiotlb_buf_count;
-		itp->curr_index =3D itp->n_buffers - 1;
-		/*
-		 * size needed for buffers + size needed for offset
-		 * table + size needed for mapping:
-		 */
-		entry_size =3D itp->size + sizeof(int) + sizeof(long);
-		/* the +1 makes room for the worst-case alignment... */
-		size +=3D (itp->n_buffers + 1)*entry_size;
-	}
+	int i;
=20
 	/*
-	 * Now get IO TLB memory from the low pages
+	 * Get IO TLB memory from the low pages
 	 */
-	io_tlb_start =3D io_tlb_end =3D alloc_bootmem_low_pages(size);
+	io_tlb_start =3D alloc_bootmem_low_pages(io_tlb_nslabs * (1 << IO_TLB_SHI=
FT));
 	if (!io_tlb_start)
 		BUG();
+	io_tlb_end =3D io_tlb_start + io_tlb_nslabs * (1 << IO_TLB_SHIFT);
=20
 	/*
-	 * For every io tlb size entry, allocate the required amount of memory
-	 * and initialize the free list array to mark all entries as available
+	 * Allocate and initialize the free list array.  This array is used
+	 * to find contiguous free memory regions of size 2^IO_TLB_SHIFT between
+	 * io_tlb_start and io_tlb_end.
 	 */
-	for (itp =3D io_tlb; itp->size; ++itp) {
-		int j;
-
-		/*
-		 * Reserve memory for the IO TLB buffers and the
-		 * offsets array for these size chunks
-		 */
-		itp->base =3D ALIGN(io_tlb_end, itp->size);
-		io_tlb_end =3D itp->base + itp->size * itp->n_buffers;
-
-		itp->orig_addr =3D ALIGN(io_tlb_end, sizeof(long));
-		io_tlb_end =3D ((char *)itp->orig_addr) + itp->n_buffers * sizeof(long);
+	io_tlb_list =3D alloc_bootmem(io_tlb_nslabs * sizeof(int));
+	for (i =3D 0; i < io_tlb_nslabs; i++)
+		io_tlb_list[i] =3D io_tlb_nslabs - i;
+	io_tlb_index =3D 0;
+	io_tlb_orig_addr =3D alloc_bootmem(io_tlb_nslabs * sizeof(char *));
=20
-		itp->free_list =3D (unsigned int *)io_tlb_end;
-		io_tlb_end =3D ((char *)itp->free_list) + itp->n_buffers * sizeof(int);
-
-		/*=20
-		 * Initialize free list array, marking all entries available
-		 */=09
-		for (j =3D 0; j < itp->n_buffers; j++)
-			itp->free_list[j] =3D (unsigned int)(j * itp->size);
-	}
 	printk("Placing software IO TLB between 0x%p - 0x%p\n", io_tlb_start, io_=
tlb_end);
 }
=20
@@ -132,51 +106,71 @@
 static void *
 __pci_map_single (struct pci_dev *hwdev, char *buffer, size_t size, int di=
rection)
 {
-	struct io_tlb_sizes *itp;
-	char *dma_addr =3D 0;
-	int index;
+	unsigned long flags;
+	char *dma_addr;
+	unsigned int i, nslots, stride, index, wrap;
+
+	/*
+	 * For mappings greater than a page size, we limit the stride (and hence =
alignment)
+	 * to a page size.
+	 */
+	nslots =3D ALIGN(size, 1 << IO_TLB_SHIFT) >> IO_TLB_SHIFT;
+	if (size > (1 << PAGE_SHIFT))
+		stride =3D (1 << (PAGE_SHIFT - IO_TLB_SHIFT));
+	else
+		stride =3D nslots;
+
+	if (!nslots)
+		BUG();
=20
 	/*
-	 * Find a IO TLB size that will fit this request and allocate a buffer
+	 * Find suitable number of IO TLB entries size that will fit this request=
 and allocate a buffer
 	 * from that IO TLB pool.
 	 */
-	for (itp =3D io_tlb; itp->size; ++itp) {
-		if (size <=3D itp->size) {
-			unsigned long flags;
-
-			spin_lock_irqsave(&itp->lock, flags);
-			{
-				if (!itp->curr_index) {
-					/*
-					 * Get buffer from next IO TLB... this will
-					 * waste memory though.
-					 */
-					spin_unlock_irqrestore(&itp->lock, flags);
-					continue;
-				}
-				dma_addr =3D (itp->base + itp->free_list[itp->curr_index--]);
-			}
-			spin_unlock_irqrestore(&itp->lock, flags);
+	spin_lock_irqsave(&io_tlb_lock, flags);
+	{
+		wrap =3D index =3D ALIGN(io_tlb_index, stride);
+		do {
 			/*
-			 * Save the mapping from original address to DMA address
-			 * because the map_single API doesen't have a mapping=20
-			 * like the map_sg API.
+			 * If we find a slot that indicates we have 'nslots' number of=20
+			 * contiguous buffers, we allocate the buffers from that slot and mark =
the
+			 * entries as '0' indicating unavailable.
 			 */
-			index =3D (dma_addr - itp->base) >> itp->log_size;
-			itp->orig_addr[index] =3D (unsigned long) buffer;
+			if (io_tlb_list[index] >=3D nslots) {
+				for (i =3D index; i < index + nslots; i++)
+					io_tlb_list[i] =3D 0;
+				dma_addr =3D io_tlb_start + (index << IO_TLB_SHIFT);
=20
-			if (direction =3D PCI_DMA_TODEVICE || direction =3D PCI_DMA_BIDIRECTION=
AL)
-				memcpy(dma_addr, buffer, size);
+				/*
+				 * Update the indices to avoid searching in the next round.
+				 */
+				io_tlb_index =3D (index + nslots) < io_tlb_nslabs ? (index + nslots) :=
 0;
=20
-			return dma_addr;
-		}
+				goto found;
+			}
+			index +=3D stride;
+			if (index >=3D io_tlb_nslabs)
+				index =3D 0;
+		} while (index !=3D wrap);
+
+		/*
+		 * XXX What is a suitable recovery mechanism here?  We cannot=20
+		 * sleep because we are called from with in interrupts!
+		 */
+		panic("__pci_map_single: could not allocate software IO TLB (%ld bytes)"=
, size);
+found:
 	}
+	spin_unlock_irqrestore(&io_tlb_lock, flags);
=20
 	/*
-	 * XXX What is a suitable recovery mechanism here?  We cannot=20
-	 * sleep because we are called from with in interrupts!
+	 * Save away the mapping from the original address to the DMA address.  T=
his is needed
+	 * when we sync the memory.  Then we sync the buffer if needed.
 	 */
-	panic("__pci_map_single: could not allocate software IO TLB (%ld bytes)",=
 size);
+	io_tlb_orig_addr[index] =3D buffer;
+	if (direction =3D PCI_DMA_TODEVICE || direction =3D PCI_DMA_BIDIRECTIONAL)
+		memcpy(dma_addr, buffer, size);
+
+	return dma_addr;
 }
=20
 /*
@@ -185,71 +179,60 @@
 static void
 __pci_unmap_single (struct pci_dev *hwdev, char *dma_addr, size_t size, in=
t direction)
 {
-	struct io_tlb_sizes *itp;
+	unsigned long flags;
+	int i, nslots =3D ALIGN(size, 1 << IO_TLB_SHIFT) >> IO_TLB_SHIFT;
+	int index =3D (dma_addr - io_tlb_start) >> IO_TLB_SHIFT;
+	char *buffer =3D io_tlb_orig_addr[index];
=20
 	/*
-	 * Return the buffer to the free list
+	 * First, sync the memory before unmapping the entry
 	 */
-	for (itp =3D io_tlb; itp->size; ++itp) {
-		if (size <=3D itp->size) {
-			unsigned long flags;
-			char *buffer;
-			int index;
-
-			/*
-	 	 	 * Get the mapping (IO address to original address)...=20
-		 	 */
-			index =3D (dma_addr - itp->base) >> itp->log_size;
-			buffer =3D (char *) itp->orig_addr[index];
-			if ((direction =3D PCI_DMA_FROMDEVICE)
-			    || (direction =3D PCI_DMA_BIDIRECTIONAL))
-				/*
- 	 	 		 * bounce... copy the data back into the original buffer
-	 	 		 * and delete the bounce buffer.
- 	 	 		 */
-				memcpy(buffer, dma_addr, size);
+	if ((direction =3D PCI_DMA_FROMDEVICE) || (direction =3D PCI_DMA_BIDIRECT=
IONAL))
+		/*
+ 	 	 * bounce... copy the data back into the original buffer
+	  	 * and delete the bounce buffer.
+ 	 	 */
+		memcpy(buffer, dma_addr, size);
=20
-			/*
-			 * Return the entry to the list
-			 */
-			spin_lock_irqsave(&itp->lock, flags);
-			{
-				itp->free_list[++itp->curr_index] =3D (dma_addr - itp->base);
-			}
-			spin_unlock_irqrestore(&itp->lock, flags);
-			return;
-		}
+	/*
+	 * Return the buffer to the free list by setting the corresponding entrie=
s to indicate
+	 * the number of contigous entries available. =20
+	 * While returning the entries to the free list, we merge the entries wit=
h slots below
+	 * and above the pool being returned.
+	 */
+	spin_lock_irqsave(&io_tlb_lock, flags);
+	{
+		int count =3D ((index + nslots) < io_tlb_nslabs ? io_tlb_list[index + ns=
lots] : 0);
+		/*
+		 * Step 1: return the slots to the free list, merging the slots with sup=
erceeding slots
+		 */
+		for (i =3D index + nslots - 1; i >=3D index; i--)
+			io_tlb_list[i] =3D ++count;
+		/*
+		 * Step 2: merge the returned slots with the preceeding slots, if availa=
ble (non zero)
+		 */
+		for (i =3D index - 1; (i >=3D 0) && io_tlb_list[i]; i--)
+			io_tlb_list[i] +=3D io_tlb_list[index];
 	}
-	BUG();
+	spin_unlock_irqrestore(&io_tlb_lock, flags);
 }
=20
 static void
 __pci_sync_single (struct pci_dev *hwdev, char *dma_addr, size_t size, int=
 direction)
 {
-	struct io_tlb_sizes *itp;
-	char *buffer;
-	int index;
+	int index =3D (dma_addr - io_tlb_start) >> IO_TLB_SHIFT;
+	char *buffer =3D io_tlb_orig_addr[index];
=20
 	/*
   	 * bounce... copy the data back into/from the original buffer
 	 * XXX How do you handle PCI_DMA_BIDIRECTIONAL here ?
  	 */
-	for (itp =3D io_tlb; itp->size; ++itp) {
-		if (size <=3D itp->size) {
-			/*
-	 	 	 * Get the mapping (IO address to original address)...=20
-		 	 */
-			index =3D (dma_addr - itp->base) >> itp->log_size;
-			buffer =3D (char *) itp->orig_addr[index];
-			if (direction =3D PCI_DMA_FROMDEVICE)
-				memcpy(buffer, dma_addr, size);
-			else if (direction =3D PCI_DMA_TODEVICE)
-				memcpy(dma_addr, buffer, size);
-			else
-				BUG();
-			break;
-		}
-	}
+	if (direction =3D PCI_DMA_FROMDEVICE)
+		memcpy(buffer, dma_addr, size);
+	else if (direction =3D PCI_DMA_TODEVICE)
+		memcpy(dma_addr, buffer, size);
+	else
+		BUG();
 }
=20
 /*
@@ -276,9 +259,11 @@
 		 */
 		return pci_addr;
=20
-	/* get a bounce buffer: */
-
+	/*=20
+	 * get a bounce buffer:=20
+	 */
 	pci_addr =3D virt_to_phys(__pci_map_single(hwdev, ptr, size, direction));
+
 	/*
 	 * Ensure that the address returned is DMA'ble:
 	 */
@@ -399,6 +384,106 @@
 	for (i =3D 0; i < nelems; i++, sg++)
 		if (sg->orig_address !=3D sg->address)
 			__pci_sync_single(hwdev, sg->address, sg->length, direction);
+}
+
+#else
+/*
+ * Map a single buffer of the indicated size for DMA in streaming mode.
+ * The 32-bit bus address to use is returned.
+ *
+ * Once the device is given the dma address, the device owns this memory
+ * until either pci_unmap_single or pci_dma_sync_single is performed.
+ */
+extern inline dma_addr_t
+pci_map_single (struct pci_dev *hwdev, void *ptr, size_t size, int directi=
on)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        return virt_to_bus(ptr);
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
+extern inline void
+pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, size_t size,=
 int direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        /* Nothing to do */
+}
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
+extern inline int
+pci_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, int =
direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        return nents;
+}
+
+/*
+ * Unmap a set of streaming mode DMA translations.
+ * Again, cpu read rules concerning calls here are the same as for
+ * pci_unmap_single() above.
+ */
+extern inline void
+pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, in=
t direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        /* Nothing to do */
+}
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
+extern inline void
+pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_handle, size_t =
size, int direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        /* Nothing to do */
+}
+
+/*
+ * Make physical memory consistent for a set of streaming mode DMA
+ * translations after a transfer.
+ *
+ * The same as pci_dma_sync_single but for a scatter-gather list,
+ * same rules and usage.
+ */
+extern inline void
+pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems=
, int direction)
+{
+        if (direction =3D PCI_DMA_NONE)
+                BUG();
+        /* Nothing to do */
 }
=20
 #endif /* CONFIG_SWIOTLB */
diff -urN linux-davidm/arch/ia64/kernel/perfmon.c linux-2.4.0-test6-lia/arc=
h/ia64/kernel/perfmon.c
--- linux-davidm/arch/ia64/kernel/perfmon.c	Fri Mar 10 15:24:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/perfmon.c	Fri Aug 11 18:19:21 20=
00
@@ -11,6 +11,7 @@
 #include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
+#include <linux/interrupt.h>
 #include <linux/smp_lock.h>
=20
 #include <asm/errno.h>
@@ -55,24 +56,23 @@
 #define WRITE_PMCS		0xa1
 #define READ_PMDS		0xa2
 #define STOP_PMCS		0xa3
-#define IA64_COUNTER_MASK	0xffffffffffffff6f
-#define PERF_OVFL_VAL		0xffffffff
+#define IA64_COUNTER_MASK	0xffffffffffffff6fL
+#define PERF_OVFL_VAL		0xffffffffL
+
+volatile int used_by_system;
=20
 struct perfmon_counter {
         unsigned long data;
         unsigned long counter_num;
 };
=20
-unsigned long pmds[MAX_PERF_COUNTER];
-struct task_struct *perf_owner=3DNULL;
+unsigned long pmds[NR_CPUS][MAX_PERF_COUNTER];
=20
 asmlinkage unsigned long
 sys_perfmonctl (int cmd1, int cmd2, void *ptr)
 {
         struct perfmon_counter tmp, *cptr =3D ptr;
-        unsigned long pmd, cnum, dcr, flags;
-        struct task_struct *p;
-        struct pt_regs *regs;
+        unsigned long cnum, dcr, flags;
         struct perf_counter;
         int i;
=20
@@ -80,22 +80,24 @@
 	      case WRITE_PMCS:           /* Writes to PMC's and clears PMDs */
 	      case WRITE_PMCS_AND_START: /* Also starts counting */
=20
-		if (!access_ok(VERIFY_READ, cptr, sizeof(struct perf_counter)*cmd2))
-			return -EFAULT;
+		if (cmd2 <=3D 0 || cmd2 > MAX_PERF_COUNTER - used_by_system)
+			return -EINVAL;
=20
-		if (cmd2 > MAX_PERF_COUNTER)
+		if (!access_ok(VERIFY_READ, cptr, sizeof(struct perf_counter)*cmd2))
 			return -EFAULT;
=20
-		if (perf_owner && perf_owner !=3D current)
-			return -EBUSY;
-		perf_owner =3D current;
+		current->thread.flags |=3D IA64_THREAD_PM_VALID;
=20
 		for (i =3D 0; i < cmd2; i++, cptr++) {
 			copy_from_user(&tmp, cptr, sizeof(tmp));
 			/* XXX need to check validity of counter_num and perhaps data!! */
+			if (tmp.counter_num < 4
+			    || tmp.counter_num >=3D 4 + MAX_PERF_COUNTER - used_by_system)
+				return -EFAULT;
+
 			ia64_set_pmc(tmp.counter_num, tmp.data);
 			ia64_set_pmd(tmp.counter_num, 0);
-			pmds[tmp.counter_num - 4] =3D 0;
+			pmds[smp_processor_id()][tmp.counter_num - 4] =3D 0;
 		}
=20
 		if (cmd1 =3D WRITE_PMCS_AND_START) {
@@ -104,26 +106,13 @@
 			dcr |=3D IA64_DCR_PP;
 			ia64_set_dcr(dcr);
 			local_irq_restore(flags);
-
-			/*
-			 * This is a no can do.  It obviously wouldn't
-			 * work on SMP where another process may not
-			 * be blocked at all. We need to put in a  perfmon=20
-			 * IPI to take care of MP systems. See blurb above.
-			 */
-			lock_kernel();
-			for_each_task(p) {
-				regs =3D (struct pt_regs *) (((char *)p) + IA64_STK_OFFSET) -1 ;=09
-				ia64_psr(regs)->pp =3D 1;
-			}
-			unlock_kernel();
 			ia64_set_pmc(0, 0);
 		}
                 break;
=20
 	      case READ_PMDS:
-		if (cmd2 > MAX_PERF_COUNTER)
-			return -EFAULT;
+		if (cmd2 <=3D 0 || cmd2 > MAX_PERF_COUNTER - used_by_system)
+			return -EINVAL;
 		if (!access_ok(VERIFY_WRITE, cptr, sizeof(struct perf_counter)*cmd2))
 			return -EFAULT;
=20
@@ -153,9 +142,13 @@
 		 * when we re-enabled interrupts. When I muck with dcr,=20
 		 * is the irq_save/restore needed?
 		 */
-		for (i =3D 0, cnum =3D 4;i < MAX_PERF_COUNTER; i++, cnum++, cptr++){
-			pmd =3D pmds[i] + (ia64_get_pmd(cnum) & PERF_OVFL_VAL);
-			put_user(pmd, &cptr->data);
+		for (i =3D 0, cnum =3D 4;i < cmd2; i++, cnum++, cptr++) {
+			tmp.data =3D (pmds[smp_processor_id()][i]
+				    + (ia64_get_pmd(cnum) & PERF_OVFL_VAL));
+			tmp.counter_num =3D cnum;
+			if (copy_to_user(cptr, &tmp, sizeof(tmp)))
+				return -EFAULT;
+			//put_user(pmd, &cptr->data);
 		}
 		local_irq_save(flags);
 		__asm__ __volatile__("ssm psr.pp");
@@ -167,30 +160,22 @@
=20
 	      case STOP_PMCS:
 		ia64_set_pmc(0, 1);
-		for (i =3D 0; i < MAX_PERF_COUNTER; ++i)
-			ia64_set_pmc(i, 0);
+		ia64_srlz_d();
+		for (i =3D 0; i < MAX_PERF_COUNTER - used_by_system; ++i)
+			ia64_set_pmc(4+i, 0);
=20
-		local_irq_save(flags);
-		dcr =3D ia64_get_dcr();
-		dcr &=3D ~IA64_DCR_PP;
-		ia64_set_dcr(dcr);
-		local_irq_restore(flags);
-		/*
-		 * This is a no can do.  It obviously wouldn't
-		 * work on SMP where another process may not
-		 * be blocked at all. We need to put in a  perfmon=20
-		 * IPI to take care of MP systems. See blurb above.
-		 */
-		lock_kernel();
-		for_each_task(p) {
-			regs =3D (struct pt_regs *) (((char *)p) + IA64_STK_OFFSET) - 1;
-			ia64_psr(regs)->pp =3D 0;
+		if (!used_by_system) {
+			local_irq_save(flags);
+			dcr =3D ia64_get_dcr();
+			dcr &=3D ~IA64_DCR_PP;
+			ia64_set_dcr(dcr);
+			local_irq_restore(flags);
 		}
-		unlock_kernel();
-		perf_owner =3D NULL;
+		current->thread.flags &=3D ~(IA64_THREAD_PM_VALID);
 		break;
=20
 	      default:
+		return -EINVAL;
 		break;
         }
         return 0;
@@ -202,13 +187,13 @@
 	unsigned long mask, i, cnum, val;
=20
 	mask =3D ia64_get_pmc(0) >> 4;
-	for (i =3D 0, cnum =3D 4; i < MAX_PERF_COUNTER; cnum++, i++, mask >>=3D 1=
) {
+	for (i =3D 0, cnum =3D 4; i < MAX_PERF_COUNTER - used_by_system; cnum++, =
i++, mask >>=3D 1) {
+		val =3D 0;
 		if (mask & 0x1)=20
-			val =3D PERF_OVFL_VAL;
-		else
+			val +=3D PERF_OVFL_VAL + 1;
 		/* since we got an interrupt, might as well clear every pmd. */
-			val =3D ia64_get_pmd(cnum) & PERF_OVFL_VAL;
-		pmds[i] +=3D val;
+		val +=3D ia64_get_pmd(cnum) & PERF_OVFL_VAL;
+		pmds[smp_processor_id()][i] +=3D val;
 		ia64_set_pmd(cnum, 0);
 	}
 }
@@ -221,20 +206,61 @@
 	ia64_srlz_d();
 }
=20
+static struct irqaction perfmon_irqaction =3D {
+	handler:	perfmon_interrupt,
+	flags:		SA_INTERRUPT,
+	name:		"perfmon"
+};
+
 void
 perfmon_init (void)
 {
-        if (request_irq(PERFMON_IRQ, perfmon_interrupt, 0, "perfmon", NULL=
)) {
-		printk("perfmon_init: could not allocate performance monitor vector %u\n=
",
-		       PERFMON_IRQ);
-		return;
-	}
+	irq_desc[PERFMON_IRQ].status |=3D IRQ_PER_CPU;
+	irq_desc[PERFMON_IRQ].handler =3D &irq_type_ia64_sapic;
+	setup_irq(PERFMON_IRQ, &perfmon_irqaction);
+
 	ia64_set_pmv(PERFMON_IRQ);
 	ia64_srlz_d();
 	printk("Initialized perfmon vector to %u\n",PERFMON_IRQ);
 }
=20
+void
+perfmon_init_percpu (void)
+{
+	ia64_set_pmv(PERFMON_IRQ);
+	ia64_srlz_d();
+}
+
+void
+ia64_save_pm_regs (struct thread_struct *t)
+{
+	int i;
+
+	ia64_set_pmc(0, 1);
+	ia64_srlz_d();
+	for (i=3D0; i< IA64_NUM_PM_REGS - used_by_system ; i++) {
+		t->pmd[i] =3D ia64_get_pmd(4+i);
+		t->pmod[i] =3D pmds[smp_processor_id()][i];
+		t->pmc[i] =3D ia64_get_pmc(4+i);
+	}
+}
+
+void
+ia64_load_pm_regs (struct thread_struct *t)
+{
+	int i;
+
+	for (i=3D0; i< IA64_NUM_PM_REGS - used_by_system ; i++) {
+		ia64_set_pmd(4+i, t->pmd[i]);
+		pmds[smp_processor_id()][i] =3D t->pmod[i];
+		ia64_set_pmc(4+i, t->pmc[i]);
+	}
+	ia64_set_pmc(0, 0);
+	ia64_srlz_d();
+}
+
 #else /* !CONFIG_PERFMON */
+
 asmlinkage unsigned long
 sys_perfmonctl (int cmd1, int cmd2, void *ptr)
 {
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.0-test6-lia/arc=
h/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/process.c	Fri Aug 11 17:20:17 20=
00
@@ -27,6 +27,8 @@
 #include <asm/unwind.h>
 #include <asm/user.h>
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+
 static void
 do_show_stack (struct unw_frame_info *info, void *arg)
 {
@@ -44,6 +46,8 @@
 	} while (unw_unwind(info) >=3D 0);
 }
=20
+#endif
+
 void
 show_stack (struct task_struct *task)
 {
@@ -118,15 +122,14 @@
 	current->nice =3D 20;
 	current->counter =3D -100;
=20
-#ifdef CONFIG_SMP
-	if (!current->need_resched)
-		min_xtp();
-#endif
=20
 	while (1) {
-		while (!current->need_resched) {
+#ifdef CONFIG_SMP
+		if (!current->need_resched)
+			min_xtp();
+#endif
+		while (!current->need_resched)
 			continue;
-		}
 #ifdef CONFIG_SMP
 		normal_xtp();
 #endif
@@ -157,11 +160,12 @@
 void
 ia64_save_extra (struct task_struct *task)
 {
-	extern void ia64_save_debug_regs (unsigned long *save_area);
-	extern void ia32_save_state (struct thread_struct *thread);
-
 	if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0)
 		ia64_save_debug_regs(&task->thread.dbr[0]);
+#ifdef CONFIG_PERFMON
+	if ((task->thread.flags & IA64_THREAD_PM_VALID) !=3D 0)
+		ia64_save_pm_regs(&task->thread);
+#endif
 	if (IS_IA32_PROCESS(ia64_task_regs(task)))
 		ia32_save_state(&task->thread);
 }
@@ -169,11 +173,12 @@
 void
 ia64_load_extra (struct task_struct *task)
 {
-	extern void ia64_load_debug_regs (unsigned long *save_area);
-	extern void ia32_load_state (struct thread_struct *thread);
-
 	if ((task->thread.flags & IA64_THREAD_DBG_VALID) !=3D 0)
 		ia64_load_debug_regs(&task->thread.dbr[0]);
+#ifdef CONFIG_PERFMON
+	if ((task->thread.flags & IA64_THREAD_PM_VALID) !=3D 0)
+		ia64_load_pm_regs(&task->thread);
+#endif
 	if (IS_IA32_PROCESS(ia64_task_regs(task)))
 		ia32_load_state(&task->thread);
 }
@@ -530,17 +535,6 @@
 	if (ia64_get_fpu_owner() =3D current) {
 		ia64_set_fpu_owner(0);
 	}
-}
-
-/*
- * Free remaining state associated with DEAD_TASK.  This is called
- * after the parent of DEAD_TASK has collected the exist status of the
- * task via wait().
- */
-void
-release_thread (struct task_struct *dead_task)
-{
-	/* nothing to do */
 }
=20
 unsigned long
diff -urN linux-davidm/arch/ia64/kernel/sal.c linux-2.4.0-test6-lia/arch/ia=
64/kernel/sal.c
--- linux-davidm/arch/ia64/kernel/sal.c	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/sal.c	Mon Jul 31 14:01:22 2000
@@ -156,6 +156,14 @@
 			      struct ia64_sal_desc_platform_feature *pf =3D (void *) p;
 			      printk("SAL: Platform features ");
=20
+#ifdef CONFIG_IA64_HAVE_IRQREDIR
+			      /*
+			       * Early versions of SAL say we don't have
+			       * IRQ redirection, even though we do...
+			       */
+			      pf->feature_mask |=3D (1 << 1);
+#endif
+
 			      if (pf->feature_mask & (1 << 0))
 				      printk("BusLock ");
=20
diff -urN linux-davidm/arch/ia64/kernel/semaphore.c linux-2.4.0-test6-lia/a=
rch/ia64/kernel/semaphore.c
--- linux-davidm/arch/ia64/kernel/semaphore.c	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/semaphore.c	Fri Aug 11 17:20:34 =
2000
@@ -222,9 +222,6 @@
 void
 __down_read_failed (struct rw_semaphore *sem, long count)
 {
-	struct task_struct *tsk =3D current;
-	DECLARE_WAITQUEUE(wait, tsk);
-
 	while (1) {
 		if (count =3D -1) {
 			down_read_failed_biased(sem);
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test6-lia/arch/=
ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Fri Aug 11 19:01:14 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/setup.c	Mon Jul 31 14:01:22 2000
@@ -137,19 +137,65 @@
 	 */
 	bootmap_start =3D PAGE_ALIGN(__pa(&_end));
 	if (ia64_boot_param.initrd_size)
-		bootmap_start =3D PAGE_ALIGN(bootmap_start + ia64_boot_param.initrd_size=
);
+		bootmap_start =3D PAGE_ALIGN(bootmap_start
+					   + ia64_boot_param.initrd_size);
 	bootmap_size =3D init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
=20
 	efi_memmap_walk(free_available_memory, 0);
=20
 	reserve_bootmem(bootmap_start, bootmap_size);
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	initrd_start =3D ia64_boot_param.initrd_start;
+
 	if (initrd_start) {
+		u64 start, size;
+#		define is_same_page(a,b) (((a)&PAGE_MASK) =3D ((b)&PAGE_MASK))
+
+#if 1
+		/* XXX for now some backwards compatibility... */
+		if (initrd_start >=3D PAGE_OFFSET)
+			printk("Warning: boot loader passed virtual address "
+			       "for initrd, please upgrade the loader\n");
+		} else
+#endif
+			/*=20
+			 * The loader ONLY passes physical addresses
+			 */
+			initrd_start =3D (unsigned long)__va(initrd_start);
 		initrd_end =3D initrd_start+ia64_boot_param.initrd_size;
+		start      =3D initrd_start;
+		size       =3D ia64_boot_param.initrd_size;
+
 		printk("Initial ramdisk at: 0x%p (%lu bytes)\n",
 		       (void *) initrd_start, ia64_boot_param.initrd_size);
-		reserve_bootmem(virt_to_phys(initrd_start), ia64_boot_param.initrd_size);
+
+		/*
+		 * The kernel end and the beginning of initrd can be
+		 * on the same page. This would cause the page to be
+		 * reserved twice.  While not harmful, it does lead to
+		 * a warning message which can cause confusion.  Thus,
+		 * we make sure that in this case we only reserve new
+		 * pages, i.e., initrd only pages. We need to:
+		 *
+		 *	- align up start
+		 *	- adjust size of reserved section accordingly
+		 *
+		 * It should be noted that this operation is only
+		 * valid for the reserve_bootmem() call and does not
+		 * affect the integrety of the initrd itself.
+		 *
+		 * reserve_bootmem() considers partial pages as reserved.
+		 */
+		if (is_same_page(initrd_start, (unsigned long)&_end)) {
+			start  =3D PAGE_ALIGN(start);
+			size  -=3D start-initrd_start;
+
+			printk("Initial ramdisk & kernel on the same page: "
+			       "reserving start=3D%lx size=3D%ld bytes\n",
+			       start, size);
+		}
+		reserve_bootmem(__pa(start), size);
 	}
 #endif
 #if 0
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-test6-lia/arch/ia=
64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/smp.c	Fri Aug 11 20:40:15 2000
@@ -135,6 +135,7 @@
 static inline int
 pointer_lock(void *lock, void *data, int retry)
 {
+	volatile long *ptr =3D lock;
  again:
 	if (cmpxchg_acq((void **) lock, 0, data) =3D 0)
 		return 0;
@@ -142,7 +143,7 @@
 	if (!retry)
 		return -EBUSY;
=20
-	while (*(void **) lock)
+	while (*ptr)
 		;
=20
 	goto again;
@@ -320,6 +321,58 @@
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
@@ -396,13 +449,19 @@
 smp_do_timer(struct pt_regs *regs)
 {
         int cpu =3D smp_processor_id();
+        int user =3D user_mode(regs);
 	struct cpuinfo_ia64 *data =3D &cpu_data[cpu];
=20
-        if (!--data->prof_counter) {
-		irq_enter(cpu, TIMER_IRQ);
-		update_process_times(user_mode(regs));
+        if (--data->prof_counter <=3D 0) {
 		data->prof_counter =3D data->prof_multiplier;
-		irq_exit(cpu, TIMER_IRQ);
+		/*
+		 * update_process_times() expects us to have done irq_enter().
+		 * Besides, if we don't timer interrupts ignore the global
+		 * interrupt lock, which is the WrongThing (tm) to do.
+		 */
+		irq_enter(cpu, 0);
+		update_process_times(user);
+		irq_exit(cpu, 0);
 	}
 }
=20
@@ -473,6 +532,11 @@
 	extern void ia64_rid_init(void);
 	extern void ia64_init_itm(void);
 	extern void ia64_cpu_local_tick(void);
+#ifdef CONFIG_PERFMON
+	extern void perfmon_init_percpu(void);
+#endif
+
+	efi_map_pal_code();
=20
 	cpu_init();
=20
@@ -480,6 +544,10 @@
=20
 	/* setup the CPU local timer tick */
 	ia64_init_itm();
+
+#ifdef CONFIG_PERFMON
+	perfmon_init_percpu();
+#endif
=20
 	/* Disable all local interrupts */
 	ia64_set_lrr0(0, 1);=09
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.0-test6-lia/arch/i=
a64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/time.c	Mon Jul 31 14:01:22 2000
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
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-test6-lia/arch=
/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/kernel/unwind.c	Fri Aug 11 15:52:00 2000
@@ -62,7 +62,7 @@
 #define UNW_LOG_HASH_SIZE	(UNW_LOG_CACHE_SIZE + 1)
 #define UNW_HASH_SIZE		(1 << UNW_LOG_HASH_SIZE)
=20
-#define UNW_DEBUG	1
+#define UNW_DEBUG	0
 #define UNW_STATS	0	/* WARNING: this disabled interrupts for long time-spa=
ns!! */
=20
 #if UNW_DEBUG
diff -urN linux-davidm/arch/ia64/lib/memcpy.S linux-2.4.0-test6-lia/arch/ia=
64/lib/memcpy.S
--- linux-davidm/arch/ia64/lib/memcpy.S	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/lib/memcpy.S	Sat Aug  5 13:19:26 2000
@@ -1,3 +1,20 @@
+/*
+ *
+ * Optimized version of the standard memcpy() function
+ *
+ * Inputs:
+ * 	in0:	destination address
+ *	in1:	source address
+ *	in2:	number of bytes to copy
+ * Output:
+ * 	no return value
+ *
+ * Copyright (C) 2000 Hewlett-Packard Co
+ * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+#include <linux/config.h>
+
 #include <asm/asmmacro.h>
=20
 GLOBAL_ENTRY(bcopy)
@@ -10,77 +27,254 @@
 	// FALL THROUGH
 GLOBAL_ENTRY(memcpy)
=20
-#	define MEM_LAT	4
-
-#	define N	MEM_LAT-1
-#	define Nrot	((MEM_LAT + 7) & ~7)
+#	define MEM_LAT	2		/* latency to L1 cache */
=20
 #	define dst	r2
 #	define src	r3
-#	define len	r9
-#	define saved_pfs r10
-#	define saved_lc	r11
-#	define saved_pr	r16
-#	define t0	r17
-#	define cnt	r18
-
+#	define retval	r8
+#	define saved_pfs r9
+#	define saved_lc	r10
+#	define saved_pr	r11
+#	define cnt	r16
+#	define src2	r17
+#	define t0	r18
+#	define t1	r19
+#	define t2	r20
+#	define t3	r21
+#	define t4	r22
+#	define src_end	r23
+
+#	define N	(MEM_LAT + 4)
+#	define Nrot	((N + 7) & ~7)
+
+	/*
+	 * First, check if everything (src, dst, len) is a multiple of eight.  If
+	 * so, we handle everything with no taken branches (other than the loop
+	 * itself) and a small icache footprint.  Otherwise, we jump off to
+	 * the more general copy routine handling arbitrary
+	 * sizes/alignment etc.
+	 */
 	UNW(.prologue)
 	UNW(.save ar.pfs, saved_pfs)
 	alloc saved_pfs=3Dar.pfs,3,Nrot,0,Nrot
+#if !(defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BST=
EP_SPECIFIC))
 	lfetch [in1]
+#else
+	nop.m 0
+#endif
+	or t0=3Din0,in1
+	;;
=20
-	.rotr val[MEM_LAT]
-	.rotp p[MEM_LAT]
-
+	or t0=3Dt0,in2
 	UNW(.save ar.lc, saved_lc)
 	mov saved_lc=3Dar.lc
-
-	or t0=3Din0,in1
 	UNW(.save pr, saved_pr)
 	mov saved_pr=3Dpr
=20
-	UNW(.body)
-
-	mov ar.ec=3DMEM_LAT
+	cmp.eq p6,p0=3Din2,r0	// zero length?
+	mov retval=3Din0		// return dst
+(p6)	br.ret.spnt.many rp	// zero length, return immediately
+	;;
=20
-	mov r8=3Din0		// return dst
-	shr cnt=3Din2,3		// number of 8-byte words to copy
+	mov dst=3Din0		// copy because of rotation
+	shr.u cnt=3Din2,3		// number of 8-byte words to copy
 	mov pr.rot=3D1<<16
 	;;
-	cmp.eq p6,p0=3Din2,r0	// zero length?
-	or t0=3Dt0,in2
-(p6)	br.ret.spnt.many rp	// yes, return immediately
=20
-	mov dst=3Din0		// copy because of rotation
-	mov src=3Din1		// copy because of rotation
 	adds cnt=3D-1,cnt		// br.ctop is repeat/until
+	cmp.gtu p7,p0=16,in2	// copying less than 16 bytes?
+	UNW(.body)
+	mov ar.ec=3DN
 	;;
+
 	and t0=3D0x7,t0
 	mov ar.lc=3Dcnt
 	;;
 	cmp.ne p6,p0=3Dt0,r0
-(p6)	br.cond.spnt.few slow_memcpy
=20
+	mov src=3Din1		// copy because of rotation
+(p7)	br.cond.spnt.few memcpy_short
+(p6)	br.cond.spnt.few memcpy_long
+	;;
+	.rotr val[N]
+	.rotp p[N]
 1:
 (p[0])	ld8 val[0]=3D[src],8
-(p[N])	st8 [dst]=3Dval[N],8
-	br.ctop.sptk.few 1b
+(p[N-1])st8 [dst]=3Dval[N-1],8
+	br.ctop.dptk.few 1b
 	;;
-.exit:
 	mov ar.lc=3Dsaved_lc
-	mov pr=3Dsaved_pr,0xffffffffffff0000
+	mov pr=3Dsaved_pr,-1
 	mov ar.pfs=3Dsaved_pfs
 	br.ret.sptk.many rp
=20
-slow_memcpy:
-	adds cnt=3D-1,in2
+	/*
+	 * Small (<16 bytes) unaligned copying is done via a simple byte-at-the-t=
ime
+	 * copy loop.  This performs relatively poorly on Itanium, but it doesn't
+	 * get used very often (gcc inlines small copies) and due to atomicity
+	 * issues, we want to avoid read-modify-write of entire words.
+	 */
+	.align 32
+memcpy_short:
+	adds cnt=3D-1,in2		// br.ctop is repeat/until
+	mov ar.ec=3DMEM_LAT
 	;;
 	mov ar.lc=3Dcnt
 	;;
+	/*
+	 * It is faster to put a stop bit in the loop here because it makes
+	 * the pipeline shorter (and latency is what matters on short copies).
+	 */
 1:
 (p[0])	ld1 val[0]=3D[src],1
-(p[N])	st1 [dst]=3Dval[N],1
-	br.ctop.sptk.few 1b
-	br.sptk.few .exit
+	;;
+(p[MEM_LAT-1])st1 [dst]=3Dval[MEM_LAT-1],1
+	br.ctop.dptk.few 1b
+	;;
+	mov ar.lc=3Dsaved_lc
+	mov pr=3Dsaved_pr,-1
+	mov ar.pfs=3Dsaved_pfs
+	br.ret.sptk.many rp
+
+	/*
+	 * Large (>=3D 16 bytes) copying is done in a fancy way.  Latency isn't
+	 * an overriding concern here, but throughput is.  We first do
+	 * sub-word copying until the destination is aligned, then we check
+	 * if the source is also aligned.  If so, we do a simple load/store-loop
+	 * until there are less than 8 bytes left over and then we do the tail,
+	 * by storing the last few bytes using sub-word copying.  If the source
+	 * is not aligned, we branch off to the non-congruent loop.
+	 *
+	 *   stage:   op:
+	 *         0  ld
+	 *	   :
+	 * MEM_LAT+3  shrp
+	 * MEM_LAT+4  st
+	 *
+	 * On Itanium, the pipeline itself runs without stalls.  However,  br.ctop
+	 * seems to introduce an unavoidable bubble in the pipeline so the overall
+	 * latency is 2 cycles/iteration.  This gives us a _copy_ throughput
+	 * of 4 byte/cycle.  Still not bad.
+	 */
+#	undef N
+#	undef Nrot
+#	define N	(MEM_LAT + 5)		/* number of stages */
+#	define Nrot	((N+1 + 2 + 7) & ~7)	/* number of rotating regs */
+
+#define LOG_LOOP_SIZE	6
+
+memcpy_long:
+	alloc t3=3Dar.pfs,3,Nrot,0,Nrot	// resize register frame
+	and t0=3D-8,src		// t0 =3D src & ~7
+	and t2=3D7,src		// t2 =3D src & 7
+	;;
+	ld8 t0=3D[t0]		// t0 =3D 1st source word
+	adds src2=3D7,src		// src2 =3D (src + 7)
+	sub t4=3Dr0,dst		// t4 =3D -dst
+	;;
+	and src2=3D-8,src2	// src2 =3D (src + 7) & ~7
+	shl t2=3Dt2,3		// t2 =3D 8*(src & 7)
+	shl t4=3Dt4,3		// t4 =3D 8*(dst & 7)
+	;;
+	ld8 t1=3D[src2]		// t1 =3D 1st source word if src is 8-byte aligned, 2nd =
otherwise
+	sub t3d,t2		// t3 =3D 64-8*(src & 7)
+	shr.u t0=3Dt0,t2
+	;;
+	add src_end=3Dsrc,in2
+	shl t1=3Dt1,t3
+	mov pr=3Dt4,0x38		// (p5,p4,p3)=3D(dst & 7)
+	;;
+	or t0=3Dt0,t1
+	mov cnt=3Dr0
+	adds src_end=3D-1,src_end
+	;;
+(p3)	st1 [dst]=3Dt0,1
+(p3)	shr.u t0=3Dt0,8
+(p3)	adds cnt=3D1,cnt
+	;;
+(p4)	st2 [dst]=3Dt0,2
+(p4)	shr.u t0=3Dt0,16
+(p4)	adds cnt=3D2,cnt
+	;;
+(p5)	st4 [dst]=3Dt0,4
+(p5)	adds cnt=3D4,cnt
+	and src_end=3D-8,src_end	// src_end =3D last word of source buffer
+	;;
+
+	// At this point, dst is aligned to 8 bytes and there at least 16-7=3D9 b=
ytes left to copy:
+
+1:{	add src=3Dcnt,src			// make src point to remainder of source buffer
+	sub cnt=3Din2,cnt			// cnt =3D number of bytes left to copy
+	mov t4=3Dip
+  }	;;
+	and src2=3D-8,src			// align source pointer
+	adds t4=3Dmemcpy_loops-1b,t4
+	mov ar.ec=3DN
+
+	and t0=3D7,src			// t0 =3D src & 7
+	shr.u t2=3Dcnt,3			// t2 =3D number of 8-byte words left to copy
+	shl cnt=3Dcnt,3			// move bits 0-2 to 3-5
+	;;
+
+	.rotr val[N+1], w[2]
+	.rotp p[N]
+
+	cmp.ne p6,p0=3Dt0,r0		// is src aligned, too?
+	shl t0=3Dt0,LOG_LOOP_SIZE		// t0 =3D 8*(src & 7)
+	adds t2=3D-1,t2			// br.ctop is repeat/until
+	;;
+	add t4=3Dt0,t4
+	mov pr=3Dcnt,0x38			// set (p5,p4,p3) to # of bytes last-word bytes to co=
py
+	mov ar.lc=3Dt2
+	;;
+(p6)	ld8 val[1]=3D[src2],8		// prime the pump...
+	mov b6=3Dt4
+	br.sptk.few b6
+	;;
+
+memcpy_tail:
+	// At this point, (p5,p4,p3) are set to the number of bytes left to copy =
(which is
+	// less than 8) and t0 contains the last few bytes of the src buffer:
+(p5)	st4 [dst]=3Dt0,4
+(p5)	shr.u t0=3Dt0,32
+	mov ar.lc=3Dsaved_lc
+	;;
+(p4)	st2 [dst]=3Dt0,2
+(p4)	shr.u t0=3Dt0,16
+	mov ar.pfs=3Dsaved_pfs
+	;;
+(p3)	st1 [dst]=3Dt0
+	mov pr=3Dsaved_pr,-1
+	br.ret.sptk.many rp
+
+///////////////////////////////////////////////////////
+	.align 64
+
+#define COPY(shift,index)									\
+ 1:												\
+  { .mfi											\
+	(p[0])		ld8 val[0]=3D[src2],8;							\
+			nop.f 0;								\
+	(p[MEM_LAT+3])	shrp w[0]=3Dval[MEM_LAT+3],val[MEM_LAT+4-index],shift;			\
+  };												\
+  { .mbb											\
+	(p[MEM_LAT+4])	st8 [dst]=3Dw[1],8;							\
+			nop.b 0;								\
+			br.ctop.dptk.few 1b;							\
+  };												\
+			;;									\
+			ld8 val[N-1]=3D[src_end];	/* load last word (may be same as val[N]) */	\
+			;;									\
+			shrp t0=3Dval[N-1],val[N-index],shift;					\
+			br memcpy_tail
+memcpy_loops:
+	COPY(0, 1) /* no point special casing this---it doesn't go any faster wit=
hout shrp */
+	COPY(8, 0)
+	COPY(16, 0)
+	COPY(24, 0)
+	COPY(32, 0)
+	COPY(40, 0)
+	COPY(48, 0)
+	COPY(56, 0)
=20
 END(memcpy)
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test6-lia/arch/ia64/=
mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Fri Aug 11 19:01:15 2000
+++ linux-2.4.0-test6-lia/arch/ia64/mm/init.c	Mon Jul 31 14:01:22 2000
@@ -185,8 +185,42 @@
 void
 free_initrd_mem(unsigned long start, unsigned long end)
 {
+	/*
+	 * EFI uses 4KB pages while the kernel can use 4KB  or bigger.
+	 * Thus EFI and the kernel may have different page sizes. It is=20
+	 * therefore possible to have the initrd share the same page as=20
+	 * the end of the kernel (given current setup).=20
+	 *
+	 * To avoid freeing/using the wrong page (kernel sized) we:
+	 * 	- align up the beginning of initrd
+	 *	- keep the end untouched
+	 *
+	 *  |             |
+	 *  |=3D=3D=3D=3D=3D=3D=3D| a000
+	 *  |             |
+	 *  |             |
+	 *  |             | 9000
+	 *  |/////////////|=20
+	 *  |/////////////|=20
+	 *  |=3D=3D=3D=3D=3D=3D=3D| 8000
+	 *  |///INITRD////|
+	 *  |/////////////|
+	 *  |/////////////| 7000
+	 *  |             |
+	 *  |KKKKKKKKKKKKK|
+	 *  |=3D=3D=3D=3D=3D=3D=3D| 6000
+	 *  |KKKKKKKKKKKKK|
+	 *  |KKKKKKKKKKKKK|=20
+	 *  K=3Dkernel using 8KB pages
+	 *=20
+	 * In this example, we must free page 8000 ONLY. So we must align up
+	 * initrd_start and keep initrd_end as is.
+	 */
+	start =3D PAGE_ALIGN(start);
+
 	if (start < end)
 		printk ("Freeing initrd memory: %ldkB freed\n", (end - start) >> 10);
+
 	for (; start < end; start +=3D PAGE_SIZE) {
 		clear_bit(PG_reserved, &virt_to_page(start)->flags);
 		set_page_count(virt_to_page(start), 1);
diff -urN linux-davidm/arch/ia64/mm/tlb.c linux-2.4.0-test6-lia/arch/ia64/m=
m/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Wed Aug  2 18:54:02 2000
+++ linux-2.4.0-test6-lia/arch/ia64/mm/tlb.c	Mon Jul 31 14:01:22 2000
@@ -1,8 +1,11 @@
 /*
  * TLB support routines.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 08/02/00 A. Mallick <asit.k.mallick@intel.com>=09
+ *		Modified RID allocation for SMP=20
  */
 #include <linux/config.h>
 #include <linux/init.h>
@@ -27,9 +30,11 @@
 		1 << _PAGE_SIZE_8K   |		\
 		1 << _PAGE_SIZE_4K )
=20
-static void wrap_context (struct mm_struct *mm);
-
-unsigned long ia64_next_context =3D (1UL << IA64_HW_CONTEXT_BITS) + 1;
+struct ia64_ctx ia64_ctx =3D {
+	lock:	SPIN_LOCK_UNLOCKED,
+	next:	1,
+	limit:	(1UL << IA64_HW_CONTEXT_BITS)
+};
=20
  /*
   * Put everything in a struct so we avoid the global offset table whenever
@@ -106,49 +111,43 @@
=20
 #endif /* CONFIG_SMP && !CONFIG_ITANIUM_PTCG */
=20
-void
-get_new_mmu_context (struct mm_struct *mm)
-{
-	if ((ia64_next_context & IA64_HW_CONTEXT_MASK) =3D 0) {
-		wrap_context(mm);
-	}
-	mm->context =3D ia64_next_context++;
-}
-
 /*
- * This is where we handle the case where (ia64_next_context &
- * IA64_HW_CONTEXT_MASK) =3D 0.  Whenever this happens, we need to
- * flush the entire TLB and skip over region id number 0, which is
- * used by the kernel.
+ * Acquire the ia64_ctx.lock before calling this function!
  */
-static void
-wrap_context (struct mm_struct *mm)
+void
+wrap_mmu_context (struct mm_struct *mm)
 {
-	struct task_struct *task;
+	struct task_struct *tsk;
+	unsigned long tsk_context;
+
+	if (ia64_ctx.next >=3D (1UL << IA64_HW_CONTEXT_BITS))=20
+		ia64_ctx.next =3D 300;	/* skip daemons */
+	ia64_ctx.limit =3D (1UL << IA64_HW_CONTEXT_BITS);
=20
 	/*
-	 * We wrapped back to the first region id so we nuke the TLB
-	 * so we can switch to the next generation of region ids.
+	 * Scan all the task's mm->context and set proper safe range
 	 */
-	__flush_tlb_all();
-	if (ia64_next_context++ =3D 0) {
-		/*
-		 * Oops, we've used up all 64 bits of the context
-		 * space---walk through task table to ensure we don't
-		 * get tricked into using an old context.  If this
-		 * happens, the machine has been running for a long,
-		 * long time!
-		 */
-		ia64_next_context =3D (1UL << IA64_HW_CONTEXT_BITS) + 1;
-
-		read_lock(&tasklist_lock);
-		for_each_task (task) {
-			if (task->mm =3D mm)
-				continue;
-			flush_tlb_mm(mm);
+
+	read_lock(&tasklist_lock);
+  repeat:
+	for_each_task(tsk) {
+		if (!tsk->mm)
+			continue;
+		tsk_context =3D tsk->mm->context;
+		if (tsk_context =3D ia64_ctx.next) {
+			if (++ia64_ctx.next >=3D ia64_ctx.limit) {
+				/* empty range: reset the range limit and start over */
+				if (ia64_ctx.next >=3D (1UL << IA64_HW_CONTEXT_BITS))=20
+					ia64_ctx.next =3D 300;
+				ia64_ctx.limit =3D (1UL << IA64_HW_CONTEXT_BITS);
+				goto repeat;
+			}
 		}
-		read_unlock(&tasklist_lock);
+		if ((tsk_context > ia64_ctx.next) && (tsk_context < ia64_ctx.limit))
+			ia64_ctx.limit =3D tsk_context;
 	}
+	read_unlock(&tasklist_lock);
+	flush_tlb_all();
 }
=20
 void
diff -urN linux-davidm/arch/ia64/sn/sn1/irq.c linux-2.4.0-test6-lia/arch/ia=
64/sn/sn1/irq.c
--- linux-davidm/arch/ia64/sn/sn1/irq.c	Fri Aug 11 19:01:15 2000
+++ linux-2.4.0-test6-lia/arch/ia64/sn/sn1/irq.c	Mon Jul 31 14:01:22 2000
@@ -1,6 +1,6 @@
 #include <linux/kernel.h>
-#include <linux/irq.h>
 #include <linux/sched.h>
+#include <linux/irq.h>
=20
 #include <asm/ptrace.h>
=20
diff -urN linux-davidm/drivers/char/Makefile linux-2.4.0-test6-lia/drivers/=
char/Makefile
--- linux-davidm/drivers/char/Makefile	Fri Aug 11 19:01:15 2000
+++ linux-2.4.0-test6-lia/drivers/char/Makefile	Thu Aug 10 20:29:27 2000
@@ -109,7 +109,17 @@
 endif
=20
 obj-$(CONFIG_MAGIC_SYSRQ) +=3D sysrq.o
+
 obj-$(CONFIG_ATARI_DSP56K) +=3D dsp56k.o
+ifeq ($(CONFIG_ATARI_DSP56K),y)
+S =3D y
+else
+  ifeq ($(CONFIG_ATARI_DSP56K),m)
+  SM =3D y
+  endif
+endif
+
+obj-$(CONFIG_SIM_SERIAL) +=3D simserial.o
 obj-$(CONFIG_ROCKETPORT) +=3D rocket.o
 obj-$(CONFIG_MOXA_SMARTIO) +=3D mxser.o
 obj-$(CONFIG_MOXA_INTELLIO) +=3D moxa.o
diff -urN linux-davidm/drivers/char/agp/agpgart_be.c linux-2.4.0-test6-lia/=
drivers/char/agp/agpgart_be.c
--- linux-davidm/drivers/char/agp/agpgart_be.c	Thu Aug 10 19:56:21 2000
+++ linux-2.4.0-test6-lia/drivers/char/agp/agpgart_be.c	Mon Jul 31 14:01:22=
 2000
@@ -67,14 +67,16 @@
 {
 #if defined(__i386__)
 	asm volatile ("wbinvd":::"memory");
-#elif defined(__alpha__)
+#elif defined(__alpha__) || defined(__ia64__)
 	/* ??? I wonder if we'll really need to flush caches, or if the
 	   core logic can manage to keep the system coherent.  The ARM
 	   speaks only of using `cflush' to get things in memory in
 	   preparation for power failure.
=20
 	   If we do need to call `cflush', we'll need a target page,
-	   as we can only flush one page at a time.  */
+	   as we can only flush one page at a time.
+
+	   Ditto for IA-64. --davidm 00/08/07 */
 	mb();
 #else
 #error "Please define flush_cache."
diff -urN linux-davidm/drivers/char/drm/agpsupport.c linux-2.4.0-test6-lia/=
drivers/char/drm/agpsupport.c
--- linux-davidm/drivers/char/drm/agpsupport.c	Thu Aug 10 19:56:21 2000
+++ linux-2.4.0-test6-lia/drivers/char/drm/agpsupport.c	Mon Jul 31 14:01:22=
 2000
@@ -322,7 +322,7 @@
 		case ALI_M1541: 	head->chipset =3D "ALi M1541";     break;
 		default:		head->chipset =3D "Unknown";       break;
 		}
-		DRM_INFO("AGP %d.%d on %s @ 0x%08lx %dMB\n",
+		DRM_INFO("AGP %d.%d on %s @ 0x%08lx %ZuMB\n",
 			 head->agp_info.version.major,
 			 head->agp_info.version.minor,
 			 head->chipset,
diff -urN linux-davidm/drivers/char/drm/lists.c linux-2.4.0-test6-lia/drive=
rs/char/drm/lists.c
--- linux-davidm/drivers/char/drm/lists.c	Wed Aug  2 18:54:13 2000
+++ linux-2.4.0-test6-lia/drivers/char/drm/lists.c	Mon Jul 31 14:01:22 2000
@@ -153,6 +153,7 @@
 #endif
 	buf->list	=3D DRM_LIST_FREE;
 	do {
+		/* XXX this is wrong due to the ABA problem! --davidm 00/08/07 */
 		old       =3D bl->next;
 		buf->next =3D old;
 		prev      =3D cmpxchg(&bl->next, old, buf);
@@ -185,6 +186,7 @@
 =09
 				/* Get buffer */
 	do {
+		/* XXX this is wrong due to the ABA problem! --davidm 00/08/07 */
 		old =3D bl->next;
 		if (!old) return NULL;
 		new  =3D bl->next->next;
diff -urN linux-davidm/drivers/char/drm/vm.c linux-2.4.0-test6-lia/drivers/=
char/drm/vm.c
--- linux-davidm/drivers/char/drm/vm.c	Thu Aug 10 19:56:21 2000
+++ linux-2.4.0-test6-lia/drivers/char/drm/vm.c	Fri Aug 11 15:38:46 2000
@@ -250,7 +250,7 @@
 		  vma->vm_start, vma->vm_end, VM_OFFSET(vma));
=20
 				/* Length must match exact page count */
-	if ((length >> PAGE_SHIFT) !=3D dma->page_count) {
+	if (!dma || (length >> PAGE_SHIFT) !=3D dma->page_count) {
 		unlock_kernel();
 		return -EINVAL;
 	}
@@ -323,6 +323,9 @@
 				pgprot_val(vma->vm_page_prot) |=3D _PAGE_PCD;
 				pgprot_val(vma->vm_page_prot) &=3D ~_PAGE_PWT;
 			}
+#elif defined(__ia64__)
+			if (map->type !=3D _DRM_AGP)
+				vma->vm_page_prot =3D pgprot_writecombine(vma->vm_page_prot);
 #endif
 			vma->vm_flags |=3D VM_IO;	/* not in core dump */
 		}
diff -urN linux-davidm/drivers/char/efirtc.c linux-2.4.0-test6-lia/drivers/=
char/efirtc.c
--- linux-davidm/drivers/char/efirtc.c	Wed Aug  2 18:54:14 2000
+++ linux-2.4.0-test6-lia/drivers/char/efirtc.c	Fri Aug 11 17:21:50 2000
@@ -395,11 +395,10 @@
 	return 0;
 }
=20
-static int __exit
+static void __exit
 efi_rtc_exit(void)
 {
 	/* not yet used */
-	return 0;
 }
=20
 module_init(efi_rtc_init);
diff -urN linux-davidm/drivers/char/simserial.c linux-2.4.0-test6-lia/drive=
rs/char/simserial.c
--- linux-davidm/drivers/char/simserial.c	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/drivers/char/simserial.c	Fri Aug 11 14:56:04 2000
@@ -742,7 +742,7 @@
 	info->tqueue.data =3D info;
 	info->state =3D sstate;
 	if (sstate->info) {
-		kfree_s(info, sizeof(struct async_struct));
+		kfree(info);
 		*ret_info =3D sstate->info;
 		return 0;
 	}
diff -urN linux-davidm/drivers/pci/pci.ids linux-2.4.0-test6-lia/drivers/pc=
i/pci.ids
--- linux-davidm/drivers/pci/pci.ids	Thu Aug 10 19:56:23 2000
+++ linux-2.4.0-test6-lia/drivers/pci/pci.ids	Thu Aug 10 20:29:30 2000
@@ -4635,7 +4635,12 @@
 	84c4  450KX/GX [Orion] - 82454KX/GX PCI bridge
 	84c5  450KX/GX [Orion] - 82453KX/GX Memory controller
 	84ca  450NX - 82451NX Memory & I/O Controller
-	84cb  450NX - 82454NX PCI Expander Bridge
+	84cb  450NX - 82454NX/84460GX PCI Expander Bridge
+	84e0  460GX - 84460GX System Address Controller (SAC)
+	84e1  460GX - 84460GX System Data Controller (SDC)
+	84e2  460GX - 84460GX AGP Bridge (GXB)
+	84e3  460GX - 84460GX Memory Address Controller (MAC)
+	84e4  460GX - 84460GX Memory Data Controller (MDC)
 	ffff  450NX/GX [Orion] - 82453KX/GX Memory controller [BUG]
 8800  Trigem Computer Inc.
 	2008  Video assistent component
diff -urN linux-davidm/fs/dcache.c linux-2.4.0-test6-lia/fs/dcache.c
--- linux-davidm/fs/dcache.c	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/fs/dcache.c	Fri Aug 11 17:23:00 2000
@@ -1189,8 +1189,9 @@
 	if (!dentry_cache)
 		panic("Cannot create dentry cache");
=20
-	if (PAGE_SHIFT < 13)
-		mempages >>=3D (13 - PAGE_SHIFT);
+#if PAGE_SHIFT < 13
+	mempages >>=3D (13 - PAGE_SHIFT);
+#endif
 	mempages *=3D sizeof(struct list_head);
 	for (order =3D 0; ((1UL << order) << PAGE_SHIFT) < mempages; order++)
 		;
diff -urN linux-davidm/include/asm-ia64/asmmacro.h linux-2.4.0-test6-lia/in=
clude/asm-ia64/asmmacro.h
--- linux-davidm/include/asm-ia64/asmmacro.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/asmmacro.h	Fri Aug 11 16:43:58 2=
000
@@ -23,7 +23,7 @@
 #endif
=20
 #define ENTRY(name)				\
-	.align 16;				\
+	.align 32;				\
 	.proc name;				\
 name:
=20
diff -urN linux-davidm/include/asm-ia64/machvec.h linux-2.4.0-test6-lia/inc=
lude/asm-ia64/machvec.h
--- linux-davidm/include/asm-ia64/machvec.h	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/machvec.h	Fri Aug 11 16:43:55 20=
00
@@ -40,7 +40,7 @@
 # elif defined (CONFIG_IA64_DIG)
 #  include <asm/machvec_dig.h>
 # elif defined (CONFIG_IA64_SGI_SN1_SIM)
-#  include <asm/machvec_sgi_sn1.h>
+#  include <asm/machvec_sn1.h>
 # elif defined (CONFIG_IA64_GENERIC)
=20
 # ifdef MACHVEC_PLATFORM_HEADER
diff -urN linux-davidm/include/asm-ia64/mmu_context.h linux-2.4.0-test6-lia=
/include/asm-ia64/mmu_context.h
--- linux-davidm/include/asm-ia64/mmu_context.h	Sun Feb 13 10:31:06 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/mmu_context.h	Fri Aug 11 16:43:5=
6 2000
@@ -2,12 +2,13 @@
 #define _ASM_IA64_MMU_CONTEXT_H
=20
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/config.h>
 #include <linux/sched.h>
+#include <linux/spinlock.h>
=20
 #include <asm/processor.h>
=20
@@ -26,21 +27,6 @@
  * architecture manual guarantees this number to be in the range
  * 18-24.
  *
- * A context number has the following format:
- *
- *  +--------------------+---------------------+
- *  |  generation number |    region id        |
- *  +--------------------+---------------------+
- *
- * A context number of 0 is considered "invalid".
- *
- * The generation number is incremented whenever we end up having used
- * up all available region ids.  At that point with flush the entire
- * TLB and reuse the first region id.  The new generation number
- * ensures that when we context switch back to an old process, we do
- * not inadvertently end up using its possibly reused region id.
- * Instead, we simply allocate a new region id for that process.
- *
  * Copyright (C) 1998 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
@@ -56,9 +42,15 @@
=20
 #define IA64_HW_CONTEXT_MASK	((1UL << IA64_HW_CONTEXT_BITS) - 1)
=20
-extern unsigned long ia64_next_context;
+struct ia64_ctx {
+	spinlock_t lock;
+	unsigned int next;	/* next context number to use */
+	unsigned int limit;	/* next >=3D limit =3D> must call wrap_mmu_context() =
*/
+};
+
+extern struct ia64_ctx ia64_ctx;
=20
-extern void get_new_mmu_context (struct mm_struct *mm);
+extern void wrap_mmu_context (struct mm_struct *mm);
=20
 static inline void
 enter_lazy_tlb (struct mm_struct *mm, struct task_struct *tsk, unsigned cp=
u)
@@ -76,12 +68,24 @@
 }
=20
 extern inline void
+get_new_mmu_context (struct mm_struct *mm)
+{
+	spin_lock(&ia64_ctx.lock);
+	{
+		if (ia64_ctx.next >=3D ia64_ctx.limit)
+			wrap_mmu_context(mm);
+		mm->context =3D ia64_ctx.next++;
+	}
+	spin_unlock(&ia64_ctx.lock);
+
+}
+
+extern inline void
 get_mmu_context (struct mm_struct *mm)
 {
 	/* check if our ASN is of an older generation and thus invalid: */
-	if (((mm->context ^ ia64_next_context) & ~IA64_HW_CONTEXT_MASK) !=3D 0) {
+	if (mm->context =3D 0)
 		get_new_mmu_context(mm);
-	}
 }
=20
 extern inline void
@@ -103,7 +107,7 @@
 	unsigned long rid_incr =3D 0;
 	unsigned long rr0, rr1, rr2, rr3, rr4;
=20
-	rid =3D (mm->context & IA64_HW_CONTEXT_MASK);
+	rid =3D mm->context;
=20
 #ifndef CONFIG_IA64_TLB_CHECKS_REGION_NUMBER
 	rid <<=3D 3;	/* make space for encoding the region number */
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.0-test6-lia/inc=
lude/asm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Wed Aug  2 18:54:53 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/offsets.h	Fri Aug 11 15:53:25 20=
00
@@ -11,10 +11,10 @@
 #define PT_PTRACED_BIT			0
 #define PT_TRACESYS_BIT			1
=20
-#define IA64_TASK_SIZE			2768	/* 0xad0 */
+#define IA64_TASK_SIZE			2864	/* 0xb30 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
-#define IA64_SIGINFO_SIZE		136	/* 0x88 */
+#define IA64_SIGINFO_SIZE		128	/* 0x80 */
 #define UNW_FRAME_INFO_SIZE		448	/* 0x1c0 */
=20
 #define IA64_TASK_PTRACE_OFFSET		48	/* 0x30 */
@@ -23,7 +23,7 @@
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
 #define IA64_TASK_THREAD_OFFSET		896	/* 0x380 */
 #define IA64_TASK_THREAD_KSP_OFFSET	896	/* 0x380 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	2648	/* 0xa58 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	2744	/* 0xab8 */
 #define IA64_TASK_PID_OFFSET		188	/* 0xbc */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/page.h linux-2.4.0-test6-lia/includ=
e/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/page.h	Fri Aug 11 16:43:55 2000
@@ -100,13 +100,14 @@
 #define MAP_NR_SN1(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE_S=
HIFT)
=20
 #ifdef CONFIG_IA64_GENERIC
-# define virt_to_page(kaddr)	(mem_map + platform_map_nr(kaddr))
+# include <asm/machvec.h>
+# define virt_to_page(kaddr)   (mem_map + platform_map_nr(kaddr))
 #elif defined (CONFIG_IA64_SN_SN1_SIM)
-# define virt_to_page(kaddr)	(mem_map + MAP_NR_SN1(kaddr))
+# define virt_to_page(kaddr)   (mem_map + MAP_NR_SN1(kaddr))
 #else
-# define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
+# define virt_to_page(kaddr)   (mem_map + MAP_NR_DENSE(kaddr))
 #endif
-#define VALID_PAGE(page)	((page - mem_map) < max_mapnr)
+#define VALID_PAGE(page)       ((page - mem_map) < max_mapnr)
=20
 # endif /* __KERNEL__ */
=20
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.0-test6-lia/inc=
lude/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/pgtable.h	Fri Aug 11 16:43:56 20=
00
@@ -287,34 +287,29 @@
  * contains the memory attribute bits, dirty bits, and various other
  * bits as well.
  */
-#define pgprot_noncached(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_MASK=
) | _PAGE_MA_UC)
+#define pgprot_noncached(prot)		__pgprot((pgprot_val(prot) & ~_PAGE_MA_MAS=
K) | _PAGE_MA_UC)
=20
 /*
- * Return the region index for virtual address ADDRESS.
+ * Macro to make mark a page protection value as "write-combining".
+ * Note that "protection" is really a misnomer here as the protection
+ * value contains the memory attribute bits, dirty bits, and various
+ * other bits as well.  Accesses through a write-combining translation
+ * works bypasses the caches, but does allow for consecutive writes to
+ * be combined into single (but larger) write transactions.
  */
-extern __inline__ unsigned long
-rgn_index (unsigned long address)
-{
-	ia64_va a;
-
-	a.l =3D address;
-	return a.f.reg;
-}
+#define pgprot_writecombine(prot)	__pgprot((pgprot_val(prot) & ~_PAGE_MA_M=
ASK) | _PAGE_MA_WC)
=20
 /*
- * Return the region offset for virtual address ADDRESS.
+ * Return the region index for virtual address ADDRESS.
  */
 extern __inline__ unsigned long
-rgn_offset (unsigned long address)
+rgn_index (unsigned long address)
 {
 	ia64_va a;
=20
 	a.l =3D address;
-	return a.f.off;
+	return a.f.reg;
 }
-
-#define RGN_SIZE	(1UL << 61)
-#define RGN_KERNEL	7
=20
 /*
  * Return the region offset for virtual address ADDRESS.
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-test6-lia/i=
nclude/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/processor.h	Fri Aug 11 16:43:56 =
2000
@@ -19,6 +19,7 @@
 #include <asm/types.h>
=20
 #define IA64_NUM_DBG_REGS	8
+#define IA64_NUM_PM_REGS	4
=20
 /*
  * TASK_SIZE really is a mis-named.  It really is the maximum user
@@ -152,12 +153,13 @@
=20
 #define IA64_THREAD_FPH_VALID	(__IA64_UL(1) << 0)	/* floating-point high s=
tate valid? */
 #define IA64_THREAD_DBG_VALID	(__IA64_UL(1) << 1)	/* debug registers valid=
? */
-#define IA64_THREAD_UAC_NOPRINT	(__IA64_UL(1) << 2)	/* don't log unaligned=
 accesses */
-#define IA64_THREAD_UAC_SIGBUS	(__IA64_UL(1) << 3)	/* generate SIGBUS on u=
naligned acc. */
-#define IA64_THREAD_KRBS_SYNCED	(__IA64_UL(1) << 4)	/* krbs synced with pr=
ocess vm? */
+#define IA64_THREAD_PM_VALID	(__IA64_UL(1) << 2)	/* performance registers =
valid? */
+#define IA64_THREAD_UAC_NOPRINT	(__IA64_UL(1) << 3)	/* don't log unaligned=
 accesses */
+#define IA64_THREAD_UAC_SIGBUS	(__IA64_UL(1) << 4)	/* generate SIGBUS on u=
naligned acc. */
+#define IA64_THREAD_KRBS_SYNCED	(__IA64_UL(1) << 5)	/* krbs synced with pr=
ocess vm? */
 #define IA64_KERNEL_DEATH	(__IA64_UL(1) << 63)	/* see die_if_kernel()... */
=20
-#define IA64_THREAD_UAC_SHIFT	2=09
+#define IA64_THREAD_UAC_SHIFT	3
 #define IA64_THREAD_UAC_MASK	(IA64_THREAD_UAC_NOPRINT | IA64_THREAD_UAC_SI=
GBUS)
=20
 #ifndef __ASSEMBLY__
@@ -285,6 +287,14 @@
 	struct ia64_fpreg fph[96];	/* saved/loaded on demand */
 	__u64 dbr[IA64_NUM_DBG_REGS];
 	__u64 ibr[IA64_NUM_DBG_REGS];
+#ifdef CONFIG_PERFMON
+	__u64 pmc[IA64_NUM_PM_REGS];
+	__u64 pmd[IA64_NUM_PM_REGS];
+	__u64 pmod[IA64_NUM_PM_REGS];
+# define INIT_THREAD_PM		{0, }, {0, }, {0, },
+#else
+# define INIT_THREAD_PM
+#endif
 	__u64 map_base;			/* base address for mmap() */
 #ifdef CONFIG_IA32_SUPPORT
 	__u64 eflag;			/* IA32 EFLAGS reg */
@@ -316,6 +326,7 @@
 	{{{{0}}}, },			/* fph */	\
 	{0, },				/* dbr */	\
 	{0, },				/* ibr */	\
+	INIT_THREAD_PM					\
 	0x2000000000000000		/* map_base */	\
 	INIT_THREAD_IA32,				\
 	0				/* siginfo */	\
@@ -396,6 +407,18 @@
 extern void __ia64_init_fpu (void);
 extern void __ia64_save_fpu (struct ia64_fpreg *fph);
 extern void __ia64_load_fpu (struct ia64_fpreg *fph);
+extern void ia64_save_debug_regs (unsigned long *save_area);
+extern void ia64_load_debug_regs (unsigned long *save_area);
+
+#ifdef CONFIG_IA32_SUPPORT
+extern void ia32_save_state (struct thread_struct *thread);
+extern void ia32_load_state (struct thread_struct *thread);
+#endif
+
+#ifdef CONFIG_PERFMON
+extern void ia64_save_pm_regs (struct thread_struct *thread);
+extern void ia64_load_pm_regs (struct thread_struct *thread);
+#endif
=20
 #define ia64_fph_enable()	__asm__ __volatile__ (";; rsm psr.dfh;; srlz.d;;=
" ::: "memory");
 #define ia64_fph_disable()	__asm__ __volatile__ (";; ssm psr.dfh;; srlz.d;=
;" ::: "memory");
diff -urN linux-davidm/include/asm-ia64/siginfo.h linux-2.4.0-test6-lia/inc=
lude/asm-ia64/siginfo.h
--- linux-davidm/include/asm-ia64/siginfo.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/siginfo.h	Mon Jul 31 14:01:22 20=
00
@@ -14,12 +14,13 @@
 } sigval_t;
=20
 #define SI_MAX_SIZE	128
-#define SI_PAD_SIZE	((SI_MAX_SIZE/sizeof(int)) - 3)
+#define SI_PAD_SIZE	((SI_MAX_SIZE/sizeof(int)) - 4)
=20
 typedef struct siginfo {
 	int si_signo;
 	int si_errno;
 	int si_code;
+	int __pad0;
=20
 	union {
 		int _pad[SI_PAD_SIZE];
@@ -212,7 +213,7 @@
 #define SIGEV_THREAD	2	/* deliver via thread creation */
=20
 #define SIGEV_MAX_SIZE	64
-#define SIGEV_PAD_SIZE	((SIGEV_MAX_SIZE/sizeof(int)) - 3)
+#define SIGEV_PAD_SIZE	((SIGEV_MAX_SIZE/sizeof(int)) - 4)
=20
 typedef struct sigevent {
 	sigval_t sigev_value;
diff -urN linux-davidm/include/asm-ia64/spinlock.h linux-2.4.0-test6-lia/in=
clude/asm-ia64/spinlock.h
--- linux-davidm/include/asm-ia64/spinlock.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/spinlock.h	Fri Aug 11 16:43:56 2=
000
@@ -15,8 +15,11 @@
 #include <asm/bitops.h>
 #include <asm/atomic.h>
=20
+#undef NEW_LOCK
+
+#ifdef NEW_LOCK
 typedef struct {=20
-	volatile unsigned int lock;
+	volatile unsigned char lock;
 } spinlock_t;
=20
 #define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
@@ -26,44 +29,86 @@
  * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
  * rather than a simple xchg to avoid writing the cache-line when
  * there is contention.
+ *
+ * XXX Fix me: instead of preserving ar.pfs, we should just mark it
+ * XXX as "clobbered".  Unfortunately, the Mar 2000 release of the compiler
+ * XXX doesn't let us do that.  The August release fixes that.
  */
-#if 1 /* Bad code generation? */
-#define spin_lock(x) __asm__ __volatile__ ( \
-       "mov ar.ccv =3D r0\n" \
-       "mov r29 =3D 1\n" \
-       ";;\n" \
-       "1:\n" \
-       "ld4 r2 =3D %0\n" \
-       ";;\n" \
-       "cmp4.eq p0,p7 =3D r0,r2\n" \
-       "(p7) br.cond.spnt.few 1b \n" \
-       "cmpxchg4.acq r2 =3D %0, r29, ar.ccv\n" \
-       ";;\n" \
-       "cmp4.eq p0,p7 =3D r0, r2\n" \
-       "(p7) br.cond.spnt.few 1b\n" \
-       ";;\n" \
-       :: "m" __atomic_fool_gcc((x)) : "r2", "r29", "memory")
-=20
-#else=20
-#define spin_lock(x)					\
-{							\
-	spinlock_t *__x =3D (x);				\
-							\
-	do {						\
-		while (__x->lock);			\
-	} while (cmpxchg_acq(&__x->lock, 0, 1));	\
+#define spin_lock(x)								\
+{										\
+	register char *addr __asm__ ("r31") =3D (char *) &(x)->lock;		\
+	long saved_pfs;								\
+										\
+	__asm__ __volatile__ (							\
+		"mov r30=3D1\n"							\
+		"mov ar.ccv=3Dr0\n"						\
+		";;\n"								\
+		IA64_SEMFIX"cmpxchg1.acq r30=3D[%1],r30,ar.ccv\n"			\
+		";;\n"								\
+		"cmp.ne p15,p0=3Dr30,r0\n"					\
+		"mov %0=3Dar.pfs\n"						\
+		"(p15) br.call.spnt.few b7=3Dia64_spinlock_contention\n"		\
+		";;\n"								\
+		"1: (p15) mov ar.pfs=3D%0;;\n"	/* force a new bundle */	\
+		: "=3D&r"(saved_pfs) : "r"(addr)					\
+		: "p15", "r28", "r29", "r30", "memory");			\
 }
-#endif
+
+#define spin_trylock(x)							\
+({									\
+	register char *addr __asm__ ("r31") =3D (char *) &(x)->lock;	\
+	register long result;						\
+									\
+	__asm__ __volatile__ (						\
+		"mov r30=3D1\n"						\
+		"mov ar.ccv=3Dr0\n"					\
+		";;\n"							\
+		IA64_SEMFIX"cmpxchg1.acq %0=3D[%1],r30,ar.ccv\n"		\
+		: "=3Dr"(result) : "r"(addr) : "r30", "memory");		\
+	(result =3D 0);							\
+})
=20
 #define spin_is_locked(x)	((x)->lock !=3D 0)
+#define spin_unlock(x)		({((spinlock_t *) x)->lock =3D 0;})
+#define spin_unlock_wait(x)	({ while ((x)->lock); })
=20
-#define spin_unlock(x)		({((spinlock_t *) x)->lock =3D 0; barrier();})
+#else /* !NEW_LOCK */
=20
-/* Streamlined !test_and_set_bit(0, (x)) */
-#define spin_trylock(x)		(cmpxchg_acq(&(x)->lock, 0, 1) =3D 0)
+typedef struct {=20
+	volatile unsigned int lock;
+} spinlock_t;
+
+#define SPIN_LOCK_UNLOCKED			(spinlock_t) { 0 }
+#define spin_lock_init(x)			((x)->lock =3D 0)
=20
+/*
+ * Streamlined test_and_set_bit(0, (x)).  We use test-and-test-and-set
+ * rather than a simple xchg to avoid writing the cache-line when
+ * there is contention.
+ */
+#define spin_lock(x) __asm__ __volatile__ (			\
+	"mov ar.ccv =3D r0\n"					\
+	"mov r29 =3D 1\n"						\
+	";;\n"							\
+	"1:\n"							\
+	"ld4 r2 =3D %0\n"						\
+	";;\n"							\
+	"cmp4.eq p0,p7 =3D r0,r2\n"				\
+	"(p7) br.cond.spnt.few 1b \n"				\
+	IA64_SEMFIX"cmpxchg4.acq r2 =3D %0, r29, ar.ccv\n"	\
+	";;\n"							\
+	"cmp4.eq p0,p7 =3D r0, r2\n"				\
+	"(p7) br.cond.spnt.few 1b\n"				\
+	";;\n"							\
+	:: "m" __atomic_fool_gcc((x)) : "r2", "r29", "memory")
+
+#define spin_is_locked(x)	((x)->lock !=3D 0)
+#define spin_unlock(x)		({((spinlock_t *) x)->lock =3D 0; barrier();})
+#define spin_trylock(x)		(cmpxchg_acq(&(x)->lock, 0, 1) =3D 0)
 #define spin_unlock_wait(x)	({ do { barrier(); } while ((x)->lock); })
=20
+#endif /* !NEW_LOCK */
+
 typedef struct {
 	volatile int read_counter:31;
 	volatile int write_lock:1;
@@ -73,12 +118,12 @@
 #define read_lock(rw)							 \
 do {									 \
 	int tmp =3D 0;							 \
-	__asm__ __volatile__ ("1:\tfetchadd4.acq %0 =3D %1, 1\n"		 \
+	__asm__ __volatile__ ("1:\t"IA64_SEMFIX"fetchadd4.acq %0 =3D %1, 1\n"		 \
 			      ";;\n"					 \
 			      "tbit.nz p6,p0 =3D %0, 31\n"		 \
 			      "(p6) br.cond.sptk.few 2f\n"		 \
 			      ".section .text.lock,\"ax\"\n"		 \
-			      "2:\tfetchadd4.rel %0 =3D %1, -1\n"		 \
+			      "2:\t"IA64_SEMFIX"fetchadd4.rel %0 =3D %1, -1\n"		 \
 			      ";;\n"					 \
 			      "3:\tld4.acq %0 =3D %1\n"			 \
 			      ";;\n"					 \
@@ -94,7 +139,7 @@
 #define read_unlock(rw)						\
 do {								\
 	int tmp =3D 0;						\
-	__asm__ __volatile__ ("fetchadd4.rel %0 =3D %1, -1\n"	\
+	__asm__ __volatile__ (IA64_SEMFIX"fetchadd4.rel %0 =3D %1, -1\n"	\
 			      : "=3Dr" (tmp)			\
 			      : "m" (__atomic_fool_gcc(rw))	\
 			      : "memory");			\
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.0-test6-lia/incl=
ude/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/include/asm-ia64/system.h	Fri Aug 11 16:43:55 2000
@@ -27,6 +27,15 @@
=20
 #define GATE_ADDR		(0xa000000000000000 + PAGE_SIZE)
=20
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC)
+  /* Workaround for Errata 97.  */
+# define IA64_SEMFIX_INSN	mf;
+# define IA64_SEMFIX	"mf;"
+#else
+# define IA64_SEMFIX_INSN
+# define IA64_SEMFIX	""
+#endif
+
 #ifndef __ASSEMBLY__
=20
 #include <linux/types.h>
@@ -231,13 +240,13 @@
 ({										\
 	switch (sz) {								\
 	      case 4:								\
-		__asm__ __volatile__ ("fetchadd4.rel %0=3D%1,%3"			\
+		__asm__ __volatile__ (IA64_SEMFIX"fetchadd4.rel %0=3D%1,%3"	\
 				      : "=3Dr"(tmp), "=3Dm"(__atomic_fool_gcc(v))	\
 				      : "m" (__atomic_fool_gcc(v)), "i"(n));	\
 		break;								\
 										\
 	      case 8:								\
-		__asm__ __volatile__ ("fetchadd8.rel %0=3D%1,%3"			\
+		__asm__ __volatile__ (IA64_SEMFIX"fetchadd8.rel %0=3D%1,%3"	\
 				      : "=3Dr"(tmp), "=3Dm"(__atomic_fool_gcc(v))	\
 				      : "m" (__atomic_fool_gcc(v)), "i"(n));	\
 		break;								\
@@ -280,22 +289,22 @@
=20
 	switch (size) {
 	      case 1:
-		__asm__ __volatile ("xchg1 %0=3D%1,%2" : "=3Dr" (result)
+		__asm__ __volatile (IA64_SEMFIX"xchg1 %0=3D%1,%2" : "=3Dr" (result)
 				    : "m" (*(char *) ptr), "r" (x) : "memory");
 		return result;
=20
 	      case 2:
-		__asm__ __volatile ("xchg2 %0=3D%1,%2" : "=3Dr" (result)
+		__asm__ __volatile (IA64_SEMFIX"xchg2 %0=3D%1,%2" : "=3Dr" (result)
 				    : "m" (*(short *) ptr), "r" (x) : "memory");
 		return result;
=20
 	      case 4:
-		__asm__ __volatile ("xchg4 %0=3D%1,%2" : "=3Dr" (result)
+		__asm__ __volatile (IA64_SEMFIX"xchg4 %0=3D%1,%2" : "=3Dr" (result)
 				    : "m" (*(int *) ptr), "r" (x) : "memory");
 		return result;
=20
 	      case 8:
-		__asm__ __volatile ("xchg8 %0=3D%1,%2" : "=3Dr" (result)
+		__asm__ __volatile (IA64_SEMFIX"xchg8 %0=3D%1,%2" : "=3Dr" (result)
 				    : "m" (*(long *) ptr), "r" (x) : "memory");
 		return result;
 	}
@@ -305,7 +314,6 @@
=20
 #define xchg(ptr,x)							     \
   ((__typeof__(*(ptr))) __xchg ((unsigned long) (x), (ptr), sizeof(*(ptr))=
))
-#define tas(ptr)	(xchg ((ptr), 1))
=20
 /*=20
  * Atomic compare and exchange.  Compare OLD with MEM, if identical,
@@ -324,50 +332,50 @@
 struct __xchg_dummy { unsigned long a[100]; };
 #define __xg(x) (*(struct __xchg_dummy *)(x))
=20
-#define ia64_cmpxchg(sem,ptr,old,new,size)				\
-({									\
-	__typeof__(ptr) _p_ =3D (ptr);					\
-	__typeof__(new) _n_ =3D (new);					\
-	__u64 _o_, _r_;							\
-									\
-	switch (size) {							\
-	      case 1: _o_ =3D (__u8 ) (old); break;			\
-	      case 2: _o_ =3D (__u16) (old); break;			\
-	      case 4: _o_ =3D (__u32) (old); break;			\
-	      case 8: _o_ =3D (__u64) (old); break;			\
-	      default:							\
-	}								\
-	 __asm__ __volatile__ ("mov ar.ccv=3D%0;;" :: "rO"(_o_));		\
-	switch (size) {							\
-	      case 1:							\
-		__asm__ __volatile__ ("cmpxchg1."sem" %0=3D%2,%3,ar.ccv"	\
-				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))	\
-				      : "m"(__xg(_p_)), "r"(_n_));	\
-		break;							\
-									\
-	      case 2:							\
-		__asm__ __volatile__ ("cmpxchg2."sem" %0=3D%2,%3,ar.ccv"	\
-				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))	\
-				      : "m"(__xg(_p_)), "r"(_n_));	\
-		break;							\
-									\
-	      case 4:							\
-		__asm__ __volatile__ ("cmpxchg4."sem" %0=3D%2,%3,ar.ccv"	\
-				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))	\
-				      : "m"(__xg(_p_)), "r"(_n_));	\
-		break;							\
-									\
-	      case 8:							\
-		__asm__ __volatile__ ("cmpxchg8."sem" %0=3D%2,%3,ar.ccv"	\
-				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))	\
-				      : "m"(__xg(_p_)), "r"(_n_));	\
-		break;							\
-									\
-	      default:							\
-		_r_ =3D __cmpxchg_called_with_bad_pointer();		\
-		break;							\
-	}								\
-	(__typeof__(old)) _r_;						\
+#define ia64_cmpxchg(sem,ptr,old,new,size)						\
+({											\
+	__typeof__(ptr) _p_ =3D (ptr);							\
+	__typeof__(new) _n_ =3D (new);							\
+	__u64 _o_, _r_;									\
+											\
+	switch (size) {									\
+	      case 1: _o_ =3D (__u8 ) (long) (old); break;				\
+	      case 2: _o_ =3D (__u16) (long) (old); break;				\
+	      case 4: _o_ =3D (__u32) (long) (old); break;				\
+	      case 8: _o_ =3D (__u64) (long) (old); break;				\
+	      default:									\
+	}										\
+	 __asm__ __volatile__ ("mov ar.ccv=3D%0;;" :: "rO"(_o_));				\
+	switch (size) {									\
+	      case 1:									\
+		__asm__ __volatile__ (IA64_SEMFIX"cmpxchg1."sem" %0=3D%2,%3,ar.ccv"	\
+				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))			\
+				      : "m"(__xg(_p_)), "r"(_n_));			\
+		break;									\
+											\
+	      case 2:									\
+		__asm__ __volatile__ (IA64_SEMFIX"cmpxchg2."sem" %0=3D%2,%3,ar.ccv"	\
+				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))			\
+				      : "m"(__xg(_p_)), "r"(_n_));			\
+		break;									\
+											\
+	      case 4:									\
+		__asm__ __volatile__ (IA64_SEMFIX"cmpxchg4."sem" %0=3D%2,%3,ar.ccv"	\
+				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))			\
+				      : "m"(__xg(_p_)), "r"(_n_));			\
+		break;									\
+											\
+	      case 8:									\
+		__asm__ __volatile__ (IA64_SEMFIX"cmpxchg8."sem" %0=3D%2,%3,ar.ccv"	\
+				      : "=3Dr"(_r_), "=3Dm"(__xg(_p_))			\
+				      : "m"(__xg(_p_)), "r"(_n_));			\
+		break;									\
+											\
+	      default:									\
+		_r_ =3D __cmpxchg_called_with_bad_pointer();				\
+		break;									\
+	}										\
+	(__typeof__(old)) _r_;								\
 })
=20
 #define cmpxchg_acq(ptr,o,n)	ia64_cmpxchg("acq", (ptr), (o), (n), sizeof(*=
(ptr)))
@@ -418,15 +426,15 @@
 extern void ia64_save_extra (struct task_struct *task);
 extern void ia64_load_extra (struct task_struct *task);
=20
-#define __switch_to(prev,next,last) do {					\
-	if (((prev)->thread.flags & IA64_THREAD_DBG_VALID)			\
-	    || IS_IA32_PROCESS(ia64_task_regs(prev)))				\
-		ia64_save_extra(prev);						\
-	if (((next)->thread.flags & IA64_THREAD_DBG_VALID)			\
-	    || IS_IA32_PROCESS(ia64_task_regs(next)))				\
-		ia64_load_extra(next);						\
-	ia64_psr(ia64_task_regs(next))->dfh =3D (ia64_get_fpu_owner() !=3D (next)=
);	\
-	(last) =3D ia64_switch_to((next));					\
+#define __switch_to(prev,next,last) do {						\
+	if (((prev)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID))=
	\
+	    || IS_IA32_PROCESS(ia64_task_regs(prev)))					\
+		ia64_save_extra(prev);							\
+	if (((next)->thread.flags & (IA64_THREAD_DBG_VALID|IA64_THREAD_PM_VALID))=
	\
+	    || IS_IA32_PROCESS(ia64_task_regs(next)))					\
+		ia64_load_extra(next);							\
+	ia64_psr(ia64_task_regs(next))->dfh =3D (ia64_get_fpu_owner() !=3D (next)=
);		\
+	(last) =3D ia64_switch_to((next));						\
 } while (0)
=20
 #ifdef CONFIG_SMP=20
diff -urN linux-davidm/init/main.c linux-2.4.0-test6-lia/init/main.c
--- linux-davidm/init/main.c	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/init/main.c	Fri Aug 11 14:55:42 2000
@@ -584,6 +584,7 @@
 #endif
 	check_bugs();
 	printk("POSIX conformance testing by UNIFIX\n");
+
 	/*=20
 	 *	We count on the initial thread going ok=20
 	 *	Like idlers init is an unlocked kernel thread, which will
diff -urN linux-davidm/kernel/timer.c linux-2.4.0-test6-lia/kernel/timer.c
--- linux-davidm/kernel/timer.c	Fri Aug 11 19:01:16 2000
+++ linux-2.4.0-test6-lia/kernel/timer.c	Mon Jul 31 14:01:22 2000
@@ -680,7 +680,7 @@
=20
 void do_timer(struct pt_regs *regs)
 {
-	(*(unsigned long *)&jiffies)++;
+	(*(volatile unsigned long *)&jiffies)++;
 #ifndef CONFIG_SMP
 	/* SMP process accounting uses the local APIC timer */
=20

