From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 08 Mar 2007 01:09:49 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200703080109.l2819nmO023970@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

A few more ia64 fixes.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/kernel/asm-offsets.c |    1 
 arch/ia64/kernel/efi.c         |   10 +--
 arch/ia64/kernel/fsys.S        |  105 +++++++++++++++++++++++++++++++++++++++++
 arch/ia64/kernel/iosapic.c     |    8 ++-
 arch/ia64/kernel/setup.c       |    2 
 arch/ia64/sn/kernel/irq.c      |   14 +++++
 6 files changed, 130 insertions(+), 10 deletions(-)

Fenghua Yu:
      [IA64] fsys_getcpu for IA64

Horms:
      [IA64] remove duplicate declaration of efi_initialize_iomem_resources

KAMEZAWA Hiroyuki:
      [IA64] fix NULL pointer in ia64/irq_chip-mask/unmask function

Tony Luck:
      [IA64] Pick highest possible saved_max_pfn for crash_dump
