From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 31 Jan 2001 20:32:36 +0000
Subject: [Linux-ia64] kernel update (relative to 2.4.1)
Message-Id: <marc-linux-ia64-105590693005112@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is a quick update of last week's patch that brings us in sync
with 2.4.1.  As usual, the patch is available at ftp.*.kernel.org in
/pub/linux/kernel/ports/ia64//linux-2.4.1-ia64-010131.diff*.

Summary of changes:

	- add Don's IA-32 patch that I missed last week
	- add stop bit in integer division that Chuck found to be
	  missing; as far as I know, this didn't cause any actual
	  problems on Itanium, but it was clearly wrong
	- schedule save_switch_stack/load_switch_stack for Itanium
	- Gerrit: fix config.in so it works with "make xconfig" again
	- print fpswa fault message as KERN_WARNING; use "dmesg -n 4"
	  to get rid of it

Enjoy,

  --david

diff -urN linux-davidm/arch/ia64/config.in linux-2.4.1-lia/arch/ia64/config=
.in
--- linux-davidm/arch/ia64/config.in	Wed Jan 31 11:46:51 2001
+++ linux-2.4.1-lia/arch/ia64/config.in	Wed Jan 31 10:17:50 2001
@@ -37,22 +37,32 @@
 	 16KB			CONFIG_IA64_PAGE_SIZE_16KB		\
 	 64KB			CONFIG_IA64_PAGE_SIZE_64KB" 16KB
=20
-if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
+if [ "$CONFIG_IA64_DIG" =3D "y" -o "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
 	define_bool CONFIG_ITANIUM y
 	define_bool CONFIG_IA64_BRL_EMU y
+fi
+
+if [ "$CONFIG_ITANIUM" =3D "y" ]; then
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
 	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
 	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECIF=
IC
+        fi
+	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium B1-step specific code' CONFIG_ITANIUM_B1_SPECIF=
IC
+	fi
+	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium B2-step specific code' CONFIG_ITANIUM_B2_SPECIF=
IC
 	fi
 	bool '  Enable Itanium C-step specific code' CONFIG_ITANIUM_CSTEP_SPECIFIC
 	if [ "$CONFIG_ITANIUM_CSTEP_SPECIFIC" =3D "y" ]; then
 	  bool '   Enable Itanium C0-step specific code' CONFIG_ITANIUM_C0_SPECIF=
IC
 	fi
-	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
 	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
+fi
+
+if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
+	bool '  Force interrupt redirection' CONFIG_IA64_HAVE_IRQREDIR
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
 	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
 	bool '  Enable ACPI 2.0 with errata 1.3' CONFIG_ACPI20
@@ -65,11 +75,6 @@
 fi
=20
 if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
-	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
-	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
-	if [ "$CONFIG_ITANIUM_BSTEP_SPECIFIC" =3D "y" ]; then
-	  bool '    Enable Itanium B0-step specific code' CONFIG_ITANIUM_B0_SPECI=
FIC
-	fi
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN1_SIM n
 	define_bool CONFIG_DEVFS_DEBUG y
 	define_bool CONFIG_DEVFS_FS y
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.1-lia/arch/ia6=
4/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Wed Jan 31 11:46:51 2001
+++ linux-2.4.1-lia/arch/ia64/ia32/ia32_entry.S	Wed Jan 31 10:18:02 2001
@@ -160,8 +160,8 @@
 	data8 sys32_ni_syscall /* sys_stime is not supported on IA64 */  /* 25 */
 	data8 sys32_ptrace
 	data8 sys32_alarm
-	data8 sys_pause
 	data8 sys32_ni_syscall
+	data8 sys_pause
 	data8 ia32_utime	  /* 30 */
 	data8 sys32_ni_syscall	  /* old stty syscall holder */
 	data8 sys32_ni_syscall	  /* old gtty syscall holder */
@@ -276,7 +276,7 @@
 	data8 sys32_getdents
 	data8 sys32_select
 	data8 sys_flock
-	data8 sys_msync
+	data8 sys32_msync
 	data8 sys32_readv	  /* 145 */
 	data8 sys32_writev
 	data8 sys_getsid
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.4.1-lia/arch/ia64/=
ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Wed Jan 31 11:46:51 2001
+++ linux-2.4.1-lia/arch/ia64/ia32/sys_ia32.c	Wed Jan 31 10:18:14 2001
@@ -655,7 +655,7 @@
 ia32_utime(char * filename, struct utimbuf_32 *times32)
 {
 	mm_segment_t old_fs =3D get_fs();
-	struct timeval tv[2];
+	struct timeval tv[2], *tvp;
 	long ret;
=20
 	if (times32) {
@@ -664,15 +664,10 @@
 		get_user(tv[1].tv_sec, &times32->mtime);
 		tv[1].tv_usec =3D 0;
 		set_fs (KERNEL_DS);
-	} else {
-		set_fs (KERNEL_DS);
-		ret =3D sys_gettimeofday(&tv[0], 0);
-		if (ret < 0)
-			goto out;
-		tv[1] =3D tv[0];
-	}
-	ret =3D sys_utimes(filename, tv);
-  out:
+		tvp =3D tv;
+	} else
+		tvp =3D NULL;
+	ret =3D sys_utimes(filename, tvp);
 	set_fs (old_fs);
 	return ret;
 }
@@ -2497,7 +2492,7 @@
 	case F_GETLK:
 	case F_SETLK:
 	case F_SETLKW:
-		if(cmd !=3D F_GETLK && get_flock32(&f, (struct flock32 *)((long)arg)))
+		if(get_flock32(&f, (struct flock32 *)((long)arg)))
 			return -EFAULT;
 		old_fs =3D get_fs();
 		set_fs(KERNEL_DS);
@@ -2667,14 +2662,25 @@
 	return(ret);
 }
