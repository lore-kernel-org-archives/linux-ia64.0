From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 10 Jul 2002 18:39:17 +0000
Subject: [Linux-ia64] RE: kernel update (relative to 2.4.18)
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C22841.18F17DA0"
Message-Id: <marc-linux-ia64-105590701905761@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205855@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205855@msgid-missing>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C22841.18F17DA0
Content-Type: text/plain;
	charset="iso-8859-1"

This patch fixes some critical bugs in copy_user exception handler found by
Xavier.  The fixes are all in the exception handler and there are no changes
in the main "copy" body.  I have tested with both gcc2.96 and gcc3.1
compiler.  Please report issues to me if there are any.  Thanks.

- Ken

-----Original Message-----
From: Xavier Bru [mailto:Xavier.Bru@bull.net]
Sent: Thursday, July 04, 2002 6:42 AM
To: davidm@hpl.hp.com; Chen, Kenneth W
Cc: Jacky.Malcles@bull.net; linux-ia64@linuxia64.org
Subject: RE: kernel update (relative to 2.4.18)



Thanks for your answers.

Kernel is compiled with gcc 3.1 (that should explain the problem of
missing ex-handler in the bundle).

If you need more infos about ltp test suite, you can ask Jacky
Malcles(Jacky.Malcles@bull.net).
Thanks
Xavier
------------------------------------------------------------------
test for  Problem 1 (missing EX handler)

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/signal.h>
#include <sys/ioctl.h>
#include <errno.h>


main()
{
  int	s, sinlen;
  s = socket(PF_INET, SOCK_STREAM, 0);
  if (s <0)
    perror("socket");
  getsockname(s, (struct sockaddr *)0, &sinlen);
  perror("getsockname");
}
------------------------------------------------------------------
test for Problem 2(recursive call to __copy_user)

# include <sys/types.h>
# include <sys/ipc.h>
# include <sys/sem.h>
main()
{
  int rc, semid;


  if ((semid=semget(IPC_PRIVATE, 10, IPC_CREAT | IPC_EXCL | 0600 )) == -1) {
    perror("semget");
    exit(2);
  }
  rc=semctl(semid, 0x0, 0xd, 0xffffffffUL);
  perror("semctl");
}
------------------------------------------------------------------


------_=_NextPart_000_01C22841.18F17DA0
Content-Type: application/octet-stream;
	name="cu.fix.diff"
Content-Disposition: attachment;
	filename="cu.fix.diff"

--- arch/ia64/lib/memcpy_mck.orig.S	Wed Jul 10 10:54:15 2002
+++ arch/ia64/lib/memcpy_mck.S	Wed Jul 10 10:54:23 2002
@@ -15,7 +15,11 @@
 #include <asm/asmmacro.h>
 #include <asm/page.h>
 
-#define EK(y,x...)  x
+#if __GNUC__ >= 3
+# define EK(y...) EX(y)
+#else
+# define EK(y,x...)  x
+#endif
 
 GLOBAL_ENTRY(bcopy)
 	.regstk 3,0,0,0
@@ -173,14 +177,14 @@
 EX(.ex_handler, (p6)	ld8	t1=[src0])
 	mov	ar.lc=saved_lc
 	mov	ar.pfs=saved_pfs
-EX(.ex_handler, (p7)	ld8	t2=[src1],8)
+EX(.ex_hndlr_s, (p7)	ld8	t2=[src1],8)
 	cmp.le	p8,p0=24,tmp
 	and	r21=-8,tmp
 	;;
-EX(.ex_handler, (p8)	ld8	t3=[src1])
-EK(.ex_handler, (p6)	st8	[dst0]=t1)	// store byte 1
+EX(.ex_hndlr_s, (p8)	ld8	t3=[src1])
+EX(.ex_handler, (p6)	st8	[dst0]=t1)	// store byte 1
 	and	in2=7,tmp	// remaining length
-EX(.ex_handler, (p7)	st8	[dst1]=t2,8)	// store byte 2
+EX(.ex_hndlr_d, (p7)	st8	[dst1]=t2,8)	// store byte 2
 	add	src0=src0,r21	// setting up src pointer
 	add	dst0=dst0,r21	// setting up dest pointer
 	;;
