From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 21 Oct 2014 04:12:54 +0000
Subject: [PATCH v2 38/47] ia64: Register with kernel poweroff handler
Message-Id: <1413864783-3271-39-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1413864783-3271-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1413864783-3271-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-pm@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Register with kernel poweroff handler instead of setting pm_power_off
directly. Register with low priority to reflect that the call is expected
to be replaced at some point in the future.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
- Use define to specify poweroff handler priority

 arch/ia64/sn/kernel/setup.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 5f6b6b4..1888aeb 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -488,12 +488,13 @@ void __init sn_setup(char **cmdline_p)
 	sn_timer_init();
 
 	/*
-	 * set pm_power_off to a SAL call to allow
+	 * set poweroff handler to a SAL call to allow
 	 * sn machines to power off. The SAL call can be replaced
 	 * by an ACPI interface call when ACPI is fully implemented
 	 * for sn.
 	 */
-	pm_power_off = ia64_sn_power_down;
+	register_power_off_handler_simple(ia64_sn_power_down,
+					  POWEROFF_PRIORITY_LOW);
 	current->thread.flags |= IA64_THREAD_MIGRATION;
 }
 
-- 
1.9.1

