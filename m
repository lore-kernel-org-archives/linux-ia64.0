From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 02 Nov 2009 18:07:50 +0000
Subject: [git pull] ia64 changes
Message-Id: <4aef1ff632340df3fa@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
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

 arch/ia64/include/asm/spinlock.h       |   62 +++++++++++++-------
 arch/ia64/include/asm/spinlock_types.h |    2 +-
 arch/ia64/kernel/mca.c                 |  104 +++++++++++++++++--------------
 arch/ia64/kernel/unaligned.c           |    6 +-
 arch/ia64/mm/tlb.c                     |   24 ++++++--
 arch/ia64/pci/pci.c                    |    9 ++-
 arch/ia64/sn/kernel/io_common.c        |    8 +--
 arch/ia64/sn/kernel/sn2/sn_hwperf.c    |    7 +-
 8 files changed, 132 insertions(+), 90 deletions(-)

Marcin Slusarz (1):
      [IA64] use printk_once() unaligned.c/io_common.c

Matthew Wilcox (1):
      [IA64] Require SAL 3.2 in order to do extended config space ops

Randy Dunlap (1):
      [IA64] fix percpu warnings

Roel Kluin (1):
      [IA64] unsigned cannot be less than 0 in sn_hwperf_ioctl()

Takao Indoh (1):
      [IA64] Restore registers in the stack on INIT

Tony Luck (4):
      [IA64] Squeeze ticket locks back into 4 bytes.
      [IA64] Re-implement spinaphores using ticket lock concepts
      [IA64] SMT friendly version of spin_unlock_wait()
      Revert "[IA64] fix percpu warnings"

