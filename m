From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:56:13 +0000
Subject: [PATCH 0152/1529] Fix typo
Message-Id: <20160521115613.7423-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/include/asm/native/inst.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/include/asm/native/inst.h b/arch/ia64/include/asm/native/inst.h
index 7e08f17..ad4ce34 100644
--- a/arch/ia64/include/asm/native/inst.h
+++ b/arch/ia64/include/asm/native/inst.h
@@ -89,7 +89,7 @@
 #define SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(clob0, clob1)		\
 	ssm psr.ic | PSR_DEFAULT_BITS					\
 	;;								\
-	srlz.i /* guarantee that interruption collectin is on */	\
+	srlz.i /* guarantee that interruption collection is on */	\
 	;;
 
 #define SSM_PSR_IC_AND_SRLZ_D(clob0, clob1)	\
-- 
2.8.2.534.g1f66975

