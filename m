From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 07 Mar 2007 00:54:23 +0000
Subject: RE: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A013577B7@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

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

I'll be merging more of my backlog of fixes and sending
them up to Linus too ... so don't panic if your patch
wasn't in this bundle).

-Tony
