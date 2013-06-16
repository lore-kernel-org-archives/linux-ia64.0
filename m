From: ddaney.cavm@gmail.com
Date: Sun, 16 Jun 2013 20:06:28 +0000
Subject: [PATCH 1/2] ia64: Fix include dependency in asm/irqflags.h
Message-Id: <1371413189-2568-2-git-send-email-ddaney.cavm@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1371413189-2568-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, linux-am33-list@redhat.com
Cc: david.s.daney@gmail.com, David Daney <ddaney@caviumnetworks.com>, David Daney <david.daney@cavium.com>

From: David Daney <ddaney@caviumnetworks.com>

asm/kregs.h isn't always included first, so we need an explicit include.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/ia64/include/asm/irqflags.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/ia64/include/asm/irqflags.h b/arch/ia64/include/asm/irqflags.h
index 1bf2cf2..cec6c06 100644
--- a/arch/ia64/include/asm/irqflags.h
+++ b/arch/ia64/include/asm/irqflags.h
@@ -11,6 +11,7 @@
 #define _ASM_IA64_IRQFLAGS_H
 
 #include <asm/pal.h>
+#include <asm/kregs.h>
 
 #ifdef CONFIG_IA64_DEBUG_IRQ
 extern unsigned long last_cli_ip;
-- 
1.7.11.7

