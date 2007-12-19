From: Kyle McMartin <kyle@mcmartin.ca>
Date: Wed, 19 Dec 2007 16:42:04 +0000
Subject: Re: [ia64] BUG: sleeping in atomic
Message-Id: <20071219164204.GA18161@fattire.cabal.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071219055430.GV4396912@sgi.com>
In-Reply-To: <20071219055430.GV4396912@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Chinner <dgc@sgi.com>
Cc: lkml <linux-kernel@vger.kernel.org>, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Wed, Dec 19, 2007 at 04:54:30PM +1100, David Chinner wrote:
> [ 5667.086055] BUG: sleeping function called from invalid context at kernel/fork.c:401
> 

The problem is that mmput is called under the read_lock by
find_thread_for_addr... The comment above seems to indicate that gdb
needs to be able to access any child tasks register backing store
memory... This seems pretty broken.

cheers, Kyle

---

Who knows, maybe gdb is saner now?

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 2e96f17..b609704 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1418,7 +1418,7 @@ asmlinkage long
 sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long data)
 {
 	struct pt_regs *pt;
-	unsigned long urbs_end, peek_or_poke;
+	unsigned long urbs_end;
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
@@ -1430,23 +1430,12 @@ sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long data)
 		goto out;
 	}
 
-	peek_or_poke = (request = PTRACE_PEEKTEXT
-			|| request = PTRACE_PEEKDATA
-			|| request = PTRACE_POKETEXT
-			|| request = PTRACE_POKEDATA);
-	ret = -ESRCH;
-	read_lock(&tasklist_lock);
-	{
-		child = find_task_by_pid(pid);
-		if (child) {
-			if (peek_or_poke)
-				child = find_thread_for_addr(child, addr);
-			get_task_struct(child);
-		}
-	}
-	read_unlock(&tasklist_lock);
-	if (!child)
+	child = ptrace_get_task_struct(pid);
+	if (IS_ERR(child)) {
+		ret = PTR_ERR(child);
 		goto out;
+	}
+
 	ret = -EPERM;
 	if (pid = 1)		/* no messing around with init! */
 		goto out_tsk;
