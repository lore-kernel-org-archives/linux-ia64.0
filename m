From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 10 Apr 2007 20:58:56 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200704102103.l3AL3j0N010393@agluck-lia64.sc.intel.com>
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

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/msi_ia64.c          |    4 ++--
 arch/ia64/kernel/setup.c             |    2 +-
 arch/ia64/sn/kernel/bte_error.c      |    6 +++---
 arch/ia64/sn/pci/pcibr/pcibr_dma.c   |    8 ++++++--
 include/asm-ia64/sn/pcibr_provider.h |    5 +++--
 5 files changed, 15 insertions(+), 10 deletions(-)

Ishimatsu Yasuaki (1):
      [IA64] Fix wrong assumption about irq and vector in msi_ia64.c

Mike Habeck (1):
      [IA64] SGI Altix : fix pcibr_dmamap_ate32() bug

Russ Anderson (1):
      [IA64] BTE error timer fix

Venki Pallipadi (1):
      [IA64] Fix CPU freq displayed in /proc/cpuinfo
