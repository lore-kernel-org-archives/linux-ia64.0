From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 06 May 2004 05:15:56 +0000
Subject: [PATCH] new ".serialize" gas directive
Message-Id: <16537.51724.854691.934006@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi HJ,

I finally got tired of those spurious dependency-violation warnings
which occur when compiling the Linux kernel.  I believe you're
planning to fix some of the DV problems in other ways, but a few of
the spurious warnings are difficult to handle even with a perfect
assembler.  For example, the perfmon code writes to a data-breakpoint
register (without "srlz.d") and then GAS complains about all
subsequent stores.  The complaint is valid _unless_ you know that the
breakpoint isn't actually enabled.  So rather than trying to have all
kinds of complicated logic to handle these special cases, I decided to
add ".serialize.instruction" and ".serialize.data" directives which,
for DV-purposes, behave exactly like:

	;; srlz.i ;;
and

	;; srlz.d ;;

respectively, except that they don't actually insert any stop-bits or
(slow) serialization instructions.

After applying the attached patch to GAS, I had to add about eight
.serialize.data directives to the kernel and now there are no more
spurious warnings except for this one:

{standard input}: Assembler messages:
{standard input}:6117: Warning: Use of 'mov' may violate WAW dependency 'GR%, %
in 1 - 127' (impliedf), specific resource number is 14
{standard input}:6117: Warning: Only the first path encountering the conflict is
 reported
{standard input}:6116: Warning: This is the location of the conflicting usage

This one comes from plain C code (mm/vmscan.c):

	tbit.z p34, p35 = r22, 12	;;
	(p34) cmp4.eq p6, p7 = 2, r15
	(p35) cmp4.eq p6, p7 = 3, r15	;;
	(p6) addl r14 = 1, r0
	(p7) mov r14 = r0

I'm not sure whether GCC ought to be emitting .pred.rel.mutex p6,p7 or
whether GAS is supposed to be smart enough to figure this out on its
own.

In any case, if you think this patch is acceptable, would you mind
checking it into binutils?

Thanks,

	--david

ChangeLog

2004-05-05  David Mosberger-Tang  <davidm@hpl.hp.com>

	* config/tc-ia64.c (dot_serialize): Declare.
	(dot_serialize): New function.
	(md_pseudo_table): Add ".serialize.data" and
	".serialize.instruction" directives.

Index: config/tc-ia64.c
=================================RCS file: /cvs/src/src/gas/config/tc-ia64.c,v
retrieving revision 1.108
diff -u -r1.108 tc-ia64.c
--- config/tc-ia64.c	4 May 2004 14:58:11 -0000	1.108
+++ config/tc-ia64.c	6 May 2004 05:01:49 -0000
@@ -750,6 +750,7 @@
 static void print_prmask PARAMS ((valueT mask));
 static void dot_pred_rel PARAMS ((int));
 static void dot_reg_val PARAMS ((int));
+static void dot_serialize PARAMS ((int));
 static void dot_dv_mode PARAMS ((int));
 static void dot_entry PARAMS ((int));
 static void dot_mem_offset PARAMS ((int));
@@ -4651,6 +4652,23 @@
   demand_empty_rest_of_line ();
 }
 
+/*
+  .serialize.data
+  .serialize.instruction
+ */
+static void
+dot_serialize (type)
+     int type;
+{
+  insn_group_break (0, 0, 0);
+  if (type)
+    instruction_serialization ();
+  else
+    data_serialization ();
+  insn_group_break (0, 0, 0);
+  demand_empty_rest_of_line ();
+}
+
 /* select dv checking mode
    .auto
    .explicit
@@ -5033,6 +5051,8 @@
     { "pred.rel.mutex", dot_pred_rel, 'm' },
     { "pred.safe_across_calls", dot_pred_rel, 's' },
     { "reg.val", dot_reg_val, 0 },
+    { "serialize.data", dot_serialize, 0 },
+    { "serialize.instruction", dot_serialize, 1 },
     { "auto", dot_dv_mode, 'a' },
     { "explicit", dot_dv_mode, 'e' },
     { "default", dot_dv_mode, 'd' },
