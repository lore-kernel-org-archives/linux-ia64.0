From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 26 Jan 2001 04:53:44 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.0)
Message-Id: <marc-linux-ia64-105590693005104@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The latest IA-64 patch is now available at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file linux-2.4.0-ia64-010125.diff*

What changed since last time:

 o Alex Williamson: Fix "implemented VA bits" calculation so it
	doesn't fail when all virtual address bits are implemented.
 o Erich Focht/YT: Fix llseek() in /proc/mem to make it work when
   offset >=3D2^63.
 o William Taber/YT: fix mm/memory.c so handle_mm_fault() gets called
   with the right arguments.
 o BJ Nima: Update qla1280 driver to version 3.23 beta.
 o Keith Owens: Fix unw_access_gr() so it accesses stacked regs correctly.
 o Don Dugger: Fix munmap, mprotect, & msync to do the right thing
	when 4KB pages are in use.  Various other IA-32 fixes.
 o Asit Mallick:
    + Fix TLB handlers (this was fix was posted to the list earlier on).
    + Add missing restore of ar.lc in copy_user()
 o YT:
    + Make IA-64 timer data structure (itm) part of CPU-local data
    + "Randomize" the timer tick on different CPUs so it's less likely
      for multiple CPUs to hit the timer interrupt simultaneous (shouldn't
      really make much of a difference on today's machines, but it seemed
      like the right thing to do and was easy to add)
    + Make unaligned handler work inside the kernel and fix
      a nasty bug that would let a user program crash the system.
    + Turn on "alignment check" (psr.ac) inside the kernel so we can
      reliably detect unaligned accesses
    + Clean up syscall path and improve code scheduling.
    + Make MAX_DMA_ADDRESS a variable so platform-specific code can
      override the default value
    + Various IA-32 subsystem cleanups
	- added ia32_execve() to get the right register frame when
	  execv'ing an IA-64 program
	- drop IA-32 syscall register frame in the IA-32 specific
	  code, so we don't have to check and slow down the normal
	  kernel exit path
	- added sys32_signal since Intel's cross compiler wants it

Below is a diff that shows the changes since the last IA-64 patch.  As
usual, this is for your enjoyment only.  If you want to get the real
sources, start with 2.4.0 and apply the above patch on top of it.

This patch has been tested on BigSur, Lion, and the HP Ski simulator
and found to be generally good to public health.  As always, if you
should encounter some unexpected problems, please let us all know.

Enjoy,

	--david

diff -urN linux-davidm/Documentation/Configure.help linux-2.4.0-lia/Documen=
tation/Configure.help
--- linux-davidm/Documentation/Configure.help	Thu Jan 25 19:17:24 2001
+++ linux-2.4.0-lia/Documentation/Configure.help	Thu Jan 25 15:00:58 2001
@@ -17030,11 +17030,6 @@
   Say Y here to enable hacks to make the kernel work on the Intel
   SoftSDV simulator.  Select N here if you're unsure.
=20
-Enable AzusA hacks
-CONFIG_IA64_AZUSA_HACKS
-  Say Y here to enable hacks to make the kernel work on the NEC
-  AzusA platform.  Select N here if you're unsure.
-
 Force socket buffers below 4GB?
 CONFIG_SKB_BELOW_4GB
   Most of today's network interface cards (NICs) support DMA to
diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-lia/arch/ia64/config=
.in
--- linux-davidm/arch/ia64/config.in	Thu Jan 25 19:17:24 2001
+++ linux-2.4.0-lia/arch/ia64/config.in	Thu Jan 25 18:44:45 2001
@@ -54,7 +54,6 @@
 	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
 	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
-	bool '  Enable AzusA hacks' CONFIG_IA64_AZUSA_HACKS
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 	bool '  Enable ACPI 2.0 with errata 1.3' CONFIG_ACPI20
 	bool '  ACPI kernel configuration manager (EXPERIMENTAL)' CONFIG_ACPI_KER=
NEL_CONFIG
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c linux-2.4.0-lia/arch/i=
a64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Thu Jan 25 19:17:24 2001
+++ linux-2.4.0-lia/arch/ia64/ia32/binfmt_elf32.c	Thu Jan 25 15:06:16 2001
@@ -93,8 +93,8 @@
 =09
 	/* Do all the IA-32 setup here */
=20
-	current->thread.map_base  =3D  0x40000000;
-	current->thread.task_size =3D  0xc0000000;	/* use what Linux/x86 uses... =
*/
+	current->thread.map_base  =3D 0x40000000;
+	current->thread.task_size =3D 0xc0000000;		/* use what Linux/x86 uses... =
*/
 	set_fs(USER_DS);				/* set addr limit for new TASK_SIZE */
 =20
 	/* setup ia32 state for ia32_load_state */
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.0-lia/arch/ia6=
4/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/ia32/ia32_entry.S	Thu Jan 25 15:06:29 2001
@@ -4,11 +4,36 @@
=20
 #include "../kernel/entry.h"
=20
+	.text
+
+	/*
+	 * execve() is special because in case of success, we need to
+	 * setup a null register window frame (in case an IA-32 process
+	 * is exec'ing an IA-64 program).
+	 */
+ENTRY(ia32_execve)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(3))
+	alloc loc1=3Dar.pfs,3,2,4,0
+	mov loc0=3Drp
+	UNW(.body)
+	mov out0=3Din0			// filename
+	;;				// stop bit between alloc and call
+	mov out1=3Din1			// argv
+	mov out2=3Din2			// envp
+	add out3=16,sp			// regs
+	br.call.sptk.few rp=3Dsys32_execve
+1:	cmp4.ge p6,p0=3Dr8,r0
+	mov ar.pfs=3Dloc1			// restore ar.pfs
+	;;
+(p6)	mov ar.pfs=3Dr0			// clear ar.pfs in case of success
+	sxt4 r8=3Dr8			// return 64-bit result
+	mov rp=3Dloc0
+	br.ret.sptk.few rp
+END(ia32_execve)
+
 	//
 	// Get possibly unaligned sigmask argument into an aligned
 	//   kernel buffer
-	.text
-
 GLOBAL_ENTRY(ia32_rt_sigsuspend)
 	// We'll cheat and not do an alloc here since we are ultimately
 	// going to do a simple branch to the IA64 sys_rt_sigsuspend.
@@ -46,8 +71,9 @@
 	cmp.ge p6,p7=3Dr8,r0                      // syscall executed successfull=
y?
 	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp    // r2 =3D &pt_regs.r8
 	;;=20
+	alloc r3=3Dar.pfs,0,0,0,0			// drop the syscall argument frame
 	st8 [r2]=3Dr8                             // store return value in slot f=
or r8
-	br.cond.sptk.few ia64_leave_kernel
+	br.cond.sptk.many ia64_leave_kernel
 END(ia32_ret_from_syscall)
=20
 	//
@@ -69,7 +95,8 @@
 	;;
 	st8.spill [r2]=3Dr8			// store return value in slot for r8
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch return value
-.ret2:	br.cond.sptk.many ia64_leave_kernel	// rp MUST be !=3D ia64_leave_k=
ernel!
+.ret2:	alloc r2=3Dar.pfs,0,0,0,0			// drop the syscall argument frame
+	br.cond.sptk.many ia64_leave_kernel	// rp MUST be !=3D ia64_leave_kernel!
 END(ia32_trace_syscall)
=20
 GLOBAL_ENTRY(sys32_vfork)
@@ -116,7 +143,7 @@
 	data8 sys_creat
 	data8 sys_link
 	data8 sys_unlink	  /* 10 */
-	data8 sys32_execve
+	data8 ia32_execve
 	data8 sys_chdir
 	data8 sys32_time
 	data8 sys_mknod
@@ -153,7 +180,7 @@
 	data8 sys_brk		  /* 45 */
 	data8 sys_setgid
 	data8 sys_getgid
-	data8 sys32_ni_syscall
+	data8 sys32_signal
 	data8 sys_geteuid
 	data8 sys_getegid	  /* 50 */
 	data8 sys_acct
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.0-lia/arch/ia64/=
ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Thu Jan 25 19:17:24 2001
+++ linux-2.4.0-lia/arch/ia64/ia32/sys_ia32.c	Thu Jan 25 17:17:36 2001
@@ -64,7 +64,6 @@
 #define NAME_OFFSET(de) ((int) ((de)->d_name - (char *) (de)))
=20
 extern asmlinkage long sys_execve (char *, char **, char **, struct pt_reg=
s *);
-extern asmlinkage long sys_munmap (unsigned long, size_t len);
 extern asmlinkage long sys_mprotect (unsigned long, size_t, unsigned long);
=20
 static int
@@ -134,10 +133,10 @@
 		/* oops, execve failed, switch back to old map base & task-size: */
 		current->thread.map_base  =3D old_map_base;
 		current->thread.task_size =3D old_task_size;
+		set_fs(USER_DS);	/* establish new task-size as the address-limit */
 	  out:
 		kfree(av);
 	}
-	set_fs(USER_DS);	/* establish new task-size as the address-limit */
 	return r;
 }
=20
@@ -213,7 +212,6 @@
 	return ret;
 }
=20
-#define ALIGN4K(a)	(((a) + 0xfff) & ~0xfff)
 #define OFFSET4K(a)	((a) & 0xfff)
=20
 unsigned long
@@ -320,18 +318,46 @@
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
=20
+	if (PAGE_ALIGN(a.len) =3D 0)
+		return a.addr;
+
 	if (!(a.flags & MAP_ANONYMOUS)) {
 		file =3D fget(a.fd);
 		if (!file)
 			return -EBADF;
 	}
+#ifdef	CONFIG_IA64_PAGE_SIZE_4KB
+	if ((a.offset & ~PAGE_MASK) !=3D 0)
+		return -EINVAL;
+
+	down(&current->mm->mmap_sem);
+	retval =3D do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, a.offset >=
> PAGE_SHIFT);
+	up(&current->mm->mmap_sem);
+#else	// CONFIG_IA64_PAGE_SIZE_4KB
 	retval =3D ia32_do_mmap(file, a.addr, a.len, a.prot, a.flags, a.fd, a.off=
set);
+#endif	// CONFIG_IA64_PAGE_SIZE_4KB
 	if (file)
 		fput(file);
 	return retval;
 }
=20
 asmlinkage long
+sys32_mprotect(unsigned long start, size_t len, unsigned long prot)
+{
+
+#ifdef	CONFIG_IA64_PAGE_SIZE_4KB
+	return(sys_mprotect(start, len, prot));
+#else	// CONFIG_IA64_PAGE_SIZE_4KB
+	if (prot =3D 0)
+		return(0);
+	len +=3D start & ~PAGE_MASK;
+	if ((start & ~PAGE_MASK) && (prot & PROT_WRITE))
+		prot |=3D PROT_EXEC;
+	return(sys_mprotect(start & PAGE_MASK, len & PAGE_MASK, prot));
+#endif	// CONFIG_IA64_PAGE_SIZE_4KB
+}
+
+asmlinkage long
 sys32_pipe(int *fd)
 {
 	int retval;
@@ -347,15 +373,17 @@
 }
=20
 asmlinkage long
-sys32_mprotect(unsigned long start, size_t len, unsigned long prot)
+sys32_signal (int sig, unsigned int handler)
 {
+	struct k_sigaction new_sa, old_sa;
+	int ret;
=20
-	if (prot =3D 0)
-		return(0);
-	len +=3D start & ~PAGE_MASK;
-	if ((start & ~PAGE_MASK) && (prot & PROT_WRITE))
-		prot |=3D PROT_EXEC;
-	return(sys_mprotect(start & PAGE_MASK, len & PAGE_MASK, prot));
+	new_sa.sa.sa_handler =3D (__sighandler_t) A(handler);
+	new_sa.sa.sa_flags =3D SA_ONESHOT | SA_NOMASK;
+
+	ret =3D do_sigaction(sig, &new_sa, &old_sa);
+
+	return ret ? ret : (unsigned long)old_sa.sa.sa_handler;
 }
=20
 asmlinkage long
@@ -526,7 +554,6 @@
 	return (!access_ok(VERIFY_READ, i, sizeof(*i)) ||
 		(__get_user(o->tv_sec, &i->tv_sec) |
 		 __get_user(o->tv_usec, &i->tv_usec)));
-	return ENOSYS;
 }
=20
 static inline long
@@ -545,18 +572,16 @@
 		 __get_user(o->it_interval.tv_usec, &i->it_interval.tv_usec) |
 		 __get_user(o->it_value.tv_sec, &i->it_value.tv_sec) |
 		 __get_user(o->it_value.tv_usec, &i->it_value.tv_usec)));
-	return ENOSYS;
 }
=20
 static inline long
 put_it32(struct itimerval32 *o, struct itimerval *i)
 {
-	return (!access_ok(VERIFY_WRITE, i, sizeof(*i)) ||
+	return (!access_ok(VERIFY_WRITE, o, sizeof(*o)) ||
 		(__put_user(i->it_interval.tv_sec, &o->it_interval.tv_sec) |
 		 __put_user(i->it_interval.tv_usec, &o->it_interval.tv_usec) |
 		 __put_user(i->it_value.tv_sec, &o->it_value.tv_sec) |
 		 __put_user(i->it_value.tv_usec, &o->it_value.tv_usec)));
-	return ENOSYS;
 }
=20
 extern int do_getitimer(int which, struct itimerval *value);
@@ -2644,6 +2669,8 @@
 	}
 	return(ret);
 }
+
+asmlinkage long sys_msync(unsigned long start, size_t len, int flags);
=20
 asmlinkage int
 sys_pause (void)
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-lia/arch/ia64/k=
ernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Thu Jan 25 19:17:25 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/entry.S	Thu Jan 25 15:08:06 2001
@@ -40,7 +40,7 @@
 #include <asm/asmmacro.h>
 #include <asm/pgtable.h>
 =09
-#include "entry.h"
+#include "minstate.h"
=20
 	.text
 	.psr abi64
@@ -147,7 +147,7 @@
 	mov r13=3Din0			// set "current" pointer
 	;;
 (p6)	ssm psr.i			// renable psr.i AFTER the ic bit is serialized
-	DO_LOAD_SWITCH_STACK( )
+	DO_LOAD_SWITCH_STACK
=20
 #ifdef CONFIG_SMP
 	sync.i				// ensure "fc"s done by this CPU are visible on other CPUs
@@ -492,22 +492,6 @@
 	br.cond.sptk.few strace_save_retval
 END(ia64_trace_syscall)
=20
-/*
- * A couple of convenience macros to help implement/understand the state
- * restoration that happens at the end of ia64_ret_from_syscall.
- */
-#define rARPR		r31
-#define rCRIFS		r30
-#define rCRIPSR		r29
-#define rCRIIP		r28
-#define rARRSC		r27
-#define rARPFS		r26
-#define rARUNAT		r25
-#define rARRNAT		r24
-#define rARBSPSTORE	r23
-#define rKRBS		r22
-#define rB6		r21
-
 GLOBAL_ENTRY(ia64_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
 #ifdef CONFIG_SMP
@@ -554,10 +538,11 @@
 	;;
 	add r3=3Dr2,r3
 #else
+	adds r16=3DIA64_PT_REGS_R8_OFFSET+16,r12
 	movl r3=3Dirq_stat		// softirq_active
 #endif
 	;;
-	ld8 r2=3D[r3]		// r3 (softirq_active+softirq_mask) is guaranteed to be 8-=
byte aligned!
+	ld8 r2=3D[r3]	// r3 (softirq_active+softirq_mask) is guaranteed to be 8-b=
yte aligned!
 	;;
 	shr r3=3Dr2,32
 	;;
@@ -692,12 +677,13 @@
 	;;
 	ld8 rCRIFS=3D[r16],16	// load cr.ifs
 	ld8 rARUNAT=3D[r17],16	// load ar.unat
+	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
 	;;
 	ld8 rARPFS=3D[r16],16	// load ar.pfs
 	ld8 rARRSC=3D[r17],16	// load ar.rsc
 	;;
 	ld8 rARRNAT=3D[r16],16	// load ar.rnat (may be garbage)
-	ld8 rARBSPSTORE=3D[r17],16	// load ar.bspstore (may be garbage)
+	ld8 rARBSPSTORE=3D[r17],16 // load ar.bspstore (may be garbage)
 	;;
 	ld8 rARPR=3D[r16],16	// load predicates
 	ld8 rB6=3D[r17],16	// load b6
@@ -707,15 +693,17 @@
 	;;
 	ld8.fill r2=3D[r16],16
 	ld8.fill r3=3D[r17],16
+	extr.u r19=3DrCRIPSR,32,2	// extract ps.cpl
 	;;
 	ld8.fill r12=3D[r16],16
 	ld8.fill r13=3D[r17],16
-	extr.u r19=3DrCRIPSR,32,2	// extract ps.cpl
+(pSys)	shr.u r18=3Dr18,16	// get size of existing "dirty" partition
 	;;
-	ld8.fill r14=3D[r16],16
-	ld8.fill r15=3D[r17],16
+	ld8.fill r14=3D[r16]
+	ld8.fill r15=3D[r17]
 	cmp.eq p6,p7=3Dr0,r19	// are we returning to kernel mode? (psr.cpl=3D0)
 	;;
+	mov r16=3Dar.bsp			// get existing backing store pointer
 	mov b6=3DrB6
 	mov ar.pfs=3DrARPFS
 (p6)	br.cond.dpnt.few skip_rbs_switch
@@ -724,47 +712,34 @@
 	 * Restore user backing store.
 	 *
 	 * NOTE: alloc, loadrs, and cover can't be predicated.
-	 *
-	 * XXX This needs some scheduling/tuning once we believe it
-	 *     really does work as intended.
 	 */
-	mov r16=3Dar.bsp			// get existing backing store pointer
 (pNonSys) br.cond.dpnt.few dont_preserve_current_frame
 	cover				// add current frame into dirty partition
 	;;
-	mov rCRIFS=3Dcr.ifs		// fetch the cr.ifs value that "cover" produced
 	mov r17=3Dar.bsp			// get new backing store pointer
+	sub r18=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
+	cmp.ne p9,p0=3Dr0,r0		// clear p9 to skip restore of cr.ifs
 	;;
-	sub r16=3Dr17,r16			// calculate number of bytes that were added to rbs
-	;;
-	shl r16=3Dr16,16			// shift additional frame size into position for loadrs
+	sub r18=3Dr17,r18			// calculate number of bytes that were added to rbs
 	;;
-	add r18=3Dr16,r18			// adjust the loadrs value
+	shl r18=3Dr18,16			// shift size of dirty partition into loadrs position
 	;;
 dont_preserve_current_frame:
-	alloc r16=3Dar.pfs,0,0,0,0	// drop the current call frame (noop for sysca=
lls)
-	;;
+	alloc r17=3Dar.pfs,0,0,0,0	// drop the current call frame (noop for sysca=
lls)
 	mov ar.rsc=3Dr18			// load ar.rsc to be used for "loadrs"
