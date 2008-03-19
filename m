From: Roland McGrath <roland@redhat.com>
Date: Wed, 19 Mar 2008 21:19:14 +0000
Subject: [PATCH 3/8] ia64 ptrace: forced_successful_syscall_return()
Message-Id: <20080319211914.AFE0E26F995@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Wednesday, 19 March 2008 14:17:14 -0700 <20080319211714.8B14226F995@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

Define the forced_successful_syscall_return() macro to
pair with our force_successful_syscall_return() definition.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 include/asm-ia64/ptrace.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/asm-ia64/ptrace.h b/include/asm-ia64/ptrace.h
index 4b2a8d4..5e82915 100644
--- a/include/asm-ia64/ptrace.h
+++ b/include/asm-ia64/ptrace.h
@@ -276,6 +276,7 @@ struct switch_stack {
    * On ia64, we can clear the user's pt_regs->r8 to force a successful syscall.
    */
 # define force_successful_syscall_return()	(task_pt_regs(current)->r8 = 0)
+# define forced_successful_syscall_return()	(task_pt_regs(current)->r8 = 0)
 
   struct task_struct;			/* forward decl */
   struct unw_frame_info;		/* forward decl */
