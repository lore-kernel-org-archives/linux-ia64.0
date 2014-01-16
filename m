From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 16 Jan 2014 22:18:05 +0000
Subject: [PATCH] ia6: don't use module_init in non-modular sim/simscsi.c code
Message-Id: <1389910685-3958-1-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

The simscsi.o is built for HP_SIMSCSI -- which is bool, and hence
this code is either present or absent.  It will never be modular,
so using module_init as an alias for __initcall can be somewhat
misleading.

Fix this up now, so that we can relocate module_init from
init.h into module.h in the future.  If we don't do this, we'd
have to add module.h to obviously non-modular code, and that
would be a worse thing.

Note that direct use of __initcall is discouraged, vs. one
of the priority categorized subgroups.  As __initcall gets
mapped onto device_initcall, our use of device_initcall
directly in this change means that the runtime impact is
zero -- it will remain at level 6 in initcall ordering.

And since it can't be modular, we remove all the __exitcall
stuff related to module_exit() -- it is dead code that won't
ever be executed.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

diff --git a/arch/ia64/hp/sim/simscsi.c b/arch/ia64/hp/sim/simscsi.c
index 3a428f19a001..085047f3a545 100644
--- a/arch/ia64/hp/sim/simscsi.c
+++ b/arch/ia64/hp/sim/simscsi.c
@@ -368,13 +368,4 @@ simscsi_init(void)
 	scsi_host_put(host);
 	return error;
 }
-
-static void __exit
-simscsi_exit(void)
-{
-	scsi_remove_host(host);
-	scsi_host_put(host);
-}
-
-module_init(simscsi_init);
-module_exit(simscsi_exit);
+device_initcall(simscsi_init);
-- 
1.8.5.2

