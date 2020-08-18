From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Tue, 18 Aug 2020 17:34:01 +0000
Subject: [PATCH 01/11] fork: introduce kernel_clone()
Message-Id: <20200818173411.404104-2-christian.brauner@ubuntu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200818173411.404104-1-christian.brauner@ubuntu.com>
In-Reply-To: <20200818173411.404104-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hewllig <hch@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ley Foon Tan <ley.foon.tan@intel.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, Stafford Horne <shorne@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Kars de Jong <jongk@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Greentime Hu <green.hu@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Mauro Carvalho Chehab <mchehab+huawei@kernel.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, Masami Hiramatsu <mhiramat@kernel.org>, Tom Zanussi <zanussi@kernel.org>, Xiao Yang <yangx.jy@cn.fujitsu.com>, linux-doc@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-kselftest@vger.kernel.org, Christian Brauner <christian.brauner@ubuntu.com>, Ingo Molnar <mingo@kernel.org>

The old _do_fork() helper doesn't follow naming conventions of in-kernel
helpers for syscalls. The process creation cleanup in [1] didn't change the
name to something more reasonable mainly because _do_fork() was used in quite a
few places. So sending this as a separate series seemed the better strategy.

This commit renames _do_fork() to kernel_clone() but keeps _do_fork() as a
simple static inline wrapper around kernel_clone().
Follow-up patches will switch each caller of _do_fork() and each place where it
is referenced over to kernel_clone(). After all these changes are done, we can
remove _do_fork() completely and will only be left with kernel_clone().

[1]: 9ba27414f2ec ("Merge tag 'fork-v5.9' of git://git.kernel.org/pub/scm/linux/kernel/git/brauner/linux")
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 include/linux/sched/task.h |  6 +++++-
 kernel/fork.c              | 14 +++++++-------
 2 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index a98965007eef..d9ef07359c96 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -83,7 +83,11 @@ extern void do_group_exit(int);
 extern void exit_files(struct task_struct *);
 extern void exit_itimers(struct signal_struct *);
 
-extern long _do_fork(struct kernel_clone_args *kargs);
+extern int kernel_clone(struct kernel_clone_args *kargs);
+static inline long _do_fork(struct kernel_clone_args *kargs)
+{
+	return kernel_clone(kargs);
+}
 struct task_struct *fork_idle(int);
 struct mm_struct *copy_init_mm(void);
 extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
diff --git a/kernel/fork.c b/kernel/fork.c
index 4d32190861bd..34e37cee239f 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -2384,7 +2384,7 @@ struct mm_struct *copy_init_mm(void)
  *
  * args->exit_signal is expected to be checked for sanity by the caller.
  */
-long _do_fork(struct kernel_clone_args *args)
+int kernel_clone(struct kernel_clone_args *args)
 {
 	u64 clone_flags = args->flags;
 	struct completion vfork;
@@ -2477,7 +2477,7 @@ pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags)
 		.stack_size	= (unsigned long)arg,
 	};
 
-	return _do_fork(&args);
+	return kernel_clone(&args);
 }
 
 #ifdef __ARCH_WANT_SYS_FORK
@@ -2488,7 +2488,7 @@ SYSCALL_DEFINE0(fork)
 		.exit_signal = SIGCHLD,
 	};
 
-	return _do_fork(&args);
+	return kernel_clone(&args);
 #else
 	/* can not support in nommu mode */
 	return -EINVAL;
@@ -2504,7 +2504,7 @@ SYSCALL_DEFINE0(vfork)
 		.exit_signal	= SIGCHLD,
 	};
 
-	return _do_fork(&args);
+	return kernel_clone(&args);
 }
 #endif
 
@@ -2542,7 +2542,7 @@ SYSCALL_DEFINE5(clone, unsigned long, clone_flags, unsigned long, newsp,
 		.tls		= tls,
 	};
 
-	return _do_fork(&args);
+	return kernel_clone(&args);
 }
 #endif
 
@@ -2700,7 +2700,7 @@ SYSCALL_DEFINE2(clone3, struct clone_args __user *, uargs, size_t, size)
 	if (!clone3_args_valid(&kargs))
 		return -EINVAL;
 
-	return _do_fork(&kargs);
+	return kernel_clone(&kargs);
 }
 #endif
 
@@ -2863,7 +2863,7 @@ int unshare_fd(unsigned long unshare_flags, unsigned int max_fds,
 /*
  * unshare allows a process to 'unshare' part of the process
  * context which was originally shared using clone.  copy_*
- * functions used by _do_fork() cannot be used here directly
+ * functions used by kernel_clone() cannot be used here directly
  * because they modify an inactive task_struct that is being
  * constructed. Here we are modifying the current, active,
  * task_struct.
-- 
2.28.0
