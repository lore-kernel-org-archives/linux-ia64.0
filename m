From: Horms <horms@verge.net.au>
Date: Mon, 23 Oct 2006 08:48:42 +0000
Subject: [patch 2/5] physical mode SAL calls
Message-Id: <20061023090334.254998770@tabatha.lab.ultramonkey.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Currently the EFI code will fall back to making real mode calls
if the call to map the EFI code fails. Unfortunately this only
takes into account EFI calls, but if EFI calls are made in physical
mode SAL calls also need to be made in physical mode. On a Tiger2 at least,
forcing EFI to stay in physical mode caues the boot to oops in a SAL call.

This patch changes things around by adding code to allow SAL calls to
be made in physical mode. I then makes this the path that is allways
followed - that is SAL calls are always physical with this patch.

A small patch will follow that will make physical SAL calls when
physical EFI calls are in operation, and virtual SAL calls when
virtual EFI calls are in poration. However, again a Tiger2, it seems
that having SAL always physical does actually work. So although this
patch seems like it should break stuff, it doesn't.

Signed-Off-By: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/Makefile   |    2=20
 arch/ia64/kernel/sal_stub.S |   92 +++++++++++++++++++++++++++++++++++++++=
++++
 include/asm-ia64/sal.h      |    4 +
 3 files changed, 96 insertions(+), 2 deletions(-)

Index: kexec-ia64-2.6/ia64/kernel/sal_stub.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ kexec-ia64-2.6/arch/ia64/kernel/sal_stub.S	2006-10-05 13:22:14.00000000=
0 +0900
@@ -0,0 +1,92 @@
+/*
+ * SAL call stub.
+ *
+ * Copyright (C) 2006 Horms <horms@verge.net.au>
+ *
+ * Based heavily on arch/ia64/kernel/efi_stub.S
+ *
+ * Copyright (C) 1999-2001 Hewlett-Packard Co
+ *	David Mosberger <davidm@hpl.hp.com>
+ *
+ * This stub allows us to make PAL calls in physical mode with interrupts
+ * turned off. This is needed to make PAL calls if EFI has not been
+ * maped using SetVirtualMap() for one reason or another
+ */
+
+/*
+ * PSR settings as per SAL spec (Chapter 8 in the "IA-64 System
+ * Abstraction Layer Specification", revision 2.6e).  Note that
+ * psr.dfl and psr.dfh MUST be cleared, despite what this manual says.
+ * Otherwise, SAL dies whenever it's trying to do an IA-32 BIOS call
+ * (the br.ia instruction fails unless psr.dfl and psr.dfh are
+ * cleared).  Fortunately, SAL promises not to touch the floating
+ * point regs, so at least we don't have to save f2-f127.
+ */
+#define PSR_BITS_TO_CLEAR						\
+	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT | IA64_PSR_RT |		\
+	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	\
+	 IA64_PSR_DFL | IA64_PSR_DFH)
+
+#define PSR_BITS_TO_SET							\
+	(IA64_PSR_BN)
+
+#include <asm/processor.h>
+#include <asm/asmmacro.h>
+
+/*
+ * Inputs:
+ *	in0 =3D address of function descriptor of EFI routine to call
+ *	in1..in8 =3D arguments to routine
+ *
+ * Outputs:
+ *	r8..r11 =3D return
+ */
+
+GLOBAL_ENTRY(sal_call_phys)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(9)
+	alloc loc1=3Dar.pfs,9,8,8,0
+	ld8 r2=3D[in0],8			// load SAL function's entry point
+	mov loc0=3Drp			// save return pointer
+	.body
+	;;
+	mov loc2=3Dgp			// save global pointer
+	mov loc4=3Dar.rsc			// save RSE configuration
+	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
+	;;
+	dep r2=3D0,r2,61,3		// __pa
+	ld8 gp=3D[in0]			// load EFI function's global pointer
+	movl r16=3DPSR_BITS_TO_CLEAR
+	mov loc3=3Dpsr
+	movl r17=3DPSR_BITS_TO_SET
+	;;
+	or loc3=3Dloc3,r17
+	mov b6=3Dr2
+	;;
+	dep gp=3D0,gp,61,3		// __pa
+	andcm r16=3Dloc3,r16
+	br.call.sptk.many rp=3Dia64_switch_mode_phys
+.ret0:	mov out0=3Din1
+	mov out1=3Din2
+	mov out2=3Din3
+	mov out3=3Din4
+	mov out4=3Din5
+	mov out5=3Din6
+	mov out6=3Din7
+	mov out7=3Din8
+	mov loc5=3Dr19
+	mov loc6=3Dr20
+	;;
+	br.call.sptk.many rp=B6		// call the SAL function
+	;;
+	mov ar.rsc=3D0                    // put RSE in enforced lazy, LE mode
+	mov r16=3Dloc3
+	mov r19=3Dloc5
+	mov r20=3Dloc6
+.ret1:	br.call.sptk.many rp=3Dia64_switch_mode_virt // return to virtual 	=
;;
+.ret2:	mov ar.rsc=3Dloc4                 // restore RSE configuration
+	mov ar.pfs =3D loc1		// restore register stack
+	mov rp=3Dloc0			// retore return pointer
+	mov gp=3Dloc2			// retore global pointer
+	br.ret.sptk.many rp
+END(sal_call_phys)
+
Index: kexec-ia64-2.6/arch/ia64/kernel/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- kexec-ia64-2.6.orig/arch/ia64/kernel/Makefile	2=
006-10-05 13:22:05.000000000 +0900
+++ kexec-ia64-2.6/arch/ia64/kernel/Makefile	2006-10-05 13:22:14.000000000 =
+0900
@@ -7,7 +7,7 @@
 obj-y :=3D acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o=
 irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o =
sal.o		\
 	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unalign=
ed.o \
-	 unwind.o mca.o mca_asm.o topology.o
+	 unwind.o mca.o mca_asm.o topology.o sal_stub.o
=20
 obj-$(CONFIG_IA64_BRL_EMU)	+=3D brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+=3D acpi-ext.o
Index: kexec-ia64-2.6/include/asm-ia64/sal.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- kexec-ia64-2.6.orig/include/asm-ia64/sal.h	2006=
-10-05 13:22:14.000000000 +0900
+++ kexec-ia64-2.6/include/asm-ia64/sal.h	2006-10-05 13:26:42.000000000 +09=
00
@@ -62,8 +62,10 @@
 typedef struct ia64_sal_retval (*ia64_sal_handler) (u64, ...);
=20
 /* SAL spec _requires_ eight args for each call. */
+struct ia64_sal_retval sal_call_phys(ia64_sal_handler ia64_sal, ...);
+
 #define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
-	result =3D (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7)
+	result =3D sal_call_phys(ia64_sal,a0,a1,a2,a3,a4,a5,a6,a7);
=20
 # define SAL_CALL(result,args...) do {				\
 	unsigned long __ia64_sc_flags;				\

--

--=20
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

