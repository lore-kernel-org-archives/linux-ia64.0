From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Wed, 17 Apr 2002 18:51:15 +0000
Subject: [Linux-ia64] Patch to fix lfetches accessing beyond a page (copy_page/clear_pa
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C1E640.D9E05E20"
Message-Id: <marc-linux-ia64-105590701905475@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C1E640.D9E05E20
Content-Type: text/plain;
	charset="iso-8859-1"

Here is a patch fix the lfetches accessing beyond a page that can have a
side effect of generating an MCA if the physical memory does not exist. For
example, copy_page will try to access video memory for the page that ends at
640K and this can cause MCA for some platforms. Some of the Bigsur UP boot
failures were root caused to this problem.

Both copy page and clear_page are very performance critical functions and
tuned for both Itanium and McKinley. The patch is implemented using unused
slots (nops) and has no performance impact.

For kernels 2.4.18 and higher you will just need the patch for copy_page().
clear_page and McKinley optimized copy_page has been already taken care.

--- linux-2.4.16-akm/arch/ia64/lib/copy_page.S  Fri Nov  9 14:26:17 2001

+++ linux/arch/ia64/lib/copy_page.S     Wed Apr 10 17:38:07 2002
@@ -30,6 +30,7 @@
 #define tgt2           r23
 #define srcf           r24
 #define tgtf           r25
+#define tgt_last       r26
                        
 #define Nrot           ((8*PIPE_DEPTH+7)&~7)

  
@@ -55,18 +56,21 @@  
        
        mov src1=in1
        adds src2=8,in1
+       mov tgt_last = PAGE_SIZE
        ;;
        adds tgt2=8,in0
        add srcf=512,in1
        mov ar.lc=lcount
        mov tgt1=in0
        add tgtf=512,in0
+       add tgt_last = tgt_last, in0
        ;;
 1:
 (p[0]) ld8 t1[0]=[src1],16
 (EPI)  st8 [tgt1]=t1[PIPE_DEPTH-1],16
 (p[0]) ld8 t2[0]=[src2],16
 (EPI)  st8 [tgt2]=t2[PIPE_DEPTH-1],16
+       cmp.ltu p6,p0 = tgtf, tgt_last
        ;;
 (p[0]) ld8 t3[0]=[src1],16
 (EPI)  st8 [tgt1]=t3[PIPE_DEPTH-1],16
@@ -83,8 +87,8 @@
 (p[0]) ld8 t8[0]=[src2],16
 (EPI)  st8 [tgt2]=t8[PIPE_DEPTH-1],16

-       lfetch [srcf], 64
-       lfetch [tgtf], 64
+(p6)   lfetch [srcf], 64
+(p6)   lfetch [tgtf], 64
        br.ctop.sptk.few 1b
        ;;
        mov pr=saved_pr,0xffffffffffff0000      // restore predicates


For kernels below 2.4.18, you will need the patch for clear_page also.

--- linux-2.4.16-akm/arch/ia64/lib/clear_page.S Fri Nov  9 14:26:17 2001
+++ linux/arch/ia64/lib/clear_page.S    Wed Apr 10 17:32:26 2002
@@ -23,15 +23,18 @@
 #define dst2           r9
 #define dst3           r10
 #define dst_fetch      r11
+#define dst_last       r14

 GLOBAL_ENTRY(clear_page)
        .prologue
        .regstk 1,0,0,0
        mov r16 = PAGE_SIZE/64-1        // -1 = repeat/until
+       mov r17 = PAGE_SIZE
        ;;
        .save ar.lc, saved_lc
        mov saved_lc = ar.lc
        .body
+       add dst_last = r17, dst0
        mov ar.lc = r16
        adds dst1 = 16, dst0
        adds dst2 = 32, dst0
@@ -40,10 +43,12 @@
        ;;
 1:     stf.spill.nta [dst0] = f0, 64
        stf.spill.nta [dst1] = f0, 64
+       cmp.ltu p6,p0 = dst_fetch, dst_last
        stf.spill.nta [dst2] = f0, 64
        stf.spill.nta [dst3] = f0, 64
+       ;;
 
-       lfetch [dst_fetch], 64
+(p6)   lfetch [dst_fetch], 64
        br.cloop.dptk.few 1b
        ;;      
        mov ar.lc = r2          // restore lc

Thanks,
Asit

 <<copy_page.diff>>  <<clear_page.diff>> 

------_=_NextPart_000_01C1E640.D9E05E20
Content-Type: application/octet-stream;
	name="copy_page.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="copy_page.diff"

--- linux-2.4.16-akm/arch/ia64/lib/copy_page.S	Fri Nov  9 14:26:17 =
2001=0A=
+++ linux/arch/ia64/lib/copy_page.S	Wed Apr 10 17:38:07 2002=0A=
@@ -30,6 +30,7 @@=0A=
 #define tgt2		r23=0A=
 #define srcf		r24=0A=
 #define tgtf		r25=0A=
+#define tgt_last	r26=0A=
 =0A=
 #define Nrot		((8*PIPE_DEPTH+7)&~7)=0A=
 =0A=
@@ -55,18 +56,21 @@=0A=
 =0A=
 	mov src1=3Din1=0A=
 	adds src2=3D8,in1=0A=
+	mov tgt_last =3D PAGE_SIZE=0A=
 	;;=0A=
 	adds tgt2=3D8,in0=0A=
 	add srcf=3D512,in1=0A=
 	mov ar.lc=3Dlcount=0A=
 	mov tgt1=3Din0=0A=
 	add tgtf=3D512,in0=0A=
+	add tgt_last =3D tgt_last, in0=0A=
 	;;=0A=
 1:=0A=
 (p[0])	ld8 t1[0]=3D[src1],16=0A=
 (EPI)	st8 [tgt1]=3Dt1[PIPE_DEPTH-1],16=0A=
 (p[0])	ld8 t2[0]=3D[src2],16=0A=
 (EPI)	st8 [tgt2]=3Dt2[PIPE_DEPTH-1],16=0A=
+	cmp.ltu p6,p0 =3D tgtf, tgt_last=0A=
 	;;=0A=
 (p[0])	ld8 t3[0]=3D[src1],16=0A=
 (EPI)	st8 [tgt1]=3Dt3[PIPE_DEPTH-1],16=0A=
@@ -83,8 +87,8 @@=0A=
 (p[0])	ld8 t8[0]=3D[src2],16=0A=
 (EPI)	st8 [tgt2]=3Dt8[PIPE_DEPTH-1],16=0A=
 =0A=
-	lfetch [srcf], 64=0A=
-	lfetch [tgtf], 64=0A=
+(p6)	lfetch [srcf], 64=0A=
+(p6)	lfetch [tgtf], 64=0A=
 	br.ctop.sptk.few 1b=0A=
 	;;=0A=
 	mov pr=3Dsaved_pr,0xffffffffffff0000	// restore predicates=0A=

------_=_NextPart_000_01C1E640.D9E05E20
Content-Type: application/octet-stream;
	name="clear_page.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="clear_page.diff"

--- linux-2.4.16-akm/arch/ia64/lib/clear_page.S	Fri Nov  9 14:26:17 =
2001=0A=
+++ linux/arch/ia64/lib/clear_page.S	Wed Apr 10 17:32:26 2002=0A=
@@ -23,15 +23,18 @@=0A=
 #define dst2		r9=0A=
 #define dst3		r10=0A=
 #define dst_fetch	r11=0A=
+#define dst_last	r14=0A=
 =0A=
 GLOBAL_ENTRY(clear_page)=0A=
 	.prologue=0A=
 	.regstk 1,0,0,0=0A=
 	mov r16 =3D PAGE_SIZE/64-1	// -1 =3D repeat/until=0A=
+	mov r17 =3D PAGE_SIZE=0A=
 	;;=0A=
 	.save ar.lc, saved_lc=0A=
 	mov saved_lc =3D ar.lc=0A=
 	.body=0A=
+	add dst_last =3D r17, dst0=0A=
 	mov ar.lc =3D r16=0A=
 	adds dst1 =3D 16, dst0=0A=
 	adds dst2 =3D 32, dst0=0A=
@@ -40,10 +43,12 @@=0A=
 	;;=0A=
 1:	stf.spill.nta [dst0] =3D f0, 64=0A=
 	stf.spill.nta [dst1] =3D f0, 64=0A=
+	cmp.ltu p6,p0 =3D dst_fetch, dst_last=0A=
 	stf.spill.nta [dst2] =3D f0, 64=0A=
 	stf.spill.nta [dst3] =3D f0, 64=0A=
+	;;=0A=
 =0A=
-	lfetch [dst_fetch], 64=0A=
+(p6)	lfetch [dst_fetch], 64=0A=
 	br.cloop.dptk.few 1b=0A=
 	;;=0A=
 	mov ar.lc =3D r2		// restore lc=0A=

------_=_NextPart_000_01C1E640.D9E05E20--

