From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 02 Oct 2001 05:34:24 +0000
Subject: [Linux-ia64] [patch] quick combo patch relative to 2.4.10+010924 ia64 patch
Message-Id: <marc-linux-ia64-105590698805286@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Below is a quick patch which collects the various small fixes that
have been posted since the last kernel patch.  It also contains a
fairly major update to the ia32 subsystem.  In particular, I redid the
ia32 subsystem's mmap emulation.  With this patch, you can run WINE
with any page size, not just 4KB.  In fact, the page size does not
seem to make any noticable difference for WINE anymore, even though it
does some tricky things which are (virtually) impossible to emulate
accurately with a large page size (such as using both MAP_FIXED and
MAP_SHARED on non-page aligned memory regions).  The new mmap
emulation prints a warning messages of the form:

 COMMAND(PID): emulate_mmap() can't share contents of incongruent mmap
 COMMAND(PID): emulate_mmap() can't share head
 COMMAND(PID): emulate_mmap() can't share tail

when these problematic cases occur.  Mind you, this doesn't
necessarily mean that the program won't work, it's just a warning that
there might be problems.

Also, I should say that I used WINE mostly as a nasty test case for
the ia32 subsystem.  The RPMS available from CodeWeavers worked best
for me and with those, I was able to get stuff like wordpad, mspaint,
cd player, and even Acrobat 4 to work.  Stuff like Outlook Express,
NetMeeting, Acrobat 5, TurboTax and Real Player would start up, but
crash shortly afterwards.  I have never used WINE on an x86 box, so
it's possible that at least some of these problems are due to genuine
WINE bugs and not due to ia32 emulation bugs.  I don't really care
about any of these apps, except for TurboTax.  If someone got that one
to work, now *that* would be more interesting...

On the Linux/x86 front, Civilization: Call to Power and Myth II
Soulblighter now work, too.  (No, I don't play these games, I just had
the CDs which I bought in support of Loki and Linux desktop/gaming
laying around and though I'd give them a try.)

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/Makefile lia64/arch/ia64/Makefile
--- linux-davidm/arch/ia64/Makefile	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/Makefile	Mon Oct  1 20:40:02 2001
@@ -18,14 +18,14 @@
 EXTRA	=20
 CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -ffixed-r13 -mfixed-range=F10-f15,f32=
-f127 \
-	  -falign-functions2 --param max-inline-insns@0
+	  -falign-functions2
 # -ffunction-sections
 CFLAGS_KERNEL :=3D -mconstant-gp
=20
 GCC_VERSION=3D$(shell $(CROSS_COMPILE)$(HOSTCC) -v 2>&1 | fgrep 'gcc versi=
on' | cut -f3 -d' ' | cut -f1 -d'.')
=20
 ifneq ($(GCC_VERSION),2)
-	CFLAGS +=3D -frename-registers
+	CFLAGS +=3D -frename-registers --param max-inline-insns@0
 endif
=20
 ifeq ($(CONFIG_ITANIUM_BSTEP_SPECIFIC),y)
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c lia64/arch/ia64/ia32/b=
infmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/ia32/binfmt_elf32.c	Mon Oct  1 20:40:37 2001
@@ -72,7 +72,6 @@
 ia64_elf32_init (struct pt_regs *regs)
 {
 	struct vm_area_struct *vma;
-	int nr;
=20
 	/*
 	 * Map GDT and TSS below 4GB, where the processor can find them.  We need=
 to map
@@ -119,27 +118,6 @@
 		up_write(&current->mm->mmap_sem);
 	}
=20
-	nr =3D smp_processor_id();
-
-	/* Setup the segment selectors */
-	regs->r16 =3D (__USER_DS << 16) | __USER_DS; /* ES =3D DS, GS, FS are zer=
o */
-	regs->r17 =3D (__USER_DS << 16) | __USER_CS; /* SS, CS; ia32_load_state()=
 sets TSS and LDT */
-
-	/* Setup the segment descriptors */
-	regs->r24 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_DS >> 3]);		/* ESD */
-	regs->r27 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_DS >> 3]);		/* DSD */
-	regs->r28 =3D 0;								/* FSD (null) */
-	regs->r29 =3D 0;								/* GSD (null) */
-	regs->r30 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[_LDT(nr)]);			/* LDTD */
-
-	/*
-	 * Setup GDTD.  Note: GDTD is the descrambled version of the pseudo-descr=
iptor
-	 * format defined by Figure 3-11 "Pseudo-Descriptor Format" in the IA-32
-	 * architecture manual.
-	 */
-	regs->r31 =3D IA32_SEG_UNSCRAMBLE(IA32_SEG_DESCRIPTOR(IA32_GDT_OFFSET, IA=
32_PAGE_SIZE - 1, 0,
-							    0, 0, 0, 0, 0, 0));
-
 	ia64_psr(regs)->ac =3D 0;		/* turn off alignment checking */
 	regs->loadrs =3D 0;
 	/*
@@ -160,10 +138,19 @@
 	current->thread.fcr =3D IA32_FCR_DEFAULT;
 	current->thread.fir =3D 0;
 	current->thread.fdr =3D 0;
-	current->thread.csd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_CS >> 3]);
-	current->thread.ssd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[__USER_DS >> 3]);
-	current->thread.tssd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[_TSS(nr)]);
=20
+	/*
+	 * Setup GDTD.  Note: GDTD is the descrambled version of the pseudo-descr=
iptor
+	 * format defined by Figure 3-11 "Pseudo-Descriptor Format" in the IA-32
+	 * architecture manual.
+	 */
+	regs->r31 =3D IA32_SEG_UNSCRAMBLE(IA32_SEG_DESCRIPTOR(IA32_GDT_OFFSET, IA=
32_PAGE_SIZE - 1, 0,
+							    0, 0, 0, 0, 0, 0));
+	/* Setup the segment selectors */
+	regs->r16 =3D (__USER_DS << 16) | __USER_DS; /* ES =3D DS, GS, FS are zer=
o */
+	regs->r17 =3D (__USER_DS << 16) | __USER_CS; /* SS, CS; ia32_load_state()=
 sets TSS and LDT */
+
+	ia32_load_segment_descriptors(current);
 	ia32_load_state(current);
 }
=20
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S lia64/arch/ia64/ia32/ia3=
2_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/ia32/ia32_entry.S	Mon Oct  1 20:40:51 2001
@@ -48,31 +48,42 @@
 	br.ret.sptk.many rp
 END(ia32_clone)
=20
-	//
-	// Get possibly unaligned sigmask argument into an aligned
-	//   kernel buffer
-GLOBAL_ENTRY(ia32_rt_sigsuspend)
-	// We'll cheat and not do an alloc here since we are ultimately
-	// going to do a simple branch to the IA64 sys_rt_sigsuspend.
-	// r32 is still the first argument which is the signal mask.
-	// We copy this 4-byte aligned value to an 8-byte aligned buffer
-	// in the task structure and then jump to the IA64 code.
-	zxt4 r32=3Dr32
-	;;
-	EX(.Lfail, ld4 r2=3D[r32],4)		// load low part of sigmask
-	;;
-	EX(.Lfail, ld4 r3=3D[r32])		// load high part of sigmask
-	adds r32=3DIA64_TASK_THREAD_SIGMASK_OFFSET,r13
-	;;
-	st8 [r32]=3Dr2
-	adds r10=3DIA64_TASK_THREAD_SIGMASK_OFFSET+4,r13
+ENTRY(sys32_rt_sigsuspend)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
+	alloc loc1=3Dar.pfs,8,2,3,0		// preserve all eight input regs
+	mov loc0=3Drp
+	mov out0=3Din0				// mask
+	mov out1=3Din1				// sigsetsize
+	mov out2=3Dsp				// out2 =3D &sigscratch
+	.fframe 16
+	adds sp=3D-16,sp				// allocate dummy "sigscratch"
 	;;
+	.body
+	br.call.sptk.many rp=3Dia32_rt_sigsuspend
+1:	.restore sp
+	adds sp=16,sp
+	mov rp=3Dloc0
+	mov ar.pfs=3Dloc1
+	br.ret.sptk.many rp
+END(sys32_rt_sigsuspend)
=20
-	st4 [r10]=3Dr3
-	br.cond.sptk.many sys_rt_sigsuspend
-
-.Lfail:	br.ret.sptk.many rp	// failed to read sigmask
-END(ia32_rt_sigsuspend)
+ENTRY(sys32_sigsuspend)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
+	alloc loc1=3Dar.pfs,8,2,3,0		// preserve all eight input regs
+	mov loc0=3Drp
+	mov out0=3Din2				// mask (first two args are ignored)
+	;;
+	mov out1=3Dsp				// out1 =3D &sigscratch
+	.fframe 16
+	adds sp=3D-16,sp				// allocate dummy "sigscratch"
+	.body
+	br.call.sptk.many rp=3Dia32_sigsuspend
+1:	.restore sp
+	adds sp=16,sp
+	mov rp=3Dloc0
+	mov ar.pfs=3Dloc1
+	br.ret.sptk.many rp
+END(sys32_sigsuspend)
=20
 GLOBAL_ENTRY(ia32_ret_from_clone)
 	PT_REGS_UNWIND_INFO(0)
@@ -236,7 +247,7 @@
 	data8 sys32_ni_syscall
 	data8 sys_setreuid	/* 16-bit version */	  /* 70 */
 	data8 sys_setregid	/* 16-bit version */
-	data8 sys32_ni_syscall
+	data8 sys32_sigsuspend
 	data8 sys32_sigpending
 	data8 sys_sethostname
 	data8 sys32_setrlimit	  /* 75 */
@@ -343,7 +354,7 @@
 	data8 sys_rt_sigpending
 	data8 sys32_rt_sigtimedwait
 	data8 sys32_rt_sigqueueinfo
-	data8 ia32_rt_sigsuspend
+	data8 sys32_rt_sigsuspend
 	data8 sys32_pread	  /* 180 */
 	data8 sys32_pwrite
 	data8 sys_chown	/* 16-bit version */
diff -urN linux-davidm/arch/ia64/ia32/ia32_ioctl.c lia64/arch/ia64/ia32/ia3=
2_ioctl.c
--- linux-davidm/arch/ia64/ia32/ia32_ioctl.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/ia32/ia32_ioctl.c	Mon Oct  1 20:41:05 2001
@@ -3,6 +3,8 @@
  *
  * Copyright (C) 2000 VA Linux Co
  * Copyright (C) 2000 Don Dugger <n0ano@valinux.com>
+ * Copyright (C) 2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
 #include <linux/types.h>
@@ -22,8 +24,12 @@
 #include <linux/if_ppp.h>
 #include <linux/ixjuser.h>
 #include <linux/i2o-dev.h>
+
+#include <asm/ia32.h>
+
 #include <../drivers/char/drm/drm.h>
=20
+
 #define IOCTL_NR(a)	((a) & ~(_IOC_SIZEMASK << _IOC_SIZESHIFT))
=20
 #define DO_IOCTL(fd, cmd, arg) ({			\
@@ -38,171 +44,195 @@
=20
 #define P(i)	((void *)(unsigned long)(i))
=20
-
 asmlinkage long sys_ioctl(unsigned int fd, unsigned int cmd, unsigned long=
 arg);
=20
+static long
+put_dirent32 (struct dirent *d, struct linux32_dirent *d32)
+{
+	size_t namelen =3D strlen(d->d_name);
+
+	return (put_user(d->d_ino, &d32->d_ino)
+		|| put_user(d->d_off, &d32->d_off)
+		|| put_user(d->d_reclen, &d32->d_reclen)
+		|| copy_to_user(d32->d_name, d->d_name, namelen + 1));
+}
+
 asmlinkage long
 sys32_ioctl (unsigned int fd, unsigned int cmd, unsigned int arg)
 {
 	long ret;
=20
 	switch (IOCTL_NR(cmd)) {
-
-	case IOCTL_NR(DRM_IOCTL_VERSION):
-		{
-			drm_version_t ver;
-			struct {
-				int	version_major;
-				int	version_minor;
-				int	version_patchlevel;
-				unsigned int name_len;
-				unsigned int name; /* pointer */
-				unsigned int date_len;
-				unsigned int date; /* pointer */
-				unsigned int desc_len;
-				unsigned int desc; /* pointer */
-			} ver32;
-
-			if (copy_from_user(&ver32, P(arg), sizeof(ver32)))
-				return -EFAULT;
-			ver.name_len =3D ver32.name_len;
-			ver.name =3D P(ver32.name);
-			ver.date_len =3D ver32.date_len;
-			ver.date =3D P(ver32.date);
-			ver.desc_len =3D ver32.desc_len;
-			ver.desc =3D P(ver32.desc);
-			ret =3D DO_IOCTL(fd, cmd, &ver);
-			if (ret >=3D 0) {
-				ver32.version_major =3D ver.version_major;
-				ver32.version_minor =3D ver.version_minor;
-				ver32.version_patchlevel =3D ver.version_patchlevel;
-				ver32.name_len =3D ver.name_len;
-				ver32.date_len =3D ver.date_len;
-				ver32.desc_len =3D ver.desc_len;
-				if (copy_to_user(P(arg), &ver32, sizeof(ver32)))
-					return -EFAULT;
-			}
-			return ret;
-		}
-
-	case IOCTL_NR(DRM_IOCTL_GET_UNIQUE):
-		{
-			drm_unique_t un;
-			struct {
-				unsigned int unique_len;
-				unsigned int unique;
-			} un32;
-
-			if (copy_from_user(&un32, P(arg), sizeof(un32)))
-				return -EFAULT;
-			un.unique_len =3D un32.unique_len;
-			un.unique =3D P(un32.unique);
-			ret =3D DO_IOCTL(fd, cmd, &un);
-			if (ret >=3D 0) {
-				un32.unique_len =3D un.unique_len;
-				if (copy_to_user(P(arg), &un32, sizeof(un32)))
-					return -EFAULT;
-			}
-			return(ret);
-		}
-	case IOCTL_NR(DRM_IOCTL_SET_UNIQUE):
-	case IOCTL_NR(DRM_IOCTL_ADD_MAP):
-	case IOCTL_NR(DRM_IOCTL_ADD_BUFS):
-	case IOCTL_NR(DRM_IOCTL_MARK_BUFS):
-	case IOCTL_NR(DRM_IOCTL_INFO_BUFS):
-	case IOCTL_NR(DRM_IOCTL_MAP_BUFS):
-	case IOCTL_NR(DRM_IOCTL_FREE_BUFS):
-	case IOCTL_NR(DRM_IOCTL_ADD_CTX):
-	case IOCTL_NR(DRM_IOCTL_RM_CTX):
-	case IOCTL_NR(DRM_IOCTL_MOD_CTX):
-	case IOCTL_NR(DRM_IOCTL_GET_CTX):
-	case IOCTL_NR(DRM_IOCTL_SWITCH_CTX):
-	case IOCTL_NR(DRM_IOCTL_NEW_CTX):
-	case IOCTL_NR(DRM_IOCTL_RES_CTX):
-
-	case IOCTL_NR(DRM_IOCTL_AGP_ACQUIRE):
-	case IOCTL_NR(DRM_IOCTL_AGP_RELEASE):
-	case IOCTL_NR(DRM_IOCTL_AGP_ENABLE):
-	case IOCTL_NR(DRM_IOCTL_AGP_INFO):
-	case IOCTL_NR(DRM_IOCTL_AGP_ALLOC):
-	case IOCTL_NR(DRM_IOCTL_AGP_FREE):
-	case IOCTL_NR(DRM_IOCTL_AGP_BIND):
-	case IOCTL_NR(DRM_IOCTL_AGP_UNBIND):
-
-	/* Mga specific ioctls */
-
-	case IOCTL_NR(DRM_IOCTL_MGA_INIT):
-
-	/* I810 specific ioctls */
-
-	case IOCTL_NR(DRM_IOCTL_I810_GETBUF):
-	case IOCTL_NR(DRM_IOCTL_I810_COPY):
-
-	case IOCTL_NR(VFAT_IOCTL_READDIR_BOTH):
-	case IOCTL_NR(VFAT_IOCTL_READDIR_SHORT):
-	case IOCTL_NR(MTIOCGET):
-	case IOCTL_NR(MTIOCPOS):
-	case IOCTL_NR(MTIOCGETCONFIG):
-	case IOCTL_NR(MTIOCSETCONFIG):
-	case IOCTL_NR(PPPIOCSCOMPRESS):
-	case IOCTL_NR(PPPIOCGIDLE):
-	case IOCTL_NR(NCP_IOC_GET_FS_INFO_V2):
-	case IOCTL_NR(NCP_IOC_GETOBJECTNAME):
-	case IOCTL_NR(NCP_IOC_SETOBJECTNAME):
-	case IOCTL_NR(NCP_IOC_GETPRIVATEDATA):
-	case IOCTL_NR(NCP_IOC_SETPRIVATEDATA):
-	case IOCTL_NR(NCP_IOC_GETMOUNTUID2):
-	case IOCTL_NR(CAPI_MANUFACTURER_CMD):
-	case IOCTL_NR(VIDIOCGTUNER):
-	case IOCTL_NR(VIDIOCSTUNER):
-	case IOCTL_NR(VIDIOCGWIN):
-	case IOCTL_NR(VIDIOCSWIN):
-	case IOCTL_NR(VIDIOCGFBUF):
-	case IOCTL_NR(VIDIOCSFBUF):
-	case IOCTL_NR(MGSL_IOCSPARAMS):
-	case IOCTL_NR(MGSL_IOCGPARAMS):
-	case IOCTL_NR(ATM_GETNAMES):
-	case IOCTL_NR(ATM_GETLINKRATE):
-	case IOCTL_NR(ATM_GETTYPE):
-	case IOCTL_NR(ATM_GETESI):
-	case IOCTL_NR(ATM_GETADDR):
-	case IOCTL_NR(ATM_RSTADDR):
-	case IOCTL_NR(ATM_ADDADDR):
-	case IOCTL_NR(ATM_DELADDR):
-	case IOCTL_NR(ATM_GETCIRANGE):
-	case IOCTL_NR(ATM_SETCIRANGE):
-	case IOCTL_NR(ATM_SETESI):
-	case IOCTL_NR(ATM_SETESIF):
-	case IOCTL_NR(ATM_GETSTAT):
-	case IOCTL_NR(ATM_GETSTATZ):
-	case IOCTL_NR(ATM_GETLOOP):
-	case IOCTL_NR(ATM_SETLOOP):
-	case IOCTL_NR(ATM_QUERYLOOP):
-	case IOCTL_NR(ENI_SETMULT):
-	case IOCTL_NR(NS_GETPSTAT):
-	/* case IOCTL_NR(NS_SETBUFLEV): This is a duplicate case with ZATM_GETPOO=
LZ */
-	case IOCTL_NR(ZATM_GETPOOLZ):
-	case IOCTL_NR(ZATM_GETPOOL):
-	case IOCTL_NR(ZATM_SETPOOL):
-	case IOCTL_NR(ZATM_GETTHIST):
-	case IOCTL_NR(IDT77105_GETSTAT):
-	case IOCTL_NR(IDT77105_GETSTATZ):
-	case IOCTL_NR(IXJCTL_TONE_CADENCE):
-	case IOCTL_NR(IXJCTL_FRAMES_READ):
-	case IOCTL_NR(IXJCTL_FRAMES_WRITTEN):
-	case IOCTL_NR(IXJCTL_READ_WAIT):
-	case IOCTL_NR(IXJCTL_WRITE_WAIT):
-	case IOCTL_NR(IXJCTL_DRYBUFFER_READ):
-	case IOCTL_NR(I2OHRTGET):
-	case IOCTL_NR(I2OLCTGET):
-	case IOCTL_NR(I2OPARMSET):
-	case IOCTL_NR(I2OPARMGET):
-	case IOCTL_NR(I2OSWDL):
-	case IOCTL_NR(I2OSWUL):
-	case IOCTL_NR(I2OSWDEL):
-	case IOCTL_NR(I2OHTML):
+	      case IOCTL_NR(VFAT_IOCTL_READDIR_SHORT):
+	      case IOCTL_NR(VFAT_IOCTL_READDIR_BOTH): {
+		      struct linux32_dirent *d32 =3D P(arg);
+		      struct dirent d[2];
+
+		      ret =3D DO_IOCTL(fd, _IOR('r', _IOC_NR(cmd),
+					      struct dirent [2]),
+				     (unsigned long) d);
+		      if (ret < 0)
+			  return ret;
+
+		      if (put_dirent32(d, d32) || put_dirent32(d + 1, d32 + 1))
+			  return -EFAULT;
+
+		      return ret;
+	      }
+
+	      case IOCTL_NR(DRM_IOCTL_VERSION):
+	      {
+		      drm_version_t ver;
+		      struct {
+			      int	version_major;
+			      int	version_minor;
+			      int	version_patchlevel;
+			      unsigned int name_len;
+			      unsigned int name; /* pointer */
+			      unsigned int date_len;
+			      unsigned int date; /* pointer */
+			      unsigned int desc_len;
+			      unsigned int desc; /* pointer */
+		      } ver32;
+
+		      if (copy_from_user(&ver32, P(arg), sizeof(ver32)))
+			      return -EFAULT;
+		      ver.name_len =3D ver32.name_len;
+		      ver.name =3D P(ver32.name);
+		      ver.date_len =3D ver32.date_len;
+		      ver.date =3D P(ver32.date);
+		      ver.desc_len =3D ver32.desc_len;
+		      ver.desc =3D P(ver32.desc);
+		      ret =3D DO_IOCTL(fd, DRM_IOCTL_VERSION, &ver);
+		      if (ret >=3D 0) {
+			      ver32.version_major =3D ver.version_major;
+			      ver32.version_minor =3D ver.version_minor;
+			      ver32.version_patchlevel =3D ver.version_patchlevel;
+			      ver32.name_len =3D ver.name_len;
+			      ver32.date_len =3D ver.date_len;
+			      ver32.desc_len =3D ver.desc_len;
+			      if (copy_to_user(P(arg), &ver32, sizeof(ver32)))
+				      return -EFAULT;
+		      }
+		      return ret;
+	      }
+
+	      case IOCTL_NR(DRM_IOCTL_GET_UNIQUE):
+	      {
+		      drm_unique_t un;
+		      struct {
+			      unsigned int unique_len;
+			      unsigned int unique;
+		      } un32;
+
+		      if (copy_from_user(&un32, P(arg), sizeof(un32)))
+			      return -EFAULT;
+		      un.unique_len =3D un32.unique_len;
+		      un.unique =3D P(un32.unique);
+		      ret =3D DO_IOCTL(fd, DRM_IOCTL_GET_UNIQUE, &un);
+		      if (ret >=3D 0) {
+			      un32.unique_len =3D un.unique_len;
+			      if (copy_to_user(P(arg), &un32, sizeof(un32)))
+				      return -EFAULT;
+		      }
+		      return ret;
+	      }
+	      case IOCTL_NR(DRM_IOCTL_SET_UNIQUE):
+	      case IOCTL_NR(DRM_IOCTL_ADD_MAP):
+	      case IOCTL_NR(DRM_IOCTL_ADD_BUFS):
+	      case IOCTL_NR(DRM_IOCTL_MARK_BUFS):
+	      case IOCTL_NR(DRM_IOCTL_INFO_BUFS):
+	      case IOCTL_NR(DRM_IOCTL_MAP_BUFS):
+	      case IOCTL_NR(DRM_IOCTL_FREE_BUFS):
+	      case IOCTL_NR(DRM_IOCTL_ADD_CTX):
+	      case IOCTL_NR(DRM_IOCTL_RM_CTX):
+	      case IOCTL_NR(DRM_IOCTL_MOD_CTX):
+	      case IOCTL_NR(DRM_IOCTL_GET_CTX):
+	      case IOCTL_NR(DRM_IOCTL_SWITCH_CTX):
+	      case IOCTL_NR(DRM_IOCTL_NEW_CTX):
+	      case IOCTL_NR(DRM_IOCTL_RES_CTX):
+
+	      case IOCTL_NR(DRM_IOCTL_AGP_ACQUIRE):
+	      case IOCTL_NR(DRM_IOCTL_AGP_RELEASE):
+	      case IOCTL_NR(DRM_IOCTL_AGP_ENABLE):
+	      case IOCTL_NR(DRM_IOCTL_AGP_INFO):
+	      case IOCTL_NR(DRM_IOCTL_AGP_ALLOC):
+	      case IOCTL_NR(DRM_IOCTL_AGP_FREE):
+	      case IOCTL_NR(DRM_IOCTL_AGP_BIND):
+	      case IOCTL_NR(DRM_IOCTL_AGP_UNBIND):
+
+		/* Mga specific ioctls */
+
+	      case IOCTL_NR(DRM_IOCTL_MGA_INIT):
+
+		/* I810 specific ioctls */
+
+	      case IOCTL_NR(DRM_IOCTL_I810_GETBUF):
+	      case IOCTL_NR(DRM_IOCTL_I810_COPY):
+
+	      case IOCTL_NR(MTIOCGET):
+	      case IOCTL_NR(MTIOCPOS):
+	      case IOCTL_NR(MTIOCGETCONFIG):
+	      case IOCTL_NR(MTIOCSETCONFIG):
+	      case IOCTL_NR(PPPIOCSCOMPRESS):
+	      case IOCTL_NR(PPPIOCGIDLE):
+	      case IOCTL_NR(NCP_IOC_GET_FS_INFO_V2):
+	      case IOCTL_NR(NCP_IOC_GETOBJECTNAME):
+	      case IOCTL_NR(NCP_IOC_SETOBJECTNAME):
+	      case IOCTL_NR(NCP_IOC_GETPRIVATEDATA):
+	      case IOCTL_NR(NCP_IOC_SETPRIVATEDATA):
+	      case IOCTL_NR(NCP_IOC_GETMOUNTUID2):
+	      case IOCTL_NR(CAPI_MANUFACTURER_CMD):
+	      case IOCTL_NR(VIDIOCGTUNER):
+	      case IOCTL_NR(VIDIOCSTUNER):
+	      case IOCTL_NR(VIDIOCGWIN):
+	      case IOCTL_NR(VIDIOCSWIN):
+	      case IOCTL_NR(VIDIOCGFBUF):
+	      case IOCTL_NR(VIDIOCSFBUF):
+	      case IOCTL_NR(MGSL_IOCSPARAMS):
+	      case IOCTL_NR(MGSL_IOCGPARAMS):
+	      case IOCTL_NR(ATM_GETNAMES):
+	      case IOCTL_NR(ATM_GETLINKRATE):
+	      case IOCTL_NR(ATM_GETTYPE):
+	      case IOCTL_NR(ATM_GETESI):
+	      case IOCTL_NR(ATM_GETADDR):
+	      case IOCTL_NR(ATM_RSTADDR):
+	      case IOCTL_NR(ATM_ADDADDR):
+	      case IOCTL_NR(ATM_DELADDR):
+	      case IOCTL_NR(ATM_GETCIRANGE):
+	      case IOCTL_NR(ATM_SETCIRANGE):
+	      case IOCTL_NR(ATM_SETESI):
+	      case IOCTL_NR(ATM_SETESIF):
+	      case IOCTL_NR(ATM_GETSTAT):
+	      case IOCTL_NR(ATM_GETSTATZ):
+	      case IOCTL_NR(ATM_GETLOOP):
+	      case IOCTL_NR(ATM_SETLOOP):
+	      case IOCTL_NR(ATM_QUERYLOOP):
+	      case IOCTL_NR(ENI_SETMULT):
+	      case IOCTL_NR(NS_GETPSTAT):
+		/* case IOCTL_NR(NS_SETBUFLEV): This is a duplicate case with ZATM_GETPO=
OLZ */
+	      case IOCTL_NR(ZATM_GETPOOLZ):
+	      case IOCTL_NR(ZATM_GETPOOL):
+	      case IOCTL_NR(ZATM_SETPOOL):
+	      case IOCTL_NR(ZATM_GETTHIST):
+	      case IOCTL_NR(IDT77105_GETSTAT):
+	      case IOCTL_NR(IDT77105_GETSTATZ):
+	      case IOCTL_NR(IXJCTL_TONE_CADENCE):
+	      case IOCTL_NR(IXJCTL_FRAMES_READ):
+	      case IOCTL_NR(IXJCTL_FRAMES_WRITTEN):
+	      case IOCTL_NR(IXJCTL_READ_WAIT):
+	      case IOCTL_NR(IXJCTL_WRITE_WAIT):
+	      case IOCTL_NR(IXJCTL_DRYBUFFER_READ):
+	      case IOCTL_NR(I2OHRTGET):
+	      case IOCTL_NR(I2OLCTGET):
+	      case IOCTL_NR(I2OPARMSET):
+	      case IOCTL_NR(I2OPARMGET):
+	      case IOCTL_NR(I2OSWDL):
+	      case IOCTL_NR(I2OSWUL):
+	      case IOCTL_NR(I2OSWDEL):
+	      case IOCTL_NR(I2OHTML):
 		break;
-	default:
+	      default:
 		return sys_ioctl(fd, cmd, (unsigned long)arg);
=20
 	}
diff -urN linux-davidm/arch/ia64/ia32/ia32_ldt.c lia64/arch/ia64/ia32/ia32_=
ldt.c
--- linux-davidm/arch/ia64/ia32/ia32_ldt.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/ia32/ia32_ldt.c	Mon Oct  1 20:41:25 2001
@@ -64,6 +64,7 @@
 {
 	struct ia32_modify_ldt_ldt_s ldt_info;
 	__u64 entry;
+	int ret;
=20
 	if (bytecount !=3D sizeof(ldt_info))
 		return -EINVAL;
@@ -99,7 +100,9 @@
 	 * memory, but we still need to guard against out-of-memory, hence we mus=
t use
 	 * put_user().
 	 */
-	return __put_user(entry, (__u64 *) IA32_LDT_OFFSET + ldt_info.entry_numbe=
r);
+	ret =3D __put_user(entry, (__u64 *) IA32_LDT_OFFSET + ldt_info.entry_numb=
er);
+	ia32_load_segment_descriptors(current);
+	return ret;
 }
=20
 asmlinkage int
diff -urN linux-davidm/arch/ia64/ia32/ia32_signal.c lia64/arch/ia64/ia32/ia=
32_signal.c
--- linux-davidm/arch/ia64/ia32/ia32_signal.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/ia32/ia32_signal.c	Mon Oct  1 20:41:37 2001
@@ -29,6 +29,10 @@
 #include <asm/segment.h>
 #include <asm/ia32.h>
=20
+#include "../kernel/sigframe.h"
+
+#define A(__x)		((unsigned long)(__x))
+
 #define DEBUG_SIG	0
 #define _BLOCKABLE	(~(sigmask(SIGKILL) | sigmask(SIGSTOP)))
=20
@@ -139,7 +143,226 @@
 	return err;
 }
