From: Bjorn Helgaas <helgaas@kernel.org>
Date: Fri, 14 Oct 2022 00:19:10 +0000
Subject: [PATCH 2/3] ia64: remove unused __SLOW_DOWN_IO and SLOW_DOWN_IO definitions
Message-Id: <20221014001911.3342485-3-helgaas@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20221014001911.3342485-1-helgaas@kernel.org>
In-Reply-To: <20221014001911.3342485-1-helgaas@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-ia64@vger.kernel.org

From: Bjorn Helgaas <bhelgaas@google.com>

Remove unused __SLOW_DOWN_IO and SLOW_DOWN_IO definitions.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/io.h | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index ce66dfc0e719..83a492c8d298 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -23,10 +23,6 @@
 #include <asm/unaligned.h>
 #include <asm/early_ioremap.h>
 
-/* We don't use IO slowdowns on the ia64, but.. */
-#define __SLOW_DOWN_IO	do { } while (0)
-#define SLOW_DOWN_IO	do { } while (0)
-
 #define __IA64_UNCACHED_OFFSET	RGN_BASE(RGN_UNCACHED)
 
 /*
-- 
2.25.1
