From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 17 Aug 2005 17:57:17 +0000
Subject: git pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F04294DCF@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

please pull from:

	
rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git
release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig                 |   11 -
 arch/ia64/configs/sn2_defconfig   |  262
+++++++++++++++++++++++---------------
 arch/ia64/configs/tiger_defconfig |  149 +++++++++++----------
 arch/ia64/configs/zx1_defconfig   |  224
++++++++++++++------------------
 arch/ia64/kernel/perfmon.c        |    1 
 arch/ia64/kernel/salinfo.c        |    3 
 arch/ia64/sn/kernel/io_init.c     |    1 
 drivers/serial/sn_console.c       |    1 
 include/asm-ia64/iosapic.h        |    4 
 9 files changed, 354 insertions(+), 302 deletions(-)

Christoph Hellwig:
  [IA64] update CONFIG_PCI description

Greg Edwards:
  [IA64] Refresh arch/ia64/configs/sn2_defconfig.

Keith Owens:
  [IA64] Initialize some spinlocks

Kenji Kaneshige:
  [IA64] fix iosapic_remove build error for !HOTPLUG

Peter Chubb:
  [IA64] Updated zx1 defconfig

stephane.eranian@hp.com:
  [IA64] fix perfmon context load

Tony Luck:
  [IA64] Updated tiger defconfig

