From: Kevin Hilman <khilman@kernel.org>
Date: Thu, 13 Nov 2014 22:28:20 +0000
Subject: [PATCH] PM / Runtime: Kconfig: move ia64 dependency to arch/ia64/Kconfig
Message-Id: <1415917702-6742-1-git-send-email-khilman@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Ulf Hansson <ulf.hansson@linaro.org>, Geert Uytterhoeven <geert+renesas@glider.be>, linux-pm@vger.kernel.org, linaro-kernel@lists.linaro.org, Kevin Hilman <khilman@linaro.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, "open list:IA64 Itanium PL..." <linux-ia64@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>

From: Kevin Hilman <khilman@linaro.org>

The IA64_HP_SIM dependency on PM_RUNTIME should be done in the arch
Kconfig instead of in the PM core.  Move it accordingly.

NOTE: arch/ia64/Kconfig currently does a 'select PM', which since
commit 1eb208aea317 (PM: Make CONFIG_PM depend on (CONFIG_PM_SLEEP ||
CONFIG_PM_RUNTIME)) is effectively a noop unless PM_SLEEP or
PM_RUNTIME are set elsewhere.

Signed-off-by: Kevin Hilman <khilman@linaro.org>
---
 arch/ia64/Kconfig    | 1 +
 kernel/power/Kconfig | 1 -
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index c84c88bbbbd7..55bc92ca2ce6 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -233,6 +233,7 @@ config IA64_SGI_UV
 config IA64_HP_SIM
 	bool "Ski-simulator"
 	select SWIOTLB
+	depends on !PM_RUNTIME
 
 endchoice
 
diff --git a/kernel/power/Kconfig b/kernel/power/Kconfig
index bbef57f5bdfd..3d39cc0228e9 100644
--- a/kernel/power/Kconfig
+++ b/kernel/power/Kconfig
@@ -131,7 +131,6 @@ config PM_WAKELOCKS_GC
 
 config PM_RUNTIME
 	bool "Run-time PM core functionality"
-	depends on !IA64_HP_SIM
 	---help---
 	  Enable functionality allowing I/O devices to be put into energy-saving
 	  (low power) states at run time (or autosuspended) after a specified
-- 
2.1.3

