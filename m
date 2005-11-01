From: dcn@sgi.com (Dean Nelson)
Date: Tue, 01 Nov 2005 16:21:51 +0000
Subject: [PATCH] restrict CONFIG_SGI_SN_XP to IA64_GENERIC or IA64_SGI_SN2
Message-Id: <4367961F.mailxIFY1NMD3F@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Restrict CONFIG_SGI_SN_XP to IA64_GENERIC or IA64_SGI_SN2 kernels.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6.git-test/arch/ia64/Kconfig
=================================--- linux-2.6.git-test.orig/arch/ia64/Kconfig	2005-10-27 09:09:39.106967961 -0500
+++ linux-2.6.git-test/arch/ia64/Kconfig	2005-11-01 08:13:52.645349274 -0600
@@ -187,6 +187,7 @@
 
 config IA64_SGI_SN_XP
 	tristate "Support communication between SGI SSIs"
+	depends on IA64_GENERIC || IA64_SGI_SN2
 	select IA64_UNCACHED_ALLOCATOR
 	help
 	  An SGI machine can be divided into multiple Single System
