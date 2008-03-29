From: Roland McGrath <roland@redhat.com>
Date: Sat, 29 Mar 2008 00:12:30 +0000
Subject: [PATCH 1/4] set_restore_sigmask
Message-Id: <20080329001230.D013726FA1D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org

This adds the set_restore_sigmask() inline in <linux/thread_info.h> and
replaces every set_thread_flag(TIF_RESTORE_SIGMASK) with a call to it.
No change, but abstracts the flag protocol details from all the calls.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 fs/compat.c                 |    6 +++---
 fs/eventpoll.c              |    3 +--
 fs/select.c                 |    4 ++--
 include/linux/thread_info.h |   15 ++++++++++++++-
 kernel/compat.c             |    3 +--
 kernel/signal.c             |    2 +-
 6 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 2ce4456..9964d54 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1720,7 +1720,7 @@ sticky:
 		if (sigmask) {
 			memcpy(&current->saved_sigmask, &sigsaved,
 					sizeof(sigsaved));
-			set_thread_flag(TIF_RESTORE_SIGMASK);
+			set_restore_sigmask();
 		}
 	} else if (sigmask)
 		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
@@ -1791,7 +1791,7 @@ asmlinkage long compat_sys_ppoll(struct pollfd __user *ufds,
 		if (sigmask) {
 			memcpy(&current->saved_sigmask, &sigsaved,
 				sizeof(sigsaved));
-			set_thread_flag(TIF_RESTORE_SIGMASK);
+			set_restore_sigmask();
 		}
 		ret = -ERESTARTNOHAND;
 	} else if (sigmask)
@@ -2117,7 +2117,7 @@ asmlinkage long compat_sys_epoll_pwait(int epfd,
 		if (err = -EINTR) {
 			memcpy(&current->saved_sigmask, &sigsaved,
 			       sizeof(sigsaved));
-			set_thread_flag(TIF_RESTORE_SIGMASK);
+			set_restore_sigmask();
 		} else
 			sigprocmask(SIG_SETMASK, &sigsaved, NULL);
 	}
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index a415f42..503ffa4 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1300,7 +1300,7 @@ asmlinkage long sys_epoll_pwait(int epfd, struct epoll_event __user *events,
 		if (error = -EINTR) {
 			memcpy(&current->saved_sigmask, &sigsaved,
 			       sizeof(sigsaved));
-			set_thread_flag(TIF_RESTORE_SIGMASK);
+			set_restore_sigmask();
 		} else
 			sigprocmask(SIG_SETMASK, &sigsaved, NULL);
 	}
@@ -1330,4 +1330,3 @@ static int __init eventpoll_init(void)
 	return 0;
 }
 fs_initcall(eventpoll_init);
-
diff --git a/fs/select.c b/fs/select.c
index 5633fe9..bbd351c 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -498,7 +498,7 @@ sticky:
 		if (sigmask) {
 			memcpy(&current->saved_sigmask, &sigsaved,
 					sizeof(sigsaved));
-			set_thread_flag(TIF_RESTORE_SIGMASK);
+			set_restore_sigmask();
 		}
 	} else if (sigmask)
 		sigprocmask(SIG_SETMASK, &sigsaved, NULL);
@@ -805,7 +805,7 @@ asmlinkage long sys_ppoll(struct pollfd __user *ufds, unsigned int nfds,
 		if (sigmask) {
 			memcpy(&current->saved_sigmask, &sigsaved,
 					sizeof(sigsaved));
-			set_thread_flag(TIF_RESTORE_SIGMASK);
+			set_restore_sigmask();
 		}
 		ret = -ERESTARTNOHAND;
 	} else if (sigmask)
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index 421323e..d82c073 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -80,6 +80,19 @@ static inline int test_ti_thread_flag(struct thread_info *ti, int flag)
 #define set_need_resched()	set_thread_flag(TIF_NEED_RESCHED)
 #define clear_need_resched()	clear_thread_flag(TIF_NEED_RESCHED)
 
-#endif
+#ifdef TIF_RESTORE_SIGMASK
+/**
+ * set_restore_sigmask() - make sure saved_sigmask processing gets done
+ *
+ * This sets TIF_RESTORE_SIGMASK and ensures that the arch signal code
+ * will run before returning to user mode, to process the flag.
+ */
+static inline void set_restore_sigmask(void)
+{
+	set_thread_flag(TIF_RESTORE_SIGMASK);
+}
+#endif	/* TIF_RESTORE_SIGMASK */
+
+#endif	/* __KERNEL__ */
 
 #endif /* _LINUX_THREAD_INFO_H */
diff --git a/kernel/compat.c b/kernel/compat.c
index 5f0e201..a830c84 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -899,7 +899,7 @@ asmlinkage long compat_sys_rt_sigsuspend(compat_sigset_t __user *unewset, compat
 
 	current->state = TASK_INTERRUPTIBLE;
 	schedule();
-	set_thread_flag(TIF_RESTORE_SIGMASK);
+	set_restore_sigmask();
 	return -ERESTARTNOHAND;
 }
 #endif /* __ARCH_WANT_COMPAT_SYS_RT_SIGSUSPEND */
@@ -1081,4 +1081,3 @@ compat_sys_sysinfo(struct compat_sysinfo __user *info)
 
 	return 0;
 }
-
diff --git a/kernel/signal.c b/kernel/signal.c
index 6af1210..977b3cd 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -2610,7 +2610,7 @@ asmlinkage long sys_rt_sigsuspend(sigset_t __user *unewset, size_t sigsetsize)
 
 	current->state = TASK_INTERRUPTIBLE;
 	schedule();
-	set_thread_flag(TIF_RESTORE_SIGMASK);
+	set_restore_sigmask();
 	return -ERESTARTNOHAND;
 }
 #endif /* __ARCH_WANT_SYS_RT_SIGSUSPEND */