=20
-asmlinkage long sys_msync(unsigned long start, size_t len, int flags);
-
 asmlinkage int
 sys_pause (void)
 {
 	current->state =3D TASK_INTERRUPTIBLE;
 	schedule();
 	return -ERESTARTNOHAND;
+}
+
+asmlinkage long sys_msync(unsigned long start, size_t len, int flags);
+
+asmlinkage int
+sys32_msync(unsigned int start, unsigned int len, int flags)
+{
+	unsigned int addr;
+
+	if (OFFSET4K(start))
+		return -EINVAL;
+	addr =3D start & PAGE_MASK;
+	return(sys_msync(addr, len + (start - addr), flags));
 }
=20
 #ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
diff -urN linux-davidm/arch/ia64/kernel/efi_stub.S linux-2.4.1-lia/arch/ia6=
4/kernel/efi_stub.S
--- linux-davidm/arch/ia64/kernel/efi_stub.S	Fri Jul 14 16:08:11 2000
+++ linux-2.4.1-lia/arch/ia64/kernel/efi_stub.S	Wed Jan 31 10:18:45 2001
@@ -58,7 +58,7 @@
 	;;
 	mov loc2=3Dgp			// save global pointer
 	mov loc4=3Dar.rsc			// save RSE configuration
-	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	;;
=20
 	ld8 gp=3D[in0]			// load EFI function's global pointer
@@ -80,7 +80,7 @@
 	mov out5=3Din6
 	mov out6=3Din7
 	br.call.sptk.few rp=B6		// call the EFI function
-.ret1:	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+.ret1:	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3
 	br.call.sptk.few rp=3Dia64_switch_mode // return to virtual mode
 .ret2:	mov ar.rsc=3Dloc4			// restore RSE configuration
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.1-lia/arch/ia64/k=
ernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Jan 31 11:46:51 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/entry.S	Wed Jan 31 10:19:12 2001
@@ -208,92 +208,102 @@
 	UNW(.prologue)
 	UNW(.altrp b7)
 	flushrs			// flush dirty regs to backing store (must be first in insn gro=
up)
+	UNW(.save @priunat,r17)
 	mov r17=3Dar.unat		// preserve caller's
-	adds r2=16,sp		// r2 =3D &sw->caller_unat
+	UNW(.body)
+#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+	adds r3=80,sp
 	;;
-	mov r18=3Dar.fpsr		// preserve fpsr
-	mov ar.rsc=3Dr0		// put RSE in mode: enforced lazy, little endian, pl 0
+	lfetch.fault.excl.nt1 [r3],128
+#endif
+	mov ar.rsc=3D0		// put RSE in mode: enforced lazy, little endian, pl 0
+#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+	adds r2=16+128,sp
 	;;
-	mov r19=3Dar.rnat
-	adds r3$,sp		// r3 =3D &sw->ar_fpsr
+	lfetch.fault.excl.nt1 [r2],128
+	lfetch.fault.excl.nt1 [r3],128
+#endif
+	adds r14=3DSW(R4)+16,sp
+#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+	;;
+	lfetch.fault.excl [r2]
+	lfetch.fault.excl [r3]
+#endif
+	adds r15=3DSW(R5)+16,sp
 	;;
-	.savesp ar.unat,SW(CALLER_UNAT)
-	st8 [r2]=3Dr17,16
-	.savesp ar.fpsr,SW(AR_FPSR)
-	st8 [r3]=3Dr18,24
+	mov r18=3Dar.fpsr		// preserve fpsr
+	mov r19=3Dar.rnat
+	add r2=3DSW(F2)+16,sp	// r2 =3D &sw->f2
+.mem.offset 0,0; st8.spill [r14]=3Dr4,16		// spill r4
+.mem.offset 8,0; st8.spill [r15]=3Dr5,16		// spill r5
+	add r3=3DSW(F3)+16,sp	// r3 =3D &sw->f3
 	;;
-	UNW(.body)
 	stf.spill [r2]=F2,32
 	stf.spill [r3]=F3,32
 	mov r21=B0
+.mem.offset 0,0; st8.spill [r14]=3Dr6,16		// spill r6
+.mem.offset 8,0; st8.spill [r15]=3Dr7,16		// spill r7
+	mov r22=B1
 	;;
+	// since we're done with the spills, read and save ar.unat:
+	mov r29=3Dar.unat		// M-unit
+	mov r20=3Dar.bspstore	// M-unit
+	mov r23=B2
 	stf.spill [r2]=F4,32
 	stf.spill [r3]=F5,32
+	mov r24=B3
 	;;
+	st8 [r14]=3Dr21,16	// save b0
+	st8 [r15]=3Dr22,16	// save b1
+	mov r25=B4
 	stf.spill [r2]=F10,32
 	stf.spill [r3]=F11,32
-	mov r22=B1
+	mov r26=B5
 	;;
+	st8 [r14]=3Dr23,16	// save b2
+	st8 [r15]=3Dr24,16	// save b3
+	mov r21=3Dar.lc		// I-unit
 	stf.spill [r2]=F12,32
 	stf.spill [r3]=F13,32
-	mov r23=B2
 	;;
+	st8 [r14]=3Dr25,16	// save b4
+	st8 [r15]=3Dr26,16	// save b5
 	stf.spill [r2]=F14,32
 	stf.spill [r3]=F15,32
-	mov r24=B3
 	;;
+	st8 [r14]=3Dr16		// save ar.pfs
+	st8 [r15]=3Dr21		// save ar.lc
 	stf.spill [r2]=F16,32
 	stf.spill [r3]=F17,32
-	mov r25=B4
 	;;
 	stf.spill [r2]=F18,32
 	stf.spill [r3]=F19,32
-	mov r26=B5
 	;;
 	stf.spill [r2]=F20,32
 	stf.spill [r3]=F21,32
-	mov r17=3Dar.lc				// I-unit
 	;;
 	stf.spill [r2]=F22,32
 	stf.spill [r3]=F23,32
 	;;
 	stf.spill [r2]=F24,32
 	stf.spill [r3]=F25,32
+	add r14=3DSW(CALLER_UNAT)+16,sp
 	;;
 	stf.spill [r2]=F26,32
 	stf.spill [r3]=F27,32
+	add r15=3DSW(AR_FPSR)+16,sp
 	;;
 	stf.spill [r2]=F28,32
 	stf.spill [r3]=F29,32
