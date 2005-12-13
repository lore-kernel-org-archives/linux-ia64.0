From: hawkes@sgi.com
Date: Tue, 13 Dec 2005 21:45:44 +0000
Subject: [PATCH] ia64/sn: change default_sn2 to NR_CPUS==1024
Message-Id: <20051213214544.6811.40690.sendpatchset@tomahawk.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, please change the NR_CPUS default for ia64/sn up to 1024.

Signed-off-by: John Hawkes <hawkes@sgi.com>
Signed-off-by: John Hesterberg <jh@sgi.com>

Index: linux/arch/ia64/configs/sn2_defconfig
=================================--- linux.orig/arch/ia64/configs/sn2_defconfig	2005-12-06 15:12:14.000000000 -0800
+++ linux/arch/ia64/configs/sn2_defconfig	2005-12-13 12:59:53.000000000 -0800
@@ -96,7 +96,7 @@
 CONFIG_IA64_SGI_SN_XP=m
 CONFIG_FORCE_MAX_ZONEORDER
 CONFIG_SMP=y
-CONFIG_NR_CPUSQ2
+CONFIG_NR_CPUS24
 # CONFIG_HOTPLUG_CPU is not set
 CONFIG_SCHED_SMT=y
 CONFIG_PREEMPT=y
