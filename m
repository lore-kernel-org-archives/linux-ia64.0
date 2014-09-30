From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:46 +0000
Subject: [RFC PATCH 06/16] avr32: support poweroff through poweroff handler call chain
Message-Id: <1412100056-15517-7-git-send-email-linux@roeck-us.net>
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

Cc: Haavard Skinnemoen <hskinnemoen@gmail.com>
Cc: Hans-Christian Egtvedt <egtvedt@samfundet.no>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/avr32/kernel/process.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/avr32/kernel/process.c b/arch/avr32/kernel/process.c
index 42a53e74..6bd6289 100644
--- a/arch/avr32/kernel/process.c
+++ b/arch/avr32/kernel/process.c
@@ -50,6 +50,8 @@ void machine_power_off(void)
 {
 	if (pm_power_off)
 		pm_power_off();
+	else
+		do_kernel_poweroff();
 }
 
 void machine_restart(char *cmd)
-- 
1.9.1

