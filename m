From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Mar 2002 06:46:31 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.18-ia64-020226 generalize exception recovery
Message-Id: <marc-linux-ia64-105590701905273@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905271@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905271@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Mar 2002 16:51:04 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> On Wed, 13 Mar 2002 19:13:44 -0800, 
  Keith> David Mosberger <davidm@napali.hpl.hp.com> wrote:
  >> I'm OK with the first macro (rename it to SEARCH_EXCEPTION_TABLE,
  >> though), but the HANDLE_EXCEPTION() macro is ugly: it looks like a
  >> statement, when in fact it's a conditional return.

  Keith> Take 2.

I applied the attached patch, which is the same as yours except for
renaming HANDLE_EXCEPTION() to done_with_exception().  I hope this
works for you.

	--david

=== arch/ia64/kernel/unaligned.c 1.5 vs edited ==--- 1.5/arch/ia64/kernel/unaligned.c	Fri Mar  8 18:11:40 2002
+++ edited/arch/ia64/kernel/unaligned.c	Wed Mar 13 22:37:11 2002
@@ -1305,11 +1305,7 @@
 	 * handler into reading an arbitrary kernel addresses...
 	 */
 	if (!user_mode(regs)) {
-#ifdef GAS_HAS_LOCAL_TAGS
-		fix = search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
-#else
-		fix = search_exception_table(regs->cr_iip);
-#endif
+		fix = SEARCH_EXCEPTION_TABLE(regs);
 	}
 	if (user_mode(regs) || fix.cont) {
 		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) != 0)
=== arch/ia64/mm/fault.c 1.5 vs edited ==--- 1.5/arch/ia64/mm/fault.c	Fri Mar  8 18:11:40 2002
+++ edited/arch/ia64/mm/fault.c	Wed Mar 13 22:43:00 2002
@@ -49,7 +49,6 @@
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
-	struct exception_fixup fix;
 	struct siginfo si;
 	unsigned long mask;
 
@@ -167,15 +166,8 @@
 		return;
 	}
 
-#ifdef GAS_HAS_LOCAL_TAGS
-	fix = search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
-#else
-	fix = search_exception_table(regs->cr_iip);
-#endif
-	if (fix.cont) {
-		handle_exception(regs, fix);
+	if (done_with_exception(regs))
 		return;
-	}
 
 	/*
 	 * Oops. The kernel tried to access some bad page. We'll have to terminate things
=== include/asm-ia64/uaccess.h 1.3 vs edited ==--- 1.3/include/asm-ia64/uaccess.h	Fri Mar  8 18:11:40 2002
+++ edited/include/asm-ia64/uaccess.h	Wed Mar 13 22:43:05 2002
@@ -320,4 +320,22 @@
 extern struct exception_fixup search_exception_table (unsigned long addr);
 extern void handle_exception (struct pt_regs *regs, struct exception_fixup fixup);
 
+#ifdef GAS_HAS_LOCAL_TAGS
+#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
+#else
+#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip);
+#endif
+
+static inline int
+done_with_exception (struct pt_regs *regs)
+{
+	struct exception_fixup fix;
+	fix = SEARCH_EXCEPTION_TABLE(regs);
+	if (fix.cont) {
+		handle_exception(regs, fix);
+		return 1;
+	}
+	return 0;
+}
+
 #endif /* _ASM_IA64_UACCESS_H */