-#ifdef CONFIG_IA32_SUPPORT
-	tbit.nz p6,p0=3DrCRIPSR,IA64_PSR_IS_BIT
-	;;
-(p6)	mov ar.rsc=3Dr0                   // returning to IA32 mode
-#endif
  	;;
 	loadrs
 	;;
-	mov ar.bspstore=3DrARBSPSTORE
-	;;
-	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
-
 skip_rbs_switch:
+(p7)	mov ar.bspstore=3DrARBSPSTORE
+(p9)	mov cr.ifs=3DrCRIFS
+	mov cr.ipsr=3DrCRIPSR
+	mov cr.iip=3DrCRIIP
+	;;
+(p7)	mov ar.rnat=3DrARRNAT	// must happen with RSE in lazy mode
 	mov ar.rsc=3DrARRSC
 	mov ar.unat=3DrARUNAT
-	mov cr.ifs=3DrCRIFS	// restore cr.ifs only if not a (synchronous) syscall
 	mov pr=3DrARPR,-1
-	mov cr.iip=3DrCRIIP
-	mov cr.ipsr=3DrCRIPSR
-	;;
 	rfi;;			// must be last instruction in an insn group
 END(ia64_leave_kernel)
=20
@@ -904,7 +879,7 @@
 (pNonSys) mov out2=3D0				// out2=3D0 =3D> not a syscall
 	br.call.sptk.few rp=3Dia64_do_signal
 .ret16:	// restore the switch stack (ptrace may have modified it)
-	DO_LOAD_SWITCH_STACK( )
+	DO_LOAD_SWITCH_STACK
 	br.ret.sptk.many rp
 #endif /* !CONFIG_IA64_NEW_UNWIND */
 END(handle_signal_delivery)
@@ -944,7 +919,7 @@
 	adds out2=16,sp				// out1=3D&sigscratch
 	br.call.sptk.many rp=3Dia64_rt_sigsuspend
 .ret18:	// restore the switch stack (ptrace may have modified it)
-	DO_LOAD_SWITCH_STACK( )
+	DO_LOAD_SWITCH_STACK
 	br.ret.sptk.many rp
 #endif /* !CONFIG_IA64_NEW_UNWIND */
 END(sys_rt_sigsuspend)
@@ -957,7 +932,7 @@
 	PT_REGS_SAVES(16)
 	adds sp=3D-16,sp
 	.body
-	cmp.eq pNonSys,p0=3Dr0,r0			// sigreturn isn't a normal syscall...
+	cmp.eq pNonSys,pSys=3Dr0,r0		// sigreturn isn't a normal syscall...
 	;;
 	adds out0=16,sp				// out0 =3D &sigscratch
 	br.call.sptk.few rp=3Dia64_rt_sigreturn
@@ -979,7 +954,7 @@
 	UNW(.spillsp ar.unat, PT(AR_UNAT)+IA64_SWITCH_STACK_SIZE)
 	UNW(.spillsp pr, PT(PR)+IA64_SWITCH_STACK_SIZE)
 	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp
-	cmp.eq pNonSys,p0=3Dr0,r0			// sigreturn isn't a normal syscall...
+	cmp.eq pNonSys,pSys=3Dr0,r0		// sigreturn isn't a normal syscall...
 	;;
 	UNW(.body)
=20
@@ -1002,13 +977,12 @@
 	// r16 =3D fake ar.pfs, we simply need to make sure=20
 	// privilege is still 0
 	//
-	PT_REGS_UNWIND_INFO(0)
 	mov r16=3Dr0 			=09
 	UNW(.prologue)
 	DO_SAVE_SWITCH_STACK
 	br.call.sptk.few rp=3Dia64_handle_unaligned // stack frame setup in ivt
 .ret21:	.body
-	DO_LOAD_SWITCH_STACK(PT_REGS_UNWIND_INFO(0))
+	DO_LOAD_SWITCH_STACK
 	br.cond.sptk.many rp			  // goes to ia64_leave_kernel
 END(ia64_prepare_handle_unaligned)
=20
diff -urN linux-davidm/arch/ia64/kernel/entry.h linux-2.4.0-lia/arch/ia64/k=
ernel/entry.h
--- linux-davidm/arch/ia64/kernel/entry.h	Thu Jun 22 07:09:44 2000
+++ linux-2.4.0-lia/arch/ia64/kernel/entry.h	Thu Jan 25 15:08:35 2001
@@ -55,11 +55,10 @@
 	br.cond.sptk.many save_switch_stack;	\
 1:
=20
-#define DO_LOAD_SWITCH_STACK(extra)		\
+#define DO_LOAD_SWITCH_STACK			\
 	movl r28=1F;				\
 	;;					\
 	mov b7=3Dr28;				\
 	br.cond.sptk.many load_switch_stack;	\
 1:	UNW(.restore sp);			\
-	extra;					\
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp
diff -urN linux-davidm/arch/ia64/kernel/iosapic.c linux-2.4.0-lia/arch/ia64=
/kernel/iosapic.c
--- linux-davidm/arch/ia64/kernel/iosapic.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/iosapic.c	Thu Jan 25 15:40:04 2001
@@ -137,12 +137,6 @@
 		 (dmode << IOSAPIC_DELIVERY_SHIFT) |
 		 vector);
=20
-#ifdef CONFIG_IA64_AZUSA_HACKS
-	/* set Flush Disable bit */
-	if (addr !=3D (char *) 0xc0000000fec00000)
-		low32 |=3D (1 << 17);
-#endif
-
 	/* dest contains both id and eid */
 	high32 =3D (dest << IOSAPIC_DEST_SHIFT);=09
=20
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-lia/arch/ia64/ker=
nel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Thu Jan 25 19:17:25 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/ivt.S	Thu Jan 25 15:41:48 2001
@@ -45,6 +45,12 @@
 #include <asm/system.h>
 #include <asm/unistd.h>
=20
+#if 1
+# define PSR_DEFAULT_BITS	psr.ac
+#else
+# define PSR_DEFAULT_BITS	0
+#endif
+
 #define MINSTATE_VIRT	/* needed by minstate.h */
 #include "minstate.h"
=20
@@ -184,15 +190,16 @@
 	 * mode, walk the page table, and then re-execute the L3 PTE read
 	 * and go on normally after that.
 	 */
-itlb_fault:
 	mov r16=3Dcr.ifa				// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
+itlb_fault:
 	mov r17=3Dcr.iha				// get virtual address of L3 PTE
 	movl r30=1F				// load nested fault continuation point
 	;;
 1:	ld8 r18=3D[r17]				// read L3 PTE
 	;;
+	mov b0=3Dr29
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.cond.spnt.many page_fault
 	;;
@@ -219,15 +226,16 @@
 	 * mode, walk the page table, and then re-execute the L3 PTE read
 	 * and go on normally after that.
 	 */
-dtlb_fault:
 	mov r16=3Dcr.ifa				// get virtual address
 	mov r29=B0				// save b0
 	mov r31=3Dpr				// save predicates
+dtlb_fault:
 	mov r17=3Dcr.iha				// get virtual address of L3 PTE
 	movl r30=1F				// load nested fault continuation point
 	;;
 1:	ld8 r18=3D[r17]				// read L3 PTE
 	;;
+	mov b0=3Dr29
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?
 (p6)	br.cond.spnt.many page_fault
 	;;
@@ -261,6 +269,7 @@
 (p8)	thash r17=3Dr16
 	;;
 (p8)	mov cr.iha=3Dr17
+(p8)	mov r29=B0				// save b0
 (p8)	br.cond.dptk.many itlb_fault
 #endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
@@ -296,6 +305,7 @@
 (p8)	thash r17=3Dr16
 	;;
 (p8)	mov cr.iha=3Dr17
+(p8)	mov r29=B0				// save b0
 (p8)	br.cond.dptk.many dtlb_fault
 #endif
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl
@@ -336,7 +346,7 @@
 	mov r9=3Dcr.isr
 	adds r3=3D8,r2				// set up second base pointer
 	;;
-	ssm psr.ic
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
@@ -399,7 +409,6 @@
 	shr.u r18=3Dr16,PMD_SHIFT			// shift L2 index into position
 	;;
 	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)
-	mov b0=3Dr30
 	;;
 (p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?
 	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page table en=
try
@@ -409,8 +418,8 @@
 	;;
 (p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was L2 entry NULL?
 	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page table en=
try
-	;;
 (p6)	br.cond.spnt.many page_fault
+	mov b0=3Dr30
 	br.sptk.many b0				// return to continuation point
 	;;
=20
@@ -613,8 +622,7 @@
=20
 	SAVE_MIN				// uses r31; defines r2:
=20
-	// turn interrupt collection back on:
-	ssm psr.ic
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	cmp.eq pSys,pNonSys=3Dr0,r0		// set pSys=3D1, pNonSys=3D0
@@ -701,11 +709,12 @@
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x3000 Entry 12 (size 64 bundles) External Interrupt (4)
+interrupt:
 	mov r31=3Dpr		// prepare to save predicates
 	;;
=20
 	SAVE_MIN_WITH_COVER	// uses r31; defines r2 and r3
-	ssm psr.ic		// turn interrupt collection
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	adds r3=3D8,r2		// set up second base pointer for SAVE_REST
 	srlz.i			// ensure everybody knows psr.ic is back on
@@ -755,7 +764,7 @@
 	// The "alloc" can cause a mandatory store which could lead to
 	// an "Alt DTLB" fault which we can handle only if psr.ic is on.
 	//
-	ssm psr.ic
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i		// guarantee that interrupt collection is enabled
 	;;
@@ -801,7 +810,7 @@
 	SAVE_MIN
 	;;
 	mov r14=3Dcr.isr
-	ssm psr.ic
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
@@ -887,8 +896,7 @@
 	mov r8=3Dcr.iim			// get break immediate (must be done while psr.ic is of=
f)
 	adds r3=3D8,r2			// set up second base pointer for SAVE_REST
=20
-	// turn interrupt collection back on:
-	ssm psr.ic
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i				// guarantee that interrupt collection is enabled
 	;;
@@ -926,7 +934,7 @@
 	// wouldn't get the state to recover.
 	//
 	mov r15=3Dcr.ifa
-	ssm psr.ic
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
@@ -974,7 +982,7 @@
 	mov r10=3Dcr.iim
 	mov r11=3Dcr.itir
 	;;
-	ssm psr.ic
+	ssm psr.ic | PSR_DEFAULT_BITS
 	;;
 	srlz.i					// guarantee that interrupt collection is enabled
 	;;
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.4.0-lia/arch/ia64=
/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/mca_asm.S	Thu Jan 25 15:42:26 2001
@@ -8,6 +8,7 @@
 //		   kstack, switch modes, jump to C INIT handler
 //
 #include <linux/config.h>
+
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/mca_asm.h>
diff -urN linux-davidm/arch/ia64/kernel/minstate.h linux-2.4.0-lia/arch/ia6=
4/kernel/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/minstate.h	Thu Jan 25 15:42:35 2001
@@ -107,7 +107,7 @@
  * Note that psr.ic is NOT turned on by this macro.  This is so that
  * we can pass interruption state as arguments to a handler.
  */
-#define DO_SAVE_MIN(COVER,EXTRA)								  \
+#define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							  \
 	mov rARRSC=3Dar.rsc;									  \
 	mov rARPFS=3Dar.pfs;									  \
 	mov rR1=3Dr1;										  \
@@ -116,14 +116,15 @@
 	mov rB6=B6;		/* rB6 =3D branch reg 6 */					  \
 	mov rCRIIP=3Dcr.iip;									  \
 	mov r1=3Dar.k6;		/* r1 =3D current (physical) */					  \
+	COVER;											  \
 	;;											  \
 	invala;											  \
 	extr.u r16=3DrCRIPSR,32,2;		/* extract psr.cpl */				  \
 	;;											  \
 	cmp.eq pKern,p7=3Dr0,r16;			/* are we in kernel mode already? (psr.cpl=3D=
0) */ \
 	/* switch from user to kernel RBS: */							  \
-	COVER;											  \
 	;;											  \
+	SAVE_IFS;										  \
 	MINSTATE_START_SAVE_MIN									  \
 	;;											  \
 	mov r16=3Dr1;					/* initialize first base pointer */	  \
@@ -240,6 +241,6 @@
 # define STOPS
 #endif
=20
-#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover;; mov rCRIFS=3Dcr.ifs,) STOPS
-#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover;; mov rCRIFS=3Dcr.ifs, m=
ov r15=3Dr19) STOPS
-#define SAVE_MIN		DO_SAVE_MIN(mov rCRIFS=3Dr0,) STOPS
+#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover, mov rCRIFS=3Dcr.ifs,) STOPS
+#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover, mov rCRIFS=3Dcr.ifs, mo=
v r15=3Dr19) STOPS
+#define SAVE_MIN		DO_SAVE_MIN(     , mov rCRIFS=3Dr0, ) STOPS
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-lia/arch/ia64/ker=
nel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Thu Jan 25 19:17:25 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/smp.c	Thu Jan 25 17:19:30 2001
@@ -64,7 +64,6 @@
 volatile int __cpu_physical_id[NR_CPUS] =3D { -1, };    /* Logical ID -> S=
APIC ID */
 int smp_num_cpus =3D 1;	=09
 volatile int smp_threads_ready;			     /* Set when the idlers are all fork=
ed */
-cycles_t cacheflush_time;
 unsigned long ap_wakeup_vector =3D -1;		     /* External Int to use to wak=
eup AP's */
=20
 static volatile unsigned long cpu_callin_map;
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.0-lia/arch/ia64/ke=
rnel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Thu Jan 25 19:17:25 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/time.c	Thu Jan 25 17:21:22 2001
@@ -1,9 +1,9 @@
 /*
  * linux/arch/ia64/kernel/time.c
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
  * Copyright (C) 1998-2000 Stephane Eranian <eranian@hpl.hp.com>
- * Copyright (C) 1999-2000 David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2001 David Mosberger <davidm@hpl.hp.com>
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  * Copyright (C) 1999-2000 VA Linux Systems
  * Copyright (C) 1999-2000 Walt Drummond <drummond@valinux.com>
@@ -32,14 +32,6 @@
=20
 #endif
=20
-static struct {
-	unsigned long delta;
-	union {
-		unsigned long count;
-		unsigned char pad[SMP_CACHE_BYTES];
-	} next[NR_CPUS];
-} itm;
-
 static void
 do_profile (unsigned long ip)
 {
@@ -82,7 +74,7 @@
 	unsigned long now =3D ia64_get_itc(), last_tick;
 	unsigned long elapsed_cycles, lost =3D jiffies - wall_jiffies;
=20
-	last_tick =3D (itm.next[smp_processor_id()].count - (lost+1)*itm.delta);
+	last_tick =3D (my_cpu_data.itm_next - (lost+1)*my_cpu_data.itm_delta);
 # if 1
 	if ((long) (now - last_tick) < 0) {
 		printk("Yikes: now < last_tick (now=3D0x%lx,last_tick=3D%lx)!  No can do=
.\n",
@@ -153,7 +145,7 @@
 	int cpu =3D smp_processor_id();
 	unsigned long new_itm;
=20
-	new_itm =3D itm.next[cpu].count;
+	new_itm =3D cpu_data[cpu].itm_next;
=20
 	if (!time_after(ia64_get_itc(), new_itm))
 		printk("Oops: timer tick before it's due (itc=3D%lx,itm=3D%lx)\n",
@@ -183,8 +175,8 @@
 			write_unlock(&xtime_lock);
 		}
=20
-		new_itm +=3D itm.delta;
-		itm.next[cpu].count =3D new_itm;
+		new_itm +=3D cpu_data[cpu].itm_delta;
+		cpu_data[cpu].itm_next =3D new_itm;
 		if (time_after(new_itm, ia64_get_itc()))
 			break;
 	}
@@ -197,8 +189,8 @@
 	 * turn would let our clock run too fast (with the potentially
 	 * devastating effect of losing monotony of time).
 	 */
