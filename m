From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 01 Sep 2000 22:44:39 +0000
Subject: [Linux-ia64] toolchain patch.011 to eliminate some false DV warnings
Message-Id: <marc-linux-ia64-105590678205444@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This eliminates some false DV warnings that can occur when gcc generates
a predicated call to a function that does not return.

Here is a simple testcase for that.  This gets false DV warnings when compiled
with -O2.

#include <stdlib.h>

sub (int i, int k)
{
  int j = i ? 1 : 0;
  int a;

  if (k)
    abort ();

  a = i ? 3 : 2;

  sub2 (a);
  return j;
}

2000-09-01  Jim Wilson  <wilson@cygnus.com>

	* calls.c (emit_call_1): Add REG_NORETURN note to call if ECF_NORETURN.
	* combine.c (distribute_notes): Handle REG_NORETURN.
	* rtl.c (reg_note_name): Add REG_NORETURN.
	* rtl.h (enum reg_note): Likewise.

	* config/ia64/ia64-protos.h (emit_safe_across_calls): Renamed from
	ia64_file_start.
	* config/ia64/ia64.c (emit_safe_across_calls): Likewise.
	(rtx_needs_barrier): Handle unspec_volatile 8 and 9.
	(emit_predicate_relation_info): Handle conditional calls with
	REG_NORETURN.
	* config/ia64/ia64.h (ASM_FILE_START): Call emit_safe_across_calls
	instead of ia64_file_start.
	* config/ia64/sysv4.h (ASM_FILE_START): Likewise.
	* config/ia64/ia64.md (safe_across_calls_all,
	save_across_calls_normal): New patterns.

Index: calls.c
=================================RCS file: /cvs/cvsfiles/devo/gcc/calls.c,v
retrieving revision 1.190
diff -p -r1.190 calls.c
*** calls.c	2000/07/14 17:44:00	1.190
--- calls.c	2000/09/01 22:26:40
*************** emit_call_1 (funexp, fndecl, funtype, st
*** 586,591 ****
--- 586,595 ----
      REG_NOTES (call_insn) = gen_rtx_EXPR_LIST (REG_EH_REGION, const0_rtx,
  					       REG_NOTES (call_insn));
  
+   if (ecf_flags & ECF_NORETURN)
+     REG_NOTES (call_insn) = gen_rtx_EXPR_LIST (REG_NORETURN, const0_rtx,
+ 					       REG_NOTES (call_insn));
+ 
    SIBLING_CALL_P (call_insn) = ((ecf_flags & ECF_SIBCALL) != 0);
  
    /* Restore this now, so that we do defer pops for this call's args
Index: combine.c
=================================RCS file: /cvs/cvsfiles/devo/gcc/combine.c,v
retrieving revision 1.228.2.1
diff -p -r1.228.2.1 combine.c
*** combine.c	2000/08/19 19:10:32	1.228.2.1
--- combine.c	2000/09/01 22:26:40
*************** distribute_notes (notes, from_insn, i3, 
*** 12022,12027 ****
--- 12022,12028 ----
  
  	case REG_EH_REGION:
  	case REG_EH_RETHROW:
+ 	case REG_NORETURN:
  	  /* These notes must remain with the call.  It should not be
  	     possible for both I2 and I3 to be a call.  */
  	  if (GET_CODE (i3) = CALL_INSN) 
Index: rtl.c
=================================RCS file: /cvs/cvsfiles/devo/gcc/rtl.c,v
retrieving revision 1.77
diff -p -r1.77 rtl.c
*** rtl.c	2000/07/14 17:46:05	1.77
--- rtl.c	2000/09/01 22:26:40
*************** const char * const reg_note_name[] *** 262,268 ****
    "REG_LABEL", "REG_DEP_ANTI", "REG_DEP_OUTPUT", "REG_BR_PROB",
    "REG_EXEC_COUNT", "REG_NOALIAS", "REG_SAVE_AREA", "REG_BR_PRED",
    "REG_FRAME_RELATED_EXPR", "REG_EH_CONTEXT", "REG_EH_REGION",
!   "REG_EH_RETHROW", "REG_SAVE_NOTE"
  };
  
  static void fatal_with_file_and_line PARAMS ((FILE *, const char *, ...))
