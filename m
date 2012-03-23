From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 23 Mar 2012 17:23:14 +0000
Subject: [GIT PULL] ia64 changes
Message-Id: <4f6cb1823081914aa@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit 62aa2b537c6f5957afd98e29f96897419ed5ebab:

  Linux 3.3-rc2 (2012-01-31 13:31:54 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git ia64-for-linus

for you to fetch changes up to b86c4782ab501e3b69e5e0b32050455f95caa681:

  Documentation/kernel-parameters: remove inttest parameter (2012-03-22 16:07:18 -0700)

----------------------------------------------------------------
Miscellaneous Itanium patches

----------------------------------------------------------------
Dimitri Sivanich (1):
      [IA64] genirq fixup for SGI/SN

Jiri Kosina (1):
      [IA64] disable interrupts when exiting from ia64_mca_cmc_int_handler()

Jiri Slaby (4):
      [IA64] hpsim, fix SAL handling in fw-emu
      [IA64] simserial, include some headers
      [IA64] hpsim, initialize chip for assigned irqs
      [IA64] simserial, bail out when request_irq fails

Liu Jiang (1):
      [IA64] Fix ISA IRQ trigger model and polarity setting

Paul Gortmaker (3):
      [IA64] Fix warning from machine_kexec.c
      [IA64] Check return from device_register() in cx_device_register()
      [IA64] Fix a couple of warnings for EXPORT_SYMBOL

Sebastian Andrzej Siewior (1):
      Documentation/kernel-parameters: remove inttest parameter

 Documentation/kernel-parameters.txt     |    2 -
 arch/ia64/hp/sim/boot/fw-emu.c          |   17 +++-----------
 arch/ia64/hp/sim/hpsim_irq.c            |   36 +++++++++++++++++++++++++-----
 arch/ia64/hp/sim/hpsim_setup.c          |    6 -----
 arch/ia64/hp/sim/simeth.c               |   19 ++-------------
 arch/ia64/hp/sim/simserial.c            |   20 ++++-------------
 arch/ia64/include/asm/hpsim.h           |    2 +-
 arch/ia64/kernel/acpi.c                 |    8 +++---
 arch/ia64/kernel/machine_kexec.c        |    2 +-
 arch/ia64/kernel/mca.c                  |    2 +
 arch/ia64/sn/kernel/huberror.c          |    2 +
 arch/ia64/sn/kernel/io_common.c         |    1 +
 arch/ia64/sn/kernel/irq.c               |    2 +
 arch/ia64/sn/kernel/sn2/sn_hwperf.c     |    1 +
 arch/ia64/sn/kernel/tiocx.c             |    7 +++++-
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    1 +
 arch/ia64/sn/pci/tioca_provider.c       |    1 +
 arch/ia64/sn/pci/tioce_provider.c       |    1 +
 drivers/tty/serial/sn_console.c         |    1 +
 19 files changed, 66 insertions(+), 65 deletions(-)
