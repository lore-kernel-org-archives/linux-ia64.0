From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Wed, 05 Apr 2023 15:05:53 +0000
Subject: [PATCH 17/18] arch/sparc: Implement <asm/fb.h> with generic helpers
Message-Id: <20230405150554.30540-18-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230405150554.30540-1-tzimmermann@suse.de>
In-Reply-To: <20230405150554.30540-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, "David S. Miller" <davem@davemloft.net>

Replace the architecture's fb_pgprotect() with the generic one
from <asm-generic/fb.h> on 32-bit builds. No functional changes.

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
---
 arch/sparc/include/asm/fb.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/arch/sparc/include/asm/fb.h b/arch/sparc/include/asm/fb.h
index e4ef1955b2b6..da411d77bafb 100644
--- a/arch/sparc/include/asm/fb.h
+++ b/arch/sparc/include/asm/fb.h
@@ -5,18 +5,22 @@
 #include <linux/fs.h>
 
 #include <asm/page.h>
-#include <asm/prom.h>
 
 struct fb_info;
+struct file;
 
+#ifdef CONFIG_SPARC64
 static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 				unsigned long off)
 {
-#ifdef CONFIG_SPARC64
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
-#endif
 }
+#define fb_pgprotect fb_pgprotect
+#endif
 
 int fb_is_primary_device(struct fb_info *info);
+#define fb_is_primary_device fb_is_primary_device
+
+#include <asm-generic/fb.h>
 
 #endif /* _SPARC_FB_H_ */
-- 
2.40.0
