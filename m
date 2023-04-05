From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Wed, 05 Apr 2023 15:05:51 +0000
Subject: [PATCH 15/18] arch/sh: Implement <asm/fb.h> with generic helpers
Message-Id: <20230405150554.30540-16-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230405150554.30540-1-tzimmermann@suse.de>
In-Reply-To: <20230405150554.30540-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, Yoshinori Sato <ysato@users.sourceforge.jp>, loongarch@lists.linux.dev, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

Replace the architecture's fb_is_primary_device() with the generic
one from <asm-generic/fb.h>. No functional changes.

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
---
 arch/sh/include/asm/fb.h | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/arch/sh/include/asm/fb.h b/arch/sh/include/asm/fb.h
index 9a0bca2686fd..1e7b1cfd5b5e 100644
--- a/arch/sh/include/asm/fb.h
+++ b/arch/sh/include/asm/fb.h
@@ -2,19 +2,17 @@
 #ifndef _ASM_FB_H_
 #define _ASM_FB_H_
 
-#include <linux/fb.h>
-#include <linux/fs.h>
 #include <asm/page.h>
 
+struct file;
+
 static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 				unsigned long off)
 {
 	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
 }
+#define fb_pgprotect fb_pgprotect
 
-static inline int fb_is_primary_device(struct fb_info *info)
-{
-	return 0;
-}
+#include <asm-generic/fb.h>
 
 #endif /* _ASM_FB_H_ */
-- 
2.40.0
