From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 01 Aug 2007 22:22:33 +0000
Subject: git pull on ia64 linux tree
Message-Id: <617E1C2C70743745A92448908E030B2A0211AA95@scsmsx411.amr.corp.intel.com>
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

 arch/ia64/ia32/sys_ia32.c       |    1 -
 arch/ia64/kernel/iosapic.c      |   19 ++++++++++---------
 arch/ia64/kernel/irq_ia64.c     |   17 ++++++-----------
 arch/ia64/kernel/mca.c          |   17 +++++++++++------
 arch/ia64/kernel/setup.c        |    1 -
 arch/ia64/kernel/smp.c          |    8 +++++---
 arch/ia64/kernel/time.c         |   16 +++++++++++++++-
 arch/ia64/sn/kernel/io_common.c |    2 +-
 arch/ia64/sn/kernel/setup.c     |    1 -
 arch/ia64/sn/kernel/sn2/timer.c |    7 ++-----
 10 files changed, 50 insertions(+), 39 deletions(-)

Avi Kivity (1):
      [IA64] Allow smp_call_function_single() to current cpu

Christoph Lameter (2):
      [IA64] SN2: Fix up sn2_rtc clock
      [IA64] ITC: Reduce rating for ITC clock if ITCs are drifty

Jesper Juhl (1):
      [IA64] Remove a few duplicate includes

Kenji Kaneshige (3):
      [IA64] Fix registered interrupt check
      [IA64] Fix possible race in destroy_and_reserve_irq()
      [IA64] Fix wrong access to irq_desc[] in iosapic_register_intr().

Sam Ravnborg (1):
      [IA64] fix a few section mismatch warnings
