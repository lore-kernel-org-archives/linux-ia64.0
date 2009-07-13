From: Aurelien Jarno <aurelien@aurel32.net>
Date: Mon, 13 Jul 2009 16:53:35 +0000
Subject: [PATCH v2] Revert "Neither asm/types.h nor linux/types.h is
Message-Id: <20090713165335.GA29702@volta.aurel32.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090712155833.GB12923@volta.aurel32.net>
In-Reply-To: <20090712155833.GB12923@volta.aurel32.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jaswinder Singh Rajput <jaswinderrajput@gmail.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Sorry forget to add a S-o-B tag. Please find a new version below.


asm/fpu.h uses the __IA64_UL macro which is declared in asm/types.h, so
this include is really required. Without it, GNU libc fails to build.

This reverts commit 2678c07b07ac2076675e5d57653bdf02e9af1950.

Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

---
 arch/ia64/include/asm/fpu.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/fpu.h b/arch/ia64/include/asm/fpu.h
index 0c26157..b6395ad 100644
--- a/arch/ia64/include/asm/fpu.h
+++ b/arch/ia64/include/asm/fpu.h
@@ -6,6 +6,8 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  */
 
+#include <linux/types.h>
+
 /* floating point status register: */
 #define FPSR_TRAP_VD	(1 << 0)	/* invalid op trap disabled */
 #define FPSR_TRAP_DD	(1 << 1)	/* denormal trap disabled */
-- 
1.6.1.3

-- 
Aurelien Jarno	                        GPG: 1024D/F1BCDB73
aurelien@aurel32.net                 http://www.aurel32.net
