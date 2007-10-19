From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 19 Oct 2007 19:55:29 +0000
Subject: [PATCH] Simplify ptrace handling
Message-Id: <1192823729.2727.56.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

with Shaohua Li's patch we can get rid of much of the ugly code in
arch/ia64/kernel/ptrace.c:

 - find_thread_for_addr() is no longer needed
 - most calls to ia64_poke() and ia64_peek() can be converted to
   simple accesses to the VM

This patch is incremental with Shaohua Li's fix, so it can't be applied
until we resolve the only remaining problem (race condition in
ptrace_stop). I'm only sending it to demonstrate the benefits of that
patch.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>

diff -u linux.orig/arch/ia64/kernel/ptrace.c linux/arch/ia64/kernel/ptrace.c
--- linux.orig/arch/ia64/kernel/ptrace.c	2007-10-19 21:24:21.451863000 +0200
+++ linux/arch/ia64/kernel/ptrace.c	2007-10-19 21:37:48.835854400 +0200
@@ -631,52 +631,6 @@
 }
 
 /*
- * GDB apparently wants to be able to read the register-backing store
- * of any thread when attached to a given process.  If we are peeking
- * or poking an address that happens to reside in the kernel-backing
- * store of another thread, we need to attach to that thread, because
- * otherwise we end up accessing stale data.
- *
- * task_list_lock must be read-locked before calling this routine!
- */
-static struct task_struct *
-find_thread_for_addr (struct task_struct *child, unsigned long addr)
-{
-	struct task_struct *p;
-	struct mm_struct *mm;
-	struct list_head *this, *next;
-	int mm_users;
-
-	if (!(mm = get_task_mm(child)))
-		return child;
-
-	/* -1 because of our get_task_mm(): */
-	mm_users = atomic_read(&mm->mm_users) - 1;
-	if (mm_users <= 1)
-		goto out;		/* not multi-threaded */
-
-	/*
-	 * Traverse the current process' children list.  Every task that
-	 * one attaches to becomes a child.  And it is only attached children
-	 * of the debugger that are of interest (ptrace_check_attach checks
-	 * for this).
-	 */
- 	list_for_each_safe(this, next, &current->children) {
-		p = list_entry(this, struct task_struct, sibling);
-		if (p->tgid != child->tgid)
-			continue;
-		if (thread_matches(p, addr)) {
-			child = p;
-			goto out;
-		}
-	}
-
-  out:
-	mmput(mm);
-	return child;
-}
-
-/*
  * Write f32-f127 back to task->thread.fph if it has been modified.
  */
 inline void
@@ -841,7 +795,7 @@
 access_uarea (struct task_struct *child, unsigned long addr,
 	      unsigned long *data, int write_access)
 {
-	unsigned long *ptr, regnum, urbs_end, rnat_addr, cfm;
+	unsigned long *ptr, regnum, urbs_end, cfm;
 	struct switch_stack *sw;
 	struct pt_regs *pt;
 #	define pt_reg_addr(pt, reg)	((void *)			    \
@@ -1026,15 +980,11 @@
 			return 0;
 
 		      case PT_AR_RNAT:
-			urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
-			rnat_addr = (long) ia64_rse_rnat_addr((long *)
-							      urbs_end);
 			if (write_access)
-				return ia64_poke(child, sw, urbs_end,
-						 rnat_addr, *data);
+				pt->ar_rnat = *data;
 			else
-				return ia64_peek(child, sw, urbs_end,
-						 rnat_addr, data);
+				*data = pt->ar_rnat;
+			return 0;
 
 		      case PT_R1:
 			ptr = pt_reg_addr(pt, r1);
@@ -1474,11 +1424,9 @@
 sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long data)
 {
 	struct pt_regs *pt;
-	unsigned long urbs_end, peek_or_poke;
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
-	struct unw_frame_info info;
 
 	lock_kernel();
 	ret = -EPERM;
@@ -1487,19 +1435,12 @@
 		goto out;
 	}
 
-	peek_or_poke = (request = PTRACE_PEEKTEXT
-			|| request = PTRACE_PEEKDATA
-			|| request = PTRACE_POKETEXT
-			|| request = PTRACE_POKEDATA);
 	ret = -ESRCH;
 	read_lock(&tasklist_lock);
 	{
 		child = find_task_by_pid(pid);
-		if (child) {
-			if (peek_or_poke)
-				child = find_thread_for_addr(child, addr);
+		if (child)
 			get_task_struct(child);
-		}
 	}
 	read_unlock(&tasklist_lock);
 	if (!child)
@@ -1524,25 +1465,23 @@
 	      case PTRACE_PEEKTEXT:
 	      case PTRACE_PEEKDATA:
 		/* read word at location addr */
-		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
-		ret = ia64_peek(child, sw, urbs_end, addr, &data);
-		if (ret = 0) {
+		if (access_process_vm(child, addr, &data, sizeof(data), 0)
+		    = sizeof(data)) {
 			ret = data;
 			/* ensure "ret" is not mistaken as an error code: */
 			force_successful_syscall_return();
-		}
+		} else
+			ret = -EIO;
 		goto out_tsk;
 
 	      case PTRACE_POKETEXT:
 	      case PTRACE_POKEDATA:
 		/* write the word at location addr */
-		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
-		ret = ia64_poke(child, sw, urbs_end, addr, data);
-
-		/* Make sure user RBS has the latest data */
-		unw_init_from_blocked_task(&info, child);
-		do_sync_rbs(&info, RBS_SYNC_TO_USER);
-
+		if (access_process_vm(child, addr, &data, sizeof(data), 1)
+		    = sizeof(data))
+			ret = 0;
+		else
+			ret = -EIO;
 		goto out_tsk;
 
 	      case PTRACE_PEEKUSR:

