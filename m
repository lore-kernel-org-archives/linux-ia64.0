From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 09 Nov 2005 05:52:46 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200511090552.jA95qkK2015958@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/mca_drv.c              |    3 ++-
 arch/ia64/sn/pci/pcibr/pcibr_provider.c |    4 ++--
 arch/ia64/sn/pci/pcibr/pcibr_reg.c      |    2 +-
 3 files changed, 5 insertions(+), 4 deletions(-)

Mark Maule:
      [IA64] altix: misc pci interrupt related fixes

Russ Anderson:
      [IA64] MCA recovery: pfn_valid() needs a pfn
      [IA64] MCA recovery: Bump reference count on bad pages

