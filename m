From: Christoph Lameter <clameter@sgi.com>
Date: Tue, 22 Aug 2006 02:11:52 +0000
Subject: Increase default nodes shift to 10
Message-Id: <Pine.LNX.4.64.0608211908270.21433@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We have systems with 1024 nodes and 1024 processors. Could we set
the default nodes shift to 10?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc4/arch/ia64/Kconfig
=================================--- linux-2.6.18-rc4.orig/arch/ia64/Kconfig	2006-08-06 11:20:11.000000000 -0700
+++ linux-2.6.18-rc4/arch/ia64/Kconfig	2006-08-21 19:06:30.329846676 -0700
@@ -354,7 +354,7 @@ config NUMA
 config NODES_SHIFT
 	int "Max num nodes shift(3-10)"
 	range 3 10
-	default "8"
+	default "10"
 	depends on NEED_MULTIPLE_NODES
 	help
 	  This option specifies the maximum number of nodes in your SSI system.

