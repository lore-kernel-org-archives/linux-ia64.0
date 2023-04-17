From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Mon, 17 Apr 2023 12:56:50 +0000
Subject: [PATCH v3 18/19] arch/sparc: Implement <asm/fb.h> with generic helpers
Message-Id: <20230417125651.25126-19-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230417125651.25126-1-tzimmermann@suse.de>
In-Reply-To: <20230417125651.25126-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, linux-parisc@vger.kernel.org, linux-sh@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mips@vger.kernel.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linuxppc-dev@lists.ozlabs.org, "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org

Replace sparc64's fb_pgprotect() with the generic one
from <asm-generic/fb.h>. On sparc, pgprot_writecombine() and
pgprot_noncached() are the same; hence no functional changes

v3:
	* use default implementation for fb_pgprotect() on
	  sparc64 (Arnd)
v2:
	* restore the original fb_pgprotect()

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
---
 arch/sparc/include/asm/fb.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/sparc/include/asm/fb.h b/arch/sparc/include/asm/fb.h
index 28609f7a965c..689ee5c60054 100644
--- a/arch/sparc/include/asm/fb.h
+++ b/arch/sparc/include/asm/fb.h
@@ -2,20 +2,20 @@
 #ifndef _SPARC_FB_H_
 #define _SPARC_FB_H_
 
-#include <linux/fs.h>
-
-#include <asm/page.h>
-
 struct fb_info;
+struct file;
+struct vm_area_struct;
 
+#ifdef CONFIG_SPARC32
 static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 				unsigned long off)
-{
-#ifdef CONFIG_SPARC64
-	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+{ }
+#define fb_pgprotect fb_pgprotect
 #endif
-}
 
 int fb_is_primary_device(struct fb_info *info);
+#define fb_is_primary_device fb_is_primary_device
+
+#include <asm-generic/fb.h>
 
 #endif /* _SPARC_FB_H_ */
-- 
2.40.0
