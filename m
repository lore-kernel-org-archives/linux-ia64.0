From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 01 Apr 2006 01:11:15 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200604010111.k311BFdT010927@agluck-lia64.sc.intel.com>
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

 arch/ia64/kernel/palinfo.c  |    8 
 arch/ia64/kernel/time.c     |    2 
 arch/ia64/kernel/topology.c |  367 ++++++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/pal.h      |   34 +++-
 4 files changed, 403 insertions(+), 8 deletions(-)

Tony Luck:
      [IA64] Avoid "u64 foo : 32;" for gcc3 vs. gcc4 compatibility

Zhang, Yanmin:
      [IA64] Export cpu cache info by sysfs
