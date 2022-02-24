From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Thu, 24 Feb 2022 17:07:26 +0000
Subject: Re: cleanup swiotlb initialization
Message-Id: <8ffd8587-7eb3-d5b6-eab0-b86df5c0ebbd@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220222153514.593231-1-hch@lst.de>
 <09cb4ad3-88e7-3744-b4b8-a6d745ecea9e@oracle.com>
 <20220224155854.GA30938@lst.de>
 <206ba6a3-770a-70ad-96bc-76c6380da988@oracle.com>
 <20220224163943.GA32088@lst.de>
In-Reply-To: <20220224163943.GA32088@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, Stefano Stabellini <sstabellini@kernel.org>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org


On 2/24/22 11:39 AM, Christoph Hellwig wrote:
> On Thu, Feb 24, 2022 at 11:18:33AM -0500, Boris Ostrovsky wrote:
>> On 2/24/22 10:58 AM, Christoph Hellwig wrote:
>>> Thanks.
>>>
>>> This looks really strange as early_amd_iommu_init should not interact much
>>> with the changes.  I'll see if I can find a AMD system to test on.
>>
>> Just to be clear: this crashes only as dom0. Boots fine as baremetal.
> Ah.  I can gues what this might be.  On Xen the hypervisor controls the
> IOMMU and we should never end up initializing it in Linux, right?


Right, we shouldn't be in that code path.


-boris
