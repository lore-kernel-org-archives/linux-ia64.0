From: cpw@sgi.com (Cliff Wickman)
Date: Thu, 27 Oct 2005 15:29:08 +0000
Subject: [PATCH 1/2] ia64: ptrace - find memory sharers on children list
Message-Id: <4360F244.mailxI4A11KHTU@eag09.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


From: Cliff Wickman <cpw@sgi.com>

In arch/ia64/kernel/ptrace.c there is a test for a peek or poke of a
register image (in register backing storage).
The test can be unnecessarily long (and occurs while holding the tasklist_lock).
Especially long on a large system with thousands of active tasks.

The ptrace caller (presumably a debugger) specifies the pid of
its target and an address to peek or poke.  But the debugger could be
attached to several tasks.
The idea of find_thread_for_addr() is to find whether the target address
is in the RBS for any of those tasks.

Currently it searches the thread-list of the target pid.  If that search
does not find a match, and the shared mm-struct's user count indicates
that there are other tasks sharing this address space (a rare occurrence),
a search is made of all the tasks in the system.

Another approach can drastically shorten this procedure.
It depends upon the fact that in order to peek or poke from/to any task,
the debugger must first attach to that task.  And when it does, the
attached task is made a child of the debugger (is chained to its children list).

Therefore we can search just the debugger's children list.

Diffed against 2.6.14-rc4

Signed-off-by: Cliff Wickman <cpw@sgi.com>
---

The need for this patch will be eliminated if/when the ptrace_arch_stop()
approach is implemented (per David Mosberger).
But ptrace can suffer a serious performance problem (on SGI Altix) without
this change. Particularly because of the way MPI is done on Altix.

--- linux/arch/ia64/kernel/ptrace.orig	2005-09-30 15:58:09 -05:00
+++ linux/arch/ia64/kernel/ptrace.c	2005-10-10 17:21:20 -05:00
@@ -569,6 +569,7 @@ find_thread_for_addr (struct task_struct
 {
 	struct task_struct *g, *p;
 	struct mm_struct *mm;
+	struct list_head *this, *next;
 	int mm_users;
 
 	if (!(mm = get_task_mm(child)))
@@ -579,28 +580,21 @@ find_thread_for_addr (struct task_struct
 		goto out;		/* not multi-threaded */
 
 	/*
-	 * First, traverse the child's thread-list.  Good for scalability with
-	 * NPTL-threads.
+	 * Traverse the current process' children list.  Every task that
+	 * one attaches to becomes a child.  And it is only attached children
+	 * of the debugger that are of interest (ptrace_check_attach checks
+	 * for this).
 	 */
-	p = child;
-	do {
-		if (thread_matches(p, addr)) {
-			child = p;
-			goto out;
-		}
-		if (mm_users-- <= 1)
-			goto out;
-	} while ((p = next_thread(p)) != child);
-
-	do_each_thread(g, p) {
-		if (child->mm != mm)
+ 	list_for_each_safe(this, next, &current->children) {
+		p = list_entry(this, struct task_struct, sibling);
+		if (p->mm != mm)
 			continue;
-
 		if (thread_matches(p, addr)) {
 			child = p;
 			goto out;
 		}
-	} while_each_thread(g, p);
+	}
+
   out:
 	mmput(mm);
 	return child;
