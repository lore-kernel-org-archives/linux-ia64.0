From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Wed, 05 Apr 2023 15:05:37 +0000
Subject: [PATCH 01/18] fbdev: Prepare generic architecture helpers
Message-Id: <20230405150554.30540-2-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230405150554.30540-1-tzimmermann@suse.de>
In-Reply-To: <20230405150554.30540-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Zimmermann <tzimmermann@suse.de>

Generic implementations of fb_pgprotect() and fb_is_primary_device()
have been in the source code for a long time. Prepare the header file
to make use of them.

Improve the code by using an inline function for fb_pgprotect() and
by removing include statements.

Symbols are protected by preprocessor guards. Architectures that
provide a symbol need to define a preprocessor token of the same
name and value. Otherwise the header file will provide a generic
implementation. This pattern has been taken from <asm/io.h>.

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
---
 include/asm-generic/fb.h | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/fb.h b/include/asm-generic/fb.h
index f9f18101ed36..cb42166e7e11 100644
--- a/include/asm-generic/fb.h
+++ b/include/asm-generic/fb.h
@@ -1,13 +1,29 @@
 /* SPDX-License-Identifier: GPL-2.0 */
+
 #ifndef __ASM_GENERIC_FB_H_
 #define __ASM_GENERIC_FB_H_
-#include <linux/fb.h>
 
-#define fb_pgprotect(...) do {} while (0)
+/*
+ * Only include this header file from your architecture's <asm/fb.h>.
+ */
+
+struct fb_info;
+struct file;
+struct vm_area_struct;
+
+#ifndef fb_pgprotect
+#define fb_pgprotect fb_pgprotect
+static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
+				unsigned long off)
+{ }
+#endif
 
+#ifndef fb_is_primary_device
+#define fb_is_primary_device fb_is_primary_device
 static inline int fb_is_primary_device(struct fb_info *info)
 {
 	return 0;
 }
+#endif
 
 #endif /* __ASM_GENERIC_FB_H_ */
-- 
2.40.0
