From: Jack Steiner <steiner@sgi.com>
Date: Thu, 12 Apr 2007 17:58:20 +0000
Subject: [PATCH] - Increase max SSI size
Message-Id: <20070412175819.GA9723@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Increase the maximum SSI size for IA64 to 4096p. No changes are being
made to the default configuration sizes (for now).

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/arch/ia64/Kconfig
=================================--- linux.orig/arch/ia64/Kconfig	2007-04-04 16:51:42.000000000 -0500
+++ linux/arch/ia64/Kconfig	2007-04-12 07:41:44.619991642 -0500
@@ -267,8 +267,8 @@ config SMP
 	  If you don't know what to do here, say N.
 
 config NR_CPUS
-	int "Maximum number of CPUs (2-1024)"
-	range 2 1024
+	int "Maximum number of CPUs (2-4096)"
+	range 2 4096
 	depends on SMP
 	default "1024"
 	help
Index: linux/arch/ia64/kernel/topology.c
=================================--- linux.orig/arch/ia64/kernel/topology.c	2007-04-04 16:51:42.000000000 -0500
+++ linux/arch/ia64/kernel/topology.c	2007-04-12 08:08:30.526370615 -0500
@@ -21,6 +21,7 @@
 #include <linux/bootmem.h>
 #include <linux/nodemask.h>
 #include <linux/notifier.h>
+#include <linux/vmalloc.h>
 #include <asm/mmzone.h>
 #include <asm/numa.h>
 #include <asm/cpu.h>
@@ -68,7 +69,8 @@ static int __init topology_init(void)
 	}
 #endif
 
-	sysfs_cpus = kzalloc(sizeof(struct ia64_cpu) * NR_CPUS, GFP_KERNEL);
+	sysfs_cpus = vmalloc(sizeof(struct ia64_cpu) * NR_CPUS);
+	memset(sysfs_cpus, 0, sizeof(sizeof(struct ia64_cpu) * NR_CPUS));
 	if (!sysfs_cpus)
 		panic("kzalloc in topology_init failed - NR_CPUS too big?");
 
