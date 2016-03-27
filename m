From: "zhaoxiu.zeng" <zhaoxiu.zeng@gmail.com>
Date: Sun, 27 Mar 2016 06:00:02 +0000
Subject: [PATCH 06/31] Add ia64-specific parity functions
Message-Id: <56F776E2.4090609@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com>
In-Reply-To: <1458788612-4367-1-git-send-email-zhaoxiu.zeng@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

From: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zeng Zhaoxiu <zhaoxiu.zeng@gmail.com>
---
 arch/ia64/include/asm/bitops.h | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/ia64/include/asm/bitops.h b/arch/ia64/include/asm/bitops.h
index 71e8145..de13d89 100644
--- a/arch/ia64/include/asm/bitops.h
+++ b/arch/ia64/include/asm/bitops.h
@@ -439,6 +439,22 @@ static __inline__ unsigned long __arch_hweight64(unsigned long x)
 
 #include <asm-generic/bitops/const_hweight.h>
 
+/*
+ * parityN: returns the parity of a N-bit word,
+ * i.e. the number of 1-bits in x modulo 2.
+ */
+static __inline__ unsigned int __arch_parity64(unsigned long x)
+{
+	return (unsigned int)ia64_popcnt(x) & 1;
+}
+
+#define __arch_parity32(x) ((unsigned int) __arch_parity64((x) & 0xfffffffful))
+#define __arch_parity16(x) ((unsigned int) __arch_parity64((x) & 0xfffful))
+#define __arch_parity8(x)  ((unsigned int) __arch_parity64((x) & 0xfful))
+#define __arch_parity4(x)  ((unsigned int) __arch_parity64((x) & 0xful))
+
+#include <asm-generic/bitops/const_parity.h>
+
 #endif /* __KERNEL__ */
 
 #include <asm-generic/bitops/find.h>
-- 
2.5.5

