From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Date: Mon, 07 Jan 2019 09:54:33 +0000
Subject: [PATCH] ia64: tweak BREAK_LOGLEVEL and RESTORE_LOGLEVEL
Message-Id: <20190107095433.6497-1-sergey.senozhatsky@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

a) Do not pass console_loglevel to macros, use console_loglevel directly.
b) Use CONSOLE_LOGLEVEL_MOTORMOUTH instead of a naked number
c) Use bust_spinlocks() to set/clear oops_in_progress
d) Fix checkpatch error: Macros with multiple statements should be
                         enclosed in a do - while loop

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 arch/ia64/kernel/mca.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 91bd1e129379..06fb40f5c2d6 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -188,19 +188,23 @@ static unsigned int mlogbuf_finished = 0;
 static unsigned long mlogbuf_timestamp = 0;
 
 static int loglevel_save = -1;
-#define BREAK_LOGLEVEL(__console_loglevel)		\
-	oops_in_progress = 1;				\
-	if (loglevel_save < 0)				\
-		loglevel_save = __console_loglevel;	\
-	__console_loglevel = 15;
-
-#define RESTORE_LOGLEVEL(__console_loglevel)		\
-	if (loglevel_save >= 0) {			\
-		__console_loglevel = loglevel_save;	\
-		loglevel_save = -1;			\
-	}						\
-	mlogbuf_finished = 0;				\
-	oops_in_progress = 0;
+#define BREAK_LOGLEVEL()					\
+	do {							\
+		bust_spinlocks(1);				\
+		if (loglevel_save < 0)				\
+			loglevel_save = __console_loglevel;	\
+		console_loglevel = CONSOLE_LOGLEVEL_MOTORMOUTH;	\
+	} while (0)
+
+#define RESTORE_LOGLEVEL()					\
+	do {							\
+		if (loglevel_save >= 0) {			\
+			console_loglevel = loglevel_save;	\
+			loglevel_save = -1;			\
+		}						\
+		mlogbuf_finished = 0;				\
+		bust_spinlocks(0);				\
+	} while (0)
 
 /*
  * Push messages into buffer, print them later if not urgent.
@@ -287,7 +291,7 @@ EXPORT_SYMBOL(ia64_mlogbuf_dump);
  */
 static void ia64_mlogbuf_finish(int wait)
 {
-	BREAK_LOGLEVEL(console_loglevel);
+	BREAK_LOGLEVEL();
 
 	spin_lock_init(&mlogbuf_rlock);
 	ia64_mlogbuf_dump();
@@ -1616,7 +1620,7 @@ default_monarch_init_process(struct notifier_block *self, unsigned long val, voi
 	 * To enable show_stack from INIT, we use oops_in_progress which should
 	 * be used in real oops. This would cause something wrong after INIT.
 	 */
-	BREAK_LOGLEVEL(console_loglevel);
+	BREAK_LOGLEVEL();
 	ia64_mlogbuf_dump_from_init();
 
 	printk(KERN_ERR "Processes interrupted by INIT -");
@@ -1641,7 +1645,7 @@ default_monarch_init_process(struct notifier_block *self, unsigned long val, voi
 		read_unlock(&tasklist_lock);
 	}
 	/* FIXME: This will not restore zapped printk locks. */
-	RESTORE_LOGLEVEL(console_loglevel);
+	RESTORE_LOGLEVEL();
 	return NOTIFY_DONE;
 }
 
-- 
2.20.1
