From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sun, 23 May 2010 20:01:45 +0000
Subject: [PATCH 149/199] arch/ia64/hp/sim/boot/ssc.h: Checkpatch cleanup
Message-Id: <1274644930-26600-1-git-send-email-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/hp/sim/boot/ssc.h:33: WARNING: space prohibited between function name and open parenthesis '('

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/hp/sim/boot/ssc.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/hp/sim/boot/ssc.h b/arch/ia64/hp/sim/boot/ssc.h
index 3b94c03..87400ed 100644
--- a/arch/ia64/hp/sim/boot/ssc.h
+++ b/arch/ia64/hp/sim/boot/ssc.h
@@ -30,6 +30,6 @@
 /*
  * Simulator system call.
  */
-extern long ssc (long arg0, long arg1, long arg2, long arg3, int nr);
+extern long ssc(long arg0, long arg1, long arg2, long arg3, int nr);
 
 #endif /* ssc_h */
-- 
1.7.1.251.gf80a2

