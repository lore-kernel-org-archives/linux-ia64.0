From: Jim Wilson <wilson@cygnus.com>
Date: Wed, 17 May 2000 20:17:03 +0000
Subject: Re: [Linux-ia64] IP-relative calls in start.S and initfini.c
Message-Id: <marc-linux-ia64-105590678205091@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205064@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205064@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Richard Henderson has written a gcc patch that I think will fix this problem.

The problem here is that we build the init/fini sections by concatening
code fragments together, and this does not work if the linker inserts
a brl thunk between two code fragments.  So Richard rewrote the init/fini
code so that we shouldn't get any out-of-range calls in these sections.

This is a patch for the current FSF gcc sources.  I don't know if this will
work with the older February branch (ia64-000216) that you have.  Also, this
probably hasn't been well tested yet.

Return-Path: rth@cygnus.com 
Received: from castro.cygnus.com (castro.cygnus.com [205.180.230.121])
	by runyon.cygnus.com (8.8.7-cygnus/8.8.7) with ESMTP id SAA17162;
	Tue, 16 May 2000 18:52:03 -0700 (PDT)
Received: (rth@localhost) by castro.cygnus.com (8.9.3/8.6.4) id SAA14025; Tue, 16 May 2000 18:52:03 -0700
Date: Tue, 16 May 2000 18:52:03 -0700
From: Richard Henderson <rth@cygnus.com>
To: gcc-patches@gcc.gnu.org
Cc: Jim Wilson <wilson@cygnus.com>
Subject: ia64 crtbegin/end changes
Message-ID: <20000516185203.A14018@cygnus.com>
Mime-Version: 1.0
X-Mailer: Mutt 1.0pre3us
Content-Type: text/plain; charset=us-ascii
Content-Length: 11447

The primary purpose of the patch is to make sure that we never
have an out of range branch in the .init/.fini fragements, 
since the thunks that the linker would inject would break the
flow of the composite function.


r~

        * config/ia64/crtbegin.asm (__dso_handle): Mark hidden if the
        assembler supports it.
        (.fini, .init): Use a gp-relative indirect call.
        (__do_global_dtors_aux): Preserve the gp; rebundle.
        (__do_frame_setup): Likewise.
        * config/ia64/crtend.asm (.IA_64.unwind): Don't terminate with -1.
        (.init): Use a gp-relative indirect call.
        (__do_global_ctors_aux): Preserve the gp.

Index: config/ia64/crtbegin.asm
=================================RCS file: /cvs/gcc/egcs/gcc/config/ia64/crtbegin.asm,v
retrieving revision 1.2
diff -c -p -d -r1.2 crtbegin.asm
*** crtbegin.asm	2000/04/25 23:16:20	1.2
--- crtbegin.asm	2000/05/17 01:45:28
*************** __DTOR_LIST__:
*** 30,58 ****
  __EH_FRAME_BEGIN__:
  
  .section .sdata
- 5:	data8	@segrel(6f)
  	.type dtor_ptr#,@object
  	.size dtor_ptr#,8
  dtor_ptr:
  	data8	__DTOR_LIST__# + 8
  
! /* A handle for __cxa_finalize to manage c++ local destructors.  */
  	.global __dso_handle#
  	.type __dso_handle#,@object
  	.size __dso_handle#,8
  #ifdef SHARED
! .section .data
  __dso_handle:
  	data8	__dso_handle#
  #else
! .section .bss
  __dso_handle:
  	data8	0
  #endif
! 
! /* The frame object.  */
! /* ??? How can we rationally keep this size correct?  */
  
  .section .bss
  	.type frame_object#,@object
  	.size frame_object#,56
--- 30,64 ----
  __EH_FRAME_BEGIN__:
  
  .section .sdata
  	.type dtor_ptr#,@object
  	.size dtor_ptr#,8
  dtor_ptr:
  	data8	__DTOR_LIST__# + 8
  