=20
+static inline void
+sigact_set_handler (struct k_sigaction *sa, unsigned int handler, unsigned=
 int restorer)
+{
+	if (handler + 1 <=3D 2)
+		/* SIG_DFL, SIG_IGN, or SIG_ERR: must sign-extend to 64-bits */
+		sa->sa.sa_handler =3D (__sighandler_t) A((int) handler);
+	else
+		sa->sa.sa_handler =3D (__sighandler_t) (((unsigned long) restorer << 32)=
 | handler);
+}
+
+asmlinkage long
+ia32_rt_sigsuspend (sigset32_t *uset, unsigned int sigsetsize, struct sigs=
cratch *scr)
+{
+	extern long ia64_do_signal (sigset_t *oldset, struct sigscratch *scr, lon=
g in_syscall);
+	sigset_t oldset, set;
+
+	scr->scratch_unat =3D 0;	/* avoid leaking kernel bits to user level */
+	memset(&set, 0, sizeof(&set));
+
+	if (sigsetsize > sizeof(sigset_t))
+		return -EINVAL;
+
+	if (copy_from_user(&set.sig, &uset->sig, sigsetsize))
+		return -EFAULT;
+
+	sigdelsetmask(&set, ~_BLOCKABLE);
+
+	spin_lock_irq(&current->sigmask_lock);
+	{
+		oldset =3D current->blocked;
+		current->blocked =3D set;
+		recalc_sigpending(current);
+	}
+	spin_unlock_irq(&current->sigmask_lock);
+
+	/*
+	 * The return below usually returns to the signal handler.  We need to pr=
e-set the
+	 * correct error code here to ensure that the right values get saved in s=
igcontext
+	 * by ia64_do_signal.
+	 */
+	scr->pt.r8 =3D -EINTR;
+	while (1) {
+		current->state =3D TASK_INTERRUPTIBLE;
+		schedule();
+		if (ia64_do_signal(&oldset, scr, 1))
+			return -EINTR;
+	}
+}
+
+asmlinkage long
+ia32_sigsuspend (unsigned int mask, struct sigscratch *scr)
+{
+	return ia32_rt_sigsuspend((sigset32_t *)&mask, sizeof(mask), scr);
+}
+
+asmlinkage long
+sys32_signal (int sig, unsigned int handler)
+{
+	struct k_sigaction new_sa, old_sa;
+	int ret;
+
+	sigact_set_handler(&new_sa, handler, 0);
+	new_sa.sa.sa_flags =3D SA_ONESHOT | SA_NOMASK;
+
+	ret =3D do_sigaction(sig, &new_sa, &old_sa);
+
+	return ret ? ret : IA32_SA_HANDLER(&old_sa);
+}
+
+asmlinkage long
+sys32_rt_sigaction (int sig, struct sigaction32 *act,
+		    struct sigaction32 *oact, unsigned int sigsetsize)
+{
+	struct k_sigaction new_ka, old_ka;
+	unsigned int handler, restorer;
+	int ret;
+
+	/* XXX: Don't preclude handling different sized sigset_t's.  */
+	if (sigsetsize !=3D sizeof(sigset32_t))
+		return -EINVAL;
+
+	if (act) {
+		ret =3D get_user(handler, &act->sa_handler);
+		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
+		ret |=3D get_user(restorer, &act->sa_restorer);
+		ret |=3D copy_from_user(&new_ka.sa.sa_mask, &act->sa_mask, sizeof(sigset=
32_t));
+		if (ret)
+			return -EFAULT;
+
+		sigact_set_handler(&new_ka, handler, restorer);
+	}
+
+	ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
=20
+	if (!ret && oact) {
+		ret =3D put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
+		ret |=3D put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret |=3D put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
+		ret |=3D copy_to_user(&oact->sa_mask, &old_ka.sa.sa_mask, sizeof(sigset3=
2_t));
+	}
+	return ret;
+}
+
+
+extern asmlinkage long sys_rt_sigprocmask (int how, sigset_t *set, sigset_=
t *oset,
+					   size_t sigsetsize);
+
+asmlinkage long
+sys32_rt_sigprocmask (int how, sigset32_t *set, sigset32_t *oset, unsigned=
 int sigsetsize)
+{
+	mm_segment_t old_fs =3D get_fs();
+	sigset_t s;
+	long ret;
+
+	if (sigsetsize > sizeof(s))
+		return -EINVAL;
+
+	if (set) {
+		memset(&s, 0, sizeof(s));
+		if (copy_from_user(&s.sig, set, sigsetsize))
+			return -EFAULT;
+	}
+	set_fs(KERNEL_DS);
+	ret =3D sys_rt_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL, sizeof=
(s));
+	set_fs(old_fs);
+	if (ret)
+		return ret;
+	if (oset) {
+		if (copy_to_user(oset, &s.sig, sigsetsize))
+			return -EFAULT;
+	}
+	return 0;
+}
+
+asmlinkage long
+sys32_sigprocmask (int how, unsigned int *set, unsigned int *oset)
+{
+	return sys32_rt_sigprocmask(how, (sigset32_t *) set, (sigset32_t *) oset,=
 sizeof(*set));
+}
+
+asmlinkage long
+sys32_rt_sigtimedwait (sigset32_t *uthese, siginfo_t32 *uinfo, struct time=
spec32 *uts,
+		       unsigned int sigsetsize)
+{
+	extern asmlinkage long sys_rt_sigtimedwait (const sigset_t *, siginfo_t *,
+						    const struct timespec *, size_t);
+	extern int copy_siginfo_to_user32 (siginfo_t32 *, siginfo_t *);
+	mm_segment_t old_fs =3D get_fs();
+	struct timespec t;
+	siginfo_t info;
+	sigset_t s;
+	int ret;
+
+	if (copy_from_user(&s.sig, uthese, sizeof(sigset32_t)))
+		return -EFAULT;
+	if (uts) {
+		ret =3D get_user(t.tv_sec, &uts->tv_sec);
+		ret |=3D get_user(t.tv_nsec, &uts->tv_nsec);
+		if (ret)
+			return -EFAULT;
+	}
+	set_fs(KERNEL_DS);
+	ret =3D sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
+	set_fs(old_fs);
+	if (ret >=3D 0 && uinfo) {
+		if (copy_siginfo_to_user32(uinfo, &info))
+			return -EFAULT;
+	}
+	return ret;
+}
+
+asmlinkage long
+sys32_rt_sigqueueinfo (int pid, int sig, siginfo_t32 *uinfo)
+{
+	extern asmlinkage long sys_rt_sigqueueinfo (int, int, siginfo_t *);
+	extern int copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 *from);
+	mm_segment_t old_fs =3D get_fs();
+	siginfo_t info;
+	int ret;
+
+	if (copy_siginfo_from_user32(&info, uinfo))
+		return -EFAULT;
+	set_fs(KERNEL_DS);
+	ret =3D sys_rt_sigqueueinfo(pid, sig, &info);
+	set_fs(old_fs);
+	return ret;
+}
+
+asmlinkage long
+sys32_sigaction (int sig, struct old_sigaction32 *act, struct old_sigactio=
n32 *oact)
+{
+	struct k_sigaction new_ka, old_ka;
+	unsigned int handler, restorer;
+	int ret;
+
+	if (act) {
+		old_sigset32_t mask;
+
+		ret =3D get_user(handler, &act->sa_handler);
+		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
+		ret |=3D get_user(restorer, &act->sa_restorer);
+		ret |=3D get_user(mask, &act->sa_mask);
+		if (ret)
+			return ret;
+
+		sigact_set_handler(&new_ka, handler, restorer);
+		siginitset(&new_ka.sa.sa_mask, mask);
+	}
+
+	ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
+
+	if (!ret && oact) {
+		ret =3D put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
+		ret |=3D put_user(old_ka.sa.sa_flags, &oact->sa_flags);
+		ret |=3D put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
+		ret |=3D put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
+	}
+
+	return ret;
+}
=20
 static int
 setup_sigcontext_ia32 (struct sigcontext_ia32 *sc, struct _fpstate_ia32 *f=
pstate,
diff -urN linux-davidm/arch/ia64/ia32/ia32_support.c lia64/arch/ia64/ia32/i=
a32_support.c
--- linux-davidm/arch/ia64/ia32/ia32_support.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/ia32/ia32_support.c	Mon Oct  1 20:41:50 2001
@@ -9,6 +9,7 @@
  * 06/16/00	A. Mallick	added csd/ssd/tssd for ia32 thread context
  * 02/19/01	D. Mosberger	dropped tssd; it's not needed
  * 09/14/01	D. Mosberger	fixed memory management for gdt/tss page
+ * 09/29/01	D. Mosberger	added ia32_load_segment_descriptors()
  */
=20
 #include <linux/kernel.h>
@@ -29,6 +30,40 @@
 struct page *ia32_shared_page[(2*IA32_PAGE_SIZE + PAGE_SIZE - 1)/PAGE_SIZE=
];
 unsigned long *ia32_gdt;
=20
+static unsigned long
+load_desc (u16 selector)
+{
+	unsigned long *table, limit, index;
+
+	if (!selector)
+		return 0;
+	if (selector & IA32_SEGSEL_TI) {
+		table =3D (unsigned long *) IA32_LDT_OFFSET;
+		limit =3D IA32_LDT_ENTRIES;
+	} else {
+		table =3D ia32_gdt;
+		limit =3D IA32_PAGE_SIZE / sizeof(ia32_gdt[0]);
+	}
+	index =3D selector >> IA32_SEGSEL_INDEX_SHIFT;
+	if (index > limit)
+		return 0;
+	return IA32_SEG_UNSCRAMBLE(table[index]);
+}
+
+void
+ia32_load_segment_descriptors (struct task_struct *task)
+{
+	struct pt_regs *regs =3D ia64_task_regs(task);
+
+	/* Setup the segment descriptors */
+	regs->r24 =3D load_desc(regs->r16 >> 16);		/* ESD */
+	regs->r27 =3D load_desc(regs->r16 >>  0);		/* DSD */
+	regs->r28 =3D load_desc(regs->r16 >> 32);		/* FSD */
+	regs->r29 =3D load_desc(regs->r16 >> 48);		/* GSD */
+	task->thread.csd =3D load_desc(regs->r17 >>  0);	/* CSD */
+	task->thread.ssd =3D load_desc(regs->r17 >> 16);	/* SSD */
+}
+
 void
 ia32_save_state (struct task_struct *t)
 {
@@ -78,9 +113,12 @@
 	current->thread.old_iob =3D ia64_get_kr(IA64_KR_IO_BASE);
 	ia64_set_kr(IA64_KR_IO_BASE, IA32_IOBASE);
=20
-	/* load TSS and LDT while preserving SS and CS: */
+	/* LDT and TSS depend on CPU number, so they need to be reloaded on each =
context switch */
 	nr =3D smp_processor_id();
 	regs->r17 =3D (_TSS(nr) << 48) | (_LDT(nr) << 32) | (__u32) regs->r17;
+
+	regs->r30 =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[_LDT(nr)]);			/* LDTD */
+	current->thread.tssd =3D IA32_SEG_UNSCRAMBLE(ia32_gdt[_TSS(nr)]);		/* TSS=
D */
 }
=20
 /*
diff -urN linux-davidm/arch/ia64/ia32/ia32_traps.c lia64/arch/ia64/ia32/ia3=
2_traps.c
--- linux-davidm/arch/ia64/ia32/ia32_traps.c	Thu Jan  4 12:50:17 2001
+++ lia64/arch/ia64/ia32/ia32_traps.c	Mon Oct  1 20:42:01 2001
@@ -1,7 +1,12 @@
 /*
- * IA32 exceptions handler
+ * IA-32 exception handlers
  *
+ * Copyright (C) 2000 Asit K. Mallick <asit.k.mallick@intel.com>
+ * Copyright (C) 2001 Hewlett-Packard Co
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
+/*
  * 06/16/00	A. Mallick	added siginfo for most cases (close to IA32)
+ * 09/29/00	D. Mosberger	added ia32_intercept()
  */
=20
 #include <linux/kernel.h>
@@ -9,6 +14,26 @@
=20
 #include <asm/ia32.h>
 #include <asm/ptrace.h>
+
+int
+ia32_intercept (struct pt_regs *regs, unsigned long isr)
+{
+	switch ((isr >> 16) & 0xff) {
+	      case 0:	/* Instruction intercept fault */
+	      case 3:	/* Locked Data reference fault */
+	      case 1:	/* Gate intercept trap */
+		return -1;
+
+	      case 2:	/* System flag trap */
+		if (((isr >> 14) & 0x3) >=3D 2) {
+			/* MOV SS, POP SS instructions */
+			ia64_psr(regs)->id =3D 1;
+			return 0;
+		} else
+			return -1;
+	}
+	return -1;
+}
=20
 int
 ia32_exception (struct pt_regs *regs, unsigned long isr)
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c lia64/arch/ia64/ia32/sys_i=
a32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/ia32/sys_ia32.c	Mon Oct  1 20:42:37 2001
@@ -57,18 +57,39 @@
 #include <net/sock.h>
 #include <asm/ia32.h>
=20
+#define DEBUG	0
+
+#if DEBUG
+# define DBG(fmt...)	printk(KERN_DEBUG fmt)
+#else
+# define DBG(fmt...)
+#endif
+
 #define A(__x)		((unsigned long)(__x))
 #define AA(__x)		((unsigned long)(__x))
 #define ROUND_UP(x,a)	((__typeof__(x))(((unsigned long)(x) + ((a) - 1)) & =
~((a) - 1)))
 #define NAME_OFFSET(de) ((int) ((de)->d_name - (char *) (de)))
=20
+#define OFFSET4K(a)		((a) & 0xfff)
+#define PAGE_START(addr)	((addr) & PAGE_MASK)
+#define PAGE_OFF(addr)		((addr) & ~PAGE_MASK)
+
 extern asmlinkage long sys_execve (char *, char **, char **, struct pt_reg=
s *);
 extern asmlinkage long sys_mprotect (unsigned long, size_t, unsigned long);
 extern asmlinkage long sys_munmap (unsigned long, size_t);
+extern unsigned long arch_get_unmapped_area (struct file *, unsigned long,=
 unsigned long,
+					     unsigned long, unsigned long);
=20
 /* forward declaration: */
 asmlinkage long sys32_mprotect (unsigned int, unsigned int, int);
=20
+/*
+ * Anything that modifies or inspects ia32 user virtual memory must hold t=
his semaphore
+ * while doing so.
+ */
+/* XXX make per-mm: */
+static DECLARE_MUTEX(ia32_mmap_sem);
+
 static int
 nargs (unsigned int arg, char **ap)
 {
@@ -221,117 +242,200 @@
 	return ret;
 }
=20
-#define OFFSET4K(a)	((a) & 0xfff)
-
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
=20
-/*
- * Determine whether address ADDR is readable.  This must be done *without=
* actually
- * touching memory because otherwise the stack auto-expansion may *make* t=
he address
- * readable, which is not at all what we want. --davidm 01/09/20
- */
-static inline long
-is_readable (unsigned long addr)
+
+static int
+get_page_prot (unsigned long addr)
 {
 	struct vm_area_struct *vma =3D find_vma(current->mm, addr);
-	return vma && (vma->vm_start <=3D addr) && (vma->vm_flags & VM_READ);
+	int prot =3D 0;
+
+	if (!vma || vma->vm_start > addr)
+		return 0;
+
+	if (vma->vm_flags & VM_READ)
+		prot |=3D PROT_READ;
+	if (vma->vm_flags & VM_WRITE)
+		prot |=3D PROT_WRITE;
+	if (vma->vm_flags & VM_EXEC)
+		prot |=3D PROT_EXEC;
+	return prot;
 }
=20
+/*
+ * Map a subpage by creating an anonymous page that contains the union of =
the old page and
+ * the subpage.
+ */
 static unsigned long
