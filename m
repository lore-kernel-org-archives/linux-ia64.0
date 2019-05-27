From: Joerg Roedel <joro@8bytes.org>
Date: Mon, 27 May 2019 14:21:40 +0000
Subject: Re: [PATCH v7 1/1] iommu: enhance IOMMU dma mode build options
Message-Id: <20190527142140.GH8420@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190520135947.14960-1-thunder.leizhen@huawei.com>
 <20190520135947.14960-2-thunder.leizhen@huawei.com>
In-Reply-To: <20190520135947.14960-2-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zhen Lei <thunder.leizhen@huawei.com>
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>

Hi Zhen Lei,

On Mon, May 20, 2019 at 09:59:47PM +0800, Zhen Lei wrote:
>  arch/ia64/kernel/pci-dma.c                |  2 +-
>  arch/powerpc/platforms/powernv/pci-ioda.c |  3 ++-
>  arch/s390/pci/pci_dma.c                   |  2 +-
>  arch/x86/kernel/pci-dma.c                 |  7 ++---
>  drivers/iommu/Kconfig                     | 44 ++++++++++++++++++++++++++-----
>  drivers/iommu/amd_iommu_init.c            |  3 ++-
>  drivers/iommu/intel-iommu.c               |  2 +-
>  drivers/iommu/iommu.c                     |  3 ++-
>  8 files changed, 48 insertions(+), 18 deletions(-)

This needs Acks from the arch maintainers of ia64, powerpc, s390 and
x86, at least.

It is easier for them if you split it up into the Kconfig change and
separete patches per arch and per iommu driver. Then collect the Acks on
the individual patches.

Thanks,

	Joerg
