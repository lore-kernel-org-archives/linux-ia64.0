From: Jun Nakajima <jun@sco.com>
Date: Wed, 18 Oct 2000 21:59:04 +0000
Subject: [Linux-ia64] optimizing __copy_user
Message-Id: <marc-linux-ia64-105590678205596@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Recently I found that __copy_user function takes a
relatively/signficantly long time under some stress tests, and it turned
out that those cases are happening when the source and destination have
more than 16 bytes and the alignment are different. In fact, this
problem is pointed out in copy_user.S:
 * Fixme:
 *      - handle the case where we have more than 16 bytes and the
alignment
 *        are different.

Basically, it's copying byte by byte no matter how large the size is.

Following is a fix to that. I tested it using linux-2.4.0-test9.
-- 
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ
Email: jun@sco.com, Phone: 908-790-2352 Fax: 908-790-2426
-----------------------------------------------------------------------
*** copy_user.S.org     Tue Oct 10 11:31:43 2000
--- copy_user.S Wed Oct 18 14:26:36 2000
***************
*** 51,57 ****
  // Tuneable parameters
  //
  #define COPY_BREAK    16      // we do byte copy below (must be >)
! #define PIPE_DEPTH    4       // pipe depth
  
  #define EPI           p[PIPE_DEPTH-1] // PASTE(p,16+PIPE_DEPTH-1)
  
--- 51,57 ----
  // Tuneable parameters
  //
  #define COPY_BREAK    16      // we do byte copy below (must be >)
! #define PIPE_DEPTH    6       // pipe depth
  
  #define EPI           p[PIPE_DEPTH-1] // PASTE(p,16+PIPE_DEPTH-1)
  
***************
*** 65,70 ****
--- 65,76 ----
  //
  // local registers
  //
+ #define t1            r2      // rshift in bytes
+ #define t2            r3      // lshift in bytes
+ #define rshift                r14     // right shift in bits
+ #define lshift                r15     // left shift in bits
+ #define word1         r16
+ #define word2         r17
  #define cnt           r18
  #define len2          r19
  #define saved_lc      r20
***************
*** 134,139 ****
--- 140,328 ----
        br.ret.sptk.few rp      // end of short memcpy
  
        //
