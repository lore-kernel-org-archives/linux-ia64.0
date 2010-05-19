From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 19 May 2010 16:00:01 +0000
Subject: [git pull] ia64 changes (revised)
Message-Id: <4bf40b012850e4dde@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Linus,

New version without the change from Robin Holt.

please pull from:

	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release

This will update the files shown below.

Thanks!

-Tony

 arch/ia64/Kconfig                       |    3 ---
 arch/ia64/hp/common/sba_iommu.c         |    8 ++++----
 arch/ia64/include/asm/mmzone.h          |    4 ----
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c |   10 +++++-----
 arch/ia64/kernel/irq_ia64.c             |    9 +++------
 arch/ia64/kernel/salinfo.c              |    5 ++---
 arch/ia64/kernel/topology.c             |    4 ++--
 arch/ia64/kernel/unaligned.c            |   24 +++++-------------------
 arch/ia64/mm/fault.c                    |   13 +++----------
 arch/ia64/sn/kernel/sn2/sn_hwperf.c     |    4 ++--
 10 files changed, 26 insertions(+), 58 deletions(-)

Akinobu Mita (1):
      [IA64] use __ratelimit

Jiri Olsa (1):
      [IA64] removing redundant ifdef

Joe Perches (1):
      [IA64] arch/ia64/hp/common/sba_iommu.c: Rename dev_info to adi

Julia Lawall (2):
      [IA64] Use set_cpus_allowed_ptr
      [IA64] Use set_cpus_allowed_ptr

Tony Luck (1):
      [IA64] Drop duplicated "config IOMMU_HELPER"

npiggin@suse.de (1):
      [IA64] invoke oom-killer from page fault

