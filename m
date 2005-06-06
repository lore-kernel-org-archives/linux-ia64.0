From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 06 Jun 2005 20:43:03 +0000
Subject: acpi.h patchlet
Message-Id: <200506062043.j56Kh3XN018997@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm not sure why this issue is suddenly showing, but without this
patchlet, the zx1 config won't compile anymore (e.g., to see the
compilation-error, look for "***" in [1]).

Please include this patch for 2.6.12.

Thanks,

	--david

[1] http://www.gelato.unsw.edu.au/kerncomp/results//2005-06-06-17-00/zx1_defconfig-log.html

--
Include <linux/config.h> before testing CONFIG_ACPI.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

diff --git a/include/linux/acpi.h b/include/linux/acpi.h
--- a/include/linux/acpi.h
+++ b/include/linux/acpi.h
@@ -25,6 +25,8 @@
 #ifndef _LINUX_ACPI_H
 #define _LINUX_ACPI_H
 
+#include <linux/config.h>
+
 #ifdef	CONFIG_ACPI
 
 #ifndef _LINUX
