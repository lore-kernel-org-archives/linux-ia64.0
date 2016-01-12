From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Tue, 12 Jan 2016 13:22:46 +0000
Subject: [PATCH v2 2/2] efi: include asm/early_ioremap.h not asm/efi.h to get early_memremap
Message-Id: <1452604966-9905-2-git-send-email-ard.biesheuvel@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1452604966-9905-1-git-send-email-ard.biesheuvel@linaro.org>
In-Reply-To: <1452604966-9905-1-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-efi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, matt-mF/unelCI9GS6iBeEJttW/XRex20P6io@public.gmane.org, fenghua.yu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc: will.deacon-5wv7dgnIgG8@public.gmane.org, Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>

The code in efi.c uses early_memremap(), but relies on a transitive
include rather than including asm/early_ioremap.h directly, since
this header did not exist on ia64.

Commit f7d924894265 ("arm64/efi: refactor EFI init and runtime code
for reuse by 32-bit ARM") attempted to work around this by including
asm/efi.h, which transitively includes asm/early_ioremap.h on most
architectures. However, since asm/efi.h does not exist on ia64 either,
this is not much of an improvement.

Now that we have created an asm/early_ioremap.h for ia64, we can just
include it directly.

Reported-by: Guenter Roeck <linux@roeck-us.net>
Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
---
 drivers/firmware/efi/efi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/firmware/efi/efi.c b/drivers/firmware/efi/efi.c
index cffa89b3317b..2cd37dad67a6 100644
--- a/drivers/firmware/efi/efi.c
+++ b/drivers/firmware/efi/efi.c
@@ -25,7 +25,7 @@
 #include <linux/io.h>
 #include <linux/platform_device.h>
 
-#include <asm/efi.h>
+#include <asm/early_ioremap.h>
 
 struct efi __read_mostly efi = {
 	.mps			= EFI_INVALID_TABLE_ADDR,
-- 
2.5.0

