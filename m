From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 15 Oct 2003 15:37:40 +0000
Subject: [PATCH] force on appropriate generic options
Message-Id: <marc-linux-ia64-106623256821584@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Make sure that generic kernels actually build by forcing on the
necessary options.  With this patch I was able to build a generic kernel
out of the to-linus-2.5 tree.

Jesse

diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Wed Oct 15 08:35:33 2003
+++ b/arch/ia64/Kconfig	Wed Oct 15 08:35:33 2003
@@ -57,6 +57,10 @@
 
 config IA64_GENERIC
 	bool "generic"
+	select NUMA
+	select ACPI_NUMA
+	select VIRTUAL_MEM_MAP
+	select DISCONTIGMEM
 	---help---
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
