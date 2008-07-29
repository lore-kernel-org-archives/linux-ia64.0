From: Robin Holt <holt@sgi.com>
Date: Tue, 29 Jul 2008 12:26:21 +0000
Subject: [Patch] Allow ia64 to CONFIG_NR_CPUS up to 4096
Message-Id: <20080729122621.GE10501@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


ia64 has compiled with NR_CPUS@96 for a couple releases, just forgot
to update Kconfig to allow it.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: contention_unroll/arch/ia64/Kconfig
=================================--- contention_unroll.orig/arch/ia64/Kconfig	2008-07-28 18:19:56.000000000 -0500
+++ contention_unroll/arch/ia64/Kconfig	2008-07-29 06:29:26.248066055 -0500
@@ -322,9 +322,9 @@ config SMP
 
 config NR_CPUS
 	int "Maximum number of CPUs (2-1024)"
-	range 2 1024
+	range 2 4096
 	depends on SMP
-	default "1024"
+	default "4096"
 	help
 	  You should set this to the number of CPUs in your system, but
 	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
