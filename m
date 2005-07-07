From: Jack Steiner <steiner@sgi.com>
Date: Thu, 07 Jul 2005 16:13:33 +0000
Subject: [PATCH] - Disable tiocx driver on non-SN systems
Message-Id: <20050707161333.GA4094@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Disable the tiocx driver on non-SN systems.


 	Signed-off-by: Jack Steiner <steiner@sgi.com>



 tiocx.c |    4 ++++
 1 files changed, 4 insertions(+)



Index: linux/arch/ia64/sn/kernel/tiocx.c
=================================--- linux.orig/arch/ia64/sn/kernel/tiocx.c	2005-07-07 08:52:25.727428068 -0500
+++ linux/arch/ia64/sn/kernel/tiocx.c	2005-07-07 08:59:05.207224795 -0500
@@ -14,6 +14,7 @@
 #include <linux/proc_fs.h>
 #include <linux/device.h>
 #include <linux/delay.h>
+#include <asm/system.h>
 #include <asm/uaccess.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/addrs.h>
@@ -481,6 +482,9 @@ static int __init tiocx_init(void)
 	cnodeid_t cnodeid;
 	int found_tiocx_device = 0;
 
+	if (!ia64_platform_is("sn2"))
+		return -ENODEV;
+
 	bus_register(&tiocx_bus_type);
 
 	for (cnodeid = 0; cnodeid < MAX_COMPACT_NODES; cnodeid++) {
