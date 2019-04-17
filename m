From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Date: Wed, 17 Apr 2019 02:36:58 +0000
Subject: Re: [PATCH v5 1/6] iommu: add generic boot option iommu.dma_mode
Message-Id: <5CB6914A.8050308@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190409125308.18304-1-thunder.leizhen@huawei.com>
 <20190409125308.18304-2-thunder.leizhen@huawei.com>
 <010d3cbd-ef74-ad21-c735-0af8b18955e6@huawei.com>
 <222946ee-adcc-1311-82a7-6afc9ffbc846@arm.com>
 <20190416152100.GB4187@fuggles.cambridge.arm.com>
In-Reply-To: <20190416152100.GB4187@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Will Deacon <will.deacon@arm.com>, Robin Murphy <robin.murphy@arm.com>
Cc: John Garry <john.garry@huawei.com>, Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>



On 2019/4/16 23:21, Will Deacon wrote:
> On Fri, Apr 12, 2019 at 02:11:31PM +0100, Robin Murphy wrote:
>> On 12/04/2019 11:26, John Garry wrote:
>>> On 09/04/2019 13:53, Zhen Lei wrote:
>>>> +static int __init iommu_dma_mode_setup(char *str)
>>>> +{
>>>> +    if (!str)
>>>> +        goto fail;
>>>> +
>>>> +    if (!strncmp(str, "passthrough", 11))
>>>> +        iommu_default_dma_mode = IOMMU_DMA_MODE_PASSTHROUGH;
>>>> +    else if (!strncmp(str, "lazy", 4))
>>>> +        iommu_default_dma_mode = IOMMU_DMA_MODE_LAZY;
>>>> +    else if (!strncmp(str, "strict", 6))
>>>> +        iommu_default_dma_mode = IOMMU_DMA_MODE_STRICT;
>>>> +    else
>>>> +        goto fail;
>>>> +
>>>> +    pr_info("Force dma mode to be %d\n", iommu_default_dma_mode);
>>>
>>> What happens if the cmdline option iommu.dma_mode is passed multiple
>>> times? We get mutliple - possibily conflicting - prints, right?
>>
>> Indeed; we ended up removing such prints for the existing options here,
>> specifically because multiple messages seemed more likely to be confusing
>> than useful.

I originally intended to be compatible with X86 printing.

 		} else if (!strncmp(str, "strict", 6)) {
 			pr_info("Disable batched IOTLB flush\n");
			intel_iommu_strict = 1;
 		}

>>
>>> And do we need to have backwards compatibility, such that the setting
>>> for iommu.strict or iommu.passthrough trumps iommu.dma_mode, regardless
>>> of order?
>>
>> As above I think it would be preferable to just keep using the existing
>> options anyway. The current behaviour works out as:
>>
>> iommu.passthrough |      Y	|	  N
>> iommu.strict	  |      x	|    Y         N
>> ------------------|-------------|---------|--------
>> MODE		  | PASSTHROUGH | STRICT  |  LAZY
>>
>> which seems intuitive enough that a specific dma_mode option doesn't add
>> much value, and would more likely just overcomplicate things for users as
>> well as our implementation.
> 
> Agreed. We can't remove the existing options, and they do the job perfectly
> well so I don't see the need to add more options on top.

OK, I will remove the iommu.dma_mode option in the next version. Thanks for you three.

I didn't want to add it at first, but later found that the boot options on
each ARCH are different, then want to normalize it.

In addition, do we need to compatible the build option name IOMMU_DEFAULT_PASSTHROUGH? or
change it to IOMMU_DEFAULT_DMA_MODE_PASSTHROUGH or IOMMU_DEFAULT_MODE_PASSTHROUGH?

> 
> Will
> 
> .
> 

-- 
Thanks!
BestRegards