-	;;
-	stf.spill [r2]=F30,32
-	stf.spill [r3]=F31,24
-	;;
-.mem.offset 0,0;	st8.spill [r2]=3Dr4,16
-.mem.offset 8,0;	st8.spill [r3]=3Dr5,16
-	;;
-.mem.offset 0,0;	st8.spill [r2]=3Dr6,16
-.mem.offset 8,0;	st8.spill [r3]=3Dr7,16
-	;;
-	st8 [r2]=3Dr21,16		// save b0
-	st8 [r3]=3Dr22,16		// save b1
-	/* since we're done with the spills, read and save ar.unat: */
-	mov r18=3Dar.unat		// M-unit
-	mov r20=3Dar.bspstore	// M-unit
-	;;
-	st8 [r2]=3Dr23,16		// save b2
-	st8 [r3]=3Dr24,16		// save b3
-	;;
-	st8 [r2]=3Dr25,16		// save b4
-	st8 [r3]=3Dr26,16		// save b5
-	;;
-	st8 [r2]=3Dr16,16		// save ar.pfs
-	st8 [r3]=3Dr17,16		// save ar.lc
+	st8 [r14]=3Dr17		// save caller_unat
+	st8 [r15]=3Dr18		// save fpsr
 	mov r21=3Dpr
 	;;
-	st8 [r2]=3Dr18,16		// save ar.unat
+	stf.spill [r2]=F30,(SW(AR_UNAT)-SW(F30))
+	stf.spill [r3]=F31,(SW(AR_RNAT)-SW(F31))
+	;;
+	st8 [r2]=3Dr29,16		// save ar.unat
 	st8 [r3]=3Dr19,16		// save ar.rnat
-	mov b7=3Dr28
 	;;
 	st8 [r2]=3Dr20		// save ar.bspstore
 	st8 [r3]=3Dr21		// save predicate registers
@@ -303,16 +313,25 @@
=20
 /*
  * load_switch_stack:
+ *	- "invala" MUST be done at call site (normally in DO_LOAD_SWITCH_STACK)
  *	- b7 holds address to return to
+ *	- must not touch r8-r11
  */
 ENTRY(load_switch_stack)
 	UNW(.prologue)
 	UNW(.altrp b7)
-	invala			// invalidate ALAT
 	UNW(.body)
-	adds r2=3DIA64_SWITCH_STACK_B0_OFFSET+16,sp	// get pointer to switch_stac=
k.b0
-	mov ar.rsc=3Dr0		// put RSE into enforced lazy mode
-	adds r3=3DIA64_SWITCH_STACK_B0_OFFSET+24,sp	// get pointer to switch_stac=
k.b1
+#if !defined(CONFIG_ITANIUM_ASTEP_SPECIFIC)
+	lfetch.fault.nt1 [sp]
+#endif
+	adds r2=3DSW(AR_BSPSTORE)+16,sp
+	adds r3=3DSW(AR_UNAT)+16,sp
+	mov ar.rsc=3D0						// put RSE into enforced lazy mode
+	adds r14=3DSW(CALLER_UNAT)+16,sp
+	adds r15=3DSW(AR_FPSR)+16,sp
+	;;
+	ld8 r27=3D[r2],(SW(B0)-SW(AR_BSPSTORE))	// bspstore
+	ld8 r29=3D[r3],(SW(B1)-SW(AR_UNAT))	// unat
 	;;
 	ld8 r21=3D[r2],16		// restore b0
 	ld8 r22=3D[r3],16		// restore b1
@@ -323,84 +342,77 @@
 	ld8 r25=3D[r2],16		// restore b4
 	ld8 r26=3D[r3],16		// restore b5
 	;;
-	ld8 r16=3D[r2],16		// restore ar.pfs
-	ld8 r17=3D[r3],16		// restore ar.lc
+	ld8 r16=3D[r2],(SW(PR)-SW(AR_PFS))	// ar.pfs
+	ld8 r17=3D[r3],(SW(AR_RNAT)-SW(AR_LC))	// ar.lc
 	;;
-	ld8 r18=3D[r2],16		// restore ar.unat
-	ld8 r19=3D[r3],16		// restore ar.rnat
-	mov b0=3Dr21
+	ld8 r28=3D[r2]		// restore pr
+	ld8 r30=3D[r3]		// restore rnat
 	;;
-	ld8 r20=3D[r2]		// restore ar.bspstore
-	ld8 r21=3D[r3]		// restore predicate registers
-	mov ar.pfs=3Dr16
+	ld8 r18=3D[r14],16	// restore caller's unat
+	ld8 r19=3D[r15],24	// restore fpsr
 	;;
-	mov ar.bspstore=3Dr20
+	ldf.fill f2=3D[r14],32
+	ldf.fill f3=3D[r15],32
 	;;
-	loadrs			// invalidate stacked regs outside current frame
-	adds r2=16-IA64_SWITCH_STACK_SIZE,r2	// get pointer to switch_stack.calle=
r_unat
-	;;			// stop bit for rnat dependency
-	mov ar.rnat=3Dr19
-	mov ar.unat=3Dr18		// establish unat holding the NaT bits for r4-r7
-	adds r3=16-IA64_SWITCH_STACK_SIZE,r3	// get pointer to switch_stack.ar_fp=
sr
+	ldf.fill f4=3D[r14],32
+	ldf.fill f5=3D[r15],32
 	;;
-	ld8 r18=3D[r2],16		// restore caller's unat
-	ld8 r19=3D[r3],24		// restore fpsr
-	mov ar.lc=3Dr17
+	ldf.fill f10=3D[r14],32
+	ldf.fill f11=3D[r15],32
 	;;
-	ldf.fill f2=3D[r2],32
-	ldf.fill f3=3D[r3],32
-	mov pr=3Dr21,-1
+	ldf.fill f12=3D[r14],32
+	ldf.fill f13=3D[r15],32
 	;;
-	ldf.fill f4=3D[r2],32
-	ldf.fill f5=3D[r3],32
+	ldf.fill f14=3D[r14],32
+	ldf.fill f15=3D[r15],32
 	;;