-	while (!time_after(new_itm, ia64_get_itc() + itm.delta/2))
-		new_itm +=3D itm.delta;
+	while (!time_after(new_itm, ia64_get_itc() + cpu_data[cpu].itm_delta/2))
+		new_itm +=3D cpu_data[cpu].itm_delta;
 	ia64_set_itm(new_itm);
 }
=20
@@ -219,16 +211,29 @@
  * Encapsulate access to the itm structure for SMP.
  */
 void __init
-ia64_cpu_local_tick(void)
+ia64_cpu_local_tick (void)
 {
+	int cpu =3D smp_processor_id();
+	unsigned long shift =3D 0, delta;
+
 #ifdef CONFIG_IA64_SOFTSDV_HACKS
 	ia64_set_itc(0);
 #endif
=20
 	/* arrange for the cycle counter to generate a timer interrupt: */
 	ia64_set_itv(TIMER_IRQ);
-	itm.next[smp_processor_id()].count =3D ia64_get_itc() + itm.delta;
-	ia64_set_itm(itm.next[smp_processor_id()].count);
+
+	delta =3D cpu_data[cpu].itm_delta;
+	/*
+	 * Stagger the timer tick for each CPU so they don't occur all at (almost=
) the
+	 * same time:
+	 */
+	if (cpu) {
+		unsigned long hi =3D 1UL << ia64_fls(cpu);
+		shift =3D (2*(cpu - hi) + 1) * delta/hi/2;
+	}
+	cpu_data[cpu].itm_next =3D ia64_get_itc() + delta + shift;
+	ia64_set_itm(cpu_data[cpu].itm_next);
 }
=20
 void __init
@@ -236,6 +241,7 @@
 {
 	unsigned long platform_base_freq, itc_freq, drift;
 	struct pal_freq_ratio itc_ratio, proc_ratio;
+	int cpu =3D smp_processor_id();
 	long status;
=20
 	/*
@@ -275,16 +281,16 @@
 		itc_ratio.num =3D 1;	/* avoid division by zero */
=20
         itc_freq =3D (platform_base_freq*itc_ratio.num)/itc_ratio.den;
-        itm.delta =3D itc_freq / HZ;
+        cpu_data[cpu].itm_delta =3D (itc_freq + HZ/2) / HZ;
         printk("CPU %d: base freq=3D%lu.%03luMHz, ITC ratio=3D%lu/%lu, ITC=
 freq=3D%lu.%03luMHz\n",
 	       smp_processor_id(),
 	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
                itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq=
 / 1000) % 1000);
=20
-	my_cpu_data.proc_freq =3D (platform_base_freq*proc_ratio.num)/proc_ratio.=
den;
-	my_cpu_data.itc_freq =3D itc_freq;
-	my_cpu_data.cyc_per_usec =3D itc_freq / 1000000;
-	my_cpu_data.usec_per_cyc =3D (1000000UL << IA64_USEC_PER_CYC_SHIFT) / itc=
_freq;
+	cpu_data[cpu].proc_freq =3D (platform_base_freq*proc_ratio.num)/proc_rati=
o.den;
+	cpu_data[cpu].itc_freq =3D itc_freq;
+	cpu_data[cpu].cyc_per_usec =3D (itc_freq + 500000) / 1000000;
+	cpu_data[cpu].usec_per_cyc =3D ((1000000UL<<IA64_USEC_PER_CYC_SHIFT) + it=
c_freq/2)/itc_freq;
=20
 	/* Setup the CPU local timer tick */
 	ia64_cpu_local_tick();
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c linux-2.4.0-lia/arch/ia=
64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/unaligned.c	Thu Jan 25 17:21:49 2001
@@ -1,8 +1,11 @@
 /*
  * Architecture-specific unaligned trap handling.
  *
- * Copyright (C) 1999-2000 Hewlett-Packard Co
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
  * Copyright (C) 1999-2000 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *
+ * 2001/01/17	Add support emulation of unaligned kernel accesses.
  */
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -17,14 +20,28 @@
 #undef DEBUG_UNALIGNED_TRAP
=20
 #ifdef DEBUG_UNALIGNED_TRAP
-#define DPRINT(a) { printk("%s, line %d: ", __FUNCTION__, __LINE__); print=
k a;}
+# define DPRINT(a...)	do { printk("%s.%u: ", __FUNCTION__, __LINE__); prin=
tk (a); } while (0)
+# define DDUMP(str,vp,len)	dump(str, vp, len)
+
+static void
+dump (const char *str, void *vp, size_t len)
+{
+	unsigned char *cp =3D vp;
+	int i;
+
+	printk("%s", str);
+	for (i =3D 0; i < len; ++i)
+		printk (" %02x", *cp++);
+	printk("\n");
+}
 #else
-#define DPRINT(a)
+# define DPRINT(a...)
+# define DDUMP(str,vp,len)
 #endif
=20
 #define IA64_FIRST_STACKED_GR	32
 #define IA64_FIRST_ROTATING_FR	32
-#define SIGN_EXT9		__IA64_UL(0xffffffffffffff00)
+#define SIGN_EXT9		0xffffffffffffff00ul
=20
 /*
  * For M-unit:
@@ -40,7 +57,8 @@
  * mask ([40:32]) using 9 bits. The 'e' comes from the fact that we defer
  * checking the m-bit until later in the load/store emulation.
  */
-#define IA64_OPCODE_MASK	0x1ef00000000
+#define IA64_OPCODE_MASK	0x1ef
+#define IA64_OPCODE_SHIFT	32
=20
 /*
  * Table C-28 Integer Load/Store
@@ -50,18 +68,18 @@
  * ld8.fill, st8.fill  MUST be aligned because the RNATs are based on=20
  * the address (bits [8:3]), so we must failed.
  */
-#define LD_OP            0x08000000000
-#define LDS_OP           0x08100000000
-#define LDA_OP           0x08200000000
-#define LDSA_OP          0x08300000000
-#define LDBIAS_OP        0x08400000000
-#define LDACQ_OP         0x08500000000
+#define LD_OP            0x080
+#define LDS_OP           0x081
+#define LDA_OP           0x082
+#define LDSA_OP          0x083
+#define LDBIAS_OP        0x084
+#define LDACQ_OP         0x085
 /* 0x086, 0x087 are not relevant */
-#define LDCCLR_OP        0x08800000000
-#define LDCNC_OP         0x08900000000
-#define LDCCLRACQ_OP     0x08a00000000
-#define ST_OP            0x08c00000000
-#define STREL_OP         0x08d00000000
+#define LDCCLR_OP        0x088
+#define LDCNC_OP         0x089
+#define LDCCLRACQ_OP     0x08a
+#define ST_OP            0x08c
+#define STREL_OP         0x08d
 /* 0x08e,0x8f are not relevant */
=20
 /*
@@ -79,32 +97,32 @@
  * ld8.fill, st8.fill  must be aligned because the Nat register are based =
on=20
  * the address, so we must fail and the program must be fixed.
  */
-#define LD_IMM_OP            0x0a000000000
-#define LDS_IMM_OP           0x0a100000000
-#define LDA_IMM_OP           0x0a200000000
-#define LDSA_IMM_OP          0x0a300000000
-#define LDBIAS_IMM_OP        0x0a400000000
-#define LDACQ_IMM_OP         0x0a500000000
+#define LD_IMM_OP            0x0a0
+#define LDS_IMM_OP           0x0a1
+#define LDA_IMM_OP           0x0a2
+#define LDSA_IMM_OP          0x0a3
+#define LDBIAS_IMM_OP        0x0a4
+#define LDACQ_IMM_OP         0x0a5
 /* 0x0a6, 0xa7 are not relevant */
-#define LDCCLR_IMM_OP        0x0a800000000
-#define LDCNC_IMM_OP         0x0a900000000
-#define LDCCLRACQ_IMM_OP     0x0aa00000000
-#define ST_IMM_OP            0x0ac00000000
-#define STREL_IMM_OP         0x0ad00000000
+#define LDCCLR_IMM_OP        0x0a8
+#define LDCNC_IMM_OP         0x0a9
+#define LDCCLRACQ_IMM_OP     0x0aa
+#define ST_IMM_OP            0x0ac
+#define STREL_IMM_OP         0x0ad
 /* 0x0ae,0xaf are not relevant */
=20
 /*
  * Table C-32 Floating-point Load/Store
  */
-#define LDF_OP           0x0c000000000
-#define LDFS_OP          0x0c100000000
-#define LDFA_OP          0x0c200000000
-#define LDFSA_OP         0x0c300000000
+#define LDF_OP           0x0c0
+#define LDFS_OP          0x0c1
+#define LDFA_OP          0x0c2
+#define LDFSA_OP         0x0c3
 /* 0x0c6 is irrelevant */
-#define LDFCCLR_OP       0x0c800000000
-#define LDFCNC_OP        0x0c900000000
+#define LDFCCLR_OP       0x0c8
+#define LDFCNC_OP        0x0c9
 /* 0x0cb is irrelevant  */
-#define STF_OP           0x0cc00000000
+#define STF_OP           0x0cc
=20
 /*
  * Table C-33 Floating-point Load +Reg
@@ -116,14 +134,14 @@
 /*
  * Table C-34 Floating-point Load/Store +Imm
  */
-#define LDF_IMM_OP       0x0e000000000
-#define LDFS_IMM_OP      0x0e100000000
-#define LDFA_IMM_OP      0x0e200000000
-#define LDFSA_IMM_OP     0x0e300000000
+#define LDF_IMM_OP       0x0e0
+#define LDFS_IMM_OP      0x0e1
+#define LDFA_IMM_OP      0x0e2
+#define LDFSA_IMM_OP     0x0e3
 /* 0x0e6 is irrelevant */
-#define LDFCCLR_IMM_OP   0x0e800000000
-#define LDFCNC_IMM_OP    0x0e900000000
-#define STF_IMM_OP       0x0ec00000000
+#define LDFCCLR_IMM_OP   0x0e8
+#define LDFCNC_IMM_OP    0x0e9
+#define STF_IMM_OP       0x0ec
=20
 typedef struct {
 	unsigned long  	 qp:6;	/* [0:5]   */
@@ -255,150 +273,148 @@
 }
=20
 static void
-set_rse_reg(struct pt_regs *regs, unsigned long r1, unsigned long val, int=
 nat)
+set_rse_reg (struct pt_regs *regs, unsigned long r1, unsigned long val, in=
t nat)
 {
-	struct switch_stack *sw =3D (struct switch_stack *)regs - 1;
-	unsigned long *kbs	=3D ((unsigned long *)current) + IA64_RBS_OFFSET/8;
+	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
+	unsigned long *bsp, *bspstore, *addr, *rnat_addr, *ubs_end;
+	unsigned long *kbs =3D (void *) current + IA64_RBS_OFFSET;
+	unsigned long rnats, nat_mask;
 	unsigned long on_kbs;
-	unsigned long *bsp, *bspstore, *addr, *ubs_end, *slot;
-	unsigned long rnats;
-	long nlocals;
+	long sof =3D (regs->cr_ifs) & 0x7f;
=20
-	/*
-	 * cr_ifs=3D[rv:ifm], ifm=3D[....:sof(6)]
-	 * nlocal=3Dnumber of locals (in+loc) register of the faulting function
-	 */
-	nlocals =3D (regs->cr_ifs) & 0x7f;
+	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld\n",
+	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) &=
 0x7f);
=20
-	DPRINT(("sw.bsptore=3D%lx pt.bspstore=3D%lx\n", sw->ar_bspstore, regs->ar=
_bspstore));
-	DPRINT(("cr.ifs=3D%lx sof=3D%ld sol=3D%ld\n",
-		regs->cr_ifs, regs->cr_ifs &0x7f, (regs->cr_ifs>>7)&0x7f));
+	if ((r1 - 32) >=3D sof) {
+		/* this should never happen, as the "rsvd register fault" has higher pri=
ority */
+		DPRINT("ignoring write to r%lu; only %lu registers are allocated!\n", r1=
, sof);
+		return;
+	}
=20
-	on_kbs   =3D ia64_rse_num_regs(kbs, (unsigned long *)sw->ar_bspstore);
-	bspstore =3D (unsigned long *)regs->ar_bspstore;
+	on_kbs =3D ia64_rse_num_regs(kbs, (unsigned long *) sw->ar_bspstore);
+	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + (r1=
 - 32));
+	if (addr >=3D kbs) {
+		/* the register is on the kernel backing store: easy... */
+		rnat_addr =3D ia64_rse_rnat_addr(addr);
+		if ((unsigned long) rnat_addr >=3D sw->ar_bspstore)
+			rnat_addr =3D &sw->ar_rnat;
+		nat_mask =3D 1UL << ia64_rse_slot_num(addr);
=20
-	DPRINT(("rse_slot_num=3D0x%lx\n",ia64_rse_slot_num((unsigned long *)sw->a=
r_bspstore)));
-	DPRINT(("kbs=3D%p nlocals=3D%ld\n", (void *) kbs, nlocals));
-	DPRINT(("bspstore next rnat slot %p\n",
-		(void *) ia64_rse_rnat_addr((unsigned long *)sw->ar_bspstore)));
-	DPRINT(("on_kbs=3D%ld rnats=3D%ld\n",
-		on_kbs, ((sw->ar_bspstore-(unsigned long)kbs)>>3) - on_kbs));
+		*addr =3D val;
+		if (nat)
+			*rnat_addr |=3D  nat_mask;
+		else
+			*rnat_addr &=3D ~nat_mask;
+		return;
+	}
=20
 	/*
-	 * See get_rse_reg() for an explanation on the following instructions
+	 * Avoid using user_mode() here: with "epc", we cannot use the privilege =
level to
+	 * infer whether the interrupt task was running on the kernel backing sto=
re.
 	 */
+	if (regs->r12 >=3D TASK_SIZE) {
+		DPRINT("ignoring kernel write to r%lu; register isn't on the RBS!", r1);
+		return;
+	}
+
+	bspstore =3D (unsigned long *) regs->ar_bspstore;
 	ubs_end =3D ia64_rse_skip_regs(bspstore, on_kbs);
-	bsp     =3D ia64_rse_skip_regs(ubs_end, -nlocals);
-	addr    =3D slot =3D ia64_rse_skip_regs(bsp, r1 - 32);
+	bsp     =3D ia64_rse_skip_regs(ubs_end, -sof);
+	addr    =3D ia64_rse_skip_regs(bsp, r1 - 32);
=20
-	DPRINT(("ubs_end=3D%p bsp=3D%p addr=3D%p slot=3D0x%lx\n",
-		(void *) ubs_end, (void *) bsp, (void *) addr, ia64_rse_slot_num(addr)));
+	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%px\n", (void *) ubs_end, (void *) b=
sp, (void *) addr);
=20
-	ia64_poke(regs, current, (unsigned long)addr, val);
+	ia64_poke(regs, current, (unsigned long) addr, val);
=20
-	/*
-	 * addr will now contain the address of the RNAT for the register
-	 */
-	addr =3D ia64_rse_rnat_addr(addr);
+	rnat_addr =3D ia64_rse_rnat_addr(addr);
=20
-	ia64_peek(regs, current, (unsigned long)addr, &rnats);
-	DPRINT(("rnat @%p =3D 0x%lx nat=3D%d rnatval=3D%lx\n",
-		(void *) addr, rnats, nat, rnats &ia64_rse_slot_num(slot)));
-=09
-	if (nat) {
-		rnats |=3D __IA64_UL(1) << ia64_rse_slot_num(slot);
-	} else {
-		rnats &=3D ~(__IA64_UL(1) << ia64_rse_slot_num(slot));
-	}
-	ia64_poke(regs, current, (unsigned long)addr, rnats);
+	ia64_peek(regs, current, (unsigned long) rnat_addr, &rnats);
+	DPRINT("rnat @%p =3D 0x%lx nat=3D%d old nat=3D%ld\n",
+	       (void *) rnat_addr, rnats, nat, (rnats >> ia64_rse_slot_num(addr))=
 & 1);