-do_mmap_fake (struct file *file, unsigned long addr, unsigned long len, in=
t prot, int flags,
+mmap_subpage (struct file *file, unsigned long start, unsigned long end, i=
nt prot, int flags,
 	      loff_t off)
 {
-	unsigned long faddr =3D (addr & PAGE_MASK), end, front_len, back_len, ret=
val;
-	void *front =3D 0, *back =3D 0;
+	void *page =3D (void *) get_zeroed_page(GFP_KERNEL);
 	struct inode *inode;
+	unsigned long ret;
+	int old_prot =3D get_page_prot(start);
=20
-	/*
-	 * Allow any kind of access: this lets us avoid having to figure out what=
 the
-	 * protection of the partial front and back pages is...
-	 */
-	prot |=3D PROT_WRITE;
-
-	if (OFFSET4K(addr))
-		return -EINVAL;
+	DBG("mmap_subpage(file=3D%p,start=3D0x%lx,end=3D0x%lx,prot=3D%x,flags=3D%=
x,off=3D0x%llx)\n",
+	    file, start, end, prot, flags, off);
=20
-	end =3D addr + len;
-	front_len =3D addr - faddr;
-	back_len =3D (end & ~PAGE_MASK);
-
-	if (front_len && is_readable(faddr)) {
-		front =3D kmalloc(front_len, GFP_KERNEL);
-		if (!front) {
-			addr =3D -ENOMEM;
-			goto fail;
-		}
-		copy_from_user(front, (void *)faddr, front_len);
-	}
+	if (!page)
+		return -ENOMEM;
=20
-	if (addr && back_len && is_readable(end)) {
-		back =3D kmalloc(PAGE_SIZE - back_len, GFP_KERNEL);
-		if (!back) {
-			addr =3D -ENOMEM;
-			goto fail;
-		}
-		copy_from_user(back, (char *)end, PAGE_SIZE - back_len);
-	}
+	if (old_prot)
+		copy_from_user(page, (void *) PAGE_START(start), PAGE_SIZE);
=20
 	down_write(&current->mm->mmap_sem);
 	{
-		retval =3D do_mmap(0, faddr, len + front_len, prot, flags | MAP_ANONYMOU=
S, 0);
+		ret =3D do_mmap(0, PAGE_START(start), PAGE_SIZE, prot | PROT_WRITE,
+			      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
 	}
 	up_write(&current->mm->mmap_sem);
=20
-	if (IS_ERR((void *) retval)) {
-		addr =3D retval;
-		goto fail;
-	}
+	if (IS_ERR((void *) ret))
+		goto out;
=20
-	if (!addr)
-		addr =3D retval;
+	if (old_prot) {
+		/* copy back the old page contents.  */
+		if (PAGE_OFF(start))
+			copy_to_user((void *) PAGE_START(start), page, PAGE_OFF(start));
+		if (PAGE_OFF(end))
+			copy_to_user((void *) end, page + PAGE_OFF(end),
+				     PAGE_SIZE - PAGE_OFF(end));
+	}
+	if (!(flags & MAP_ANONYMOUS)) {
+		/* read the file contents */
+		inode =3D file->f_dentry->d_inode;
+		if (!inode->i_fop || !file->f_op->read
+		    || ((*file->f_op->read)(file, (char *) start, end - start, &off) < 0=
))
+		{
+			ret =3D -EINVAL;
+			goto out;
+		}
+	}
+	if (!(prot & PROT_WRITE))
+		ret =3D sys_mprotect(PAGE_START(start), PAGE_SIZE, prot | old_prot);
+  out:
+	free_page((unsigned long) page);
+	return ret;
+}
=20
-	end =3D addr + len;
+static unsigned long
+emulate_mmap (struct file *file, unsigned long start, unsigned long len, i=
nt prot, int flags,
+	      loff_t off)
+{
+	unsigned long tmp, end, pend, pstart, ret, is_congruent, fudge =3D 0;
+	struct inode *inode;
+	loff_t poff;
=20
-	if (back) {
-		if (copy_to_user((char *) end, back, PAGE_SIZE - back_len)) {
-			addr =3D -EINVAL;
-			goto fail;
+	end =3D start + len;
+	pstart =3D PAGE_START(start);
+	pend =3D PAGE_ALIGN(end);
+
+	if (flags & MAP_FIXED) {
+		if (start > pstart) {
+			if (flags & MAP_SHARED)
+				printk(KERN_INFO
+				       "%s(%d): emulate_mmap() can't share head (addr=3D0x%lx)\n",
+				       current->comm, current->pid, start);
+			ret =3D mmap_subpage(file, start, min(PAGE_ALIGN(start), end), prot, fl=
ags,
+					   off);
+			if (IS_ERR((void *) ret))
+				return ret;
+			pstart +=3D PAGE_SIZE;
+			if (pstart >=3D pend)
+				return start;	/* done */
 		}
-		kfree(back);
-	}
-	if (front) {
-		if (copy_to_user((void *) faddr, front, front_len)) {
-			addr =3D -EINVAL;
-			goto fail;
+		if (end < pend) {
+			if (flags & MAP_SHARED)
+				printk(KERN_INFO
+				       "%s(%d): emulate_mmap() can't share tail (end=3D0x%lx)\n",
+				       current->comm, current->pid, end);
+			ret =3D mmap_subpage(file, max(start, PAGE_START(end)), end, prot, flag=
s,
+					   (off + len) - PAGE_OFF(end));
+			if (IS_ERR((void *) ret))
+				return ret;
+			pend -=3D PAGE_SIZE;
+			if (pstart >=3D pend)
+				return start;	/* done */
+		}
+	} else {
+		/*
+		 * If a start address was specified, use it if the entire rounded out ar=
ea
+		 * is available.
+		 */
+		if (start && !pstart)
+			fudge =3D 1;	/* handle case of mapping to range (0,PAGE_SIZE) */
+		tmp =3D arch_get_unmapped_area(file, pstart - fudge, pend - pstart, 0, f=
lags);
+		if (tmp !=3D pstart) {
+			pstart =3D tmp;
+			start =3D pstart + PAGE_OFF(off);	/* make start congruent with off */
+			end =3D start + len;
+			pend =3D PAGE_ALIGN(end);
 		}
-		kfree(front);
 	}
=20
-	if (!(flags & MAP_ANONYMOUS)) {
+	poff =3D off + (pstart - start);	/* note: (pstart - start) may be negativ=
e */
+	is_congruent =3D (flags & MAP_ANONYMOUS) || (PAGE_OFF(poff) =3D 0);
+
+	if ((flags & MAP_SHARED) && !is_congruent)
+		printk(KERN_INFO "%s(%d): emulate_mmap() can't share contents of incongr=
uent mmap "
+		       "(addr=3D0x%lx,off=3D0x%llx)\n", current->comm, current->pid, sta=
rt, off);
+
+	DBG("mmap_body: mapping [0x%lx-0x%lx) %s with poff 0x%llx\n", pstart, pen=
d,
+	    is_congruent ? "congruent" : "not congruent", poff);
+
+	down_write(&current->mm->mmap_sem);
+	{
+		if (!(flags & MAP_ANONYMOUS) && is_congruent)
+			ret =3D do_mmap(file, pstart, pend - pstart, prot, flags | MAP_FIXED, p=
off);
+		else
+			ret =3D do_mmap(0, pstart, pend - pstart,
+				      prot | ((flags & MAP_ANONYMOUS) ? 0 : PROT_WRITE),
+				      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
+	}
+	up_write(&current->mm->mmap_sem);
+
+	if (IS_ERR((void *) ret))
+		return ret;
+
+	if (!is_congruent) {
+		/* read the file contents */
 		inode =3D file->f_dentry->d_inode;
-		if (!inode->i_fop
-		    || !file->f_op->read
-		    || (*file->f_op->read)(file, (char *)addr, len, &off) < 0)
+		if (!inode->i_fop || !file->f_op->read
+		    || ((*file->f_op->read)(file, (char *) pstart, pend - pstart, &poff)=
 < 0))
 		{
-			sys_munmap(addr, len + front_len);
+			sys_munmap(pstart, pend - pstart);
 			return -EINVAL;
 		}
+		if (!(prot & PROT_WRITE) && sys_mprotect(pstart, pend - pstart, prot) < =
0)
+			return EINVAL;
 	}
-	return addr;
-
-  fail:	if (front)
-		kfree(front);
-	if (back)
-		kfree(back);
-	return addr;
+	return start;
 }
=20
 #endif /* PAGE_SHIFT > IA32_PAGE_SHIFT */
=20
+static inline unsigned int
+get_prot32 (unsigned int prot)
+{
+	if (prot & PROT_WRITE)
+		/* on x86, PROT_WRITE implies PROT_READ which implies PROT_EEC */
+		prot |=3D PROT_READ | PROT_WRITE | PROT_EXEC;
+	else if (prot & (PROT_READ | PROT_EXEC))
+		/* on x86, there is no distinction between PROT_READ and PROT_EXEC */
+		prot |=3D (PROT_READ | PROT_EXEC);
+
+	return prot;
+}
+
 unsigned long
 ia32_do_mmap (struct file *file, unsigned long addr, unsigned long len, in=
t prot, int flags,
 	      loff_t offset)
 {
+	DBG("ia32_do_mmap(file=3D%p,addr=3D0x%lx,len=3D0x%lx,prot=3D%x,flags=3D%x=
,offset=3D0x%llx)\n",
+	    file, addr, len, prot, flags, offset);
+
 	if (file && (!file->f_op || !file->f_op->mmap))
 		return -ENODEV;
=20
@@ -345,27 +449,22 @@
 	if (OFFSET4K(offset))
 		return -EINVAL;
=20
-	if (prot & (PROT_READ | PROT_WRITE))
-		prot |=3D PROT_EXEC;	/* x86 has no "execute" permission bit... */
+	prot =3D get_prot32(prot);
=20
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
-	if ((flags & MAP_FIXED) && ((addr & ~PAGE_MASK) || (offset & ~PAGE_MASK)))
-		addr =3D do_mmap_fake(file, addr, len, prot, flags, offset);
-	else
-#endif
+	down(&ia32_mmap_sem);
 	{
-		loff_t pgoff =3D offset & PAGE_MASK;
-		len +=3D offset - pgoff;
-
-		down_write(&current->mm->mmap_sem);
-		{
-			addr =3D do_mmap(file, addr, len, prot, flags, pgoff);
-		}
-		up_write(&current->mm->mmap_sem);
-
-		if (!IS_ERR((void *) addr))
-			addr +=3D offset - pgoff;
+		addr =3D emulate_mmap(file, addr, len, prot, flags, offset);
 	}
+	up(&ia32_mmap_sem);
+#else
+	down_write(&current->mm->mmap_sem);
+	{
+		addr =3D do_mmap(file, addr, len, prot, flags, offset);
+	}
+	up_write(&current->mm->mmap_sem);
+#endif
+	DBG("ia32_do_mmap: returning 0x%lx\n", addr);
 	return addr;
 }
=20
@@ -439,18 +538,27 @@
 sys32_munmap (unsigned int start, unsigned int len)
 {
 	unsigned int end =3D start + len;
+	long ret;
=20
-#if PAGE_SHIFT > IA32_PAGE_SHIFT
+#if PAGE_SHIFT <=3D IA32_PAGE_SHIFT
+	ret =3D sys_munmap(start, end - start);
+#else
 	if (start > end)
 		return -EINVAL;
=20
 	start =3D PAGE_ALIGN(start);
-	end =3D end & PAGE_MASK;
+	end =3D PAGE_START(end);
=20
 	if (start >=3D end)
 		return 0;
+
+	down(&ia32_mmap_sem);
+	{
+		ret =3D sys_munmap(start, end - start);
+	}
+	up(&ia32_mmap_sem);
 #endif
-	return sys_munmap(start, end - start);
+	return ret;
 }
=20
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
@@ -461,21 +569,14 @@
  * partial page less restrictive.
  */
 static long
-mprotect_partial_page (unsigned long address, int new_prot)
+mprotect_subpage (unsigned long address, int new_prot)
 {
 	int old_prot;
=20
 	if (new_prot =3D PROT_NONE)
 		return 0;		/* optimize case where nothing changes... */
=20
-	/*
-	 * We cannot easily determine the existing protection on this page becaus=
e we have
-	 * to relinquish the mmap-semaphore before calling sys_mprotect(), which =
would
-	 * create a window during which another task could change the protection =
settings
-	 * underneath us.  To avoid this, we conservatively assume that the page =
is
-	 * RWXable.
-	 */
-	old_prot =3D PROT_READ | PROT_WRITE | PROT_EXEC;
+	old_prot =3D get_page_prot(address);
 	return sys_mprotect(address, PAGE_SIZE, new_prot | old_prot);
 }
=20
@@ -486,14 +587,14 @@
 {
 	unsigned long end =3D start + len;
 #if PAGE_SHIFT > IA32_PAGE_SHIFT
-	long retval;
+	long retval =3D 0;
 #endif
=20
-	if (prot & (PROT_READ | PROT_WRITE))
-		/* on x86, PROT_WRITE implies PROT_READ and PROT_READ implies PROT_EXEC.=
.. */
-		prot |=3D PROT_EXEC;
+	prot =3D get_prot32(prot);
=20
-#if PAGE_SHIFT > IA32_PAGE_SHIFT
+#if PAGE_SHIFT <=3D IA32_PAGE_SHIFT
+	return sys_mprotect(start, end - start, prot);
+#else
 	if (OFFSET4K(start))
 		return -EINVAL;
=20
@@ -501,26 +602,32 @@
 	if (end < start)
 		return -EINVAL;
=20
-	if (start & ~PAGE_MASK) {
-		/* start address is 4KB aligned but not page aligned. */
-		retval =3D mprotect_partial_page(start & PAGE_MASK, prot);
-		if (retval < 0)
-			return retval;
+	down(&ia32_mmap_sem);
+	{
+		if (PAGE_OFF(start)) {
+			/* start address is 4KB aligned but not page aligned. */
+			retval =3D mprotect_subpage(PAGE_START(start), prot);
+			if (retval < 0)
+				goto out;
=20
-		start =3D PAGE_ALIGN(start);
-		if (start >=3D end)
-			return 0;
-	}
+			start =3D PAGE_ALIGN(start);
+			if (start >=3D end)
+				goto out;	/* retval is already zero... */
+		}
=20
-	if (end & ~PAGE_MASK) {
-		/* end address is 4KB aligned but not page aligned. */
-		retval =3D mprotect_partial_page(end & PAGE_MASK, prot);
-		if (retval < 0)
-			return retval;
-		end &=3D PAGE_MASK;
+		if (PAGE_OFF(end)) {
+			/* end address is 4KB aligned but not page aligned. */
+			retval =3D mprotect_subpage(PAGE_START(end), prot);
+			if (retval < 0)
+				return retval;
+			end =3D PAGE_START(end);
+		}
+		retval =3D sys_mprotect(start, end - start, prot);
 	}
+  out:
+	up(&ia32_mmap_sem);
+	return retval;
 #endif
-	return sys_mprotect(start, end - start, prot);
 }
=20
 asmlinkage long
@@ -538,169 +645,24 @@
 	return retval;
 }
=20
-static inline void
-sigact_set_handler (struct k_sigaction *sa, unsigned int handler, unsigned=
 int restorer)
-{
-	if (handler + 1 <=3D 2)
-		/* SIG_DFL, SIG_IGN, or SIG_ERR: must sign-extend to 64-bits */
-		sa->sa.sa_handler =3D (__sighandler_t) A((int) handler);
-	else
-		sa->sa.sa_handler =3D (__sighandler_t) (((unsigned long) restorer << 32)=
 | handler);
-}
-
-asmlinkage long
-sys32_signal (int sig, unsigned int handler)
-{
-	struct k_sigaction new_sa, old_sa;
-	int ret;
-
-	sigact_set_handler(&new_sa, handler, 0);
-	new_sa.sa.sa_flags =3D SA_ONESHOT | SA_NOMASK;
-
-	ret =3D do_sigaction(sig, &new_sa, &old_sa);
-
-	return ret ? ret : IA32_SA_HANDLER(&old_sa);
-}
-
-asmlinkage long
-sys32_rt_sigaction (int sig, struct sigaction32 *act,
-		    struct sigaction32 *oact, unsigned int sigsetsize)
-{
-	struct k_sigaction new_ka, old_ka;
-	unsigned int handler, restorer;
-	int ret;
-
-	/* XXX: Don't preclude handling different sized sigset_t's.  */
-	if (sigsetsize !=3D sizeof(sigset32_t))
-		return -EINVAL;
-
-	if (act) {
-		ret =3D get_user(handler, &act->sa_handler);
-		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
-		ret |=3D get_user(restorer, &act->sa_restorer);
-		ret |=3D copy_from_user(&new_ka.sa.sa_mask, &act->sa_mask, sizeof(sigset=
32_t));
-		if (ret)
-			return -EFAULT;
-
-		sigact_set_handler(&new_ka, handler, restorer);
-	}
-
-	ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
-
-	if (!ret && oact) {
-		ret =3D put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
-		ret |=3D put_user(old_ka.sa.sa_flags, &oact->sa_flags);
-		ret |=3D put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
-		ret |=3D copy_to_user(&oact->sa_mask, &old_ka.sa.sa_mask, sizeof(sigset3=
2_t));
-	}
-	return ret;
-}
-
-
-extern asmlinkage long sys_rt_sigprocmask (int how, sigset_t *set, sigset_=
t *oset,
-					   size_t sigsetsize);
-
-asmlinkage long
-sys32_rt_sigprocmask (int how, sigset32_t *set, sigset32_t *oset, unsigned=
 int sigsetsize)
-{
-	mm_segment_t old_fs =3D get_fs();
-	sigset_t s;
-	long ret;
-
-	if (sigsetsize > sizeof(s))
-		return -EINVAL;
-
-	if (set) {
-		memset(&s, 0, sizeof(s));
-		if (copy_from_user(&s.sig, set, sigsetsize))
-			return -EFAULT;
-	}
-	set_fs(KERNEL_DS);
-	ret =3D sys_rt_sigprocmask(how, set ? &s : NULL, oset ? &s : NULL, sizeof=
(s));
-	set_fs(old_fs);
-	if (ret)
-		return ret;
-	if (oset) {
-		if (copy_to_user(oset, &s.sig, sigsetsize))
-			return -EFAULT;
-	}
-	return 0;
-}
-
-asmlinkage long
-sys32_sigprocmask (int how, unsigned int *set, unsigned int *oset)
-{
-	return sys32_rt_sigprocmask(how, (sigset32_t *) set, (sigset32_t *) oset,=
 sizeof(*set));
-}
-
-struct timespec32 {
-	int	tv_sec;
-	int	tv_nsec;
-};
-
-asmlinkage long
-sys32_rt_sigtimedwait (sigset32_t *uthese, siginfo_t32 *uinfo, struct time=
spec32 *uts,
-		       unsigned int sigsetsize)
-{
-	extern asmlinkage long sys_rt_sigtimedwait (const sigset_t *, siginfo_t *,
-						    const struct timespec *, size_t);
-	extern int copy_siginfo_to_user32 (siginfo_t32 *, siginfo_t *);
-	mm_segment_t old_fs =3D get_fs();
-	struct timespec t;
-	siginfo_t info;
-	sigset_t s;
-	int ret;
-
-	if (copy_from_user(&s.sig, uthese, sizeof(sigset32_t)))
-		return -EFAULT;
-	if (uts) {
-		ret =3D get_user(t.tv_sec, &uts->tv_sec);
-		ret |=3D get_user(t.tv_nsec, &uts->tv_nsec);
-		if (ret)
-			return -EFAULT;
-	}
-	set_fs(KERNEL_DS);
-	ret =3D sys_rt_sigtimedwait(&s, &info, &t, sigsetsize);
-	set_fs(old_fs);
-	if (ret >=3D 0 && uinfo) {
-		if (copy_siginfo_to_user32(uinfo, &info))
-			return -EFAULT;
-	}
-	return ret;
-}
-
-asmlinkage long
-sys32_rt_sigqueueinfo (int pid, int sig, siginfo_t32 *uinfo)
-{
-	extern asmlinkage long sys_rt_sigqueueinfo (int, int, siginfo_t *);
-	extern int copy_siginfo_from_user32 (siginfo_t *to, siginfo_t32 *from);
-	mm_segment_t old_fs =3D get_fs();
-	siginfo_t info;
-	int ret;
-
-	if (copy_siginfo_from_user32(&info, uinfo))
-		return -EFAULT;
-	set_fs(KERNEL_DS);
-	ret =3D sys_rt_sigqueueinfo(pid, sig, &info);
-	set_fs(old_fs);
-	return ret;
-}
-
 static inline int
 put_statfs (struct statfs32 *ubuf, struct statfs *kbuf)
 {
 	int err;
=20
-	err =3D put_user (kbuf->f_type, &ubuf->f_type);
-	err |=3D __put_user (kbuf->f_bsize, &ubuf->f_bsize);
-	err |=3D __put_user (kbuf->f_blocks, &ubuf->f_blocks);
-	err |=3D __put_user (kbuf->f_bfree, &ubuf->f_bfree);
-	err |=3D __put_user (kbuf->f_bavail, &ubuf->f_bavail);
-	err |=3D __put_user (kbuf->f_files, &ubuf->f_files);
-	err |=3D __put_user (kbuf->f_ffree, &ubuf->f_ffree);
-	err |=3D __put_user (kbuf->f_namelen, &ubuf->f_namelen);
-	err |=3D __put_user (kbuf->f_fsid.val[0], &ubuf->f_fsid.val[0]);
-	err |=3D __put_user (kbuf->f_fsid.val[1], &ubuf->f_fsid.val[1]);
+	if (!access_ok(VERIFY_WRITE, ubuf, sizeof(*ubuf)))
+		return -EFAULT;
+
+	err =3D __put_user(kbuf->f_type, &ubuf->f_type);
+	err |=3D __put_user(kbuf->f_bsize, &ubuf->f_bsize);
+	err |=3D __put_user(kbuf->f_blocks, &ubuf->f_blocks);
+	err |=3D __put_user(kbuf->f_bfree, &ubuf->f_bfree);
+	err |=3D __put_user(kbuf->f_bavail, &ubuf->f_bavail);
+	err |=3D __put_user(kbuf->f_files, &ubuf->f_files);
+	err |=3D __put_user(kbuf->f_ffree, &ubuf->f_ffree);
+	err |=3D __put_user(kbuf->f_namelen, &ubuf->f_namelen);
+	err |=3D __put_user(kbuf->f_fsid.val[0], &ubuf->f_fsid.val[0]);
+	err |=3D __put_user(kbuf->f_fsid.val[1], &ubuf->f_fsid.val[1]);
 	return err;
 }
=20
@@ -753,16 +715,14 @@
 get_tv32 (struct timeval *o, struct timeval32 *i)
 {
 	return (!access_ok(VERIFY_READ, i, sizeof(*i)) ||
-		(__get_user(o->tv_sec, &i->tv_sec) |
-		 __get_user(o->tv_usec, &i->tv_usec)));
+		(__get_user(o->tv_sec, &i->tv_sec) | __get_user(o->tv_usec, &i->tv_usec)=
));
 }
=20
 static inline long
 put_tv32 (struct timeval32 *o, struct timeval *i)
 {
 	return (!access_ok(VERIFY_WRITE, o, sizeof(*o)) ||
-		(__put_user(i->tv_sec, &o->tv_sec) |
-		 __put_user(i->tv_usec, &o->tv_usec)));
+		(__put_user(i->tv_sec, &o->tv_sec) | __put_user(i->tv_usec, &o->tv_usec)=
));
 }
=20
 static inline long
@@ -913,20 +873,6 @@
 	return do_sys_settimeofday(tv ? &ktv : NULL, tz ? &ktz : NULL);
 }
=20
-struct linux32_dirent {
-	u32	d_ino;
-	u32	d_off;
-	u16	d_reclen;
-	char	d_name[1];
-};
-
-struct old_linux32_dirent {
-	u32	d_ino;
-	u32	d_offset;
-	u16	d_namlen;
-	char	d_name[1];
-};
-
 struct getdents32_callback {
 	struct linux32_dirent * current_dir;
 	struct linux32_dirent * previous;
@@ -1177,7 +1123,7 @@
 {
 	struct timespec t;
 	int ret;
-	mm_segment_t old_fs =3D get_fs ();
+	mm_segment_t old_fs =3D get_fs();
=20
 	if (get_user (t.tv_sec, &rqtp->tv_sec) || get_user (t.tv_nsec, &rqtp->tv_=
nsec))
 		return -EFAULT;
@@ -1360,14 +1306,50 @@
 	unsigned	msg_flags;
 };
=20
+struct cmsghdr32 {
+	__kernel_size_t32 cmsg_len;
+	int               cmsg_level;
+	int               cmsg_type;
+};
+
+/* Bleech... */
+#define __CMSG32_NXTHDR(ctl, len, cmsg, cmsglen) __cmsg32_nxthdr((ctl),(le=
n),(cmsg),(cmsglen))
+#define CMSG32_NXTHDR(mhdr, cmsg, cmsglen)	cmsg32_nxthdr((mhdr), (cmsg), (=
cmsglen))
+#define CMSG32_ALIGN(len) ( ((len)+sizeof(int)-1) & ~(sizeof(int)-1) )
+#define CMSG32_DATA(cmsg) \
+	((void *)((char *)(cmsg) + CMSG32_ALIGN(sizeof(struct cmsghdr32))))
+#define CMSG32_SPACE(len) \
+	(CMSG32_ALIGN(sizeof(struct cmsghdr32)) + CMSG32_ALIGN(len))
+#define CMSG32_LEN(len) (CMSG32_ALIGN(sizeof(struct cmsghdr32)) + (len))
+#define __CMSG32_FIRSTHDR(ctl,len) \
+	((len) >=3D sizeof(struct cmsghdr32) ? (struct cmsghdr32 *)(ctl) : (struc=
t cmsghdr32 *)NULL)
+#define CMSG32_FIRSTHDR(msg)	__CMSG32_FIRSTHDR((msg)->msg_control, (msg)->=
msg_controllen)
+
+static inline struct cmsghdr32 *
+__cmsg32_nxthdr (void *ctl, __kernel_size_t size, struct cmsghdr32 *cmsg, =
int cmsg_len)
+{
+	struct cmsghdr32 * ptr;
+
+	ptr =3D (struct cmsghdr32 *)(((unsigned char *) cmsg) + CMSG32_ALIGN(cmsg=
_len));
+	if ((unsigned long)((char*)(ptr+1) - (char *) ctl) > size)
+		return NULL;
+	return ptr;
+}
+
+static inline struct cmsghdr32 *
+cmsg32_nxthdr (struct msghdr *msg, struct cmsghdr32 *cmsg, int cmsg_len)
+{
+	return __cmsg32_nxthdr(msg->msg_control, msg->msg_controllen, cmsg, cmsg_=
len);
+}
+
 static inline int
