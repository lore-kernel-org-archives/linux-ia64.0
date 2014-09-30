From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:49 +0000
Subject: [RFC PATCH 09/16] metag: support poweroff through poweroff handler call chain
Message-Id: <1412100056-15517-10-git-send-email-linux@roeck-us.net>
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

Cc: James Hogan <james.hogan@imgtec.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/metag/kernel/process.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/metag/kernel/process.c b/arch/metag/kernel/process.c
index 483dff9..ff7f3eb 100644
--- a/arch/metag/kernel/process.c
+++ b/arch/metag/kernel/process.c
@@ -92,6 +92,8 @@ void machine_power_off(void)
 {
 	if (pm_power_off)
 		pm_power_off();
+	else
+		do_kernel_poweroff();
 	smp_send_stop();
 	hard_processor_halt(HALT_OK);
 }
-- 
1.9.1

