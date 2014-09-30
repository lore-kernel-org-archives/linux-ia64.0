From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:47 +0000
Subject: [RFC PATCH 07/16] c6x: support poweroff through poweroff handler call chain
Message-Id: <1412100056-15517-8-git-send-email-linux@roeck-us.net>
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

Cc: Mark Salter <msalter@redhat.com>
Cc: Aurelien Jacquiot <a-jacquiot@ti.com>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/c6x/kernel/process.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/c6x/kernel/process.c b/arch/c6x/kernel/process.c
index 57d2ea8..ddf088e 100644
--- a/arch/c6x/kernel/process.c
+++ b/arch/c6x/kernel/process.c
@@ -75,6 +75,8 @@ void machine_power_off(void)
 {
 	if (pm_power_off)
 		pm_power_off();
+	else
+		do_kernel_poweroff();
 	halt_loop();
 }
 
-- 
1.9.1

