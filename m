From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Thu, 24 Jun 2004 06:05:55 +0000
Subject: [PATCH] Quiet corrected errors (CMC/CPE)
Message-Id: <0HZS006RBU9VGJ@fjmail504.fjmail.jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

I think we don't always need this message to printk.

Is it better to have a choice between a daemon-A which quickly alerts
a user to the error or a daemon-B which silently takes the error statistic,
or a quiet with no daemon?

...BTW, could anyone tell me a link to the most recent salinfo_decode?


Thanks,
H.Seto

-----

diff -Nur linux-2.6.7/arch/ia64/kernel/mca.c linux-2.6.7-noprintk/arch/ia64/kernel/mca.c
--- linux-2.6.7/arch/ia64/kernel/mca.c  2004-06-24 14:04:32.000000000 +0900
+++ linux-2.6.7-noprintk/arch/ia64/kernel/mca.c 2004-06-24 14:05:14.000000000 +0900
@@ -253,7 +253,7 @@
        salinfo_log_wakeup(sal_info_type, buffer, size, irq_safe);

        if (irq_safe)
-               printk(KERN_INFO "CPU %d: SAL log contains %s error record\n",
+               IA64_MCA_DEBUG("CPU %d: SAL log contains %s error record\n",
                        smp_processor_id(),
                        sal_info_type < ARRAY_SIZE(rec_name) ? rec_name[sal_info_type] : "UNKNOWN");


