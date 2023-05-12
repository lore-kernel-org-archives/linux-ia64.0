From: Thomas Zimmermann <tzimmermann@suse.de>
Date: Fri, 12 May 2023 10:24:40 +0000
Subject: [PATCH v7 3/7] ipu-v3: Include <linux/io.h>
Message-Id: <20230512102444.5438-4-tzimmermann@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230512102444.5438-1-tzimmermann@suse.de>
In-Reply-To: <20230512102444.5438-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@HansenPartnership.com, arnd@arndb.de, sam@ravnborg.org, suijingfeng@loongson.cn
Cc: linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>

The code uses readl() and writel(). Include the header file to
get the declarations.

Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
Reviewed-by: Sam Ravnborg <sam@ravnborg.org>
Reviewed-by: Sui Jingfeng <suijingfeng@loongson.cn>
---
 drivers/gpu/ipu-v3/ipu-prv.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/gpu/ipu-v3/ipu-prv.h b/drivers/gpu/ipu-v3/ipu-prv.h
index 291ac1bab66d..d4621b1ea7f1 100644
--- a/drivers/gpu/ipu-v3/ipu-prv.h
+++ b/drivers/gpu/ipu-v3/ipu-prv.h
@@ -8,6 +8,7 @@
 
 struct ipu_soc;
 
+#include <linux/io.h>
 #include <linux/types.h>
 #include <linux/device.h>
 #include <linux/clk.h>
-- 
2.40.1
