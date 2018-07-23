From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Date: Mon, 23 Jul 2018 05:56:54 +0000
Subject: [PATCH 0/4] ia64: switch to NO_BOOTMEM
Message-Id: <1532325418-22617-1-git-send-email-rppt@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches convert ia64 to use NO_BOOTMEM.

The first two patches are cleanups, the third patches reduces usage of
'struct bootmem_data' for easier transition and the forth patch actually
replaces bootmem with memblock + nobootmem.

I've tested the sim_defconfig with the ski simulator and build tested other
defconfigs.

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

-- 
2.7.4

