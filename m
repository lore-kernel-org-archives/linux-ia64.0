From: Andrea Gelmini <andrea.gelmini@gelma.net>
Date: Sat, 21 May 2016 11:55:44 +0000
Subject: [PATCH 0148/1529] Fix typo
Message-Id: <20160521115544.7211-1-andrea.gelmini@gelma.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Andrea Gelmini <andrea.gelmini@gelma.net>
---
 arch/ia64/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/Makefile b/arch/ia64/Makefile
index 970d0bd..a5900896 100644
--- a/arch/ia64/Makefile
+++ b/arch/ia64/Makefile
@@ -34,7 +34,7 @@ GAS_STATUS	= $(shell $(srctree)/arch/ia64/scripts/check-gas "$(CC)" "$(OBJDUMP)"
 KBUILD_CPPFLAGS += $(shell $(srctree)/arch/ia64/scripts/toolchain-flags "$(CC)" "$(OBJDUMP)" "$(READELF)")
 
 ifeq ($(GAS_STATUS),buggy)
-$(error Sorry, you need a newer version of the assember, one that is built from	\
+$(error Sorry, you need a newer version of the assembler, one that is built from	\
 	a source-tree that post-dates 18-Dec-2002.  You can find a pre-compiled	\
 	static binary of such an assembler at:					\
 										\
-- 
2.8.2.534.g1f66975

