From: Jim Wilson <wilson@cygnus.com>
Date: Fri, 01 Sep 2000 22:08:30 +0000
Subject: [Linux-ia64] toolchain patch.010 for tcl miscompilation
Message-Id: <marc-linux-ia64-105590678205443@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The file tcl/generic/tclCompExpr.c was being miscompiled at -O2 due to
a strength reduction bug.  This showed up as a gcc "make check" failure
if the toolchain was built with itself.  I've added the following patch
to fix this problem.

2000-09-01  Jim Wilson  <wilson@cygnus.com>

	* loop.c (check_final_value): Check for biv use before checking for
	giv use.  Check for both biv and giv uses.  Always set last_giv_use
	if there is a giv use.

Index: loop.c
=================================RCS file: /cvs/gcc/egcs/gcc/loop.c,v
retrieving revision 1.277
diff -p -r1.277 loop.c
*** loop.c	2000/08/29 19:15:26	1.277
--- loop.c	2000/09/01 21:53:40
*************** check_final_value (loop, v)
*** 5677,5695 ****
  	  if (GET_CODE (p) = INSN || GET_CODE (p) = JUMP_INSN
  	      || GET_CODE (p) = CALL_INSN)
  	    {
! 	      if (biv_increment_seen)
  		{
! 		  if (reg_mentioned_p (v->dest_reg, PATTERN (p)))
  		    {
  		      v->replaceable = 0;
  		      v->not_replaceable = 1;
  		      break;
  		    }
  		}
- 	      else if (reg_set_p (v->src_reg, PATTERN (p)))
- 		biv_increment_seen = 1;
- 	      else if (reg_mentioned_p (v->dest_reg, PATTERN (p)))
- 		last_giv_use = p;
  	    }
  	}
  
--- 5677,5701 ----
  	  if (GET_CODE (p) = INSN || GET_CODE (p) = JUMP_INSN
  	      || GET_CODE (p) = CALL_INSN)
  	    {
! 	      /* It is possible for the BIV increment to use the GIV if we
! 		 have a cycle.  Thus we must be sure to check each insn for
! 		 both BIV and GIV uses, and we must check for BIV uses
! 		 first.  */
! 
! 	      if (! biv_increment_seen
! 		  && reg_set_p (v->src_reg, PATTERN (p)))
! 		biv_increment_seen = 1;
! 		
! 	      if (reg_mentioned_p (v->dest_reg, PATTERN (p)))
  		{
! 		  if (biv_increment_seen)
  		    {
  		      v->replaceable = 0;
  		      v->not_replaceable = 1;
  		      break;
  		    }
+ 		  last_giv_use = p;
  		}
  	    }
  	}
  

