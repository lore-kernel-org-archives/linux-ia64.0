From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 10 Sep 2003 21:33:29 +0000
Subject: [PATCH] turn off SLIT debugging
Message-Id: <marc-linux-ia64-106323063211258@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This code works pretty well now, so we don't need to dump all this stuff
at boot time (esp. on 128 node systems).

Jesse

diff -Nru a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
--- a/arch/ia64/kernel/acpi.c	Wed Sep 10 14:25:39 2003
+++ b/arch/ia64/kernel/acpi.c	Wed Sep 10 14:25:39 2003
@@ -331,7 +331,7 @@
 
 #ifdef CONFIG_ACPI_NUMA
 
-#define SLIT_DEBUG
+#undef SLIT_DEBUG
 
 #define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
 
