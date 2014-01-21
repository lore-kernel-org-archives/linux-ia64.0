From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 21 Jan 2014 21:22:28 +0000
Subject: [PATCH 25/73] ia64: don't use module_init for non-modular core kernel/mca.c code
Message-Id: <1390339396-3479-26-git-send-email-paul.gortmaker@windriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1390339396-3479-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

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
---
 arch/ia64/sn/kernel/mca.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/mca.c b/arch/ia64/sn/kernel/mca.c
index 27793f7..5b799d4d 100644
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
1.8.4.1

