From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 30 Mar 2007 02:30:24 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200703300230.l2U2UOHe010532@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/msi_ia64.c |    2 +-
 arch/ia64/kernel/smpboot.c  |   17 ++++++++++++++++-
 arch/ia64/mm/init.c         |    2 +-
 arch/ia64/pci/pci.c         |    1 -
 4 files changed, 18 insertions(+), 4 deletions(-)

Jack Steiner (1):
      [IA64] Speed up boot - skip unnecessary clock calibration

KAMEZAWA Hiroyuki (1):
      [IA64] bugfix stack layout upside-down

Kenji Kaneshige (1):
      [IA64] Fix possible invalid memory access in ia64_setup_msi_irq()

Tony Luck (1):
      [IA64] Fix arch/ia64/pci/pci.c:571: warning: `return' with a value