-shape_msg (struct msghdr *mp, struct msghdr32 *mp32)
+get_msghdr32 (struct msghdr *mp, struct msghdr32 *mp32)
 {
 	int ret;
 	unsigned int i;
=20
 	if (!access_ok(VERIFY_READ, mp32, sizeof(*mp32)))
-		return(-EFAULT);
+		return -EFAULT;
 	ret =3D __get_user(i, &mp32->msg_name);
 	mp->msg_name =3D (void *)A(i);
 	ret |=3D __get_user(mp->msg_namelen, &mp32->msg_namelen);
@@ -1378,48 +1360,125 @@
 	mp->msg_control =3D (void *)A(i);
 	ret |=3D __get_user(mp->msg_controllen, &mp32->msg_controllen);
 	ret |=3D __get_user(mp->msg_flags, &mp32->msg_flags);
-	return(ret ? -EFAULT : 0);
+	return ret ? -EFAULT : 0;
 }
=20
 /*
- *	Verify & re-shape IA32 iovec. The caller must ensure that the
- *      iovec is big enough to hold the re-shaped message iovec.
- *
- *	Save time not doing verify_area. copy_*_user will make this work
- *	in any case.
- *
- *	Don't need to check the total size for overflow (cf net/core/iovec.c),
- *	32-bit sizes can't overflow a 64-bit count.
+ * There is a lot of hair here because the alignment rules (and thus place=
ment) of cmsg
+ * headers and length are different for 32-bit apps.  -DaveM
  */
