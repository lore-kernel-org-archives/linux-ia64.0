From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Mon, 01 Nov 2004 09:05:36 +0000
Subject: [PATCH] cleanup CPU drift print
Message-Id: <20041101.180536.41629669.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch skips printing drift information of a cpu where
ITC drift information is not supported by SAL.  Without this,
bogus value (-1ppm) is printed on boot.

CPU 1: base freq 0.007MHz, ITC ratio/2, ITC freq00.035MHz+/--1ppm

is now

CPU 1: base freq 0.007MHz, ITC ratio/2, ITC freq00.035MHz

Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

Index: 269-bk/arch/ia64/kernel/time.c
=================================--- 269-bk/arch/ia64/kernel/time.c	(revision 48)
+++ 269-bk/arch/ia64/kernel/time.c	(working copy)
@@ -186,18 +186,21 @@
 		itc_ratio.den = 1;	/* avoid division by zero */
 
 	itc_freq = (platform_base_freq*itc_ratio.num)/itc_ratio.den;
-	if (platform_base_drift != -1)
-		itc_drift = platform_base_drift*itc_ratio.num/itc_ratio.den;
-	else
-		itc_drift = -1;
 
 	local_cpu_data->itm_delta = (itc_freq + HZ/2) / HZ;
 	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, "
-	       "ITC freq=%lu.%03luMHz+/-%ldppm\n", smp_processor_id(),
+	       "ITC freq=%lu.%03luMHz", smp_processor_id(),
 	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
-	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000) % 1000,
-	       itc_drift);
+	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000) % 1000);
 
+	if (platform_base_drift != -1) {
+		itc_drift = platform_base_drift*itc_ratio.num/itc_ratio.den;
+		printk("+/-%ldppm\n", itc_drift);
+	} else {
+		itc_drift = -1;
+		printk("\n");
+	}
+
 	local_cpu_data->proc_freq = (platform_base_freq*proc_ratio.num)/proc_ratio.den;
 	local_cpu_data->itc_freq = itc_freq;
 	local_cpu_data->cyc_per_usec = (itc_freq + USEC_PER_SEC/2) / USEC_PER_SEC;
