From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 13 Aug 2004 17:23:35 +0000
Subject: [PATCH] make per-cpu boot messages quieter
Message-Id: <200408131023.35453.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_XkPHBXSiQj9Ey2B"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_XkPHBXSiQj9Ey2B
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch turns the per-CPU frequency printk into a KERN_DEBUG instead of a 
KERN_INFO so it'll show up in the system log but won't be printed at boot, 
since it's a big pain on system with a lot of CPUs.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Jesse

--Boundary-00=_XkPHBXSiQj9Ey2B
Content-Type: text/plain;
  charset="us-ascii";
  name="quiet-cpu-frequency.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="quiet-cpu-frequency.patch"

===== arch/ia64/kernel/time.c 1.42 vs edited =====
--- 1.42/arch/ia64/kernel/time.c	2004-06-04 15:44:03 -07:00
+++ edited/arch/ia64/kernel/time.c	2004-08-13 09:53:06 -07:00
@@ -371,7 +371,7 @@
 		itc_drift = -1;
 
 	local_cpu_data->itm_delta = (itc_freq + HZ/2) / HZ;
-	printk(KERN_INFO "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, "
+	printk(KERN_DEBUG "CPU %d: base freq=%lu.%03luMHz, ITC ratio=%lu/%lu, "
 	       "ITC freq=%lu.%03luMHz+/-%ldppm\n", smp_processor_id(),
 	       platform_base_freq / 1000000, (platform_base_freq / 1000) % 1000,
 	       itc_ratio.num, itc_ratio.den, itc_freq / 1000000, (itc_freq / 1000) % 1000,

--Boundary-00=_XkPHBXSiQj9Ey2B--