+       // Not 8-byte alinged
+       //
+ diff_align_copy_user:
+       // At this point we know we have more than 16 bytes to copy
+       // and also that src and dest do _not_ have the same alignment.
+       and src2=0x7,src1                               // src offset
+       and dst2=0x7,dst1                               // dst offset
+       ;;
+       // The basic idea is that we copy byte-by-byte at the head so 
+       // that we can reach 8-byte alignment for both src1 and dst1. 
+       // Then copy the body using software pipelined 8-byte copy, 
+       // shifting the two back-to-back words right and left, then copy 
+       // the tail by copying byte-by-byte.
+       //
+       // Fault handling. If the byte-by-byte at the head fails on the
+       // load, then restart and finish the pipleline by copying zeros
+       // to the dst1. Then copy zeros for the rest of dst1.
+       // If 8-byte software pipeline fails on the load, do the same as
+       // failure_in3 does. If the byte-by-byte at the tails fail, it
is
+       // handled simply by failure_in_pipe1.
+       //
+       // The case p14 represents the source has more bytes in the
+       // the first word (by the shifted part), whereas the p15 needs
to 
+       // copy some bytes from the 2nd word from the source that has
the 
+       // tail of the 1st of the destination.
+       //
+ 
+       //
+       // Optimization. If dst1 is 8-byte aligned (not rarely), we
don't need 
+       // to copy the head to dst1, to start 8-byte copy software
pipleline. 
+       // We know src1 is not 8-byte aligned in this case.
+       //
+       cmp.eq p14,p15=r0,dst2
+ (p15) br.cond.spnt.few 1f
+       ;;
+       sub t1=8,src2
+       mov t2=src2
+       ;;
+       shl rshift=t2,3
+       sub len1=len,t1                                 // set len1
+       ;;
+       sub lshiftd,rshift
+       ;; 
+       br.cond.spnt.few word_copy_user
+       ;; 
+ 1:
+       cmp.leu p14,p15=src2,dst2
+       sub t1=dst2,src2
+       ;;
+       .pred.rel "mutex", p14, p15
+ (p14) sub word1=8,src2                                // (8 - src
offset)
+ (p15) sub t1=r0,t1                                    // absolute
value
+ (p15) sub word1=8,dst2                                // (8 - dst
offset)
+       ;;
+       // For the case p14, we don't need to copy the shifted part to
+       // the 1st word of destination.
+       sub t2=8,t1
+ (p14) sub word1=word1,t1
+       ;;
+       sub len1=len,word1                              // resulting len
+       ;;
+ (p15) shl rshift=t1,3                                 // in bits
+ (p14) shl rshift=t2,3
+       ;; 
+ (p14) sub len1=len1,t1
+       adds cnt=-1,word1
+       ;; 
+       sub lshiftd,rshift
+       mov ar.ec=PIPE_DEPTH
+       mov pr.rot=1<<16        // p16=true all others are false
+       mov ar.lc=cnt
+       ;; 
+ 2:
+       EX(failure_in_pipe2,(p16) ld1 val1[0]=[src1],1)
+       ;; 
+       EX(failure_out,(EPI) st1 [dst1]=val1[PIPE_DEPTH-1],1)
+       br.ctop.dptk.few 2b
+       ;;
+ word_copy_user:
+       cmp.gtu p9,p0,len1
+ (p9)  br.cond.spnt.few 4f             // if (16 > len1) skip 8-byte
copy
+       ;;
+       shr.u cnt=len1,3                // number of 64-bit words
+       ;;
+       adds cnt=-1,cnt
+       ;;
+       .pred.rel "mutex", p14, p15
+ (p14) sub src1=src1,t2
+ (p15) sub src1=src1,t1
+       //
+       // Now both src1 and dst1 point to an 8-byte alinged address.
And
+       // we have more than 8 bytes to copy.
+       //
+       mov ar.lc=cnt
+       mov ar.ec=PIPE_DEPTH
+       mov pr.rot=1<<16        // p16=true all others are false
+       ;; 
+ 3:
+ #if PIPE_DEPTH >= 5
+ #define EPI_1         p[PIPE_DEPTH-2]
+ #define EPI_2         p[PIPE_DEPTH-3] 
+       //
+       // The pipleline consists of 4 stages:
+       // 1 (p16):     Load a word from src1
+       // 2 (EPI_2):   Shift two back-to-back val1[] right and left
+       // 3 (EPI_1):   Or them, saving the result to tmp
+       // 4 (EPI):     Store tmp to dst1
+       //
+       // To make it simple, use at least 2 (p16) loops to set up
val1[n] 
+       // because we need 2 back-to-back val1[] to get tmp.
+       // Note that this implies EPI_2 must be p18 or greater.
+       // 
+ 
+       EX(failure_out,(EPI) st8 [dst1]=tmp,8)
+ (EPI_1)       or tmp=word1,word2
+ (EPI_2)       shr.u word1=val1[PIPE_DEPTH-3],rshift
+ (EPI_2)       shl word2=val1[PIPE_DEPTH-4],lshift
+       EX(failure_in2,(p16) ld8 val1[0]=[src1],8)
+       br.ctop.dptk.few 3b
+       ;;                      // RAW on src1 when fall through from
loop
+ #else
+       //
+       // The software pipeline above should be smoother because it
does
+       // not have any stop bits.
+       //
+       EX(failure_in2,(p16) ld8 val1[0]=[src1],8)
+ (EPI) shr.u word1=val1[PIPE_DEPTH-1],rshift
+ (EPI) shl word2=val1[PIPE_DEPTH-2],lshift
+       ;; 
+ (EPI) or tmp=word1,word2
+       ;; 
+       EX(failure_out,(EPI) st8 [dst1]=tmp,8)
+       ;;
+       br.ctop.dptk.few 3b
+       ;;                      // RAW on src1 when fall through from
loop
+ #endif
+       .pred.rel "mutex", p14, p15
+ (p14) sub src1=src1,t1
+ (p14) adds dst1=-8,dst1
+ (p15) sub dst1=dst1,t1
+       ;; 
+ 4:
+       // Tail correction.
+       //
+       // The problem with this piplelined loop is that the last word
is not
+       // loaded and thus parf of the last word written is not correct. 
+       // To fix that, we simply copy the tail byte by byte.
+       ;;
+       sub len1=endsrc,src1,1
+       ;;
+       mov ar.lc=len1
+       ;;
+ 5:
+       EX(failure_in_pipe1,ld1 tmp=[src1],1)
+       ;; 
+       EX(failure_out,st1 [dst1]=tmp,1)
+       br.cloop.dptk.few 5b
+       ;; 
+ 
+ #if 0
+       // Fixme. Use the simple loop above in the meantime.
+       // If the code is followed by the software pipleline below,
+       // instead of the simple loop above, it sometimes does not work
+       // as expected.
+       // 
+       adds len1=1,len1
+       ;; 
+       mov ar.ec=PIPE_DEPTH
+       mov pr.rot=1<<16        // p16=true all others are false
+       mov ar.lc=len1
+       ;; 
+ 5:
+       EX(failure_in_pipe1,(p16) ld1 val1[0]=[src1],1)
+ 
+       EX(failure_out,(EPI) st1 [dst1]=val1[PIPE_DEPTH-1],1)
+       br.ctop.dptk.few 5b
+       ;;
+ #endif
+       mov pr=saved_pr,0xffffffffffff0000
+       mov ar.pfs=saved_pfs
+       br.ret.dptk.few rp
+ 
+       //
        // Beginning of long mempcy (i.e. > 16 bytes)
        //
  long_copy_user:
