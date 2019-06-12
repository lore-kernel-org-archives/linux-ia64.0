From: "Leizhen (ThunderTown)" <thunder.leizhen@huawei.com>
Date: Wed, 12 Jun 2019 06:26:43 +0000
Subject: Re: [PATCH v8 2/7] x86/dma: use IS_ENABLED() to simplify the code
Message-Id: <bd743433-73e9-3cf1-c159-4371abebd989@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190530034831.4184-1-thunder.leizhen@huawei.com>
 <20190530034831.4184-3-thunder.leizhen@huawei.com>
 <20190612051624.GF32652@zn.tnic>
In-Reply-To: <20190612051624.GF32652@zn.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Borislav Petkov <bp@alien8.de>
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>



On 2019/6/12 13:16, Borislav Petkov wrote:
> On Thu, May 30, 2019 at 11:48:26AM +0800, Zhen Lei wrote:
>> This patch removes the ifdefs around CONFIG_IOMMU_DEFAULT_PASSTHROUGH to
>> improve readablity.
> 
> Avoid having "This patch" or "This commit" in the commit message. It is
> tautologically useless.

OK, thanks.

> 
> Also, do
> 
> $ git grep 'This patch' Documentation/process
> 
> for more details.
> 
>> Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
>> ---
>>  arch/x86/kernel/pci-dma.c | 7 ++-----
>>  1 file changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/arch/x86/kernel/pci-dma.c b/arch/x86/kernel/pci-dma.c
>> index dcd272dbd0a9330..9f2b19c35a060df 100644
>> --- a/arch/x86/kernel/pci-dma.c
>> +++ b/arch/x86/kernel/pci-dma.c
>> @@ -43,11 +43,8 @@
>>   * It is also possible to disable by default in kernel config, and enable with
>>   * iommu=nopt at boot time.
>>   */
>> -#ifdef CONFIG_IOMMU_DEFAULT_PASSTHROUGH
>> -int iommu_pass_through __read_mostly = 1;
>> -#else
>> -int iommu_pass_through __read_mostly;
>> -#endif
>> +int iommu_pass_through __read_mostly >> +			IS_ENABLED(CONFIG_IOMMU_DEFAULT_PASSTHROUGH);
> 
> Let that line stick out.

OK, I will merge them on the same line.

> 
> Thx.
> 
