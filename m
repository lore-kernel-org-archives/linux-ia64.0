From: "Yu, Fenghua" <fenghua.yu@intel.com>
Date: Thu, 02 Oct 2008 22:06:18 +0000
Subject: RE: [PATCH 1/2]Add Variable Page Size and IA64 Support in Intel
Message-Id: <A6AD88C3F2289247BE726C37303E1EB88408AE54@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <BAE9DCEF64577A439B3A37F36F9B691C0339372B@orsmsx418.amr.corp.intel.com>
 <617E1C2C70743745A92448908E030B2A02AD5AD7@scsmsx411.amr.corp.intel.com>
 <20081001165725.GA21559@linux-os.sc.intel.com>
 <20081002082942.GA26084@elte.hu>
In-Reply-To: <20081002082942.GA26084@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Jesse Barnes <jbarnes@virtuousgeek.org>, David Woodhouse <dwmw2@infradead.org>, Avi Kivity <avi@redhat.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>


>> --- a/drivers/pci/dmar.c
>> +++ b/drivers/pci/dmar.c
>> @@ -35,6 +35,10 @@
>>  #undef PREFIX
>>  #define PREFIX "DMAR:"
>>
>> +#ifdef CONFIG_IA64
>> +#define cpu_has_x2apic 0
>> +#endif
>
>hm, that's not too nice - why not add it to arch/ia64/include/?

OK. I'll move this to arch/ia64/include (along with other #ifdef CONFIG_IA64 places if needed).


>> diff --git a/include/linux/intel-iommu.h b/include/linux/intel-iommu.h
>> index e7b196b..d84612a 100644
>> --- a/include/linux/intel-iommu.h
>> +++ b/include/linux/intel-iommu.h
>> @@ -67,6 +67,13 @@
>>               hi = readl(dmar + reg + 4); \
>>               (((u64) hi) << 32) + lo; })
>>  */
>> +#ifdef CONFIG_IA64
>> +#define dmar_readq readq
>> +static inline void dmar_writeq(void __iomem *addr, u64 val)
>> +{
>> +     writeq(val, addr);
>> +}
>> +#else
>>  static inline u64 dmar_readq(void __iomem *addr)
>>  {
>>       u32 lo, hi;
>> @@ -80,6 +87,7 @@ static inline void dmar_writeq(void __iomem *addr, u64 val)
>>       writel((u32)val, addr);
>>       writel((u32)(val >> 32), addr + 4);
>>  }
>> +#endif
>
>What's this all about?  Why do we need #ifdef CONFIG_IA64 here?
>Doesn't x86 provide its own readq/writeq implementation?

This is a comment from Bjorn.

In my patch, one readq/one writeq are working faster than two readl/two writel on IA64. X86 uses two readl/two writel so that the code works on both x86 and x86-64 although Intel IOMMU only has x86-64 version currently. dmar_readq() and dmar_writeq() are in moderate performance critical path.

Do you think my current implementation is ok to have #ifdef CONFIG_IA64 here? Or I can change X86 to use readq/writeq as well or IA64 uses two readl/two writel for clean code?

Thanks.

-Fenghua


