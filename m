From: Horms <horms@verge.net.au>
Date: Mon, 05 Feb 2007 02:05:29 +0000
Subject: [PATCH] [IA64] kexec: typo in the saved_max_pfn description in contig.c
Message-Id: <20070205020527.GB31446@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Fix a typo in the saved_max_pfn description in contig.c

Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 1e79551..ec8657b 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -177,7 +177,7 @@ find_memory (void)
 
 #ifdef CONFIG_CRASH_DUMP
 	/* If we are doing a crash dump, we still need to know the real mem
-	 * size before original memory map is * reset. */
+	 * size before original memory map is reset. */
 	saved_max_pfn = max_pfn;
 #endif
 }
