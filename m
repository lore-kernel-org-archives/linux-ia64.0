From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sun, 23 May 2010 20:01:51 +0000
Subject: [PATCH 155/199] arch/ia64/lib/idiv32.S: Checkpatch cleanup
Message-Id: <1274644930-26600-7-git-send-email-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

arch/ia64/lib/idiv32.S:62: ERROR: trailing whitespace

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/lib/idiv32.S |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/lib/idiv32.S b/arch/ia64/lib/idiv32.S
index 2ac28bf..a28d7fc 100644
--- a/arch/ia64/lib/idiv32.S
+++ b/arch/ia64/lib/idiv32.S
@@ -59,7 +59,7 @@ GLOBAL_ENTRY(NAME)
 	frcpa.s1 f6, p6 = f8, f9	// y0 = frcpa(b)
 	;;
 (p6)	fmpy.s1 f8 = f8, f6		// q0 = a*y0
-(p6)	fnma.s1 f6 = f9, f6, f1		// e0 = -b*y0 + 1 
+(p6)	fnma.s1 f6 = f9, f6, f1		// e0 = -b*y0 + 1
 	;;
 #ifdef MODULO
 	setf.sig f9 = in1		// f9 = -b
-- 
1.7.1.251.gf80a2

