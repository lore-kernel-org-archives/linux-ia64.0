From: Keith Owens <kaos@sgi.com>
Date: Thu, 14 Mar 2002 05:51:04 +0000
Subject: [Linux-ia64] Re: [patch] 2.4.18-ia64-020226 generalize exception recovery
Message-Id: <marc-linux-ia64-105590701905272@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905271@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905271@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 13 Mar 2002 19:13:44 -0800, 
David Mosberger <davidm@napali.hpl.hp.com> wrote:
>I'm OK with the first macro (rename it to SEARCH_EXCEPTION_TABLE,
>though), but the HANDLE_EXCEPTION() macro is ugly: it looks like a
>statement, when in fact it's a conditional return.

Take 2.

Index: 18.5/include/asm-ia64/uaccess.h
--- 18.5/include/asm-ia64/uaccess.h Sun, 08 Apr 2001 14:10:15 +1000 kaos (linux-2.4/s/20_uaccess.h 1.1.1.1 644)
+++ 18.5(w)/include/asm-ia64/uaccess.h Thu, 14 Mar 2002 15:30:16 +1100 kaos (linux-2.4/s/20_uaccess.h 1.1.1.1 644)
@@ -320,4 +320,21 @@ struct exception_fixup {
 extern struct exception_fixup search_exception_table (unsigned long addr);
 extern void handle_exception (struct pt_regs *regs, struct exception_fixup fixup);
 
+#ifdef GAS_HAS_LOCAL_TAGS
+#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
+#else
+#define SEARCH_EXCEPTION_TABLE(regs) search_exception_table(regs->cr_iip);
+#endif
+static inline int HANDLE_EXCEPTION(struct pt_regs *regs)
+{
+	struct exception_fixup fix;
+	fix = SEARCH_EXCEPTION_TABLE(regs);
+	if (fix.cont) {
+		handle_exception(regs, fix);
+		return(1);
+	}
+	return(0);
+}
+
+
 #endif /* _ASM_IA64_UACCESS_H */
Index: 18.5/arch/ia64/mm/fault.c
--- 18.5/arch/ia64/mm/fault.c Wed, 27 Feb 2002 12:38:35 +1100 kaos (linux-2.4/r/c/10_fault.c 1.3.1.2 644)
+++ 18.5(w)/arch/ia64/mm/fault.c Thu, 14 Mar 2002 15:30:35 +1100 kaos (linux-2.4/r/c/10_fault.c 1.3.1.2 644)
@@ -49,7 +49,6 @@ ia64_do_page_fault (unsigned long addres
 	int signal = SIGSEGV, code = SEGV_MAPERR;
 	struct vm_area_struct *vma, *prev_vma;
 	struct mm_struct *mm = current->mm;
-	struct exception_fixup fix;
 	struct siginfo si;
 	unsigned long mask;
 
@@ -167,15 +166,8 @@ ia64_do_page_fault (unsigned long addres
 		return;
 	}
 
-#ifdef GAS_HAS_LOCAL_TAGS
-	fix = search_exception_table(regs->cr_iip + ia64_psr(regs)->ri);
-#else
-	fix = search_exception_table(regs->cr_iip);
-#endif
-	if (fix.cont) {
-		handle_exception(regs, fix);
+	if (HANDLE_EXCEPTION(regs))
 		return;
-	}
 
 	/*
 	 * Oops. The kernel tried to access some bad page. We'll have to terminate things
Index: 18.5/arch/ia64/kernel/unaligned.c
--- 18.5/arch/ia64/kernel/unaligned.c Wed, 27 Feb 2002 12:38:35 +1100 kaos (linux-2.4/r/c/40_unaligned. 1.1.3.1.3.1.1.2 644)
+++ 18.5(w)/arch/ia64/kernel/unaligned.c Thu, 14 Mar 2002 15:30:59 +1100 kaos (linux-2.4/r/c/40_unaligned. 1.1.3.1.3.1.1.2 644)
@@ -1304,11 +1304,7 @@ ia64_handle_unaligned (unsigned long ifa
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

kdb update to go with above.

  Index: 18.5/arch/ia64/kernel/traps.c
  --- 18.5/arch/ia64/kernel/traps.c Wed, 27 Feb 2002 12:38:35 +1100 kaos (linux-2.4/r/c/43_traps.c 1.1.4.1.3.1.1.2 644)
  +++ 18.5(w)/arch/ia64/kernel/traps.c Thu, 14 Mar 2002 15:31:31 +1100 kaos (linux-2.4/r/c/43_traps.c 1.1.4.1.3.1.1.2 644)
  @@ -591,6 +591,10 @@ ia64_fault (unsigned long vector, unsign
		  sprintf(buf, "Fault %lu", vector);
		  break;
	  }
  +#ifdef	CONFIG_KDB
  +	if (KDB_IS_RUNNING() && HANDLE_EXCEPTION(regs))
  +		return;
  +#endif	/* CONFIG_KDB */
	  die_if_kernel(buf, regs, error);
	  force_sig(SIGILL, current);
   }


