From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Thu, 11 Jan 2001 22:10:11 +0000
Subject: RE: [Linux-ia64] Kernel panic in dtlb_fault
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C07C1B.442CECD0"
Message-Id: <marc-linux-ia64-105590693005034@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C07C1B.442CECD0
Content-Type: text/plain;
	charset="iso-8859-1"

Attached is a patch to fix the problem. Uros and Jenna were able to boot
with this patch. Sorry for sending the early version.

Thanks,
Asit




> -----Original Message-----
> From: Uros Prestor [mailto:uros@turbolinux.com]
> Sent: Thursday, January 11, 2001 12:13 PM
> To: davidm@hpl.hp.com
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
> 
> 
> David Mosberger wrote:
> 
> > Are you sure you picked up the new kernel?  Try "objdump -d" on
> > vmlinux and verify that itlb_fault ends with "b0" being restored.
> 
> This is the disassembly output of itlb_fault:
> e000000000500400 <itlb_fault>:
> e000000000500400:       00 80 00 28 24 04       [MII]       
> mov r16=cr20
> e000000000500406:       d0 01 00 62 00 e0                   mov r29=b0
> e00000000050040c:       03 00 cc 00                         mov r31=pr
> e000000000500410:       05 88 00 32 24 44       [MLX]       
> mov r17=cr25
> e000000000500416:       00 00 00 00 60 c0                   
> movl r30=0xe00000000
> 0500420;;
> e00000000050041c:       03 02 22 68
> e000000000500420:       0a 90 00 22 18 10       [MMI]       
> ld8 r18=[r17];;
> e000000000500426:       00 00 00 02 00 c0                   nop.m 0x0
> e00000000050042c:       00 90 00 50                         
> tbit.z p6,p0=r18,0
> e000000000500430:       11 00 00 00 01 00       [MIB]       nop.m 0x0
> e000000000500436:       00 00 00 02 00 03                   nop.i 0x0
> e00000000050043c:       98 0c 00 41                   (p06) 
> br.cond.spnt.many e0
> 000000005010c0 <page_fault>;;
> e000000000500440:       0a 00 48 00 2f 04       [MMI]       
> itc.i r18;;
> e000000000500446:       00 00 00 02 00 00                   nop.m 0x0
> e00000000050044c:       d0 09 00 07                         mov b0=r29
> e000000000500450:       11 00 00 00 01 00       [MIB]       nop.m 0x0
> e000000000500456:       f0 ff c0 bf 05 00                   
> mov pr=r31,0xfffffff
> ffffffffe
> e00000000050045c:       00 00 20 00                         rfi;;
> 
> Seems like the b0 register is getting restored correctly.
> 
> Uros
> 
> --
> Uros Prestor
> uros@turbolinux.com
> 
> 
> 
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


------_=_NextPart_000_01C07C1B.442CECD0
Content-Type: application/octet-stream;
	name="ivt.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="ivt.diff"

--- linux-2.4.0/arch/ia64/kernel/ivt.S	Tue Jan  9 03:48:36 2001=0A=
+++ linux/arch/ia64/kernel/ivt.S	Thu Jan 11 02:30:30 2001=0A=
@@ -193,6 +193,7 @@=0A=
 	;;=0A=
 1:	ld8 r18=3D[r17]				// read L3 PTE=0A=
 	;;=0A=
+	mov b0=3Dr29=0A=
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?=0A=
 (p6)	br.cond.spnt.many page_fault=0A=
 	;;=0A=
@@ -228,6 +229,7 @@=0A=
 	;;=0A=
 1:	ld8 r18=3D[r17]				// read L3 PTE=0A=
 	;;=0A=
+	mov b0=3Dr29=0A=
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?=0A=
 (p6)	br.cond.spnt.many page_fault=0A=
 	;;=0A=
@@ -399,7 +401,6 @@=0A=
 	shr.u r18=3Dr16,PMD_SHIFT			// shift L2 index into position=0A=
 	;;=0A=
 	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)=0A=
-	mov b0=3Dr30=0A=
 	;;=0A=
 (p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?=0A=
 	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page =
table entry=0A=
@@ -409,8 +410,8 @@=0A=
 	;;=0A=
 (p7)	cmp.eq.or.andcm p6,p7=3Dr17,r0		// was L2 entry NULL?=0A=
 	dep r17=3Dr19,r17,3,(PAGE_SHIFT-3)	// compute address of L3 page =
table entry=0A=
-	;;=0A=
 (p6)	br.cond.spnt.many page_fault=0A=
+	mov b0=3Dr30=0A=
 	br.sptk.many b0				// return to continuation point=0A=
 	;;=0A=
 =0A=

------_=_NextPart_000_01C07C1B.442CECD0--


