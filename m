From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 11 Nov 2005 20:07:49 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200511112007.jABK7nAS030843@agluck-lia64.sc.intel.com>
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

P.S. Robin Holt's "4-level page table" patch may sound a bit scary for the
last day of merge time ... but it provides a config option to choose either
3-level or 4-level, and the default stays at 3-level for all platforms except
Altix (with their multi-terabyte memory).  Apart from rescheduling a few
instructions in ivt.S handlers, his patch leaves the whole kernel unchanged
at a binary level when using 3-level page tables.

 arch/ia64/Kconfig               |   13 +++
 arch/ia64/configs/sn2_defconfig |    2 
 arch/ia64/defconfig             |    2 
 arch/ia64/kernel/ivt.S          |   63 ++++++++++++----
 arch/ia64/sn/kernel/setup.c     |  157 ++++++++++++++++++++++++++++++++++++++--
 include/asm-ia64/page.h         |    8 +-
 include/asm-ia64/pgalloc.h      |   19 ++++
 include/asm-ia64/pgtable.h      |   76 +++++++++++++++----
 8 files changed, 303 insertions(+), 37 deletions(-)

Mark Maule:
      [IA64-SGI] set altix preferred console

Robin Holt:
      [IA64] 4-level page tables