-	ldf.fill f10=3D[r2],32
-	ldf.fill f11=3D[r3],32
+	ldf.fill f16=3D[r14],32
+	ldf.fill f17=3D[r15],32
+	;;
+	ldf.fill f18=3D[r14],32
+	ldf.fill f19=3D[r15],32
+	mov b0=3Dr21
+	;;
+	ldf.fill f20=3D[r14],32
+	ldf.fill f21=3D[r15],32
 	mov b1=3Dr22
 	;;
-	ldf.fill f12=3D[r2],32
-	ldf.fill f13=3D[r3],32
+	ldf.fill f22=3D[r14],32
+	ldf.fill f23=3D[r15],32
 	mov b2=3Dr23
 	;;
-	ldf.fill f14=3D[r2],32
-	ldf.fill f15=3D[r3],32
+	mov ar.bspstore=3Dr27
+	mov ar.unat=3Dr29		// establish unat holding the NaT bits for r4-r7
 	mov b3=3Dr24
 	;;
-	ldf.fill f16=3D[r2],32
-	ldf.fill f17=3D[r3],32
+	ldf.fill f24=3D[r14],32
+	ldf.fill f25=3D[r15],32
 	mov b4=3Dr25
 	;;
-	ldf.fill f18=3D[r2],32
-	ldf.fill f19=3D[r3],32
+	ldf.fill f26=3D[r14],32
+	ldf.fill f27=3D[r15],32
 	mov b5=3Dr26
 	;;
-	ldf.fill f20=3D[r2],32
-	ldf.fill f21=3D[r3],32
-	;;
-	ldf.fill f22=3D[r2],32
-	ldf.fill f23=3D[r3],32
-	;;
-	ldf.fill f24=3D[r2],32
-	ldf.fill f25=3D[r3],32
-	;;
-	ldf.fill f26=3D[r2],32
-	ldf.fill f27=3D[r3],32
-	;;
-	ldf.fill f28=3D[r2],32
-	ldf.fill f29=3D[r3],32
+	ldf.fill f28=3D[r14],32
+	ldf.fill f29=3D[r15],32
+	mov ar.pfs=3Dr16
 	;;
-	ldf.fill f30=3D[r2],32
-	ldf.fill f31=3D[r3],24
+	ldf.fill f30=3D[r14],32
+	ldf.fill f31=3D[r15],24
+	mov ar.lc=3Dr17
 	;;
-	ld8.fill r4=3D[r2],16
-	ld8.fill r5=3D[r3],16
+	ld8.fill r4=3D[r14],16
+	ld8.fill r5=3D[r15],16
+	mov pr=3Dr28,-1
 	;;
-	ld8.fill r6=3D[r2],16
-	ld8.fill r7=3D[r3],16
+	ld8.fill r6=3D[r14],16
+	ld8.fill r7=3D[r15],16
+
 	mov ar.unat=3Dr18				// restore caller's unat
+	mov ar.rnat=3Dr30				// must restore after bspstore but before rsc!
 	mov ar.fpsr=3Dr19				// restore fpsr
 	mov ar.rsc=3D3				// put RSE back into eager mode, pl 0
-	br.cond.sptk.few b7
+	br.cond.sptk.many b7
 END(load_switch_stack)
=20
 GLOBAL_ENTRY(__ia64_syscall)
@@ -468,8 +480,8 @@
 .ret6:	br.call.sptk.few rp=B6			// do the syscall
 strace_check_retval:
 	cmp.lt p6,p0=3Dr8,r0			// syscall failed?
-	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp	// r2 =3D &pt_regs.r8
-	adds r3=3DIA64_PT_REGS_R8_OFFSET+32,sp	// r3 =3D &pt_regs.r10
+	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
+	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
 	mov r10=3D0
 (p6)	br.cond.sptk.few strace_error		// syscall failed ->
 	;;					// avoid RAW on r10
