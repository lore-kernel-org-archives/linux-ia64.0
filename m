From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 17 Jul 2007 16:35:48 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A01F27CD3@scsmsx411.amr.corp.intel.com>
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

 arch/ia64/hp/common/sba_iommu.c     |   20 ++++++++++++++++++--
 arch/ia64/hp/sim/boot/fw-emu.c      |    5 -----
 arch/ia64/hp/sim/simserial.c        |    4 ----
 arch/ia64/kernel/fsys.S             |    4 +++-
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    3 ++-
 include/asm-ia64/ioctls.h           |    4 ++++
 include/asm-ia64/termbits.h         |    5 ++++-
 include/asm-ia64/termios.h          |    6 ++++--
 8 files changed, 35 insertions(+), 16 deletions(-)

Alan Cox (1):
      [IA64] arbitary speed tty ioctl support

Hidetoshi Seto (1):
      [IA64] ar.itc access must really be after xtime_lock.sequence has been read

Mark Goodwin (1):
      [IA64] correctly count CPU objects in the ia64/sn hwperf interface

Terry Loftin (1):
      [IA64] use machvec=dig on hpzx1 platforms

Tony Luck (1):
      [IA64] Clean away some code inside some non-existent CONFIG ifdefs
