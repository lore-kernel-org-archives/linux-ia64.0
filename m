From: Bruce Losure <blosure@sgi.com>
Date: Mon, 04 Apr 2005 12:23:28 +0000
Subject: [PATCH 2.6.12] Altix patch to fix missing Kconfig dependency.
Message-Id: <Pine.LNX.4.44.0504040717010.8457-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Tony,

This is a one-liner to make the mbcs driver depend on SGI_TIOCX in the
drivers/char/Kconfig file.

Thanks,
-Bruce

Signed-off-by: Bruce Losure <blosure@sgi.com>

Index: tiocx-test-2.6.12/drivers/char/Kconfig
=================================--- tiocx-test-2.6.12.orig/drivers/char/Kconfig 2005-03-23 18:50:41.588156677 -0600
+++ tiocx-test-2.6.12/drivers/char/Kconfig      2005-04-04 07:14:57.317156041 -0500
@@ -408,7 +408,7 @@
  
 config SGI_MBCS
        tristate "SGI FPGA Core Services driver support"
-       depends on (IA64_SGI_SN2 || IA64_GENERIC)
+       depends on SGI_TIOCX
        help
          If you have an SGI Altix with an attached SABrick
          say Y or M here, otherwise say N.

