From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 11 Feb 2008 21:42:34 +0000
Subject: [PATCH 3/6] remove find_thread_for_addr()
Message-Id: <1202766154.9594.26.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

find_thread_for_addr() is no longer needed.  It was only used to find
the correct kernel RBS for a given memory address, but since the kernel
RBS is not needed any longer, this function can go away.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Tony Luck <tony.luck@intel.com>
CC: Christoph Hellwig <hch@infradead.org>

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 54b7ea5..e82fe29 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -698,52 +698,6 @@ thread_matches (struct task_struct *thre
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
@@ -1520,7 +1474,6 @@ asmlinkage long
 sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long data)
 {
 	struct pt_regs *pt;
-	unsigned long peek_or_poke;
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
@@ -1532,19 +1485,12 @@ sys_ptrace (long request, pid_t pid, uns
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

