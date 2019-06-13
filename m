From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Date: Thu, 13 Jun 2019 08:30:08 +0000
Subject: Re: [PATCH v8 1/7] iommu: enhance IOMMU default DMA mode build options
Message-Id: <7d3727e3-a455-3a26-1104-5b85c196bbdf@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190530034831.4184-1-thunder.leizhen@huawei.com>
 <20190530034831.4184-2-thunder.leizhen@huawei.com>
 <645bd526-4eb0-4a36-2dda-023f009247ab@huawei.com>
 <030bafab-58f5-8bb1-0533-2977d6e138b2@huawei.com>
 <55d0e30c-5bca-41fc-5bf0-4366dc387afd@huawei.com>
In-Reply-To: <55d0e30c-5bca-41fc-5bf0-4366dc387afd@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: John Garry <john.garry@huawei.com>, Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Hanjun Guo <guohanjun@huawei.com>, Linuxarm <linuxarm@huawei.com>



On 2019/5/31 18:42, John Garry wrote:
> 
>>>> -config IOMMU_DEFAULT_PASSTHROUGH
>>>> -    bool "IOMMU passthrough by default"
>>>> +choice
>>>> +    prompt "IOMMU default DMA mode"
>>>>      depends on IOMMU_API
>>>> -        help
>>>> -      Enable passthrough by default, removing the need to pass in
>>>> -      iommu.passthrough=on or iommu=pt through command line. If this
>>>> -      is enabled, you can still disable with iommu.passthrough=off
>>>> -      or iommu=nopt depending on the architecture.
>>>> +    default IOMMU_DEFAULT_STRICT
>>>> +    help
>>>> +      This option allows IOMMU DMA mode to be chose at build time, to
>>>
>>> As before:
>>> /s/chose/chosen/, /s/allows IOMMU/allows an IOMMU/
>> I'm sorry that the previous version was not modified.
>>
>>>
>>>> +      override the default DMA mode of each ARCHs, removing the need to
>>>
>>> Again, as before:
>>> ARCHs should be singular
>> OK
>>
>>>
>>>> +      pass in kernel parameters through command line. You can still use
>>>> +      ARCHs specific boot options to override this option again.
> 
> *
> 
>>>> +
>>>> +config IOMMU_DEFAULT_PASSTHROUGH
>>>> +    bool "passthrough"
>>>> +    help
>>>> +      In this mode, the DMA access through IOMMU without any addresses
>>>> +      translation. That means, the wrong or illegal DMA access can not
>>>> +      be caught, no error information will be reported.
>>>>
>>>>        If unsure, say N here.
>>>>
>>>> +config IOMMU_DEFAULT_LAZY
>>>> +    bool "lazy"
>>>> +    help
>>>> +      Support lazy mode, where for every IOMMU DMA unmap operation, the
>>>> +      flush operation of IOTLB and the free operation of IOVA are deferred.
>>>> +      They are only guaranteed to be done before the related IOVA will be
>>>> +      reused.
>>>
>>> why no advisory on how to set if unsure?
>> Because the LAZY and STRICT have their own advantages and disadvantages.
>>
>> Should I say: If unsure, keep the default。
> 
> Maybe. So you could put this in the help for the choice, * above, and remove the advisory on IOMMU_DEFAULT_PASSTHROUGH.

OK, I'll revise it according to this idea in v9.

> 
> However the maintainer may have a different view.
> 
> Thanks,
> John
> 
>>
>>>
>>>> +
>>>> +config IOMMU_DEFAULT_STRICT
>>>> +    bool "strict"
>>>> +    help
>>>> +      For every IOMMU DMA unmap operation, the flush operation of IOTLB and
>>>> +      the free operation of IOVA are guaranteed to be done in the unmap
>>>> +      function.
>>>> +
>>>> +      This mode is safer than the two above, but it maybe slower in some
>>>> +      high performace scenarios.
>>>
>>> and here?
> 
> 
> .
> 
