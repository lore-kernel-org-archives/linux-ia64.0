From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Date: Wed, 07 May 2003 05:11:54 +0000
Subject: [Linux-ia64] [PATCH 2.{4,5}.x] IA64 SN mod_timer fix for kernel/irq.c
Message-Id: <marc-linux-ia64-105590723705647@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

irq.c: Remove {del,add}_timer to use mod_timer.

--- linux-2.5.68/arch/ia64/sn/kernel/irq.c	2003-03-25 10:07:20.000000000 +0530
+++ linux-2.5.68-nvk/arch/ia64/sn/kernel/irq.c	2003-05-03 16:14:38.000000000 +0530
@@ -310,9 +310,7 @@
 			bridge->b_force_always[intr_test_registered[i].slot].intr = 1;
 		}
 	}
-	del_timer(&intr_test_timer);
-	intr_test_timer.expires = jiffies + HZ/100;
-	add_timer(&intr_test_timer);
+	mod_timer(&intr_test_timer, jiffies + HZ/100);
 }
 
 void




