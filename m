From: Vinay K Nallamothu <vinay-rc@naturesoft.net>
Date: Wed, 07 May 2003 05:16:02 +0000
Subject: [Linux-ia64] [PATCH 2.5.69] IA64 sn mod_timer fixes for kernel/mca.c
Message-Id: <marc-linux-ia64-105590723705648@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

mca.c: Trivial {del,add}_timer to mod_timer conversion.

Thanks
vinay

--- linux-2.5.69/arch/ia64/sn/kernel/mca.c	2003-03-25 10:07:20.000000000 +0530
+++ linux-2.5.69-nvk/arch/ia64/sn/kernel/mca.c	2003-05-07 10:11:42.000000000 +0530
@@ -246,9 +246,7 @@
 void
 sn_cpei_timer_handler(unsigned long dummy) {
         sn_cpei_handler(-1, NULL, NULL);
-        del_timer(&sn_cpei_timer);
-        sn_cpei_timer.expires = jiffies + CPEI_INTERVAL;
-        add_timer(&sn_cpei_timer);
+        mod_timer(&sn_cpei_timer, jiffies + CPEI_INTERVAL);
 }
 
 void
@@ -267,9 +265,7 @@
         unsigned long *pi_ce_error_inject_reg = 0xc00000092fffff00;
 
         *pi_ce_error_inject_reg = 0x0000000000000100;
-        del_timer(&sn_ce_timer);
-        sn_ce_timer.expires = jiffies + CPEI_INTERVAL;
-        add_timer(&sn_ce_timer);
+        mod_timer(&sn_ce_timer, jiifies + CPEI_INTERVAL);
 }
 
 sn_init_ce_timer() {




