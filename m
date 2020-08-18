From: Christian Brauner <christian.brauner@ubuntu.com>
Date: Tue, 18 Aug 2020 17:34:04 +0000
Subject: [PATCH 04/11] m68k: switch to kernel_clone()
Message-Id: <20200818173411.404104-5-christian.brauner@ubuntu.com>
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

Cc: Kars de Jong <jongk@linux-m68k.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-m68k@lists.linux-m68k.org
Signed-off-by: Christian Brauner <christian.brauner@ubuntu.com>
---
 arch/m68k/kernel/process.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/m68k/kernel/process.c b/arch/m68k/kernel/process.c
index 6492a2c54dbc..08359a6e058f 100644
--- a/arch/m68k/kernel/process.c
+++ b/arch/m68k/kernel/process.c
@@ -107,10 +107,10 @@ void flush_thread(void)
  * on top of pt_regs, which means that sys_clone() arguments would be
  * buried.  We could, of course, copy them, but it's too costly for no
  * good reason - generic clone() would have to copy them *again* for
- * _do_fork() anyway.  So in this case it's actually better to pass pt_regs *
- * and extract arguments for _do_fork() from there.  Eventually we might
- * go for calling _do_fork() directly from the wrapper, but only after we
- * are finished with _do_fork() prototype conversion.
+ * kernel_clone() anyway.  So in this case it's actually better to pass pt_regs *
+ * and extract arguments for kernel_clone() from there.  Eventually we might
+ * go for calling kernel_clone() directly from the wrapper, but only after we
+ * are finished with kernel_clone() prototype conversion.
  */
 asmlinkage int m68k_clone(struct pt_regs *regs)
 {
@@ -125,7 +125,7 @@ asmlinkage int m68k_clone(struct pt_regs *regs)
 		.tls		= regs->d5,
 	};
 
-	return _do_fork(&args);
+	return kernel_clone(&args);
 }
 
 /*
-- 
2.28.0
