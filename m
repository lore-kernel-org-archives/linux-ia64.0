From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Fri, 14 Sep 2018 07:06:17 +0000
Subject: [PATCH] ia64: disable SCHED_STACK_END_CHECK
Message-Id: <20180914070617.29203-1-slyfox@gentoo.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: Sergei Trofimovich <slyfox@gentoo.org>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

SCHED_STACK_END_CHECK assumes stack grows in one direction.
ia64 is a rare case where it is not.

As a result kernel fails at startup as:
  Kernel panic - not syncing: corrupted stack end detected inside scheduler

The error does not find a real problem: it's register backing store
is written on top of canary value.

Disable SCHED_STACK_END_CHECK on ia64 as there is no good
place for canary without moving initial stack address.

CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-kernel@vger.kernel.org
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 lib/Kconfig.debug | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 4966c4fbe7f7..a097dfe38d2b 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1004,7 +1004,7 @@ config SCHEDSTATS
 
 config SCHED_STACK_END_CHECK
 	bool "Detect stack corruption on calls to schedule()"
-	depends on DEBUG_KERNEL
+	depends on DEBUG_KERNEL && !IA64
 	default n
 	help
 	  This option checks for a stack overrun on calls to schedule().
-- 
2.19.0
