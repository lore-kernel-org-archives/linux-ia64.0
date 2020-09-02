From: Niklas Schnelle <schnelle@linux.ibm.com>
Date: Wed, 02 Sep 2020 08:13:12 +0000
Subject: Re: [PATCH 0/2] dma-mapping: update default segment_boundary_mask
Message-Id: <2c8db0aa-e8b5-e577-b971-1de10ecc6747@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200901221646.26491-1-nicoleotsuka@gmail.com>
In-Reply-To: <20200901221646.26491-1-nicoleotsuka@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nicolin Chen <nicoleotsuka@gmail.com>, hch@lst.de
Cc: sfr@canb.auug.org.au, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux-alpha@vger.kernel.org, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, linux-s390@vger.kernel.org, davem@davemloft.net, sparclinux@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de, linux-parisc@vger.kernel.org



On 9/2/20 12:16 AM, Nicolin Chen wrote:
> These two patches are to update default segment_boundary_mask.
> 
> PATCH-1 fixes overflow issues in callers of dma_get_seg_boundary.
> Previous version was a series: https://lkml.org/lkml/2020/8/31/1026
> 
> Then PATCH-2 sets default segment_boundary_mask to ULONG_MAX.
> 
> Nicolin Chen (2):
>   dma-mapping: introduce dma_get_seg_boundary_nr_pages()
>   dma-mapping: set default segment_boundary_mask to ULONG_MAX

I gave both of your patches a quick test ride on a couple of dev mainframes,
both NVMe, ConnectX and virtio-pci devices all seems to work fine.
I already commented on Christoph's mail that I like the helper approach,
so as for s390 you can add my

Acked-by: Niklas Schnelle <schnelle@linux.ibm.com>

> 
>  arch/alpha/kernel/pci_iommu.c    |  7 +------
>  arch/ia64/hp/common/sba_iommu.c  |  3 +--
>  arch/powerpc/kernel/iommu.c      |  9 ++-------
>  arch/s390/pci/pci_dma.c          |  6 ++----
>  arch/sparc/kernel/iommu-common.c | 10 +++-------
>  arch/sparc/kernel/iommu.c        |  3 +--
>  arch/sparc/kernel/pci_sun4v.c    |  3 +--
>  arch/x86/kernel/amd_gart_64.c    |  3 +--
>  drivers/parisc/ccio-dma.c        |  3 +--
>  drivers/parisc/sba_iommu.c       |  3 +--
>  include/linux/dma-mapping.h      | 21 ++++++++++++++++++++-
>  11 files changed, 34 insertions(+), 37 deletions(-)
> 
