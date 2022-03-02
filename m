From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Date: Wed, 02 Mar 2022 13:15:03 +0000
Subject: Re: [PATCH 11/12] swiotlb: merge swiotlb-xen initialization into swiotlb
Message-Id: <ca748512-12bb-7d75-13f1-8d5ec9703e26@oracle.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220301105311.885699-1-hch@lst.de>
 <20220301105311.885699-12-hch@lst.de>
 <alpine.DEB.2.22.394.2203011720150.3261@ubuntu-linux-20-04-desktop>
In-Reply-To: <alpine.DEB.2.22.394.2203011720150.3261@ubuntu-linux-20-04-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Stefano Stabellini <sstabellini@kernel.org>, Christoph Hellwig <hch@lst.de>
Cc: iommu@lists.linux-foundation.org, x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org



On 3/1/22 9:55 PM, Stefano Stabellini wrote:
> On Tue, 1 Mar 2022, Christoph Hellwig wrote:
>> Allow to pass a remap argument to the swiotlb initialization functions
>> to handle the Xen/x86 remap case.  ARM/ARM64 never did any remapping
>> from xen_swiotlb_fixup, so we don't even need that quirk.
>>

> Aside from that the rest looks OK. Also, you can add my:
> 
> Tested-by: Stefano Stabellini <sstabellini@kernel.org>


Not for me, I fail to boot with

[   52.202000] bnxt_en 0000:31:00.0: swiotlb buffer is full (sz: 256 bytes), total 0 (slots), used 0 (slots)

(this is iscsi root so I need the NIC).


I bisected it to "x86: remove the IOMMU table infrastructure" but haven't actually looked at the code yet.


-boris
