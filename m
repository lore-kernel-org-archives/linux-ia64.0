From: Lorenzo Stoakes <lstoakes@gmail.com>
Date: Mon, 31 Oct 2016 10:02:26 +0000
Subject: [PATCH 0/2] mm: remove get_user_pages_locked()
Message-Id: <20161031100228.17917-1-lstoakes@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: devel@driverdev.osuosl.org, linux-ia64@vger.kernel.org, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-cris-kernel@axis.com, linux-rdma@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Michal Hocko <mhocko@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-media@vger.kernel.org

by adding an int *locked parameter to get_user_pages() callers to this function
can now utilise VM_FAULT_RETRY functionality.

Taken in conjunction with the patch series adding the same parameter to
get_user_pages_remote() this means all slow-path get_user_pages*() functions
will now have the ability to utilise VM_FAULT_RETRY.

Additionally get_user_pages() and get_user_pages_remote() previously mirrored
one another in functionality differing only in the ability to specify task/mm,
this patch series reinstates this relationship.

This patch series should not introduce any functional changes.

Lorenzo Stoakes (2):
  mm: add locked parameter to get_user_pages()
  mm: remove get_user_pages_locked()

 arch/cris/arch-v32/drivers/cryptocop.c             |  2 +
 arch/ia64/kernel/err_inject.c                      |  2 +-
 arch/x86/mm/mpx.c                                  |  2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                |  2 +-
 drivers/gpu/drm/via/via_dmablit.c                  |  2 +-
 drivers/infiniband/core/umem.c                     |  2 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c        |  3 +-
 drivers/infiniband/hw/qib/qib_user_pages.c         |  2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c           |  2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |  2 +-
 drivers/misc/mic/scif/scif_rma.c                   |  1 +
 drivers/misc/sgi-gru/grufault.c                    |  3 +-
 drivers/platform/goldfish/goldfish_pipe.c          |  2 +-
 drivers/rapidio/devices/rio_mport_cdev.c           |  2 +-
 .../interface/vchiq_arm/vchiq_2835_arm.c           |  3 +-
 .../vc04_services/interface/vchiq_arm/vchiq_arm.c  |  3 +-
 drivers/virt/fsl_hypervisor.c                      |  2 +-
 include/linux/mm.h                                 |  4 +-
 mm/frame_vector.c                                  |  4 +-
 mm/gup.c                                           | 62 ++++++++--------------
 mm/ksm.c                                           |  3 +-
 mm/mempolicy.c                                     |  2 +-
 mm/nommu.c                                         | 10 +---
 virt/kvm/kvm_main.c                                |  4 +-
 25 files changed, 55 insertions(+), 73 deletions(-)