--- 262,268 ----
    "REG_LABEL", "REG_DEP_ANTI", "REG_DEP_OUTPUT", "REG_BR_PROB",
    "REG_EXEC_COUNT", "REG_NOALIAS", "REG_SAVE_AREA", "REG_BR_PRED",
    "REG_FRAME_RELATED_EXPR", "REG_EH_CONTEXT", "REG_EH_REGION",
!   "REG_EH_RETHROW", "REG_SAVE_NOTE", "REG_NORETURN"
  };
  
  static void fatal_with_file_and_line PARAMS ((FILE *, const char *, ...))
Index: rtl.h
=================================RCS file: /cvs/cvsfiles/devo/gcc/rtl.h,v
retrieving revision 1.161.2.1
diff -p -r1.161.2.1 rtl.h
*** rtl.h	2000/07/28 19:57:48	1.161.2.1
--- rtl.h	2000/09/01 22:26:40
*************** enum reg_note
*** 523,529 ****
    REG_EH_RETHROW,
  
    /* Used by haifa-sched to save NOTE_INSN notes across scheduling.  */
!   REG_SAVE_NOTE
  };
  
  /* The base value for branch probability notes.  */
--- 523,532 ----
    REG_EH_RETHROW,
  
    /* Used by haifa-sched to save NOTE_INSN notes across scheduling.  */
!   REG_SAVE_NOTE,
! 
!   /* Indicates that a call does not return.  */
!   REG_NORETURN
  };
  
  /* The base value for branch probability notes.  */
Index: config/ia64/ia64-protos.h
=================================RCS file: /cvs/cvsfiles/devo/gcc/config/ia64/ia64-protos.h,v
retrieving revision 1.16.2.7
diff -p -r1.16.2.7 ia64-protos.h
*** ia64-protos.h	2000/08/24 21:51:17	1.16.2.7
--- ia64-protos.h	2000/09/01 22:26:41
*************** extern void ia64_encode_section_info PAR
*** 118,124 ****
  
  extern int ia64_register_move_cost PARAMS((enum reg_class, enum reg_class));
  extern int ia64_epilogue_uses PARAMS((int));
! extern void ia64_file_start PARAMS((FILE *));
  extern void ia64_output_end_prologue PARAMS((FILE *));
  extern void ia64_init_builtins PARAMS((void));
  extern void ia64_override_options PARAMS((void));
--- 118,124 ----
  
  extern int ia64_register_move_cost PARAMS((enum reg_class, enum reg_class));
  extern int ia64_epilogue_uses PARAMS((int));
! extern void emit_safe_across_calls PARAMS((FILE *));
  extern void ia64_output_end_prologue PARAMS((FILE *));
  extern void ia64_init_builtins PARAMS((void));
  extern void ia64_override_options PARAMS((void));
Index: config/ia64/ia64.c
=================================RCS file: /cvs/cvsfiles/devo/gcc/config/ia64/ia64.c,v
retrieving revision 1.71.2.13
diff -p -r1.71.2.13 ia64.c
*** ia64.c	2000/08/25 22:43:38	1.71.2.13
--- ia64.c	2000/09/01 22:26:41[
*************** spill_tfmode_operand (in, force)
*** 984,990 ****
  /* Begin the assembly file.  */
  
  void
! ia64_file_start (f)
       FILE *f;
  {
    unsigned int rs, re;
--- 984,990 ----
  /* Begin the assembly file.  */
  
  void
! emit_safe_across_calls (f)
       FILE *f;
  {
    unsigned int rs, re;
*************** rtx_needs_barrier (x, flags, pred)
*** 4003,4008 ****
--- 4003,4010 ----
            break;
  
  	case 7: /* pred.rel.mutex */
+ 	case 8: /* safe_across_calls all */
+ 	case 9: /* safe_across_calls normal */
  	  return 0;
  
  	default:
*************** emit_predicate_relation_info (insns)
*** 4248,4253 ****
--- 4250,4284 ----
  	      bb->end = n;
  	    head = n;
  	  }
+     }
+ 
+   /* Look for conditional calls that do not return, and protect predicate
+      relations around them.  Otherwise the assembler will assume the call
+      returns, and complain about uses of call-clobbered predicates after
+      the call.  */
+   for (i = n_basic_blocks - 1; i >= 0; --i)
+     {
+       basic_block bb = BASIC_BLOCK (i);
+       rtx insn = bb->head;
+       
+       while (1)
+ 	{
+ 	  if (GET_CODE (insn) = CALL_INSN
+ 	      && GET_CODE (PATTERN (insn)) = COND_EXEC
+ 	      && find_reg_note (insn, REG_NORETURN, NULL_RTX))
+ 	    {
+ 	      rtx b = emit_insn_before (gen_safe_across_calls_all (), insn);
+ 	      rtx a = emit_insn_after (gen_safe_across_calls_normal (), insn);
+ 	      if (bb->head = insn)
+ 		bb->head = b;
+ 	      if (bb->end = insn)
+ 		bb->end = a;
+ 	    }
+ 	  
+ 	  if (insn = bb->end)
+ 	    break;
+ 	  insn = NEXT_INSN (insn);
+ 	}
      }
  }
  
