From: Jack Steiner <steiner@sgi.com>
Date: Wed, 14 Sep 2005 15:33:40 +0000
Subject: [PATCH] - Increase max SSI size on IA64 to 1024
Message-Id: <20050914153340.GA978@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch increases the maximum number of cpus supported on IA64
to 1024. No changes are made to the default SSI size. The patch 
simply allows specifying up to 1024p.

There are certainly scaling (& other) issues that also need to be 
addressed!!!  Additional patches will follow.....


	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2005-09-12 10:40:09.645656866 -0500
+++ linux/arch/ia64/Kconfig	2005-09-14 08:44:11.018603385 -0500
@@ -254,8 +254,8 @@ config SMP
 	  If you don't know what to do here, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-512)"
-	range 2 512
+	int "Maximum number of CPUs (2-1024)"
+	range 2 1024
 	depends on SMP
 	default "64"
 	help
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


