From: Christoph Hellwig <hch@lst.de>
Date: Wed, 07 Aug 2019 13:30:44 +0000
Subject: [PATCH 24/29] ia64: move the ROOT_DEV setup to common code
Message-Id: <20190807133049.20893-25-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190807133049.20893-1-hch@lst.de>
In-Reply-To: <20190807133049.20893-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

I'm not sure how useful a platform default ROOT_DEV is these days,
but it pretty sure isn't machvec dependent.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/dig/setup.c    | 9 ---------
 arch/ia64/kernel/setup.c | 9 +++++++++
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/ia64/dig/setup.c b/arch/ia64/dig/setup.c
index cc14fdce6db6..0b1866d2462a 100644
--- a/arch/ia64/dig/setup.c
+++ b/arch/ia64/dig/setup.c
@@ -13,13 +13,11 @@
 #include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/kernel.h>
-#include <linux/kdev_t.h>
 #include <linux/string.h>
 #include <linux/screen_info.h>
 #include <linux/console.h>
 #include <linux/timex.h>
 #include <linux/sched.h>
-#include <linux/root_dev.h>
 
 #include <asm/io.h>
 #include <asm/machvec.h>
@@ -30,13 +28,6 @@ dig_setup (char **cmdline_p)
 {
 	unsigned int orig_x, orig_y, num_cols, num_rows, font_height;
 
-	/*
-	 * Default to /dev/sda2.  This assumes that the EFI partition
-	 * is physical disk 1 partition 1 and the Linux root disk is
-	 * physical disk 1 partition 2.
-	 */
-	ROOT_DEV = Root_SDA2;		/* default to second partition on first drive */
-
 #ifdef CONFIG_SMP
 	init_smp_config();
 #endif
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 8d47836d932c..560f9833c665 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -30,6 +30,7 @@
 #include <linux/console.h>
 #include <linux/delay.h>
 #include <linux/cpu.h>
+#include <linux/kdev_t.h>
 #include <linux/kernel.h>
 #include <linux/memblock.h>
 #include <linux/reboot.h>
@@ -41,6 +42,7 @@
 #include <linux/threads.h>
 #include <linux/screen_info.h>
 #include <linux/dmi.h>
+#include <linux/root_dev.h>
 #include <linux/serial.h>
 #include <linux/serial_core.h>
 #include <linux/efi.h>
@@ -599,6 +601,13 @@ setup_arch (char **cmdline_p)
 	if (!nomca)
 		ia64_mca_init();
 
+	/*
+	 * Default to /dev/sda2.  This assumes that the EFI partition
+	 * is physical disk 1 partition 1 and the Linux root disk is
+	 * physical disk 1 partition 2.
+	 */
+	ROOT_DEV = Root_SDA2;		/* default to second partition on first drive */
+
 	platform_setup(cmdline_p);
 	paging_init();
 
-- 
2.20.1
