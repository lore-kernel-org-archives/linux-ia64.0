From: Akinobu Mita <akinobu.mita@gmail.com>
Date: Wed, 14 Aug 2013 13:06:59 +0000
Subject: [PATCH] ia64: use asm-generic/bitops/builtin-ffs.h
Message-Id: <1376485619-5166-1-git-send-email-akinobu.mita@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

The definision of ffs() for ia64 is almost same as
asm-generic/bitops/builtin-ffs.h.  The only difference is that it is
defined as inline function or macro function.  So this switches to use
the header.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/bitops.h | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/ia64/include/asm/bitops.h b/arch/ia64/include/asm/bitops.h
index 8e20bff..c27eccd 100644
--- a/arch/ia64/include/asm/bitops.h
+++ b/arch/ia64/include/asm/bitops.h
@@ -425,13 +425,7 @@ __fls (unsigned long x)
 
 #include <asm-generic/bitops/fls64.h>
 
-/*
- * ffs: find first bit set. This is defined the same way as the libc and
- * compiler builtin ffs routines, therefore differs in spirit from the above
- * ffz (man ffs): it operates on "int" values only and the result value is the
- * bit number + 1.  ffs(0) is defined to return zero.
- */
-#define ffs(x)	__builtin_ffs(x)
+#include <asm-generic/bitops/builtin-ffs.h>
 
 /*
  * hweightN: returns the hamming weight (i.e. the number
-- 
1.8.3.1