-
-static inline int
-verify_iovec32 (struct msghdr *m, struct iovec *iov, char *address, int mo=
de)
+static int
+get_cmsghdr32 (struct msghdr *kmsg, unsigned char *stackbuf, struct sock *=
sk, size_t *bufsize)
 {
-	int size, err, ct;
-	struct iovec32 *iov32;
-
-	if(m->msg_namelen)
-	{
-		if(mode=3DVERIFY_READ)
-		{
-			err=3Dmove_addr_to_kernel(m->msg_name, m->msg_namelen, address);
-			if(err<0)
-				goto out;
-		}
+	struct cmsghdr *kcmsg, *kcmsg_base;
+	__kernel_size_t kcmlen, tmp;
+	__kernel_size_t32 ucmlen;
+	struct cmsghdr32 *ucmsg;
+	long err;
=20
-		m->msg_name =3D address;
-	} else
-		m->msg_name =3D NULL;
+	kcmlen =3D 0;
+	kcmsg_base =3D kcmsg =3D (struct cmsghdr *)stackbuf;
+	ucmsg =3D CMSG32_FIRSTHDR(kmsg);
+	while (ucmsg !=3D NULL) {
+		if (get_user(ucmlen, &ucmsg->cmsg_len))
+			return -EFAULT;
=20
-	err =3D -EFAULT;
-	size =3D m->msg_iovlen * sizeof(struct iovec32);
-	if (copy_from_user(iov, m->msg_iov, size))
-		goto out;
-	m->msg_iov=3Diov;
+		/* Catch bogons. */
+		if (CMSG32_ALIGN(ucmlen) < CMSG32_ALIGN(sizeof(struct cmsghdr32)))
+			return -EINVAL;
+		if ((unsigned long)(((char *)ucmsg - (char *)kmsg->msg_control) + ucmlen)
+		    > kmsg->msg_controllen)
+			return -EINVAL;
=20
-	err =3D 0;
-	iov32 =3D (struct iovec32 *)iov;
-	for (ct =3D m->msg_iovlen; ct-- > 0; ) {
+		tmp =3D ((ucmlen - CMSG32_ALIGN(sizeof(*ucmsg))) +
+		       CMSG_ALIGN(sizeof(struct cmsghdr)));
+		kcmlen +=3D tmp;
+		ucmsg =3D CMSG32_NXTHDR(kmsg, ucmsg, ucmlen);
+	}
+	if (kcmlen =3D 0)
+		return -EINVAL;
+
+	/*
+	 * The kcmlen holds the 64-bit version of the control length.  It may not=
 be
+	 * modified as we do not stick it into the kmsg until we have successfull=
y copied
+	 * over all of the data from the user.
+	 */
+	if (kcmlen > *bufsize) {
+		*bufsize =3D kcmlen;
+		kcmsg_base =3D kcmsg =3D sock_kmalloc(sk, kcmlen, GFP_KERNEL);
+	}
+	if (kcmsg =3D NULL)
+		return -ENOBUFS;
+
+	/* Now copy them over neatly. */
+	memset(kcmsg, 0, kcmlen);
+	ucmsg =3D CMSG32_FIRSTHDR(kmsg);
+	while (ucmsg !=3D NULL) {
+		err =3D get_user(ucmlen, &ucmsg->cmsg_len);
+		tmp =3D ((ucmlen - CMSG32_ALIGN(sizeof(*ucmsg))) +
+		       CMSG_ALIGN(sizeof(struct cmsghdr)));
+		kcmsg->cmsg_len =3D tmp;
+		err |=3D get_user(kcmsg->cmsg_level, &ucmsg->cmsg_level);
+		err |=3D get_user(kcmsg->cmsg_type, &ucmsg->cmsg_type);
+
+		/* Copy over the data. */
+		err |=3D copy_from_user(CMSG_DATA(kcmsg), CMSG32_DATA(ucmsg),
+				      (ucmlen - CMSG32_ALIGN(sizeof(*ucmsg))));
+		if (err)
+			goto out_free_efault;
+
+		/* Advance. */
+		kcmsg =3D (struct cmsghdr *)((char *)kcmsg + CMSG_ALIGN(tmp));
+		ucmsg =3D CMSG32_NXTHDR(kmsg, ucmsg, ucmlen);
+	}
+
+	/* Ok, looks like we made it.  Hook it up and return success. */
+	kmsg->msg_control =3D kcmsg_base;
+	kmsg->msg_controllen =3D kcmlen;
+	return 0;
+
+out_free_efault:
+	if (kcmsg_base !=3D (struct cmsghdr *)stackbuf)
+		sock_kfree_s(sk, kcmsg_base, kcmlen);
+	return -EFAULT;
+}
+
+/*
+ *	Verify & re-shape IA32 iovec. The caller must ensure that the
+ *      iovec is big enough to hold the re-shaped message iovec.
+ *
+ *	Save time not doing verify_area. copy_*_user will make this work
+ *	in any case.
+ *
+ *	Don't need to check the total size for overflow (cf net/core/iovec.c),
+ *	32-bit sizes can't overflow a 64-bit count.
+ */
+
+static inline int
+verify_iovec32 (struct msghdr *m, struct iovec *iov, char *address, int mo=
de)
+{
+	int size, err, ct;
+	struct iovec32 *iov32;
+
+	if (m->msg_namelen) {
+		if (mode =3D VERIFY_READ) {
+			err =3D move_addr_to_kernel(m->msg_name, m->msg_namelen, address);
+			if (err < 0)
+				goto out;
+		}
+		m->msg_name =3D address;
+	} else
+		m->msg_name =3D NULL;
+
+	err =3D -EFAULT;
+	size =3D m->msg_iovlen * sizeof(struct iovec32);
+	if (copy_from_user(iov, m->msg_iov, size))
+		goto out;
+	m->msg_iov =3D iov;
+
+	err =3D 0;
+	iov32 =3D (struct iovec32 *)iov;
+	for (ct =3D m->msg_iovlen; ct-- > 0; ) {
 		iov[ct].iov_len =3D (__kernel_size_t)iov32[ct].iov_len;
 		iov[ct].iov_base =3D (void *) A(iov32[ct].iov_base);
 		err +=3D iov[ct].iov_len;
@@ -1428,6 +1487,186 @@
 	return err;
 }
=20
+static void
+put_cmsg32(struct msghdr *kmsg, int level, int type, int len, void *data)
+{
+	struct cmsghdr32 *cm =3D (struct cmsghdr32 *) kmsg->msg_control;
+	struct cmsghdr32 cmhdr;
+	int cmlen =3D CMSG32_LEN(len);
+
+	if(cm =3D NULL || kmsg->msg_controllen < sizeof(*cm)) {
+		kmsg->msg_flags |=3D MSG_CTRUNC;
+		return;
+	}
+
+	if(kmsg->msg_controllen < cmlen) {
+		kmsg->msg_flags |=3D MSG_CTRUNC;
+		cmlen =3D kmsg->msg_controllen;
+	}
+	cmhdr.cmsg_level =3D level;
+	cmhdr.cmsg_type =3D type;
+	cmhdr.cmsg_len =3D cmlen;
+
+	if(copy_to_user(cm, &cmhdr, sizeof cmhdr))
+		return;
+	if(copy_to_user(CMSG32_DATA(cm), data,
+			cmlen - sizeof(struct cmsghdr32)))
+		return;
+	cmlen =3D CMSG32_SPACE(len);
+	kmsg->msg_control +=3D cmlen;
+	kmsg->msg_controllen -=3D cmlen;
+}
+
+static void
+scm_detach_fds32 (struct msghdr *kmsg, struct scm_cookie *scm)
+{
+	struct cmsghdr32 *cm =3D (struct cmsghdr32 *) kmsg->msg_control;
+	int fdmax =3D (kmsg->msg_controllen - sizeof(struct cmsghdr32))
+		/ sizeof(int);
+	int fdnum =3D scm->fp->count;
+	struct file **fp =3D scm->fp->fp;
+	int *cmfptr;
+	int err =3D 0, i;
+
+	if (fdnum < fdmax)
+		fdmax =3D fdnum;
+
+	for (i =3D 0, cmfptr =3D (int *) CMSG32_DATA(cm);
+	     i < fdmax;
+	     i++, cmfptr++) {
+		int new_fd;
+		err =3D get_unused_fd();
+		if (err < 0)
+			break;
+		new_fd =3D err;
+		err =3D put_user(new_fd, cmfptr);
+		if (err) {
+			put_unused_fd(new_fd);
+			break;
+		}
+		/* Bump the usage count and install the file. */
+		get_file(fp[i]);
+		current->files->fd[new_fd] =3D fp[i];
+	}
+
+	if (i > 0) {
+		int cmlen =3D CMSG32_LEN(i * sizeof(int));
+		if (!err)
+			err =3D put_user(SOL_SOCKET, &cm->cmsg_level);
+		if (!err)
+			err =3D put_user(SCM_RIGHTS, &cm->cmsg_type);
+		if (!err)
+			err =3D put_user(cmlen, &cm->cmsg_len);
+		if (!err) {
+			cmlen =3D CMSG32_SPACE(i * sizeof(int));
+			kmsg->msg_control +=3D cmlen;
+			kmsg->msg_controllen -=3D cmlen;
+		}
+	}
+	if (i < fdnum)
+		kmsg->msg_flags |=3D MSG_CTRUNC;
+
+	/*
+	 * All of the files that fit in the message have had their
+	 * usage counts incremented, so we just free the list.
+	 */
+	__scm_destroy(scm);
+}
+
+/*
+ * In these cases we (currently) can just copy to data over verbatim becau=
se all CMSGs
+ * created by the kernel have well defined types which have the same layou=
t in both the
+ * 32-bit and 64-bit API.  One must add some special cased conversions her=
e if we start
+ * sending control messages with incompatible types.
+ *
+ * SCM_RIGHTS and SCM_CREDENTIALS are done by hand in recvmsg32 right after
+ * we do our work.  The remaining cases are:
+ *
+ * SOL_IP	IP_PKTINFO	struct in_pktinfo	32-bit clean
+ *		IP_TTL		int			32-bit clean
+ *		IP_TOS		__u8			32-bit clean
+ *		IP_RECVOPTS	variable length		32-bit clean
+ *		IP_RETOPTS	variable length		32-bit clean
+ *		(these last two are clean because the types are defined
+ *		 by the IPv4 protocol)
+ *		IP_RECVERR	struct sock_extended_err +
+ *				struct sockaddr_in	32-bit clean
+ * SOL_IPV6	IPV6_RECVERR	struct sock_extended_err +
+ *				struct sockaddr_in6	32-bit clean
+ *		IPV6_PKTINFO	struct in6_pktinfo	32-bit clean
+ *		IPV6_HOPLIMIT	int			32-bit clean
+ *		IPV6_FLOWINFO	u32			32-bit clean
+ *		IPV6_HOPOPTS	ipv6 hop exthdr		32-bit clean
+ *		IPV6_DSTOPTS	ipv6 dst exthdr(s)	32-bit clean
+ *		IPV6_RTHDR	ipv6 routing exthdr	32-bit clean
+ *		IPV6_AUTHHDR	ipv6 auth exthdr	32-bit clean
+ */
+static void
+cmsg32_recvmsg_fixup (struct msghdr *kmsg, unsigned long orig_cmsg_uptr)
+{
+	unsigned char *workbuf, *wp;
+	unsigned long bufsz, space_avail;
+	struct cmsghdr *ucmsg;
+	long err;
+
+	bufsz =3D ((unsigned long)kmsg->msg_control) - orig_cmsg_uptr;
+	space_avail =3D kmsg->msg_controllen + bufsz;
+	wp =3D workbuf =3D kmalloc(bufsz, GFP_KERNEL);
+	if (workbuf =3D NULL)
+		goto fail;
+
+	/* To make this more sane we assume the kernel sends back properly
+	 * formatted control messages.  Because of how the kernel will truncate
+	 * the cmsg_len for MSG_TRUNC cases, we need not check that case either.
+	 */
+	ucmsg =3D (struct cmsghdr *) orig_cmsg_uptr;
+	while (((unsigned long)ucmsg) < ((unsigned long)kmsg->msg_control)) {
+		struct cmsghdr32 *kcmsg32 =3D (struct cmsghdr32 *) wp;
+		int clen64, clen32;
+
+		/*
+		 * UCMSG is the 64-bit format CMSG entry in user-space.  KCMSG32 is with=
in
+		 * the kernel space temporary buffer we use to convert into a 32-bit sty=
le
+		 * CMSG.
+		 */
+		err =3D get_user(kcmsg32->cmsg_len, &ucmsg->cmsg_len);
+		err |=3D get_user(kcmsg32->cmsg_level, &ucmsg->cmsg_level);
+		err |=3D get_user(kcmsg32->cmsg_type, &ucmsg->cmsg_type);
+		if (err)
+			goto fail2;
+
+		clen64 =3D kcmsg32->cmsg_len;
+		copy_from_user(CMSG32_DATA(kcmsg32), CMSG_DATA(ucmsg),
+			       clen64 - CMSG_ALIGN(sizeof(*ucmsg)));
+		clen32 =3D ((clen64 - CMSG_ALIGN(sizeof(*ucmsg))) +
+			  CMSG32_ALIGN(sizeof(struct cmsghdr32)));
+		kcmsg32->cmsg_len =3D clen32;
+
+		ucmsg =3D (struct cmsghdr *) (((char *)ucmsg) + CMSG_ALIGN(clen64));
+		wp =3D (((char *)kcmsg32) + CMSG32_ALIGN(clen32));
+	}
+
+	/* Copy back fixed up data, and adjust pointers. */
+	bufsz =3D (wp - workbuf);
+	if (copy_to_user((void *)orig_cmsg_uptr, workbuf, bufsz))
+		goto fail2;
+
+	kmsg->msg_control =3D (struct cmsghdr *) (((char *)orig_cmsg_uptr) + bufs=
z);
+	kmsg->msg_controllen =3D space_avail - bufsz;
+	kfree(workbuf);
+	return;
+
+  fail2:
+	kfree(workbuf);
+  fail:
+	/*
+	 * If we leave the 64-bit format CMSG chunks in there, the application co=
uld get
+	 * confused and crash.  So to ensure greater recovery, we report no CMSGs.
+	 */
+	kmsg->msg_controllen +=3D bufsz;
+	kmsg->msg_control =3D (void *) orig_cmsg_uptr;
+}
+
 static inline void
 sockfd_put (struct socket *sock)
 {
@@ -1455,10 +1694,11 @@
 	unsigned char ctl[sizeof(struct cmsghdr) + 20];	/* 20 is size of ipv6_pkt=
info */
 	unsigned char *ctl_buf =3D ctl;
 	struct msghdr msg_sys;
-	int err, ctl_len, iov_size, total_len;
+	int err, iov_size, total_len;
+	size_t ctl_len;
=20
 	err =3D -EFAULT;
-	if (shape_msg(&msg_sys, msg))
+	if (get_msghdr32(&msg_sys, msg))
 		goto out;
=20
 	sock =3D sockfd_lookup(fd, &err);
@@ -1489,20 +1729,12 @@
=20
 	if (msg_sys.msg_controllen > INT_MAX)
 		goto out_freeiov;
-	ctl_len =3D msg_sys.msg_controllen;
-	if (ctl_len)
-	{
-		if (ctl_len > sizeof(ctl))
-		{
-			err =3D -ENOBUFS;
-			ctl_buf =3D sock_kmalloc(sock->sk, ctl_len, GFP_KERNEL);
-			if (ctl_buf =3D NULL)
-				goto out_freeiov;
-		}
-		err =3D -EFAULT;
-		if (copy_from_user(ctl_buf, msg_sys.msg_control, ctl_len))
-			goto out_freectl;
-		msg_sys.msg_control =3D ctl_buf;
+	if (msg_sys.msg_controllen) {
+		ctl_len =3D sizeof(ctl);
+		err =3D get_cmsghdr32(&msg_sys, ctl_buf, sock->sk, &ctl_len);
+		if (err)
+			goto out_freeiov;
+		ctl_buf =3D msg_sys.msg_control;
 	}
 	msg_sys.msg_flags =3D flags;
=20
@@ -1510,7 +1742,6 @@
 		msg_sys.msg_flags |=3D MSG_DONTWAIT;
 	err =3D sock_sendmsg(sock, &msg_sys, total_len);
=20
-out_freectl:
 	if (ctl_buf !=3D ctl)
 		sock_kfree_s(sock->sk, ctl_buf, ctl_len);
 out_freeiov:
@@ -1535,6 +1766,7 @@
 	struct msghdr msg_sys;
 	unsigned long cmsg_ptr;
 	int err, iov_size, total_len, len;
+	struct scm_cookie scm;
=20
 	/* kernel mode address */
 	char addr[MAX_SOCK_ADDR];
@@ -1543,8 +1775,8 @@
 	struct sockaddr *uaddr;
 	int *uaddr_len;
=20
-	err=3D-EFAULT;
-	if (shape_msg(&msg_sys, msg))
+	err =3D -EFAULT;
+	if (get_msghdr32(&msg_sys, msg))
 		goto out;
=20
 	sock =3D sockfd_lookup(fd, &err);
@@ -1581,10 +1813,39 @@
=20
 	if (sock->file->f_flags & O_NONBLOCK)
 		flags |=3D MSG_DONTWAIT;
-	err =3D sock_recvmsg(sock, &msg_sys, total_len, flags);
-	if (err < 0)
-		goto out_freeiov;
-	len =3D err;
+
+	memset(&scm, 0, sizeof(scm));
+
+	lock_kernel();
+	{
+		err =3D sock->ops->recvmsg(sock, &msg_sys, total_len, flags, &scm);
+		if (err < 0)
+			goto out_unlock_freeiov;
+
+		len =3D err;
+		if (!msg_sys.msg_control) {
+			if (sock->passcred || scm.fp)
+				msg_sys.msg_flags |=3D MSG_CTRUNC;
+			if (scm.fp)
+				__scm_destroy(&scm);
+		} else {
+			/*
+			 * If recvmsg processing itself placed some control messages into
+			 * user space, it's is using 64-bit CMSG processing, so we need to
+			 * fix it up before we tack on more stuff.
+			 */
+			if ((unsigned long) msg_sys.msg_control !=3D cmsg_ptr)
+				cmsg32_recvmsg_fixup(&msg_sys, cmsg_ptr);
+
+			/* Wheee... */
+			if (sock->passcred)
+				put_cmsg32(&msg_sys, SOL_SOCKET, SCM_CREDENTIALS,
+					   sizeof(scm.creds), &scm.creds);
+			if (scm.fp !=3D NULL)
+				scm_detach_fds32(&msg_sys, &scm);
+		}
+	}
+	unlock_kernel();
=20
 	if (uaddr !=3D NULL) {
 		err =3D move_addr_to_user(addr, msg_sys.msg_namelen, uaddr, uaddr_len);
@@ -1600,13 +1861,16 @@
 		goto out_freeiov;
 	err =3D len;
=20
-out_freeiov:
+  out_freeiov:
 	if (iov !=3D iovstack)
 		sock_kfree_s(sock->sk, iov, iov_size);
-out_put:
+  out_put:
 	sockfd_put(sock);
-out:
+  out:
 	return err;
+
+  out_unlock_freeiov:
+	goto out_freeiov;
 }
=20
 /* Argument list sizes for sys_socketcall */
@@ -1725,15 +1989,28 @@
=20
 struct msgbuf32 { s32 mtype; char mtext[1]; };
=20
-struct ipc_perm32
-{
-	key_t	  key;
-	__kernel_uid_t32  uid;
-	__kernel_gid_t32  gid;
-	__kernel_uid_t32  cuid;
-	__kernel_gid_t32  cgid;
+struct ipc_perm32 {
+	key_t key;
+	__kernel_uid_t32 uid;
+	__kernel_gid_t32 gid;
+	__kernel_uid_t32 cuid;
+	__kernel_gid_t32 cgid;
+	__kernel_mode_t32 mode;
+	unsigned short seq;
+};
+
+struct ipc64_perm32 {
+	key_t key;
+	__kernel_uid32_t32 uid;
+	__kernel_gid32_t32 gid;
+	__kernel_uid32_t32 cuid;
+	__kernel_gid32_t32 cgid;
 	__kernel_mode_t32 mode;
-	unsigned short  seq;
+	unsigned short __pad1;
+	unsigned short seq;
+	unsigned short __pad2;
+	unsigned int unused1;
+	unsigned int unused2;
 };
=20
 struct semid_ds32 {
@@ -1747,8 +2024,18 @@
 	unsigned short  sem_nsems;              /* no. of semaphores in array */
 };
=20
-struct msqid_ds32
-{
+struct semid64_ds32 {
+	struct ipc64_perm32 sem_perm;
+	__kernel_time_t32 sem_otime;
+	unsigned int __unused1;
+	__kernel_time_t32 sem_ctime;
+	unsigned int __unused2;
+	unsigned int sem_nsems;
+	unsigned int __unused3;
+	unsigned int __unused4;
+};
+
+struct msqid_ds32 {
 	struct ipc_perm32 msg_perm;
 	u32 msg_first;
 	u32 msg_last;
@@ -1764,15 +2051,66 @@
 	__kernel_ipc_pid_t32 msg_lrpid;
 };
=20
+struct msqid64_ds32 {
+	struct ipc64_perm32 msg_perm;
+	__kernel_time_t32 msg_stime;
+	unsigned int __unused1;
+	__kernel_time_t32 msg_rtime;
+	unsigned int __unused2;
+	__kernel_time_t32 msg_ctime;
+	unsigned int __unused3;
+	unsigned int msg_cbytes;
+	unsigned int msg_qnum;
+	unsigned int msg_qbytes;
+	__kernel_pid_t32 msg_lspid;
+	__kernel_pid_t32 msg_lrpid;
+	unsigned int __unused4;
+	unsigned int __unused5;
+};
+
 struct shmid_ds32 {
-	struct ipc_perm32       shm_perm;
-	int                     shm_segsz;
-	__kernel_time_t32       shm_atime;
-	__kernel_time_t32       shm_dtime;
-	__kernel_time_t32       shm_ctime;
-	__kernel_ipc_pid_t32    shm_cpid;
-	__kernel_ipc_pid_t32    shm_lpid;
-	unsigned short          shm_nattch;
+	struct ipc_perm32 shm_perm;
+	int shm_segsz;
+	__kernel_time_t32 shm_atime;
+	__kernel_time_t32 shm_dtime;
+	__kernel_time_t32 shm_ctime;
+	__kernel_ipc_pid_t32 shm_cpid;
+	__kernel_ipc_pid_t32 shm_lpid;
+	unsigned short shm_nattch;
+};
+
+struct shmid64_ds32 {
+	struct ipc64_perm shm_perm;
+	__kernel_size_t32 shm_segsz;
+	__kernel_time_t32 shm_atime;
+	unsigned int __unused1;
+	__kernel_time_t32 shm_dtime;
+	unsigned int __unused2;
+	__kernel_time_t32 shm_ctime;
+	unsigned int __unused3;
+	__kernel_pid_t32 shm_cpid;
+	__kernel_pid_t32 shm_lpid;
+	unsigned int shm_nattch;
+	unsigned int __unused4;
+	unsigned int __unused5;
+};
+
+struct shminfo64_32 {
+	unsigned int shmmax;
+	unsigned int shmmin;
+	unsigned int shmmni;
+	unsigned int shmseg;
+	unsigned int shmall;
+	unsigned int __unused1;
+	unsigned int __unused2;
+	unsigned int __unused3;
+	unsigned int __unused4;
+};
+
+struct shm_info32 {
+	int used_ids;
+	u32 shm_tot, shm_rss, shm_swp;
+	u32 swap_attempts, swap_successes;
 };
=20
 struct ipc_kludge {
@@ -1795,14 +2133,25 @@
 #define IPCOP_MASK(__x)	(1UL << (__x))
=20
 static int
-do_sys32_semctl (int first, int second, int third, void *uptr)
+ipc_parse_version32 (int *cmd)
+{
+	if (*cmd & IPC_64) {
+		*cmd ^=3D IPC_64;
+		return IPC_64;
+	} else {
+		return IPC_OLD;
+	}
+}
+
+static int
+semctl32 (int first, int second, int third, void *uptr)
 {
 	union semun fourth;
 	u32 pad;
 	int err =3D 0, err2;
 	struct semid64_ds s;
-	struct semid_ds32 *usp;
 	mm_segment_t old_fs;
+	int version =3D ipc_parse_version32(&third);
=20
 	if (!uptr)
 		return -EINVAL;
@@ -1813,41 +2162,65 @@
 	else
 		fourth.__pad =3D (void *)A(pad);
 	switch (third) {
-
-	case IPC_INFO:
-	case IPC_RMID:
-	case IPC_SET:
-	case SEM_INFO:
-	case GETVAL:
-	case GETPID:
-	case GETNCNT:
-	case GETZCNT:
-	case GETALL:
-	case SETVAL:
-	case SETALL:
+	      case IPC_INFO:
+	      case IPC_RMID:
+	      case IPC_SET:
+	      case SEM_INFO:
+	      case GETVAL:
+	      case GETPID:
+	      case GETNCNT:
+	      case GETZCNT:
+	      case GETALL:
+	      case SETVAL:
+	      case SETALL:
 		err =3D sys_semctl(first, second, third, fourth);
 		break;
=20
-	case IPC_STAT:
-	case SEM_STAT:
-		usp =3D (struct semid_ds32 *)A(pad);
+	      case IPC_STAT:
+	      case SEM_STAT:
 		fourth.__pad =3D &s;
 		old_fs =3D get_fs();
 		set_fs(KERNEL_DS);
 		err =3D sys_semctl(first, second, third, fourth);
 		set_fs(old_fs);
-		err2 =3D put_user(s.sem_perm.key, &usp->sem_perm.key);
-		err2 |=3D put_user(s.sem_perm.uid, &usp->sem_perm.uid);
-		err2 |=3D put_user(s.sem_perm.gid, &usp->sem_perm.gid);
-		err2 |=3D put_user(s.sem_perm.cuid, &usp->sem_perm.cuid);
-		err2 |=3D put_user(s.sem_perm.cgid, &usp->sem_perm.cgid);
-		err2 |=3D put_user(s.sem_perm.mode, &usp->sem_perm.mode);
-		err2 |=3D put_user(s.sem_perm.seq, &usp->sem_perm.seq);
-		err2 |=3D put_user(s.sem_otime, &usp->sem_otime);
-		err2 |=3D put_user(s.sem_ctime, &usp->sem_ctime);
-		err2 |=3D put_user(s.sem_nsems, &usp->sem_nsems);
+
+		if (version =3D IPC_64) {
+			struct semid64_ds32 *usp64 =3D (struct semid64_ds32 *) A(pad);
+
+			if (!access_ok(VERIFY_WRITE, usp64, sizeof(*usp64))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(s.sem_perm.key, &usp64->sem_perm.key);
+			err2 |=3D __put_user(s.sem_perm.uid, &usp64->sem_perm.uid);
+			err2 |=3D __put_user(s.sem_perm.gid, &usp64->sem_perm.gid);
+			err2 |=3D __put_user(s.sem_perm.cuid, &usp64->sem_perm.cuid);
+			err2 |=3D __put_user(s.sem_perm.cgid, &usp64->sem_perm.cgid);
+			err2 |=3D __put_user(s.sem_perm.mode, &usp64->sem_perm.mode);
+			err2 |=3D __put_user(s.sem_perm.seq, &usp64->sem_perm.seq);
+			err2 |=3D __put_user(s.sem_otime, &usp64->sem_otime);
+			err2 |=3D __put_user(s.sem_ctime, &usp64->sem_ctime);
+			err2 |=3D __put_user(s.sem_nsems, &usp64->sem_nsems);
+		} else {
+			struct semid_ds32 *usp32 =3D (struct semid_ds32 *) A(pad);
+
+			if (!access_ok(VERIFY_WRITE, usp32, sizeof(*usp32))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(s.sem_perm.key, &usp32->sem_perm.key);
+			err2 |=3D __put_user(s.sem_perm.uid, &usp32->sem_perm.uid);
+			err2 |=3D __put_user(s.sem_perm.gid, &usp32->sem_perm.gid);
+			err2 |=3D __put_user(s.sem_perm.cuid, &usp32->sem_perm.cuid);
+			err2 |=3D __put_user(s.sem_perm.cgid, &usp32->sem_perm.cgid);
+			err2 |=3D __put_user(s.sem_perm.mode, &usp32->sem_perm.mode);
+			err2 |=3D __put_user(s.sem_perm.seq, &usp32->sem_perm.seq);
+			err2 |=3D __put_user(s.sem_otime, &usp32->sem_otime);
+			err2 |=3D __put_user(s.sem_ctime, &usp32->sem_ctime);
+			err2 |=3D __put_user(s.sem_nsems, &usp32->sem_nsems);
+		}
 		if (err2)
-			err =3D -EFAULT;
+		    err =3D -EFAULT;
 		break;
 	}
 	return err;
@@ -1856,23 +2229,23 @@
 static int
 do_sys32_msgsnd (int first, int second, int third, void *uptr)
 {
-	struct msgbuf *p =3D kmalloc (second + sizeof(struct msgbuf) + 4, GFP_USE=
R);
+	struct msgbuf *p =3D kmalloc(second + sizeof(struct msgbuf) + 4, GFP_USER=
);
 	struct msgbuf32 *up =3D (struct msgbuf32 *)uptr;
 	mm_segment_t old_fs;
 	int err;
=20
 	if (!p)
 		return -ENOMEM;
-	err =3D get_user (p->mtype, &up->mtype);
-	err |=3D __copy_from_user (p->mtext, &up->mtext, second);
+	err =3D get_user(p->mtype, &up->mtype);
+	err |=3D copy_from_user(p->mtext, &up->mtext, second);
 	if (err)
 		goto out;
-	old_fs =3D get_fs ();
+	old_fs =3D get_fs();
 	set_fs(KERNEL_DS);
-	err =3D sys_msgsnd (first, p, second, third);
+	err =3D sys_msgsnd(first, p, second, third);
 	set_fs(old_fs);
-out:
-	kfree (p);
+  out:
+	kfree(p);
 	return err;
 }
=20
@@ -1892,53 +2265,60 @@
 		if (!uptr)
 			goto out;
 		err =3D -EFAULT;
-		if (copy_from_user (&ipck, uipck, sizeof (struct ipc_kludge)))
+		if (copy_from_user(&ipck, uipck, sizeof(struct ipc_kludge)))
 			goto out;
 		uptr =3D (void *)A(ipck.msgp);
 		msgtyp =3D ipck.msgtyp;
 	}
 	err =3D -ENOMEM;
-	p =3D kmalloc (second + sizeof (struct msgbuf) + 4, GFP_USER);
+	p =3D kmalloc(second + sizeof(struct msgbuf) + 4, GFP_USER);
 	if (!p)
 		goto out;
-	old_fs =3D get_fs ();
+	old_fs =3D get_fs();
 	set_fs(KERNEL_DS);
-	err =3D sys_msgrcv (first, p, second + 4, msgtyp, third);
+	err =3D sys_msgrcv(first, p, second + 4, msgtyp, third);
 	set_fs(old_fs);
 	if (err < 0)
 		goto free_then_out;
 	up =3D (struct msgbuf32 *)uptr;
-	if (put_user (p->mtype, &up->mtype) ||
-	    __copy_to_user (&up->mtext, p->mtext, err))
+	if (put_user(p->mtype, &up->mtype) || copy_to_user(&up->mtext, p->mtext, =
err))
 		err =3D -EFAULT;
 free_then_out:
-	kfree (p);
+	kfree(p);
 out:
 	return err;
 }
=20
 static int
-do_sys32_msgctl (int first, int second, void *uptr)
+msgctl32 (int first, int second, void *uptr)
 {
 	int err =3D -EINVAL, err2;
 	struct msqid_ds m;
 	struct msqid64_ds m64;
-	struct msqid_ds32 *up =3D (struct msqid_ds32 *)uptr;
+	struct msqid_ds32 *up32 =3D (struct msqid_ds32 *)uptr;
+	struct msqid64_ds32 *up64 =3D (struct msqid64_ds32 *)uptr;
 	mm_segment_t old_fs;
+	int version =3D ipc_parse_version32(&second);
=20
 	switch (second) {
-
-	case IPC_INFO:
-	case IPC_RMID:
-	case MSG_INFO:
+	      case IPC_INFO:
+	      case IPC_RMID:
+	      case MSG_INFO:
 		err =3D sys_msgctl(first, second, (struct msqid_ds *)uptr);
 		break;
=20
-	case IPC_SET:
-		err =3D get_user(m.msg_perm.uid, &up->msg_perm.uid);
-		err |=3D get_user(m.msg_perm.gid, &up->msg_perm.gid);
-		err |=3D get_user(m.msg_perm.mode, &up->msg_perm.mode);
-		err |=3D get_user(m.msg_qbytes, &up->msg_qbytes);
+	      case IPC_SET:
+		if (version =3D IPC_64) {
+			err =3D get_user(m.msg_perm.uid, &up64->msg_perm.uid);
+			err |=3D get_user(m.msg_perm.gid, &up64->msg_perm.gid);
+			err |=3D get_user(m.msg_perm.mode, &up64->msg_perm.mode);
+			err |=3D get_user(m.msg_qbytes, &up64->msg_qbytes);
+		} else {
+			err =3D get_user(m.msg_perm.uid, &up32->msg_perm.uid);
+			err |=3D get_user(m.msg_perm.gid, &up32->msg_perm.gid);
+			err |=3D get_user(m.msg_perm.mode, &up32->msg_perm.mode);
+			err |=3D get_user(m.msg_qbytes, &up32->msg_qbytes);
+		}
 		if (err)
 			break;
 		old_fs =3D get_fs();
@@ -1947,36 +2327,65 @@
 		set_fs(old_fs);
 		break;
=20
-	case IPC_STAT:
-	case MSG_STAT:
+	      case IPC_STAT:
+	      case MSG_STAT:
 		old_fs =3D get_fs();
 		set_fs(KERNEL_DS);
 		err =3D sys_msgctl(first, second, (void *) &m64);
 		set_fs(old_fs);
-		err2 =3D put_user(m64.msg_perm.key, &up->msg_perm.key);
-		err2 |=3D put_user(m64.msg_perm.uid, &up->msg_perm.uid);
-		err2 |=3D put_user(m64.msg_perm.gid, &up->msg_perm.gid);
-		err2 |=3D put_user(m64.msg_perm.cuid, &up->msg_perm.cuid);
-		err2 |=3D put_user(m64.msg_perm.cgid, &up->msg_perm.cgid);
-		err2 |=3D put_user(m64.msg_perm.mode, &up->msg_perm.mode);
-		err2 |=3D put_user(m64.msg_perm.seq, &up->msg_perm.seq);
-		err2 |=3D put_user(m64.msg_stime, &up->msg_stime);
-		err2 |=3D put_user(m64.msg_rtime, &up->msg_rtime);
-		err2 |=3D put_user(m64.msg_ctime, &up->msg_ctime);
-		err2 |=3D put_user(m64.msg_cbytes, &up->msg_cbytes);
-		err2 |=3D put_user(m64.msg_qnum, &up->msg_qnum);
-		err2 |=3D put_user(m64.msg_qbytes, &up->msg_qbytes);
-		err2 |=3D put_user(m64.msg_lspid, &up->msg_lspid);
-		err2 |=3D put_user(m64.msg_lrpid, &up->msg_lrpid);
-		if (err2)
-			err =3D -EFAULT;
+
+		if (version =3D IPC_64) {
+			if (!access_ok(VERIFY_WRITE, up64, sizeof(*up64))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(m64.msg_perm.key, &up64->msg_perm.key);
+			err2 |=3D __put_user(m64.msg_perm.uid, &up64->msg_perm.uid);
+			err2 |=3D __put_user(m64.msg_perm.gid, &up64->msg_perm.gid);
+			err2 |=3D __put_user(m64.msg_perm.cuid, &up64->msg_perm.cuid);
+			err2 |=3D __put_user(m64.msg_perm.cgid, &up64->msg_perm.cgid);
+			err2 |=3D __put_user(m64.msg_perm.mode, &up64->msg_perm.mode);
+			err2 |=3D __put_user(m64.msg_perm.seq, &up64->msg_perm.seq);
+			err2 |=3D __put_user(m64.msg_stime, &up64->msg_stime);
+			err2 |=3D __put_user(m64.msg_rtime, &up64->msg_rtime);
+			err2 |=3D __put_user(m64.msg_ctime, &up64->msg_ctime);
+			err2 |=3D __put_user(m64.msg_cbytes, &up64->msg_cbytes);
+			err2 |=3D __put_user(m64.msg_qnum, &up64->msg_qnum);
+			err2 |=3D __put_user(m64.msg_qbytes, &up64->msg_qbytes);
+			err2 |=3D __put_user(m64.msg_lspid, &up64->msg_lspid);
+			err2 |=3D __put_user(m64.msg_lrpid, &up64->msg_lrpid);
+			if (err2)
+				err =3D -EFAULT;
+		} else {
+			if (!access_ok(VERIFY_WRITE, up32, sizeof(*up32))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(m64.msg_perm.key, &up32->msg_perm.key);
+			err2 |=3D __put_user(m64.msg_perm.uid, &up32->msg_perm.uid);
+			err2 |=3D __put_user(m64.msg_perm.gid, &up32->msg_perm.gid);
+			err2 |=3D __put_user(m64.msg_perm.cuid, &up32->msg_perm.cuid);
+			err2 |=3D __put_user(m64.msg_perm.cgid, &up32->msg_perm.cgid);
+			err2 |=3D __put_user(m64.msg_perm.mode, &up32->msg_perm.mode);
+			err2 |=3D __put_user(m64.msg_perm.seq, &up32->msg_perm.seq);
+			err2 |=3D __put_user(m64.msg_stime, &up32->msg_stime);
+			err2 |=3D __put_user(m64.msg_rtime, &up32->msg_rtime);
+			err2 |=3D __put_user(m64.msg_ctime, &up32->msg_ctime);
+			err2 |=3D __put_user(m64.msg_cbytes, &up32->msg_cbytes);
+			err2 |=3D __put_user(m64.msg_qnum, &up32->msg_qnum);
+			err2 |=3D __put_user(m64.msg_qbytes, &up32->msg_qbytes);
+			err2 |=3D __put_user(m64.msg_lspid, &up32->msg_lspid);
+			err2 |=3D __put_user(m64.msg_lrpid, &up32->msg_lrpid);
+			if (err2)
+				err =3D -EFAULT;
+		}
 		break;
 	}
 	return err;
 }
=20
 static int
-do_sys32_shmat (int first, int second, int third, int version, void *uptr)
+shmat32 (int first, int second, int third, int version, void *uptr)
 {
 	unsigned long raddr;
 	u32 *uaddr =3D (u32 *)A((u32)third);
@@ -1991,32 +2400,69 @@
 }
=20
 static int
-do_sys32_shmctl (int first, int second, void *uptr)
+shmctl32 (int first, int second, void *uptr)
 {
 	int err =3D -EFAULT, err2;
 	struct shmid_ds s;
 	struct shmid64_ds s64;
-	struct shmid_ds32 *up =3D (struct shmid_ds32 *)uptr;
+	struct shmid_ds32 *up32 =3D (struct shmid_ds32 *)uptr;
+	struct shmid64_ds32 *up64 =3D (struct shmid64_ds32 *)uptr;
 	mm_segment_t old_fs;
-	struct shm_info32 {
-		int used_ids;
-		u32 shm_tot, shm_rss, shm_swp;
-		u32 swap_attempts, swap_successes;
-	} *uip =3D (struct shm_info32 *)uptr;
+	struct shm_info32 *uip =3D (struct shm_info32 *)uptr;
 	struct shm_info si;
+	int version =3D ipc_parse_version32(&second);
+	struct shminfo64 smi;
+	struct shminfo *usi32 =3D (struct shminfo *) uptr;
+	struct shminfo64_32 *usi64 =3D (struct shminfo64_32 *) uptr;
=20
 	switch (second) {
+	      case IPC_INFO:
+		old_fs =3D get_fs();
+		set_fs(KERNEL_DS);
+		err =3D sys_shmctl(first, second, (struct shmid_ds *)&smi);
+		set_fs(old_fs);
+
+		if (version =3D IPC_64) {
+			if (!access_ok(VERIFY_WRITE, usi64, sizeof(*usi64))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(smi.shmmax, &usi64->shmmax);
+			err2 |=3D __put_user(smi.shmmin, &usi64->shmmin);
+			err2 |=3D __put_user(smi.shmmni, &usi64->shmmni);
+			err2 |=3D __put_user(smi.shmseg, &usi64->shmseg);
+			err2 |=3D __put_user(smi.shmall, &usi64->shmall);
+		} else {
+			if (!access_ok(VERIFY_WRITE, usi32, sizeof(*usi32))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(smi.shmmax, &usi32->shmmax);
+			err2 |=3D __put_user(smi.shmmin, &usi32->shmmin);
+			err2 |=3D __put_user(smi.shmmni, &usi32->shmmni);
+			err2 |=3D __put_user(smi.shmseg, &usi32->shmseg);
+			err2 |=3D __put_user(smi.shmall, &usi32->shmall);
+		}
+		if (err2)
+			err =3D -EFAULT;
+		break;
=20
-	case IPC_INFO:
-	case IPC_RMID:
-	case SHM_LOCK:
-	case SHM_UNLOCK:
-		err =3D sys_shmctl (first, second, (struct shmid_ds *)uptr);
+	      case IPC_RMID:
+	      case SHM_LOCK:
+	      case SHM_UNLOCK:
+		err =3D sys_shmctl(first, second, (struct shmid_ds *)uptr);
 		break;
-	case IPC_SET:
-		err =3D get_user (s.shm_perm.uid, &up->shm_perm.uid);
-		err |=3D get_user(s.shm_perm.gid, &up->shm_perm.gid);
-		err |=3D get_user(s.shm_perm.mode, &up->shm_perm.mode);
+
+	      case IPC_SET:
+		if (version =3D IPC_64) {
+			err =3D get_user(s.shm_perm.uid, &up64->shm_perm.uid);
+			err |=3D get_user(s.shm_perm.gid, &up64->shm_perm.gid);
+			err |=3D get_user(s.shm_perm.mode, &up64->shm_perm.mode);
+		} else {
+			err =3D get_user(s.shm_perm.uid, &up32->shm_perm.uid);
+			err |=3D get_user(s.shm_perm.gid, &up32->shm_perm.gid);
+			err |=3D get_user(s.shm_perm.mode, &up32->shm_perm.mode);
+		}
 		if (err)
 			break;
 		old_fs =3D get_fs();
@@ -2025,45 +2471,75 @@
 		set_fs(old_fs);
 		break;
=20
-	case IPC_STAT:
-	case SHM_STAT:
+	      case IPC_STAT:
+	      case SHM_STAT:
 		old_fs =3D get_fs();
 		set_fs(KERNEL_DS);
-		err =3D sys_shmctl (first, second, (void *) &s64);
+		err =3D sys_shmctl(first, second, (void *) &s64);
 		set_fs(old_fs);
 		if (err < 0)
 			break;
-		err2 =3D put_user(s64.shm_perm.key, &up->shm_perm.key);
-		err2 |=3D put_user(s64.shm_perm.uid, &up->shm_perm.uid);
-		err2 |=3D put_user(s64.shm_perm.gid, &up->shm_perm.gid);
-		err2 |=3D put_user(s64.shm_perm.cuid, &up->shm_perm.cuid);
-		err2 |=3D put_user(s64.shm_perm.cgid, &up->shm_perm.cgid);
-		err2 |=3D put_user(s64.shm_perm.mode, &up->shm_perm.mode);
-		err2 |=3D put_user(s64.shm_perm.seq, &up->shm_perm.seq);
-		err2 |=3D put_user(s64.shm_atime, &up->shm_atime);
-		err2 |=3D put_user(s64.shm_dtime, &up->shm_dtime);
-		err2 |=3D put_user(s64.shm_ctime, &up->shm_ctime);
-		err2 |=3D put_user(s64.shm_segsz, &up->shm_segsz);
-		err2 |=3D put_user(s64.shm_nattch, &up->shm_nattch);
-		err2 |=3D put_user(s64.shm_cpid, &up->shm_cpid);
-		err2 |=3D put_user(s64.shm_lpid, &up->shm_lpid);
+		if (version =3D IPC_64) {
+			if (!access_ok(VERIFY_WRITE, up64, sizeof(*up64))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(s64.shm_perm.key, &up64->shm_perm.key);
+			err2 |=3D __put_user(s64.shm_perm.uid, &up64->shm_perm.uid);
+			err2 |=3D __put_user(s64.shm_perm.gid, &up64->shm_perm.gid);
+			err2 |=3D __put_user(s64.shm_perm.cuid, &up64->shm_perm.cuid);
+			err2 |=3D __put_user(s64.shm_perm.cgid, &up64->shm_perm.cgid);
+			err2 |=3D __put_user(s64.shm_perm.mode, &up64->shm_perm.mode);
+			err2 |=3D __put_user(s64.shm_perm.seq, &up64->shm_perm.seq);
+			err2 |=3D __put_user(s64.shm_atime, &up64->shm_atime);
+			err2 |=3D __put_user(s64.shm_dtime, &up64->shm_dtime);
+			err2 |=3D __put_user(s64.shm_ctime, &up64->shm_ctime);
+			err2 |=3D __put_user(s64.shm_segsz, &up64->shm_segsz);
+			err2 |=3D __put_user(s64.shm_nattch, &up64->shm_nattch);
+			err2 |=3D __put_user(s64.shm_cpid, &up64->shm_cpid);
+			err2 |=3D __put_user(s64.shm_lpid, &up64->shm_lpid);
+		} else {
+			if (!access_ok(VERIFY_WRITE, up32, sizeof(*up32))) {
+				err =3D -EFAULT;
+				break;
+			}
+			err2 =3D __put_user(s64.shm_perm.key, &up32->shm_perm.key);
+			err2 |=3D __put_user(s64.shm_perm.uid, &up32->shm_perm.uid);
+			err2 |=3D __put_user(s64.shm_perm.gid, &up32->shm_perm.gid);
+			err2 |=3D __put_user(s64.shm_perm.cuid, &up32->shm_perm.cuid);
+			err2 |=3D __put_user(s64.shm_perm.cgid, &up32->shm_perm.cgid);
+			err2 |=3D __put_user(s64.shm_perm.mode, &up32->shm_perm.mode);
+			err2 |=3D __put_user(s64.shm_perm.seq, &up32->shm_perm.seq);
+			err2 |=3D __put_user(s64.shm_atime, &up32->shm_atime);
+			err2 |=3D __put_user(s64.shm_dtime, &up32->shm_dtime);
+			err2 |=3D __put_user(s64.shm_ctime, &up32->shm_ctime);
+			err2 |=3D __put_user(s64.shm_segsz, &up32->shm_segsz);
+			err2 |=3D __put_user(s64.shm_nattch, &up32->shm_nattch);
+			err2 |=3D __put_user(s64.shm_cpid, &up32->shm_cpid);
+			err2 |=3D __put_user(s64.shm_lpid, &up32->shm_lpid);
+		}
 		if (err2)
 			err =3D -EFAULT;
 		break;
=20
-	case SHM_INFO:
+	      case SHM_INFO:
 		old_fs =3D get_fs();
 		set_fs(KERNEL_DS);
 		err =3D sys_shmctl(first, second, (void *)&si);
 		set_fs(old_fs);
 		if (err < 0)
 			break;
-		err2 =3D put_user(si.used_ids, &uip->used_ids);
-		err2 |=3D put_user(si.shm_tot, &uip->shm_tot);
-		err2 |=3D put_user(si.shm_rss, &uip->shm_rss);
-		err2 |=3D put_user(si.shm_swp, &uip->shm_swp);
-		err2 |=3D put_user(si.swap_attempts, &uip->swap_attempts);
-		err2 |=3D put_user(si.swap_successes, &uip->swap_successes);
+
+		if (!access_ok(VERIFY_WRITE, uip, sizeof(*uip))) {
+			err =3D -EFAULT;
+			break;
+		}
+		err2 =3D __put_user(si.used_ids, &uip->used_ids);
+		err2 |=3D __put_user(si.shm_tot, &uip->shm_tot);
+		err2 |=3D __put_user(si.shm_rss, &uip->shm_rss);
+		err2 |=3D __put_user(si.shm_swp, &uip->shm_swp);
+		err2 |=3D __put_user(si.swap_attempts, &uip->swap_attempts);
+		err2 |=3D __put_user(si.swap_successes, &uip->swap_successes);
 		if (err2)
 			err =3D -EFAULT;
 		break;
@@ -2087,11 +2563,7 @@
 	      case SEMGET:
 		return sys_semget(first, second, third);
 	      case SEMCTL:
-		if (third & IPC_64) {
-			printk("sys32_ipc(SEMCTL): no IPC_64 version; please fix me.");
-			return -ENOSYS;
-		}
-		return do_sys32_semctl(first, second, third, (void *)AA(ptr));
+		return semctl32(first, second, third, (void *)AA(ptr));
=20
 	      case MSGSND:
 		return do_sys32_msgsnd(first, second, third, (void *)AA(ptr));
@@ -2100,25 +2572,17 @@
 	      case MSGGET:
 		return sys_msgget((key_t) first, second);
 	      case MSGCTL:
-		if (second & IPC_64) {
-			printk("sys32_ipc(MSGCTL): no IPC_64 version; please fix me.");
-			return -ENOSYS;
-		}
-		return do_sys32_msgctl(first, second, (void *)AA(ptr));
+		return msgctl32(first, second, (void *)AA(ptr));
=20
 	      case SHMAT:
-		err =3D do_sys32_shmat(first, second, third, version, (void *)AA(ptr));
+		err =3D shmat32(first, second, third, version, (void *)AA(ptr));
 		break;
 	      case SHMDT:
 		return sys_shmdt((char *)AA(ptr));
 	      case SHMGET:
 		return sys_shmget(first, second, third);
 	      case SHMCTL:
-		if (second & IPC_64) {
-			printk("sys32_ipc(SHMCTL): no IPC_64 version; please fix me.");
-			return -ENOSYS;
-		}
-		return do_sys32_shmctl(first, second, (void *)AA(ptr));
+		return shmctl32(first, second, (void *)AA(ptr));
=20
 	      default:
 		return -EINVAL;
@@ -2169,7 +2633,10 @@
 {
 	int err;
=20
-	err =3D put_user (r->ru_utime.tv_sec, &ru->ru_utime.tv_sec);
+	if (!access_ok(VERIFY_WRITE, ru, sizeof(*ru)))
+		return -EFAULT;
+
+	err =3D __put_user (r->ru_utime.tv_sec, &ru->ru_utime.tv_sec);
 	err |=3D __put_user (r->ru_utime.tv_usec, &ru->ru_utime.tv_usec);
 	err |=3D __put_user (r->ru_stime.tv_sec, &ru->ru_stime.tv_sec);
 	err |=3D __put_user (r->ru_stime.tv_usec, &ru->ru_stime.tv_usec);
@@ -2329,7 +2796,7 @@
 		return __USER_DS;
 	      case PT_CS: return __USER_CS;
 	      default:
-		printk(KERN_ERR "getreg:unknown register %d\n", regno);
+		printk(KERN_ERR "ia32.getreg(): unknown register %d\n", regno);
 		break;
 	}
 	return 0;
@@ -2355,16 +2822,18 @@
 	      case PT_EFL: child->thread.eflag =3D value; break;
 	      case PT_DS: case PT_ES: case PT_FS: case PT_GS: case PT_SS:
 		if (value !=3D __USER_DS)
-			printk(KERN_ERR "setregs:try to set invalid segment register %d =3D %x\=
n",
+			printk(KERN_ERR
+			       "ia32.putreg: attempt to set invalid segment register %d =3D %x\=
n",
 			       regno, value);
 		break;
 	      case PT_CS:
 		if (value !=3D __USER_CS)
-			printk(KERN_ERR "setregs:try to set invalid segment register %d =3D %x\=
n",
+			printk(KERN_ERR
+			       "ia32.putreg: attempt to to set invalid segment register %d =3D =
%x\n",
 			       regno, value);
 		break;
 	      default:
-		printk(KERN_ERR "putreg:unknown register %d\n", regno);
+		printk(KERN_ERR "ia32.putreg: unknown register %d\n", regno);
 		break;
 	}
 }
@@ -2372,22 +2841,14 @@
 static inline void
 ia32f2ia64f (void *dst, void *src)
 {
-
-	__asm__ ("ldfe f6=3D[%1] ;;\n\t"
-		 "stf.spill [%0]=F6"
-		:
-		: "r"(dst), "r"(src));
+	asm volatile ("ldfe f6=3D[%1];; stf.spill [%0]=F6" :: "r"(dst), "r"(src) =
: "memory");
 	return;
 }
=20
 static inline void
 ia64f2ia32f (void *dst, void *src)
 {
-
-	__asm__ ("ldf.fill f6=3D[%1] ;;\n\t"
-		 "stfe [%0]=F6"
-		:
-		: "r"(dst),  "r"(src));
+	asm volatile ("ldf.fill f6=3D[%1];; stfe [%0]=F6" :: "r"(dst),  "r"(src) =
: "memory");
 	return;
 }
=20
@@ -2402,24 +2863,22 @@
 	if ((regno +=3D tos) >=3D 8)
 		regno -=3D 8;
 	switch (regno) {
-
-	case 0:
+	      case 0:
 		ia64f2ia32f(f, &ptp->f8);
 		break;
-	case 1:
+	      case 1:
 		ia64f2ia32f(f, &ptp->f9);
 		break;
-	case 2:
-	case 3:
-	case 4:
-	case 5:
-	case 6:
-	case 7:
+	      case 2:
+	      case 3:
+	      case 4:
+	      case 5:
+	      case 6:
+	      case 7:
 		ia64f2ia32f(f, &swp->f10 + (regno - 2));
 		break;
-
 	}
-	__copy_to_user(reg, f, sizeof(*reg));
+	copy_to_user(reg, f, sizeof(*reg));
 }
=20
 static void
@@ -2430,22 +2889,20 @@
 	if ((regno +=3D tos) >=3D 8)
 		regno -=3D 8;
 	switch (regno) {
-
-	case 0:
-		__copy_from_user(&ptp->f8, reg, sizeof(*reg));
+	      case 0:
+		copy_from_user(&ptp->f8, reg, sizeof(*reg));
 		break;
-	case 1:
-		__copy_from_user(&ptp->f9, reg, sizeof(*reg));
+	      case 1:
+		copy_from_user(&ptp->f9, reg, sizeof(*reg));
 		break;
-	case 2:
-	case 3:
-	case 4:
-	case 5:
-	case 6:
-	case 7:
-		__copy_from_user(&swp->f10 + (regno - 2), reg, sizeof(*reg));
+	      case 2:
+	      case 3:
+	      case 4:
+	      case 5:
+	      case 6:
+	      case 7:
+		copy_from_user(&swp->f10 + (regno - 2), reg, sizeof(*reg));
 		break;
-
 	}
 	return;
 }
@@ -2458,7 +2915,7 @@
 	int i, tos;
=20
 	if (!access_ok(VERIFY_WRITE, save, sizeof(*save)))
-		return(-EIO);
+		return -EIO;
 	__put_user(tsk->thread.fcr, &save->cw);
 	__put_user(tsk->thread.fsr, &save->sw);
 	__put_user(tsk->thread.fsr >> 32, &save->tag);
@@ -2643,7 +3100,10 @@
 {
 	int err;
=20
-	err =3D get_user(kfl->l_type, &ufl->l_type);
+	if (!access_ok(VERIFY_READ, ufl, sizeof(*ufl)))
+		return -EFAULT;
+
+	err =3D __get_user(kfl->l_type, &ufl->l_type);
 	err |=3D __get_user(kfl->l_whence, &ufl->l_whence);
 	err |=3D __get_user(kfl->l_start, &ufl->l_start);
 	err |=3D __get_user(kfl->l_len, &ufl->l_len);
@@ -2656,6 +3116,9 @@
 {
 	int err;
=20
+	if (!access_ok(VERIFY_WRITE, ufl, sizeof(*ufl)))
+		return -EFAULT;
+
 	err =3D __put_user(kfl->l_type, &ufl->l_type);
 	err |=3D __put_user(kfl->l_whence, &ufl->l_whence);
 	err |=3D __put_user(kfl->l_start, &ufl->l_start);
@@ -2696,39 +3159,6 @@
 	}
 }
=20
-asmlinkage long
-sys32_sigaction (int sig, struct old_sigaction32 *act, struct old_sigactio=
n32 *oact)
-{
-	struct k_sigaction new_ka, old_ka;
-	unsigned int handler, restorer;
-	int ret;
-
-	if (act) {
-		old_sigset32_t mask;
-
-		ret =3D get_user(handler, &act->sa_handler);
-		ret |=3D get_user(new_ka.sa.sa_flags, &act->sa_flags);
-		ret |=3D get_user(restorer, &act->sa_restorer);
-		ret |=3D get_user(mask, &act->sa_mask);
-		if (ret)
-			return ret;
-
-		sigact_set_handler(&new_ka, handler, restorer);
-		siginitset(&new_ka.sa.sa_mask, mask);
-	}
-
-	ret =3D do_sigaction(sig, act ? &new_ka : NULL, oact ? &old_ka : NULL);
-
-	if (!ret && oact) {
-		ret =3D put_user(IA32_SA_HANDLER(&old_ka), &oact->sa_handler);
-		ret |=3D put_user(old_ka.sa.sa_flags, &oact->sa_flags);
-		ret |=3D put_user(IA32_SA_RESTORER(&old_ka), &oact->sa_restorer);
-		ret |=3D put_user(old_ka.sa.sa_mask.sig[0], &oact->sa_mask);
-	}
-
-	return ret;
-}
-
 asmlinkage long sys_ni_syscall(void);
=20
 asmlinkage long
@@ -2784,7 +3214,7 @@
=20
 	if (addr >=3D 0) {
 		old =3D (old & ~0x3000) | (level << 12);
-		__asm__ __volatile__("mov ar.eflag=3D%0 ;;" :: "r"(old));
+		asm volatile ("mov ar.eflag=3D%0;;" :: "r"(old));
 	}
=20
 	fput(file);
@@ -2863,7 +3293,7 @@
=20
 	if (OFFSET4K(start))
 		return -EINVAL;
-	addr =3D start & PAGE_MASK;
+	addr =3D PAGE_START(start);
 	return sys_msync(addr, len + (start - addr), flags);
 }
=20
@@ -3360,844 +3790,225 @@
 	if (!ret && offset && put_user(of, offset))
 		return -EFAULT;
=20
-	return ret;
-}
-
-asmlinkage long
-sys32_personality (unsigned int personality)
-{
-	extern asmlinkage long sys_personality (unsigned long);
-	long ret;
-
-	if (current->personality =3D PER_LINUX32 && personality =3D PER_LINUX)
-		personality =3D PER_LINUX32;
-	ret =3D sys_personality(personality);
-	if (ret =3D PER_LINUX32)
-		ret =3D PER_LINUX;
-	return ret;
-}
-
-#ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
-
-/*
- * Ooo, nasty.  We need here to frob 32-bit unsigned longs to
- * 64-bit unsigned longs.
- */
-
-static inline int
-get_fd_set32(unsigned long n, unsigned long *fdset, u32 *ufdset)
-{
-	if (ufdset) {
-		unsigned long odd;
-
-		if (verify_area(VERIFY_WRITE, ufdset, n*sizeof(u32)))
-			return -EFAULT;
-
-		odd =3D n & 1UL;
-		n &=3D ~1UL;
-		while (n) {
-			unsigned long h, l;
-			__get_user(l, ufdset);
-			__get_user(h, ufdset+1);
-			ufdset +=3D 2;
-			*fdset++ =3D h << 32 | l;
-			n -=3D 2;
-		}
-		if (odd)
-			__get_user(*fdset, ufdset);
-	} else {
-		/* Tricky, must clear full unsigned long in the
-		 * kernel fdset at the end, this makes sure that
-		 * actually happens.
-		 */
-		memset(fdset, 0, ((n + 1) & ~1)*sizeof(u32));
-	}
-	return 0;
-}
-
-static inline void
-set_fd_set32(unsigned long n, u32 *ufdset, unsigned long *fdset)
-{
-	unsigned long odd;
-
-	if (!ufdset)
-		return;
-
-	odd =3D n & 1UL;
-	n &=3D ~1UL;
-	while (n) {
-		unsigned long h, l;
-		l =3D *fdset++;
-		h =3D l >> 32;
-		__put_user(l, ufdset);
-		__put_user(h, ufdset+1);
-		ufdset +=3D 2;
-		n -=3D 2;
-	}
-	if (odd)
-		__put_user(*fdset, ufdset);
-}
-
-struct ncp_mount_data32 {
-	int version;
-	unsigned int ncp_fd;
-	__kernel_uid_t32 mounted_uid;
-	int wdog_pid;
-	unsigned char mounted_vol[NCP_VOLNAME_LEN + 1];
-	unsigned int time_out;
-	unsigned int retry_count;
-	unsigned int flags;
-	__kernel_uid_t32 uid;
-	__kernel_gid_t32 gid;
-	__kernel_mode_t32 file_mode;
-	__kernel_mode_t32 dir_mode;
-};
-
-static void *
-do_ncp_super_data_conv(void *raw_data)
-{
-	struct ncp_mount_data *n =3D (struct ncp_mount_data *)raw_data;
-	struct ncp_mount_data32 *n32 =3D (struct ncp_mount_data32 *)raw_data;
-
-	n->dir_mode =3D n32->dir_mode;
-	n->file_mode =3D n32->file_mode;
-	n->gid =3D n32->gid;
-	n->uid =3D n32->uid;
-	memmove (n->mounted_vol, n32->mounted_vol,
-		 (sizeof (n32->mounted_vol) + 3 * sizeof (unsigned int)));
-	n->wdog_pid =3D n32->wdog_pid;
-	n->mounted_uid =3D n32->mounted_uid;
-	return raw_data;
-}
-
-struct smb_mount_data32 {
-	int version;
-	__kernel_uid_t32 mounted_uid;
-	__kernel_uid_t32 uid;
-	__kernel_gid_t32 gid;
-	__kernel_mode_t32 file_mode;
-	__kernel_mode_t32 dir_mode;
-};
-
-static void *
-do_smb_super_data_conv(void *raw_data)
-{
-	struct smb_mount_data *s =3D (struct smb_mount_data *)raw_data;
-	struct smb_mount_data32 *s32 =3D (struct smb_mount_data32 *)raw_data;
-
-	s->version =3D s32->version;
-	s->mounted_uid =3D s32->mounted_uid;
-	s->uid =3D s32->uid;
-	s->gid =3D s32->gid;
-	s->file_mode =3D s32->file_mode;
-	s->dir_mode =3D s32->dir_mode;
-	return raw_data;
-}
-
-static int
-copy_mount_stuff_to_kernel(const void *user, unsigned long *kernel)
-{
-	int i;
-	unsigned long page;
-	struct vm_area_struct *vma;
-
-	*kernel =3D 0;
-	if(!user)
-		return 0;
-	vma =3D find_vma(current->mm, (unsigned long)user);
-	if(!vma || (unsigned long)user < vma->vm_start)
-		return -EFAULT;
-	if(!(vma->vm_flags & VM_READ))
-		return -EFAULT;
-	i =3D vma->vm_end - (unsigned long) user;
-	if(PAGE_SIZE <=3D (unsigned long) i)
-		i =3D PAGE_SIZE - 1;
-	if(!(page =3D __get_free_page(GFP_KERNEL)))
-		return -ENOMEM;
-	if(copy_from_user((void *) page, user, i)) {
-		free_page(page);
-		return -EFAULT;
-	}
-	*kernel =3D page;
-	return 0;
-}
-
-extern asmlinkage long sys_mount(char * dev_name, char * dir_name, char * =
type,
-				unsigned long new_flags, void *data);
-
-#define SMBFS_NAME	"smbfs"
-#define NCPFS_NAME	"ncpfs"
-
-asmlinkage long
-sys32_mount(char *dev_name, char *dir_name, char *type,
-	    unsigned long new_flags, u32 data)
-{
-	unsigned long type_page;
-	int err, is_smb, is_ncp;
-
-	if(!capable(CAP_SYS_ADMIN))
-		return -EPERM;
-	is_smb =3D is_ncp =3D 0;
-	err =3D copy_mount_stuff_to_kernel((const void *)type, &type_page);
-	if(err)
-		return err;
-	if(type_page) {
-		is_smb =3D !strcmp((char *)type_page, SMBFS_NAME);
-		is_ncp =3D !strcmp((char *)type_page, NCPFS_NAME);
-	}
-	if(!is_smb && !is_ncp) {
-		if(type_page)
-			free_page(type_page);
-		return sys_mount(dev_name, dir_name, type, new_flags,
-				 (void *)AA(data));
-	} else {
-		unsigned long dev_page, dir_page, data_page;
-
-		err =3D copy_mount_stuff_to_kernel((const void *)dev_name,
-						 &dev_page);
-		if(err)
-			goto out;
-		err =3D copy_mount_stuff_to_kernel((const void *)dir_name,
-						 &dir_page);
-		if(err)
-			goto dev_out;
-		err =3D copy_mount_stuff_to_kernel((const void *)AA(data),
-						 &data_page);
-		if(err)
-			goto dir_out;
-		if(is_ncp)
-			do_ncp_super_data_conv((void *)data_page);
-		else if(is_smb)
-			do_smb_super_data_conv((void *)data_page);
-		else
-			panic("The problem is here...");
-		err =3D do_mount((char *)dev_page, (char *)dir_page,
-				(char *)type_page, new_flags,
-				(void *)data_page);
-		if(data_page)
-			free_page(data_page);
-	dir_out:
-		if(dir_page)
-			free_page(dir_page);
-	dev_out:
-		if(dev_page)
-			free_page(dev_page);
-	out:
-		if(type_page)
-			free_page(type_page);
-		return err;
-	}
-}
-
-extern asmlinkage long sys_setreuid(uid_t ruid, uid_t euid);
-
-asmlinkage long sys32_setreuid(__kernel_uid_t32 ruid, __kernel_uid_t32 eui=
d)
-{
-	uid_t sruid, seuid;
-
-	sruid =3D (ruid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)ruid);
-	seuid =3D (euid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)euid);
-	return sys_setreuid(sruid, seuid);
-}
-
-extern asmlinkage long sys_setresuid(uid_t ruid, uid_t euid, uid_t suid);
-
-asmlinkage long
-sys32_setresuid(__kernel_uid_t32 ruid, __kernel_uid_t32 euid,
-		__kernel_uid_t32 suid)
-{
-	uid_t sruid, seuid, ssuid;
-
-	sruid =3D (ruid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)ruid);
-	seuid =3D (euid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)euid);
-	ssuid =3D (suid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)suid);
-	return sys_setresuid(sruid, seuid, ssuid);
-}
-
-extern asmlinkage long sys_setregid(gid_t rgid, gid_t egid);
-
-asmlinkage long
-sys32_setregid(__kernel_gid_t32 rgid, __kernel_gid_t32 egid)
-{
-	gid_t srgid, segid;
-
-	srgid =3D (rgid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)rgid);
-	segid =3D (egid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)egid);
-	return sys_setregid(srgid, segid);
-}
-
-extern asmlinkage long sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid);
-
-asmlinkage long
-sys32_setresgid(__kernel_gid_t32 rgid, __kernel_gid_t32 egid,
-		__kernel_gid_t32 sgid)
-{
-	gid_t srgid, segid, ssgid;
-
-	srgid =3D (rgid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)rgid);
-	segid =3D (egid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)egid);
-	ssgid =3D (sgid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)sgid);
-	return sys_setresgid(srgid, segid, ssgid);
-}
-
-/* XXX These as well... */
-extern __inline__ struct socket *
-socki_lookup(struct inode *inode)
-{
-	return &inode->u.socket_i;
-}
-
-extern __inline__ struct socket *
-sockfd_lookup(int fd, int *err)
-{
-	struct file *file;
-	struct inode *inode;
-
-	if (!(file =3D fget(fd)))
-	{
-		*err =3D -EBADF;
-		return NULL;
-	}
-
-	inode =3D file->f_dentry->d_inode;
-	if (!inode->i_sock || !socki_lookup(inode))
-	{
-		*err =3D -ENOTSOCK;
-		fput(file);
-		return NULL;
-	}
-
-	return socki_lookup(inode);
-}
-
-struct msghdr32 {
-	u32               msg_name;
-	int               msg_namelen;
-	u32               msg_iov;
-	__kernel_size_t32 msg_iovlen;
-	u32               msg_control;
-	__kernel_size_t32 msg_controllen;
-	unsigned          msg_flags;
-};
-
-struct cmsghdr32 {
-	__kernel_size_t32 cmsg_len;
-	int               cmsg_level;
-	int               cmsg_type;
-};
-
-/* Bleech... */
-#define __CMSG32_NXTHDR(ctl, len, cmsg, cmsglen) \
-	__cmsg32_nxthdr((ctl),(len),(cmsg),(cmsglen))
-#define CMSG32_NXTHDR(mhdr, cmsg, cmsglen) \
-	cmsg32_nxthdr((mhdr), (cmsg), (cmsglen))
-
-#define CMSG32_ALIGN(len) ( ((len)+sizeof(int)-1) & ~(sizeof(int)-1) )
-
-#define CMSG32_DATA(cmsg) \
-	((void *)((char *)(cmsg) + CMSG32_ALIGN(sizeof(struct cmsghdr32))))
-#define CMSG32_SPACE(len) \
-	(CMSG32_ALIGN(sizeof(struct cmsghdr32)) + CMSG32_ALIGN(len))
-#define CMSG32_LEN(len) (CMSG32_ALIGN(sizeof(struct cmsghdr32)) + (len))
-
-#define __CMSG32_FIRSTHDR(ctl,len) ((len) >=3D sizeof(struct cmsghdr32) ? \
-				    (struct cmsghdr32 *)(ctl) : \
-				    (struct cmsghdr32 *)NULL)
-#define CMSG32_FIRSTHDR(msg) \
-	__CMSG32_FIRSTHDR((msg)->msg_control, (msg)->msg_controllen)
-
-__inline__ struct cmsghdr32 *
-__cmsg32_nxthdr(void *__ctl, __kernel_size_t __size,
-		struct cmsghdr32 *__cmsg, int __cmsg_len)
-{
-	struct cmsghdr32 * __ptr;
-
-	__ptr =3D (struct cmsghdr32 *)(((unsigned char *) __cmsg) +
-				     CMSG32_ALIGN(__cmsg_len));
-	if ((unsigned long)((char*)(__ptr+1) - (char *) __ctl) > __size)
-		return NULL;
-
-	return __ptr;
-}
-
-__inline__ struct cmsghdr32 *
-cmsg32_nxthdr (struct msghdr *__msg, struct cmsghdr32 *__cmsg, int __cmsg_=
len)
-{
-	return __cmsg32_nxthdr(__msg->msg_control, __msg->msg_controllen,
-			       __cmsg, __cmsg_len);
-}
-
-static inline int
-iov_from_user32_to_kern(struct iovec *kiov, struct iovec32 *uiov32, int ni=
ov)
-{
-	int tot_len =3D 0;
-
-	while(niov > 0) {
-		u32 len, buf;
-
-		if(get_user(len, &uiov32->iov_len) ||
-		   get_user(buf, &uiov32->iov_base)) {
-			tot_len =3D -EFAULT;
-			break;
-		}
-		tot_len +=3D len;
-		kiov->iov_base =3D (void *)A(buf);
-		kiov->iov_len =3D (__kernel_size_t) len;
-		uiov32++;
-		kiov++;
-		niov--;
-	}
-	return tot_len;
-}
-
-static inline int
-msghdr_from_user32_to_kern(struct msghdr *kmsg, struct msghdr32 *umsg)
-{
-	u32 tmp1, tmp2, tmp3;
-	int err;
-
-	err =3D get_user(tmp1, &umsg->msg_name);
-	err |=3D __get_user(tmp2, &umsg->msg_iov);
-	err |=3D __get_user(tmp3, &umsg->msg_control);
-	if (err)
-		return -EFAULT;
-
-	kmsg->msg_name =3D (void *)A(tmp1);
-	kmsg->msg_iov =3D (struct iovec *)A(tmp2);
-	kmsg->msg_control =3D (void *)A(tmp3);
-
-	err =3D get_user(kmsg->msg_namelen, &umsg->msg_namelen);
-	err |=3D get_user(kmsg->msg_iovlen, &umsg->msg_iovlen);
-	err |=3D get_user(kmsg->msg_controllen, &umsg->msg_controllen);
-	err |=3D get_user(kmsg->msg_flags, &umsg->msg_flags);
-
-	return err;
-}
-
-/* I've named the args so it is easy to tell whose space the pointers are =
in. */
-static int
-verify_iovec32(struct msghdr *kern_msg, struct iovec *kern_iov,
-	       char *kern_address, int mode)
-{
-	int tot_len;
-
-	if(kern_msg->msg_namelen) {
-		if(mode=3DVERIFY_READ) {
-			int err =3D move_addr_to_kernel(kern_msg->msg_name,
-						      kern_msg->msg_namelen,
-						      kern_address);
-			if(err < 0)
-				return err;
-		}
-		kern_msg->msg_name =3D kern_address;
-	} else
-		kern_msg->msg_name =3D NULL;
-
-	if(kern_msg->msg_iovlen > UIO_FASTIOV) {
-		kern_iov =3D kmalloc(kern_msg->msg_iovlen * sizeof(struct iovec),
-				   GFP_KERNEL);
-		if(!kern_iov)
-			return -ENOMEM;
-	}
-
-	tot_len =3D iov_from_user32_to_kern(kern_iov,
-					  (struct iovec32 *)kern_msg->msg_iov,
-					  kern_msg->msg_iovlen);
-	if(tot_len >=3D 0)
-		kern_msg->msg_iov =3D kern_iov;
-	else if(kern_msg->msg_iovlen > UIO_FASTIOV)
-		kfree(kern_iov);
-
-	return tot_len;
-}
-
-/* There is a lot of hair here because the alignment rules (and
- * thus placement) of cmsg headers and length are different for
- * 32-bit apps.  -DaveM
- */
-static int
-cmsghdr_from_user32_to_kern(struct msghdr *kmsg, unsigned char *stackbuf,
-			    int stackbuf_size)
-{
-	struct cmsghdr32 *ucmsg;
-	struct cmsghdr *kcmsg, *kcmsg_base;
-	__kernel_size_t32 ucmlen;
-	__kernel_size_t kcmlen, tmp;
-
-	kcmlen =3D 0;
-	kcmsg_base =3D kcmsg =3D (struct cmsghdr *)stackbuf;
-	ucmsg =3D CMSG32_FIRSTHDR(kmsg);
-	while(ucmsg !=3D NULL) {
-		if(get_user(ucmlen, &ucmsg->cmsg_len))
-			return -EFAULT;
-
-		/* Catch bogons. */
-		if(CMSG32_ALIGN(ucmlen) <
-		   CMSG32_ALIGN(sizeof(struct cmsghdr32)))
-			return -EINVAL;
-		if((unsigned long)(((char *)ucmsg - (char *)kmsg->msg_control)
-				   + ucmlen) > kmsg->msg_controllen)
-			return -EINVAL;
-
-		tmp =3D ((ucmlen - CMSG32_ALIGN(sizeof(*ucmsg))) +
-		       CMSG_ALIGN(sizeof(struct cmsghdr)));
-		kcmlen +=3D tmp;
-		ucmsg =3D CMSG32_NXTHDR(kmsg, ucmsg, ucmlen);
-	}
-	if(kcmlen =3D 0)
-		return -EINVAL;
-
-	/* The kcmlen holds the 64-bit version of the control length.
-	 * It may not be modified as we do not stick it into the kmsg
-	 * until we have successfully copied over all of the data
-	 * from the user.
-	 */
-	if(kcmlen > stackbuf_size)
-		kcmsg_base =3D kcmsg =3D kmalloc(kcmlen, GFP_KERNEL);
-	if(kcmsg =3D NULL)
-		return -ENOBUFS;
-
-	/* Now copy them over neatly. */
-	memset(kcmsg, 0, kcmlen);
-	ucmsg =3D CMSG32_FIRSTHDR(kmsg);
-	while(ucmsg !=3D NULL) {
-		__get_user(ucmlen, &ucmsg->cmsg_len);
-		tmp =3D ((ucmlen - CMSG32_ALIGN(sizeof(*ucmsg))) +
-		       CMSG_ALIGN(sizeof(struct cmsghdr)));
-		kcmsg->cmsg_len =3D tmp;
-		__get_user(kcmsg->cmsg_level, &ucmsg->cmsg_level);
-		__get_user(kcmsg->cmsg_type, &ucmsg->cmsg_type);
-
-		/* Copy over the data. */
-		if(copy_from_user(CMSG_DATA(kcmsg),
-				  CMSG32_DATA(ucmsg),
-				  (ucmlen - CMSG32_ALIGN(sizeof(*ucmsg)))))
-			goto out_free_efault;
-
-		/* Advance. */
-		kcmsg =3D (struct cmsghdr *)((char *)kcmsg + CMSG_ALIGN(tmp));
-		ucmsg =3D CMSG32_NXTHDR(kmsg, ucmsg, ucmlen);
-	}
-
-	/* Ok, looks like we made it.  Hook it up and return success. */
-	kmsg->msg_control =3D kcmsg_base;
-	kmsg->msg_controllen =3D kcmlen;
-	return 0;
-
-out_free_efault:
-	if(kcmsg_base !=3D (struct cmsghdr *)stackbuf)
-		kfree(kcmsg_base);
-	return -EFAULT;
-}
-
-static void
-put_cmsg32(struct msghdr *kmsg, int level, int type, int len, void *data)
-{
-	struct cmsghdr32 *cm =3D (struct cmsghdr32 *) kmsg->msg_control;
-	struct cmsghdr32 cmhdr;
-	int cmlen =3D CMSG32_LEN(len);
-
-	if(cm =3D NULL || kmsg->msg_controllen < sizeof(*cm)) {
-		kmsg->msg_flags |=3D MSG_CTRUNC;
-		return;
-	}
-
-	if(kmsg->msg_controllen < cmlen) {
-		kmsg->msg_flags |=3D MSG_CTRUNC;
-		cmlen =3D kmsg->msg_controllen;
-	}
-	cmhdr.cmsg_level =3D level;
-	cmhdr.cmsg_type =3D type;
-	cmhdr.cmsg_len =3D cmlen;
-
-	if(copy_to_user(cm, &cmhdr, sizeof cmhdr))
-		return;
-	if(copy_to_user(CMSG32_DATA(cm), data,
-			cmlen - sizeof(struct cmsghdr32)))
-		return;
-	cmlen =3D CMSG32_SPACE(len);
-	kmsg->msg_control +=3D cmlen;
-	kmsg->msg_controllen -=3D cmlen;
-}
-
-static void scm_detach_fds32(struct msghdr *kmsg, struct scm_cookie *scm)
-{
-	struct cmsghdr32 *cm =3D (struct cmsghdr32 *) kmsg->msg_control;
-	int fdmax =3D (kmsg->msg_controllen - sizeof(struct cmsghdr32))
-		/ sizeof(int);
-	int fdnum =3D scm->fp->count;
-	struct file **fp =3D scm->fp->fp;
-	int *cmfptr;
-	int err =3D 0, i;
-
-	if (fdnum < fdmax)
-		fdmax =3D fdnum;
-
-	for (i =3D 0, cmfptr =3D (int *) CMSG32_DATA(cm);
-	     i < fdmax;
-	     i++, cmfptr++) {
-		int new_fd;
-		err =3D get_unused_fd();
-		if (err < 0)
-			break;
-		new_fd =3D err;
-		err =3D put_user(new_fd, cmfptr);
-		if (err) {
-			put_unused_fd(new_fd);
-			break;
-		}
-		/* Bump the usage count and install the file. */
-		fp[i]->f_count++;
-		current->files->fd[new_fd] =3D fp[i];
-	}
-
-	if (i > 0) {
-		int cmlen =3D CMSG32_LEN(i * sizeof(int));
-		if (!err)
-			err =3D put_user(SOL_SOCKET, &cm->cmsg_level);
-		if (!err)
-			err =3D put_user(SCM_RIGHTS, &cm->cmsg_type);
-		if (!err)
-			err =3D put_user(cmlen, &cm->cmsg_len);
-		if (!err) {
-			cmlen =3D CMSG32_SPACE(i * sizeof(int));
-			kmsg->msg_control +=3D cmlen;
-			kmsg->msg_controllen -=3D cmlen;
-		}
-	}
-	if (i < fdnum)
-		kmsg->msg_flags |=3D MSG_CTRUNC;
-
-	/*
-	 * All of the files that fit in the message have had their
-	 * usage counts incremented, so we just free the list.
-	 */
-	__scm_destroy(scm);
-}
-
-/* In these cases we (currently) can just copy to data over verbatim
- * because all CMSGs created by the kernel have well defined types which
- * have the same layout in both the 32-bit and 64-bit API.  One must add
- * some special cased conversions here if we start sending control messages
- * with incompatible types.
- *
- * SCM_RIGHTS and SCM_CREDENTIALS are done by hand in recvmsg32 right after
- * we do our work.  The remaining cases are:
- *
- * SOL_IP	IP_PKTINFO	struct in_pktinfo	32-bit clean
- *		IP_TTL		int			32-bit clean
- *		IP_TOS		__u8			32-bit clean
- *		IP_RECVOPTS	variable length		32-bit clean
- *		IP_RETOPTS	variable length		32-bit clean
- *		(these last two are clean because the types are defined
- *		 by the IPv4 protocol)
- *		IP_RECVERR	struct sock_extended_err +
- *				struct sockaddr_in	32-bit clean
- * SOL_IPV6	IPV6_RECVERR	struct sock_extended_err +
- *				struct sockaddr_in6	32-bit clean
- *		IPV6_PKTINFO	struct in6_pktinfo	32-bit clean
- *		IPV6_HOPLIMIT	int			32-bit clean
- *		IPV6_FLOWINFO	u32			32-bit clean
- *		IPV6_HOPOPTS	ipv6 hop exthdr		32-bit clean
- *		IPV6_DSTOPTS	ipv6 dst exthdr(s)	32-bit clean
- *		IPV6_RTHDR	ipv6 routing exthdr	32-bit clean
- *		IPV6_AUTHHDR	ipv6 auth exthdr	32-bit clean
- */
-static void
-cmsg32_recvmsg_fixup(struct msghdr *kmsg, unsigned long orig_cmsg_uptr)
+	return ret;
+}
+
+asmlinkage long
+sys32_personality (unsigned int personality)
 {
-	unsigned char *workbuf, *wp;
-	unsigned long bufsz, space_avail;
-	struct cmsghdr *ucmsg;
+	extern asmlinkage long sys_personality (unsigned long);
+	long ret;
=20
-	bufsz =3D ((unsigned long)kmsg->msg_control) - orig_cmsg_uptr;
-	space_avail =3D kmsg->msg_controllen + bufsz;
-	wp =3D workbuf =3D kmalloc(bufsz, GFP_KERNEL);
-	if(workbuf =3D NULL)
-		goto fail;
+	if (current->personality =3D PER_LINUX32 && personality =3D PER_LINUX)
+		personality =3D PER_LINUX32;
+	ret =3D sys_personality(personality);
+	if (ret =3D PER_LINUX32)
+		ret =3D PER_LINUX;
+	return ret;
+}
=20
-	/* To make this more sane we assume the kernel sends back properly
-	 * formatted control messages.  Because of how the kernel will truncate
-	 * the cmsg_len for MSG_TRUNC cases, we need not check that case either.
-	 */
-	ucmsg =3D (struct cmsghdr *) orig_cmsg_uptr;
-	while(((unsigned long)ucmsg) < ((unsigned long)kmsg->msg_control)) {
-		struct cmsghdr32 *kcmsg32 =3D (struct cmsghdr32 *) wp;
-		int clen64, clen32;
+#ifdef	NOTYET  /* UNTESTED FOR IA64 FROM HERE DOWN */
=20
-		/* UCMSG is the 64-bit format CMSG entry in user-space.
-		 * KCMSG32 is within the kernel space temporary buffer
-		 * we use to convert into a 32-bit style CMSG.
-		 */
-		__get_user(kcmsg32->cmsg_len, &ucmsg->cmsg_len);
-		__get_user(kcmsg32->cmsg_level, &ucmsg->cmsg_level);
-		__get_user(kcmsg32->cmsg_type, &ucmsg->cmsg_type);
+struct ncp_mount_data32 {
+	int version;
+	unsigned int ncp_fd;
+	__kernel_uid_t32 mounted_uid;
+	int wdog_pid;
+	unsigned char mounted_vol[NCP_VOLNAME_LEN + 1];
+	unsigned int time_out;
+	unsigned int retry_count;
+	unsigned int flags;
+	__kernel_uid_t32 uid;
+	__kernel_gid_t32 gid;
+	__kernel_mode_t32 file_mode;
+	__kernel_mode_t32 dir_mode;
+};
=20
-		clen64 =3D kcmsg32->cmsg_len;
-		copy_from_user(CMSG32_DATA(kcmsg32), CMSG_DATA(ucmsg),
-			       clen64 - CMSG_ALIGN(sizeof(*ucmsg)));
-		clen32 =3D ((clen64 - CMSG_ALIGN(sizeof(*ucmsg))) +
-			  CMSG32_ALIGN(sizeof(struct cmsghdr32)));
-		kcmsg32->cmsg_len =3D clen32;
+static void *
+do_ncp_super_data_conv(void *raw_data)
+{
+	struct ncp_mount_data *n =3D (struct ncp_mount_data *)raw_data;
+	struct ncp_mount_data32 *n32 =3D (struct ncp_mount_data32 *)raw_data;
=20
-		ucmsg =3D (struct cmsghdr *) (((char *)ucmsg) +
-					    CMSG_ALIGN(clen64));
-		wp =3D (((char *)kcmsg32) + CMSG32_ALIGN(clen32));
-	}
+	n->dir_mode =3D n32->dir_mode;
+	n->file_mode =3D n32->file_mode;
+	n->gid =3D n32->gid;
+	n->uid =3D n32->uid;
+	memmove (n->mounted_vol, n32->mounted_vol,
+		 (sizeof (n32->mounted_vol) + 3 * sizeof (unsigned int)));
+	n->wdog_pid =3D n32->wdog_pid;
+	n->mounted_uid =3D n32->mounted_uid;
+	return raw_data;
+}
=20
-	/* Copy back fixed up data, and adjust pointers. */
-	bufsz =3D (wp - workbuf);
-	copy_to_user((void *)orig_cmsg_uptr, workbuf, bufsz);
+struct smb_mount_data32 {
+	int version;
+	__kernel_uid_t32 mounted_uid;
+	__kernel_uid_t32 uid;
+	__kernel_gid_t32 gid;
+	__kernel_mode_t32 file_mode;
+	__kernel_mode_t32 dir_mode;
+};
=20
-	kmsg->msg_control =3D (struct cmsghdr *)
-		(((char *)orig_cmsg_uptr) + bufsz);
-	kmsg->msg_controllen =3D space_avail - bufsz;
+static void *
+do_smb_super_data_conv(void *raw_data)
+{
+	struct smb_mount_data *s =3D (struct smb_mount_data *)raw_data;
+	struct smb_mount_data32 *s32 =3D (struct smb_mount_data32 *)raw_data;
=20
-	kfree(workbuf);
-	return;
+	s->version =3D s32->version;
+	s->mounted_uid =3D s32->mounted_uid;
+	s->uid =3D s32->uid;
+	s->gid =3D s32->gid;
+	s->file_mode =3D s32->file_mode;
+	s->dir_mode =3D s32->dir_mode;
+	return raw_data;
+}
=20
-fail:
-	/* If we leave the 64-bit format CMSG chunks in there,
-	 * the application could get confused and crash.  So to
-	 * ensure greater recovery, we report no CMSGs.
-	 */
-	kmsg->msg_controllen +=3D bufsz;
-	kmsg->msg_control =3D (void *) orig_cmsg_uptr;
+static int
+copy_mount_stuff_to_kernel(const void *user, unsigned long *kernel)
+{
+	int i;
+	unsigned long page;
+	struct vm_area_struct *vma;
+
+	*kernel =3D 0;
+	if(!user)
+		return 0;
+	vma =3D find_vma(current->mm, (unsigned long)user);
+	if(!vma || (unsigned long)user < vma->vm_start)
+		return -EFAULT;
+	if(!(vma->vm_flags & VM_READ))
+		return -EFAULT;
+	i =3D vma->vm_end - (unsigned long) user;
+	if(PAGE_SIZE <=3D (unsigned long) i)
+		i =3D PAGE_SIZE - 1;
+	if(!(page =3D __get_free_page(GFP_KERNEL)))
+		return -ENOMEM;
+	if(copy_from_user((void *) page, user, i)) {
+		free_page(page);
+		return -EFAULT;
+	}
+	*kernel =3D page;
+	return 0;
 }
