From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 16 Jan 2014 22:16:39 +0000
Subject: [PATCH] ia64: don't use module_init for non-modular core kernel/mca.c code
Message-Id: <1389910599-3883-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

The mca.c code is always built in.  It will never be modular,
so using module_init as an alias for __initcall is rather
misleading.

Fix this up now, so that we can relocate module_init from
init.h into module.h in the future.  If we don't do this, we'd
have to add module.h to obviously non-modular code, and that
would be a worse thing.

Direct use of __initcall is discouraged, vs prioritized ones.
Use of device_initcall is consistent with what __initcall
maps onto, and hence does not change the init order, making the
impact of this change zero.   Should someone with real hardware
for boot testing want to change it later to arch_initcall or
something different, they can do that at a later date.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/arch/ia64/sn/kernel/mca.c b/arch/ia64/sn/kernel/mca.c
index 27793f7aa99c..5b799d4deb74 100644
--- a/arch/ia64/sn/kernel/mca.c
+++ b/arch/ia64/sn/kernel/mca.c
@@ -142,5 +142,4 @@ static int __init sn_salinfo_init(void)
 		salinfo_platform_oemdata = &sn_salinfo_platform_oemdata;
 	return 0;
 }
-
-module_init(sn_salinfo_init)
+device_initcall(sn_salinfo_init);
-- 
1.8.5.2

