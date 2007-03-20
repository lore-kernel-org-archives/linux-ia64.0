From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 20 Mar 2007 22:11:20 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200703202211.l2KMBKoe032435@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/crash.c      |    2 +-
 arch/ia64/kernel/setup.c      |   22 +++++++++++++++-------
 arch/ia64/mm/contig.c         |   30 ++++++------------------------
 arch/ia64/mm/discontig.c      |    4 +---
 arch/ia64/mm/init.c           |   16 ++++++++++++++++
 arch/ia64/sn/kernel/io_init.c |   12 ++++++++++--
 arch/ia64/sn/kernel/setup.c   |    6 +++---
 include/asm-ia64/meminit.h    |    1 +
 8 files changed, 53 insertions(+), 40 deletions(-)

Bernhard Walle (1):
      [IA64] Fix wrong /proc/iomem on SGI Altix

Jack Steiner (1):
      [IA64] Fix get_model_name() for mixed cpu type systems

Jay Lan (1):
      [IA64] Fix typo/thinko in crash.c

John Keller (1):
      [IA64] Altix: ioremap vga_console_iobase

Zou Nan hai (1):
      [IA64] min_low_pfn and max_low_pfn calculation fix
