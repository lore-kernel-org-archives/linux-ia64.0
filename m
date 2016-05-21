From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:57:14 +0000
Subject: [PATCH 0160/1529] Fix typo
Message-Id: <20160521115714.8064-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/sn/kernel/sn2/sn2_smp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index c98dc96..cf0a74d 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -59,7 +59,7 @@ sn2_ptc_deadlock_recovery(nodemask_t, short, short, int,
 			  volatile unsigned long *, unsigned long);
 
 /*
- * Note: some is the following is captured here to make degugging easier
+ * Note: some is the following is captured here to make debugging easier
  * (the macros make more sense if you see the debug patch - not posted)
  */
 #define sn2_ptctest	0
-- 
2.8.2.534.g1f66975

