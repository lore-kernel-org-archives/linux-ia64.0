From: Qais Yousef <qais.yousef@arm.com>
Date: Mon, 23 Mar 2020 13:50:56 +0000
Subject: [PATCH v4 03/17] ia64: Replace cpu_down with smp_shutdown_nonboot_cpus()
Message-Id: <20200323135110.30522-4-qais.yousef@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200323135110.30522-1-qais.yousef@arm.com>
In-Reply-To: <20200323135110.30522-1-qais.yousef@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Qais Yousef <qais.yousef@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Use the new smp_shutdown_nonboot_cpus() instead of open coding using
cpu_down() directly.

Use reboot_cpu instead of hardcoding the boot CPU to 0.

This also prepares to make cpu_up/down a private interface for anything
but the cpu subsystem.

Signed-off-by: Qais Yousef <qais.yousef@arm.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 arch/ia64/kernel/process.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 968b5f33e725..bf4c0cdb7a25 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -646,14 +646,8 @@ cpu_halt (void)
 
 void machine_shutdown(void)
 {
-#ifdef CONFIG_HOTPLUG_CPU
-	int cpu;
+	smp_shutdown_nonboot_cpus(reboot_cpu);
 
-	for_each_online_cpu(cpu) {
-		if (cpu != smp_processor_id())
-			cpu_down(cpu);
-	}
-#endif
 #ifdef CONFIG_KEXEC
 	kexec_disable_iosapic();
 #endif
-- 
2.17.1
