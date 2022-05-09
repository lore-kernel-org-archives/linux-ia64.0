From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 09 May 2022 04:13:05 +0000
Subject: [PATCHv3 2/2] arm/arm64/ia64: kexec: fix the primary cpu passed to smp_shutdown_nonboot_cpus()
Message-Id: <20220509041305.15056-3-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220509041305.15056-1-kernelfans@gmail.com>
In-Reply-To: <20220509041305.15056-1-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Jens Axboe <axboe@kernel.dk>, Russell King <linux@armlinux.org.uk>, Guenter Roeck <linux@roeck-us.net>, Arnd Bergmann <arnd@arndb.de>, Wolfram Sang <wsa+renesas@sang-engineering.com>, Lee Jones <lee.jones@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Peter Collingbourne <pcc@google.com>, Marc Zyngier <maz@kernel.org>, linux-kernel@vger.kernel.org

kernel_kexec()->migrate_to_reboot_cpu() has already pinned the reboot
thread on a valid online cpu, either reboot_cpu or the first online cpu.

So machine_shutdown() should pass smp_processor_id() of the pinned
thread as the primary cpu to smp_shutdown_nonboot_cpus().

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Kees Cook <keescook@chromium.org>
Cc: Jens Axboe <axboe@kernel.dk>
To: linux-ia64@vger.kernel.org
Cc: Russell King <linux@armlinux.org.uk>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Wolfram Sang <wsa+renesas@sang-engineering.com>
Cc: Lee Jones <lee.jones@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Peter Collingbourne <pcc@google.com>
Cc: Marc Zyngier <maz@kernel.org>
To: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
---
 arch/arm/kernel/reboot.c    | 2 +-
 arch/arm64/kernel/process.c | 2 +-
 arch/ia64/kernel/process.c  | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/arm/kernel/reboot.c b/arch/arm/kernel/reboot.c
index 3044fcb8d073..898405682e08 100644
--- a/arch/arm/kernel/reboot.c
+++ b/arch/arm/kernel/reboot.c
@@ -91,7 +91,7 @@ void soft_restart(unsigned long addr)
  */
 void machine_shutdown(void)
 {
-	smp_shutdown_nonboot_cpus(reboot_cpu);
+	smp_shutdown_nonboot_cpus(smp_processor_id());
 }
 
 /*
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 7fa97df55e3a..e5c130582cc6 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -86,7 +86,7 @@ void arch_cpu_idle_dead(void)
  */
 void machine_shutdown(void)
 {
-	smp_shutdown_nonboot_cpus(reboot_cpu);
+	smp_shutdown_nonboot_cpus(smp_processor_id());
 }
 
 /*
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index d7a256bd9d6b..ae732e35e7da 100644
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
