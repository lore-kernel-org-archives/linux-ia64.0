From: Jiri Slaby <jslaby@suse.cz>
Date: Fri, 24 Feb 2012 11:10:16 +0000
Subject: [PATCH 2/4] IA64: simserial, include some headers
Message-Id: <1330081818-15517-2-git-send-email-jslaby@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1330081818-15517-1-git-send-email-jslaby@suse.cz>
In-Reply-To: <1330081818-15517-1-git-send-email-jslaby@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com

And remove declarations which are already in the headers.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 arch/ia64/hp/sim/simserial.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/arch/ia64/hp/sim/simserial.c b/arch/ia64/hp/sim/simserial.c
index bff0824..974cac8 100644
--- a/arch/ia64/hp/sim/simserial.c
+++ b/arch/ia64/hp/sim/simserial.c
@@ -34,9 +34,12 @@
 #include <linux/sysrq.h>
 
 #include <asm/irq.h>
+#include <asm/hpsim.h>
 #include <asm/hw_irq.h>
 #include <asm/uaccess.h>
 
+#include "hpsim_ssc.h"
+
 #undef SIMSERIAL_DEBUG	/* define this to get some debug information */
 
 #define KEYBOARD_INTR	3	/* must match with simulator! */
@@ -45,11 +48,6 @@
 
 #define IRQ_T(info) ((info->flags & ASYNC_SHARE_IRQ) ? IRQF_SHARED : IRQF_DISABLED)
 
-#define SSC_GETCHAR	21
-
-extern long ia64_ssc (long, long, long, long, int);
-extern void ia64_ssc_connect_irq (long intr, long irq);
-
 static char *serial_name = "SimSerial driver";
 static char *serial_version = "0.6";
 
-- 
1.7.9