@@ -514,8 +526,8 @@
 GLOBAL_ENTRY(ia64_ret_from_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	cmp.ge p6,p7=3Dr8,r0			// syscall executed successfully?
-	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp	// r2 =3D &pt_regs.r8
-	adds r3=3DIA64_PT_REGS_R8_OFFSET+32,sp	// r3 =3D &pt_regs.r10
+	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
+	adds r3=3DPT(R10)+16,sp			// r3 =3D &pt_regs.r10
 	;;
 	.mem.offset 0,0
 (p6)	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat=
 bit
@@ -538,7 +550,6 @@
 	;;
 	add r3=3Dr2,r3
 #else
-	adds r16=3DIA64_PT_REGS_R8_OFFSET+16,r12
 	movl r3=3Dirq_stat		// softirq_active
 #endif
 	;;
@@ -599,13 +610,13 @@
 .ret10:
 	;;
 	ssm psr.i
-#endif=20
+#endif
 restore_all:
=20
 	// start restoring the state saved on the kernel stack (struct pt_regs):
=20
-	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,r12
-	adds r3=3DIA64_PT_REGS_R8_OFFSET+24,r12
+	adds r2=3DPT(R8)+16,r12
+	adds r3=3DPT(R9)+16,r12
 	;;
 	ld8.fill r8=3D[r2],16
 	ld8.fill r9=3D[r3],16
@@ -936,11 +947,11 @@
 	;;
 	adds out0=16,sp				// out0 =3D &sigscratch
 	br.call.sptk.few rp=3Dia64_rt_sigreturn
-.ret19:	adds sp=16,sp		// doesn't drop pt_regs, so don't mark it as restor=
ing sp!
-	PT_REGS_UNWIND_INFO(0)	// instead, create a new body section with the sma=
ller frame
+.ret19:	.restore sp
+	adds sp=16,sp
 	;;
 	ld8 r9=3D[sp]				// load new ar.unat
-	mov b7=3Dr8
+	MOVBR(.sptk,b7,r8,ia64_leave_kernel)
 	;;
 	mov ar.unat=3Dr9
 	br b7
@@ -949,10 +960,10 @@
 	PT_REGS_UNWIND_INFO(0)
 	UNW(.prologue)
 	UNW(.fframe IA64_PT_REGS_SIZE+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp rp, PT(CR_IIP)+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp ar.pfs, PT(CR_IFS)+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp ar.unat, PT(AR_UNAT)+IA64_SWITCH_STACK_SIZE)
-	UNW(.spillsp pr, PT(PR)+IA64_SWITCH_STACK_SIZE)
+	UNW(.spillsp rp, PT(CR_IIP)+16+IA64_SWITCH_STACK_SIZE)
+	UNW(.spillsp ar.pfs, PT(CR_IFS)+16+IA64_SWITCH_STACK_SIZE)
+	UNW(.spillsp ar.unat, PT(AR_UNAT)+16+IA64_SWITCH_STACK_SIZE)
+	UNW(.spillsp pr, PT(PR)+16+IA64_SWITCH_STACK_SIZE)
 	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp
 	cmp.eq pNonSys,pSys=3Dr0,r0		// sigreturn isn't a normal syscall...
 	;;
@@ -960,10 +971,10 @@
=20
 	adds out0=16,sp				// out0 =3D &sigscratch
 	br.call.sptk.few rp=3Dia64_rt_sigreturn
-.ret20:	adds r3=3DIA64_SWITCH_STACK_CALLER_UNAT_OFFSET+16,sp
+.ret20:	adds r3=3DSW(CALLER_UNAT)+16,sp
 	;;
 	ld8 r9=3D[r3]			// load new ar.unat
-	mov b7=3Dr8
+	MOVBR(.sptk,b7,r8,ia64_leave_kernel)
 	;;
 	PT_REGS_UNWIND_INFO(0)
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop (dummy) switch-stack frame
diff -urN linux-davidm/arch/ia64/kernel/entry.h linux-2.4.1-lia/arch/ia64/k=
ernel/entry.h
--- linux-davidm/arch/ia64/kernel/entry.h	Wed Jan 31 11:46:51 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/entry.h	Wed Jan 31 10:20:40 2001
@@ -1,3 +1,12 @@
+#include <linux/config.h>
+
+/* XXX fixme */
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_ITANIUM_BSTEP=
_SPECIFIC)
+# define MOVBR(type,br,gr,lbl)	mov br=3Dgr
+#else
+# define MOVBR(type,br,gr,lbl)	mov##type br=3Dgr,lbl
+#endif
+
 /*
  * Preserved registers that are shared between code in ivt.S and entry.S. =
 Be
  * careful not to step on these!
@@ -6,51 +15,53 @@
 #define pSys		p4	/* are we processing a (synchronous) system call? */
 #define pNonSys		p5	/* complement of pSys */
=20
-#define PT(f)		(IA64_PT_REGS_##f##_OFFSET + 16)
-#define SW(f)		(IA64_SWITCH_STACK_##f##_OFFSET + 16)
+#define PT(f)		(IA64_PT_REGS_##f##_OFFSET)
+#define SW(f)		(IA64_SWITCH_STACK_##f##_OFFSET)
=20
 #define PT_REGS_SAVES(off)				\
 	UNW(.unwabi @svr4, 'i');			\
 	UNW(.fframe IA64_PT_REGS_SIZE+16+(off));	\
-	UNW(.spillsp rp, PT(CR_IIP)+(off));		\
-	UNW(.spillsp ar.pfs, PT(CR_IFS)+(off));		\
-	UNW(.spillsp ar.unat, PT(AR_UNAT)+(off));	\
-	UNW(.spillsp ar.fpsr, PT(AR_FPSR)+(off));	\
-	UNW(.spillsp pr, PT(PR)+(off));
+	UNW(.spillsp rp, PT(CR_IIP)+16+(off));		\
+	UNW(.spillsp ar.pfs, PT(CR_IFS)+16+(off));	\
+	UNW(.spillsp ar.unat, PT(AR_UNAT)+16+(off));	\
+	UNW(.spillsp ar.fpsr, PT(AR_FPSR)+16+(off));	\
+	UNW(.spillsp pr, PT(PR)+16+(off));
=20
 #define PT_REGS_UNWIND_INFO(off)		\
 	UNW(.prologue);				\
 	PT_REGS_SAVES(off);			\
 	UNW(.body)
=20
-#define SWITCH_STACK_SAVES(off)									  \
-	UNW(.savesp ar.unat,SW(CALLER_UNAT)+(off)); UNW(.savesp ar.fpsr,SW(AR_FPS=
R)+(off));	  \
-	UNW(.spillsp f2,SW(F2)+(off)); UNW(.spillsp f3,SW(F3)+(off));				  \
-	UNW(.spillsp f4,SW(F4)+(off)); UNW(.spillsp f5,SW(F5)+(off));				  \
-	UNW(.spillsp f16,SW(F16)+(off)); UNW(.spillsp f17,SW(F17)+(off));			  \
-	UNW(.spillsp f18,SW(F18)+(off)); UNW(.spillsp f19,SW(F19)+(off));			  \
-	UNW(.spillsp f20,SW(F20)+(off)); UNW(.spillsp f21,SW(F21)+(off));			  \
-	UNW(.spillsp f22,SW(F22)+(off)); UNW(.spillsp f23,SW(F23)+(off));			  \
-	UNW(.spillsp f24,SW(F24)+(off)); UNW(.spillsp f25,SW(F25)+(off));			  \
-	UNW(.spillsp f26,SW(F26)+(off)); UNW(.spillsp f27,SW(F27)+(off));			  \
-	UNW(.spillsp f28,SW(F28)+(off)); UNW(.spillsp f29,SW(F29)+(off));			  \
-	UNW(.spillsp f30,SW(F30)+(off)); UNW(.spillsp f31,SW(F31)+(off));			  \
-	UNW(.spillsp r4,SW(R4)+(off)); UNW(.spillsp r5,SW(R5)+(off));				  \
-	UNW(.spillsp r6,SW(R6)+(off)); UNW(.spillsp r7,SW(R7)+(off));				  \
-	UNW(.spillsp b0,SW(B0)+(off)); UNW(.spillsp b1,SW(B1)+(off));				  \
-	UNW(.spillsp b2,SW(B2)+(off)); UNW(.spillsp b3,SW(B3)+(off));				  \
-	UNW(.spillsp b4,SW(B4)+(off)); UNW(.spillsp b5,SW(B5)+(off));				  \
-	UNW(.spillsp ar.pfs,SW(AR_PFS)+(off)); UNW(.spillsp ar.lc,SW(AR_LC)+(off)=
);		  \
-	UNW(.spillsp @priunat,SW(AR_UNAT)+(off));						  \
-	UNW(.spillsp ar.rnat,SW(AR_RNAT)+(off)); UNW(.spillsp ar.bspstore,SW(AR_B=
SPSTORE)+(off)); \
-	UNW(.spillsp pr,SW(PR)+(off))
+#define SWITCH_STACK_SAVES(off)									\
+	UNW(.savesp ar.unat,SW(CALLER_UNAT)+16+(off));						\
+	UNW(.savesp ar.fpsr,SW(AR_FPSR)+16+(off));						\
+	UNW(.spillsp f2,SW(F2)+16+(off)); UNW(.spillsp f3,SW(F3)+16+(off));			\
+	UNW(.spillsp f4,SW(F4)+16+(off)); UNW(.spillsp f5,SW(F5)+16+(off));			\
+	UNW(.spillsp f16,SW(F16)+16+(off)); UNW(.spillsp f17,SW(F17)+16+(off));		=
	\