+
+	nat_mask =3D 1UL << ia64_rse_slot_num(addr);
+	if (nat)
+		rnats |=3D  nat_mask;
+	else
+		rnats &=3D ~nat_mask;
+	ia64_poke(regs, current, (unsigned long) rnat_addr, rnats);
=20
-	DPRINT(("rnat changed to @%p =3D 0x%lx\n", (void *) addr, rnats));
+	DPRINT("rnat changed to @%p =3D 0x%lx\n", (void *) rnat_addr, rnats);
 }
=20
=20
 static void
-get_rse_reg(struct pt_regs *regs, unsigned long r1, unsigned long *val, in=
t *nat)
+get_rse_reg (struct pt_regs *regs, unsigned long r1, unsigned long *val, i=
nt *nat)
 {
-	struct switch_stack *sw =3D (struct switch_stack *)regs - 1;
-	unsigned long *kbs	=3D (unsigned long *)current + IA64_RBS_OFFSET/8;
+	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
+	unsigned long *bsp, *addr, *rnat_addr, *ubs_end, *bspstore;
+	unsigned long *kbs =3D (void *) current + IA64_RBS_OFFSET;
+	unsigned long rnats, nat_mask;
 	unsigned long on_kbs;
-	long nlocals;
-	unsigned long *bsp, *addr, *ubs_end, *slot, *bspstore;
-	unsigned long rnats;
+	long sof =3D (regs->cr_ifs) & 0x7f;
=20
-	/*
-	 * cr_ifs=3D[rv:ifm], ifm=3D[....:sof(6)]
-	 * nlocals=3Dnumber of local registers in the faulting function
-	 */
-	nlocals =3D (regs->cr_ifs) & 0x7f;
+	DPRINT("r%lu, sw.bspstore=3D%lx pt.bspstore=3D%lx sof=3D%ld sol=3D%ld\n",
+	       r1, sw->ar_bspstore, regs->ar_bspstore, sof, (regs->cr_ifs >> 7) &=
 0x7f);
=20
-	/*
-	 * save_switch_stack does a flushrs and saves bspstore.
-	 * on_kbs =3D actual number of registers saved on kernel backing store
-	 *          (taking into accound potential RNATs)
-	 *
-	 * Note that this number can be greater than nlocals if the dirty
-	 * parititions included more than one stack frame at the time we
-	 * switched to KBS
-	 */
-	on_kbs   =3D ia64_rse_num_regs(kbs, (unsigned long *)sw->ar_bspstore);
-	bspstore =3D (unsigned long *)regs->ar_bspstore;
+	if ((r1 - 32) >=3D sof) {
+		/* this should never happen, as the "rsvd register fault" has higher pri=
ority */
+		DPRINT("ignoring read from r%lu; only %lu registers are allocated!\n", r=
1, sof);
+		return;
+	}
+
+	on_kbs =3D ia64_rse_num_regs(kbs, (unsigned long *) sw->ar_bspstore);
+	addr =3D ia64_rse_skip_regs((unsigned long *) sw->ar_bspstore, -sof + (r1=
 - 32));
+	if (addr >=3D kbs) {
+		/* the register is on the kernel backing store: easy... */
+		*val =3D *addr;
+		if (nat) {
+			rnat_addr =3D ia64_rse_rnat_addr(addr);
+			if ((unsigned long) rnat_addr >=3D sw->ar_bspstore)
+				rnat_addr =3D &sw->ar_rnat;
+			nat_mask =3D 1UL << ia64_rse_slot_num(addr);
+			*nat =3D (*rnat_addr & nat_mask) !=3D 0;
+		}
+		return;
+	}
=20
 	/*
-	 * To simplify the logic, we calculate everything as if there was only
-	 * one backing store i.e., the user one (UBS). We let it to peek/poke
-	 * to figure out whether the register we're looking for really is
-	 * on the UBS or on KBS.
-	 *
-	 * regs->ar_bsptore =3D address of last register saved on UBS (before swi=
tch)
-	 *
-	 * ubs_end =3D virtual end of the UBS (if everything had been spilled the=
re)
-	 *
-	 * We know that ubs_end is the point where the last register on the
-	 * stack frame we're interested in as been saved. So we need to walk
-	 * our way backward to figure out what the BSP "was" for that frame,
-	 * this will give us the location of r32.=20
-	 *
-	 * bsp =3D "virtual UBS" address of r32 for our frame
-	 *
-	 * Finally, get compute the address of the register we're looking for
-	 * using bsp as our base (move up again).
-	 *
-	 * Please note that in our case, we know that the register is necessarily
-	 * on the KBS because we are only interested in the current frame at the =
moment
-	 * we got the exception i.e., bsp is not changed until we switch to KBS.
+	 * Avoid using user_mode() here: with "epc", we cannot use the privilege =
level to
+	 * infer whether the interrupt task was running on the kernel backing sto=
re.
 	 */
+	if (regs->r12 >=3D TASK_SIZE) {
+		DPRINT("ignoring kernel read of r%lu; register isn't on the RBS!", r1);
+		return;
+	}
+
+	bspstore =3D (unsigned long *)regs->ar_bspstore;
 	ubs_end =3D ia64_rse_skip_regs(bspstore, on_kbs);
-	bsp     =3D ia64_rse_skip_regs(ubs_end, -nlocals);
-	addr    =3D slot =3D ia64_rse_skip_regs(bsp, r1 - 32);
+	bsp     =3D ia64_rse_skip_regs(ubs_end, -sof);
+	addr    =3D ia64_rse_skip_regs(bsp, r1 - 32);
=20
-	DPRINT(("ubs_end=3D%p bsp=3D%p addr=3D%p slot=3D0x%lx\n",
-		(void *) ubs_end, (void *) bsp, (void *) addr, ia64_rse_slot_num(addr)));
+	DPRINT("ubs_end=3D%p bsp=3D%p addr=3D%p\n", (void *) ubs_end, (void *) bs=
p, (void *) addr);
 =09
-	ia64_peek(regs, current, (unsigned long)addr, val);
+	ia64_peek(regs, current, (unsigned long) addr, val);
=20
-	/*
-	 * addr will now contain the address of the RNAT for the register
-	 */
-	addr =3D ia64_rse_rnat_addr(addr);
+	if (nat) {
+		rnat_addr =3D ia64_rse_rnat_addr(addr);
+		nat_mask =3D 1UL << ia64_rse_slot_num(addr);
=20
-	ia64_peek(regs, current, (unsigned long)addr, &rnats);
-	DPRINT(("rnat @%p =3D 0x%lx\n", (void *) addr, rnats));
-=09
-	if (nat)
-		*nat =3D rnats >> ia64_rse_slot_num(slot) & 0x1;
+		DPRINT("rnat @%p =3D 0x%lx\n", (void *) rnat_addr, rnats);
+
+		ia64_peek(regs, current, (unsigned long) rnat_addr, &rnats);
+		*nat =3D (rnats & nat_mask) !=3D 0;
+	}
 }
=20
=20
 static void
-setreg(unsigned long regnum, unsigned long val, int nat, struct pt_regs *r=
egs)
+setreg (unsigned long regnum, unsigned long val, int nat, struct pt_regs *=
regs)
 {
-	struct switch_stack *sw =3D (struct switch_stack *)regs -1;
+	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
 	unsigned long addr;
 	unsigned long bitmask;
 	unsigned long *unat;
=20
-
 	/*
 	 * First takes care of stacked registers
 	 */
@@ -422,8 +438,8 @@
 		addr =3D (unsigned long)regs;
 		unat =3D &sw->caller_unat;
 	}
-	DPRINT(("tmp_base=3D%lx switch_stack=3D%s offset=3D%d\n",
-		addr, unat=3D&sw->ar_unat ? "yes":"no", GR_OFFS(regnum)));
+	DPRINT("tmp_base=3D%lx switch_stack=3D%s offset=3D%d\n",
+	       addr, unat=3D&sw->ar_unat ? "yes":"no", GR_OFFS(regnum));
 	/*
 	 * add offset from base of struct
 	 * and do it !
@@ -436,20 +452,20 @@
 	 * We need to clear the corresponding UNAT bit to fully emulate the load
 	 * UNAT bit_pos =3D GR[r3]{8:3} form EAS-2.4
 	 */
-	bitmask   =3D __IA64_UL(1) << (addr >> 3 & 0x3f);
-	DPRINT(("*0x%lx=3D0x%lx NaT=3D%d prev_unat @%p=3D%lx\n", addr, val, nat, =
(void *) unat, *unat));
+	bitmask   =3D 1UL << (addr >> 3 & 0x3f);
+	DPRINT("*0x%lx=3D0x%lx NaT=3D%d prev_unat @%p=3D%lx\n", addr, val, nat, (=
void *) unat, *unat);
 	if (nat) {
 		*unat |=3D bitmask;
 	} else {
 		*unat &=3D ~bitmask;
 	}
-	DPRINT(("*0x%lx=3D0x%lx NaT=3D%d new unat: %p=3D%lx\n", addr, val, nat, (=
void *) unat,*unat));
+	DPRINT("*0x%lx=3D0x%lx NaT=3D%d new unat: %p=3D%lx\n", addr, val, nat, (v=
oid *) unat,*unat);
 }
=20
 #define IA64_FPH_OFFS(r) (r - IA64_FIRST_ROTATING_FR)
=20
 static void
-setfpreg(unsigned long regnum, struct ia64_fpreg *fpval, struct pt_regs *r=
egs)
+setfpreg (unsigned long regnum, struct ia64_fpreg *fpval, struct pt_regs *=
regs)
 {
 	struct switch_stack *sw =3D (struct switch_stack *)regs - 1;
 	unsigned long addr;
@@ -478,7 +494,7 @@
 			addr =3D (unsigned long)regs;
 		}
 	=09
-		DPRINT(("tmp_base=3D%lx offset=3D%d\n", addr, FR_OFFS(regnum)));
+		DPRINT("tmp_base=3D%lx offset=3D%d\n", addr, FR_OFFS(regnum));
=20
 		addr +=3D FR_OFFS(regnum);
 		*(struct ia64_fpreg *)addr =3D *fpval;
@@ -498,21 +514,21 @@
  * registers which can be used with stfX
  */
 static inline void=20
-float_spill_f0(struct ia64_fpreg *final)
+float_spill_f0 (struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("stf.spill [%0]=F0" :: "r"(final) : "memory");
 }
=20
 static inline void=20
-float_spill_f1(struct ia64_fpreg *final)
+float_spill_f1 (struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("stf.spill [%0]=F1" :: "r"(final) : "memory");
 }
=20
 static void
