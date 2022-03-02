From: Anatoly Pugachev <matorola@gmail.com>
Date: Wed, 02 Mar 2022 09:18:26 +0000
Subject: Re: [PATCH 07/11] x86: remove the IOMMU table infrastructure
Message-Id: <CADxRZqxrjp4erFNorH+XqubZWLRNjw2E14z7vOW537no1eKnhw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220227143055.335596-1-hch@lst.de> <20220227143055.335596-8-hch@lst.de>
In-Reply-To: <20220227143055.335596-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390 <linux-s390@vger.kernel.org>, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

On Sun, Feb 27, 2022 at 7:31 PM Christoph Hellwig <hch@lst.de> wrote:
>
> The IOMMU table tries to separate the different IOMMUs into different
> backends, but actually requires various cross calls.
>
> Rewrite the code to do the generic swiotlb/swiotlb-xen setup directly
> in pci-dma.c and then just call into the IOMMU drivers.
...
> --- a/arch/x86/include/asm/iommu_table.h
> +++ /dev/null
> @@ -1,102 +0,0 @@
> -/* SPDX-License-Identifier: GPL-2.0 */
> -#ifndef _ASM_X86_IOMMU_TABLE_H
> -#define _ASM_X86_IOMMU_TABLE_H
> -
> -#include <asm/swiotlb.h>
> -
> -/*
> - * History lesson:
> - * The execution chain of IOMMUs in 2.6.36 looks as so:
> - *
> - *            [xen-swiotlb]
> - *                 |
> - *         +----[swiotlb *]--+
> - *        /         |         \
> - *       /          |          \
> - *    [GART]     [Calgary]  [Intel VT-d]
> - *     /
> - *    /
> - * [AMD-Vi]
> - *
> - * *: if SWIOTLB detected 'iommu=soft'/'swiotlb=force' it would skip
> - * over the rest of IOMMUs and unconditionally initialize the SWIOTLB.
> - * Also it would surreptitiously initialize set the swiotlb=1 if there were
> - * more than 4GB and if the user did not pass in 'iommu=off'. The swiotlb
> - * flag would be turned off by all IOMMUs except the Calgary one.
> - *
> - * The IOMMU_INIT* macros allow a similar tree (or more complex if desired)
> - * to be built by defining who we depend on.
> - *
> - * And all that needs to be done is to use one of the macros in the IOMMU
> - * and the pci-dma.c will take care of the rest.
> - */

Christoph,

Is it possible to keep documentation comments in source files? Or are
they completely irrelevant now?

Thanks.
