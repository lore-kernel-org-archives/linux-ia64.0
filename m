From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Wed, 19 Aug 2020 10:46:55 +0000
Subject: [PATCH v2 11/11] sched: remove _do_fork()
Message-Id: <20200819104655.436656-12-christian.brauner@ubuntu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200819104655.436656-1-christian.brauner@ubuntu.com>
In-Reply-To: <20200819104655.436656-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ley Foon Tan <ley.foon.tan@intel.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, Stafford Horne <shorne@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Kars de Jong <jongk@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Greentime Hu <green.hu@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Mauro Carvalho Chehab <mchehab+huawei@kernel.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, Masami Hiramatsu <mhiramat@kernel.org>, Tom Zanussi <zanussi@kernel.org>, Xiao Yang <yangx.jy@cn.fujitsu.com>, linux-doc@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-kselftest@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hewllig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, Christian Brauner <christian.brauner@ubuntu.com>

Now that all callers of _do_fork() have been switched to kernel_clone() remove
the _do_fork() helper.

Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
/* v2 */
unchanged
---
 include/linux/sched/task.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/include/linux/sched/task.h b/include/linux/sched/task.h
index d4428039c3c1..85fb2f34c59b 100644
--- a/include/linux/sched/task.h
+++ b/include/linux/sched/task.h
@@ -84,10 +84,6 @@ extern void exit_files(struct task_struct *);
 extern void exit_itimers(struct signal_struct *);
 
 extern pid_t kernel_clone(struct kernel_clone_args *kargs);
-static inline long _do_fork(struct kernel_clone_args *kargs)
-{
-	return kernel_clone(kargs);
-}
 struct task_struct *fork_idle(int);
 struct mm_struct *copy_init_mm(void);
 extern pid_t kernel_thread(int (*fn)(void *), void *arg, unsigned long flags);
-- 
2.28.0
