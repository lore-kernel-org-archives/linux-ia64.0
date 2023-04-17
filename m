From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Mon, 17 Apr 2023 12:56:49 +0000
Subject: [PATCH v3 17/19] arch/sparc: Implement fb_is_primary_device() in source file
Message-Id: <20230417125651.25126-18-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230417125651.25126-1-tzimmermann@suse.de>
In-Reply-To: <20230417125651.25126-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, "David S. Miller" <davem@davemloft.net>

Other architectures implment fb_is_primary_device() in a source
file. Do the same on sparc. No functional changes, but allows to
remove several include statement from <asm/fb.h>.

v2:
	* don't include <asm/prom.h> in header file

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
---
 arch/sparc/Makefile         |  1 +
 arch/sparc/include/asm/fb.h | 23 +++++------------------
 arch/sparc/video/Makefile   |  3 +++
 arch/sparc/video/fbdev.c    | 24 ++++++++++++++++++++++++
 4 files changed, 33 insertions(+), 18 deletions(-)
 create mode 100644 arch/sparc/video/Makefile
 create mode 100644 arch/sparc/video/fbdev.c

diff --git a/arch/sparc/Makefile b/arch/sparc/Makefile
index a4ea5b05f288..95a9211e48e3 100644
--- a/arch/sparc/Makefile
+++ b/arch/sparc/Makefile
@@ -60,6 +60,7 @@ libs-y                 += arch/sparc/prom/
 libs-y                 += arch/sparc/lib/
 
 drivers-$(CONFIG_PM) += arch/sparc/power/
+drivers-$(CONFIG_FB) += arch/sparc/video/
 
 boot := arch/sparc/boot
 
diff --git a/arch/sparc/include/asm/fb.h b/arch/sparc/include/asm/fb.h
index f699962e9ddf..28609f7a965c 100644
--- a/arch/sparc/include/asm/fb.h
+++ b/arch/sparc/include/asm/fb.h
@@ -1,11 +1,12 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 #ifndef _SPARC_FB_H_
 #define _SPARC_FB_H_
-#include <linux/console.h>
-#include <linux/fb.h>
+
 #include <linux/fs.h>
+
 #include <asm/page.h>
-#include <asm/prom.h>
+
+struct fb_info;
 
 static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 				unsigned long off)
@@ -15,20 +16,6 @@ static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 #endif
 }
 
-static inline int fb_is_primary_device(struct fb_info *info)
-{
-	struct device *dev = info->device;
-	struct device_node *node;
-
-	if (console_set_on_cmdline)
-		return 0;
-
-	node = dev->of_node;
-	if (node &&
-	    node = of_console_device)
-		return 1;
-
-	return 0;
-}
+int fb_is_primary_device(struct fb_info *info);
 
 #endif /* _SPARC_FB_H_ */
diff --git a/arch/sparc/video/Makefile b/arch/sparc/video/Makefile
new file mode 100644
index 000000000000..6baddbd58e4d
--- /dev/null
+++ b/arch/sparc/video/Makefile
@@ -0,0 +1,3 @@
+# SPDX-License-Identifier: GPL-2.0-only
+
+obj-$(CONFIG_FB) += fbdev.o
diff --git a/arch/sparc/video/fbdev.c b/arch/sparc/video/fbdev.c
new file mode 100644
index 000000000000..dadd5799fbb3
--- /dev/null
+++ b/arch/sparc/video/fbdev.c
@@ -0,0 +1,24 @@
+// SPDX-License-Identifier: GPL-2.0
+
+#include <linux/console.h>
+#include <linux/fb.h>
+#include <linux/module.h>
+
+#include <asm/fb.h>
+#include <asm/prom.h>
+
+int fb_is_primary_device(struct fb_info *info)
+{
+	struct device *dev = info->device;
+	struct device_node *node;
+
+	if (console_set_on_cmdline)
+		return 0;
+
+	node = dev->of_node;
+	if (node && node = of_console_device)
+		return 1;
+
+	return 0;
+}
+EXPORT_SYMBOL(fb_is_primary_device);
-- 
2.40.0
