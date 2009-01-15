From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 15 Jan 2009 19:45:33 +0000
Subject: [git pull] ia64 changes
Message-Id: <200901151945.n0FJjXMe001477@agluck-lia64.sc.intel.com>
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

 Documentation/DMA-API.txt            |    9 ++++-----
 arch/ia64/Kconfig                    |    1 +
 arch/ia64/configs/generic_defconfig  |    2 +-
 arch/ia64/include/asm/dma-mapping.h  |    2 ++
 arch/ia64/include/asm/machvec.h      |    7 +++++++
 arch/ia64/include/asm/machvec_init.h |    1 +
 arch/ia64/include/asm/machvec_sn2.h  |    2 ++
 arch/ia64/kernel/unaligned.c         |    6 +++++-
 arch/ia64/pci/pci.c                  |   27 +++++++++++++++++++++++++++
 arch/ia64/sn/pci/pci_dma.c           |    6 ++++++
 arch/ia64/xen/time.c                 |    4 ++--
 kernel/sysctl.c                      |    9 +++++++++
 12 files changed, 67 insertions(+), 9 deletions(-)

Brent Casavant (1):
      [IA64] generic_defconfig: Enable SATA_VITESSE

Doug Chapman (1):
      [IA64] dump stack on kernel unaligned warnings

Isaku Yamahata (1):
      [IA64] Update to use account_{steal,idle}_ticks

John Keller (1):
      [IA64] SN specific version of dma_get_required_mask()

Tony Luck (1):
      [IA64] Turn on CONFIG_HAVE_UNSTABLE_CLOCK

