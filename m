From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Date: Sat, 03 May 2003 12:52:34 +0000
Subject: [Linux-ia64] [PATCH 2.5.68] mod_timer fix for sn/kernel/irq.c
Message-Id: <marc-linux-ia64-105590723705631@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Small fix converting {del,add}_timer to mod_timer.

vinay

PS: I am not on the mailing list

--- linux-2.5.68/arch/ia64/sn/kernel/irq.c      2003-03-25
10:07:20.000000000 +0530
+++ linux-2.5.68-nvk/arch/ia64/sn/kernel/irq.c  2003-05-03
16:14:38.000000000 +0530
@@ -310,9 +310,7 @@
                       
bridge->b_force_always[intr_test_registered[i].slot].intr = 1;
                }
        }
-       del_timer(&intr_test_timer);
-       intr_test_timer.expires = jiffies + HZ/100;
-       add_timer(&intr_test_timer);
+       mod_timer(&intr_test_timer, jiffies + HZ/100);
 }

 void




