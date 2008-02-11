From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 11 Feb 2008 21:41:18 +0000
Subject: [PATCH 1/6] access user RBS directly
Message-Id: <1202766078.9594.23.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

access user RBS directly

Because the user RBS of a process is now completely stored in
user-mode when the process is ptrace-stopped, accesses to the
RBS should no longer augment any part of the kernel RBS.

This means we can get rid of most ia64_peek() and ia64_poke()
calls.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Tony Luck <tony.luck@intel.com>
CC: Christoph Hellwig <hch@infradead.org>

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 331d676..9d25914 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -908,7 +908,7 @@ static int
 access_uarea (struct task_struct *child, unsigned long addr,
 	      unsigned long *data, int write_access)
 {
-	unsigned long *ptr, regnum, urbs_end, rnat_addr, cfm;
+	unsigned long *ptr, regnum, urbs_end, cfm;
 	struct switch_stack *sw;
 	struct pt_regs *pt;
 #	define pt_reg_addr(pt, reg)	((void *)			    \
@@ -1093,16 +1093,8 @@ #	define pt_reg_addr(pt, reg)	((void *)	
 			return 0;
 
 		      case PT_AR_RNAT:
-			urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
-			rnat_addr = (long) ia64_rse_rnat_addr((long *)
-							      urbs_end);
-			if (write_access)
-				return ia64_poke(child, sw, urbs_end,
-						 rnat_addr, *data);
-			else
-				return ia64_peek(child, sw, urbs_end,
-						 rnat_addr, data);
-
+			ptr = pt_reg_addr(pt, ar_rnat);
+			break;
 		      case PT_R1:
 			ptr = pt_reg_addr(pt, r1);
 			break;
@@ -1541,11 +1533,10 @@ asmlinkage long
 sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long data)
 {
 	struct pt_regs *pt;
-	unsigned long urbs_end, peek_or_poke;
+	unsigned long peek_or_poke;
 	struct task_struct *child;
 	struct switch_stack *sw;
 	long ret;
-	struct unw_frame_info info;
 
 	lock_kernel();
 	ret = -EPERM;
@@ -1593,26 +1584,19 @@ sys_ptrace (long request, pid_t pid, uns
 	      case PTRACE_PEEKTEXT:
 	      case PTRACE_PEEKDATA:
 		/* read word at location addr */
-		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
-		ret = ia64_peek(child, sw, urbs_end, addr, &data);
-		if (ret = 0) {
-			ret = data;
-			/* ensure "ret" is not mistaken as an error code: */
-			force_successful_syscall_return();
+		if (access_process_vm(child, addr, &data, sizeof(data), 0)
+		    != sizeof(data)) {
+			ret = -EIO;
+			goto out_tsk;
 		}
+		ret = data;
+		/* ensure "ret" is not mistaken as an error code */
+		force_successful_syscall_return();
 		goto out_tsk;
 
-	      case PTRACE_POKETEXT:
-	      case PTRACE_POKEDATA:
-		/* write the word at location addr */
-		urbs_end = ia64_get_user_rbs_end(child, pt, NULL);
-		ret = ia64_poke(child, sw, urbs_end, addr, data);
-
-		/* Make sure user RBS has the latest data */
-		unw_init_from_blocked_task(&info, child);
-		do_sync_rbs(&info, ia64_sync_user_rbs);
-
-		goto out_tsk;
+	/* PTRACE_POKETEXT and PTRACE_POKEDATA is handled
+	 * by the generic ptrace_request().
+	 */
 
 	      case PTRACE_PEEKUSR:
 		/* read the word at addr in the USER area */

