From: Jack Steiner <steiner@sgi.com>
Date: Sun, 31 Aug 2003 13:31:53 +0000
Subject: 4 SGI patches - non-identity mapped kernel + misc fixes
Message-Id: <marc-linux-ia64-106233674100576@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Bjorn -=20

Attached are 4 patches for the SGI platform. These are against the latest
2.4 bitkeeper tree.

The patches:

	linux/arch/ia64/config.in
		- delete some remnents of support for the SGI SN1 platform
		- add config option for SN2.=20

	linux_base/arch/ia64/kernel/Makefile
		- fix compile error (SN2 needs iosapic.o)

	linux/arch/ia64/acpi.c
		- update acpi.c to recognize the SN2 platform

	linux/arch/ia64/kernel/efi_stub.S
	linux/arch/ia64/kernel/head.S
	linux/arch/ia64/kernel/pal.S
		- backport of 2.6 "ia64_switch_mode" changes for non-identity
	  	  mapped kernels


---------------------------------------------------------------------------=
-----------


 linux/arch/ia64/config.in         |   12 +-----
 linux/arch/ia64/kernel/Makefile   |    1=20
 linux/arch/ia64/kernel/acpi.c     |    5 +-
 linux/arch/ia64/kernel/efi_stub.S |    4 +-
 linux/arch/ia64/kernel/head.S     |   74 +++++++++++++++++++++++++++++++--=
-----
 linux/arch/ia64/kernel/pal.S      |   10 ++---
 6 files changed, 76 insertions(+), 30 deletions(-)





diff -Naur linux_base/arch/ia64/config.in linux/arch/ia64/config.in
--- linux_base/arch/ia64/config.in	Thu Aug 28 11:56:41 2003
+++ linux/arch/ia64/config.in	Fri Aug 29 08:26:14 2003
@@ -35,7 +35,6 @@
 	 DIG-compliant		CONFIG_IA64_DIG			\
 	 HP-simulator		CONFIG_IA64_HP_SIM		\
 	 HP-zx1			CONFIG_IA64_HP_ZX1		\
-	 SGI-SN1		CONFIG_IA64_SGI_SN1		\
 	 SGI-SN2		CONFIG_IA64_SGI_SN2" generic
=20
 if [ "$CONFIG_ITANIUM" =3D "y" ]; then
@@ -54,11 +53,7 @@
 if [ "$CONFIG_ITANIUM" =3D "y" ]; then
 	define_bool CONFIG_IA64_BRL_EMU y
 	bool '  Enable Itanium B-step specific code' CONFIG_ITANIUM_BSTEP_SPECIFIC
-	if [ "$CONFIG_IA64_SGI_SN1" =3D "y" ]; then
-	  define_int CONFIG_IA64_L1_CACHE_SHIFT 7 # align cache-sensitive data to=
 128 bytes
-	else
-	  define_int CONFIG_IA64_L1_CACHE_SHIFT 6 # align cache-sensitive data to=
 64 bytes
-	fi
+	define_int CONFIG_IA64_L1_CACHE_SHIFT 6 # align cache-sensitive data to 6=
4 bytes
 fi
=20
 if [ "$CONFIG_MCKINLEY" =3D "y" ]; then
@@ -74,13 +69,12 @@
 	define_bool CONFIG_PM y
 fi
=20
-if [ "$CONFIG_IA64_SGI_SN1" =3D "y" -o "$CONFIG_IA64_SGI_SN2" =3D "y" ]; t=
hen
+if [ "$CONFIG_IA64_SGI_SN2" =3D "y" ]; then
 	define_bool CONFIG_IA64_SGI_SN y
 	bool '  Enable extra debugging code' CONFIG_IA64_SGI_SN_DEBUG
 	bool '  Enable SGI Medusa Simulator Support' CONFIG_IA64_SGI_SN_SIM
-	bool '  Enable autotest (llsc). Option to run cache test instead of booti=
ng' \
-			CONFIG_IA64_SGI_AUTOTEST
 	bool '  Enable protocol mode for the L1 console' CONFIG_SERIAL_SGI_L1_PRO=
TOCOL
+	define_bool CONFIG_HWGFS_FS y
 	define_bool CONFIG_DISCONTIGMEM y
 	define_bool CONFIG_IA64_MCA y
 	define_bool CONFIG_NUMA y
