From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 01 Jul 2013 16:47:14 +0000
Subject: [GIT PULL] Miscellaneous ia64 changes for 3.11 merge window
Message-Id: <51d1b292169713ed3@agluck-desk.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit d683b96b072dc4680fc74964eca77e6a23d1fa6e:

  Linux 3.10-rc4 (2013-06-02 17:11:17 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-misc-3.11

for you to fetch changes up to ccce9bb83ed20bca52f82ff9d7cf889d23a2ec01:

  [IA64] Delete __cpuinit usage from all ia64 users (2013-06-24 15:44:27 -0700)

----------------------------------------------------------------
Miscellaneous ia64 changes for 3.11 merge window

----------------------------------------------------------------
Andy Shevchenko (1):
      [IA64] perfmon: Use %*phD specifier to dump small buffers

Bjorn Helgaas (1):
      [IA64] pci: Remove unused fallback_dev

Chen Gang (2):
      [IA64] Fix trap #45 handling
      [IA64] hpsim: Fix check for overlong simscsi prefix.

Paul Gortmaker (1):
      [IA64] Delete __cpuinit usage from all ia64 users

 arch/ia64/hp/sim/simscsi.c    |  4 ++--
 arch/ia64/kernel/acpi.c       |  4 ++--
 arch/ia64/kernel/err_inject.c |  8 ++++----
 arch/ia64/kernel/mca.c        | 12 ++++++------
 arch/ia64/kernel/numa.c       |  4 ++--
 arch/ia64/kernel/palinfo.c    |  4 ++--
 arch/ia64/kernel/pci-dma.c    |  9 ---------
 arch/ia64/kernel/perfmon.c    | 20 ++------------------
 arch/ia64/kernel/salinfo.c    |  4 ++--
 arch/ia64/kernel/setup.c      | 10 +++++-----
 arch/ia64/kernel/smpboot.c    |  8 ++++----
 arch/ia64/kernel/topology.c   | 18 +++++++++---------
 arch/ia64/kernel/traps.c      |  2 +-
 arch/ia64/mm/contig.c         |  3 +--
 arch/ia64/mm/discontig.c      |  2 +-
 arch/ia64/mm/numa.c           |  2 +-
 arch/ia64/sn/kernel/setup.c   |  8 ++++----
 arch/ia64/xen/hypervisor.c    |  2 +-
 18 files changed, 49 insertions(+), 75 deletions(-)
