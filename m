From: Kyle McMartin <kyle@engsoc.carleton.ca>
Date: Wed, 19 Nov 2003 16:42:16 +0000
Subject: [PATCH] remove unimplemented syscalls noise
MIME-Version: 1
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
Message-Id: <marc-linux-ia64-106926030617023@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi guys, this is a simple patch which removes the really
irritating sc<> messages that appear in logs. I haven't seen
any reason to keep the messages, as they appear to be
superfluous since the fact that some processes spit it doesn't
effect their operation.

Regards,
--
Kyle McMartin <kyle@engsoc.carleton.ca>
System Administrator, The EngSoc Project
Faculty of Engineering, Carleton University

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ia64-traps.c.diff"

--- arch/ia64/kernel/traps.c.orig	2003-11-16 12:58:50.483531475 -0500
+++ arch/ia64/kernel/traps.c	2003-11-16 12:59:55.443491617 -0500
@@ -225,10 +225,6 @@
 		 unsigned long arg4, unsigned long arg5, unsigned long arg6, unsigned long arg7,
 		 unsigned long stack)
 {
-	struct pt_regs *regs = (struct pt_regs *) &stack;
-
-	printk(KERN_DEBUG "%s(%d): <sc%ld(%lx,%lx,%lx,%lx)>\n", current->comm, current->pid,
-	       regs->r15, arg0, arg1, arg2, arg3);
 	return -ENOSYS;
 }
 

--X1bOJ3K7DJ5YkBrT--
