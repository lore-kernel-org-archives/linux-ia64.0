From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 18 Nov 2008 10:19:50 +0000
Subject: [PATCH] ia64/pv_ops/pv_cpu_ops: fix _IA64_REG_IP case.
Message-Id: <20081118101950.GA12360%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

pv_cpu_ops.getreg(_IA64_REG_IP) returned constant.
But the returned ip valued should be the one in the caller, not of the callee.
This patch fixes that.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/intrinsics.h      |    2 +-
 arch/ia64/include/asm/paravirt_privop.h |   13 +++++++++++++
 arch/ia64/kernel/paravirt.c             |    2 +-
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/intrinsics.h b/arch/ia64/include/asm/intrinsics.h
index 47d686d..a3e44a5 100644
--- a/arch/ia64/include/asm/intrinsics.h
+++ b/arch/ia64/include/asm/intrinsics.h
@@ -226,7 +226,7 @@ extern long ia64_cmpxchg_called_with_bad_pointer (void);
 /************************************************/
 #define ia64_ssm			IA64_INTRINSIC_MACRO(ssm)
 #define ia64_rsm			IA64_INTRINSIC_MACRO(rsm)
-#define ia64_getreg			IA64_INTRINSIC_API(getreg)
+#define ia64_getreg			IA64_INTRINSIC_MACRO(getreg)
 #define ia64_setreg			IA64_INTRINSIC_API(setreg)
 #define ia64_set_rr			IA64_INTRINSIC_API(set_rr)
 #define ia64_get_rr			IA64_INTRINSIC_API(get_rr)
diff --git a/arch/ia64/include/asm/paravirt_privop.h b/arch/ia64/include/asm/paravirt_privop.h
index d577aac..0b59742 100644
--- a/arch/ia64/include/asm/paravirt_privop.h
+++ b/arch/ia64/include/asm/paravirt_privop.h
@@ -78,6 +78,19 @@ extern unsigned long ia64_native_getreg_func(int regnum);
 			ia64_native_rsm(mask);	\
 	} while (0)
 
+/* returned ip value should be the one in the caller,
+ * not in __paravirt_getreg() */
+#define paravirt_getreg(reg)					\
+	({							\
+		unsigned long res;				\
+		BUILD_BUG_ON(!__builtin_constant_p(reg));	\
+		if ((reg) = _IA64_REG_IP)			\
+			res = ia64_native_getreg(_IA64_REG_IP); \
+		else						\
+			res = pv_cpu_ops.getreg(reg);		\
+		res;						\
+	})
+
 /******************************************************************************
  * replacement of hand written assembly codes.
  */
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index de35d8e..9f14c16 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -130,7 +130,7 @@ ia64_native_getreg_func(int regnum)
 	unsigned long res = -1;
 	switch (regnum) {
 	CASE_GET_REG(GP);
-	CASE_GET_REG(IP);
+	/*CASE_GET_REG(IP);*/ /* returned ip value shouldn't be constant */
 	CASE_GET_REG(PSR);
 	CASE_GET_REG(TP);
 	CASE_GET_REG(SP);
-- 
1.6.0.2



-- 
yamahata
