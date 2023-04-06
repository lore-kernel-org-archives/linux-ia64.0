From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Thu, 06 Apr 2023 14:30:18 +0000
Subject: [PATCH v2 18/19] arch/sparc: Implement <asm/fb.h> with generic helpers
Message-Id: <20230406143019.6709-19-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de>
In-Reply-To: <20230406143019.6709-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, "David S. Miller" <davem@davemloft.net>

Include <asm-generic/fb.h> for correctness. Sparc does provide
it's own implementation of the contained functions.

v2:
	* restore the original fb_pgprotect()

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Cc: "David S. Miller" <davem@davemloft.net>
---
 arch/sparc/include/asm/fb.h | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/sparc/include/asm/fb.h b/arch/sparc/include/asm/fb.h
index 28609f7a965c..496e58d22e7b 100644
--- a/arch/sparc/include/asm/fb.h
+++ b/arch/sparc/include/asm/fb.h
@@ -2,11 +2,10 @@
 #ifndef _SPARC_FB_H_
 #define _SPARC_FB_H_
 
-#include <linux/fs.h>
-
 #include <asm/page.h>
 
 struct fb_info;
+struct file;
 
 static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 				unsigned long off)
@@ -15,7 +14,11 @@ static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
 	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
 #endif
 }
+#define fb_pgprotect fb_pgprotect
 
 int fb_is_primary_device(struct fb_info *info);
+#define fb_is_primary_device fb_is_primary_device
+
+#include <asm-generic/fb.h>
 
 #endif /* _SPARC_FB_H_ */
-- 
2.40.0
