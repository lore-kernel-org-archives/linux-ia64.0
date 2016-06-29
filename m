From: zengzhaoxiu@163.com
Date: Wed, 29 Jun 2016 15:15:21 +0000
Subject: [patch V4 05/31] bitops: Add ia64-specific parity functions
Message-Id: <1467213321-33337-1-git-send-email-zengzhaoxiu@163.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1462957827-24492-1-git-send-email-zengzhaoxiu@163.com>
In-Reply-To: <1462957827-24492-1-git-send-email-zengzhaoxiu@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>

From: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>

Signed-off-by: Zhaoxiu Zeng <zhaoxiu.zeng@gmail.com>
---
 arch/ia64/include/asm/bitops.h | 31 +++++++++++++++++++++++++++++++
 1 file changed, 31 insertions(+)

diff --git a/arch/ia64/include/asm/bitops.h b/arch/ia64/include/asm/bitops.h
index 71e8145..041d1d6 100644
--- a/arch/ia64/include/asm/bitops.h
+++ b/arch/ia64/include/asm/bitops.h
@@ -439,6 +439,37 @@ static __inline__ unsigned long __arch_hweight64(unsigned long x)
 
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
+static __inline__ unsigned int __arch_parity32(unsigned int x)
+{
+	return __arch_parity64((unsigned long)x << 32);
+}
+
+static __inline__ unsigned int __arch_parity16(unsigned int x)
+{
+	return __arch_parity64((unsigned long)x << 48);
+}
+
+static __inline__ unsigned int __arch_parity8(unsigned int x)
+{
+	return __arch_parity64((unsigned long)x << 56);
+}
+
+static __inline__ unsigned int __arch_parity4(unsigned int x)
+{
+	return __arch_parity64((unsigned long)x << 60);
+}
+
+#include <asm-generic/bitops/const_parity.h>
+
 #endif /* __KERNEL__ */
 
 #include <asm-generic/bitops/find.h>
-- 
2.7.4


