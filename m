From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 30 Aug 2007 23:03:50 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A024F30AF@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.  The change to drivers/char/hpet.c
makes the hpet timer code there ia64 only until we can do something better
to merge in arch/{i386,x86_64)/kernel/hpet.c

Thanks!

-Tony

 arch/ia64/hp/sim/hpsim_console.c        |   16 ++++++++++++++--
 arch/ia64/hp/sim/hpsim_setup.c          |    9 ++-------
 arch/ia64/hp/sim/simeth.c               |   12 +++---------
 arch/ia64/hp/sim/simscsi.c              |    3 +--
 arch/ia64/kernel/irq_ia64.c             |   28 ++++++++++++++++++++++------
 arch/ia64/kernel/setup.c                |   13 +++++++------
 arch/ia64/kernel/smpboot.c              |    6 ++++++
 arch/ia64/mm/contig.c                   |    3 +++
 arch/ia64/mm/discontig.c                |    3 +++
 arch/ia64/sn/kernel/huberror.c          |   14 ++++++++++----
 arch/ia64/sn/kernel/irq.c               |   15 +++++++++++++++
 arch/ia64/sn/kernel/sn2/sn2_smp.c       |   26 ++++++++++++++++++++++++++
 arch/ia64/sn/kernel/sn2/sn_hwperf.c     |    3 ++-
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    1 +
 arch/ia64/sn/pci/tioca_provider.c       |    2 ++
 arch/ia64/sn/pci/tioce_provider.c       |    1 +
 drivers/char/hpet.c                     |   10 ++++++++++
 include/asm-ia64/hpsim.h                |   16 ++++++++++++++++
 include/asm-ia64/sn/arch.h              |    1 +
 include/asm-ia64/sn/intr.h              |    1 +
 include/asm-ia64/sn/sn_feature_sets.h   |    1 +
 21 files changed, 147 insertions(+), 37 deletions(-)

Jesper Juhl (1):
      [IA64] Remove unnecessary cast of allocation return value in sn_hwperf_enum_objects()

John Keller (1):
      [IA64] SN: Add support for CPU disable

John Stultz (1):
      [HPET] "double" hpet clocksource && hard freeze

Kenji Kaneshige (2):
      [IA64] Fix unexpected interrupt vector handling
      [IA64] Clear pending interrupts at CPU boot up time

Peter Chubb (2):
      [IA64] Enable early console for Ski simulator
      [IA64] Cleanup HPSIM code (was: Re: Enable early console for Ski simulator)

Prarit Bhargava (1):
      [IA64] Stop bogus NMI & softlockup warnings in ia64 show_mem
