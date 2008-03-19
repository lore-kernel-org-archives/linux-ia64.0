From: Roland McGrath <roland@redhat.com>
Date: Wed, 19 Mar 2008 21:20:24 +0000
Subject: [PATCH 6/8] ptrace: arch_ptrace -ENOSYS return
Message-Id: <20080319212024.EA03126F995@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080319211714.8B14226F995@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Wednesday, 19 March 2008 14:17:14 -0700 <20080319211714.8B14226F995@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org

The arch_ptrace and compat_arch_ptrace functions can now return
-ENOSYS for requests they do not actually implement in arch
code.  Returning -ENOSYS replaces the calls to ptrace_request
and compat_ptrace_request.  This leaves more latitude for the
machine-independent ptrace implementation code to change without
requiring any more updates in the arch code.

This change has no effect on the old arch code that still calls
ptrace_request or compat_ptrace_request.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 kernel/ptrace.c |   42 ++++++++++++++++++++++++++----------------
 1 files changed, 26 insertions(+), 16 deletions(-)

diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 67e392e..60b2b57 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -574,18 +574,21 @@ asmlinkage long sys_ptrace(long request, long pid, long addr, long data)
 		 */
 		if (!ret)
 			arch_ptrace_attach(child);
-		goto out_put_task_struct;
+	} else {
+		ret = ptrace_check_attach(child, request = PTRACE_KILL);
+		/*
+		 * Let the arch handler inspect it first.  It returns
+		 * -ENOSYS if this is not an arch-specific request.
+		 */
+		if (!ret) {
+			ret = arch_ptrace(child, request, addr, data);
+			if (ret = -ENOSYS &&
+			    !forced_successful_syscall_return())
+				ret = ptrace_request(child, request,
+						     addr, data);
+		}
 	}
 
-	ret = ptrace_check_attach(child, request = PTRACE_KILL);
-	if (ret < 0)
-		goto out_put_task_struct;
-
-	ret = arch_ptrace(child, request, addr, data);
-	if (ret < 0)
-		goto out_put_task_struct;
-
- out_put_task_struct:
 	put_task_struct(child);
  out:
 	unlock_kernel();
@@ -697,14 +700,21 @@ asmlinkage long compat_sys_ptrace(compat_long_t request, compat_long_t pid,
 		 */
 		if (!ret)
 			arch_ptrace_attach(child);
-		goto out_put_task_struct;
+	} else {
+		ret = ptrace_check_attach(child, request = PTRACE_KILL);
+		/*
+		 * Let the arch handler inspect it first.  It returns
+		 * -ENOSYS if this is not an arch-specific request.
+		 */
+		if (!ret) {
+			ret = compat_arch_ptrace(child, request, addr, data);
+			if (ret = -ENOSYS &&
+			    !forced_successful_syscall_return())
+				ret = compat_ptrace_request(child, request,
+							    addr, data);
+		}
 	}
 
-	ret = ptrace_check_attach(child, request = PTRACE_KILL);
-	if (!ret)
-		ret = compat_arch_ptrace(child, request, addr, data);
-
- out_put_task_struct:
 	put_task_struct(child);
  out:
 	unlock_kernel();
