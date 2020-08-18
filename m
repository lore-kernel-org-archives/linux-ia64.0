From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Tue, 18 Aug 2020 17:34:06 +0000
Subject: [PATCH 06/11] sparc: switch to kernel_clone()
Message-Id: <20200818173411.404104-7-christian.brauner@ubuntu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200818173411.404104-1-christian.brauner@ubuntu.com>
In-Reply-To: <20200818173411.404104-1-christian.brauner@ubuntu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hewllig <hch@infradead.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-arch@vger.kernel.org
Cc: Jonathan Corbet <corbet@lwn.net>, Yoshinori Sato <ysato@users.sourceforge.jp>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Ley Foon Tan <ley.foon.tan@intel.com>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Steven Rostedt <rostedt@goodmis.org>, Stafford Horne <shorne@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Kars de Jong <jongk@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Greentime Hu <green.hu@gmail.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Mauro Carvalho Chehab <mchehab+huawei@kernel.org>, Alexandre Chartre <alexandre.chartre@oracle.com>, Masami Hiramatsu <mhiramat@kernel.org>, Tom Zanussi <zanussi@kernel.org>, Xiao Yang <yangx.jy@cn.fujitsu.com>, linux-doc@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, kgdb-bugreport@lists.sourceforge.net, linux-kselftest@vger.kernel.org, Christian Brauner <christian.brauner@ubuntu.com>

The old _do_fork() helper is removed in favor of the new kernel_clone() helper.
The latter adheres to naming conventions for kernel internal syscall helpers.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: sparclinux@vger.kernel.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 arch/sparc/kernel/process.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/sparc/kernel/process.c b/arch/sparc/kernel/process.c
index 5234b5ccc0b9..0442ab00518d 100644
--- a/arch/sparc/kernel/process.c
+++ b/arch/sparc/kernel/process.c
@@ -25,7 +25,7 @@ asmlinkage long sparc_fork(struct pt_regs *regs)
 		.stack		= regs->u_regs[UREG_FP],
 	};
 
-	ret = _do_fork(&args);
+	ret = kernel_clone(&args);
 
 	/* If we get an error and potentially restart the system
 	 * call, we're screwed because copy_thread() clobbered
@@ -50,7 +50,7 @@ asmlinkage long sparc_vfork(struct pt_regs *regs)
 		.stack		= regs->u_regs[UREG_FP],
 	};
 
-	ret = _do_fork(&args);
+	ret = kernel_clone(&args);
 
 	/* If we get an error and potentially restart the system
 	 * call, we're screwed because copy_thread() clobbered
@@ -96,7 +96,7 @@ asmlinkage long sparc_clone(struct pt_regs *regs)
 	else
 		args.stack = regs->u_regs[UREG_FP];
 
-	ret = _do_fork(&args);
+	ret = kernel_clone(&args);
 
 	/* If we get an error and potentially restart the system
 	 * call, we're screwed because copy_thread() clobbered
-- 
2.28.0
