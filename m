From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 30 Aug 2020 00:31:59 +0000
Subject: [PATCH] MAINTAINERS: IA64: mark Status as Odd Fixes only
Message-Id: <7e719139-450f-52c2-59a2-7964a34eda1f@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>

From: Randy Dunlap <rdunlap@infradead.org>

IA64 isn't really being maintained, so mark it as
Odd Fixes only.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
---
 MAINTAINERS |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20200828.orig/MAINTAINERS
+++ linux-next-20200828/MAINTAINERS
@@ -8316,7 +8316,7 @@ IA64 (Itanium) PLATFORM
 M:	Tony Luck <tony.luck@intel.com>
 M:	Fenghua Yu <fenghua.yu@intel.com>
 L:	linux-ia64@vger.kernel.org
-S:	Maintained
+S:	Odd Fixes
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git
 F:	Documentation/ia64/
 F:	arch/ia64/
