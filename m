From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 28 Jun 2006 19:03:40 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200606281903.k5SJ3e2K013688@agluck-lia64.sc.intel.com>
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

 arch/ia64/configs/tiger_defconfig |    2 +-
 arch/ia64/kernel/palinfo.c        |    2 +-
 arch/ia64/sn/kernel/setup.c       |   12 +++++++++---
 arch/ia64/sn/pci/tioca_provider.c |    2 +-
 include/asm-ia64/sn/sn_sal.h      |   10 ++++++++++
 5 files changed, 22 insertions(+), 6 deletions(-)

Aaron Young:
      [IA64-SGI] fix prom revision checks in SN kernel

Jack Steiner:
      [IA64-SGI] - Pass OS logical cpu number to the SN prom (bios)

Tony Luck:
      [IA64] palinfo.c: s/register_cpu_notifier/register_hotcpu_notifier/
      [IA64] tiger_defconfig s/NR_CPUS=4/NR_CPUS/
