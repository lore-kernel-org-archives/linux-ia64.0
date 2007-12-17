From: Joe Perches <joe@perches.com>
Date: Mon, 17 Dec 2007 19:30:05 +0000
Subject: [PATCH] arch/ia64/: Spelling fixes
Message-Id: <5703e57f925f31fc0eb38873bd7f10fc44f99cb4.1197918889.git.joe@perches.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Lennert Buytenhek <kernel@wantstofly.org>, Richard Purdie <rpurdie@rpsys.net>


Signed-off-by: Joe Perches <joe@perches.com>
---
 arch/ia64/sn/pci/tioce_provider.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index cee9379..e1a3e19 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -41,7 +41,7 @@
  *	} else
  *		do desired mmr access
  *
- * According to hw, we can use reads instead of writes to the above addres
+ * According to hw, we can use reads instead of writes to the above address
  *
  * Note this WAR can only to be used for accessing internal MMR's in the
  * TIOCE Coretalk Address Range 0x0 - 0x07ff_ffff.  This includes the
-- 
1.5.3.7.949.g2221a6

