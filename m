From: Jun Nakajima <jun@sco.com>
Date: Mon, 23 Oct 2000 20:04:47 +0000
Subject: [Linux-ia64] Update: optimizing __copy_user
Message-Id: <marc-linux-ia64-105590678205606@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have updated __copy_user, reflecting the comments I got. Thanks for
those comments. The major changes are that it uses 'shrp' to make the
software pipeline shorter and more efficient (rahter than using 'shr.u',
'shl', and 'or'). 

-- 
Jun U Nakajima
Core OS Development
SCO/Murray Hill, NJ
Email: jun@sco.com, Phone: 908-790-2352 Fax: 908-790-2426

-----------------------------------------------------------------------
*** copy_user.S.org     Tue Oct 10 11:31:43 2000
--- copy_user.S Mon Oct 23 12:00:06 2000
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
--- 140,329 ----
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
+       // failure_in3 does. If the byte-by-byte at the tail fails, it
is
+       // handled simply by failure_in_pipe1.
+       //
+       // The case p14 represents the source has more bytes in the
+       // the first word (by the shifted part), whereas the p15 needs
to 
+       // copy some bytes from the 2nd word of the source that has the 
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
+       clrrrb
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
+       //
+       // The pipleline consists of 3 stages:
+       // 1 (p16):     Load a word from src1
+       // 2 (EPI_1):   Shift right pair, saving to tmp
+       // 3 (EPI):     Store tmp to dst1
+       //
+       // To make it simple, use at least 2 (p16) loops to set up
val1[n] 
+       // because we need 2 back-to-back val1[] to get tmp.
+       // Note that this implies EPI_2 must be p18 or greater.
+       // 
+ 
+ #define EPI_1         p[PIPE_DEPTH-2]
+ #define SWITCH(pred, shift)   cmp.eq pred,p0=shift,rshift
+ #define CASE(pred, shift)     \
+       (pred)  br.cond.spnt.few copy_user_bit##shift
+ #define BODY(rshift)                                                 
\
+ copy_user_bit##rshift:
\
+ 1:                                                                   
\
+       EX(failure_out,(EPI) st8 [dst1]=tmp,8);                        
\
+ (EPI_1) shrp tmp=val1[PIPE_DEPTH-3],val1[PIPE_DEPTH-2],rshift;
\
+       EX(failure_in2,(p16) ld8 val1[0]=[src1],8);                    
\
+       br.ctop.dptk.few 1b;                                           
\
+       ;;                                                             
\
+       br.cond.spnt.few .diff_align_do_tail
+ 
+       //
+       // Since the instruction 'shrp' requires a fixed 128-bit value
+       // specifying the bits to shift, we need to provide 7 cases
+       // below. 
+       //
+       SWITCH(p6, 8)
+       SWITCH(p7, 16)
+       SWITCH(p8, 24)
+       SWITCH(p9, 32)
+       SWITCH(p10, 40)
+       SWITCH(p11, 48)
+       SWITCH(p12, 56)
+       ;;
+       CASE(p6, 8)
+       CASE(p7, 16)
+       CASE(p8, 24)
+       CASE(p9, 32)
+       CASE(p10, 40)
+       CASE(p11, 48)
+       CASE(p12, 56)
+       ;;
+       BODY(8)
+       BODY(16)
+       BODY(24)
+       BODY(32)
+       BODY(40)
+       BODY(48)
+       BODY(56)
+       ;; 
+ .diff_align_do_tail:
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
+ 
+       sub len1=endsrc,src1,1
+       clrrrb
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
--- 332,338 ----
        ;;
        cmp.eq p10,p8=r0,tmp
        mov len1=len            // copy because of rotation
! (p8)  br.cond.dpnt.few diff_align_copy_user
        ;;
        // At this point we know we have more than 16 bytes to copy
        // and also that both src and dest have the same alignment
***************
*** 267,272 ****
--- 457,477 ----
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
--- 600,622 ----
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

