From: Jim Wilson <wilson@cygnus.com>
Date: Sat, 17 Mar 2001 05:00:26 +0000
Subject: Re: [Linux-ia64] .auto directive appears broken for IA-64 assembler
Message-Id: <marc-linux-ia64-105590693005295@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005270@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005270@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Technically, the .auto directive is working fine.  It is the dependency
violation support that is broken here.

Both bugs are problems with parsing the resource and dependency tables
from Appendix 2 of Volume II of the PRM.

The problem with post-inc stores is that we didn't support the M5 format
check used in the st-postinc instruction class.  The result is that when
you had a pair of instructions, with the post-inc store as the second one, then
we did detect the DV.  But if you had a pair of instruction, with the post-inc
store as the first one, then we did not detect the DV.

The problem with dep is that we were a little sloppy with string searches,
and ended up treating "dep\dep[Format in {I3}]" as if it was
"dep[Format in {I3}]\dep[Format in {I3}]".  So this is supposed to be all
dep instructions except Format I3 deps (zero_form,imm_form), but we
accidentally handled it as only Format I3 deps.  The result is that we never
did DV checks for input registers of the other dep instructions.

By the way, there are known to be a number of other problems with the DV
code, mostly with handling complicated predicated relations.  I've got a
bunch of patches and testcases from Intel that I'm going through, but that
work has been stalled for a while now as I've been so busy responding to
new bug reports, new patches for review, questions, etc.

Here is the opcodes patch for these two bugs.  This also requires
regenerating ia64-asmtab.c, but I did not include that as it is almost 60K.

Oops, I just noticed I have a duplicate comment.  I will fix that before I
check it in.  If I am feeling up to it, I'll write some new testcases
for the gas testsuite also.

2001-03-16  Jim Wilson  <wilson@redhat.com>

	* ia64-gen.c (fetch_insn_class): If xsect, then ignore comment and
	notestr if larger than xsect.
	(in_class): Handle format M5.
	* ia64-asmtab.c: Regnerate.

Index: ia64-gen.c
=================================RCS file: /cvs/src/src/opcodes/ia64-gen.c,v
retrieving revision 1.7
diff -p -r1.7 ia64-gen.c
*** ia64-gen.c	2001/03/13 22:58:35	1.7
--- ia64-gen.c	2001/03/17 04:05:00
*************** fetch_insn_class(const char *full_name, 
*** 399,407 ****
    if ((comment = strchr(name, '[')) != NULL)
      is_class = 1;
    if ((notestr = strchr(name, '+')) != NULL)
      {
        char *nextnotestr;
-       is_class = 1;
        note = atoi (notestr + 1);
        if ((nextnotestr = strchr (notestr + 1, '+')) != NULL)
          {
--- 399,421 ----
    if ((comment = strchr(name, '[')) != NULL)
      is_class = 1;
    if ((notestr = strchr(name, '+')) != NULL)
+     is_class = 1;
+ 
+   /* If it is a composite class, then ignore comments and notes that come after
+      the '\\', since they don't apply to the part we are decoding now.  */
+   if (xsect)
+     {
+       /* Ignore comments and notes that come after the \, since they don't
+ 	 apply to the part we are decoding now.  */
+       if (comment > xsect)
+ 	comment = 0;
+       if (notestr > xsect)
+ 	notestr = 0;
+     }
+ 
+   if (notestr)
      {
        char *nextnotestr;
        note = atoi (notestr + 1);
        if ((nextnotestr = strchr (notestr + 1, '+')) != NULL)
          {
*************** fetch_insn_class(const char *full_name, 
*** 413,420 ****
          }
      }
  
!   /* if it's a composite class, leave the notes and comments in place so that
!      we have a unique name for the composite class */
    if (!xsect)
      {
        if (notestr)
--- 427,435 ----
          }
      }
  
!   /* If it's a composite class, leave the notes and comments in place so that
!      we have a unique name for the composite class.  Otherwise, we remove
!      them.  */
    if (!xsect)
      {
        if (notestr)
*************** in_iclass(struct ia64_opcode *idesc, str
*** 1055,1060 ****
--- 1070,1078 ----
              resolved = idesc->operands[0] = IA64_OPND_B2;
            else if (strcmp (ic->name, "invala") = 0)
              resolved = strcmp (idesc->name, ic->name) = 0;
+ 	  else if (strncmp (idesc->name, "st", 2) = 0
+ 		   && strstr (format, "M5") != NULL)
+ 	    resolved = idesc->flags & IA64_OPCODE_POSTINC;
            else
              resolved = 0;
          }

