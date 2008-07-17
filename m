From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 17 Jul 2008 20:31:30 +0000
Subject: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3065E3073@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

        git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 Documentation/ia64/paravirt_ops.txt     |  137 +++++++++
 arch/ia64/Kconfig                       |    4 +-
 arch/ia64/Makefile                      |    6 +
 arch/ia64/kernel/Makefile               |   44 +++
 arch/ia64/kernel/acpi.c                 |    5 +-
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c |    4 +-
 arch/ia64/kernel/entry.S                |  115 +++++---
 arch/ia64/kernel/head.S                 |   41 +++
 arch/ia64/kernel/iosapic.c              |   45 ++-
 arch/ia64/kernel/irq_ia64.c             |   19 +-
 arch/ia64/kernel/ivt.S                  |  462 +++++++++++++++---------------
 arch/ia64/kernel/minstate.h             |   13 +-
 arch/ia64/kernel/module.c               |    3 +-
 arch/ia64/kernel/nr-irqs.c              |   24 ++
 arch/ia64/kernel/paravirt.c             |  369 ++++++++++++++++++++++++
 arch/ia64/kernel/paravirt_inst.h        |   29 ++
 arch/ia64/kernel/paravirtentry.S        |   60 ++++
 arch/ia64/kernel/setup.c                |   10 +
 arch/ia64/kernel/smpboot.c              |    2 +
 arch/ia64/kernel/time.c                 |   23 ++
 arch/ia64/kernel/vmlinux.lds.S          |    1 -
 drivers/char/mmtimer.c                  |   29 +-
 include/asm-ia64/Kbuild                 |    2 +-
 include/asm-ia64/gcc_intrin.h           |   24 +-
 include/asm-ia64/hw_irq.h               |   23 ++-
 include/asm-ia64/intel_intrin.h         |   41 ++--
 include/asm-ia64/intrinsics.h           |   55 ++++
 include/asm-ia64/iosapic.h              |   18 +-
 include/asm-ia64/irq.h                  |    9 +-
 include/asm-ia64/mmu_context.h          |    6 +-
 include/asm-ia64/native/inst.h          |  175 ++++++++++++
 include/asm-ia64/native/irq.h           |   35 +++
 include/asm-ia64/paravirt.h             |  255 +++++++++++++++++
 include/asm-ia64/paravirt_privop.h      |  114 ++++++++
 include/asm-ia64/smp.h                  |    2 +
 include/asm-ia64/system.h               |   11 +-
 include/asm-ia64/uv/uv_mmrs.h           |  423 +++++++++++++++++++++++++++-
 37 files changed, 2251 insertions(+), 387 deletions(-)
 create mode 100644 Documentation/ia64/paravirt_ops.txt
 create mode 100644 arch/ia64/kernel/nr-irqs.c
 create mode 100644 arch/ia64/kernel/paravirt.c
 create mode 100644 arch/ia64/kernel/paravirt_inst.h
 create mode 100644 arch/ia64/kernel/paravirtentry.S
 create mode 100644 include/asm-ia64/native/inst.h
 create mode 100644 include/asm-ia64/native/irq.h
 create mode 100644 include/asm-ia64/paravirt.h
 create mode 100644 include/asm-ia64/paravirt_privop.h

Akiyama, Nobuyuki (1):
      [IA64] adding parameter check to module_free()

Alan Cox (1):
      mmtimer: Push BKL down into the ioctl handler

Alex Chiang (1):
      [IA64] Avoid overflowing ia64_cpu_to_sapicid in acpi_map_lsapic()

Bernhard Walle (1):
      [IA64] Remove experimental status of kdump

Denis V. Lunev (1):
      [IA64] improper printk format in acpi-cpufreq

Dimitri Sivanich (1):
      [IA64] Update ia64 mmr list for SGI uv

Isaku Yamahata (19):
      [IA64] pvops: preparation: remove extern in irq_ia64.c
      [IA64] pvops: preparation: move the constants, LOAD_OFFSET, to a header file.
      [IA64] pvops: preparation: introduce ia64_set_rr0_to_rr4() to make kernel paravirtualization friendly.
      [IA64] pvops: preparation: introduce ia64_get_psr_i() to make kernel paravirtualization friendly.
      [IA64] pvops: introduce pv_info which describes some random info.
      [IA64] pvops: add an early setup hook for pv_ops.
      [IA64] pvops: introduce pv_cpu_ops to paravirtualize privileged instructions.
      [IA64] pvops: preparation for paravirtulization of hand written assembly code.
      [IA64] pvops: define paravirtualized instructions for native.
      [IA64] pvops: paravirtualize minstate.h.
      [IA64] pvops: paravirtualize ivt.S
      [IA64] pvops: paravirtualize entry.S
      [IA64] pvops: paravirtualize NR_IRQS
      [IA64] pvops: define initialization hooks, pv_init_ops, for paravirtualized environment.
      [IA64] pvops: add hooks, pv_iosapic_ops, to paravirtualize iosapic.
      [IA64] pvops: add hooks, pv_irq_ops, to paravirtualized irq related operations.
      [IA64] pvops: add to hooks, pv_time_ops, for steal time accounting.
      [IA64] pvops: documentation on ia64/pv_ops
      [IA64] pv_ops: move some functions in ivt.S to avoid lack of space.



