From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Mar 2007 00:35:52 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200703070035.l270Zqnh019703@agluck-lia64.sc.intel.com>
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

This will update the files shown below.  The big change to swiotlb.c
is backing out a change from Jan to make his life easier with Xen, but
is "more than ugly" according to Christoph (and having re-read it, I
have to agree with him).

Thanks!

-Tony

 include/asm-ia64/swiotlb.h   |    9 --
 arch/ia64/ia32/sys_ia32.c    |   10 +-
 arch/ia64/kernel/efi.c       |   36 ++++++++
 arch/ia64/kernel/perfmon.c   |   11 +-
 arch/ia64/kernel/setup.c     |   30 +++++++
 arch/ia64/lib/Makefile       |    3 
 arch/ia64/mm/contig.c        |    5 -
 arch/ia64/mm/discontig.c     |    6 -
 include/asm-ia64/meminit.h   |    6 +
 include/asm-ia64/resource.h  |    1 
 include/asm-x86_64/swiotlb.h |    1 
 lib/swiotlb.c                |  184 ++++++++-----------------------------------
 12 files changed, 121 insertions(+), 181 deletions(-)

Alexandr Andreev:
      [IA64] sync compat getdents

Horms:
      [IA64] point saved_max_pfn to the max_pfn of the entire system

Lee Schermerhorn:
      [IA64] always build arch/ia64/lib/xor.o

Magnus Damm:
      [IA64] kexec: Use EFI_LOADER_DATA for ELF core header

Nick Piggin:
      [IA64] permon use-after-free fix

schwab@suse.de:
      [IA64] Remove stack hard limit on ia64

Tony Luck:
      Revert "[IA64] swiotlb abstraction (e.g. for Xen)"
