From: Yong Zhang <yong.zhang0@gmail.com>
Date: Wed, 30 May 2012 08:07:24 +0000
Subject: [PATCH] ia64: remove configuration for GENERIC_LOCKBREAK
Message-Id: <1338365244-11971-1-git-send-email-yong.zhang0@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

From: Yong Zhang <yong.zhang@windriver.com>

'def_bool n' is pointless and ia64 has realized ticket
spinlock.

'grep' makes me think ia64 has GENERIC_LOCKBREAK set,
then notice that it's off by default.

Signed-off-by: Yong Zhang <yong.zhang0@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8186ec5..5e6b361 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -78,9 +78,6 @@ config SWIOTLB
 config STACKTRACE_SUPPORT
 	def_bool y
 
-config GENERIC_LOCKBREAK
-	def_bool n
-
 config RWSEM_XCHGADD_ALGORITHM
 	bool
 	default y
-- 
1.7.5.4

