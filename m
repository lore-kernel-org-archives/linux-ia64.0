From: Alex Chiang <achiang@hp.com>
Date: Fri, 06 Feb 2009 16:49:06 +0000
Subject: [PATCH] ia64: don't need cpu_set() when migrate_platform_irqs()
Message-Id: <20090206164906.GA2445@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Commit e7b14036 (prevent ia64 from invoking irq handlers on
offline CPUs) removed the call to cpu_clear() before we call
migrate_platform_irqs().

Thus, if migrate_platform_irqs() fails (returns -EBUSY), we do
not need to re-set our CPU in the cpu_online_map, since it was
never cleared.

Remove the redundant call and cleanup the resulting stylistic
fallout.

Signed-off-by: Alex Chiang <achiang@hp.com>
---

Tony, unlike my previous patch, this patch is .30 material,
thanks.

---

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 1146399..92fe9cf 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -736,10 +736,8 @@ int __cpu_disable(void)
 			return -EBUSY;
 	}
 
-	if (migrate_platform_irqs(cpu)) {
-		cpu_set(cpu, cpu_online_map);
-		return (-EBUSY);
-	}
+	if (migrate_platform_irqs(cpu))
+		return -EBUSY;
 
 	remove_siblinginfo(cpu);
 	fixup_irqs();
