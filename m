From: "Mallick, Asit K" <asit.k.mallick@intel.com>
Date: Sat, 27 Jul 2002 01:05:16 +0000
Subject: [Linux-ia64] Patch to fix Itanium copy_user for uninitialized NaT
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----_=_NextPart_000_01C23509.AB317C40"
Message-Id: <marc-linux-ia64-105590701905841@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_000_01C23509.AB317C40
Content-Type: text/plain;
	charset="iso-8859-1"

We recently found a problem with Itanium version of copy_user while running
optimized spec benchmarks. We root caused this to an uninitialized register
use in the copy_user.S that happens to have a NaT and was causing NaT
consumption fault -> resulted in seg fault.

This is due to the case in copy_user for handling unaligned accesses it uses
the rotating registers R[N] and R[N-1] in Nth cycle. So, when the loop count
is smaller than the pipe depth last R[N-1] is uninitialized. The patch
cahnges the register usage to R[N+1] and R[N] and initializes both registers
in the loop and fixes this problem. McKinley optimized version of the
copy_user function (in memcpy_mck.S) does not have this problem.

Thanks,
Asit

--- linux/arch/ia64/lib/copy_user.S.orig	Wed Jul 24 16:43:54 2002
+++ linux/arch/ia64/lib/copy_user.S	Wed Jul 24 16:46:27 2002
@@ -237,15 +237,17 @@
 .copy_user_bit##rshift:						\
 1:								\
 	EX(.failure_out,(EPI) st8 [dst1]=tmp,8);		\
-(EPI_1) shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
-	EX(3f,(p16) ld8 val1[0]=[src1],8);			\
+(EPI_1) shrp tmp=val1[PIPE_DEPTH-2],val1[PIPE_DEPTH-1],rshift;	\
+	EX(3f,(p16) ld8 val1[1]=[src1],8);			\
+(p16)	mov val1[0]=r0;						\
 	br.ctop.dptk 1b;					\
 	;;							\
 	br.cond.sptk.many .diff_align_do_tail;			\
 2:								\
 (EPI)	st8 [dst1]=tmp,8;					\
-(EPI_1)	shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
+(EPI_1)	shrp tmp=val1[PIPE_DEPTH-2],val1[PIPE_DEPTH-1],rshift;	\
 3:								\
+(p16)	mov val1[1]=r0;						\
 (p16)	mov val1[0]=r0;						\
 	br.ctop.dptk 2b;					\
 	;;							\

 <<nat-patch.diff>> 

------_=_NextPart_000_01C23509.AB317C40
Content-Type: application/octet-stream;
	name="nat-patch.diff"
Content-Disposition: attachment;
	filename="nat-patch.diff"

--- linux/arch/ia64/lib/copy_user.S.orig	Wed Jul 24 16:43:54 2002
+++ linux/arch/ia64/lib/copy_user.S	Wed Jul 24 16:46:27 2002
@@ -237,15 +237,17 @@
 .copy_user_bit##rshift:						\
 1:								\
 	EX(.failure_out,(EPI) st8 [dst1]=tmp,8);		\
-(EPI_1) shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
-	EX(3f,(p16) ld8 val1[0]=[src1],8);			\
+(EPI_1) shrp tmp=val1[PIPE_DEPTH-2],val1[PIPE_DEPTH-1],rshift;	\
+	EX(3f,(p16) ld8 val1[1]=[src1],8);			\
+(p16)	mov val1[0]=r0;						\
 	br.ctop.dptk 1b;					\
 	;;							\
 	br.cond.sptk.many .diff_align_do_tail;			\
 2:								\
 (EPI)	st8 [dst1]=tmp,8;					\
-(EPI_1)	shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
+(EPI_1)	shrp tmp=val1[PIPE_DEPTH-2],val1[PIPE_DEPTH-1],rshift;	\
 3:								\
+(p16)	mov val1[1]=r0;						\
 (p16)	mov val1[0]=r0;						\
 	br.ctop.dptk 2b;					\
 	;;							\

------_=_NextPart_000_01C23509.AB317C40--

