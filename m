From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 05 Jan 2006 22:09:54 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200601052209.k05M9sVg016395@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

A couple of easy one-liners as I wake-up from the holiday hibernation.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/setup.c |    2 +-
 arch/ia64/pci/pci.c      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Alex Williamson:
      [IA64] incorrect return from ia64_pci_legacy_write()

Tony Luck:
      [IA64] Fix compile warnings in setup.c

