From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 19 Jul 2001 19:25:35 +0000
Subject: Re: [Linux-ia64] 010626 kernel, copy_from_user() broken?
Message-Id: <marc-linux-ia64-105590693005854@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005846@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005846@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 12 Jul 2001 12:16:58 +0100, Richard Hirst <rhirst@linuxcare.com> said:

  Rich> Hi, Summary: I had to change PIPE_DEPTH in
  Rich> arch/ia64/lib/copy_user.S from 21 to 4 to make
  Rich> copy_from_user() work with non-aligned user addresses on my B3
  Rich> cpu.  PIPE_DEPTH was 4 in the 010530 kernel.

Thanks for reporting this (and for tracking it down!).  It turns out
that the author of the copy_user() recovery code either knowingly or
accidentally assumed that PIPE_DEPTH=4, which is of course not good
as it defeats the whole purpose of making the sw-pipelined loop
tunable.  The patch below should fix this.  Can you try it instead and
let me know how it goes?

Thanks,

	--david

--- lia64/arch/ia64/lib/copy_user.S	Tue Jun 26 22:31:21 2001
+++ lia64-kdb/arch/ia64/lib/copy_user.S	Thu Jul 19 12:21:26 2001
@@ -37,7 +37,7 @@
 #define COPY_BREAK	16	// we do byte copy below (must be >)
 #define PIPE_DEPTH	21	// pipe depth
 
-#define EPI		p[PIPE_DEPTH-1] // PASTE(p,16+PIPE_DEPTH-1)
+#define EPI		p[PIPE_DEPTH-1]
 
 //
 // arguments
@@ -148,8 +148,8 @@
 	//
 
 	//
-	// Optimization. If dst1 is 8-byte aligned (not rarely), we don't need
-	// to copy the head to dst1, to start 8-byte copy software pipleline.
+	// Optimization. If dst1 is 8-byte aligned (quite common), we don't need
+	// to copy the head to dst1, to start 8-byte copy software pipeline.
 	// We know src1 is not 8-byte aligned in this case.
 	//
 	cmp.eq p14,p15=r0,dst2
@@ -233,15 +233,23 @@
 #define SWITCH(pred, shift)	cmp.eq pred,p0=shift,rshift
 #define CASE(pred, shift)	\
 	(pred)	br.cond.spnt.few copy_user_bit##shift
-#define BODY(rshift)							\
-copy_user_bit##rshift:							\
-1:									\
-	EX(failure_out,(EPI) st8 [dst1]=tmp,8);				\
-(EPI_1) shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;		\
-	EX(failure_in2,(p16) ld8 val1[0]=[src1],8);			\
-	br.ctop.dptk.few 1b;						\
-	;;								\
-	br.cond.spnt.few .diff_align_do_tail
+#define BODY(rshift)						\
+copy_user_bit##rshift:						\
+1:								\
+	EX(failure_out,(EPI) st8 [dst1]=tmp,8);			\
+(EPI_1) shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
+	EX(3f,(p16) ld8 val1[0]=[src1],8);			\
+	br.ctop.dptk.few 1b;					\
+	;;							\
+	br.cond.sptk.few .diff_align_do_tail;			\
+2:								\
+(EPI)	st8 [dst1]=tmp,8;					\
+(EPI_1)	shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;	\
+3:								\
+(p16)	mov val1[0]=r0;						\
+	br.ctop.dptk.few 2b;					\
+	;;							\
+	br.cond.sptk.few failure_in2
 
 	//
 	// Since the instruction 'shrp' requires a fixed 128-bit value
@@ -581,13 +589,7 @@
 	br.ret.dptk.few rp
 
 failure_in2:
-	sub ret0=endsrc,src1	// number of bytes to zero, i.e. not copied
-	;;
-3:
-(p16)	mov val1[0]=r0
-(EPI)	st8 [dst1]=val1[PIPE_DEPTH-1],8
-	br.ctop.dptk.few 3b
-	;;
+	sub ret0=endsrc,src1
 	cmp.ne p6,p0=dst1,enddst	// Do we need to finish the tail ?
 	sub len=enddst,dst1,1		// precompute len
 (p6)	br.cond.dptk.few failure_in1bis

