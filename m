From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Mon, 15 Jan 2001 23:08:38 +0000
Subject: RE: [Linux-ia64] Kernel panic in dtlb_fault
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C07F48.184F6563"
Message-Id: <marc-linux-ia64-105590693005046@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205904@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205904@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C07F48.184F6563
Content-Type: text/plain;
	charset="ISO-8859-1"

This is a patch that fixes the VHPT disabled kernel problems. Uros has
verified this and it is at the same level as VHPT enabled kernel on B3.

Thanks,
Asit


> -----Original Message-----
> From: Uros Prestor [mailto:uros@turbolinux.com]
> Sent: Friday, January 12, 2001 11:37 AM
> To: Mallick, Asit K
> Cc: linux-ia64@linuxia64.org
> Subject: Re: [Linux-ia64] Kernel panic in dtlb_fault
> 
> 
> "Mallick, Asit K" wrote:
> 
> > Attached is a patch to fix the problem. Uros and Jenna were 
> able to boot
> > with this patch. Sorry for sending the early version.
> 
> Something is still not kosher if you enable 
> CONFIG_DISABLE_VHPT=y.  If I try
> recompiling the gnupro RPM the compilation breaks down 
> immediately after the
> config stage With the following error:
> 
>      # rpm -ba /usr/src/turbo/SPECS/gnupro.spec
>      ...
>      creating ./config.status
>      creating Makefile
>      Configuring utils...
>      Created "Makefile" in /work/BUILD/gnupro-2.96/build/utils
>      Configuring spu...
>      Created "Makefile" in /work/BUILD/gnupro-2.96/build/utils/spu
>      ++ perl -e 'if( -x "/usr/bin/getconf" &&  ( ($p=`/usr/bin/getconf
>      _NPROCESSORS_ONLN`) >= 0 ) ){ print "$p"} else { print "1"; }'
>      + make -j 2
>      /bin/sh: SHELL: command not found
>      /bin/sh: -c: command not found
>      make: *** [all-libiberty] Error 127
>      make: *** Waiting for unfinished jobs....
>      Bad exit status from /var/tmp/rpm-tmp.82077 (%build)
> 
> Things become very bizarre if you try to compile by hand, ranging from
> reports of missing /lib/libc.so.6.1 to internal compiler 
> errors...  This
> happens both on 2xB3 BigSur and 4xB3 Lion.  If I revert to 
> the kernel which
> enables VHPT the compilation goes just fine.
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


------_=_NextPart_000_01C07F48.184F6563
Content-Type: application/octet-stream;
	name="ivt.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="ivt.diff"

--- linux-2.4.0/arch/ia64/kernel/ivt.S	Tue Jan  9 03:48:36 2001=0A=
+++ linux/arch/ia64/kernel/ivt.S	Fri Jan 12 04:47:05 2001=0A=
@@ -184,15 +184,16 @@=0A=
 	 * mode, walk the page table, and then re-execute the L3 PTE read=0A=
 	 * and go on normally after that.=0A=
 	 */=0A=
-itlb_fault:=0A=
 	mov r16=3Dcr.ifa				// get virtual address=0A=
 	mov r29=3Db0				// save b0=0A=
 	mov r31=3Dpr				// save predicates=0A=
+itlb_fault:=0A=
 	mov r17=3Dcr.iha				// get virtual address of L3 PTE=0A=
 	movl r30=3D1f				// load nested fault continuation point=0A=
 	;;=0A=
 1:	ld8 r18=3D[r17]				// read L3 PTE=0A=
 	;;=0A=
+	mov b0=3Dr29=0A=
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?=0A=
 (p6)	br.cond.spnt.many page_fault=0A=
 	;;=0A=
@@ -219,15 +220,16 @@=0A=
 	 * mode, walk the page table, and then re-execute the L3 PTE read=0A=
 	 * and go on normally after that.=0A=
 	 */=0A=
-dtlb_fault:=0A=
 	mov r16=3Dcr.ifa				// get virtual address=0A=
 	mov r29=3Db0				// save b0=0A=
 	mov r31=3Dpr				// save predicates=0A=
+dtlb_fault:=0A=
 	mov r17=3Dcr.iha				// get virtual address of L3 PTE=0A=
 	movl r30=3D1f				// load nested fault continuation point=0A=
 	;;=0A=
 1:	ld8 r18=3D[r17]				// read L3 PTE=0A=
 	;;=0A=
+	mov b0=3Dr29=0A=
 	tbit.z p6,p0=3Dr18,_PAGE_P_BIT		// page present bit cleared?=0A=
 (p6)	br.cond.spnt.many page_fault=0A=
 	;;=0A=
@@ -261,6 +263,7 @@=0A=
 (p8)	thash r17=3Dr16=0A=
 	;;=0A=
 (p8)	mov cr.iha=3Dr17=0A=
+(p8)	mov r29=3Db0				// save b0=0A=
 (p8)	br.cond.dptk.many itlb_fault=0A=
 #endif=0A=
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl=0A=
@@ -296,6 +299,7 @@=0A=
 (p8)	thash r17=3Dr16=0A=
 	;;=0A=
 (p8)	mov cr.iha=3Dr17=0A=
+(p8)	mov r29=3Db0				// save b0=0A=
 (p8)	br.cond.dptk.many dtlb_fault=0A=
 #endif=0A=
 	extr.u r23=3Dr21,IA64_PSR_CPL0_BIT,2	// extract psr.cpl=0A=
@@ -399,7 +403,6 @@=0A=
 	shr.u r18=3Dr16,PMD_SHIFT			// shift L2 index into position=0A=
 	;;=0A=
 	ld8 r17=3D[r17]				// fetch the L1 entry (may be 0)=0A=
-	mov b0=3Dr30=0A=
 	;;=0A=
 (p7)	cmp.eq p6,p7=3Dr17,r0			// was L1 entry NULL?=0A=
 	dep r17=3Dr18,r17,3,(PAGE_SHIFT-3)	// compute address of L2 page =
table entry=0A=
@@ -409,8 +412,8 @@=0A=
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

------_=_NextPart_000_01C07F48.184F6563--


