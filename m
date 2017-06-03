From: Christoph Hellwig <hch@lst.de>
Date: Sat, 03 Jun 2017 19:01:00 +0000
Subject: [PATCH 3/5] posix-timers: move the do_schedule_next_timer declaration
Message-Id: <20170603190102.28866-4-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170603190102.28866-1-hch@lst.de>
In-Reply-To: <20170603190102.28866-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-arch@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Having it in asm-generic/siginfo.h doesn't make any sense as it is in no way
architecture specific.  Move it to posix-timers.h instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/asm-generic/siginfo.h | 1 -
 include/linux/posix-timers.h  | 3 +++
 kernel/signal.c               | 1 +
 3 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
index a2508a8f9a9c..5a9394763a66 100644
--- a/include/asm-generic/siginfo.h
+++ b/include/asm-generic/siginfo.h
@@ -15,7 +15,6 @@
 #define __SI_CODE(T,N)	((T) | ((N) & 0xffff))
 
 struct siginfo;
-void do_schedule_next_timer(struct siginfo *info);
 
 extern int copy_siginfo_to_user(struct siginfo __user *to, const struct siginfo *from);
 
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 8c1e43ab14a9..fa25c23192a4 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -7,6 +7,7 @@
 #include <linux/timex.h>
 #include <linux/alarmtimer.h>
 
+struct siginfo;
 
 struct cpu_timer_list {
 	struct list_head entry;
@@ -125,4 +126,6 @@ long clock_nanosleep_restart(struct restart_block *restart_block);
 
 void update_rlimit_cpu(struct task_struct *task, unsigned long rlim_new);
 
+void do_schedule_next_timer(struct siginfo *info);
+
 #endif
diff --git a/kernel/signal.c b/kernel/signal.c
index ca92bcfeb322..1f85c843be8e 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -39,6 +39,7 @@
 #include <linux/compat.h>
 #include <linux/cn_proc.h>
 #include <linux/compiler.h>
+#include <linux/posix-timers.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/signal.h>
-- 
2.11.0

