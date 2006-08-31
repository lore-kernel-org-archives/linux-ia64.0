From: Jack Steiner <steiner@sgi.com>
Date: Thu, 31 Aug 2006 16:34:47 +0000
Subject: [PATCH] - Save register stack contents on cpu start
Message-Id: <20060831163447.GA28508@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The SN PROM uses the register stack in the slave loop. The contents 
must be preserved for the OS to return to the slave loop via offlining 
a cpu or for kexec. A 'flushrs" is needed to force the stack to be written
to memory prior to changing bspstore.



	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/kernel/head.S
=================================--- linux.orig/arch/ia64/kernel/head.S	2006-08-31 11:14:49.000000000 -0500
+++ linux/arch/ia64/kernel/head.S	2006-08-31 11:20:37.405590270 -0500
@@ -197,6 +197,11 @@ start_ap:
 	;;
 	srlz.i
 	;;
+ {
+	flushrs				// must be first insn in group
+	srlz.i
+ }
+	;;
 	/*
 	 * Save the region registers, predicate before they get clobbered
 	 */
