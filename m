From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 30 Sep 2014 18:00:52 +0000
Subject: [RFC PATCH 12/16] unicore32: support poweroff through poweroff handler call chain
Message-Id: <1412100056-15517-13-git-send-email-linux@roeck-us.net>
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

Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 arch/unicore32/kernel/process.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/unicore32/kernel/process.c b/arch/unicore32/kernel/process.c
index b008e99..421fde6 100644
--- a/arch/unicore32/kernel/process.c
+++ b/arch/unicore32/kernel/process.c
@@ -66,6 +66,8 @@ void machine_power_off(void)
 {
 	if (pm_power_off)
 		pm_power_off();
+	else
+		do_kernel_poweroff();
 	machine_halt();
 }
 
-- 
1.9.1

