From: Jack Steiner <steiner@sgi.com>
Date: Tue, 18 Apr 2006 20:00:45 +0000
Subject: [PATCH] - Fix MAX_PXM_DOMAINS for systems with > 256 nodes
Message-Id: <20060418200045.GA6853@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Correctly size the PXM-related arrays for systems that have more than 
256 nodes.

	Signed-off-by: Jack Steiner <steiner@sgi.com>


Index: linux/include/asm-ia64/acpi.h
=================================--- linux.orig/include/asm-ia64/acpi.h	2006-04-18 12:32:21.191273221 -0500
+++ linux/include/asm-ia64/acpi.h	2006-04-18 14:35:52.941609225 -0500
@@ -110,9 +110,8 @@ extern void prefill_possible_map(void);
 extern int additional_cpus;
 
 #ifdef CONFIG_ACPI_NUMA
-/* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
-#ifdef CONFIG_IA64_NR_NODES
-#define MAX_PXM_DOMAINS CONFIG_IA64_NR_NODES
+#if MAX_NUMNODES > 256
+#define MAX_PXM_DOMAINS MAX_NUMNODES
 #else
 #define MAX_PXM_DOMAINS (256)
 #endif
