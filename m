From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 12 May 2022 03:06:17 +0000
Subject: [PATCHv4 0/2] cpu/hotplug: Keep cpu hotplug disabled until the rebooting cpu is stable
Message-Id: <20220512030619.13426-1-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kexec@lists.infradead.org

For the architectures (arm/arm64/ia64/riscv), which relies on the cpu
hot-removing mechanism to implement "kexec -e", it is important to
ensure that the rebooting happens on a valid online cpu. And this logic
should have been guaranteed in migrate_to_reboot_cpu().

But the current code has either contradict (resolved by [2/2]) or
redundancy (resolved by [1/2]) about the logic.


V3 -> V4:
Fix the cpu hotplug enable before kexec-rebooting in powerpc.
Improve commit log and the code's note.

V2 -> V3:
Taking in [2/2], which also has problem with the valid rebooting
cpu. (I had sent three patches for different arches. But maybe it is
better to collapse them into one and collect acks from different arches'
maintainers )

Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
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

Pingfan Liu (2):
  cpu/hotplug: Keep cpu hotplug disabled until the rebooting cpu is
    stable
  cpu/hotplug: Remove the input parameter primary_cpu of
    smp_shutdown_nonboot_cpus()

 arch/arm/kernel/reboot.c          |  2 +-
 arch/arm64/kernel/process.c       |  2 +-
 arch/ia64/kernel/process.c        |  2 +-
 arch/powerpc/kexec/core_64.c      |  1 +
 arch/riscv/kernel/machine_kexec.c |  2 +-
 include/linux/cpu.h               |  4 ++--
 kernel/cpu.c                      | 14 +++++++-------
 kernel/kexec_core.c               | 11 +++++------
 8 files changed, 19 insertions(+), 19 deletions(-)

-- 
2.31.1
