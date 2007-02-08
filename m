From: Horms <horms@verge.net.au>
Date: Thu, 08 Feb 2007 01:42:22 +0000
Subject: Re: [PATCH 1/2] [IA64] physical mode SAL calls
Message-Id: <20070208014219.GG10404@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070207061904.GA29959@verge.net.au>
In-Reply-To: <20070207061904.GA29959@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Wed, Feb 07, 2007 at 03:19:06PM +0900, Horms wrote:
> Hi,
>=20
> I am resending this patch, which is a consolidated version of 3 or 4
> patches sent late last year. It includes a few minor fixes, and
> I have removed the portion which caused the pal code not to be mapped.
>=20
> I have been using this code successfully for a number of months on
> my Tiger box.

This is an update on the version I sent yesterday. I miss-diffed, sorry.

  * Remove arch/ia64/kernel/machine_kexec.c chunk as this
      is part of a separate change that alters the
      arguments that are passed to kexec's relocate_kernel()
  * Add missing arch/ia64/kernel/sal.c chunk

--=20
Simon Horman (Horms)
  horms@verge.net.au
  http://verge.net.au/~horms/

[IA64] physical mode SAL calls

Currently the EFI code will fall back to making real mode calls if the call
to map the EFI code fails. Unfortunately this only takes into account EFI
calls, but if EFI calls are made in physical mode SAL calls also need to be
made in physical mode. On a Tiger2 at least, forcing EFI to stay in
physical mode caues the boot to oops in a SAL call.

This patch changes things around by adding code to allow SAL calls to be
made in physical mode. I then makes this the path that is allways followed
- that is SAL calls are always physical with this patch.

This patch fixes things up so that physical SAL calls are made when
physical EFI calls are in operation, and virtual SAL calls when virtual EFI
calls are in poration.=20

Curiously on my Tiger2, it seems that having SAL always physical, regadless
of if EFI is physical or virtual, actually works.

Signed-Off-By: Simon Horman <horms@verge.net.au>


 arch/ia64/kernel/Makefile   |    2=20
 arch/ia64/kernel/efi.c      |    1=20
 arch/ia64/kernel/sal.c      |   24 +++++++++++
 arch/ia64/kernel/sal_stub.S |   92 +++++++++++++++++++++++++++++++++++++++=
++++
 include/asm-ia64/sal.h      |   56 +++++++++++++++++---------
 include/linux/efi.h         |    1=20
 6 files changed, 157 insertions(+), 19 deletions(-)

Index: linux-2.6/include/asm-ia64/sal.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/include/asm-ia64/sal.h	2007-02-0=
7 13:25:17.000000000 +0900
+++ linux-2.6/include/asm-ia64/sal.h	2007-02-07 13:26:26.000000000 +0900
@@ -45,9 +45,45 @@
=20
 extern spinlock_t sal_lock;
=20
+struct ia64_sal_retval {
+	/*
+	 * A zero status value indicates call completed without error.
+	 * A negative status value indicates reason of call failure.
+	 * A positive status value indicates success but an
+	 * informational value should be printed (e.g., "reboot for
+	 * change to take effect").
+	 */
+	s64 status;
+	u64 v0;
+	u64 v1;
+	u64 v2;
+};
+
+typedef struct ia64_sal_retval (*ia64_sal_handler) (u64, ...);
+
 /* SAL spec _requires_ eight args for each call. */
-#define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)	\
-	result =3D (*ia64_sal)(a0,a1,a2,a3,a4,a5,a6,a7)
+struct ia64_sal_retval sal_call_phys(ia64_sal_handler ia64_sal,
+				     unsigned long a0, unsigned long a1,
+				     unsigned long a2, unsigned long a3,
+				     unsigned long a4, unsigned long a5,
+				     unsigned long a6, unsigned long a7);
+struct ia64_sal_retval __sal_call_phys(ia64_sal_handler ia64_sal,
+				       unsigned long a0, unsigned long a1,
+				       unsigned long a2, unsigned long a3,
+				       unsigned long a4, unsigned long a5,
+				       unsigned long a6, unsigned long a7);
+
+#define __SAL_CALL(result,a0,a1,a2,a3,a4,a5,a6,a7)			\
+	result =3D efi.mapped ? 						\
+		 (*ia64_sal)((unsigned long)a0, (unsigned long)a1,	\
+		 	     (unsigned long)a2, (unsigned long)a3,	\
+		     	     (unsigned long)a4, (unsigned long)a5,	\
+		     	     (unsigned long)a6, (unsigned long)a7) :	\
+		 sal_call_phys(ia64_sal,				\
+		             (unsigned long)a0, (unsigned long)a1,	\
+			     (unsigned long)a2, (unsigned long)a3,	\
+			     (unsigned long)a4, (unsigned long)a5,	\
+			     (unsigned long)a6, (unsigned long)a7);
=20
 # define SAL_CALL(result,args...) do {				\
 	unsigned long __ia64_sc_flags;				\