=20
+extern asmlinkage long sys_mount(char * dev_name, char * dir_name, char * =
type,
+				unsigned long new_flags, void *data);
+
+#define SMBFS_NAME	"smbfs"
+#define NCPFS_NAME	"ncpfs"
+
 asmlinkage long
-sys32_sendmsg(int fd, struct msghdr32 *user_msg, unsigned user_flags)
+sys32_mount(char *dev_name, char *dir_name, char *type,
+	    unsigned long new_flags, u32 data)
 {
-	struct socket *sock;
-	char address[MAX_SOCK_ADDR];
-	struct iovec iov[UIO_FASTIOV];
-	unsigned char ctl[sizeof(struct cmsghdr) + 20];
-	unsigned char *ctl_buf =3D ctl;
-	struct msghdr kern_msg;
-	int err, total_len;
+	unsigned long type_page;
+	int err, is_smb, is_ncp;
=20
-	if(msghdr_from_user32_to_kern(&kern_msg, user_msg))
-		return -EFAULT;
-	if(kern_msg.msg_iovlen > UIO_MAXIOV)
-		return -EINVAL;
-	err =3D verify_iovec32(&kern_msg, iov, address, VERIFY_READ);
-	if (err < 0)
-		goto out;
-	total_len =3D err;
+	if(!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	is_smb =3D is_ncp =3D 0;
+	err =3D copy_mount_stuff_to_kernel((const void *)type, &type_page);
+	if(err)
+		return err;
+	if(type_page) {
+		is_smb =3D !strcmp((char *)type_page, SMBFS_NAME);
+		is_ncp =3D !strcmp((char *)type_page, NCPFS_NAME);
+	}
+	if(!is_smb && !is_ncp) {
+		if(type_page)
+			free_page(type_page);
+		return sys_mount(dev_name, dir_name, type, new_flags,
+				 (void *)AA(data));
+	} else {
+		unsigned long dev_page, dir_page, data_page;
=20
-	if(kern_msg.msg_controllen) {
-		err =3D cmsghdr_from_user32_to_kern(&kern_msg, ctl, sizeof(ctl));
+		err =3D copy_mount_stuff_to_kernel((const void *)dev_name,
+						 &dev_page);
 		if(err)
-			goto out_freeiov;
-		ctl_buf =3D kern_msg.msg_control;
+			goto out;
+		err =3D copy_mount_stuff_to_kernel((const void *)dir_name,
+						 &dir_page);
+		if(err)
+			goto dev_out;
+		err =3D copy_mount_stuff_to_kernel((const void *)AA(data),
+						 &data_page);
+		if(err)
+			goto dir_out;
+		if(is_ncp)
+			do_ncp_super_data_conv((void *)data_page);
+		else if(is_smb)
+			do_smb_super_data_conv((void *)data_page);
+		else
+			panic("The problem is here...");
+		err =3D do_mount((char *)dev_page, (char *)dir_page,
+				(char *)type_page, new_flags,
+				(void *)data_page);
+		if(data_page)
+			free_page(data_page);
+	dir_out:
+		if(dir_page)
+			free_page(dir_page);
+	dev_out:
+		if(dev_page)
+			free_page(dev_page);
+	out:
+		if(type_page)
+			free_page(type_page);
+		return err;
 	}
-	kern_msg.msg_flags =3D user_flags;
+}
=20
-	sock =3D sockfd_lookup(fd, &err);
-	if (sock !=3D NULL) {
-		if (sock->file->f_flags & O_NONBLOCK)
-			kern_msg.msg_flags |=3D MSG_DONTWAIT;
-		err =3D sock_sendmsg(sock, &kern_msg, total_len);
-		sockfd_put(sock);
-	}
+extern asmlinkage long sys_setreuid(uid_t ruid, uid_t euid);
=20
-	/* N.B. Use kfree here, as kern_msg.msg_controllen might change? */
-	if(ctl_buf !=3D ctl)
-		kfree(ctl_buf);
-out_freeiov:
-	if(kern_msg.msg_iov !=3D iov)
-		kfree(kern_msg.msg_iov);
-out:
-	return err;
+asmlinkage long sys32_setreuid(__kernel_uid_t32 ruid, __kernel_uid_t32 eui=
d)
+{
+	uid_t sruid, seuid;
+
+	sruid =3D (ruid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)ruid);
+	seuid =3D (euid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)euid);
+	return sys_setreuid(sruid, seuid);
 }