***************
*** 142,148 ****
        ;;
        cmp.eq p10,p8=r0,tmp
        mov len1=len            // copy because of rotation
! (p8)  br.cond.dpnt.few 1b     // XXX Fixme. memcpy_diff_align 
        ;;
        // At this point we know we have more than 16 bytes to copy
        // and also that both src and dest have the same alignment
--- 331,337 ----
        ;;
        cmp.eq p10,p8=r0,tmp
        mov len1=len            // copy because of rotation
! (p8)  br.cond.dpnt.few diff_align_copy_user
        ;;
        // At this point we know we have more than 16 bytes to copy
        // and also that both src and dest have the same alignment
***************
*** 267,272 ****
--- 456,476 ----
        mov ar.pfs=saved_pfs
        br.ret.dptk.few rp
  
+       //
+       // This is the case where the byte by byte copy fails on the
load
+       // when we copy the head. We need to finish the pipeline and
copy 
+       // zeros for the rest of the destination. Since this happens
+       // at the top we still need to fill the body and tail.
+ failure_in_pipe2:
+       sub ret0=endsrc,src1    // number of bytes to zero, i.e. not
copied
+ 2:
+ (p16) mov val1[0]=r0
+ (EPI) st1 [dst1]=val1[PIPE_DEPTH-1],1
+       br.ctop.dptk.few 2b
+       ;;
+       sub len=enddst,dst1,1           // precompute len
+       br.cond.dptk.few failure_in1bis
+       ;; 
  
        //
        // Here we handle the head & tail part when we check for
alignment.
***************
*** 395,400 ****
--- 599,621 ----
        mov ar.pfs=saved_pfs
        br.ret.dptk.few rp
  
+ failure_in2:
+       sub ret0=endsrc,src1    // number of bytes to zero, i.e. not
copied
+       ;;
+ 3:
+ (p16) mov val1[0]=r0
+ (EPI) st8 [dst1]=val1[PIPE_DEPTH-1],8
+       br.ctop.dptk.few 3b
+       ;;
+       cmp.ne p6,p0=dst1,enddst        // Do we need to finish the tail
?
+       sub len=enddst,dst1,1           // precompute len
+ (p6)  br.cond.dptk.few failure_in1bis
+       ;;
+       mov pr=saved_pr,0xffffffffffff0000
+       mov ar.lc=saved_lc
+       mov ar.pfs=saved_pfs
+       br.ret.dptk.few rp
+ 
        //
        // handling of failures on stores: that's the easy part
        //