@@ -95,22 +131,6 @@
=20
 #define SAL_UPDATE_PAL			0x01000020
=20
-struct ia64_sal_retval {
-	/*
-	 * A zero status value indicates call completed without error.
-	 * A negative status value indicates reason of call failure.
-	 * A positive status value indicates success but an
-	 * informational value should be printed (e.g., "reboot for
-	 * change to take effect").
-	 */
-	s64 status;
-	u64 v0;
-	u64 v1;
-	u64 v2;
-};
-
-typedef struct ia64_sal_retval (*ia64_sal_handler) (u64, ...);
-
 enum {
 	SAL_FREQ_BASE_PLATFORM =3D 0,
 	SAL_FREQ_BASE_INTERVAL_TIMER =3D 1,
Index: linux-2.6/arch/ia64/kernel/sal_stub.S
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6/arch/ia64/kernel/sal_stub.S	2007-02-07 13:26:26.000000000 +09=
00
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
+GLOBAL_ENTRY(__sal_call_phys)
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
+END(__sal_call_phys)
+
Index: linux-2.6/arch/ia64/kernel/Makefile
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/Makefile	2007-0=
2-07 13:25:17.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/Makefile	2007-02-07 13:26:26.000000000 +0900
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
Index: linux-2.6/include/linux/efi.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/include/linux/efi.h	2007-02-07 1=
3:25:16.000000000 +0900
+++ linux-2.6/include/linux/efi.h	2007-02-07 13:26:26.000000000 +0900
@@ -265,6 +265,7 @@
 	efi_get_next_high_mono_count_t *get_next_high_mono_count;
 	efi_reset_system_t *reset_system;
 	efi_set_virtual_address_map_t *set_virtual_address_map;
+	unsigned mapped;
 } efi;
=20
 static inline int
Index: linux-2.6/arch/ia64/kernel/efi.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-02-0=
7 13:25:16.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-02-07 13:27:54.000000000 +0900
@@ -601,6 +601,7 @@
 	efi.set_variable =3D virt_set_variable;
 	efi.get_next_high_mono_count =3D virt_get_next_high_mono_count;
 	efi.reset_system =3D virt_reset_system;
+	efi.mapped =3D 1;
 }
=20
 /*
Index: linux-2.6/arch/ia64/kernel/sal.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D--- linux-2.6.orig/arch/ia64/kernel/sal.c	2007-02-0=
7 13:25:16.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/sal.c	2007-02-07 13:27:54.000000000 +0900
@@ -373,3 +373,27 @@ ia64_sal_oemcall_reentrant(struct ia64_sal_retval *isr=
vp, u64 oemfunc,
 	return 0;
 }
 EXPORT_SYMBOL(ia64_sal_oemcall_reentrant);
+
+/* In practice this seems to be needed for at least SAL_GET_STATE_INFO
+ * in Xen. Tested on a Tiger 2 box */
+struct ia64_sal_retval sal_call_phys(ia64_sal_handler ia64_sal,
+				    unsigned long a0, unsigned long a1,
+				    unsigned long a2, unsigned long a3,
+				    unsigned long a4, unsigned long a5,
+				    unsigned long a6, unsigned long a7)
+{
+       switch (a0) {
+       case SAL_GET_STATE_INFO:
+	       a3 =3D __pa(a3);
+	       break;
+       case SAL_MC_SET_PARAMS:
+	       if (a2 =3D 0x2) /* It is a memory address */
+		       a3 =3D __pa(a3);
+	       break;
+       case SAL_UPDATE_PAL:
+	       a1 =3D __pa(a1);
+	       a2 =3D __pa(a2);
+	       break;
+       }
+       return __sal_call_phys(ia64_sal, a0, a1, a2, a3, a4, a5, a6, a7);
+}
