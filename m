From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 09 May 2022 04:13:03 +0000
Subject: [PATCHv3 0/2] cpu/hotplug: Keep cpu hotplug disabled until the rebooting cpu is stable
Message-Id: <20220509041305.15056-1-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Eric Biederman <ebiederm@xmission.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Valentin Schneider <valentin.schneider@arm.com>, Vincent Donnefort <vincent.donnefort@arm.com>, Ingo Molnar <mingo@kernel.org>, YueHaibing <yuehaibing@huawei.com>, Baokun Li <libaokun1@huawei.com>, Randy Dunlap <rdunlap@infradead.org>, kexec@lists.infradead.org, Geert Uytterhoeven <geert@linux-m68k.org>, Kees Cook <keescook@chromium.org>, Jens Axboe <axboe@kernel.dk>, Russell King <linux@armlinux.org.uk>, Guenter Roeck <linux@roeck-us.net>, Arnd Bergmann <arnd@arndb.de>, Wolfram Sang <wsa+renesas@sang-engineering.com>, Lee Jones <lee.jones@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Peter Collingbourne <pcc@google.com>, Marc Zyngier <maz@kernel.org>

For the arches (arm/arm64/ia64/riscv), which relies on the cpu hot-removing
mechanism to implement "kexec -e", it is important to make sure that the
rebooting happens on a valid online cpu. And this logic should have been
guaranteed in migrate_to_reboot_cpu().

But the current code has either contradict (resolved by [2/2]) or
redundancy (resolved by [1/2]) about the logic.

V2 -> V3:
Taking in [2/2], which also has problem with the valid rebooting
cpu. (I had sent three patches for different arches. But maybe it is
better to collapse them into one and collect acks from different arches'
maintainers )

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Valentin Schneider <valentin.schneider@arm.com>
Cc: Vincent Donnefort <vincent.donnefort@arm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: YueHaibing <yuehaibing@huawei.com>
Cc: Baokun Li <libaokun1@huawei.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Valentin Schneider <valentin.schneider@arm.com>
Cc: kexec@lists.infradead.org
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
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
Cc: Peter Collingbourne <pcc@google.com>
Cc: Marc Zyngier <maz@kernel.org>
To: linux-arm-kernel@lists.infradead.org
To: linux-kernel@vger.kernel.org

Pingfan Liu (2):
  cpu/hotplug: Keep cpu hotplug disabled until the rebooting cpu is
    stable
  arm/arm64/ia64: kexec: fix the primary cpu passed to
    smp_shutdown_nonboot_cpus()

 arch/arm/kernel/reboot.c    |  2 +-
 arch/arm64/kernel/process.c |  2 +-
 arch/ia64/kernel/process.c  |  2 +-
 kernel/cpu.c                | 16 ++++++++++------
 kernel/kexec_core.c         | 10 ++++------
 5 files changed, 17 insertions(+), 15 deletions(-)

-- 
2.31.1