! 	.type segrel_ofs#,@object
! 	.size segrel_ofs#,8
! segrel_ofs:
! 	data8	@segrel(.Lsegrel_ref#)
! 
! 	/* A handle for __cxa_finalize to manage c++ local destructors.  */
  	.global __dso_handle#
  	.type __dso_handle#,@object
  	.size __dso_handle#,8
  #ifdef SHARED
! 	.section .data
  __dso_handle:
  	data8	__dso_handle#
  #else
! 	.section .bss
  __dso_handle:
  	data8	0
  #endif
! #ifdef HAVE_GAS_HIDDEN
! 	.hidden __dso_handle#
! #endif
  
+ 	/* The frame object.  */
+ 	/* ??? How can we rationally keep this size correct?  */
  .section .bss
  	.type frame_object#,@object
  	.size frame_object#,56
*************** frame_object:
*** 63,82 ****
  /*
   * Fragment of the ELF _fini routine that invokes our dtor cleanup.
   *
!  * The code going into .fini is spread all over the place, thus we need
!  * to save gp in order to make sure that other bits don't get into any
!  * nasty surprises by expecting a gp that has suddenly changed.
   */
  .section .fini,"ax","progbits"
! 	{ .mfb
! 	  st8 [r12] = gp, -16
! 	  br.call.sptk.many b0 = __do_global_dtors_aux#
  	  ;;
  	}
! 	{ .mmi
! 	  adds r12 = 16, r12
  	  ;;
! 	  ld8 gp = [r12]
  	  ;;
  	}
  
--- 69,97 ----
  /*
   * Fragment of the ELF _fini routine that invokes our dtor cleanup.
   *
!  * We make the call by indirection, because in large programs the 
!  * .fini and .init sections are not in range of the destination, and
!  * we cannot allow the linker to insert a stub at the end of this
!  * fragment of the _fini function.  Further, Itanium does not implement
!  * the long branch instructions, and we do not wish every program to
!  * trap to the kernel for emulation.
!  *
!  * Note that we require __do_global_dtors_aux to preserve the GP,
!  * so that the next fragment in .fini gets the right value.
   */
  .section .fini,"ax","progbits"
! 	{ .mlx
! 	  movl r2 = @gprel(__do_global_dtors_aux#)
  	  ;;
  	}
! 	{ .mii
! 	  nop.m 0
! 	  add r2 = r2, gp
  	  ;;
! 	  mov b6 = r2
! 	}
! 	{ .bbb
! 	  br.call.sptk.many b0 = b6
  	  ;;
  	}
  
*************** frame_object:
*** 85,99 ****
   */
  
  .section .init,"ax","progbits"
! 	{ .mfb
! 	  st8 [r12] = gp, -16
! 	  br.call.sptk.many b0 = __do_frame_setup#
  	  ;;
  	}
! 	{ .mmi
! 	  adds r12 = 16, r12
  	  ;;
! 	  ld8 gp = [r12]
  	  ;;
  	}
  
--- 100,117 ----
   */
  
  .section .init,"ax","progbits"
! 	{ .mlx
! 	  movl r2 = @gprel(__do_frame_setup#)
  	  ;;
  	}
! 	{ .mii
! 	  nop.m 0
! 	  add r2 = r2, gp
  	  ;;
! 	  mov b6 = r2
! 	}
! 	{ .bbb
! 	  br.call.sptk.many b0 = b6
  	  ;;
  	}
  
*************** __do_global_dtors_aux:
*** 107,113 ****
  	  addl loc0 = @gprel(dtor_ptr#), gp
  	  mov loc1 = b0
  	}
! 	mov loc2 = gp
  #else
  	/*
  		if (__cxa_finalize)
--- 125,135 ----
  	  addl loc0 = @gprel(dtor_ptr#), gp
  	  mov loc1 = b0
  	}
! 	{ .mib
! 	  mov loc2 = gp
! 	  br.sptk.few 1f
! 	  ;;
! 	}
  #else
  	/*
  		if (__cxa_finalize)
*************** __do_global_dtors_aux:
*** 119,125 ****
  	  addl r16 = @ltoff(@fptr(__cxa_finalize#)), gp
  	  ;;
  	}
- 	mov loc2 = gp
  	{ .mmi
  	  ld8 r16 = [r16]
  	  ;;
--- 141,146 ----
*************** __do_global_dtors_aux:
*** 133,143 ****
  	  mov loc1 = b0
  	  ;;
  	}
! 	{ .mib
! (p7)	  ld8 gp = [r16]
  (p7)	  mov b6 = r18
  (p7)	  br.call.sptk.many b0 = b6
  	}
  #endif
  	/*
  		do {
--- 154,171 ----
  	  mov loc1 = b0
  	  ;;
  	}
! 	{ .mfi
! 	  mov loc2 = gp
  (p7)	  mov b6 = r18
+ 	}
+ 	{
+ 	  .mfb
+ (p7)	  ld8 gp = [r16]
  (p7)	  br.call.sptk.many b0 = b6
  	}
+ 	{ .mfb
+ 	  br.sptk.few 1f
+ 	}
  #endif
  	/*
  		do {
*************** __do_global_dtors_aux:
*** 145,154 ****
  		  (*(dtor_ptr-1)) ();
  		} while (dtor_ptr);
  	*/
- 	{ .bbb
- 	  br.sptk.few 1f
- 	  ;;
- 	}
  0:
  	{ .mmi
  	  st8 [loc0] = r15
--- 173,178 ----
*************** __do_global_dtors_aux:
*** 171,183 ****
  	  cmp.ne p6, p0 = r0, r16
  (p6)	  br.cond.sptk.few 0b
  	}
- 	mov gp = loc2
- 	;;
  	/*
  		if (__deregister_frame_info)
  		  __deregister_frame_info(__EH_FRAME_BEGIN__)
  	*/
! 	{ .mii
  	  addl r16 = @ltoff(@fptr(__deregister_frame_info#)), gp
  	  addl out0 = @ltoff(__EH_FRAME_BEGIN__#), gp
  	  ;;
--- 195,207 ----
  	  cmp.ne p6, p0 = r0, r16
  (p6)	  br.cond.sptk.few 0b
  	}
  	/*
  		if (__deregister_frame_info)
  		  __deregister_frame_info(__EH_FRAME_BEGIN__)
  	*/
! 	{ .mmi
! 	  mov gp = loc2
! 	  ;;
  	  addl r16 = @ltoff(@fptr(__deregister_frame_info#)), gp
  	  addl out0 = @ltoff(__EH_FRAME_BEGIN__#), gp
  	  ;;
*************** __do_global_dtors_aux:
*** 199,204 ****
--- 223,229 ----
  (p7)	  br.call.sptk.many b0 = b6
  	}
  	{ .mii
+ 	  mov gp = loc2
  	  mov b0 = loc1
  	  mov ar.pfs = loc3
  	}
*************** __do_frame_setup:
*** 215,259 ****
  		  __register_frame_info(__EH_FRAME_BEGIN__)
  	*/
  	{ .mii
! 	  alloc loc3 = ar.pfs, 0, 4, 2, 0
  	  addl r16 = @ltoff(@fptr(__register_frame_info#)), gp
  	  addl out0 = @ltoff(__EH_FRAME_BEGIN__#), gp
- 	  ;;
  	}
- 	addl out1 = @ltoff(frame_object#), gp
- 	;;
  	/* frame_object.pc_base = segment_base_offset;
! 	      pc_base is at offset 0 within frame_object.  */
! 6:
! 	mov loc0 = ip
! 	addl loc1 = @gprel(5b), gp
! 	;;
! 	ld8 loc1 = [loc1]
! 	ld8 out1 = [out1]
! 	;;
! 	sub loc2 = loc0, loc1
! 	;;
! 	st8 [out1] = loc2
  	{ .mmi
  	  ld8 r16 = [r16]
- 	  ld8 out0 = [out0]  
  	  mov loc0 = b0
  	  ;;
  	}
! 	{ .mmi
  	  cmp.ne p7, p0 = r0, r16
  	  ;;
  (p7)	  ld8 r18 = [r16], 8
  	  ;;
  	}
  	{ .mib
  (p7)	  ld8 gp = [r16]
  (p7)	  mov b6 = r18
  (p7)	  br.call.sptk.many b0 = b6
  	}
  	{ .mii
  	  mov b0 = loc0
! 	  mov ar.pfs = loc3
  	}
  	{ .bbb
  	  br.ret.sptk.many b0
--- 240,289 ----
  		  __register_frame_info(__EH_FRAME_BEGIN__)
  	*/
  	{ .mii
! 	  alloc loc2 = ar.pfs, 0, 3, 2, 0
  	  addl r16 = @ltoff(@fptr(__register_frame_info#)), gp
  	  addl out0 = @ltoff(__EH_FRAME_BEGIN__#), gp
  	}
  	/* frame_object.pc_base = segment_base_offset;
! 	   pc_base is at offset 0 within frame_object.  */
! .Lsegrel_ref:
! 	{ .mmi
! 	  addl out1 = @ltoff(frame_object#), gp
! 	  ;;
! 	  addl r2 = @gprel(segrel_ofs#), gp
! 	  mov r3 = ip
! 	  ;;
! 	}
  	{ .mmi
+ 	  ld8 r2 = [r2]
  	  ld8 r16 = [r16]
  	  mov loc0 = b0
  	  ;;
  	}
! 	{ .mii
! 	  ld8 out1 = [out1]
  	  cmp.ne p7, p0 = r0, r16
+ 	  sub r3 = r3, r2
  	  ;;
+ 	}
+ 	{ .mmi
+ 	  st8 [out1] = r3 
  (p7)	  ld8 r18 = [r16], 8
+ 	  mov loc1 = gp
  	  ;;
  	}
+ 	{ .mfb
+ 	  ld8 out0 = [out0]  
+ 	}
  	{ .mib
  (p7)	  ld8 gp = [r16]
  (p7)	  mov b6 = r18
  (p7)	  br.call.sptk.many b0 = b6
  	}
  	{ .mii
+ 	  mov gp = loc1
  	  mov b0 = loc0
! 	  mov ar.pfs = loc2
  	}
  	{ .bbb
  	  br.ret.sptk.many b0
Index: config/ia64/crtend.asm
=================================RCS file: /cvs/gcc/egcs/gcc/config/ia64/crtend.asm,v
retrieving revision 1.2
diff -c -p -d -r1.2 crtend.asm
*** crtend.asm	2000/04/25 23:16:20	1.2
--- crtend.asm	2000/05/17 01:45:28
*************** __DTOR_END__:
*** 28,52 ****
  
  .section .IA_64.unwind
  __EH_FRAME_END__:
- 	data8	-1
  
  /*
   * Fragment of the ELF _init routine that invokes our dtor cleanup.
   *
!  * The code going into .init is spread all over the place, thus we need
!  * to save gp in order to make sure that other bits don't get into any
!  * nasty surprises by expecting a gp that has suddenly changed.
   */
  .section .init,"ax","progbits"
! 	{ .mfb
! 	  st8 [r12] = gp, -16
! 	  br.call.sptk.many b0 = __do_global_ctors_aux
  	  ;;
  	}
! 	{ .mmi
! 	  adds r12 = 16, r12
  	  ;;
! 	  ld8 gp = [r12]
  	  ;;
  	}
  
--- 28,60 ----
  
  .section .IA_64.unwind
  __EH_FRAME_END__:
  
  /*
   * Fragment of the ELF _init routine that invokes our dtor cleanup.
   *
!  * We make the call by indirection, because in large programs the 
!  * .fini and .init sections are not in range of the destination, and
!  * we cannot allow the linker to insert a stub at the end of this
!  * fragment of the _fini function.  Further, Itanium does not implement
!  * the long branch instructions, and we do not wish every program to
!  * trap to the kernel for emulation.
!  *
!  * Note that we require __do_global_ctors_aux to preserve the GP,
!  * so that the next fragment in .fini gets the right value.
   */
  .section .init,"ax","progbits"
! 	{ .mlx
! 	  movl r2 = @gprel(__do_global_ctors_aux#)
  	  ;;
  	}
! 	{ .mii
! 	  nop.m 0
! 	  add r2 = r2, gp
  	  ;;
! 	  mov b6 = r2
! 	}
! 	{ .bbb
! 	  br.call.sptk.many b0 = b6
  	  ;;
  	}
  
*************** __do_global_ctors_aux:
*** 59,92 ****
  		  (*p) ();
  	*/
  	{ .mii
! 	  alloc loc2 = ar.pfs, 0, 4, 0, 0
  	  addl loc0 = @ltoff(__CTOR_END__# - 8), gp
! 	  cmp.ne p6, p0 = r0, r0
  	  ;;
  	}
! 	{ .mfi
  	  ld8 loc0 = [loc0]
! 	  mov loc1 = b0
  	}
  0:
  	{ .mmi
! (p6)	  ld8 r15 = [loc3], 8
  	  ;;
! (p6)	  ld8 gp = [loc3]
! (p6)	  mov b6 = r15
  	}
  	{ .mfb
  	  ld8 loc3 = [loc0], -8
! (p6)	  br.call.sptk.many b0 = b6
  	  ;;
  	}
  	{ .mfb
  	  cmp.ne p6, p0 = -1, loc3
  (p6)	  br.cond.sptk.few 0b
  	}
  	{ .mii
! 	  mov ar.pfs = loc2
  	  mov b0 = loc1
  	}
  	{ .bbb
  	  br.ret.sptk.many b0
--- 67,109 ----
  		  (*p) ();
  	*/
  	{ .mii
! 	  alloc loc4 = ar.pfs, 0, 5, 0, 0
  	  addl loc0 = @ltoff(__CTOR_END__# - 8), gp
! 	  mov loc1 = b0
  	  ;;
  	}
! 	{ .mmi
  	  ld8 loc0 = [loc0]
! 	  ;;
! 	  ld8 loc3 = [loc0], -8
! 	  mov loc2 = gp
! 	  ;;
  	}
+ 	{ .mfb
+ 	  cmp.eq p6, p0 = -1, loc3
+ (p6)	  br.cond.spnt.few 2f
+ 	}
  0:
  	{ .mmi
! 	  ld8 r15 = [loc3], 8
  	  ;;
! 	  ld8 gp = [loc3]
! 	  mov b6 = r15
  	}
  	{ .mfb
  	  ld8 loc3 = [loc0], -8
! 	  br.call.sptk.many b0 = b6
  	  ;;
  	}
  	{ .mfb
  	  cmp.ne p6, p0 = -1, loc3
  (p6)	  br.cond.sptk.few 0b
  	}
+ 2:
  	{ .mii
! 	  mov gp = loc2
  	  mov b0 = loc1
+ 	  mov ar.pfs = loc4
  	}
  	{ .bbb
  	  br.ret.sptk.many b0


