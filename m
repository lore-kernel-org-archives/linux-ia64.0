From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Thu, 06 Apr 2023 14:30:04 +0000
Subject: [PATCH v2 04/19] arch/arm64: Implement <asm/fb.h> with generic helpers
Message-Id: <20230406143019.6709-5-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de>
In-Reply-To: <20230406143019.6709-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org
Cc: linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>

Replace the architecture's fbdev helpers with the generic
ones from <asm-generic/fb.h>. No functional changes.

v2:
	* use default implementation for fb_pgprotect() (Arnd)

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
---
 arch/arm64/include/asm/fb.h | 15 +--------------
 1 file changed, 1 insertion(+), 14 deletions(-)

diff --git a/arch/arm64/include/asm/fb.h b/arch/arm64/include/asm/fb.h
index bdc735ee1f67..1a495d8fb2ce 100644
--- a/arch/arm64/include/asm/fb.h
+++ b/arch/arm64/include/asm/fb.h
@@ -5,19 +5,6 @@
 #ifndef __ASM_FB_H_
 #define __ASM_FB_H_
 
-#include <linux/fb.h>
-#include <linux/fs.h>
-#include <asm/page.h>
-
-static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
-				unsigned long off)
-{
-	vma->vm_page_prot = pgprot_writecombine(vma->vm_page_prot);
-}
-
-static inline int fb_is_primary_device(struct fb_info *info)
-{
-	return 0;
-}
+#include <asm-generic/fb.h>
 
 #endif /* __ASM_FB_H_ */
-- 
2.40.0
