From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 22 Aug 2022 02:15:10 +0000
Subject: [RFC 00/10] arm64/riscv: Introduce fast kexec reboot
Message-Id: <20220822021520.6996-1-kernelfans@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-riscv@lists.infradead.org, linux-kernel@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Price <steven.price@arm.com>, Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>, "Jason A. Donenfeld" <Jason@zx2c4.com>, Frederic Weisbecker <frederic@kernel.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Paul Walmsley <paul.walmsley@sifive.com>, Palmer Dabbelt <palmer@dabbelt.com>, Albert Ou <aou@eecs.berkeley.edu>, Peter Zijlstra <peterz@infradead.org>, "Eric W. Biederman" <ebiederm@xmission.com>

On a SMP arm64 machine, it may take a long time to kexec-reboot a new
kernel, where the time is linear to the number of the cpus. On a 80 cpus
machine, it takes about 15 seconds, while with this patch, the time
will dramaticly drop to one second.

*** Current situation 'slow kexec reboot' ***

At present, some architectures rely on smp_shutdown_nonboot_cpus() to
implement "kexec -e". Since smp_shutdown_nonboot_cpus() tears down the
cpus serially, it is very slow.

Take a close look, a cpu_down() processing on a single cpu can approximately be
divided into two stages:
-1. from CPUHP_ONLINE to CPUHP_TEARDOWN_CPU
-2. from CPUHP_TEARDOWN_CPU to CPUHP_AP_IDLE_DEAD
    which is by stop_machine_cpuslocked(take_cpu_down, NULL, cpumask_of(cpu));
    and runs on the teardown cpu.

If these processes can run in parallel, then, the reboot can be speeded
up. That is the aim of this patch.

*** Contrast to other implements ***

X86 and PowerPC have their own machine_shutdown(), which does not reply
on the cpu hot-removing mechanism. They just discriminate some critical
components and tear down in per cpu NMI handler during the kexec
reboot. But for some architectures, let's say arm64, it is not easy to define
these critical component due to various chipmakers' implements.

As a result, sticking to the cpu hot-removing mechanism is the simplest
way to re-implement the parallel. 


*** Things worthy of consideration ***

1. The definition of a clean boundary between the first kernel and the new kernel
-1.1 firmware
     The firmware's internal state should enter into a proper state, so
it can work for the new kernel. And this is achieved by the firmware's
cpuhp_step's teardown interface if any.

-1.2 CPU internal state
     Whether the cache or PMU needs a clean shutdown before rebooting.

2. The dependency of each cpuhp_step
   The boundary of a clean cut involves only few cpuhp_step, but they
may propagate to other cpuhp_step by dependency. This series does not
bother to judge the dependency, instead, just iterate downside each
cpuhp_step. And this strategy demands that each involved cpuhp_step's
teardown procedure supports parallelism.


*** Solution ***

Ideally, if the interface _cpu_down() can be enhanced to enable
parallelism, then the fast reboot can be achieved.

But revisiting the two parts of the current cpu_down() process, the
second part 'stop_machine_cpuslocked()' is a blockade. Packed inside the
_cpu_down(), stop_machine_cpuslocked() only allow one cpu to execute the
teardown.

So this patch breaks down the process of _cpu_down(), and divides the
teardown into three steps.
1. Send each AP from CPUHP_ONLINE to CPUHP_TEARDOWN_CPU
   in parallel.
2. Sync on BP to wait all APs to enter CPUHP_TEARDOWN_CPU state
3. Send each AP from CPUHP_TEARDOWN_CPU to CPUHP_AP_IDLE_DEAD by the
   interface of stop_machine_cpuslocked() in parallel.

Finally the exposed stop_machine_cpuslocked()can be used to support
parallelism.

Apparently, step 2 is introduced in order to satisfy the prerequisite on
which stop_machine_cpuslocked() can start on each cpu.