+	UNW(.spillsp f18,SW(F18)+16+(off)); UNW(.spillsp f19,SW(F19)+16+(off));		=
	\
+	UNW(.spillsp f20,SW(F20)+16+(off)); UNW(.spillsp f21,SW(F21)+16+(off));		=
	\
+	UNW(.spillsp f22,SW(F22)+16+(off)); UNW(.spillsp f23,SW(F23)+16+(off));		=
	\
+	UNW(.spillsp f24,SW(F24)+16+(off)); UNW(.spillsp f25,SW(F25)+16+(off));		=
	\
+	UNW(.spillsp f26,SW(F26)+16+(off)); UNW(.spillsp f27,SW(F27)+16+(off));		=
	\
+	UNW(.spillsp f28,SW(F28)+16+(off)); UNW(.spillsp f29,SW(F29)+16+(off));		=
	\
+	UNW(.spillsp f30,SW(F30)+16+(off)); UNW(.spillsp f31,SW(F31)+16+(off));		=
	\
+	UNW(.spillsp r4,SW(R4)+16+(off)); UNW(.spillsp r5,SW(R5)+16+(off));			\
+	UNW(.spillsp r6,SW(R6)+16+(off)); UNW(.spillsp r7,SW(R7)+16+(off));			\
+	UNW(.spillsp b0,SW(B0)+16+(off)); UNW(.spillsp b1,SW(B1)+16+(off));			\
+	UNW(.spillsp b2,SW(B2)+16+(off)); UNW(.spillsp b3,SW(B3)+16+(off));			\
+	UNW(.spillsp b4,SW(B4)+16+(off)); UNW(.spillsp b5,SW(B5)+16+(off));			\
+	UNW(.spillsp ar.pfs,SW(AR_PFS)+16+(off)); UNW(.spillsp ar.lc,SW(AR_LC)+16=
+(off));	\
+	UNW(.spillsp @priunat,SW(AR_UNAT)+16+(off));						\
+	UNW(.spillsp ar.rnat,SW(AR_RNAT)+16+(off));						\
+	UNW(.spillsp ar.bspstore,SW(AR_BSPSTORE)+16+(off));					\
+	UNW(.spillsp pr,SW(PR)+16+(off))
=20
 #define DO_SAVE_SWITCH_STACK			\
 	movl r28=1F;				\
 	;;					\
 	.fframe IA64_SWITCH_STACK_SIZE;		\
 	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp;	\
-	mov b7=3Dr28;				\
+	MOVBR(.ret.sptk,b7,r28,1f);		\
 	SWITCH_STACK_SAVES(0);			\
 	br.cond.sptk.many save_switch_stack;	\
 1:
@@ -58,7 +69,8 @@
 #define DO_LOAD_SWITCH_STACK			\
 	movl r28=1F;				\
 	;;					\
-	mov b7=3Dr28;				\
+	invala;					\
+	MOVBR(.ret.sptk,b7,r28,1f);		\
 	br.cond.sptk.many load_switch_stack;	\
 1:	UNW(.restore sp);			\
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp
diff -urN linux-davidm/arch/ia64/kernel/gate.S linux-2.4.1-lia/arch/ia64/ke=
rnel/gate.S
--- linux-davidm/arch/ia64/kernel/gate.S	Fri Jul 14 16:08:11 2000
+++ linux-2.4.1-lia/arch/ia64/kernel/gate.S	Wed Jan 31 10:21:10 2001
@@ -153,7 +153,7 @@
=20
 ENTRY(setup_rbs)
 	flushrs					// must be first in insn
-	mov ar.rsc=3Dr0				// put RSE into enforced lazy mode
+	mov ar.rsc=3D0				// put RSE into enforced lazy mode
 	adds r16=3D(RNAT_OFF+SIGCONTEXT_OFF),sp
 	;;
 	mov r14=3Dar.rnat				// get rnat as updated by flushrs
@@ -167,7 +167,7 @@
=20
 ENTRY(restore_rbs)
 	flushrs
-	mov ar.rsc=3Dr0				// put RSE into enforced lazy mode
+	mov ar.rsc=3D0				// put RSE into enforced lazy mode
 	adds r16=3D(RNAT_OFF+SIGCONTEXT_OFF),sp
 	;;
 	ld8 r14=3D[r16]				// get new rnat
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.1-lia/arch/ia64/ke=
rnel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/head.S	Wed Jan 31 10:21:20 2001
@@ -113,7 +113,7 @@
 	 */
 	addl r12=3DIA64_STK_OFFSET-IA64_PT_REGS_SIZE-16,r2
 	addl r2=3DIA64_RBS_OFFSET,r2	// initialize the RSE
-	mov ar.rsc=3Dr0		// place RSE in enforced lazy mode
+	mov ar.rsc=3D0		// place RSE in enforced lazy mode
 	;;
 	mov ar.bspstore=3Dr2	// establish the new RSE stack
 	;;
