From: Christoph Hellwig <hch@lst.de>
Date: Tue, 13 Aug 2019 07:25:11 +0000
Subject: [PATCH 25/28] ia64: move the screen_info setup to common code
Message-Id: <20190813072514.23299-26-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190813072514.23299-1-hch@lst.de>
In-Reply-To: <20190813072514.23299-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Mike Travis <mike.travis@hpe.com>, Dimitri Sivanich <sivanich@hpe.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-ide@vger.kernel.org, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org

There is nothing really platform specific about setting about the
screen_info from the ia64_boot_param structure, so move it from the
dig machvec to common code.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/dig/setup.c    | 30 ------------------------------
 arch/ia64/kernel/setup.c | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/dig/setup.c b/arch/ia64/dig/setup.c
index 0b1866d2462a..ca8be4617b2e 100644
--- a/arch/ia64/dig/setup.c
+++ b/arch/ia64/dig/setup.c
@@ -26,37 +26,7 @@
 void __init
 dig_setup (char **cmdline_p)
 {
-	unsigned int orig_x, orig_y, num_cols, num_rows, font_height;
-
 #ifdef CONFIG_SMP
 	init_smp_config();
 #endif
-
-	memset(&screen_info, 0, sizeof(screen_info));
-
-	if (!ia64_boot_param->console_info.num_rows
-	    || !ia64_boot_param->console_info.num_cols)
-	{
-		printk(KERN_WARNING "dig_setup: warning: invalid screen-info, guessing 80x25\n");
-		orig_x = 0;
-		orig_y = 0;
-		num_cols = 80;
-		num_rows = 25;
-		font_height = 16;
-	} else {
-		orig_x = ia64_boot_param->console_info.orig_x;
-		orig_y = ia64_boot_param->console_info.orig_y;
-		num_cols = ia64_boot_param->console_info.num_cols;
-		num_rows = ia64_boot_param->console_info.num_rows;
-		font_height = 400 / num_rows;
-	}
-
-	screen_info.orig_x = orig_x;
-	screen_info.orig_y = orig_y;
-	screen_info.orig_video_cols  = num_cols;
-	screen_info.orig_video_lines = num_rows;
-	screen_info.orig_video_points = font_height;
-	screen_info.orig_video_mode = 3;	/* XXX fake */
-	screen_info.orig_video_isVGA = 1;	/* XXX fake */
-	screen_info.orig_video_ega_bx = 3;	/* XXX fake */
 }
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 560f9833c665..65d07c60f12d 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -469,6 +469,39 @@ early_console_setup (char *cmdline)
 	return -1;
 }
 
+static void __init
+screen_info_setup(void)
+{
+	unsigned int orig_x, orig_y, num_cols, num_rows, font_height;
+
+	memset(&screen_info, 0, sizeof(screen_info));
+
+	if (!ia64_boot_param->console_info.num_rows ||
+	    !ia64_boot_param->console_info.num_cols) {
+		printk(KERN_WARNING "invalid screen-info, guessing 80x25\n");
+		orig_x = 0;
+		orig_y = 0;
+		num_cols = 80;
+		num_rows = 25;
+		font_height = 16;
+	} else {
+		orig_x = ia64_boot_param->console_info.orig_x;
+		orig_y = ia64_boot_param->console_info.orig_y;
+		num_cols = ia64_boot_param->console_info.num_cols;
+		num_rows = ia64_boot_param->console_info.num_rows;
+		font_height = 400 / num_rows;
+	}
+
+	screen_info.orig_x = orig_x;
+	screen_info.orig_y = orig_y;
+	screen_info.orig_video_cols  = num_cols;
+	screen_info.orig_video_lines = num_rows;
+	screen_info.orig_video_points = font_height;
+	screen_info.orig_video_mode = 3;	/* XXX fake */
+	screen_info.orig_video_isVGA = 1;	/* XXX fake */
+	screen_info.orig_video_ega_bx = 3;	/* XXX fake */
+}
+
 static inline void
 mark_bsp_online (void)
 {
@@ -609,6 +642,7 @@ setup_arch (char **cmdline_p)
 	ROOT_DEV = Root_SDA2;		/* default to second partition on first drive */
 
 	platform_setup(cmdline_p);
+	screen_info_setup();
 	paging_init();
 
 	clear_sched_clock_stable();
-- 
2.20.1