=20
+extern asmlinkage long sys_setresuid(uid_t ruid, uid_t euid, uid_t suid);
+
 asmlinkage long
-sys32_recvmsg(int fd, struct msghdr32 *user_msg, unsigned int user_flags)
+sys32_setresuid(__kernel_uid_t32 ruid, __kernel_uid_t32 euid,
+		__kernel_uid_t32 suid)
 {
-	struct iovec iovstack[UIO_FASTIOV];
-	struct msghdr kern_msg;
-	char addr[MAX_SOCK_ADDR];
-	struct socket *sock;
-	struct iovec *iov =3D iovstack;
-	struct sockaddr *uaddr;
-	int *uaddr_len;
-	unsigned long cmsg_ptr;
-	int err, total_len, len =3D 0;
+	uid_t sruid, seuid, ssuid;
=20
-	if(msghdr_from_user32_to_kern(&kern_msg, user_msg))
-		return -EFAULT;
-	if(kern_msg.msg_iovlen > UIO_MAXIOV)
-		return -EINVAL;
+	sruid =3D (ruid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)ruid);
+	seuid =3D (euid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)euid);
+	ssuid =3D (suid =3D (__kernel_uid_t32)-1) ? ((uid_t)-1) : ((uid_t)suid);
+	return sys_setresuid(sruid, seuid, ssuid);
+}
=20
-	uaddr =3D kern_msg.msg_name;
-	uaddr_len =3D &user_msg->msg_namelen;
-	err =3D verify_iovec32(&kern_msg, iov, addr, VERIFY_WRITE);
-	if (err < 0)
-		goto out;
-	total_len =3D err;
+extern asmlinkage long sys_setregid(gid_t rgid, gid_t egid);
=20
-	cmsg_ptr =3D (unsigned long) kern_msg.msg_control;
-	kern_msg.msg_flags =3D 0;
+asmlinkage long
+sys32_setregid(__kernel_gid_t32 rgid, __kernel_gid_t32 egid)
+{
+	gid_t srgid, segid;
=20
-	sock =3D sockfd_lookup(fd, &err);
-	if (sock !=3D NULL) {
-		struct scm_cookie scm;
+	srgid =3D (rgid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)rgid);
+	segid =3D (egid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)egid);
+	return sys_setregid(srgid, segid);
+}
=20
-		if (sock->file->f_flags & O_NONBLOCK)
-			user_flags |=3D MSG_DONTWAIT;
-		memset(&scm, 0, sizeof(scm));
-		lock_kernel();
-		err =3D sock->ops->recvmsg(sock, &kern_msg, total_len,
-					 user_flags, &scm);
-		if(err >=3D 0) {
-			len =3D err;
-			if(!kern_msg.msg_control) {
-				if(sock->passcred || scm.fp)
-					kern_msg.msg_flags |=3D MSG_CTRUNC;
-				if(scm.fp)
-					__scm_destroy(&scm);
-			} else {
-				/* If recvmsg processing itself placed some
-				 * control messages into user space, it's is
-				 * using 64-bit CMSG processing, so we need
-				 * to fix it up before we tack on more stuff.
-				 */
-				if((unsigned long) kern_msg.msg_control
-				   !=3D cmsg_ptr)
-					cmsg32_recvmsg_fixup(&kern_msg,
-							     cmsg_ptr);
-
-				/* Wheee... */
-				if(sock->passcred)
-					put_cmsg32(&kern_msg,
-						   SOL_SOCKET, SCM_CREDENTIALS,
-						   sizeof(scm.creds),
-						   &scm.creds);
-				if(scm.fp !=3D NULL)
-					scm_detach_fds32(&kern_msg, &scm);
-			}
-		}
-		unlock_kernel();
-		sockfd_put(sock);
-	}
+extern asmlinkage long sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid);
=20
-	if(uaddr !=3D NULL && err >=3D 0)
-		err =3D move_addr_to_user(addr, kern_msg.msg_namelen, uaddr,
-					uaddr_len);
-	if(cmsg_ptr !=3D 0 && err >=3D 0) {
-		unsigned long ucmsg_ptr =3D ((unsigned long)kern_msg.msg_control);
-		__kernel_size_t32 uclen =3D (__kernel_size_t32) (ucmsg_ptr
-							       - cmsg_ptr);
-		err |=3D __put_user(uclen, &user_msg->msg_controllen);
-	}
-	if(err >=3D 0)
-		err =3D __put_user(kern_msg.msg_flags, &user_msg->msg_flags);
-	if(kern_msg.msg_iov !=3D iov)
-		kfree(kern_msg.msg_iov);
-out:
-	if(err < 0)
-		return err;
-	return len;
+asmlinkage long
+sys32_setresgid(__kernel_gid_t32 rgid, __kernel_gid_t32 egid,
+		__kernel_gid_t32 sgid)
+{
+	gid_t srgid, segid, ssgid;
+
+	srgid =3D (rgid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)rgid);
+	segid =3D (egid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)egid);
+	ssgid =3D (sgid =3D (__kernel_gid_t32)-1) ? ((gid_t)-1) : ((gid_t)sgid);
+	return sys_setresgid(srgid, segid, ssgid);
 }