-getfpreg(unsigned long regnum, struct ia64_fpreg *fpval, struct pt_regs *r=
egs)
+getfpreg (unsigned long regnum, struct ia64_fpreg *fpval, struct pt_regs *=
regs)
 {
-	struct switch_stack *sw =3D (struct switch_stack *)regs -1;
+	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
 	unsigned long addr;
=20
 	/*
@@ -546,8 +562,8 @@
 			addr =3D  FR_IN_SW(regnum) ? (unsigned long)sw
 						 : (unsigned long)regs;
=20
-			DPRINT(("is_sw=3D%d tmp_base=3D%lx offset=3D0x%x\n",
-				FR_IN_SW(regnum), addr, FR_OFFS(regnum)));
+			DPRINT("is_sw=3D%d tmp_base=3D%lx offset=3D0x%x\n",
+			       FR_IN_SW(regnum), addr, FR_OFFS(regnum));
=20
 			addr  +=3D FR_OFFS(regnum);
 			*fpval =3D *(struct ia64_fpreg *)addr;
@@ -557,9 +573,9 @@
=20
=20
 static void
-getreg(unsigned long regnum, unsigned long *val, int *nat, struct pt_regs =
*regs)
+getreg (unsigned long regnum, unsigned long *val, int *nat, struct pt_regs=
 *regs)
 {
-	struct switch_stack *sw =3D (struct switch_stack *)regs -1;
+	struct switch_stack *sw =3D (struct switch_stack *) regs - 1;
 	unsigned long addr, *unat;
=20
  	if (regnum >=3D IA64_FIRST_STACKED_GR) {
@@ -588,7 +604,7 @@
 		unat =3D &sw->caller_unat;
 	}
=20
-	DPRINT(("addr_base=3D%lx offset=3D0x%x\n", addr,  GR_OFFS(regnum)));
+	DPRINT("addr_base=3D%lx offset=3D0x%x\n", addr,  GR_OFFS(regnum));
=20
 	addr +=3D GR_OFFS(regnum);
=20
@@ -602,7 +618,7 @@
 }
=20
 static void
-emulate_load_updates(update_t type, load_store_t *ld, struct pt_regs *regs=
, unsigned long ifa)
+emulate_load_updates (update_t type, load_store_t ld, struct pt_regs *regs=
, unsigned long ifa)
 {	=09
 	/*
 	 * IMPORTANT:=20
@@ -610,7 +626,7 @@
 	 * not get to this point in the code but we keep this sanity check,
 	 * just in case.
 	 */
-	if (ld->x6_op =3D 1 || ld->x6_op =3D 3) {
+	if (ld.x6_op =3D 1 || ld.x6_op =3D 3) {
 		printk(KERN_ERR __FUNCTION__": register update on speculative load, erro=
r\n");=09
 		die_if_kernel("unaligned reference on specualtive load with register upd=
ate\n",
 			      regs, 30);
@@ -630,12 +646,12 @@
 		 *
 	   	 * form imm9: [13:19] contain the first 7 bits
       		 */		=20
-		imm =3D ld->x << 7 | ld->imm;
+		imm =3D ld.x << 7 | ld.imm;
=20
 		/*
 		 * sign extend (1+8bits) if m set
 		 */
-		if (ld->m) imm |=3D SIGN_EXT9;
+		if (ld.m) imm |=3D SIGN_EXT9;
=20
 		/*
 		 * ifa =3D r3 and we know that the NaT bit on r3 was clear so
@@ -643,11 +659,11 @@
 		 */
 		ifa +=3D imm;
=20
-		setreg(ld->r3, ifa, 0, regs);
+		setreg(ld.r3, ifa, 0, regs);
=20
-		DPRINT(("ld.x=3D%d ld.m=3D%d imm=3D%ld r3=3D0x%lx\n", ld->x, ld->m, imm,=
 ifa));
+		DPRINT("ld.x=3D%d ld.m=3D%d imm=3D%ld r3=3D0x%lx\n", ld.x, ld.m, imm, if=
a);
=20
-	} else if (ld->m) {
+	} else if (ld.m) {
 		unsigned long r2;
 		int nat_r2;
=20
@@ -667,39 +683,24 @@
 		 * never reach this code when trying to do a ldX.s.
 		 * If we ever make it to here on an ldfX.s then=20
 		 */
-		getreg(ld->imm, &r2, &nat_r2, regs);
+		getreg(ld.imm, &r2, &nat_r2, regs);
 	=09
 		ifa +=3D r2;
 	=09
 		/*
 		 * propagate Nat r2 -> r3
 		 */
-		setreg(ld->r3, ifa, nat_r2, regs);
+		setreg(ld.r3, ifa, nat_r2, regs);
=20
-		DPRINT(("imm=3D%d r2=3D%ld r3=3D0x%lx nat_r2=3D%d\n",ld->imm, r2, ifa, n=
at_r2));
+		DPRINT("imm=3D%d r2=3D%ld r3=3D0x%lx nat_r2=3D%d\n",ld.imm, r2, ifa, nat=
_r2);
 	}
 }
=20
=20
 static int
-emulate_load_int(unsigned long ifa, load_store_t *ld, struct pt_regs *regs)
+emulate_load_int (unsigned long ifa, load_store_t ld, struct pt_regs *regs)
 {
-	unsigned long val;
-	unsigned int len =3D 1<< ld->x6_sz;
-
-	/*
-	 * the macro supposes sequential access (which is the case)
-	 * if the first byte is an invalid address we return here. Otherwise
-	 * there is a guard page at the top of the user's address page and=20
-	 * the first access would generate a NaT consumption fault and return
-	 * with a SIGSEGV, which is what we want.
-	 *
-	 * Note: the first argument is ignored=20
-	 */
-	if (access_ok(VERIFY_READ, (void *)ifa, len) < 0) {
-		DPRINT(("verify area failed on %lx\n", ifa));
-		return -1;
-	}
+	unsigned int len =3D 1 << ld.x6_sz;
=20
 	/*
 	 * r0, as target, doesn't need to be checked because Illegal Instruction
@@ -710,42 +711,27 @@
 	 */
=20
 	/*
-	 * ldX.a we don't try to emulate anything but we must
-	 * invalidate the ALAT entry.
+	 * ldX.a we don't try to emulate anything but we must invalidate the ALAT=
 entry.
 	 * See comment below for explanation on how we handle ldX.a
 	 */
-	if (ld->x6_op !=3D 0x2) {
-		/*
-		 * we rely on the macros in unaligned.h for now i.e.,
-		 * we let the compiler figure out how to read memory gracefully.
-		 *
-		 * We need this switch/case because the way the inline function
-		 * works. The code is optimized by the compiler and looks like
-		 * a single switch/case.
-		 */
-		switch(len) {
-			case 2:
-				val =3D ia64_get_unaligned((void *)ifa, 2);
-				break;
-			case 4:
-				val =3D ia64_get_unaligned((void *)ifa, 4);
-				break;
-			case 8:
-				val =3D ia64_get_unaligned((void *)ifa, 8);
-				break;
-			default:
-				DPRINT(("unknown size: x6=3D%d\n", ld->x6_sz));
-				return -1;
-		}
+	if (ld.x6_op !=3D 0x2) {
+		unsigned long val =3D 0;
=20
-		setreg(ld->r1, val, 0, regs);
+		if (len !=3D 2 && len !=3D 4 && len !=3D 8) {
+			DPRINT("unknown size: x6=3D%d\n", ld.x6_sz);
+			return -1;
+		}
+		/* this assumes little-endian byte-order: */
+		if (copy_from_user(&val, (void *) ifa, len))
+		    return -1;
+		setreg(ld.r1, val, 0, regs);
 	}
=20
 	/*
 	 * check for updates on any kind of loads
 	 */
-	if (ld->op =3D 0x5 || ld->m)
-		emulate_load_updates(ld->op =3D 0x5 ? UPD_IMMEDIATE: UPD_REG, ld, regs, =
ifa);
+	if (ld.op =3D 0x5 || ld.m)
+		emulate_load_updates(ld.op =3D 0x5 ? UPD_IMMEDIATE: UPD_REG, ld, regs, i=
fa);
=20
 	/*
 	 * handling of various loads (based on EAS2.4):
@@ -753,7 +739,6 @@
 	 * ldX.acq (ordered load):
 	 *	- acquire semantics would have been used, so force fence instead.
 	 *
-	 *
 	 * ldX.c.clr (check load and clear):
 	 *	- if we get to this handler, it's because the entry was not in the ALA=
T.
 	 *	  Therefore the operation reverts to a normal load
@@ -831,45 +816,31 @@
 	 * when the load has the .acq completer then=20
 	 * use ordering fence.
 	 */
-	if (ld->x6_op =3D 0x5 || ld->x6_op =3D 0xa)
+	if (ld.x6_op =3D 0x5 || ld.x6_op =3D 0xa)
 		mb();
=20
 	/*
 	 * invalidate ALAT entry in case of advanced load
 	 */
-	if (ld->x6_op =3D 0x2)
-		invala_gr(ld->r1);
+	if (ld.x6_op =3D 0x2)
+		invala_gr(ld.r1);
=20
 	return 0;
 }
=20
 static int
-emulate_store_int(unsigned long ifa, load_store_t *ld, struct pt_regs *reg=
s)
+emulate_store_int (unsigned long ifa, load_store_t ld, struct pt_regs *reg=
s)
 {
 	unsigned long r2;
-	unsigned int len =3D 1<< ld->x6_sz;
+	unsigned int len =3D 1 << ld.x6_sz;
 =09
 	/*
-	 * the macro supposes sequential access (which is the case)
-	 * if the first byte is an invalid address we return here. Otherwise
-	 * there is a guard page at the top of the user's address page and=20
-	 * the first access would generate a NaT consumption fault and return
-	 * with a SIGSEGV, which is what we want.
-	 *
-	 * Note: the first argument is ignored=20
-	 */
-	if (access_ok(VERIFY_WRITE, (void *)ifa, len) < 0) {
-		DPRINT(("verify area failed on %lx\n",ifa));
-		return -1;
-	}
-
-	/*
 	 * if we get to this handler, Nat bits on both r3 and r2 have already
 	 * been checked. so we don't need to do it
 	 *
 	 * extract the value to be stored
 	 */
-	getreg(ld->imm, &r2, 0, regs);
+	getreg(ld.imm, &r2, 0, regs);
=20
 	/*
 	 * we rely on the macros in unaligned.h for now i.e.,
@@ -879,48 +850,43 @@
 	 * works. The code is optimized by the compiler and looks like
 	 * a single switch/case.
 	 */
-	DPRINT(("st%d [%lx]=3D%lx\n", len, ifa, r2));
+	DPRINT("st%d [%lx]=3D%lx\n", len, ifa, r2);
=20
-	switch(len) {
-		case 2:
-			ia64_put_unaligned(r2, (void *)ifa, 2);
-			break;
-		case 4:
-			ia64_put_unaligned(r2, (void *)ifa, 4);
-			break;
-		case 8:
-			ia64_put_unaligned(r2, (void *)ifa, 8);
-			break;
-		default:
-			DPRINT(("unknown size: x6=3D%d\n", ld->x6_sz));
-			return -1;
+	if (len !=3D 2 && len !=3D 4 && len !=3D 8) {
+		DPRINT("unknown size: x6=3D%d\n", ld.x6_sz);
+		return -1;
 	}
+
+	/* this assumes little-endian byte-order: */
+	if (copy_to_user((void *) ifa, &r2, len))
+		return -1;
+
 	/*
 	 * stX [r3]=3Dr2,imm(9)
 	 *
 	 * NOTE:
-	 * ld->r3 can never be r0, because r0 would not generate an=20
+	 * ld.r3 can never be r0, because r0 would not generate an=20
 	 * unaligned access.
 	 */
-	if (ld->op =3D 0x5) {
+	if (ld.op =3D 0x5) {
 		unsigned long imm;
=20
 		/*
 		 * form imm9: [12:6] contain first 7bits
 		 */
-		imm =3D ld->x << 7 | ld->r1;
+		imm =3D ld.x << 7 | ld.r1;
 		/*
 		 * sign extend (8bits) if m set
 		 */
-		if (ld->m) imm |=3D SIGN_EXT9;=20
+		if (ld.m) imm |=3D SIGN_EXT9;=20
 		/*
 		 * ifa =3D r3 (NaT is necessarily cleared)
 		 */
 		ifa +=3D imm;
=20
-		DPRINT(("imm=3D%lx r3=3D%lx\n", imm, ifa));
+		DPRINT("imm=3D%lx r3=3D%lx\n", imm, ifa);
 =09
-		setreg(ld->r3, ifa, 0, regs);
+		setreg(ld.r3, ifa, 0, regs);
 	}
 	/*
 	 * we don't have alat_invalidate_multiple() so we need
@@ -931,7 +897,7 @@
 	/*
 	 * stX.rel: use fence instead of release
 	 */
-	if (ld->x6_op =3D 0xd)
+	if (ld.x6_op =3D 0xd)
 		mb();
=20
 	return 0;
@@ -940,7 +906,7 @@
 /*
  * floating point operations sizes in bytes
  */
-static const unsigned short float_fsz[4]=3D{
+static const unsigned char float_fsz[4]=3D{
 	16, /* extended precision (e) */
 	8,  /* integer (8)            */
 	4,  /* single precision (s)   */
@@ -948,72 +914,68 @@
 };
=20
 static inline void=20
-mem2float_extended(struct ia64_fpreg *init, struct ia64_fpreg *final)
+mem2float_extended (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldfe f6=3D[%0];; stf.spill [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static inline void=20
-mem2float_integer(struct ia64_fpreg *init, struct ia64_fpreg *final)
+mem2float_integer (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldf8 f6=3D[%0];; stf.spill [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static inline void=20
-mem2float_single(struct ia64_fpreg *init, struct ia64_fpreg *final)
+mem2float_single (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldfs f6=3D[%0];; stf.spill [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static inline void=20
-mem2float_double(struct ia64_fpreg *init, struct ia64_fpreg *final)
+mem2float_double (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldfd f6=3D[%0];; stf.spill [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static inline void=20
-float2mem_extended(struct ia64_fpreg *init, struct ia64_fpreg *final)
+float2mem_extended (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldf.fill f6=3D[%0];; stfe [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static inline void=20
-float2mem_integer(struct ia64_fpreg *init, struct ia64_fpreg *final)
+float2mem_integer (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldf.fill f6=3D[%0];; stf8 [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static inline void=20
-float2mem_single(struct ia64_fpreg *init, struct ia64_fpreg *final)
+float2mem_single (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldf.fill f6=3D[%0];; stfs [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static inline void=20
-float2mem_double(struct ia64_fpreg *init, struct ia64_fpreg *final)
+float2mem_double (struct ia64_fpreg *init, struct ia64_fpreg *final)
 {
 	__asm__ __volatile__ ("ldf.fill f6=3D[%0];; stfd [%1]=F6"
 			      :: "r"(init), "r"(final) : "f6","memory");
 }
=20
 static int
-emulate_load_floatpair(unsigned long ifa, load_store_t *ld, struct pt_regs=
 *regs)
+emulate_load_floatpair (unsigned long ifa, load_store_t ld, struct pt_regs=
 *regs)
 {
 	struct ia64_fpreg fpr_init[2];
 	struct ia64_fpreg fpr_final[2];
-	unsigned long len =3D float_fsz[ld->x6_sz];
+	unsigned long len =3D float_fsz[ld.x6_sz];
=20
-	if (access_ok(VERIFY_READ, (void *)ifa, len<<1) < 0) {
-		DPRINT(("verify area failed on %lx\n", ifa));
-		return -1;
-	}
 	/*
 	 * fr0 & fr1 don't need to be checked because Illegal Instruction
 	 * faults have higher priority than unaligned faults.
@@ -1025,35 +987,27 @@
 	/*=20
 	 * make sure we get clean buffers
 	 */
-	memset(&fpr_init,0, sizeof(fpr_init));
-	memset(&fpr_final,0, sizeof(fpr_final));
+	memset(&fpr_init, 0, sizeof(fpr_init));
+	memset(&fpr_final, 0, sizeof(fpr_final));
=20
 	/*
 	 * ldfpX.a: we don't try to emulate anything but we must
 	 * invalidate the ALAT entry and execute updates, if any.
 	 */
-	if (ld->x6_op !=3D 0x2) {
-		/*
-		 * does the unaligned access
-		 */
-		memcpy(&fpr_init[0], (void *)ifa, len);
-		memcpy(&fpr_init[1], (void *)(ifa+len), len);
+	if (ld.x6_op !=3D 0x2) {
+		/* this assumes little-endian byte-order: */
=20
-		DPRINT(("ld.r1=3D%d ld.imm=3D%d x6_sz=3D%d\n", ld->r1, ld->imm, ld->x6_s=
z));
-#ifdef DEBUG_UNALIGNED_TRAP
-		{ int i; char *c =3D (char *)&fpr_init;
-			printk("fpr_init=3D ");
-			for(i=3D0; i < len<<1; i++ ) {
-				printk("%02x ", c[i]&0xff);
-			}
-			printk("\n");
-		}
-#endif
+		if (copy_from_user(&fpr_init[0], (void *) ifa, len)
+		    || copy_from_user(&fpr_init[1], (void *) (ifa + len), len))
+			return -1;
+
+		DPRINT("ld.r1=3D%d ld.imm=3D%d x6_sz=3D%d\n", ld.r1, ld.imm, ld.x6_sz);
+		DDUMP("frp_init =3D", &fpr_init, 2*len);
 		/*
 		 * XXX fixme
 		 * Could optimize inlines by using ldfpX & 2 spills=20
 		 */
-		switch( ld->x6_sz ) {
+		switch( ld.x6_sz ) {
 			case 0:
 				mem2float_extended(&fpr_init[0], &fpr_final[0]);
 				mem2float_extended(&fpr_init[1], &fpr_final[1]);
@@ -1071,15 +1025,7 @@
 				mem2float_double(&fpr_init[1], &fpr_final[1]);
 				break;
 		}
-#ifdef DEBUG_UNALIGNED_TRAP
-		{ int i; char *c =3D (char *)&fpr_final;
-			printk("fpr_final=3D ");
-			for(i=3D0; i < len<<1; i++ ) {
-				printk("%02x ", c[i]&0xff);
-			}
-			printk("\n");
-		}
-#endif
+		DDUMP("fpr_final =3D", &fpr_final, 2*len);
 		/*
 		 * XXX fixme
 		 *
@@ -1087,16 +1033,15 @@
 		 * use the storage from the saved context i.e., the actual final
 		 * destination (pt_regs, switch_stack or thread structure).
 		 */
-		setfpreg(ld->r1, &fpr_final[0], regs);
-		setfpreg(ld->imm, &fpr_final[1], regs);
+		setfpreg(ld.r1, &fpr_final[0], regs);
+		setfpreg(ld.imm, &fpr_final[1], regs);
 	}
=20
 	/*
 	 * Check for updates: only immediate updates are available for this
 	 * instruction.
 	 */
-	if (ld->m) {
-
+	if (ld.m) {
 		/*
 		 * the immediate is implicit given the ldsz of the operation:
 		 * single: 8 (2x4) and for  all others it's 16 (2x8)
@@ -1109,43 +1054,32 @@
 		 * as long as we don't come here with a ldfpX.s.
 		 * For this reason we keep this sanity check
 		 */
-		if (ld->x6_op =3D 1 || ld->x6_op =3D 3) {
-			printk(KERN_ERR "%s: register update on speculative load pair, error\n",
-			       __FUNCTION__);=09
-		}
-
+		if (ld.x6_op =3D 1 || ld.x6_op =3D 3)
+			printk(KERN_ERR __FUNCTION__": register update on speculative load pair=
, "
+			       "error\n");=09
=20
-		setreg(ld->r3, ifa, 0, regs);
+		setreg(ld.r3, ifa, 0, regs);
 	}
=20
 	/*
 	 * Invalidate ALAT entries, if any, for both registers.
 	 */
-	if (ld->x6_op =3D 0x2) {
-		invala_fr(ld->r1);
-		invala_fr(ld->imm);
+	if (ld.x6_op =3D 0x2) {
+		invala_fr(ld.r1);
+		invala_fr(ld.imm);
 	}
 	return 0;
 }
=20
=20
 static int
-emulate_load_float(unsigned long ifa, load_store_t *ld, struct pt_regs *re=
gs)
+emulate_load_float (unsigned long ifa, load_store_t ld, struct pt_regs *re=
gs)
 {
 	struct ia64_fpreg fpr_init;
 	struct ia64_fpreg fpr_final;
-	unsigned long len =3D float_fsz[ld->x6_sz];
+	unsigned long len =3D float_fsz[ld.x6_sz];
=20
 	/*
-	 * check for load pair because our masking scheme is not fine grain enough
-	if (ld->x =3D 1) return emulate_load_floatpair(ifa,ld,regs);
-	 */
-
-	if (access_ok(VERIFY_READ, (void *)ifa, len) < 0) {
-		DPRINT(("verify area failed on %lx\n", ifa));
-		return -1;
-	}
-	/*
 	 * fr0 & fr1 don't need to be checked because Illegal Instruction
 	 * faults have higher priority than unaligned faults.
 	 *
@@ -1153,7 +1087,6 @@
 	 * unaligned reference.
 	 */
=20
-
 	/*=20
 	 * make sure we get clean buffers
 	 */
@@ -1165,27 +1098,16 @@
 	 * invalidate the ALAT entry.
 	 * See comments in ldX for descriptions on how the various loads are hand=
led.
 	 */
-	if (ld->x6_op !=3D 0x2) {
-
-		/*
-		 * does the unaligned access
-		 */
-		memcpy(&fpr_init, (void *)ifa, len);
+	if (ld.x6_op !=3D 0x2) {
+		if (copy_from_user(&fpr_init, (void *) ifa, len))
+			return -1;
=20
-		DPRINT(("ld.r1=3D%d x6_sz=3D%d\n", ld->r1, ld->x6_sz));
-#ifdef DEBUG_UNALIGNED_TRAP
-		{ int i; char *c =3D (char *)&fpr_init;
-			printk("fpr_init=3D ");
-			for(i=3D0; i < len; i++ ) {
-				printk("%02x ", c[i]&0xff);
-			}
-			printk("\n");
-		}
-#endif
+		DPRINT("ld.r1=3D%d x6_sz=3D%d\n", ld.r1, ld.x6_sz);
+		DDUMP("fpr_init =3D", &fpr_init, len);
 		/*
 		 * we only do something for x6_op=3D{0,8,9}
 		 */
-		switch( ld->x6_sz ) {
+		switch( ld.x6_sz ) {
 			case 0:
 				mem2float_extended(&fpr_init, &fpr_final);
 				break;
@@ -1199,15 +1121,7 @@
 				mem2float_double(&fpr_init, &fpr_final);
 				break;
 		}
-#ifdef DEBUG_UNALIGNED_TRAP
-		{ int i; char *c =3D (char *)&fpr_final;
-			printk("fpr_final=3D ");
-			for(i=3D0; i < len; i++ ) {
-				printk("%02x ", c[i]&0xff);
-			}
-			printk("\n");
-		}
-#endif
+		DDUMP("fpr_final =3D", &fpr_final, len);
 		/*
 		 * XXX fixme
 		 *
@@ -1215,66 +1129,51 @@
 		 * use the storage from the saved context i.e., the actual final
 		 * destination (pt_regs, switch_stack or thread structure).
 		 */
-		setfpreg(ld->r1, &fpr_final, regs);
+		setfpreg(ld.r1, &fpr_final, regs);
 	}
=20
 	/*
 	 * check for updates on any loads
 	 */
-	if (ld->op =3D 0x7 || ld->m)
-		emulate_load_updates(ld->op =3D 0x7 ? UPD_IMMEDIATE: UPD_REG, ld, regs, =
ifa);
+	if (ld.op =3D 0x7 || ld.m)
+		emulate_load_updates(ld.op =3D 0x7 ? UPD_IMMEDIATE: UPD_REG, ld, regs, i=
fa);
=20
 	/*
 	 * invalidate ALAT entry in case of advanced floating point loads
 	 */
-	if (ld->x6_op =3D 0x2)
-		invala_fr(ld->r1);
+	if (ld.x6_op =3D 0x2)
+		invala_fr(ld.r1);
=20
 	return 0;
 }
=20
=20
 static int
-emulate_store_float(unsigned long ifa, load_store_t *ld, struct pt_regs *r=
egs)
+emulate_store_float (unsigned long ifa, load_store_t ld, struct pt_regs *r=
egs)
 {
 	struct ia64_fpreg fpr_init;
 	struct ia64_fpreg fpr_final;
-	unsigned long len =3D float_fsz[ld->x6_sz];
+	unsigned long len =3D float_fsz[ld.x6_sz];
 =09
-	/*
-	 * the macro supposes sequential access (which is the case)
-	 * if the first byte is an invalid address we return here. Otherwise
-	 * there is a guard page at the top of the user's address page and=20
-	 * the first access would generate a NaT consumption fault and return
-	 * with a SIGSEGV, which is what we want.
-	 *
-	 * Note: the first argument is ignored=20
-	 */
-	if (access_ok(VERIFY_WRITE, (void *)ifa, len) < 0) {
-		DPRINT(("verify area failed on %lx\n",ifa));
-		return -1;
-	}
-
 	/*=20
 	 * make sure we get clean buffers
 	 */
 	memset(&fpr_init,0, sizeof(fpr_init));
 	memset(&fpr_final,0, sizeof(fpr_final));
=20
-
 	/*
 	 * if we get to this handler, Nat bits on both r3 and r2 have already
 	 * been checked. so we don't need to do it
 	 *
 	 * extract the value to be stored
 	 */
-	getfpreg(ld->imm, &fpr_init, regs);
+	getfpreg(ld.imm, &fpr_init, regs);
 	/*
 	 * during this step, we extract the spilled registers from the saved
 	 * context i.e., we refill. Then we store (no spill) to temporary
 	 * aligned location
 	 */
-	switch( ld->x6_sz ) {
+	switch( ld.x6_sz ) {
 		case 0:
 			float2mem_extended(&fpr_init, &fpr_final);
 			break;
@@ -1288,56 +1187,40 @@
 			float2mem_double(&fpr_init, &fpr_final);
 			break;
 	}
-	DPRINT(("ld.r1=3D%d x6_sz=3D%d\n", ld->r1, ld->x6_sz));
-#ifdef DEBUG_UNALIGNED_TRAP
-		{ int i; char *c =3D (char *)&fpr_init;
-			printk("fpr_init=3D ");
-			for(i=3D0; i < len; i++ ) {
-				printk("%02x ", c[i]&0xff);
-			}
-			printk("\n");
-		}
-		{ int i; char *c =3D (char *)&fpr_final;
-			printk("fpr_final=3D ");
-			for(i=3D0; i < len; i++ ) {
-				printk("%02x ", c[i]&0xff);
-			}
-			printk("\n");
-		}
-#endif
+	DPRINT("ld.r1=3D%d x6_sz=3D%d\n", ld.r1, ld.x6_sz);
+	DDUMP("fpr_init =3D", &fpr_init, len);
+	DDUMP("fpr_final =3D", &fpr_final, len);
=20
-	/*
-	 * does the unaligned store
-	 */
-	memcpy((void *)ifa, &fpr_final, len);
+	if (copy_to_user((void *) ifa, &fpr_final, len))
+		return -1;
=20
 	/*
 	 * stfX [r3]=3Dr2,imm(9)
 	 *
 	 * NOTE:
-	 * ld->r3 can never be r0, because r0 would not generate an=20
+	 * ld.r3 can never be r0, because r0 would not generate an=20
 	 * unaligned access.
 	 */
-	if (ld->op =3D 0x7) {
+	if (ld.op =3D 0x7) {
 		unsigned long imm;
=20
 		/*
 		 * form imm9: [12:6] contain first 7bits
 		 */
-		imm =3D ld->x << 7 | ld->r1;
+		imm =3D ld.x << 7 | ld.r1;
 		/*
 		 * sign extend (8bits) if m set
 		 */
-		if (ld->m)
+		if (ld.m)
 			imm |=3D SIGN_EXT9;=20
 		/*
 		 * ifa =3D r3 (NaT is necessarily cleared)
 		 */
 		ifa +=3D imm;
=20
-		DPRINT(("imm=3D%lx r3=3D%lx\n", imm, ifa));
+		DPRINT("imm=3D%lx r3=3D%lx\n", imm, ifa);
 =09
-		setreg(ld->r3, ifa, 0, regs);
+		setreg(ld.r3, ifa, 0, regs);
 	}
 	/*
 	 * we don't have alat_invalidate_multiple() so we need
@@ -1348,129 +1231,96 @@
 	return 0;
 }
=20
-void
-ia64_handle_unaligned(unsigned long ifa, struct pt_regs *regs)
+/*
+ * Make sure we log the unaligned access, so that user/sysadmin can notice=
 it and
+ * eventually fix the program.  However, we don't want to do that for ever=
y access so we
+ * pace it with jiffies.  This isn't really MP-safe, but it doesn't really=
 have to be
+ * either...
+ */
+static int
+within_logging_rate_limit (void)
 {
-	static unsigned long unalign_count;
-	static long last_time;
+	static unsigned long count, last_time;
+
+	if (count > 5 && jiffies - last_time > 5*HZ)
+		count =3D 0;
+	if (++count < 5) {
+		last_time =3D jiffies;
+		return 1;
+	}
+	return 0;
=20
+}
+
+void
+ia64_handle_unaligned (unsigned long ifa, struct pt_regs *regs)
+{
+	const struct exception_table_entry *fix =3D NULL;
 	struct ia64_psr *ipsr =3D ia64_psr(regs);
-	unsigned long *bundle_addr;
+	mm_segment_t old_fs =3D get_fs();
+	unsigned long bundle[2];
 	unsigned long opcode;
-	unsigned long op;
-	load_store_t *insn;
+	struct siginfo si;
+	union {
+		unsigned long l;
+		load_store_t insn;
+	} u;
 	int ret =3D -1;
=20
-	/*
-	 * Unaligned references in the kernel could come from unaligned
-	 *   arguments to system calls.  We fault the user process in
-	 *   these cases and panic the kernel otherwise (the kernel should
-	 *   be fixed to not make unaligned accesses).
-	 */
-	if (!user_mode(regs)) {
-		const struct exception_table_entry *fix;
-
-		fix =3D search_exception_table(regs->cr_iip);
-		if (fix) {
-			regs->r8 =3D -EFAULT;
-			if (fix->skip & 1) {
-				regs->r9 =3D 0;
-			}
-			regs->cr_iip +=3D ((long) fix->skip) & ~15;
-			regs->cr_ipsr &=3D ~IA64_PSR_RI;	/* clear exception slot number */
-			return;
-		}
-		die_if_kernel("Unaligned reference while in kernel\n", regs, 30);
-		/* NOT_REACHED */
-	}
-	/*
-	 * For now, we don't support user processes running big-endian
-	 * which do unaligned accesses
-	 */
 	if (ia64_psr(regs)->be) {
-		struct siginfo si;
-
-		printk(KERN_ERR "%s(%d): big-endian unaligned access %016lx (ip=3D%016lx=
) not "
-		       "yet supported\n",
-		       current->comm, current->pid, ifa, regs->cr_iip + ipsr->ri);
-
-		si.si_signo =3D SIGBUS;
-		si.si_errno =3D 0;
-		si.si_code =3D BUS_ADRALN;
-		si.si_addr =3D (void *) ifa;
-		force_sig_info(SIGBUS, &si, current);
-		return;
+		/* we don't support big-endian accesses */
+		die_if_kernel("big-endian unaligned accesses are not supported", regs, 0=
);
+		goto force_sigbus;
 	}
=20
-	if (current->thread.flags & IA64_THREAD_UAC_SIGBUS) {
-		struct siginfo si;
-
-		si.si_signo =3D SIGBUS;
-		si.si_errno =3D 0;
-		si.si_code =3D BUS_ADRALN;
-		si.si_addr =3D (void *) ifa;
-		force_sig_info(SIGBUS, &si, current);
-		return;
-	}
+	/*
+	 * Treat kernel accesses for which there is an exception handler entry th=
e same as
+	 * user-level unaligned accesses.  Otherwise, a clever program could user=
 could
+	 * trick this handler into reading an arbitrary kernel addresses...
+	 */
+	if (user_mode(regs) || (fix =3D search_exception_table(regs->cr_iip))) {
+		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) !=3D 0)
+			goto force_sigbus;
=20
-	if (!(current->thread.flags & IA64_THREAD_UAC_NOPRINT)) {
-		/*
-		 * Make sure we log the unaligned access, so that
-		 * user/sysadmin can notice it and eventually fix the
-		 * program.
-		 *
-		 * We don't want to do that for every access so we
-		 * pace it with jiffies.
-		 */
-		if (unalign_count > 5 && jiffies - last_time > 5*HZ)
-			unalign_count =3D 0;
-		if (++unalign_count < 5) {
+		if (!(current->thread.flags & IA64_THREAD_UAC_NOPRINT)
+		    && within_logging_rate_limit())
+		{
 			char buf[200];	/* comm[] is at most 16 bytes... */
 			size_t len;
=20
-			last_time =3D jiffies;
-			len =3D sprintf(buf, "%s(%d): unaligned access to 0x%016lx, ip=3D0x%016=
lx\n\r",
-				      current->comm, current->pid, ifa, regs->cr_iip + ipsr->ri);
+			len =3D sprintf(buf, "%s(%d): unaligned access to 0x%016lx, "
+				      "ip=3D0x%016lx\n\r", current->comm, current->pid,
+				      ifa, regs->cr_iip + ipsr->ri);
 			tty_write_message(current->tty, buf);
 			buf[len-1] =3D '\0';	/* drop '\r' */
-			printk("%s", buf);	/* guard against command names containing %s!! */
+			printk("%s", buf);	/* watch for command names containing %s */
 		}
+	} else {
+		if (within_logging_rate_limit())
+			printk("kernel unaligned access to 0x%016lx, ip=3D0x%016lx\n",
+			       ifa, regs->cr_iip + ipsr->ri);
+		set_fs(KERNEL_DS);
 	}
=20
-	DPRINT(("iip=3D%lx ifa=3D%lx isr=3D%lx\n", regs->cr_iip, ifa, regs->cr_ip=
sr));
-	DPRINT(("ISR.ei=3D%d ISR.sp=3D%d\n", ipsr->ri, ipsr->it));
+	DPRINT("iip=3D%lx ifa=3D%lx isr=3D%lx (ei=3D%d, sp=3D%d)\n",
+	       regs->cr_iip, ifa, regs->cr_ipsr, ipsr->ri, ipsr->it);
=20
-	bundle_addr =3D (unsigned long *)(regs->cr_iip);
+	if (__copy_from_user(bundle, (void *) regs->cr_iip, 16))
+		goto failure;
=20
 	/*
 	 * extract the instruction from the bundle given the slot number
 	 */
-	switch ( ipsr->ri ) {
-		case 0: op =3D *bundle_addr >> 5;
-			break;
-
-		case 1: op =3D *bundle_addr >> 46 | (*(bundle_addr+1) & 0x7fffff)<<18;
-			break;
-
-		case 2: op =3D *(bundle_addr+1) >> 23;
-		 	break;
-	}
-
-	insn   =3D (load_store_t *)&op;
-	opcode =3D op & IA64_OPCODE_MASK;
-
-	DPRINT(("opcode=3D%lx ld.qp=3D%d ld.r1=3D%d ld.imm=3D%d ld.r3=3D%d ld.x=
=3D%d ld.hint=3D%d "
-		"ld.x6=3D0x%x ld.m=3D%d ld.op=3D%d\n",
-		opcode,
-		insn->qp,
-		insn->r1,
-		insn->imm,
-		insn->r3,
-		insn->x,
-		insn->hint,
-		insn->x6_sz,
-		insn->m,
-		insn->op));
+	switch (ipsr->ri) {
+	      case 0: u.l =3D (bundle[0] >>  5); break;
+	      case 1: u.l =3D (bundle[0] >> 46) | (bundle[1] << 18); break;
+	      case 2: u.l =3D (bundle[1] >> 23); break;
+	}
+	opcode =3D (u.l >> IA64_OPCODE_SHIFT) & IA64_OPCODE_MASK;
+
+	DPRINT("opcode=3D%lx ld.qp=3D%d ld.r1=3D%d ld.imm=3D%d ld.r3=3D%d ld.x=3D=
%d ld.hint=3D%d "
+	       "ld.x6=3D0x%x ld.m=3D%d ld.op=3D%d\n", opcode, u.insn.qp, u.insn.r=
1, u.insn.imm,
+	       u.insn.r3, u.insn.x, u.insn.hint, u.insn.x6_sz, u.insn.m, u.insn.o=
p);
=20
 	/*
   	 * IMPORTANT:
@@ -1502,85 +1352,109 @@
 	 * I would like to get rid of this switch case and do something
 	 * more elegant.
 	 */
-	switch(opcode) {
-		case LDS_OP:
-		case LDSA_OP:
-		case LDS_IMM_OP:
-		case LDSA_IMM_OP:
-		case LDFS_OP:
-		case LDFSA_OP:
-		case LDFS_IMM_OP:
-			/*
-			 * The instruction will be retried with defered exceptions
-			 * turned on, and we should get Nat bit installed
-			 *
-			 * IMPORTANT:
-			 * When PSR_ED is set, the register & immediate update
-			 * forms are actually executed even though the operation
-			 * failed. So we don't need to take care of this.
-			 */
-			DPRINT(("forcing PSR_ED\n"));
-			regs->cr_ipsr |=3D IA64_PSR_ED;
-			return;
-
-		case LD_OP:
-		case LDA_OP:
-		case LDBIAS_OP:
-		case LDACQ_OP:
-		case LDCCLR_OP:
-		case LDCNC_OP:
-		case LDCCLRACQ_OP:
-		case LD_IMM_OP:
-		case LDA_IMM_OP:
-		case LDBIAS_IMM_OP:
-		case LDACQ_IMM_OP:
-		case LDCCLR_IMM_OP:
-		case LDCNC_IMM_OP:
-		case LDCCLRACQ_IMM_OP:
-			ret =3D emulate_load_int(ifa, insn, regs);
-			break;
-		case ST_OP:
-		case STREL_OP:
-		case ST_IMM_OP:
-		case STREL_IMM_OP:
-			ret =3D emulate_store_int(ifa, insn, regs);
-			break;
-		case LDF_OP:
-		case LDFA_OP:
-		case LDFCCLR_OP:
-		case LDFCNC_OP:
-		case LDF_IMM_OP:
-		case LDFA_IMM_OP:
-		case LDFCCLR_IMM_OP:
-		case LDFCNC_IMM_OP:
-			ret =3D insn->x ?=20
-			      emulate_load_floatpair(ifa, insn, regs):
-			      emulate_load_float(ifa, insn, regs);
-			break;
-		case STF_OP:
-		case STF_IMM_OP:
-			ret =3D emulate_store_float(ifa, insn, regs);
-	}
-
-	DPRINT(("ret=3D%d\n", ret));
-	if (ret) {
-		struct siginfo si;
-
-		si.si_signo =3D SIGBUS;
-		si.si_errno =3D 0;
-		si.si_code =3D BUS_ADRALN;
-		si.si_addr =3D (void *) ifa;
-	        force_sig_info(SIGBUS, &si, current);
-	} else {
+	switch (opcode) {
+	      case LDS_OP:
+	      case LDSA_OP:
+	      case LDS_IMM_OP:
+	      case LDSA_IMM_OP:
+	      case LDFS_OP:
+	      case LDFSA_OP:
+	      case LDFS_IMM_OP:
 		/*
-	 	 * given today's architecture this case is not likely to happen
-	 	 * because a memory access instruction (M) can never be in the=20
-	 	 * last slot of a bundle. But let's keep it for  now.
-	 	 */
-		if (ipsr->ri =3D 2)
-			regs->cr_iip +=3D 16;
-		ipsr->ri =3D ++ipsr->ri & 3;
-	}
+		 * The instruction will be retried with deferred exceptions turned on, a=
nd
+		 * we should get Nat bit installed
+		 *
+		 * IMPORTANT: When PSR_ED is set, the register & immediate update forms
+		 * are actually executed even though the operation failed. So we don't
+		 * need to take care of this.
+		 */
+		DPRINT("forcing PSR_ED\n");
+		regs->cr_ipsr |=3D IA64_PSR_ED;
+		goto done;
+
+	      case LD_OP:
+	      case LDA_OP:
+	      case LDBIAS_OP:
+	      case LDACQ_OP:
+	      case LDCCLR_OP:
+	      case LDCNC_OP:
+	      case LDCCLRACQ_OP:
+	      case LD_IMM_OP:
+	      case LDA_IMM_OP:
+	      case LDBIAS_IMM_OP:
+	      case LDACQ_IMM_OP:
+	      case LDCCLR_IMM_OP:
+	      case LDCNC_IMM_OP:
+	      case LDCCLRACQ_IMM_OP:
+		ret =3D emulate_load_int(ifa, u.insn, regs);
+		break;
+
+	      case ST_OP:
+	      case STREL_OP:
+	      case ST_IMM_OP:
+	      case STREL_IMM_OP:
+		ret =3D emulate_store_int(ifa, u.insn, regs);
+		break;
+
+	      case LDF_OP:
+	      case LDFA_OP:
+	      case LDFCCLR_OP:
+	      case LDFCNC_OP:
+	      case LDF_IMM_OP:
+	      case LDFA_IMM_OP:
+	      case LDFCCLR_IMM_OP:
+	      case LDFCNC_IMM_OP:
+		if (u.insn.x)
+			ret =3D emulate_load_floatpair(ifa, u.insn, regs);
+		else
+			ret =3D emulate_load_float(ifa, u.insn, regs);
+		break;
+
+	      case STF_OP:
+	      case STF_IMM_OP:
+		ret =3D emulate_store_float(ifa, u.insn, regs);
+		break;
+
+	      default:
+		goto failure;
+	}
+	DPRINT("ret=3D%d\n", ret);
+	if (ret)
+		goto failure;
+
+	if (ipsr->ri =3D 2)
+		/*
+		 * given today's architecture this case is not likely to happen because a
+		 * memory access instruction (M) can never be in the last slot of a
+		 * bundle. But let's keep it for now.
+		 */
+		regs->cr_iip +=3D 16;
+	ipsr->ri =3D (ipsr->ri + 1) & 0x3;
+
+	DPRINT("ipsr->ri=3D%d iip=3D%lx\n", ipsr->ri, regs->cr_iip);
+  done:
+	set_fs(old_fs);		/* restore original address limit */
+	return;
=20
-	DPRINT(("ipsr->ri=3D%d iip=3D%lx\n", ipsr->ri, regs->cr_iip));
+  failure:
+	/* something went wrong... */
+	if (!user_mode(regs)) {
+		if (fix) {
+			regs->r8 =3D -EFAULT;
+			if (fix->skip & 1)
+				regs->r9 =3D 0;
+			regs->cr_iip +=3D ((long) fix->skip) & ~15;
+			regs->cr_ipsr &=3D ~IA64_PSR_RI;	/* clear exception slot number */
+			goto done;
+		}
+		die_if_kernel("error during unaligned kernel access\n", regs, ret);
+		/* NOT_REACHED */
+	}
+  force_sigbus:
+	si.si_signo =3D SIGBUS;
+	si.si_errno =3D 0;
+	si.si_code =3D BUS_ADRALN;
+	si.si_addr =3D (void *) ifa;
+	force_sig_info(SIGBUS, &si, current);
+	goto done;
 }
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-lia/arch/ia64/=
kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/kernel/unwind.c	Thu Jan 25 17:22:06 2001
@@ -306,7 +306,7 @@
 		}
 	} else {
 		/* access a stacked register */
-		addr =3D ia64_rse_skip_regs((unsigned long *) info->bsp, regnum);
+		addr =3D ia64_rse_skip_regs((unsigned long *) info->bsp, regnum - 32);
 		nat_addr =3D ia64_rse_rnat_addr(addr);
 		if ((unsigned long) addr < info->regstk.limit
 		    || (unsigned long) addr >=3D info->regstk.top)
diff -urN linux-davidm/arch/ia64/lib/copy_user.S linux-2.4.0-lia/arch/ia64/=
lib/copy_user.S
--- linux-davidm/arch/ia64/lib/copy_user.S	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/lib/copy_user.S	Thu Jan 25 17:22:15 2001
@@ -319,6 +319,7 @@
 	EX(failure_out,(EPI) st1 [dst1]=3Dval1[PIPE_DEPTH-1],1)
 	br.ctop.dptk.few 5b
 	;;
+	mov ar.lc=3Dsaved_lc
 	mov pr=3Dsaved_pr,0xffffffffffff0000
 	mov ar.pfs=3Dsaved_pfs
 	br.ret.dptk.few rp
diff -urN linux-davidm/arch/ia64/lib/swiotlb.c linux-2.4.0-lia/arch/ia64/li=
b/swiotlb.c
--- linux-davidm/arch/ia64/lib/swiotlb.c	Thu Jan 25 19:17:25 2001
+++ linux-2.4.0-lia/arch/ia64/lib/swiotlb.c	Thu Jan 25 17:22:25 2001
@@ -10,8 +10,6 @@
  *			unnecessary i-cache flushing.
  */
=20
-#include <linux/config.h>
-
 #include <linux/mm.h>
 #include <linux/module.h>
 #include <linux/pci.h>
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-lia/arch/ia64/mm/ini=
t.c
--- linux-davidm/arch/ia64/mm/init.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/mm/init.c	Thu Jan 25 17:22:35 2001
@@ -23,6 +23,7 @@
 #include <asm/pgalloc.h>
 #include <asm/sal.h>
 #include <asm/system.h>
+#include <asm/uaccess.h>
=20
 /* References to section boundaries: */
 extern char _stext, _etext, _edata, __init_begin, __init_end;
@@ -37,6 +38,8 @@
=20
 extern void ia64_tlb_init (void);
=20
+unsigned long MAX_DMA_ADDRESS =3D PAGE_OFFSET + 0x100000000UL;
+
 static unsigned long totalram_pages;
=20
 /*
@@ -356,7 +359,7 @@
 #	define vmlpt_bits		(impl_va_bits - PAGE_SHIFT + pte_bits)
 #	define POW2(n)			(1ULL << (n))
=20
-	impl_va_bits =3D ffz(~my_cpu_data.unimpl_va_mask);
+	impl_va_bits =3D ffz(~(my_cpu_data.unimpl_va_mask | (7UL << 61)));
=20
 	if (impl_va_bits < 51 || impl_va_bits > 61)
 		panic("CPU has bogus IMPL_VA_MSB value of %lu!\n", impl_va_bits - 1);
@@ -390,7 +393,7 @@
=20
 	memset(zones_size, 0, sizeof(zones_size));
=20
-	max_dma =3D (PAGE_ALIGN(MAX_DMA_ADDRESS) >> PAGE_SHIFT);
+	max_dma =3D virt_to_phys(MAX_DMA_ADDRESS) >> PAGE_SHIFT;
 	if (max_low_pfn < max_dma)
 		zones_size[ZONE_DMA] =3D max_low_pfn;
 	else {
diff -urN linux-davidm/arch/ia64/sn/fprom/fw-emu.c linux-2.4.0-lia/arch/ia6=
4/sn/fprom/fw-emu.c
--- linux-davidm/arch/ia64/sn/fprom/fw-emu.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.0-lia/arch/ia64/sn/fprom/fw-emu.c	Wed Dec 13 18:59:33 2000
@@ -8,6 +8,8 @@
  * Copyright (C) 2000 Silicon Graphics, Inc.
  * Copyright (C) 2000 by Jack Steiner (steiner@sgi.com)
  */
+#include <linux/config.h>
+
 #include <asm/efi.h>
 #include <asm/pal.h>
 #include <asm/sal.h>
diff -urN linux-davidm/drivers/char/mem.c linux-2.4.0-lia/drivers/char/mem.c
--- linux-davidm/drivers/char/mem.c	Thu Jan 25 19:17:25 2001
+++ linux-2.4.0-lia/drivers/char/mem.c	Thu Jan 25 17:43:34 2001
@@ -484,13 +484,13 @@
 	switch (orig) {
 		case 0:
 			file->f_pos =3D offset;
-			return file->f_pos;
 		case 1:
 			file->f_pos +=3D offset;
-			return file->f_pos;
 		default:
 			return -EINVAL;
 	}
+	force_successful_syscall_return();
+	return file->f_pos;
 }
=20
 static int open_port(struct inode * inode, struct file * filp)
diff -urN linux-davidm/drivers/scsi/qla1280.c linux-2.4.0-lia/drivers/scsi/=
qla1280.c
--- linux-davidm/drivers/scsi/qla1280.c	Thu Jan 25 19:17:26 2001
+++ linux-2.4.0-lia/drivers/scsi/qla1280.c	Thu Jan 25 17:43:56 2001
@@ -16,9 +16,23 @@
 * General Public License for more details.
 **
 **************************************************************************=
****/
-#define QLA1280_VERSION      "3.21 Beta"
+#define QLA1280_VERSION      "3.23 Beta"
 /*************************************************************************=
***
     Revision History:
+    Rev  3.23 Beta January 11, 2001 BN Qlogic
+        - Added check of device_id when handling non=20
+          QLA12160s during detect().
+    Rev  3.22 Beta January 5, 2001 BN Qlogic
+        - Changed queue_task() to schedule_task()
+          for kernels 2.4.0 and higher.=20
+          Note: 2.4.0-testxx kernels released prior to
+                the actual 2.4.0 kernel release on January 2001
+                will get compile/link errors with schedule_task().
+                Please update your kernel to released 2.4.0 level,
+                or comment lines in this file flagged with  3.22=20
+                to resolve compile/link error of schedule_task().
+        - Added -DCONFIG_SMP in addition to -D__SMP__=20
+          in Makefile for 2.4.0 builds of driver as module.
     Rev  3.21 Beta January 4, 2001 BN Qlogic
         - Changed criteria of 64/32 Bit mode of HBA
           operation according to BITS_PER_LONG rather
@@ -521,10 +535,10 @@
   scsi_qla_host_t *ha;
   int    size =3D 0;
   scsi_lu_t  *up;
-    int   len =3D 0;
-    qla_boards_t   *bdp;=20
-    uint32_t        b, t, l;
-
+  int   len =3D 0;
+  qla_boards_t   *bdp;=20
+  uint32_t        b, t, l;
+  uint8_t  *temp;
   host =3D NULL;
=20
     /* Find the host that was specified */
@@ -570,6 +584,10 @@
     /* save the size of our buffer */
   qla1280_buffer_size =3D size;
=20
+  /* 3.20 clear the buffer we use for proc display */
+  temp =3D qla1280_buffer;
+  for (b=3D0 ; b < size; b++)     *(temp+b) =3D 0;=20
+
     /* start building the print buffer */=20
     bdp =3D &QL1280BoardTbl[ha->devnum];
     size =3D  sprintf(PROC_BUF,
@@ -580,7 +598,7 @@
=20
     size =3D sprintf(PROC_BUF, "SCSI Host Adapter Information: %s\n", bdp-=
>bdName);
     len +=3D size;
-    size =3D sprintf(PROC_BUF, "Request Queue =3D 0x%lx, Response Queue =
=3D 0x%lx\n",
+    size =3D sprintf(PROC_BUF, "Request Queue =3D 0x%x, Response Queue =3D=
 0x%x\n",
                         ha->request_dma,
                         ha->response_dma);
     len +=3D size;
@@ -754,21 +772,19 @@
 #endif
=20
         /* 3.20 */
-        /* present the on-board ISP12160 for IA-64 Lion systems
-        first to the OS; to preserve boot drive access in case another
-        QLA12160 is inserted in the PCI slots */
+        /* First Initialize QLA12160 on PCI Bus 1 Dev 2 */
 #if LINUX_VERSION_CODE > KERNEL_VERSION(2,3,18)
         while ((pdev =3D pci_find_subsys(QLA1280_VENDOR_ID,
                                bdp->device_id,  /* QLA12160 first in list =
*/=20
                                PCI_ANY_ID,=20
                                PCI_ANY_ID,pdev))) {
=20
-                /* only interested here on devices on PCI bus=3D1 slot=3D2=
 */
+                /* find QLA12160 device on PCI bus=3D1 slot=3D2 */
                 if ((pdev->bus->number     !=3D 1)   ||
                     (PCI_SLOT(pdev->devfn) !=3D 2))  continue;
=20
                 if (pci_enable_device(pdev)) goto find_devices;
-                printk("qla1x160: Initializing IA-64 ISP12160\n");
+                printk("qla1x160: Initializing ISP12160 on PCI Bus 1, Dev =
2\n");
 		host =3D scsi_register(template, sizeof(scsi_qla_host_t));
 		ha =3D (scsi_qla_host_t *) host->hostdata;
 		/* Clear our data area */
@@ -801,7 +817,7 @@
                 ha->instance =3D num_hosts;
                 if (qla1280_initialize_adapter(ha))
                 {
-                   printk(KERN_INFO "qla1x160: Failed to initialize onboar=
d ISP12160 on IA-64 \n");
+                   printk(KERN_INFO "qla1x160: Failed to initialize QLA121=
60 on PCI Bus 1 Dev 2 \n");
                    qla1280_mem_free(ha);
                    scsi_unregister(host);
                    goto find_devices;
@@ -809,7 +825,7 @@
                 host->max_channel =3D bdp->numPorts-1;=20
 		/* Register our resources with Linux */
 		if( qla1280_register_with_Linux(ha, bdp->numPorts-1) ) {
-		  printk(KERN_INFO "qla1x160: Failed to register resources for onboard I=
SP12160 on IA-64\n");
+		  printk(KERN_INFO "qla1x160: Failed to register resources for QLA12160 =
on PCI Bus 1 Dev 2\n");
 		  qla1280_mem_free(ha);
 		  scsi_unregister(host);
 		  goto find_devices;
@@ -863,9 +879,11 @@
                       continue;
                     }
=20
-		  /* 3.20 skip IA-64 Lion on-board ISP12160 */
+                  /* 3.20 and 3.23 */
+		  /* skip QLA12160 already initialized on PCI Bus 1 Dev 2 */
                   /* since we already initialized and presented it */
-                  if ((pdev->bus->number     =3D 1)   &&
+                  if ((bdp->device_id        =3D QLA12160_DEVICE_ID) &&
+                      (pdev->bus->number     =3D 1)   &&
                       (PCI_SLOT(pdev->devfn) =3D 2))  continue;
=20
  		  printk("qla1x160: Supported Device Found VID=3D%x DID=3D%x SSVID=3D%x=
 SSDID=3D%x\n",
@@ -1165,7 +1183,12 @@
         {
             CMD_RESULT(cmd) =3D (int) (DID_BUS_BUSY << 16);
             qla1280_done_q_put(sp, &ha->done_q_first, &ha->done_q_last);
-            schedule_task(&ha->run_qla_bh);=20
+/* 3.22 */
+#if LINUX_VERSION_CODE < KERNEL_VERSION(2,4,0) /* 3.22 */
+            queue_task(&ha->run_qla_bh,&tq_scheduler);
+#else  /* 3.22 */=20
+            schedule_task(&ha->run_qla_bh); /* 3.22 */
+#endif /* 3.22 */
             ha->flags.dpc_sched =3D TRUE;
             DRIVER_UNLOCK
             return(0);
@@ -1663,7 +1686,7 @@
             ha->run_qla_bh.routine =3D qla1280_do_dpc;=20
=20
              COMTRACE('P')=20
-            schedule_task(&ha->run_qla_bh);=20
+            queue_task_irq(&ha->run_qla_bh,&tq_scheduler);=20
             ha->flags.dpc_sched =3D TRUE;
         }
         clear_bit(QLA1280_IN_ISR_BIT, (int *)&ha->flags);
diff -urN linux-davidm/fs/proc/base.c linux-2.4.0-lia/fs/proc/base.c
--- linux-davidm/fs/proc/base.c	Thu Nov 16 13:18:26 2000
+++ linux-2.4.0-lia/fs/proc/base.c	Thu Jan 25 17:45:12 2001
@@ -395,7 +395,22 @@
 }
 #endif
=20
+static loff_t mem_lseek(struct file * file, loff_t offset, int orig)
+{
+	switch (orig) {
+	      case 0:
+		file->f_pos =3D offset;
+	      case 1:
+		file->f_pos +=3D offset;
+	      default:
+		return -EINVAL;
+	}
+	force_successful_syscall_return();
+	return file->f_pos;
+}
+
 static struct file_operations proc_mem_operations =3D {
+	llseek:		mem_lseek,
 	read:		mem_read,
 	write:		mem_write,
 };
diff -urN linux-davidm/include/asm-ia64/acpikcfg.h linux-2.4.0-lia/include/=
asm-ia64/acpikcfg.h
--- linux-davidm/include/asm-ia64/acpikcfg.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.0-lia/include/asm-ia64/acpikcfg.h	Thu Jan 25 17:47:22 2001
@@ -1,4 +1,5 @@
 #include <linux/config.h>
+
 #ifdef	CONFIG_ACPI_KERNEL_CONFIG
 /*
  *  acpikcfg.h - ACPI based Kernel Configuration Manager External Interfac=
es
diff -urN linux-davidm/include/asm-ia64/bitops.h linux-2.4.0-lia/include/as=
m-ia64/bitops.h
--- linux-davidm/include/asm-ia64/bitops.h	Mon Oct  9 17:54:57 2000
+++ linux-2.4.0-lia/include/asm-ia64/bitops.h	Thu Jan 25 17:51:43 2001
@@ -158,6 +158,7 @@
 	__asm__ ("getf.exp %0=3D%1" : "=3Dr"(exp) : "f"(d));
 	return exp - 0xffff;
 }
+
 /*
  * ffs: find first bit set. This is defined the same way as
  * the libc and compiler builtin ffs routines, therefore
diff -urN linux-davidm/include/asm-ia64/dma.h linux-2.4.0-lia/include/asm-i=
a64/dma.h
--- linux-davidm/include/asm-ia64/dma.h	Thu Jun 22 07:09:45 2000
+++ linux-2.4.0-lia/include/asm-ia64/dma.h	Thu Jan 25 17:51:51 2001
@@ -2,35 +2,20 @@
 #define _ASM_IA64_DMA_H
=20
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/config.h>
-#include <linux/spinlock.h>	/* And spinlocks */
-#include <linux/delay.h>
=20
 #include <asm/io.h>		/* need byte IO */
=20
-#ifdef HAVE_REALLY_SLOW_DMA_CONTROLLER
-#define dma_outb	outb_p
-#else
-#define dma_outb	outb
-#endif
-
-#define dma_inb		inb
-
-#define MAX_DMA_CHANNELS	8
-#define MAX_DMA_ADDRESS		0xffffffffUL
-
-extern spinlock_t  dma_spin_lock;
-
-/* From PCI */
+extern unsigned long MAX_DMA_ADDRESS;
=20
 #ifdef CONFIG_PCI
-extern int isa_dma_bridge_buggy;
+  extern int isa_dma_bridge_buggy;
 #else
-#define isa_dma_bridge_buggy 	(0)
+# define isa_dma_bridge_buggy 	(0)
 #endif
=20
 #endif /* _ASM_IA64_DMA_H */
diff -urN linux-davidm/include/asm-ia64/ia32.h linux-2.4.0-lia/include/asm-=
ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.0-lia/include/asm-ia64/ia32.h	Thu Jan 25 17:52:10 2001
@@ -378,9 +378,10 @@
 	ia64_psr(regs)->ri =3D 0;		/* clear return slot number */		\
 	ia64_psr(regs)->is =3D 1;		/* IA-32 instruction set */		\
 	regs->cr_iip =3D new_ip;							\
-	regs->r12 =3D new_sp;							\
+	regs->ar_rsc =3D 0xc;		/* enforced lazy mode, priv. level 3 */	\
 	regs->ar_rnat =3D 0;							\
 	regs->loadrs =3D 0;							\
+	regs->r12 =3D new_sp;							\
 } while (0)
=20
 extern void ia32_gdt_init (void);
diff -urN linux-davidm/include/asm-ia64/mmu_context.h linux-2.4.0-lia/inclu=
de/asm-ia64/mmu_context.h
--- linux-davidm/include/asm-ia64/mmu_context.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.0-lia/include/asm-ia64/mmu_context.h	Thu Jan 25 17:59:55 2001
@@ -12,21 +12,14 @@
 #include <asm/processor.h>
=20
 /*
- * Routines to manage the allocation of task context numbers.  Task
- * context numbers are used to reduce or eliminate the need to perform
- * TLB flushes due to context switches.  Context numbers are
- * implemented using ia-64 region ids.  Since ia-64 TLBs do not
- * guarantee that the region number is checked when performing a TLB
- * lookup, we need to assign a unique region id to each region in a
- * process.  We use the least significant three bits in a region id
- * for this purpose.  On processors where the region number is checked
- * in TLB lookups, we can get back those two bits by defining
- * CONFIG_IA64_TLB_CHECKS_REGION_NUMBER.  The macro
- * IA64_REGION_ID_BITS gives the number of bits in a region id.  The
- * architecture manual guarantees this number to be in the range
- * 18-24.
+ * Routines to manage the allocation of task context numbers.  Task contex=
t numbers are
+ * used to reduce or eliminate the need to perform TLB flushes due to cont=
ext switches.
+ * Context numbers are implemented using ia-64 region ids.  Since the IA-6=
4 TLB does not
+ * consider the region number when performing a TLB lookup, we need to ass=
ign a unique
+ * region id to each region in a process.  We use the least significant th=
ree bits in a
+ * region id for this purpose.
  *
- * Copyright (C) 1998 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #define IA64_REGION_ID_KERNEL	0 /* the kernel's region id (tlb.c depends o=
n this being 0) */
diff -urN linux-davidm/include/asm-ia64/offsets.h linux-2.4.0-lia/include/a=
sm-ia64/offsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Thu Jan 25 19:17:27 2001
+++ linux-2.4.0-lia/include/asm-ia64/offsets.h	Thu Jan 25 18:00:03 2001
@@ -1,14 +1,17 @@
 #ifndef _ASM_IA64_OFFSETS_H
 #define _ASM_IA64_OFFSETS_H
+
 /*
  * DO NOT MODIFY
  *
- * This file was generated by arch/ia64/tools/print_offsets.awk.
+ * This file was generated by arch/ia64/tools/print_offsets.
  *
  */
-#define PT_PTRACED_BIT		0
-#define PT_TRACESYS_BIT		1
-#define IA64_TASK_SIZE			3408	/* 0xd50 */
+
+#define PT_PTRACED_BIT			0
+#define PT_TRACESYS_BIT			1
+
+#define IA64_TASK_SIZE			3376	/* 0xd30 */
 #define IA64_PT_REGS_SIZE		400	/* 0x190 */
 #define IA64_SWITCH_STACK_SIZE		560	/* 0x230 */
 #define IA64_SIGINFO_SIZE		128	/* 0x80 */
@@ -18,10 +21,9 @@
 #define IA64_TASK_SIGPENDING_OFFSET	16	/* 0x10 */
 #define IA64_TASK_NEED_RESCHED_OFFSET	40	/* 0x28 */
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
-#define IA64_TASK_THREAD_OFFSET		960	/* 0x3c0 */
-#define IA64_TASK_THREAD_KSP_OFFSET	960	/* 0x3c0 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	3256	/* 0xcb8 */
-#define IA64_TASK_PFM_NOTIFY		3152	/* 0xc50 */
+#define IA64_TASK_THREAD_OFFSET		1456	/* 0x5b0 */
+#define IA64_TASK_THREAD_KSP_OFFSET	1456	/* 0x5b0 */
+#define IA64_TASK_THREAD_SIGMASK_OFFSET	3224	/* 0xc98 */
 #define IA64_TASK_PID_OFFSET		196	/* 0xc4 */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
@@ -71,7 +73,7 @@
 #define IA64_PT_REGS_F8_OFFSET		368	/* 0x170 */
 #define IA64_PT_REGS_F9_OFFSET		384	/* 0x180 */
 #define IA64_SWITCH_STACK_CALLER_UNAT_OFFSET 0	/* 0x0 */
-#define IA64_SWITCH_STACK_AR_FPSR_OFFSET 8	/* 0x8 */
+#define IA64_SWITCH_STACK_AR_FPSR_OFFSET	8	/* 0x8 */
 #define IA64_SWITCH_STACK_F2_OFFSET	16	/* 0x10 */
 #define IA64_SWITCH_STACK_F3_OFFSET	32	/* 0x20 */
 #define IA64_SWITCH_STACK_F4_OFFSET	48	/* 0x30 */
@@ -110,8 +112,8 @@
 #define IA64_SWITCH_STACK_B5_OFFSET	504	/* 0x1f8 */
 #define IA64_SWITCH_STACK_AR_PFS_OFFSET	512	/* 0x200 */
 #define IA64_SWITCH_STACK_AR_LC_OFFSET	520	/* 0x208 */
-#define IA64_SWITCH_STACK_AR_UNAT_OFFSET 528	/* 0x210 */
-#define IA64_SWITCH_STACK_AR_RNAT_OFFSET 536	/* 0x218 */
+#define IA64_SWITCH_STACK_AR_UNAT_OFFSET	528	/* 0x210 */
+#define IA64_SWITCH_STACK_AR_RNAT_OFFSET	536	/* 0x218 */
 #define IA64_SWITCH_STACK_AR_BSPSTORE_OFFSET 544	/* 0x220 */
 #define IA64_SWITCH_STACK_PR_OFFSET	552	/* 0x228 */
 #define IA64_SIGCONTEXT_AR_BSP_OFFSET	72	/* 0x48 */
@@ -119,7 +121,7 @@
 #define IA64_SIGCONTEXT_FLAGS_OFFSET	0	/* 0x0 */
 #define IA64_SIGCONTEXT_CFM_OFFSET	48	/* 0x30 */
 #define IA64_SIGCONTEXT_FR6_OFFSET	560	/* 0x230 */
-#define IA64_CLONE_VFORK		16384	/* 0x4000 */
+#define IA64_CLONE_VFORK			16384	/* 0x4000 */
 #define IA64_CLONE_VM			256	/* 0x100 */
=20
 #endif /* _ASM_IA64_OFFSETS_H */
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.0-lia/include/a=
sm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Thu Jan 25 19:17:27 2001
+++ linux-2.4.0-lia/include/asm-ia64/pgtable.h	Thu Jan 25 18:00:19 2001
@@ -8,11 +8,12 @@
  * This hopefully works with any (fixed) IA-64 page-size, as defined
  * in <asm/page.h> (currently 8192).
  *
- * Copyright (C) 1998-2000 Hewlett-Packard Co
- * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/config.h>
+
 #include <asm/mman.h>
 #include <asm/page.h>
 #include <asm/processor.h>
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-lia/include=
/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Thu Jan 25 19:17:27 2001
+++ linux-2.4.0-lia/include/asm-ia64/processor.h	Thu Jan 25 18:00:30 2001
@@ -230,9 +230,12 @@
 #define IA64_USEC_PER_CYC_SHIFT	41
=20
 /*
- * CPU type, hardware bug flags, and per-CPU state.
+ * CPU type, hardware bug flags, and per-CPU state.  Frequently used
+ * state comes earlier:
  */
 struct cpuinfo_ia64 {
+	__u64 itm_delta;	/* # of clock cycles between clock ticks */
+	__u64 itm_next;		/* interval timer mask value to use for next clock tick =
*/
 	__u64 *pgd_quick;
 	__u64 *pmd_quick;
 	__u64 *pte_quick;
@@ -353,10 +356,10 @@
 	ia64_psr(regs)->is =3D 0;		/* IA-64 instruction set */		\
 	regs->cr_iip =3D new_ip;							\
 	regs->ar_rsc =3D 0xf;		/* eager mode, privilege level 3 */	\
-	regs->r12 =3D new_sp - 16;	/* allocate 16 byte scratch area */	\
-	regs->ar_bspstore =3D IA64_RBS_BOT;					\
 	regs->ar_rnat =3D 0;							\
+	regs->ar_bspstore =3D IA64_RBS_BOT;					\
 	regs->loadrs =3D 0;							\
+	regs->r12 =3D new_sp - 16;	/* allocate 16 byte scratch area */	\
 } while (0)
=20
 /* Forward declarations, a strange C thing... */
diff -urN linux-davidm/include/asm-ia64/segment.h linux-2.4.0-lia/include/a=
sm-ia64/segment.h
--- linux-davidm/include/asm-ia64/segment.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-lia/include/asm-ia64/segment.h	Thu Jan 25 18:00:39 2001
@@ -3,4 +3,4 @@
=20
 /* Only here because we have some old header files that expect it.. */
=20
-#endif /* __ALPHA_SEGMENT_H */
+#endif /* _ASM_IA64_SEGMENT_H */
diff -urN linux-davidm/include/asm-ia64/sn/addrs.h linux-2.4.0-lia/include/=
asm-ia64/sn/addrs.h
--- linux-davidm/include/asm-ia64/sn/addrs.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.0-lia/include/asm-ia64/sn/addrs.h	Thu Jan 25 18:00:55 2001
@@ -11,6 +11,7 @@
 #define _ASM_SN_ADDRS_H
=20
 #include <linux/config.h>
+
 #if _LANGUAGE_C
 #include <linux/types.h>
 #endif /* _LANGUAGE_C */
diff -urN linux-davidm/include/asm-ia64/sn/agent.h linux-2.4.0-lia/include/=
asm-ia64/sn/agent.h
--- linux-davidm/include/asm-ia64/sn/agent.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.0-lia/include/asm-ia64/sn/agent.h	Thu Jan 25 18:01:03 2001
@@ -13,6 +13,7 @@
 #define _ASM_SGI_SN_AGENT_H
=20
 #include <linux/config.h>
+
 #include <asm/sn/addrs.h>
 #include <asm/sn/arch.h>
 //#include <asm/sn/io.h>
diff -urN linux-davidm/include/asm-ia64/sn/mmzone_sn1.h linux-2.4.0-lia/inc=
lude/asm-ia64/sn/mmzone_sn1.h
--- linux-davidm/include/asm-ia64/sn/mmzone_sn1.h	Thu Jan  4 22:40:20 2001
+++ linux-2.4.0-lia/include/asm-ia64/sn/mmzone_sn1.h	Thu Jan 25 18:19:46 20=
01
@@ -1,11 +1,11 @@
 #ifndef _ASM_IA64_MMZONE_SN1_H
 #define _ASM_IA64_MMZONE_SN1_H
=20
+#include <linux/config.h>
+
 /*
  * Copyright, 2000, Silicon Graphics, sprasad@engr.sgi.com
  */
-
-#include <linux/config.h>
=20
 /* Maximum configuration supported by SNIA hardware. There are other
  * restrictions that may limit us to a smaller max configuration.
diff -urN linux-davidm/include/asm-ia64/timex.h linux-2.4.0-lia/include/asm=
-ia64/timex.h
--- linux-davidm/include/asm-ia64/timex.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-lia/include/asm-ia64/timex.h	Thu Jan 25 18:21:38 2001
@@ -2,14 +2,15 @@
 #define _ASM_IA64_TIMEX_H
=20
 /*
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2001 Hewlett-Packard Co
+ * Copyright (C) 1998-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ */
+/*
+ * 2001/01/18 davidm	Removed CLOCK_TICK_RATE.  It makes no sense on IA-64.
+ *			Also removed cacheflush_time as it's entirely unused.
  */
-
-#define CLOCK_TICK_RATE		1193180	/* Underlying HZ XXX fix me! */
=20
 typedef unsigned long cycles_t;
-extern cycles_t cacheflush_time;
=20
 static inline cycles_t
 get_cycles (void)
diff -urN linux-davidm/kernel/sched.c linux-2.4.0-lia/kernel/sched.c
--- linux-davidm/kernel/sched.c	Thu Jan  4 22:40:21 2001
+++ linux-2.4.0-lia/kernel/sched.c	Thu Jan 25 18:23:04 2001
@@ -260,7 +260,7 @@
 				target_tsk =3D tsk;
 			}
 		} else {
-			if (oldest_idle =3D -1ULL) {
+			if (oldest_idle =3D (cycles_t) -1) {
 				int prio =3D preemption_goodness(tsk, p, cpu);
=20
 				if (prio > max_prio) {
@@ -272,7 +272,7 @@
 	}
 	tsk =3D target_tsk;
 	if (tsk) {
-		if (oldest_idle !=3D -1ULL) {
+		if (oldest_idle !=3D (cycles_t) -1) {
 			best_cpu =3D tsk->processor;
 			goto send_now_idle;
 		}
diff -urN linux-davidm/mm/memory.c linux-2.4.0-lia/mm/memory.c
--- linux-davidm/mm/memory.c	Thu Jan 25 19:17:27 2001
+++ linux-2.4.0-lia/mm/memory.c	Thu Jan 25 18:23:11 2001
@@ -473,7 +473,7 @@
 				goto out_unlock;
 			}
 		}
-		if (handle_mm_fault(current->mm, vma, ptr, datain) <=3D 0)=20
+		if (handle_mm_fault(current->mm, vma, ptr, datain ? VM_READ : VM_WRITE) =
<=3D 0)
 			goto out_unlock;
 		spin_lock(&mm->page_table_lock);
 		map =3D follow_page(ptr);
@@ -1223,7 +1223,7 @@
 	if (addr >=3D end)
 		BUG();
 	do {
-		if (handle_mm_fault(mm, vma, addr, write) < 0)
+		if (handle_mm_fault(mm, vma, addr, write ? VM_WRITE : VM_READ) < 0)
 			return -1;
 		addr +=3D PAGE_SIZE;
 	} while (addr < end);

