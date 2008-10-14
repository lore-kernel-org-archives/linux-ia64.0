From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 14 Oct 2008 05:51:17 +0000
Subject: [PATCH 02/32] ia64/pv_ops: update native/inst.h to clobber predicate.
Message-Id: <1223963507-28056-3-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

add CLOBBER_PRED() to clobber predicate register.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/native/inst.h |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/include/asm/native/inst.h b/arch/ia64/include/asm/native/inst.h
index c8efbf7..0a1026c 100644
--- a/arch/ia64/include/asm/native/inst.h
+++ b/arch/ia64/include/asm/native/inst.h
@@ -36,8 +36,13 @@
 	;;					\
 	movl clob = PARAVIRT_POISON;		\
 	;;
+# define CLOBBER_PRED(pred_clob)		\
+	;;					\
+	cmp.eq pred_clob, p0 = r0, r0		\
+	;;
 #else
-# define CLOBBER(clob)		/* nothing */
+# define CLOBBER(clob)			/* nothing */
+# define CLOBBER_PRED(pred_clob)	/* nothing */
 #endif
 
 #define MOV_FROM_IFA(reg)	\
@@ -136,7 +141,8 @@
 
 #define SSM_PSR_I(pred, pred_clob, clob)	\
 (pred)	ssm psr.i				\
-	CLOBBER(clob)
+	CLOBBER(clob)				\
+	CLOBBER_PRED(pred_clob)
 
 #define RSM_PSR_I(pred, clob0, clob1)	\
 (pred)	rsm psr.i			\
-- 
1.6.0.2

