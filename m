From: Petr Tesarik <ptesarik@suse.cz>
Date: Mon, 11 Feb 2008 21:42:00 +0000
Subject: [PATCH 2/6] do not sync RBS when changing PT_AR_BSP or PT_CFM
Message-Id: <1202766120.9594.24.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Syncing is no longer needed, because user RBS is already
up-to-date.  Actually, if a debugger modified the contents
of the original RBS prior to changing PT_AR_BSP, the
modifications would get overwritten.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
CC: Tony Luck <tony.luck@intel.com>
CC: Christoph Hellwig <hch@infradead.org>

diff --git a/arch/ia64/kernel/ptrace.c b/arch/ia64/kernel/ptrace.c
index 9d25914..54b7ea5 100644
--- a/arch/ia64/kernel/ptrace.c
+++ b/arch/ia64/kernel/ptrace.c
@@ -1011,14 +1011,9 @@ #	define pt_reg_addr(pt, reg)	((void *)	
 			 * the kernel was entered.
 			 *
 			 * Furthermore, when changing the contents of
-			 * PT_AR_BSP (or PT_CFM) we MUST copy any
-			 * users-level stacked registers that are
-			 * stored on the kernel stack back to
-			 * user-space because otherwise, we might end
-			 * up clobbering kernel stacked registers.
-			 * Also, if this happens while the task is
-			 * blocked in a system call, which convert the
-			 * state such that the non-system-call exit
+			 * PT_AR_BSP (or PT_CFM) while the task is
+			 * blocked in a system call, convert the state
+			 * so that the non-system-call exit
 			 * path is used.  This ensures that the proper
 			 * state will be picked up when resuming
 			 * execution.  However, it *also* means that
@@ -1035,10 +1030,6 @@ #	define pt_reg_addr(pt, reg)	((void *)	
 			urbs_end = ia64_get_user_rbs_end(child, pt, &cfm);
 			if (write_access) {
 				if (*data != urbs_end) {
-					if (ia64_sync_user_rbs(child, sw,
-							       pt->ar_bspstore,
-							       urbs_end) < 0)
-						return -1;
 					if (in_syscall(pt))
 						convert_to_non_syscall(child,
 								       pt,
@@ -1058,10 +1049,6 @@ #	define pt_reg_addr(pt, reg)	((void *)	
 			urbs_end = ia64_get_user_rbs_end(child, pt, &cfm);
 			if (write_access) {
 				if (((cfm ^ *data) & PFM_MASK) != 0) {
-					if (ia64_sync_user_rbs(child, sw,
-							       pt->ar_bspstore,
-							       urbs_end) < 0)
-						return -1;
 					if (in_syscall(pt))
 						convert_to_non_syscall(child,
 								       pt,

