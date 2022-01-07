From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 07 Jan 2022 02:05:06 +0000
Subject: [PATCH 1/3] ia64: kexec: fix the primary cpu passed to smp_shutdown_nonboot_cpus()
Message-Id: <20220107020508.9778-1-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

kernel_kexec()->migrate_to_reboot_cpu() has already pinned the reboot
thread on either reboot_cpu or the first online cpu.

So machine_shutdown() should pass smp_processor_id() as the primary cpu
to smp_shutdown_nonboot_cpus().

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Jens Axboe <axboe@kernel.dk>
To: linux-ia64@vger.kernel.org
---
 arch/ia64/kernel/process.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 834df24a88f1..88ca3f587783 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -575,7 +575,7 @@ cpu_halt (void)
 
 void machine_shutdown(void)
 {
-	smp_shutdown_nonboot_cpus(reboot_cpu);
+	smp_shutdown_nonboot_cpus(smp_processor_id());
 
 #ifdef CONFIG_KEXEC
 	kexec_disable_iosapic();
-- 
2.31.1
