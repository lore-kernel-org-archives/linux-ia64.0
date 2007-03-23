From: Bernhard Walle <bwalle@suse.de>
Date: Fri, 23 Mar 2007 16:44:49 +0000
Subject: [patch 2/7] Add IRQF_IRQPOLL_IRQ flag on IA64
Message-Id: <20070323190112.007833000@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070323164447.659982000@strauss.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, linux-ia64@vger.kernel.org

Add IRQF_IRQPOLL_IRQ for the timer interrupt on IA64.

Signed-off-by: Bernhard Walle <bwalle@suse.de>
---
 arch/ia64/kernel/time.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.21-rc4-mm1/arch/ia64/kernel/time.c
=================================--- linux-2.6.21-rc4-mm1.orig/arch/ia64/kernel/time.c
+++ linux-2.6.21-rc4-mm1/arch/ia64/kernel/time.c
@@ -235,7 +235,7 @@ ia64_init_itm (void)
 
 static struct irqaction timer_irqaction = {
 	.handler =	timer_interrupt,
-	.flags =	IRQF_DISABLED,
+	.flags =	IRQF_DISABLED | IRQF_IRQPOLL_IRQ,
 	.name =		"timer"
 };
 

-- 
