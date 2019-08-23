From: Joerg Roedel <joro@8bytes.org>
Date: Fri, 23 Aug 2019 08:12:37 +0000
Subject: Re: [PATCH 00/11 v3] Cleanup IOMMU passthrough setting (and disable IOMMU Passthrough when SME is ac
Message-Id: <20190823081236.GE30332@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190819132256.14436-1-joro@8bytes.org>
In-Reply-To: <20190819132256.14436-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

On Mon, Aug 19, 2019 at 03:22:45PM +0200, Joerg Roedel wrote:
> Joerg Roedel (11):
>   iommu: Remember when default domain type was set on kernel command line
>   iommu: Add helpers to set/get default domain type
>   iommu: Use Functions to set default domain type in iommu_set_def_domain_type()
>   iommu/amd: Request passthrough mode from IOMMU core
>   iommu/vt-d: Request passthrough mode from IOMMU core
>   x86/dma: Get rid of iommu_pass_through
>   ia64: Get rid of iommu_pass_through
>   iommu: Print default domain type on boot
>   iommu: Set default domain type at runtime
>   iommu: Disable passthrough mode when SME is active
>   Documentation: Update Documentation for iommu.passthrough
> 
>  Documentation/admin-guide/kernel-parameters.txt |  2 +-
>  arch/ia64/include/asm/iommu.h                   |  2 -
>  arch/ia64/kernel/pci-dma.c                      |  2 -
>  arch/x86/include/asm/iommu.h                    |  1 -
>  arch/x86/kernel/pci-dma.c                       | 20 +-----
>  drivers/iommu/amd_iommu.c                       |  6 +-
>  drivers/iommu/intel-iommu.c                     |  2 +-
>  drivers/iommu/iommu.c                           | 93 +++++++++++++++++++++++--
>  include/linux/iommu.h                           | 16 +++++
>  9 files changed, 110 insertions(+), 34 deletions(-)

Applied.
