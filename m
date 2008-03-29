From: Roland McGrath <roland@redhat.com>
Date: Sat, 29 Mar 2008 03:11:46 +0000
Subject: [PATCH 1/2] HAVE_SET_RESTORE_SIGMASK
Message-Id: <20080329031146.6FF7126FA1D@magilla.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080329001230.D013726FA1D@magilla.localdomain>
	<20080329001341.7F93826FA1D@magilla.localdomain>
	<alpine.LFD.1.00.0803281746480.14670@woody.linux-foundation.org>
	<20080329022408.0DD4726FA1D@magilla.localdomain>
In-Reply-To: Roland McGrath's message of  Friday, 28 March 2008 19:24:08 -0700 <20080329022408.0DD4726FA1D@magilla.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Linus Torvalds <torvalds@linux-foundation.org>Andrew Morton" <akpm@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Change all the #ifdef TIF_RESTORE_SIGMASK conditionals in non-arch
code to #ifdef HAVE_SET_RESTORE_SIGMASK.  If arch code defines it
first, the generic set_restore_sigmask() using TIF_RESTORE_SIGMASK
is not defined.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 fs/compat.c                 |    8 ++++----
 fs/eventpoll.c              |    4 ++--
 fs/select.c                 |    8 ++++----
 include/linux/sched.h       |    2 +-
 include/linux/thread_info.h |   10 ++++++++--
 5 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 9964d54..139dc93 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1634,7 +1634,7 @@ sticky:
 	return ret;
 }
 
-#ifdef TIF_RESTORE_SIGMASK
+#ifdef HAVE_SET_RESTORE_SIGMASK
 asmlinkage long compat_sys_pselect7(int n, compat_ulong_t __user *inp,
 	compat_ulong_t __user *outp, compat_ulong_t __user *exp,
 	struct compat_timespec __user *tsp, compat_sigset_t __user *sigmask,
@@ -1825,7 +1825,7 @@ sticky:
 
 	return ret;
 }
-#endif /* TIF_RESTORE_SIGMASK */
+#endif /* HAVE_SET_RESTORE_SIGMASK */
 
 #if defined(CONFIG_NFSD) || defined(CONFIG_NFSD_MODULE)
 /* Stuff for NFS server syscalls... */
@@ -2080,7 +2080,7 @@ long asmlinkage compat_sys_nfsservctl(int cmd, void *notused, void *notused2)
 
 #ifdef CONFIG_EPOLL
 
-#ifdef TIF_RESTORE_SIGMASK
+#ifdef HAVE_SET_RESTORE_SIGMASK
 asmlinkage long compat_sys_epoll_pwait(int epfd,
 			struct compat_epoll_event __user *events,
 			int maxevents, int timeout,
@@ -2124,7 +2124,7 @@ asmlinkage long compat_sys_epoll_pwait(int epfd,
 
 	return err;
 }
-#endif /* TIF_RESTORE_SIGMASK */
+#endif /* HAVE_SET_RESTORE_SIGMASK */
 
 #endif /* CONFIG_EPOLL */
 
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 503ffa4..e55451e 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1262,7 +1262,7 @@ error_return:
 	return error;
 }
 
-#ifdef TIF_RESTORE_SIGMASK
+#ifdef HAVE_SET_RESTORE_SIGMASK
 
 /*
  * Implement the event wait interface for the eventpoll file. It is the kernel
@@ -1308,7 +1308,7 @@ asmlinkage long sys_epoll_pwait(int epfd, struct epoll_event __user *events,
 	return error;
 }
 
-#endif /* #ifdef TIF_RESTORE_SIGMASK */
+#endif /* HAVE_SET_RESTORE_SIGMASK */
 
 static int __init eventpoll_init(void)
 {
diff --git a/fs/select.c b/fs/select.c
index bbd351c..c06fe0b 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -425,7 +425,7 @@ sticky:
 	return ret;
 }
 
-#ifdef TIF_RESTORE_SIGMASK
+#ifdef HAVE_SET_RESTORE_SIGMASK
 asmlinkage long sys_pselect7(int n, fd_set __user *inp, fd_set __user *outp,
 		fd_set __user *exp, struct timespec __user *tsp,
 		const sigset_t __user *sigmask, size_t sigsetsize)
@@ -528,7 +528,7 @@ asmlinkage long sys_pselect6(int n, fd_set __user *inp, fd_set __user *outp,
 
 	return sys_pselect7(n, inp, outp, exp, tsp, up, sigsetsize);
 }
-#endif /* TIF_RESTORE_SIGMASK */
+#endif /* HAVE_SET_RESTORE_SIGMASK */
 
 struct poll_list {
 	struct poll_list *next;
@@ -759,7 +759,7 @@ asmlinkage long sys_poll(struct pollfd __user *ufds, unsigned int nfds,
 	return ret;
 }
 
-#ifdef TIF_RESTORE_SIGMASK
+#ifdef HAVE_SET_RESTORE_SIGMASK
 asmlinkage long sys_ppoll(struct pollfd __user *ufds, unsigned int nfds,
 	struct timespec __user *tsp, const sigset_t __user *sigmask,
 	size_t sigsetsize)
@@ -839,4 +839,4 @@ asmlinkage long sys_ppoll(struct pollfd __user *ufds, unsigned int nfds,
 
 	return ret;
 }
-#endif /* TIF_RESTORE_SIGMASK */
+#endif /* HAVE_SET_RESTORE_SIGMASK */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6a1e7af..6c275e8 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1144,7 +1144,7 @@ struct task_struct {
 	struct sighand_struct *sighand;
 
 	sigset_t blocked, real_blocked;
-	sigset_t saved_sigmask;		/* To be restored with TIF_RESTORE_SIGMASK */
+	sigset_t saved_sigmask;	/* restored if set_restore_sigmask() was used */
 	struct sigpending pending;
 
 	unsigned long sas_ss_sp;
diff --git a/include/linux/thread_info.h b/include/linux/thread_info.h
index 4a89477..dbf5daa 100644
--- a/include/linux/thread_info.h
+++ b/include/linux/thread_info.h
@@ -80,7 +80,13 @@ static inline int test_ti_thread_flag(struct thread_info *ti, int flag)
 #define set_need_resched()	set_thread_flag(TIF_NEED_RESCHED)
 #define clear_need_resched()	clear_thread_flag(TIF_NEED_RESCHED)
 
-#ifdef TIF_RESTORE_SIGMASK
+#if defined TIF_RESTORE_SIGMASK && !defined HAVE_SET_RESTORE_SIGMASK
+/*
+ * An arch can define its own version of set_restore_sigmask() to get the
+ * job done however works, with or without TIF_RESTORE_SIGMASK.
+ */
+#define HAVE_SET_RESTORE_SIGMASK	1
+
 /**
  * set_restore_sigmask() - make sure saved_sigmask processing gets done
  *
@@ -97,7 +103,7 @@ static inline void set_restore_sigmask(void)
 	set_thread_flag(TIF_RESTORE_SIGMASK);
 	set_thread_flag(TIF_SIGPENDING);
 }
-#endif	/* TIF_RESTORE_SIGMASK */
+#endif	/* TIF_RESTORE_SIGMASK && !HAVE_SET_RESTORE_SIGMASK */
 
 #endif	/* __KERNEL__ */
 