diff -Naur linux_base/arch/ia64/kernel/Makefile linux/arch/ia64/kernel/Make=
file
--- linux_base/arch/ia64/kernel/Makefile	Thu Aug 28 11:56:41 2003
+++ linux/arch/ia64/kernel/Makefile	Thu Aug 28 12:15:00 2003
@@ -17,6 +17,7 @@
 	 machvec.o pal.o process.o perfmon.o ptrace.o sal.o salinfo.o semaphore.o=
 setup.o	 \
 	 signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
 obj-$(CONFIG_IA64_GENERIC) +=3D iosapic.o
+obj-$(CONFIG_IA64_SGI_SN2) +=3D iosapic.o
 obj-$(CONFIG_IA64_HP_ZX1) +=3D iosapic.o
 obj-$(CONFIG_IA64_DIG) +=3D iosapic.o
 obj-$(CONFIG_IA64_PALINFO) +=3D palinfo.o
diff -Naur linux_base/arch/ia64/kernel/acpi.c linux/arch/ia64/kernel/acpi.c
--- linux_base/arch/ia64/kernel/acpi.c	Thu Aug 28 11:56:41 2003
+++ linux/arch/ia64/kernel/acpi.c	Thu Aug 28 12:15:00 2003
@@ -98,6 +98,9 @@
 	if (!strcmp(hdr->oem_id, "HP")) {
 		return "hpzx1";
 	}
+	else if (!strcmp(hdr->oem_id, "SGI")) {
+		return "sn2";
+	}
=20
 	return "dig";
 #else
@@ -105,8 +108,6 @@
 	return "hpsim";
 # elif defined (CONFIG_IA64_HP_ZX1)
 	return "hpzx1";
-# elif defined (CONFIG_IA64_SGI_SN1)
-	return "sn1";
 # elif defined (CONFIG_IA64_SGI_SN2)
 	return "sn2";
 # elif defined (CONFIG_IA64_DIG)
diff -Naur linux_base/arch/ia64/kernel/efi_stub.S linux/arch/ia64/kernel/ef=
i_stub.S
--- linux_base/arch/ia64/kernel/efi_stub.S	Thu Aug 28 11:56:41 2003
+++ linux/arch/ia64/kernel/efi_stub.S	Thu Aug 28 20:17:38 2003
@@ -62,7 +62,7 @@
 	mov b6=3Dr2
 	;;
 	andcm r16=3Dloc3,r16		// get psr with IT, DT, and RT bits cleared
-	br.call.sptk.many rp=3Dia64_switch_mode
+	br.call.sptk.many rp=3Dia64_switch_mode_phys
 .ret0:	mov out4=3Din5
 	mov out0=3Din1
 	mov out1=3Din2
@@ -73,7 +73,7 @@
 	br.call.sptk.many rp=B6		// call the EFI function
 .ret1:	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3
-	br.call.sptk.many rp=3Dia64_switch_mode // return to virtual mode
+	br.call.sptk.many rp=3Dia64_switch_mode_virt // return to virtual mode
 .ret2:	mov ar.rsc=3Dloc4			// restore RSE configuration
 	mov ar.pfs=3Dloc1
 	mov rp=3Dloc0
diff -Naur linux_base/arch/ia64/kernel/head.S linux/arch/ia64/kernel/head.S
--- linux_base/arch/ia64/kernel/head.S	Thu Aug 28 11:56:41 2003
+++ linux/arch/ia64/kernel/head.S	Thu Aug 28 20:16:41 2003
@@ -725,7 +725,7 @@
  *
  * Note: RSE must already be in enforced lazy mode
  */