Then the rest issue is about how to support parallelism in step 1&3.
Fortunately, each subsystem has its own carefully designed lock
mechanism. In each cpuhp_step teardown interface, adapting to the
subsystem's lock rule will make things work.


*** No rollback if failure ***

During kexec reboot, the devices have already been shutdown, there is no
way for system to roll back to a workable state. So this series also
does not consider the rollback issue if a failure on cpu_down() happens,
it just adventures to move on.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Steven Price <steven.price@arm.com>
Cc: Kuppuswamy Sathyanarayanan <sathyanarayanan.kuppuswamy@linux.intel.com>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
Cc: Frederic Weisbecker <frederic@kernel.org>
Cc: Russell King <linux@armlinux.org.uk>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>
Cc: Palmer Dabbelt <palmer@dabbelt.com>
Cc: Albert Ou <aou@eecs.berkeley.edu>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: linux-arm-kernel@lists.infradead.org
To: linux-ia64@vger.kernel.org
To: linux-riscv@lists.infradead.org
To: linux-kernel@vger.kernel.org

Pingfan Liu (10):
  cpu/hotplug: Make __cpuhp_kick_ap() ready for async
  cpu/hotplug: Compile smp_shutdown_nonboot_cpus() conditioned on
    CONFIG_SHUTDOWN_NONBOOT_CPUS
  cpu/hotplug: Introduce fast kexec reboot
  cpu/hotplug: Check the capability of kexec quick reboot
  perf/arm-dsu: Make dsu_pmu_cpu_teardown() parallel
  rcu/hotplug: Make rcutree_dead_cpu() parallel
  lib/cpumask: Introduce cpumask_not_dying_but()
  cpuhp: Replace cpumask_any_but(cpu_online_mask, cpu)
  genirq/cpuhotplug: Ask migrate_one_irq() to migrate to a real online
    cpu
  arm64: smp: Make __cpu_disable() parallel

 arch/Kconfig                             |   4 +
 arch/arm/Kconfig                         |   1 +
 arch/arm/mach-imx/mmdc.c                 |   2 +-
 arch/arm/mm/cache-l2x0-pmu.c             |   2 +-
 arch/arm64/Kconfig                       |   1 +
 arch/arm64/kernel/smp.c                  |  31 +++-
 arch/ia64/Kconfig                        |   1 +
 arch/riscv/Kconfig                       |   1 +
 drivers/dma/idxd/perfmon.c               |   2 +-
 drivers/fpga/dfl-fme-perf.c              |   2 +-
 drivers/gpu/drm/i915/i915_pmu.c          |   2 +-
 drivers/perf/arm-cci.c                   |   2 +-
 drivers/perf/arm-ccn.c                   |   2 +-
 drivers/perf/arm-cmn.c                   |   4 +-
 drivers/perf/arm_dmc620_pmu.c            |   2 +-
 drivers/perf/arm_dsu_pmu.c               |  16 +-
 drivers/perf/arm_smmuv3_pmu.c            |   2 +-
 drivers/perf/fsl_imx8_ddr_perf.c         |   2 +-
 drivers/perf/hisilicon/hisi_uncore_pmu.c |   2 +-
 drivers/perf/marvell_cn10k_tad_pmu.c     |   2 +-
 drivers/perf/qcom_l2_pmu.c               |   2 +-
 drivers/perf/qcom_l3_pmu.c               |   2 +-
 drivers/perf/xgene_pmu.c                 |   2 +-
 drivers/soc/fsl/qbman/bman_portal.c      |   2 +-
 drivers/soc/fsl/qbman/qman_portal.c      |   2 +-
 include/linux/cpuhotplug.h               |   2 +
 include/linux/cpumask.h                  |   3 +
 kernel/cpu.c                             | 213 ++++++++++++++++++++---
 kernel/irq/cpuhotplug.c                  |   3 +-
 kernel/rcu/tree.c                        |   3 +-
 lib/cpumask.c                            |  18 ++
 31 files changed, 281 insertions(+), 54 deletions(-)

-- 
2.31.1
