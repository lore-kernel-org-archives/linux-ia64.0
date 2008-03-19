From: Roland McGrath <roland@redhat.com>
Date: Wed, 19 Mar 2008 21:17:14 +0000
Subject: [PATCH 1/8] ptrace: forced_successful_syscall_return() macro
Message-Id: <20080319211714.8B14226F995@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

This adds the forced_successful_syscall_return() macro, a mate to
force_successful_syscall_return() to test rather than set the condition.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 include/linux/ptrace.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index ebe0c17..9272e63 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -124,8 +124,13 @@ int generic_ptrace_pokedata(struct task_struct *tsk, long addr, long data);
  * is a no-op and the spurious error condition needs to be filtered out by some
  * other means (e.g., in user-level, by passing an extra argument to the
  * syscall handler, or something along those lines).
+ *
+ * On architectures that define force_successful_syscall_return(),
+ * forced_successful_syscall_return() should also be defined.
+ * It returns nonzero if force_successful_syscall_return() was just used.
  */
 #define force_successful_syscall_return() do { } while (0)
+#define forced_successful_syscall_return() 0
 #endif
 
 /*
