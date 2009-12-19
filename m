From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 19 Dec 2009 16:25:43 +0000
Subject: [PATCH] ia64: Include <linux/personality.h> header in <asm/fcntl.h>
Message-Id: <1261239943.2418.95.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The definition of force_o_largefile() references personality, but this
header does not include <linux/personality.h>.  This happens to work
for sys_open(), but may not for any other users.  In particular, aufs2
now uses this macro and so fails to build on ia64.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/ia64/include/asm/fcntl.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/fcntl.h b/arch/ia64/include/asm/fcntl.h
index 1dd275d..3cac8f9 100644
--- a/arch/ia64/include/asm/fcntl.h
+++ b/arch/ia64/include/asm/fcntl.h
@@ -5,6 +5,8 @@
  *	David Mosberger-Tang <davidm@hpl.hp.com>, Hewlett-Packard Co.
  */
 
+#include <linux/personality.h>
+
 #define force_o_largefile()	\
 		(personality(current->personality) != PER_LINUX32)
 
-- 
1.6.5.7


