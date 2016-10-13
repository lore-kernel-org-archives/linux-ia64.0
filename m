From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Date: Thu, 13 Oct 2016 07:32:51 +0000
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly pass FOLL_* flags
Message-Id: <914b917f-6871-2ba3-95ba-981dd2855743@amd.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20161013002020.3062-1-lstoakes@gmail.com>
In-Reply-To: <20161013002020.3062-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org
Cc: linux-mips@linux-mips.org, linux-fbdev@vger.kernel.org, Jan Kara <jack@suse.cz>, kvm@vger.kernel.org, linux-sh@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, dri-devel@lists.freedesktop.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org, x86@kernel.org, Hugh Dickins <hughd@google.com>, linux-media@vger.kernel.org, Rik van Riel <riel@redhat.com>, intel-gfx@lists.freedesktop.org, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Mel Gorman <mgorman@techsingularity.net>, linux-cris-kernel@axis.com, netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, linux-alpha@vger.kernel.org, linux-fsdevel@vger.kernel.org

Am 13.10.2016 um 02:20 schrieb Lorenzo Stoakes:
> This patch series adjusts functions in the get_user_pages* family such th=
at
> desired FOLL_* flags are passed as an argument rather than implied by fla=
gs.
>
> The purpose of this change is to make the use of FOLL_FORCE explicit so i=
t is
> easier to grep for and clearer to callers that this flag is being used. T=
he use
> of FOLL_FORCE is an issue as it overrides missing VM_READ/VM_WRITE flags =
for the
> VMA whose pages we are reading from/writing to, which can result in surpr=
ising
> behaviour.
>
> The patch series came out of the discussion around commit 38e0885, which
> addressed a BUG_ON() being triggered when a page was faulted in with PROT=
_NONE
> set but having been overridden by FOLL_FORCE. do_numa_page() was run on t=
he
> assumption the page _must_ be one marked for NUMA node migration as an ac=
tual
> PROT_NONE page would have been dealt with prior to this code path, however
> FOLL_FORCE introduced a situation where this assumption did not hold.
>
> See https://marc.info/?l=3Dlinux-mm&m=147585445805166 for the patch propo=
sal.
>
> Lorenzo Stoakes (10):
>    mm: remove write/force parameters from __get_user_pages_locked()
>    mm: remove write/force parameters from __get_user_pages_unlocked()
>    mm: replace get_user_pages_unlocked() write/force parameters with gup_=
flags
>    mm: replace get_user_pages_locked() write/force parameters with gup_fl=
ags
>    mm: replace get_vaddr_frames() write/force parameters with gup_flags
>    mm: replace get_user_pages() write/force parameters with gup_flags
>    mm: replace get_user_pages_remote() write/force parameters with gup_fl=
ags
>    mm: replace __access_remote_vm() write parameter with gup_flags
>    mm: replace access_remote_vm() write parameter with gup_flags
>    mm: replace access_process_vm() write parameter with gup_flags

Patch number 6 in this series (which touches drivers I co-maintain) is=20
Acked-by: Christian K=C3=B6nig <christian.koenig@amd.com>.

In general looks like a very nice cleanup to me, but I'm not enlightened=20
enough to full judge.

Regards,
Christian.

>
>   arch/alpha/kernel/ptrace.c                         |  9 ++--
>   arch/blackfin/kernel/ptrace.c                      |  5 ++-
>   arch/cris/arch-v32/drivers/cryptocop.c             |  4 +-
>   arch/cris/arch-v32/kernel/ptrace.c                 |  4 +-
>   arch/ia64/kernel/err_inject.c                      |  2 +-
>   arch/ia64/kernel/ptrace.c                          | 14 +++---
>   arch/m32r/kernel/ptrace.c                          | 15 ++++---
>   arch/mips/kernel/ptrace32.c                        |  5 ++-
>   arch/mips/mm/gup.c                                 |  2 +-
>   arch/powerpc/kernel/ptrace32.c                     |  5 ++-
>   arch/s390/mm/gup.c                                 |  3 +-
>   arch/score/kernel/ptrace.c                         | 10 +++--
>   arch/sh/mm/gup.c                                   |  3 +-
>   arch/sparc/kernel/ptrace_64.c                      | 24 +++++++----
>   arch/sparc/mm/gup.c                                |  3 +-
>   arch/x86/kernel/step.c                             |  3 +-
>   arch/x86/mm/gup.c                                  |  2 +-
>   arch/x86/mm/mpx.c                                  |  5 +--
>   arch/x86/um/ptrace_32.c                            |  3 +-
>   arch/x86/um/ptrace_64.c                            |  3 +-
>   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c            |  7 ++-
>   drivers/gpu/drm/etnaviv/etnaviv_gem.c              |  7 ++-
>   drivers/gpu/drm/exynos/exynos_drm_g2d.c            |  3 +-
>   drivers/gpu/drm/i915/i915_gem_userptr.c            |  6 ++-
>   drivers/gpu/drm/radeon/radeon_ttm.c                |  3 +-
>   drivers/gpu/drm/via/via_dmablit.c                  |  4 +-
>   drivers/infiniband/core/umem.c                     |  6 ++-
>   drivers/infiniband/core/umem_odp.c                 |  7 ++-
>   drivers/infiniband/hw/mthca/mthca_memfree.c        |  2 +-
>   drivers/infiniband/hw/qib/qib_user_pages.c         |  3 +-
>   drivers/infiniband/hw/usnic/usnic_uiom.c           |  5 ++-
>   drivers/media/pci/ivtv/ivtv-udma.c                 |  4 +-
>   drivers/media/pci/ivtv/ivtv-yuv.c                  |  5 ++-
>   drivers/media/platform/omap/omap_vout.c            |  2 +-
>   drivers/media/v4l2-core/videobuf-dma-sg.c          |  7 ++-
>   drivers/media/v4l2-core/videobuf2-memops.c         |  6 ++-
>   drivers/misc/mic/scif/scif_rma.c                   |  3 +-
>   drivers/misc/sgi-gru/grufault.c                    |  2 +-
>   drivers/platform/goldfish/goldfish_pipe.c          |  3 +-
>   drivers/rapidio/devices/rio_mport_cdev.c           |  3 +-
>   drivers/scsi/st.c                                  |  5 +--
>   .../interface/vchiq_arm/vchiq_2835_arm.c           |  3 +-
>   .../vc04_services/interface/vchiq_arm/vchiq_arm.c  |  3 +-
>   drivers/video/fbdev/pvr2fb.c                       |  4 +-
>   drivers/virt/fsl_hypervisor.c                      |  4 +-
>   fs/exec.c                                          |  9 +++-
>   fs/proc/base.c                                     | 19 +++++---
>   include/linux/mm.h                                 | 18 ++++----
>   kernel/events/uprobes.c                            |  6 ++-
>   kernel/ptrace.c                                    | 16 ++++---
>   mm/frame_vector.c                                  |  9 ++--
>   mm/gup.c                                           | 50 ++++++++++-----=
-------
>   mm/memory.c                                        | 16 ++++---
>   mm/mempolicy.c                                     |  2 +-
>   mm/nommu.c                                         | 38 +++++++---------
>   mm/process_vm_access.c                             |  7 ++-
>   mm/util.c                                          |  8 ++--
>   net/ceph/pagevec.c                                 |  2 +-
>   security/tomoyo/domain.c                           |  2 +-
>   virt/kvm/async_pf.c                                |  3 +-
>   virt/kvm/kvm_main.c                                | 11 +++--
>   61 files changed, 260 insertions(+), 187 deletions(-)
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel


