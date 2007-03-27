From: Bernhard Walle <bwalle@suse.de>
Date: Tue, 27 Mar 2007 20:22:38 +0000
Subject: [patch 4/7] Add IRQF_IRQPOLL flag on IA64
Message-Id: <20070327204728.886538000@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070327202234.639415000@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>

Add IRQF_IRQPOLL for the timer interrupt on IA64.

Signed-off-by: Bernhard Walle <bwalle@suse.de>
---
 arch/ia64/kernel/time.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.21-rc5-mm2/arch/ia64/kernel/time.c
=================================--- linux-2.6.21-rc5-mm2.orig/arch/ia64/kernel/time.c
+++ linux-2.6.21-rc5-mm2/arch/ia64/kernel/time.c
@@ -235,7 +235,7 @@ ia64_init_itm (void)
 
 static struct irqaction timer_irqaction = {
 	.handler =	timer_interrupt,
-	.flags =	IRQF_DISABLED,
+	.flags =	IRQF_DISABLED | IRQF_IRQPOLL,
 	.name =		"timer"
 };
 

-- 
