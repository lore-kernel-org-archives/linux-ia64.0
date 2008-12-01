From: akpm@linux-foundation.org
Date: Mon, 01 Dec 2008 22:18:36 +0000
Subject: [patch 1/2] ia64: use the new byteorder headers
Message-Id: <200812012218.mB1MIaXY011621@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Harvey Harrison <harvey.harrison@gmail.com>

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/include/asm/byteorder.h |   26 +++++++++++---------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff -puN arch/ia64/include/asm/byteorder.h~ia64-use-the-new-byteorder-headers arch/ia64/include/asm/byteorder.h
--- a/arch/ia64/include/asm/byteorder.h~ia64-use-the-new-byteorder-headers
+++ a/arch/ia64/include/asm/byteorder.h
@@ -10,33 +10,29 @@
 #include <asm/intrinsics.h>
 #include <linux/compiler.h>
 
-static __inline__ __attribute_const__ __u64
-__ia64_swab64 (__u64 x)
+#define __LITTLE_ENDIAN
+
+static inline __attribute_const__ __u64 __arch_swab64(__u64 x)
 {
 	__u64 result;
 
 	result = ia64_mux1(x, ia64_mux1_rev);
 	return result;
 }
+#define __arch_swab64 __arch_swab64
 
-static __inline__ __attribute_const__ __u32
-__ia64_swab32 (__u32 x)
+static inline __attribute_const__ __u32 __arch_swab32(__u32 x)
 {
-	return __ia64_swab64(x) >> 32;
+	return __arch_swab64(x) >> 32;
 }
+#define __arch_swab32 __arch_swab32
 
-static __inline__ __attribute_const__ __u16
-__ia64_swab16(__u16 x)
+static inline __attribute_const__ __u16 __arch_swab16(__u16 x)
 {
-	return __ia64_swab64(x) >> 48;
+	return __arch_swab64(x) >> 48;
 }
+#define __arch_swab16 __arch_swab16
 
-#define __arch__swab64(x) __ia64_swab64(x)
-#define __arch__swab32(x) __ia64_swab32(x)
-#define __arch__swab16(x) __ia64_swab16(x)
-
-#define __BYTEORDER_HAS_U64__
-
-#include <linux/byteorder/little_endian.h>
+#include <linux/byteorder.h>
 
 #endif /* _ASM_IA64_BYTEORDER_H */
_
