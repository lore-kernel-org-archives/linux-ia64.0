From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 09 Dec 2008 22:28:28 +0000
Subject: [git pull] ia64 changes
Message-Id: <200812092228.mB9MSSxv005263@agluck-lia64.sc.intel.com>
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

 arch/ia64/configs/generic_defconfig     |  218 +++++++++++++++++++++----------
 arch/ia64/include/asm/paravirt_privop.h |    1 -
 arch/ia64/kernel/topology.c             |    4 +-
 arch/ia64/sn/kernel/irq.c               |    9 +-
 arch/ia64/sn/kernel/setup.c             |    9 +-
 drivers/ide/sgiioc4.c                   |    6 +-
 drivers/misc/sgi-gru/grufault.c         |    4 +
 drivers/serial/ioc3_serial.c            |    6 +-
 8 files changed, 171 insertions(+), 86 deletions(-)

Alexey Dobriyan (1):
      [IA64] remove BUILD_BUG_ON from paravirt_getreg()

Jack Steiner (1):
      [IA64] Fix GRU compile error w/o CONFIG_HUGETLB_PAGE

John Keller (1):
      [IA64] SN: prevent IRQ retargetting in request_irq()

Julia Lawall (1):
      [IA64] eliminate NULL test and memset after alloc_bootmem

Robin Holt (4):
      [IA64] Updated the generic_defconfig to work with the 2.6.28-rc7 kernel.
      [IA64] Clear up section mismatch for sn_check_wars.
      [IA64] Clear up section mismatch with arch_unregister_cpu()
      [IA64] Clear up section mismatch for ioc4_ide_attach_one.

Tony Luck (1):
      [IA64] Fix section mismatch ioc3uart_init()/ioc3uart_submodule

