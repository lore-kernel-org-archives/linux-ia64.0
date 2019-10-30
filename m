From: Qais Yousef <qais.yousef@arm.com>
Date: Wed, 30 Oct 2019 15:38:29 +0000
Subject: [PATCH 04/12] ia64: Replace cpu_down with freeze_secondary_cpus
Message-Id: <20191030153837.18107-5-qais.yousef@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191030153837.18107-1-qais.yousef@arm.com>
In-Reply-To: <20191030153837.18107-1-qais.yousef@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Gleixner <tglx@linutronix.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Qais Yousef <qais.yousef@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Use freeze_secondary_cpus() instead of open coding using cpu_down()
directly.

This also prepares to make cpu_up/down a private interface for anything
but the cpu subsystem.

Signed-off-by: Qais Yousef <qais.yousef@arm.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 arch/ia64/kernel/process.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 968b5f33e725..70b433eafa5c 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -647,12 +647,8 @@ cpu_halt (void)
 void machine_shutdown(void)
 {
 #ifdef CONFIG_HOTPLUG_CPU
-	int cpu;
-
-	for_each_online_cpu(cpu) {
-		if (cpu != smp_processor_id())
-			cpu_down(cpu);
-	}
+	/* TODO: Can we use disable_nonboot_cpus()? */
+	freeze_secondary_cpus(smp_processor_id());
 #endif
 #ifdef CONFIG_KEXEC
 	kexec_disable_iosapic();
-- 
2.17.1
