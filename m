From: Keith Owens <kaos@sgi.com>
Date: Wed, 17 Aug 2005 05:40:29 +0000
Subject: [Review 7/7] MCA/INIT Turn off PAL halt
Message-Id: <7895.1124257229@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Turn off PAL halt.  For some reason, INIT that is delivered while the
cpu is in PAL halt gets corrupt registers on return from the INIT
handler.  I am still investigating this, for now skip the PAL halt.

 process.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: linux/arch/ia64/kernel/process.c
=================================--- linux.orig/arch/ia64/kernel/process.c	2005-08-17 14:34:38.544845473 +1000
+++ linux/arch/ia64/kernel/process.c	2005-08-17 14:34:56.936456452 +1000
@@ -198,7 +198,7 @@ default_idle (void)
 {
 	local_irq_enable();
 	while (!need_resched())
-		if (can_do_pal_halt)
+		if (0 && can_do_pal_halt)
 			safe_halt();
 		else
 			cpu_relax();


