From: Keith Owens <kaos@sgi.com>
Date: Thu, 14 Mar 2002 02:43:19 +0000
Subject: [Linux-ia64] [patch] 2.4.18-ia64-020226 generalize exception recovery
Message-Id: <marc-linux-ia64-105590701905270@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch against 2.4.18-ia64-020226 generalizes the code for ia64
exception recovery, removing duplicate tests.  David, please apply.

The final patch (indented to prevent accidental application) uses the
generalized code to let kdb recovery from more errors.

Index: 18.5/include/asm-ia64/uaccess.h
--- 18.5/include/asm-ia64/uaccess.h Sun, 08 Apr 2001 14:10:15 +1000 kaos (linux-2.4/s/20_uaccess.h 1.1.1.1 644)
+++ 18.5(w)/include/asm-ia64/uaccess.h Thu, 14 Mar 2002 12:28:41 +1100 kaos (linux-2.4/s/20_uaccess.h 1.1.1.1 644)
@@ -320,4 +320,20 @@ struct exception_fixup {
 extern struct exception_fixup search_exception_table (unsigned long addr);
 extern void handle_exception (struct pt_regs *regs, struct exception_fixup fixup);
 
+#ifdef GAS_HAS_LOCAL_TAGS
+#define HANDLE_EXCEPTION_1(regs) search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
+#else
+#define HANDLE_EXCEPTION_1(regs) search_exception_table(regs->cr_iip);
+#endif
+#define HANDLE_EXCEPTION(regs)			\
+{						\
+	struct exception_fixup fix;		\
+	fix = HANDLE_EXCEPTION_1(regs);		\
+	if (fix.cont) {				\
+		handle_exception(regs, fix);	\
+		return;				\
+	}					\
+}
+
+
 #endif /* _ASM_IA64_UACCESS_H */
Index: 18.5/arch/ia64/mm/fault.c
--- 18.5/arch/ia64/mm/fault.c Wed, 27 Feb 2002 12:38:35 +1100 kaos (linux-2.4/r/c/10_fault.c 1.3.1.2 644)
+++ 18.5(w)/arch/ia64/mm/fault.c Wed, 13 Mar 2002 17:08:03 +1100 kaos (linux-2.4/r/c/10_fault.c 1.3.1.2 644)
@@ -49,7 +49,6 @@ ia64_do_page_fault (unsigned long addres
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
-	struct exception_fixup fix;
 	struct siginfo si;
 	unsigned long mask;
 
@@ -167,15 +166,7 @@ ia64_do_page_fault (unsigned long addres
 		return;
 	}
 
-#ifdef GAS_HAS_LOCAL_TAGS
-	fix = search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
-#else
-	fix = search_exception_table(regs->cr_iip);
-#endif
-	if (fix.cont) {
-		handle_exception(regs, fix);
-		return;
-	}
+	HANDLE_EXCEPTION(regs);		/* return if exception handled */
 
 	/*
 	 * Oops. The kernel tried to access some bad page. We'll have to terminate things
Index: 18.5/arch/ia64/kernel/unaligned.c
--- 18.5/arch/ia64/kernel/unaligned.c Wed, 27 Feb 2002 12:38:35 +1100 kaos (linux-2.4/r/c/40_unaligned. 1.1.3.1.3.1.1.2 644)
+++ 18.5(w)/arch/ia64/kernel/unaligned.c Wed, 13 Mar 2002 17:08:00 +1100 kaos (linux-2.4/r/c/40_unaligned. 1.1.3.1.3.1.1.2 644)
@@ -1304,11 +1304,7 @@ ia64_handle_unaligned (unsigned long ifa
 	 * handler into reading an arbitrary kernel addresses...
 	 */
 	if (!user_mode(regs)) {
-#ifdef GAS_HAS_LOCAL_TAGS
-		fix = search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
-#else
-		fix = search_exception_table(regs->cr_iip);
-#endif
+		fix = HANDLE_EXCEPTION_1(regs);
 	}
 	if (user_mode(regs) || fix.cont) {
 		if ((current->thread.flags & IA64_THREAD_UAC_SIGBUS) != 0)

This fragment goes into the kdb patch when the change above is
available.

  Index: 18.5/arch/ia64/kernel/traps.c
  --- 18.5/arch/ia64/kernel/traps.c Wed, 27 Feb 2002 12:38:35 +1100 kaos (linux-2.4/r/c/43_traps.c 1.1.4.1.3.1.1.2 644)
  +++ 18.5(w)/arch/ia64/kernel/traps.c Thu, 14 Mar 2002 13:37:14 +1100 kaos (linux-2.4/r/c/43_traps.c 1.1.4.1.3.1.1.2 644)
  @@ -591,6 +591,11 @@ ia64_fault (unsigned long vector, unsign
		  sprintf(buf, "Fault %lu", vector);
		  break;
	  }
  +#ifdef	CONFIG_KDB
  +	if (KDB_IS_RUNNING()) {
  +		HANDLE_EXCEPTION(regs);		/* return if exception handled */
  +	}
  +#endif	/* CONFIG_KDB */
	  die_if_kernel(buf, regs, error);
	  force_sig(SIGILL, current);
   }