-GLOBAL_ENTRY(ia64_switch_mode)
+GLOBAL_ENTRY(ia64_switch_mode_phys)
  {
 	alloc r2=3Dar.pfs,0,0,0,0
 	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
@@ -735,36 +735,86 @@
  {
 	flushrs				// must be first insn in group
 	srlz.i
-	shr.u r19=3Dr15,61		// r19 <- top 3 bits of current IP
  }
 	;;
 	mov cr.ipsr=3Dr16			// set new PSR
-	add r3=1F-ia64_switch_mode,r15
-	xor r15=3D0x7,r19			// flip the region bits
+	add r3=1F-ia64_switch_mode_phys,r15
=20
 	mov r17=3Dar.bsp
 	mov r14=3Drp			// get return address into a general register
+	;;
=20
-	// switch RSE backing store:
+	// going to physical mode, use tpa to translate virt->phys
+	tpa r17=3Dr17
+	tpa r3=3Dr3
+	tpa sp=3Dsp
+	tpa r14=3Dr14
 	;;
-	dep r17=3Dr15,r17,61,3		// make ar.bsp physical or virtual
+
 	mov r18=3Dar.rnat			// save ar.rnat
-	;;
 	mov ar.bspstore=3Dr17		// this steps on ar.rnat
-	dep r3=3Dr15,r3,61,3		// make rfi return address physical or virtual
-	;;
 	mov cr.iip=3Dr3
 	mov cr.ifs=3Dr0
-	dep sp=3Dr15,sp,61,3		// make stack pointer physical or virtual
 	;;
 	mov ar.rnat=3Dr18			// restore ar.rnat
-	dep r14=3Dr15,r14,61,3		// make function return address physical or virtu=
al
 	rfi				// must be last insn in group
 	;;
 1:	mov rp=3Dr14
 	br.ret.sptk.many rp
-END(ia64_switch_mode)
+END(ia64_switch_mode_phys)
=20
+/*
+ * Switch execution mode from physical to virtual
+ *
+ * Inputs:
+ *	r16 =3D new psr to establish
+ *
+ * Note: RSE must already be in enforced lazy mode
+ */
+GLOBAL_ENTRY(ia64_switch_mode_virt)
+ {
+	alloc r2=3Dar.pfs,0,0,0,0
+	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
+	mov r15=3Dip
+ }
+	;;
+ {
+	flushrs				// must be first insn in group
+	srlz.i
+ }
+	;;
+	mov cr.ipsr=3Dr16			// set new PSR
+	add r3=1F-ia64_switch_mode_virt,r15
+
+	mov r17=3Dar.bsp
+	mov r14=3Drp			// get return address into a general register
+	;;
+
+	// going to virtual
+	//   - for code addresses, set upper bits of addr to KERNEL_START
+	//   - for stack addresses, set upper 3 bits to 0xe.... Dont change any o=
f the
+	//     lower bits since we want it to stay identity mapped
+	movl r18=3DKERNEL_START
+	dep r3=3D0,r3,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
+	dep r14=3D0,r14,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
+	dep r17=3D-1,r17,61,3
+	dep sp=3D-1,sp,61,3
+	;;
+	or r3=3Dr3,r18
+	or r14=3Dr14,r18
+	;;
+
+	mov r18=3Dar.rnat			// save ar.rnat
+	mov ar.bspstore=3Dr17		// this steps on ar.rnat
+	mov cr.iip=3Dr3
+	mov cr.ifs=3Dr0
+	;;
+	mov ar.rnat=3Dr18			// restore ar.rnat
+	rfi				// must be last insn in group
+	;;
+1:	mov rp=3Dr14
+	br.ret.sptk.many rp
+END(ia64_switch_mode_virt)
 #ifdef CONFIG_IA64_BRL_EMU
=20
 /*
diff -Naur linux_base/arch/ia64/kernel/pal.S linux/arch/ia64/kernel/pal.S
--- linux_base/arch/ia64/kernel/pal.S	Thu Aug 28 11:56:41 2003
+++ linux/arch/ia64/kernel/pal.S	Fri Aug 29 10:58:52 2003
@@ -164,7 +164,7 @@
 	;;
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
-	dep.z r8=3Dr8,0,61		// convert rp to physical
+	tpa r8=3Dr8			// convert rp to physical
 	;;
 	mov b7 =3D loc2			// install target to branch reg
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
@@ -174,13 +174,13 @@
 	or loc3=3Dloc3,r17		// add in psr the bits to set
 	;;
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
-	br.call.sptk.many rp=3Dia64_switch_mode
+	br.call.sptk.many rp=3Dia64_switch_mode_phys
 .ret1:	mov rp =3D r8			// install return address (physical)
 	br.cond.sptk.many b7
 1:
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
-	br.call.sptk.many rp=3Dia64_switch_mode // return to virtual mode
+	br.call.sptk.many rp=3Dia64_switch_mode_virt // return to virtual mode
 .ret2:
 	mov psr.l =3D loc3		// restore init PSR
=20
@@ -228,13 +228,13 @@
 	mov b7 =3D loc2			// install target to branch reg
 	;;
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
-	br.call.sptk.many rp=3Dia64_switch_mode
+	br.call.sptk.many rp=3Dia64_switch_mode_phys
 .ret6:
 	br.call.sptk.many rp=B7		// now make the call
 .ret7:
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
-	br.call.sptk.many rp=3Dia64_switch_mode	// return to virtual mode
+	br.call.sptk.many rp=3Dia64_switch_mode_virt	// return to virtual mode
=20
 .ret8:	mov psr.l  =3D loc3		// restore init PSR
 	mov ar.pfs =3D loc1
--=20
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