@@ -214,8 +218,8 @@
 	add cnt = -(2*PREFETCH_DIST) - 1, cnt
 	// same as .line_copy loop, but with all predicated-off instructions removed:
 .prefetch_loop:
-EX(.ex_handler_lcpy, (p[A])	ld8 v[A] = [src_pre_mem], 128)		// M0
-EK(.ex_handler_lcpy, (p[B])	st8 [dst_pre_mem] = v[B], 128)		// M2
+EX(.ex_hndlr_lcpy_1, (p[A])	ld8 v[A] = [src_pre_mem], 128)		// M0
+EK(.ex_hndlr_lcpy_1, (p[B])	st8 [dst_pre_mem] = v[B], 128)		// M2
 	br.ctop.sptk .prefetch_loop
 	;;
 	cmp.eq p16, p0 = r0, r0			// reset p16 to 1
@@ -356,7 +360,7 @@
 // that the loop produces.
 .noloop:
 EX(.ex_handler, (p6)	ld8	r37=[src1],8)
-	nop.m	0
+	add	src0=8,src0
 (p6)	shl	r25=r30,3
 	;;
 EX(.ex_handler, (p6)	ld8	r27=[src1])
@@ -568,18 +572,31 @@
 #define saved_rtlink	loc1
 #define saved_pfs_stack	loc2
 
+.ex_hndlr_s:
+	add	src0=8,src0
+	br.sptk .ex_handler
+	;;
+.ex_hndlr_d:
+	add	dst0=8,dst0
+	br.sptk .ex_handler
+	;;
+.ex_hndlr_lcpy_1:
+	mov	src1=src_pre_mem
+	mov	dst1=dst_pre_mem
+	cmp.gtu	p10,p11=src_pre_mem,saved_in1
+	cmp.gtu	p12,p13=dst_pre_mem,saved_in0
+	;;
+(p10)	add	src0=8,saved_in1
+(p11)	mov	src0=saved_in1
+(p12)	add	dst0=8,saved_in0
+(p13)	mov	dst0=saved_in0
+	br.sptk	.ex_handler
 .ex_handler_lcpy:
-	// in long copy block, the preload addresses should always ahead
-	// of the other two src/det pointers.  Furthermore, src1/dst1 should
+	// in line_copy block, the preload addresses should always ahead
+	// of the other two src/dst pointers.  Furthermore, src1/dst1 should
 	// always ahead of src0/dst0.
-	cmp.ltu	p10,p11=src_pre_l2,src_pre_mem
-	cmp.ltu	p12,p13=dst_pre_l2,dst_pre_mem
-	;;
-(p10)	mov	src1=src_pre_mem
-(p11)	mov	src1=src_pre_l2
-(p12)	mov	dst1=dst_pre_mem
-(p13)	mov	dst1=dst_pre_l2
-	;;
+	mov	src1=src_pre_mem
+	mov	dst1=dst_pre_mem
 .ex_handler:
 	mov	pr=saved_pr,-1		// first restore pr, lc, and pfs
 	mov	ar.lc=saved_lc
@@ -599,8 +616,8 @@
 (p6)	dep	F = r0,dst1,0,PAGE_SHIFT // usr dst round down to page boundary
 (p7)	dep	F = r0,src1,0,PAGE_SHIFT // usr src round down to page boundary
 	;;
-(p6)	cmp.le	p14,p0=F,saved_in0	// bad address to start with
-(p7)	cmp.le	p14,p0=F,saved_in1	// here too
+(p6)	cmp.le	p14,p0=dst0,saved_in0	// no progress has been made on store
+(p7)	cmp.le	p14,p0=src0,saved_in1	// no progress has been made on load
 	mov	retval=saved_in2
 (p8)	ld1	tmp=[src1]		// force an oops for memcpy call
 (p8)	st1	[dst1]=r0		// force an oops for memcpy call

------_=_NextPart_000_01C22841.18F17DA0--

