From: Robin Holt <holt@sgi.com>
Date: Sat, 02 Aug 2008 18:29:24 +0000
Subject: [Patch] Allow ia64 to CONFIG_NR_CPUS up to 4096 v2
Message-Id: <20080802182924.GE6824@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080729122621.GE10501@sgi.com>
In-Reply-To: <20080729122621.GE10501@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


ia64 has compiled with NR_CPUS@96 for a couple releases, just forgot
to update Kconfig to allow it.

Signed-off-by: Robin Holt <holt@sgi.com>


Index: contention_unroll/arch/ia64/Kconfig
=================================--- contention_unroll.orig/arch/ia64/Kconfig	2008-07-29 07:03:17.514143399 -0500
+++ contention_unroll/arch/ia64/Kconfig	2008-07-29 08:16:50.987937542 -0500
@@ -321,10 +321,10 @@ config SMP
 	  If you don't know what to do here, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-1024)"
-	range 2 1024
+	int "Maximum number of CPUs (2-4096)"
+	range 2 4096
 	depends on SMP
-	default "1024"
+	default "4096"
 	help
 	  You should set this to the number of CPUs in your system, but
 	  keep in mind that a kernel compiled for, e.g., 2 CPUs will boot but
