From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 17 Feb 2001 20:39:22 +0000
Subject: [Linux-ia64] gas fix for .restore directive
Message-Id: <marc-linux-ia64-105590693005170@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached patch fixes a typo in the ".restore" directive and brings
it in line with the Assembly Language Reference Manual.  According to
the manual, the directive:

	.restore sp

should pop all open regions (i.e., ecount = # of prologues - 1) and

	.restore sp, N

sets the ecount field to N.  Unfortunately, I couldn't cross-check
this against the Intel assembler because, no matter what I tried, it
always complained about "illegal operand combination for .RESTORE".

The patch is relative to the CVS tree, but applies cleanly on top
of the Nov 17 toolchain as well.

Jim or Rich, could you look over it and apply it if it looks OK?

Thanks,

	--david

2001-02-17  David Mosberger  <davidm@hpl.hp.com>

	* config/tc-ia64.c (struct unwind): Add member "prologue_count".
	(dot_proc): Clear unwind.prologue_count to zero.
	(dot_prologue): Increment unwind.prologue_count.
	(dot_restore): If second operand is omitted, use
	unwind.prologue_count -1 for "ecount" (# of additional regions to
	pop).  Decrement unwind.prologue_count by number of regions
	popped.

Index: config/tc-ia64.c
=================================RCS file: /cvs/src/src/gas/config/tc-ia64.c,v
retrieving revision 1.41
diff -u -r1.41 tc-ia64.c
--- tc-ia64.c	2001/02/10 01:42:04	1.41
+++ tc-ia64.c	2001/02/17 20:16:18
@@ -624,6 +624,7 @@
   /* TRUE if processing unwind directives in a prologue region.  */
   int prologue;
   int prologue_mask;
+  unsigned int prologue_count;	/* number of .prologues seen so far */
 } unwind;
 
 typedef void (*vbyte_func) PARAMS ((int, char *, char *));
@@ -3047,7 +3048,7 @@
      int dummy ATTRIBUTE_UNUSED;
 {
   expressionS e1, e2;
-  unsigned long ecount = 0;
+  unsigned long ecount;	/* # of _additional_ regions to pop */
   int sep;
 
   sep = parse_operand (&e1);
@@ -3060,14 +3061,21 @@
   if (sep = ',')
     {
       parse_operand (&e2);
-      if (e1.X_op != O_constant)
+      if (e2.X_op != O_constant || e2.X_add_number < 0)
 	{
-	  as_bad ("Second operand to .restore must be constant");
+	  as_bad ("Second operand to .restore must be a constant >= 0");
 	  return;
 	}
-      ecount = e1.X_op;
+      ecount = e2.X_add_number;
     }
+  else
+    ecount = unwind.prologue_count - 1;
   add_unwind_entry (output_epilogue (ecount));
+
+  if (ecount < unwind.prologue_count)
+    unwind.prologue_count -= ecount + 1;
+  else
+    unwind.prologue_count = 0;
 }
 
 static void
@@ -3710,6 +3718,7 @@
   demand_empty_rest_of_line ();
   ia64_do_align (16);
 
+  unwind.prologue_count = 0;
   unwind.list = unwind.tail = unwind.current_entry = NULL;
   unwind.personality_routine = 0;
 }
@@ -3764,6 +3773,7 @@
 
   unwind.prologue = 1;
   unwind.prologue_mask = mask;
+  ++unwind.prologue_count;
 }
 
 static void

