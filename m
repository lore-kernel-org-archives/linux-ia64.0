From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Tue, 29 Jun 2004 15:09:00 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406291507.i5TF7JY12544@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Friday, June 25, 2004 10:55 PM
>  >> True, but it's really ugly to add more special cases.  Wouldn't it be
>  >> better to explicitly pass the sp/bsp that need to be restored?
>  >> (Caveat: can't use the normal calling conventions there; perhaps r17
>  >> and r18 could be used?)
>
>  Ken> Yeah, but we have to update all the call sites, current efi_call_ph=
ys
>  Ken> and two other PAL static/stacked calls.
>
> True, but I think there are only 3 call-sites.  If it turns out to be
> _really_ ugly we can reonsider, but I think it might be a better
> choice in the long run.


How does this patch look?  It is a bit big. But what it does is really
simple: change 3 call sites to save/restore virtual address of sp and
ar.bsp/ar.bspstore.


=3D=3D=3D arch/ia64/kernel/efi_stub.S 1.5 vs edited =3D=3D--- 1.5/arch/ia64=
/kernel/efi_stub.S	Thu May 15 04:45:02 2003
+++ edited/arch/ia64/kernel/efi_stub.S	Mon Jun 28 21:55:00 2004
@@ -44,7 +44,7 @@

 GLOBAL_ENTRY(efi_call_phys)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
-	alloc loc1=3Dar.pfs,8,5,7,0
+	alloc loc1=3Dar.pfs,8,7,7,0
 	ld8 r2=3D[in0],8			// load EFI function's entry point
 	mov loc0=3Drp
 	.body
@@ -70,9 +70,13 @@
 	mov out3=3Din4
 	mov out5=3Din6
 	mov out6=3Din7
+	mov loc5=3Dr19
+	mov loc6=3Dr20
 	br.call.sptk.many rp=B6		// call the EFI function
 .ret1:	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3
+	mov r19=3Dloc5
+	mov r20=3Dloc6
 	br.call.sptk.many rp=3Dia64_switch_mode_virt // return to virtual mode
 .ret2:	mov ar.rsc=3Dloc4			// restore RSE configuration
 	mov ar.pfs=3Dloc1
=3D=3D=3D arch/ia64/kernel/head.S 1.24 vs edited =3D=3D--- 1.24/arch/ia64/k=
ernel/head.S	Wed Jun 16 18:09:33 2004
+++ edited/arch/ia64/kernel/head.S	Mon Jun 28 21:55:01 2004
@@ -706,6 +706,9 @@
  *
  * Inputs:
  *	r16 =3D new psr to establish
+ * Output:
+ *	r19 =3D old virtual address of ar.bsp
+ *	r20 =3D old virtual address of sp
  *
  * Note: RSE must already be in enforced lazy mode
  */
@@ -724,12 +727,13 @@
 	mov cr.ipsr=3Dr16			// set new PSR
 	add r3=1F-ia64_switch_mode_phys,r15

-	mov r17=3Dar.bsp
+	mov r19=3Dar.bsp
+	mov r20=3Dsp
 	mov r14=3Drp			// get return address into a general register
 	;;

 	// going to physical mode, use tpa to translate virt->phys
-	tpa r17=3Dr17
+	tpa r17=3Dr19
 	tpa r3=3Dr3
 	tpa sp=3Dsp
 	tpa r14=3Dr14
@@ -752,6 +756,8 @@
  *
  * Inputs:
  *	r16 =3D new psr to establish
+ *	r19 =3D new bspstore to establish
+ *	r20 =3D new sp to establish
  *
  * Note: RSE must already be in enforced lazy mode
  */
@@ -770,7 +776,6 @@
 	mov cr.ipsr=3Dr16			// set new PSR
 	add r3=1F-ia64_switch_mode_virt,r15

-	mov r17=3Dar.bsp
 	mov r14=3Drp			// get return address into a general register
 	;;

@@ -781,15 +786,14 @@
 	movl r18=3DKERNEL_START
 	dep r3=3D0,r3,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
 	dep r14=3D0,r14,KERNEL_TR_PAGE_SHIFT,64-KERNEL_TR_PAGE_SHIFT
-	dep r17=3D-1,r17,61,3
-	dep sp=3D-1,sp,61,3
+	mov sp=3Dr20
 	;;
 	or r3=3Dr3,r18
 	or r14=3Dr14,r18
 	;;

 	mov r18=3Dar.rnat			// save ar.rnat
-	mov ar.bspstore=3Dr17		// this steps on ar.rnat
+	mov ar.bspstore=3Dr19		// this steps on ar.rnat
 	mov cr.iip=3Dr3
 	mov cr.ifs=3Dr0
 	;;
=3D=3D=3D arch/ia64/kernel/pal.S 1.7 vs edited =3D=3D--- 1.7/arch/ia64/kern=
el/pal.S	Thu May 15 04:45:02 2003
+++ edited/arch/ia64/kernel/pal.S	Mon Jun 28 21:55:03 2004
@@ -176,10 +176,14 @@
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
 	br.call.sptk.many rp=3Dia64_switch_mode_phys
 .ret1:	mov rp =3D r8			// install return address (physical)
+	mov loc5 =3D r19
+	mov loc6 =3D r20
 	br.cond.sptk.many b7
 1:
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
+	mov r19=3Dloc5
+	mov r20=3Dloc6
 	br.call.sptk.many rp=3Dia64_switch_mode_virt // return to virtual mode
 .ret2:
 	mov psr.l =3D loc3		// restore init PSR
@@ -201,7 +205,7 @@
  */
 GLOBAL_ENTRY(ia64_pal_call_phys_stacked)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
-	alloc	loc1 =3D ar.pfs,5,5,86,0
+	alloc	loc1 =3D ar.pfs,5,7,4,0
 	movl	loc2 =3D pal_entry_point
 1:	{
 	  mov r28  =3D in0		// copy procedure index
@@ -230,10 +234,14 @@
 	andcm r16=3Dloc3,r16		// removes bits to clear from psr
 	br.call.sptk.many rp=3Dia64_switch_mode_phys
 .ret6:
+	mov loc5 =3D r19
+	mov loc6 =3D r20
 	br.call.sptk.many rp=B7		// now make the call
 .ret7:
 	mov ar.rsc=3D0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3			// r16=3D original psr
+	mov r19=3Dloc5
+	mov r20=3Dloc6
 	br.call.sptk.many rp=3Dia64_switch_mode_virt	// return to virtual mode

 .ret8:	mov psr.l  =3D loc3		// restore init PSR


