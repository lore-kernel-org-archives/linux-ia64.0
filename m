From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Fri, 05 Nov 2004 05:56:09 +0000
Subject: [PATCH] Fix duplicate config for IA64_MCA_RECOVERY
Message-Id: <20041105145609.0310d9ee.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, akpm@osdl.org
Cc: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Here is a small bug fix against 2.6.10-rc1-mm2.

Thanks,
Keiichiro Tokunaga

Signed-off-by: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Description:
Fix duplicate config for IA64_MCA_RECOVERY.

---

 linux-2.6.10-rc1-mm2-kei/arch/ia64/Kconfig |    3 ---
 1 files changed, 3 deletions(-)

diff -puN arch/ia64/Kconfig~fix_mca_kconfig arch/ia64/Kconfig
--- linux-2.6.10-rc1-mm2/arch/ia64/Kconfig~fix_mca_kconfig	2004-11-05 14:44:19.861106461 +0900
+++ linux-2.6.10-rc1-mm2-kei/arch/ia64/Kconfig	2004-11-05 14:45:28.620439785 +0900
@@ -491,9 +491,6 @@ config COMPAT
 config IA64_MCA_RECOVERY
 	tristate "MCA recovery from errors other than TLB."
 
-config IA64_MCA_RECOVERY
-	tristate "MCA recovery from errors other than TLB."
-
 config PERFMON
 	bool "Performance monitor support"
 	help

_
