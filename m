From: Peng Liu <liupeng256@huawei.com>
Date: Fri, 06 May 2022 01:57:59 +0000
Subject: [PATCH 0/2] null_blk: fix wrong use of nr_online_nodes
Message-Id: <20220506015801.757918-1-liupeng256@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bhelgaas@google.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, x86@kernel.org, hpa@zytor.com, lorenzo.pieralisi@arm.com, guohanjun@huawei.com, sudeep.holla@arm.com, rafael@kernel.org, lenb@kernel.org, akpm@linux-foundation.org, logang@deltatee.com, martin.oliveira@eideticom.com, thunder.leizhen@huawei.com, axboe@kernel.dk, kch@nvidia.com, ming.lei@redhat.com, shinichiro.kawasaki@wdc.com, mcgrof@kernel.org, jiangguoqing@kylinos.cn, jpittman@redhat.com, dave@stgolabs.net, liupeng256@huawei.com, wangkefeng.wang@huawei.com, linux-block@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Helper node_available is introduced to judge whether a node can be
used, and it is used to fix the wrong use of nr_online_nodes when
numa node is sparse.

Peng Liu (2):
  include/linux/nodemask.h: create node_available() helper
  null_blk: fix wrong use of nr_online_nodes

 arch/ia64/hp/common/sba_iommu.c |  2 +-
 arch/x86/pci/acpi.c             |  2 +-
 drivers/acpi/arm64/iort.c       |  2 +-
 drivers/block/null_blk/main.c   | 45 ++++++++++++++++++++-------------
 drivers/pci/pci-sysfs.c         |  2 +-
 include/linux/nodemask.h        |  3 +++
 mm/mempolicy.c                  |  2 +-
 7 files changed, 36 insertions(+), 22 deletions(-)

-- 
2.25.1