=20
 /* Stuff for NFS server syscalls... */
@@ -4479,14 +4290,6 @@
 	return err;
 }
=20
-extern asmlinkage ssize_t sys_sendfile(int out_fd, int in_fd, off_t *offse=
t,
-				       size_t count);
-
-asmlinkage long
-sys32_sendfile(int out_fd, int in_fd, __kernel_off_t32 *offset, s32 count)
-{
-}
-
 /* Handle adjtimex compatability. */
=20
 struct timex32 {
@@ -4560,4 +4363,4 @@
=20
 	return ret;
 }
-#endif	// NOTYET
+#endif /* NOTYET */
diff -urN linux-davidm/arch/ia64/kernel/ivt.S lia64/arch/ia64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/kernel/ivt.S	Mon Oct  1 21:08:41 2001
@@ -841,7 +841,7 @@
 	;;
 	alloc r15=3Dar.pfs,0,0,6,0	// must first in an insn group
 	;;
-	ld4 r8=3D[r14],8          // r8 =3D EAX (syscall number)
+	ld4 r8=3D[r14],8          // r8 =3D eax (syscall number)
 	mov r15"2		// last entry in system call table
 	;;
 	cmp.leu.unc p6,p7=3Dr8,r15
@@ -857,10 +857,10 @@
 	ld4 out3=3D[r14],8         // r14 =3D esi
 	adds r2=3DIA64_TASK_PTRACE_OFFSET,r13	// r2 =3D &current->ptrace
 	;;
-	ld4 out4=3D[r14]           // R15 =3D edi
+	ld4 out4=3D[r14]           // r15 =3D edi
 	movl r16=3Dia32_syscall_table
 	;;
-(p6)    shladd r16=3Dr8,3,r16     // Force ni_syscall if not valid syscall=
 number
+(p6)    shladd r16=3Dr8,3,r16     // force ni_syscall if not valid syscall=
 number
 	ld8 r2=3D[r2]		// r2 =3D current->ptrace
 	;;
 	ld8 r16=3D[r16]
diff -urN linux-davidm/arch/ia64/kernel/sigframe.h lia64/arch/ia64/kernel/s=
igframe.h
--- linux-davidm/arch/ia64/kernel/sigframe.h	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/kernel/sigframe.h	Mon Oct  1 20:44:13 2001
@@ -1,3 +1,9 @@
+struct sigscratch {
+	unsigned long scratch_unat;	/* ar.unat for the general registers saved in=
 pt */
+	unsigned long pad;
+	struct pt_regs pt;
+};
+
 struct sigframe {
 	/*
 	 * Place signal handler args where user-level unwinder can find them easi=
ly.
diff -urN linux-davidm/arch/ia64/kernel/signal.c lia64/arch/ia64/kernel/sig=
nal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/kernel/signal.c	Mon Oct  1 20:44:22 2001
@@ -2,7 +2,7 @@
  * Architecture-specific signal handling support.
  *
  * Copyright (C) 1999-2001 Hewlett-Packard Co
- * Copyright (C) 1999-2001 David Mosberger-Tang <davidm@hpl.hp.com>
+ *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * Derived from i386 and Alpha versions.
  */
@@ -39,12 +39,6 @@
 # define GET_SIGSET(k,u)	__get_user((k)->sig[0], &(u)->sig[0])
 #endif
=20
-struct sigscratch {
-	unsigned long scratch_unat;	/* ar.unat for the general registers saved in=
 pt */
-	unsigned long pad;
-	struct pt_regs pt;
-};
-
 extern long ia64_do_signal (sigset_t *, struct sigscratch *, long);	/* for=
ward decl */
=20
 long
@@ -55,6 +49,10 @@
 	/* XXX: Don't preclude handling different sized sigset_t's.  */
 	if (sigsetsize !=3D sizeof(sigset_t))
 		return -EINVAL;
+
+	if (!access_ok(VERIFY_READ, uset, sigsetsize))
+		return -EFAULT;
+
 	if (GET_SIGSET(&set, uset))
 		return -EFAULT;
=20
@@ -73,15 +71,9 @@
 	 * pre-set the correct error code here to ensure that the right values
 	 * get saved in sigcontext by ia64_do_signal.
 	 */
-#ifdef CONFIG_IA32_SUPPORT
-        if (IS_IA32_PROCESS(&scr->pt)) {
-                scr->pt.r8 =3D -EINTR;
-        } else
-#endif
-	{
-		scr->pt.r8 =3D EINTR;
-		scr->pt.r10 =3D -1;
-	}
+	scr->pt.r8 =3D EINTR;
+	scr->pt.r10 =3D -1;
+
 	while (1) {
 		current->state =3D TASK_INTERRUPTIBLE;
 		schedule();
diff -urN linux-davidm/arch/ia64/kernel/traps.c lia64/arch/ia64/kernel/trap=
s.c
--- linux-davidm/arch/ia64/kernel/traps.c	Mon Oct  1 21:15:21 2001
+++ lia64/arch/ia64/kernel/traps.c	Mon Oct  1 20:45:08 2001
@@ -544,6 +544,10 @@
 		break;
=20
 	      case 46:
+#ifdef CONFIG_IA32_SUPPORT
+		if (ia32_intercept(regs, isr) =3D 0)
+			return;
+#endif
 		printk("Unexpected IA-32 intercept trap (Trap 46)\n");
 		printk("  iip - 0x%lx, ifa - 0x%lx, isr - 0x%lx, iim - 0x%lx\n",
 		       regs->cr_iip, ifa, isr, iim);
diff -urN linux-davidm/arch/ia64/tools/print_offsets.c lia64/arch/ia64/tool=
s/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Mon Oct  1 21:15:22 2001
+++ lia64/arch/ia64/tools/print_offsets.c	Mon Oct  1 20:45:32 2001
@@ -57,9 +57,6 @@
     { "IA64_TASK_PROCESSOR_OFFSET",	offsetof (struct task_struct, processo=
r) },
     { "IA64_TASK_THREAD_OFFSET",	offsetof (struct task_struct, thread) },
     { "IA64_TASK_THREAD_KSP_OFFSET",	offsetof (struct task_struct, thread.=
ksp) },
-#ifdef CONFIG_IA32_SUPPORT
-    { "IA64_TASK_THREAD_SIGMASK_OFFSET",offsetof (struct task_struct, thre=
ad.un.sigmask) },
-#endif
 #ifdef CONFIG_PERFMON
     { "IA64_TASK_PFM_MUST_BLOCK_OFFSET",offsetof(struct task_struct, threa=
d.pfm_must_block) },
 #endif
diff -urN linux-davidm/drivers/char/drm/drmP.h lia64/drivers/char/drm/drmP.h
--- linux-davidm/drivers/char/drm/drmP.h	Mon Oct  1 21:15:22 2001
+++ lia64/drivers/char/drm/drmP.h	Mon Oct  1 20:45:54 2001
@@ -366,10 +366,10 @@
    if (len > DRM_PROC_LIMIT) { ret; *eof =3D 1; return len - offset; }
=20
 				/* Mapping helper macros */
-#define DRM_IOREMAP(map)						\
+#define DRM_IOREMAP(map, dev)						\
 	(map)->handle =3D DRM(ioremap)( (map)->offset, (map)->size, (dev) )
=20
-#define DRM_IOREMAPFREE(map)						\
+#define DRM_IOREMAPFREE(map, dev)						\
 	do {								\
 		if ( (map)->handle && (map)->size )			\
 			DRM(ioremapfree)( (map)->handle, (map)->size, (dev) );	\
diff -urN linux-davidm/drivers/char/drm/drm_vm.h lia64/drivers/char/drm/drm=
_vm.h
--- linux-davidm/drivers/char/drm/drm_vm.h	Mon Oct  1 21:15:22 2001
+++ lia64/drivers/char/drm/drm_vm.h	Mon Oct  1 21:08:00 2001
@@ -524,8 +524,8 @@
                 	 */
                 	vma->vm_ops =3D &DRM(vm_ops);
 #if defined(__ia64__)
-			if (map->type !=3D _DRM_AGP)
-				vma->vm_page_prot =3D pgprot_writecombine(vma->vm_page_prot);
+			vma->vm_page_prot +			                pgprot_writecombine(vma->vm_page_=
prot);
 #endif
 			goto mapswitch_out;
 		}
diff -urN linux-davidm/drivers/char/drm/r128_cce.c lia64/drivers/char/drm/r=
128_cce.c
--- linux-davidm/drivers/char/drm/r128_cce.c	Mon Oct  1 21:15:22 2001
+++ lia64/drivers/char/drm/r128_cce.c	Mon Oct  1 21:08:12 2001
@@ -681,7 +681,7 @@
 		/*
 		 * Free the page we grabbed for RPTR_ADDR
 		 */
-		if( dev->agp->agp_info.chipset =3D INTEL_460GX ) {
+		if( !dev_priv->is_pci && dev->agp->agp_info.chipset =3D INTEL_460GX ) {
 			unsigned long alt_rh_off  				(unsigned long) dev_priv->ring.head;
=20
diff -urN linux-davidm/drivers/char/drm/radeon_cp.c lia64/drivers/char/drm/=
radeon_cp.c
--- linux-davidm/drivers/char/drm/radeon_cp.c	Mon Oct  1 21:15:22 2001
+++ lia64/drivers/char/drm/radeon_cp.c	Mon Oct  1 21:08:59 2001
@@ -1024,7 +1024,7 @@
 		/*
 		 * Free the page we grabbed for RPTR_ADDR
 		 */
-		if( dev->agp->agp_info.chipset =3D INTEL_460GX ) {
+		if( !dev_priv->is_pci && dev->agp->agp_info.chipset =3D INTEL_460GX ) {
 			unsigned long alt_rh_off  				(unsigned long) dev_priv->ring.head;
=20
diff -urN linux-davidm/include/asm-ia64/ia32.h lia64/include/asm-ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Mon Oct  1 21:15:22 2001
+++ lia64/include/asm-ia64/ia32.h	Mon Oct  1 20:46:09 2001
@@ -12,25 +12,27 @@
  */
=20
 /* 32bit compatibility types */
-typedef unsigned int	       __kernel_size_t32;
-typedef int		       __kernel_ssize_t32;
-typedef int		       __kernel_ptrdiff_t32;
-typedef int		       __kernel_time_t32;
-typedef int		       __kernel_clock_t32;
-typedef int		       __kernel_pid_t32;
-typedef unsigned short	       __kernel_ipc_pid_t32;
-typedef unsigned short	       __kernel_uid_t32;
-typedef unsigned short	       __kernel_gid_t32;
-typedef unsigned short	       __kernel_dev_t32;
-typedef unsigned int	       __kernel_ino_t32;
-typedef unsigned short	       __kernel_mode_t32;
-typedef unsigned short	       __kernel_umode_t32;
-typedef short		       __kernel_nlink_t32;
-typedef int		       __kernel_daddr_t32;
-typedef int		       __kernel_off_t32;
-typedef unsigned int	       __kernel_caddr_t32;
-typedef long		       __kernel_loff_t32;
-typedef __kernel_fsid_t	       __kernel_fsid_t32;
+typedef unsigned int	__kernel_size_t32;
+typedef int		__kernel_ssize_t32;
+typedef int		__kernel_ptrdiff_t32;
+typedef int		__kernel_time_t32;
+typedef int		__kernel_clock_t32;
+typedef int		__kernel_pid_t32;
+typedef unsigned short	__kernel_ipc_pid_t32;
+typedef unsigned short	__kernel_uid_t32;
+typedef unsigned int	__kernel_uid32_t32;
+typedef unsigned short	__kernel_gid_t32;
+typedef unsigned int	__kernel_gid32_t32;
+typedef unsigned short	__kernel_dev_t32;
+typedef unsigned int	__kernel_ino_t32;
+typedef unsigned short	__kernel_mode_t32;
+typedef unsigned short	__kernel_umode_t32;
+typedef short		__kernel_nlink_t32;
+typedef int		__kernel_daddr_t32;
+typedef int		__kernel_off_t32;
+typedef unsigned int	__kernel_caddr_t32;
+typedef long		__kernel_loff_t32;
+typedef __kernel_fsid_t	__kernel_fsid_t32;
=20
 #define IA32_PAGE_SHIFT		12	/* 4KB pages */
 #define IA32_PAGE_SIZE		(1UL << IA32_PAGE_SHIFT)
@@ -39,6 +41,11 @@
 #define IA32_CLOCKS_PER_SEC	100	/* Cast in stone for IA32 Linux */
 #define IA32_TICK(tick)		((unsigned long long)(tick) * IA32_CLOCKS_PER_SEC=
 / CLOCKS_PER_SEC)
=20
+struct timespec32 {
+	int	tv_sec;
+	int	tv_nsec;
+};
+
 /* fcntl.h */
 struct flock32 {
        short l_type;
@@ -265,6 +272,19 @@
 	} _sifields;
 } siginfo_t32;
=20
+struct linux32_dirent {
+	u32	d_ino;
+	u32	d_off;
+	u16	d_reclen;
+	char	d_name[256];
+};
+
+struct old_linux32_dirent {
+	u32	d_ino;
+	u32	d_offset;
+	u16	d_namlen;
+	char	d_name[1];
+};
=20
 /*
  * IA-32 ELF specific definitions for IA-64.
@@ -358,6 +378,10 @@
 #define _TSS(n) ((((unsigned long) n)<<4)+(FIRST_TSS_ENTRY<<3))
 #define _LDT(n) ((((unsigned long) n)<<4)+(FIRST_LDT_ENTRY<<3))
=20
+#define IA32_SEGSEL_RPL		(0x3 << 0)
+#define IA32_SEGSEL_TI		(0x1 << 2)
+#define IA32_SEGSEL_INDEX_SHIFT	3
+
 #define IA32_SEG_BASE		16
 #define IA32_SEG_TYPE		40
 #define IA32_SEG_SYS		44
@@ -457,7 +481,9 @@
 extern void ia32_init_addr_space (struct pt_regs *regs);
 extern int ia32_setup_arg_pages (struct linux_binprm *bprm);
 extern int ia32_exception (struct pt_regs *regs, unsigned long isr);
+extern int ia32_intercept (struct pt_regs *regs, unsigned long isr);
 extern unsigned long ia32_do_mmap (struct file *, unsigned long, unsigned =
long, int, int, loff_t);
+extern void ia32_load_segment_descriptors (struct task_struct *task);
=20
 #endif /* !CONFIG_IA32_SUPPORT */
=20
diff -urN linux-davidm/include/asm-ia64/mca.h lia64/include/asm-ia64/mca.h
--- linux-davidm/include/asm-ia64/mca.h	Mon Oct  1 21:15:22 2001
+++ lia64/include/asm-ia64/mca.h	Mon Oct  1 20:46:23 2001
@@ -136,7 +136,7 @@
=20
 #undef	MCA_TEST
=20
-#define IA64_MCA_DEBUG_INFO 1
+#define IA64_MCA_DEBUG_INFO 0
=20
 #if defined(IA64_MCA_DEBUG_INFO)
 # define IA64_MCA_DEBUG	printk
diff -urN linux-davidm/include/asm-ia64/offsets.h lia64/include/asm-ia64/of=
fsets.h
--- linux-davidm/include/asm-ia64/offsets.h	Mon Oct  1 21:15:22 2001
+++ lia64/include/asm-ia64/offsets.h	Mon Oct  1 20:46:32 2001
@@ -22,8 +22,7 @@
 #define IA64_TASK_PROCESSOR_OFFSET	100	/* 0x64 */
 #define IA64_TASK_THREAD_OFFSET		1472	/* 0x5c0 */
 #define IA64_TASK_THREAD_KSP_OFFSET	1472	/* 0x5c0 */
-#define IA64_TASK_THREAD_SIGMASK_OFFSET	1584	/* 0x630 */
-#define IA64_TASK_PFM_MUST_BLOCK_OFFSET	2104	/* 0x838 */
+#define IA64_TASK_PFM_MUST_BLOCK_OFFSET	2096	/* 0x830 */
 #define IA64_TASK_PID_OFFSET		220	/* 0xdc */
 #define IA64_TASK_MM_OFFSET		88	/* 0x58 */
 #define IA64_PT_REGS_CR_IPSR_OFFSET	0	/* 0x0 */
diff -urN linux-davidm/include/asm-ia64/processor.h lia64/include/asm-ia64/=
processor.h
--- linux-davidm/include/asm-ia64/processor.h	Mon Oct  1 21:15:22 2001
+++ lia64/include/asm-ia64/processor.h	Mon Oct  1 20:46:44 2001
@@ -333,9 +333,6 @@
 	__u64 map_base;			/* base address for get_unmapped_area() */
 	__u64 task_size;		/* limit for task size */
 	struct siginfo *siginfo;	/* current siginfo struct for ptrace() */
-#if JITTER_BUG
-	__u64 mem;
-#endif
=20
 #ifdef CONFIG_IA32_SUPPORT
 	__u64 eflag;			/* IA32 EFLAGS reg */
@@ -347,10 +344,7 @@
 	__u64 ssd;			/* IA32 stack selector descriptor */
 	__u64 tssd;			/* IA32 TSS descriptor */
 	__u64 old_iob;			/* old IOBase value */
-	union {
-		__u64 sigmask;		/* aligned mask for sigsuspend scall */
-	} un;
-# define INIT_THREAD_IA32	0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0, {0},
+# define INIT_THREAD_IA32	0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, 0,
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */
@@ -820,22 +814,9 @@
=20
 #define THREAD_SIZE	IA64_STK_OFFSET
 /* NOTE: The task struct and the stacks are allocated together.  */
-#if JITTER_BUG
-# define alloc_task_struct()									 \
-({												 \
-	unsigned long color, mem =3D __get_free_pages(GFP_KERNEL, IA64_TASK_STRUC=
T_LOG_NUM_PAGES); \
-	struct task_struct *p;									 \
-	color =3D ia64_fetch_and_add(1, &task_color) % NUM_TASK_COLORS;				 \
-	p =3D (struct task_struct *) (mem + color*MAX_JITTER_SIZE/(NUM_TASK_COLOR=
S - 1));		 \
-	p->thread.mem =3D mem;									 \
-	p;											 \
-})
-# define free_task_struct(p)	free_pages((p)->thread.mem, IA64_TASK_STRUCT_=
LOG_NUM_PAGES)
-#else
-# define alloc_task_struct() \
+#define alloc_task_struct() \
         ((struct task_struct *) __get_free_pages(GFP_KERNEL, IA64_TASK_STR=
UCT_LOG_NUM_PAGES))
-# define free_task_struct(p)	free_pages((unsigned long)(p), IA64_TASK_STRU=
CT_LOG_NUM_PAGES)
-#endif
+#define free_task_struct(p)	free_pages((unsigned long)(p), IA64_TASK_STRUC=
T_LOG_NUM_PAGES)
 #define get_task_struct(tsk)	atomic_inc(&virt_to_page(tsk)->count)
=20
 #define init_task	(init_task_union.task)

