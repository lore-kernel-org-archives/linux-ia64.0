From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 23 Aug 2005 15:01:54 +0000
Subject: git pull on ia64 linux tree
Message-Id: <200508231501.j7NF1s1s022971@agluck-lia64.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
In-Reply-To: <200504222203.j3MM3fV17003@unix-os.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

Last few ia64 fixes for 2.6.13 ... 

please pull from:

	rsync://rsync.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/hp/sim/boot/boot_head.S  |    2 +-
 arch/ia64/hp/sim/boot/bootloader.c |   12 ++++++------
 arch/ia64/sn/kernel/io_init.c      |   18 ++++++++++--------
 include/asm-ia64/io.h              |    8 --------
 4 files changed, 17 insertions(+), 23 deletions(-)

Ian Wienand:
  [IA64] Simulator bootloader fails with gcc 4

Peter Chubb:
  [IA64] Fix simulator boot (for real this time).

Prarit Bhargava:
  [IA64]: SN fix bus->sysdata pointer and memory cleanups

Tony Luck:
  [IA64] remove unused function __ia64_get_io_port_base
  [IA64] backout incorrect fix for simulator boot issue

