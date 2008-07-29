From: Robin Holt <holt@sgi.com>
Date: Tue, 29 Jul 2008 12:03:02 +0000
Subject: [Patch] Update .gitignore to ignore the newly generated nr-irqs.h
Message-Id: <20080729120302.GL9663@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Add the generated nr-irqs.h to the .gitignore file.

Signed-off-by: Robin Holt <holt@sgi.com>
Index: contention_unroll/include/asm-ia64/.gitignore
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ 2.6.27-rc1/include/asm-ia64/.gitignore	2008-07-29 07:01:45.002716605 -0500
@@ -0,0 +1 @@
+nr-irqs.h
