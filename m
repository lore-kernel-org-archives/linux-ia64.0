From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 24 Mar 2004 20:50:52 +0000
Subject: [PATCH] name conflict with handle_exception()
Message-Id: <200403241350.52871.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I tried to build usb/gadget/file_storage.c (CONFIG_USB_FILE_STORAGE=y),
but it uses "handle_exception()" for its own purposes, which conflicts
with the ia64 definition.  ia64 only uses handle_exception() within
arch code, so it seems like we ought to rename it to be ia64-specific.
done_with_exception() looks similar, so I renamed it as well, although
there's no actual conflict.

(handle_exception): Rename to ia64_handle_exception().
(done_with_exception): Rename to ia64_done_with_exception().

=== arch/ia64/kernel/traps.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/traps.c	Tue Feb 10 19:51:27 2004
+++ edited/arch/ia64/kernel/traps.c	Wed Mar 24 12:40:30 2004
@@ -488,7 +488,7 @@
 			siginfo.si_isr = isr;
 			force_sig_info(sig, &siginfo, current);
 			return;
-		} else if (done_with_exception(regs))
+		} else if (ia64_done_with_exception(regs))
 			return;
 		sprintf(buf, "NaT consumption");
 		break;
=== arch/ia64/kernel/unaligned.c 1.19 vs edited ==--- 1.19/arch/ia64/kernel/unaligned.c	Thu Feb  5 14:31:57 2004
+++ edited/arch/ia64/kernel/unaligned.c	Wed Mar 24 13:05:41 2004
@@ -1486,7 +1486,7 @@
 	/* something went wrong... */
 	if (!user_mode(regs)) {
 		if (eh) {
-			handle_exception(regs, eh);
+			ia64_handle_exception(regs, eh);
 			goto done;
 		}
 		die_if_kernel("error during unaligned kernel access\n", regs, ret);
=== arch/ia64/mm/extable.c 1.8 vs edited ==--- 1.8/arch/ia64/mm/extable.c	Tue Jan 27 22:23:13 2004
+++ edited/arch/ia64/mm/extable.c	Wed Mar 24 12:41:13 2004
@@ -81,7 +81,7 @@
 }
 
 void
-handle_exception (struct pt_regs *regs, const struct exception_table_entry *e)
+ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e)
 {
 	long fix = (u64) &e->cont + e->cont;
 
=== arch/ia64/mm/fault.c 1.16 vs edited ==--- 1.16/arch/ia64/mm/fault.c	Tue Jan 27 22:23:13 2004
+++ edited/arch/ia64/mm/fault.c	Wed Mar 24 12:40:32 2004
@@ -213,7 +213,7 @@
 		return;
 	}
 
-	if (done_with_exception(regs))
+	if (ia64_done_with_exception(regs))
 		return;
 
 	/*
=== include/asm-ia64/uaccess.h 1.17 vs edited ==--- 1.17/include/asm-ia64/uaccess.h	Tue Jan 27 22:23:13 2004
+++ edited/include/asm-ia64/uaccess.h	Wed Mar 24 12:39:48 2004
@@ -292,16 +292,16 @@
 	int cont;	/* location-relative continuation addr.; if bit 2 is set, r9 is set to 0 */
 };
 
-extern void handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
+extern void ia64_handle_exception (struct pt_regs *regs, const struct exception_table_entry *e);
 extern const struct exception_table_entry *search_exception_tables (unsigned long addr);
 
 static inline int
-done_with_exception (struct pt_regs *regs)
+ia64_done_with_exception (struct pt_regs *regs)
 {
 	const struct exception_table_entry *e;
 	e = search_exception_tables(regs->cr_iip + ia64_psr(regs)->ri);
 	if (e) {
-		handle_exception(regs, e);
+		ia64_handle_exception(regs, e);
 		return 1;
 	}
 	return 0;
