From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Date: Tue, 02 Jun 2015 18:33:59 +0000
Subject: [PATCH] ia64: export flush_icache_range for module use
Message-Id: <1433270039-1527-1-git-send-email-mcgrof@do-not-panic.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1433270034-1473-1-git-send-email-mcgrof@do-not-panic.com>
In-Reply-To: <1433270034-1473-1-git-send-email-mcgrof@do-not-panic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, pbonzini@redhat.com, boris.ostrovsky@oracle.com, "Luis R. Rodriguez" <mcgrof@suse.com>

From: "Luis R. Rodriguez" <mcgrof@suse.com>

This is needed the following modules:

"Linux Kernel Dump Test Tool Module"
CONFIG_LKDTM		drivers/misc/lkdtm.c

Since:
mcgrof@ergon ~/linux-next (git::master)$ git describe --contains aac416fc38cdf
v3.15-rc1~141^2~84

CONFIG_STI_CONSOLE	drivers/video/console/sticore.c
Since: beginning of new git time on Linux

Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---

Without this you can't build modules on ia64 if you've enabled
either of these modules. lkdtm is enabled on SLE11, so this helps
upkeep that tradition.

 arch/ia64/kernel/ia64_ksyms.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/ia64/kernel/ia64_ksyms.c b/arch/ia64/kernel/ia64_ksyms.c
index 5b7791d..0967310 100644
--- a/arch/ia64/kernel/ia64_ksyms.c
+++ b/arch/ia64/kernel/ia64_ksyms.c
@@ -96,3 +96,6 @@ EXPORT_SYMBOL(ia64_ivt);
 /* mcount is defined in assembly */
 EXPORT_SYMBOL(_mcount);
 #endif
+
+#include <asm/cacheflush.h>
+EXPORT_SYMBOL_GPL(flush_icache_range);
-- 
2.3.2.209.gd67f9d5.dirty

