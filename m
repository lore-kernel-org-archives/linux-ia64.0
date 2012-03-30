From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 30 Mar 2012 18:43:11 +0000
Subject: [PATCH] ia64: Fixup asm/cmpxchg.h
Message-Id: <4f75febf2903e94f6@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: David Howells <dhowells@redhat.com>

Empty asm/cmpxchg.h file that was provided as a temporary build
fix for the asm/system.h disintgration build problem should really
include <asm/intrinsics.h> to make definitions of xchg() and
cmpxchg() available.

Signed-off-by: David Howells <dhowells@redhat.com>
Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/include/asm/cmpxchg.h b/arch/ia64/include/asm/cmpxchg.h
index 507c66c..4c96187 100644
--- a/arch/ia64/include/asm/cmpxchg.h
+++ b/arch/ia64/include/asm/cmpxchg.h
@@ -1 +1 @@
-/* Future home of xchg() and cmpxchg() */
+#include <asm/intrinsics.h>
