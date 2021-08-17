From: Jason Wang <wangborong@cdjrlc.com>
Date: Tue, 17 Aug 2021 11:25:00 +0000
Subject: [PATCH] ia64: fix typo in a comment
Message-Id: <20210817112500.12848-1-wangborong@cdjrlc.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: valentin.schneider@arm.com
Cc: akpm@linux-foundation.org, wangborong@cdjrlc.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The double `when' in comment `TBD when when IA64 starts to support
suspend...' is repeated. Consequently, one `when' should be removed
from the comment.

Signed-off-by: Jason Wang <wangborong@cdjrlc.com>
---
 arch/ia64/kernel/acpi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index e2af6b172200..96d13cb7c19f 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -906,6 +906,6 @@ EXPORT_SYMBOL(acpi_unregister_ioapic);
 /*
  * acpi_suspend_lowlevel() - save kernel state and suspend.
  *
- * TBD when when IA64 starts to support suspend...
+ * TBD when IA64 starts to support suspend...
  */
 int acpi_suspend_lowlevel(void) { return 0; }
-- 
2.32.0