diff -urN linux-davidm/arch/ia64/kernel/minstate.h linux-2.4.1-lia/arch/ia6=
4/kernel/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Wed Jan 31 11:46:52 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/minstate.h	Wed Jan 31 10:21:41 2001
@@ -29,7 +29,7 @@
  */
 #define MINSTATE_START_SAVE_MIN_VIRT								\
 	dep r1=3D-1,r1,61,3;				/* r1 =3D current (virtual) */		\
-(p7)	mov ar.rsc=3Dr0;		/* set enforced lazy mode, pl 0, little-endian, loa=
drs=3D0 */	\
+(p7)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, load=
rs=3D0 */	\
 	;;											\
 (p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
 (p7)	mov rARRNAT=3Dar.rnat;									\
@@ -55,7 +55,7 @@
  */
 #define MINSTATE_START_SAVE_MIN_PHYS								\
 (pKern) movl sp=3Dia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
-(p7)	mov ar.rsc=3Dr0;		/* set enforced lazy mode, pl 0, little-endian, loa=
drs=3D0 */	\
+(p7)	mov ar.rsc=3D0;		/* set enforced lazy mode, pl 0, little-endian, load=
rs=3D0 */	\
 (p7)	addl rKRBS=3DIA64_RBS_OFFSET,r1;		/* compute base of register backing=
 store */	\
 	;;											\
 (p7)	mov rARRNAT=3Dar.rnat;									\
diff -urN linux-davidm/arch/ia64/kernel/pal.S linux-2.4.1-lia/arch/ia64/ker=
nel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/pal.S	Wed Jan 31 10:21:52 2001
@@ -171,7 +171,7 @@
 	dep.z r8=3Dr8,0,61		// convert rp to physical
 	;;
 	mov b7 =3D loc2			// install target to branch reg
-	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	movl r16=3DPAL_PSR_BITS_TO_CLEAR
 	movl r17=3DPAL_PSR_BITS_TO_SET
 	;;
@@ -182,7 +182,7 @@
 .ret1:	mov rp =3D r8			// install return address (physical)
 	br.cond.sptk.few b7
 1:
-	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
 	br.call.sptk.few rp=3Dia64_switch_mode // return to virtual mode
 .ret2:
@@ -224,7 +224,7 @@
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
 	;;
-	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	movl r16=3DPAL_PSR_BITS_TO_CLEAR
 	movl r17=3DPAL_PSR_BITS_TO_SET
 	;;
@@ -236,7 +236,7 @@
 .ret6:
 	br.call.sptk.many rp=B7		// now make the call
 .ret7:
-	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
 	br.call.sptk.few rp=3Dia64_switch_mode	// return to virtual mode
=20
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.1-lia/arch/ia64=
/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed Jan 31 11:46:52 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/process.c	Mon Jan  8 23:41:03 2001
@@ -347,6 +347,7 @@
 		unw_get_gr(info, i, &dst[i], &nat);
 		if (nat)
 			nat_bits |=3D mask;
+printk("r%u =3D %c%016lx\n", i, nat ? '*' : ' ', dst[i]);
 		mask <<=3D 1;
 	}
 	dst[32] =3D nat_bits;
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.4.1-lia/arch/ia64/=
kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Wed Jan 31 11:46:52 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/signal.c	Wed Jan 31 10:22:01 2001
@@ -52,7 +52,6 @@
 	struct sigcontext sc;
 };
=20
-extern long sys_wait4 (int, int *, int, struct rusage *);
 extern long ia64_do_signal (sigset_t *, struct sigscratch *, long);	/* for=
ward decl */
=20
 long
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.1-lia/arch/ia64/k=
ernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Thu Jan  4 22:40:10 2001
+++ linux-2.4.1-lia/arch/ia64/kernel/traps.c	Wed Jan 31 10:26:01 2001
@@ -319,15 +319,14 @@
 	if (copy_from_user(bundle, (void *) fault_ip, sizeof(bundle)))
 		return -1;