Index: config/ia64/ia64.h
=================================RCS file: /cvs/cvsfiles/devo/gcc/config/ia64/ia64.h,v
retrieving revision 1.71.2.14
diff -p -r1.71.2.14 ia64.h
*** ia64.h	2000/08/25 22:43:38	1.71.2.14
--- ia64.h	2000/09/01 22:26:41
*************** do {									\
*** 1478,1484 ****
  /* Output at beginning of assembler file.  */
  
  #define ASM_FILE_START(FILE) \
!   ia64_file_start (FILE)
  
  /* A C compound statement that outputs the assembler code for a thunk function,
     used to implement C++ virtual function calls with multiple inheritance.  */
--- 1478,1484 ----
  /* Output at beginning of assembler file.  */
  
  #define ASM_FILE_START(FILE) \
!   emit_safe_across_calls (FILE)
  
  /* A C compound statement that outputs the assembler code for a thunk function,
     used to implement C++ virtual function calls with multiple inheritance.  */
Index: config/ia64/ia64.md
=================================RCS file: /cvs/cvsfiles/devo/gcc/config/ia64/ia64.md,v
retrieving revision 1.69.2.13
diff -p -r1.69.2.13 ia64.md
*** ia64.md	2000/08/24 21:51:17	1.69.2.13
--- ia64.md	2000/09/01 22:26:41
***************
*** 70,75 ****
--- 70,77 ----
  ;;	2	insn_group_barrier
  ;;	5	set_bsp
  ;;	7	pred.rel.mutex
+ ;;	8	pred.safe_across_calls all
+ ;;	9	pred.safe_across_calls normal
  
  ;; ::::::::::::::::::::
  ;; ::
***************
*** 3944,3946 ****
--- 3946,3967 ----
    ".pred.rel.mutex %0, %I0"
    [(set_attr "type" "unknown")
     (set_attr "predicable" "no")])
+ 
+ (define_insn "safe_across_calls_all"
+   [(unspec_volatile [(const_int 0)] 8)]
+   ""
+   ".pred.safe_across_calls p1-p63"
+   [(set_attr "type" "unknown")
+    (set_attr "predicable" "no")])
+ 
+ (define_insn "safe_across_calls_normal"
+   [(unspec_volatile [(const_int 0)] 9)]
+   ""
+   "*
+ {
+   emit_safe_across_calls (asm_out_file);
+   return \"\";
+ }"
+   [(set_attr "type" "unknown")
+    (set_attr "predicable" "no")])
+ 
Index: config/ia64/sysv4.h
=================================RCS file: /cvs/cvsfiles/devo/gcc/config/ia64/sysv4.h,v
retrieving revision 1.14.10.2
diff -p -r1.14.10.2 sysv4.h
*** sysv4.h	2000/08/08 10:02:40	1.14.10.2
--- sysv4.h	2000/09/01 22:26:41
*************** do {									\
*** 178,184 ****
  #define ASM_FILE_START(STREAM) \
  do {									\
    output_file_directive (STREAM, main_input_filename);			\
!   ia64_file_start(STREAM);						\
  } while (0)
  
  /* Case label alignment is handled by ADDR_VEC_ALIGN now.  */
--- 178,184 ----
  #define ASM_FILE_START(STREAM) \
  do {									\
    output_file_directive (STREAM, main_input_filename);			\
!   emit_safe_across_calls (STREAM);					\
  } while (0)
  
  /* Case label alignment is handled by ADDR_VEC_ALIGN now.  */

