From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 24 Jan 2022 21:31:29 +0000
Subject: [PATCH -next v2] ia64: make IA64_MCA_RECOVERY bool instead of tristate
Message-Id: <20220124213129.29306-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, kernel test robot <lkp@intel.com>, Christoph Hellwig <hch@infradead.org>

In linux-next, IA64_MCA_RECOVERY uses the (new) function make_task_dead(),
which is not exported for use by modules. Instead of exporting it for
one user, convert IA64_MCA_RECOVERY to be a bool Kconfig symbol.

In a config file from "kernel test robot <lkp@intel.com>" for a
different problem, this linker error was exposed when
CONFIG_IA64_MCA_RECOVERY=m.

Fixes this build error:

ERROR: modpost: "make_task_dead" [arch/ia64/kernel/mca_recovery.ko] undefined!

Fixes: 0e25498f8cd4 ("exit: Add and use make_task_dead.")
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: kernel test robot <lkp@intel.com>
Suggested-by: Christoph Hellwig <hch@infradead.org>
---
v1 was [PATCH -next] exit: export make_task_dead().
Christoph suggests and prefers that IA64 MCA recovery code just be
forced to be builtin if it is enabled.

 arch/ia64/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20220121.orig/arch/ia64/Kconfig
+++ linux-next-20220121/arch/ia64/Kconfig
@@ -318,7 +318,7 @@ config ARCH_PROC_KCORE_TEXT
 	depends on PROC_KCORE
 
 config IA64_MCA_RECOVERY
-	tristate "MCA recovery from errors other than TLB."
+	bool "MCA recovery from errors other than TLB."
 
 config IA64_PALINFO
 	tristate "/proc/pal support"
