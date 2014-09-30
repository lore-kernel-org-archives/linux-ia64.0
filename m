From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:53 +0000
Subject: [RFC PATCH 13/16] x86: support poweroff through poweroff handler call chain
Message-Id: <1412100056-15517-14-git-send-email-linux@roeck-us.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
In-Reply-To: <1412100056-15517-1-git-send-email-linux@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

The kernel core now supports a poweroff handler call chain
to remove power from the system. Call it if pm_power_off
is set to NULL.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/x86/kernel/reboot.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/x86/kernel/reboot.c b/arch/x86/kernel/reboot.c
index 17962e6..c5514aa 100644
--- a/arch/x86/kernel/reboot.c
+++ b/arch/x86/kernel/reboot.c
@@ -651,6 +651,10 @@ static void native_machine_power_off(void)
 		if (!reboot_force)
 			machine_shutdown();
 		pm_power_off();
+	} else {
+		if (!reboot_force)
+			machine_shutdown();
+		do_kernel_poweroff();
 	}
 	/* A fallback in case there is no PM info available */
 	tboot_shutdown(TB_SHUTDOWN_HALT);
-- 
1.9.1