=20
-#ifdef FPSWA_DEBUG
 	if (fpu_swa_count > 5 && jiffies - last_time > 5*HZ)
 		fpu_swa_count =3D 0;
 	if (++fpu_swa_count < 5) {
 		last_time =3D jiffies;
-		printk("%s(%d): floating-point assist fault at ip %016lx\n",
+		printk(KERN_WARNING "%s(%d): floating-point assist fault at ip %016lx\n",
 		       current->comm, current->pid, regs->cr_iip + ia64_psr(regs)->ri);
 	}
-#endif
+
 	exception =3D fp_emulate(fp_fault, bundle, &regs->cr_ipsr, &regs->ar_fpsr=
, &isr, &regs->pr,
  			       &regs->cr_ifs, regs);
 	if (fp_fault) {
diff -urN linux-davidm/arch/ia64/lib/idiv64.S linux-2.4.1-lia/arch/ia64/lib=
/idiv64.S
--- linux-davidm/arch/ia64/lib/idiv64.S	Mon Oct  9 17:54:56 2000
+++ linux-2.4.1-lia/arch/ia64/lib/idiv64.S	Wed Jan 31 10:22:48 2001
@@ -42,6 +42,7 @@
 	// Transfer inputs to FP registers.
 	setf.sig f8 =3D in0
 	setf.sig f9 =3D in1
+	;;
 	UNW(.fframe 16)
 	UNW(.save.f 0x20)
 	stf.spill [sp] =3D f17,-16
diff -urN linux-davidm/drivers/acpi/acpiconf.c linux-2.4.1-lia/drivers/acpi=
/acpiconf.c
--- linux-davidm/drivers/acpi/acpiconf.c	Wed Jan 31 11:46:52 2001
+++ linux-2.4.1-lia/drivers/acpi/acpiconf.c	Wed Jan 31 10:24:18 2001
@@ -234,8 +234,8 @@
 		ext_obj =3D (ACPI_OBJECT *) ret_buf.pointer;
=20
 		switch (ext_obj->type) {
-		case ACPI_TYPE_NUMBER:
-			busnum =3D (NATIVE_UINT) ext_obj->number.value;
+		case ACPI_TYPE_INTEGER:
+			busnum =3D (NATIVE_UINT) ext_obj->integer.value;
 			next_busnum =3D busnum + 1;
 			dprintk(("Acpi cfg:_BBN busnum is %ld\n ", busnum));
 			break;
@@ -266,8 +266,8 @@
 		ext_obj =3D (ACPI_OBJECT *) ret_buf.pointer;
=20
 		switch (ext_obj->type) {
-		case ACPI_TYPE_NUMBER:
-			if((NATIVE_UINT) ext_obj->number.value & ACPI_STA_DEVICE_PRESENT) {
+		case ACPI_TYPE_INTEGER:
+			if((NATIVE_UINT) ext_obj->integer.value & ACPI_STA_DEVICE_PRESENT) {
 				dprintk(("Acpi cfg:_STA: pci bus %ld exist\n", busnum));
 			} else {
 				printk("Acpi cfg:_STA: pci bus %ld not exist. Discarding the _PRT\n", =
busnum);
diff -urN linux-davidm/fs/binfmt_elf.c linux-2.4.1-lia/fs/binfmt_elf.c
--- linux-davidm/fs/binfmt_elf.c	Wed Jan 31 11:46:55 2001
+++ linux-2.4.1-lia/fs/binfmt_elf.c	Wed Jan 31 10:26:35 2001
@@ -484,20 +484,6 @@
 			if (strcmp(elf_interpreter,"/usr/lib/libc.so.1") =3D 0 ||
 			    strcmp(elf_interpreter,"/usr/lib/ld.so.1") =3D 0)
 				ibcs2_interpreter =3D 1;
-#if defined(__ia64__) && !defined(CONFIG_BINFMT_ELF32)
-			/*
-			 * XXX temporary gross hack until all IA-64 Linux binaries
-			 * use /lib/ld-linux-ia64.so.1 as the linker name.
-			 */
-#define INTRP64	"/lib/ld-linux-ia64.so.1"
- 			if (strcmp(elf_interpreter,"/lib/ld-linux.so.2") =3D 0) {
-				kfree(elf_interpreter);
-				elf_interpreter=3D(char *)kmalloc(sizeof(INTRP64), GFP_KERNEL);
- 				if (!elf_interpreter)
- 					goto out_free_file;
-				strcpy(elf_interpreter, INTRP64);
- 			}
-#endif /* defined(__ia64__) && !defined(CONFIG_BINFMT_ELF32) */
 #if 0
 			printk("Using ELF interpreter %s\n", elf_interpreter);
 #endif
diff -urN linux-davidm/include/asm-ia64/byteorder.h linux-2.4.1-lia/include=
/asm-ia64/byteorder.h
--- linux-davidm/include/asm-ia64/byteorder.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.1-lia/include/asm-ia64/byteorder.h	Wed Jan 31 10:28:45 2001
@@ -20,18 +20,18 @@
 static __inline__ __const__ __u32
 __ia64_swab32 (__u32 x)
 {
-	return __ia64_swab64 (x) >> 32;
+	return __ia64_swab64(x) >> 32;
 }
=20
 static __inline__ __const__ __u16
 __ia64_swab16(__u16 x)
 {
-	return __ia64_swab64 (x) >> 48;
+	return __ia64_swab64(x) >> 48;
 }
=20
-#define __arch__swab64(x) __ia64_swab64 (x)
-#define __arch__swab32(x) __ia64_swab32 (x)
-#define __arch__swab16(x) __ia64_swab16 (x)
+#define __arch__swab64(x) __ia64_swab64(x)
+#define __arch__swab32(x) __ia64_swab32(x)
+#define __arch__swab16(x) __ia64_swab16(x)
=20
 #define __BYTEORDER_HAS_U64__
=20
diff -urN linux-davidm/include/asm-ia64/errno.h linux-2.4.1-lia/include/asm=
-ia64/errno.h
--- linux-davidm/include/asm-ia64/errno.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.1-lia/include/asm-ia64/errno.h	Wed Jan 31 10:29:01 2001
@@ -135,5 +135,5 @@
=20
 #define	ENOMEDIUM	123	/* No medium found */
 #define	EMEDIUMTYPE	124	/* Wrong medium type */
-
+#define	EHASHCOLLISION	125	/* Number of hash collisons exceeds max. genera=
tion value */
 #endif /* _ASM_IA64_ERRNO_H */
diff -urN linux-davidm/include/asm-ia64/mca_asm.h linux-2.4.1-lia/include/a=
sm-ia64/mca_asm.h
--- linux-davidm/include/asm-ia64/mca_asm.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.1-lia/include/asm-ia64/mca_asm.h	Wed Jan 31 10:29:15 2001
@@ -72,7 +72,7 @@
 	;;										\
 	dep	old_psr =3D 0, old_psr, 32, 32;						\
 	                                                                         =
       \
-	mov	ar.rsc =3D r0 ;								\
+	mov	ar.rsc =3D 0 ;								\
 	;;										\
 	mov	temp2 =3D ar.bspstore;							\
 	;;										\
@@ -148,7 +148,7 @@
 	dep	temp2 =3D 0, temp2, PSR_IC, 2;						\
 	;;										\
 	mov	psr.l =3D temp2;								\
-	mov	ar.rsc =3D r0;								\
+	mov	ar.rsc =3D 0;								\
 	;;										\
 	srlz.d;										\
 	mov	temp2 =3D ar.bspstore;							\
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.1-lia/include/as=
m-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Thu Jan  4 22:40:21 2001
+++ linux-2.4.1-lia/include/asm-ia64/system.h	Wed Jan 31 10:29:42 2001
@@ -350,7 +350,7 @@
 	      case 2: _o_ =3D (__u16) (long) (old); break;				\
 	      case 4: _o_ =3D (__u32) (long) (old); break;				\
 	      case 8: _o_ =3D (__u64) (long) (old); break;				\
-	      default:									\
+	      default: break;								\
 	}										\
 	 __asm__ __volatile__ ("mov ar.ccv=3D%0;;" :: "rO"(_o_));				\
 	switch (size) {									\

