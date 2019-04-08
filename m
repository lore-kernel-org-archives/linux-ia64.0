From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Date: Mon, 08 Apr 2019 03:16:19 +0000
Subject: Re: [PATCH v4 0/6] normalize IOMMU dma mode boot options
Message-Id: <5CAABD03.9000301@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190407124147.13576-1-thunder.leizhen@huawei.com>
 <b20fd8a6-88ce-7d26-8eb0-ed9f095988a6@huawei.com>
In-Reply-To: <b20fd8a6-88ce-7d26-8eb0-ed9f095988a6@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hanjun Guo <guohanjun@huawei.com>, Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>



On 2019/4/8 9:14, Hanjun Guo wrote:
> Hi Zhen,
> 
> On 2019/4/7 20:41, Zhen Lei wrote:
>> As Robin Murphy's suggestion:
>> "It's also not necessarily obvious to the user how this interacts with
>> IOMMU_DEFAULT_PASSTHROUGH, so if we really do go down this route, maybe it
>> would be better to refactor the whole lot into a single selection of something
>> like IOMMU_DEFAULT_MODE anyway."
>>
>> In this version, I tried to normalize the IOMMU dma mode boot options for all
>> ARCHs. When IOMMU is enabled, there are 3 dma modes: paasthrough(bypass),
>> lazy(mapping but defer the IOTLB invalidation), strict. But currently each
>> ARCHs defined their private boot options, different with each other. For
>> example, to enable/disable "passthrough", ARM64 use iommu.passthrough=1/0,
>> X86 use iommu=pt/nopt, PPC/POWERNV use iommu=nobypass.
>>
>>
>> Zhen Lei (6):
>>   iommu: use iommu.dma_mode to replace iommu.passthrough and
>>     iommu.strict
>>   iommu: keep dma mode build options consistent with cmdline options
>>   iommu: add iommu_default_dma_mode_get() helper
>>   s390/pci: use common boot option iommu.dma_mode
>>   powernv/iommu: use common boot option iommu.dma_mode
>>   x86/iommu: use common boot option iommu.dma_mode
> 
> This will break systems using boot options as now, and I think
> this is unacceptable. If you want to do so, just introduce iommu.dma_mode
> on top of those iommu boot options with dma mode boot options unchanged,
> and iommu.dma_mode is for all archs but compatible with them.

I just changed the boot options name, but keep the function no change. I added
all related maintainers/supporters in the "to=" list, maybe we can disuss this.
Should I add some "obsoleted" warnings for old options and keep them for a while?
But I think this kind of thing is best done in one go.

> 
> Thanks
> Hanjun
> 
> 
> .
> 

-- 
Thanks!
BestRegards
