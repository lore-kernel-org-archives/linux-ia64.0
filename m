From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 29 Apr 2008 23:36:12 +0000
Subject: [git pull] ia64 changes
Message-Id: <1FE6DD409037234FAB833C420AA843EC0138211B@orsmsx424.amr.corp.intel.com>
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

asm-x86/topology.h got touched to add a null stub for the change by Alex
to get better "physical id" values in /proc/cpuinfo by asking ACPI.

Thanks!

-Tony

 arch/ia64/kernel/smpboot.c          |   12 +++++++++---
 arch/ia64/kernel/topology.c         |    9 +++++++++
 arch/ia64/kernel/uncached.c         |   23 +++++++++++++----------
 arch/ia64/mm/tlb.c                  |    5 ++++-
 drivers/acpi/processor_core.c       |    9 +++++++++
 drivers/char/mspec.c                |   12 ++++++------
 drivers/misc/sgi-xp/xpc_partition.c |    4 ++--
 include/asm-ia64/topology.h         |    2 ++
 include/asm-ia64/uncached.h         |    6 +++---
 include/asm-x86/topology.h          |    4 ++++
 10 files changed, 61 insertions(+), 25 deletions(-)

Alex Chiang (2):
      [IA64] Remove printk noise on unimplemented SAL_PHYSICAL_ID_INFO
      [IA64] Provide ACPI fixup for /proc/cpuinfo/physical_id

Dean Nelson (1):
      [IA64] allocate multiple contiguous pages via uncached allocator

Hidetoshi Seto (1):
      [IA64] bugfix: nptcg breaks cpu-hotadd



