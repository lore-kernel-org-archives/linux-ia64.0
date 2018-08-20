From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 20 Aug 2018 22:13:57 +0000
Subject: [GIT PULL] convert ia64 to use NO_BOOTMEM
Message-Id: <20180820221357.GA18540@agluck-desk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following changes since commit d72e90f33aa4709ebecc5005562f52335e106a60:

  Linux 4.18-rc6 (2018-07-22 14:12:20 -0700)

are available in the Git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux.git tags/please-pull-noboot

for you to fetch changes up to f62800992e5917f2bed143dbcdce2501bc6933a9:

  ia64: switch to NO_BOOTMEM (2018-07-23 11:32:36 -0700)

----------------------------------------------------------------
Mike Rapoport kindly fixed up ia64 to work with NO_BOOTMEM

----------------------------------------------------------------
Mike Rapoport (4):
      ia64: contig/paging_init: reduce code duplication
      ia64: remove unused num_dma_physpages member from 'struct early_node_data'
      ia64: use mem_data to detect nodes' minimal and maximal PFNs
      ia64: switch to NO_BOOTMEM

 arch/ia64/Kconfig        |   1 +
 arch/ia64/kernel/setup.c |  11 +++-
 arch/ia64/mm/contig.c    |  75 +++-----------------------
 arch/ia64/mm/discontig.c | 134 ++++++-----------------------------------------
 4 files changed, 33 insertions(+), 188 deletions(-)
