From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 27 Apr 2001 03:56:09 +0000
Subject: [Linux-ia64] [PATCH] gas fix for .spillsp.p/.spillpsp.p directives
Message-Id: <marc-linux-ia64-105590693005481@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The attached patch fixes a bug in the gas .spillsp.p/.spillpsp.p
directives.  Could someone check this into the official binutils
tree?

Thanks,

	--david

2001-04-26  David Mosberger  <davidm@hpl.hp.com>

	* config/tc-ia64.c (dot_spillmem_p): Fix output_spill_?sprel_p()
	argument passing order: predicate goes last, not first.

Index: config/tc-ia64.c
=================================RCS file: /cvs/src/src/gas/config/tc-ia64.c,v
retrieving revision 1.48
diff -u -r1.48 tc-ia64.c
--- config/tc-ia64.c	2001/04/14 03:51:40	1.48
+++ config/tc-ia64.c	2001/04/27 03:53:23
@@ -3613,9 +3613,9 @@
     }
 
   if (psprel)
-    add_unwind_entry (output_spill_psprel_p (qp, ab, reg, e3.X_add_number));
+    add_unwind_entry (output_spill_psprel_p (ab, reg, e3.X_add_number, qp));
   else
-    add_unwind_entry (output_spill_sprel_p (qp, ab, reg, e3.X_add_number));
+    add_unwind_entry (output_spill_sprel_p (ab, reg, e3.X_add_number, qp));
 }
 
 static void

