From: jbarnes@sgi.com (Jesse Barnes)
Date: Tue, 09 Sep 2003 23:57:03 +0000
Subject: [PATCH] update Kconfig comment for NR_CPUS
Message-Id: <marc-linux-ia64-106315215800794@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Noticed this when I built a kernel for a 256p machine.

Jesse

=== arch/ia64/Kconfig 1.42 vs edited ==--- 1.42/arch/ia64/Kconfig	Mon Sep  8 16:15:14 2003
+++ edited/arch/ia64/Kconfig	Tue Sep  9 16:55:14 2003
@@ -424,9 +424,15 @@
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-64)"
+	int "Maximum number of CPUs"
 	depends on SMP
 	default "64"
+	help
+	  You should set this to the number of CPUs in your system, but
+	  keep in mind that a kernel compiled for e.g. 2 CPUs will boot but
+	  only use 2 CPUs on a >2 CPU system.  Setting this to a value larger
+	  than 64 will cause the use of a CPU mask array, causing a small
+	  performance hit.
 
 source "fs/Kconfig.binfmt"
 
