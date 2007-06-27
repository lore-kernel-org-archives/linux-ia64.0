From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 27 Jun 2007 15:45:35 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A01C6933C@scsmsx411.amr.corp.intel.com>
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

 arch/ia64/kernel/time.c                 |    1 -
 arch/ia64/kernel/unwind.c               |   16 +++++++++++-----
 arch/ia64/mm/hugetlbpage.c              |    3 ++-
 arch/ia64/sn/kernel/xp_nofault.S        |    3 ++-
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    7 ++++---
 arch/ia64/sn/pci/tioca_provider.c       |    4 +++-
 arch/ia64/sn/pci/tioce_provider.c       |    4 +++-
 include/asm-ia64/sn/sn_sal.h            |    4 ++--
 8 files changed, 27 insertions(+), 15 deletions(-)

Dean Nelson (1):
      [IA64] change sh_change_coherence oemcall to use nolock

Jes Sorensen (1):
      [IA64] Make SN2 PCI code use ioremap rather than manually mangle the address

Keith Owens (1):
      [IA64] Correct unwind validation code

MUNEDA Takahiro (1):
      [IA64] remove duplicate header include line

Russ Anderson (1):
      [IA64] Force error to surface in nofault code

vignesh babu (1):
      [IA64] is_power_of_2-ia64/mm/hugetlbpage.c
