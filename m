From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 17 Aug 2007 23:25:53 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A02322D33@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
release

This will update the files shown below.  The change to mod_devicetable.h
fixes a cross-build problem because of different rules for aligning
8-byte sized objects between $HOSTCC and $CC

Thanks!

-Tony

 arch/ia64/Kconfig                       |   12 -----------
 arch/ia64/configs/bigsur_defconfig      |    2 -
 arch/ia64/configs/gensparse_defconfig   |    2 -
 arch/ia64/configs/sim_defconfig         |    2 -
 arch/ia64/configs/sn2_defconfig         |    2 -
 arch/ia64/configs/tiger_defconfig       |    2 -
 arch/ia64/configs/zx1_defconfig         |    2 -
 arch/ia64/defconfig                     |    3 --
 arch/ia64/hp/sim/boot/boot_head.S       |    1 
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c |    6 +----
 arch/ia64/kernel/irq.c                  |    5 ++++
 arch/ia64/kernel/mca.c                  |   34
+++++++++++++++++---------------
 arch/ia64/kernel/process.c              |   10 ++++++---
 arch/ia64/kernel/ptrace.c               |   10 ++++++---
 arch/ia64/kernel/setup.c                |    7 ++++++
 arch/ia64/kernel/vmlinux.lds.S          |   12 ++++++-----
 arch/ia64/mm/fault.c                    |   14 ++++++++++---
 arch/ia64/sn/kernel/irq.c               |   12 ++++++++++-
 include/asm-ia64/atomic.h               |    4 +--
 include/asm-ia64/hw_irq.h               |    7 +++++-
 include/asm-ia64/machvec.h              |    7 ++++++
 include/asm-ia64/machvec_init.h         |    1 
 include/asm-ia64/machvec_sn2.h          |    2 +
 include/linux/mod_devicetable.h         |    3 +-
 24 files changed, 105 insertions(+), 57 deletions(-)

Alex Williamson (1):
      [IA64] Fix processor_get_freq

Andreas Schwab (1):
      [IA64] Use atomic64_read to read an atomic64_t.

Andrew Burgess (1):
      [IA64] Failure to grow RBS

Christoph Lameter (1):
      [IA64] Update arch/ia64/configs/* s/SLAB/SLUB/

David Mosberger-Tang (3):
      [IA64] make unwinder stop at last frame of the bootloader
      [IA64] need NOTES in vmlinux.lds.S
      [IA64] get back PT_IA_64_UNWIND program header

Dimitri Sivanich (1):
      [IA64] disable irq's and check need_resched before safe_halt

Kenji Kaneshige (1):
      [IA64] SN2 needs platform specific irq_to_vector() function.

Mike Habeck (1):
      [IA64] SGI Altix : fix a force_interrupt bug on altix

Peter Chubb (1):
      [IA64] Enable early console for Ski simulator

Russ Anderson (1):
      [IA64] Clean up CPE handler registration

Satyam Sharma (1):
      [IA64] Include Kconfig.preempt

Shaohua Li (1):
      [IA64] forbid ptrace changes psr.ri to 3

Thomas Renninger (1):
      Cross-compilation between e.g. i386 -> 64bit could break -> work
around it
