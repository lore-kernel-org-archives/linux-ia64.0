From: Robin Holt <holt@sgi.com>
Date: Wed, 16 May 2007 21:40:34 +0000
Subject: FW: Re: [PATCH] - Increase max SSI size
Message-Id: <20070516214034.GA13527@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070412175819.GA9723@sgi.com>
In-Reply-To: <20070412175819.GA9723@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Did this make it onto your radar?  Jack had submitted a fixed patch,
but I have not seen it sent to Linus yet.  Jack is on vacation right now.
If you need it resubmitted, please let me know and I will impersonate him.

Thanks,
Robin

----- Forwarded message from Jack Steiner <steiner@sgi.com> -----

Date:	Thu, 12 Apr 2007 13:39:01 -0500
From: Jack Steiner <steiner@sgi.com>
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org
Subject: Re: [PATCH] - Increase max SSI size

Increase the maximum SSI size for IA64 to 4096p. No changes are being
made to the default configuration sizes (for now).

	Signed-off-by: Jack Steiner <steiner@sgi.com>

---
With bug fix that Tony found....



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
+++ linux/arch/ia64/kernel/topology.c	2007-04-12 13:37:05.855795475 -0500
@@ -21,6 +21,7 @@
 #include <linux/bootmem.h>
 #include <linux/nodemask.h>
 #include <linux/notifier.h>
+#include <linux/vmalloc.h>
 #include <asm/mmzone.h>
 #include <asm/numa.h>
 #include <asm/cpu.h>
@@ -68,10 +69,11 @@ static int __init topology_init(void)
 	}
 #endif
 
-	sysfs_cpus = kzalloc(sizeof(struct ia64_cpu) * NR_CPUS, GFP_KERNEL);
+	sysfs_cpus = vmalloc(sizeof(struct ia64_cpu) * NR_CPUS);
 	if (!sysfs_cpus)
 		panic("kzalloc in topology_init failed - NR_CPUS too big?");
 
+	memset(sysfs_cpus, 0, sizeof(sizeof(struct ia64_cpu) * NR_CPUS));
 	for_each_present_cpu(i) {
 		if((err = arch_register_cpu(i)))
 			goto out;
-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

----- End forwarded message -----
