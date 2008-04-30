From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Wed, 30 Apr 2008 07:50:43 +0000
Subject: [PATCH] ia64: fix section mismatch in arch/ia64/kernel/irq.c
Message-Id: <481824D3.1060508@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <481824BE.2000409@jp.fujitsu.com>
In-Reply-To: <481824BE.2000409@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch shuts up the following:

	WARNING: vmlinux.o(.text+0x7102): Section mismatch in
	reference from the function fixup_irqs() to the function
	.devinit.text:ia64_disable_timer()

Removing ia64_disable_timer() is safe because there are no functions
calling it other than the fixup_irqs(),

Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
---
 arch/ia64/kernel/irq.c  |    4 ++--
 arch/ia64/kernel/time.c |    5 -----
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/irq.c b/arch/ia64/kernel/irq.c
index 6dee579..7fd18f5 100644
--- a/arch/ia64/kernel/irq.c
+++ b/arch/ia64/kernel/irq.c
@@ -183,10 +183,10 @@ void fixup_irqs(void)
 {
 	unsigned int irq;
 	extern void ia64_process_pending_intr(void);
-	extern void ia64_disable_timer(void);
 	extern volatile int time_keeper_id;
 
-	ia64_disable_timer();
+	/* Mask ITV to disable timer */
+	ia64_set_itv(1 << 16);
 
 	/*
 	 * Find a new timesync master
diff --git a/arch/ia64/kernel/time.c b/arch/ia64/kernel/time.c
index 48e15a5..8c73643 100644
--- a/arch/ia64/kernel/time.c
+++ b/arch/ia64/kernel/time.c
@@ -379,11 +379,6 @@ static struct irqaction timer_irqaction = {
 	.name =		"timer"
 };
 
-void __devinit ia64_disable_timer(void)
-{
-	ia64_set_itv(1 << 16);
-}
-
 void __init
 time_init (void)
 {
