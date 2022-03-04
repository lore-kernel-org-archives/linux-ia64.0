From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Fri, 04 Mar 2022 20:18:23 +0000
Subject: Re: [PATCH 11/12] swiotlb: merge swiotlb-xen initialization into swiotlb
Message-Id: <75cb15b5-d861-1b88-5413-df326c3f1144@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
 <20220301105311.885699-12-hch@lst.de>
 <alpine.DEB.2.22.394.2203011720150.3261@ubuntu-linux-20-04-desktop>
 <ca748512-12bb-7d75-13f1-8d5ec9703e26@oracle.com>
 <20220304172859.GA12860@lst.de>
 <fc3992a8-896b-f0fc-e500-9010ec085c57@oracle.com>
 <20220304174308.GA13515@lst.de>
In-Reply-To: <20220304174308.GA13515@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org


On 3/4/22 12:43 PM, Christoph Hellwig wrote:
> On Fri, Mar 04, 2022 at 12:36:17PM -0500, Boris Ostrovsky wrote:
>>>> I bisected it to "x86: remove the IOMMU table infrastructure" but haven't actually looked at the code yet.
>>> That looks like the swiotlb buffer did not get initialized at all, but I
>>> can't really explain why.
>>>
>>> Can you stick in a printk and see if xen_swiotlb_init_early gets called
>>> at all?
>>
>>
>> Actually, that's the only thing I did do so far and yes, it does get called.
> So, specifically for "x86: remove the IOMMU table infrastructure" I
> think we need the one-liner below so that swiotlb_exit doesn't get called
> for the Xen case.  But that should have been fixed up by the next
> patch already.


This indeed allows dom0 to boot. Not sure I see where in the next patch this would have been fixed?


(BTW, just noticed in iommu_setup() you set this variable to 1. Should be 'true')


-boris
