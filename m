From: Sina Hamedian <shamedian@gmail.com>
Date: Sun, 31 Jan 2016 06:07:31 +0000
Subject: [PATCH] arch/ia64/lib: Fix broken URL in comments
Message-Id: <1454220451-3641-1-git-send-email-shamedian@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, fenghua.yu@intel.com, trivial@kernel.org, Sina Hamedian <shamedian@gmail.com>

The URL to the book IA-64 and Elementary Functions in idiv32.S and
idiv64.S just led to a 404 page, so I updated them with a known good link
that others can reference.

Signed-off-by: Sina Hamedian <shamedian@gmail.com>
---
 arch/ia64/lib/idiv32.S | 2 +-
 arch/ia64/lib/idiv64.S | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/lib/idiv32.S b/arch/ia64/lib/idiv32.S
index 2ac28bf..c91b5b0 100644
--- a/arch/ia64/lib/idiv32.S
+++ b/arch/ia64/lib/idiv32.S
@@ -11,7 +11,7 @@
  *
  * For more details on the theory behind these algorithms, see "IA-64
  * and Elementary Functions" by Peter Markstein; HP Professional Books
- * (http://www.hp.com/go/retailbooks/)
+ * (http://www.goodreads.com/book/show/2019887.Ia_64_and_Elementary_Functions)
  */
 
 #include <asm/asmmacro.h>
diff --git a/arch/ia64/lib/idiv64.S b/arch/ia64/lib/idiv64.S
index f69bd2b..627573c 100644
--- a/arch/ia64/lib/idiv64.S
+++ b/arch/ia64/lib/idiv64.S
@@ -11,7 +11,7 @@
  *
  * For more details on the theory behind these algorithms, see "IA-64
  * and Elementary Functions" by Peter Markstein; HP Professional Books
- * (http://www.hp.com/go/retailbooks/)
+ * (http://www.goodreads.com/book/show/2019887.Ia_64_and_Elementary_Functions)
  */
 
 #include <asm/asmmacro.h>
-- 
2.5.0

