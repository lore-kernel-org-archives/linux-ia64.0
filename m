From: Hanjun Guo <guohanjun@huawei.com>
Date: Fri, 08 Mar 2013 01:40:04 +0000
Subject: Re: [PATCH 2/2] ia64: iosapic: fix kexec oops when iosapic was removed
Message-Id: <51394174.9050300@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1362368824-29640-1-git-send-email-guohanjun@huawei.com> <1362591539.12845.124.camel@misato.fc.hp.com>
In-Reply-To: <1362591539.12845.124.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Toshi Kani <toshi.kani@hp.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <jiang.liu@huawei.com>, Jianguo Wu <wujianguo@huawei.com>

On 2013/3/7 1:38, Toshi Kani wrote:
> On Mon, 2013-03-04 at 11:47 +0800, Hanjun Guo wrote:
>> Ioapic hotplug was supported in IA64 code, but will lead to kexec oops
>> when iosapic was removed. here is the code logic:
>>
>> iosapic_remove
>>   iosapic_free
>>     memset(&iosapic_lists[index], 0, sizeof(iosapic_lists[0]))
>>       iosapic_lists[index].addr was set to 0;
>>
>> and then kexec a new kernel
>> kexec_disable_iosapic
>>   iosapic_write(rte->iosapic,..)
>>     __iosapic_write(iosapic->addr, reg, val);
>>       addr was set to 0 when iosapic_remove, and oops happened
>>
>  :
>>
>> With Tony and Toshi's advice, the patch removes the "rte" from rte_list
>> when the iosapic was removed.
>>
>> Signed-off-by: Hanjun Guo <guohanjun@huawei.com>
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> ---
>>  arch/ia64/kernel/iosapic.c |   32 +++++++++++++++++++++++++++++++-
>>  1 files changed, 31 insertions(+), 1 deletions(-)
>>
>> diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
>> index a6e2f75..bc4a0f8 100644
>> --- a/arch/ia64/kernel/iosapic.c
>> +++ b/arch/ia64/kernel/iosapic.c
>> @@ -1010,6 +1010,26 @@ iosapic_check_gsi_range (unsigned int gsi_base, unsigned int ver)
>>  	return 0;
>>  }
>>  
>> +static int
>> +delete_rte_from_list(unsigned int irq, unsigned int gsi)
> 
> I'd prefer to have "iosapic" prefix to the func name, something like
> iosapic_delete_rte(), but this is just my preference.  Other than that,

Good idea. I will send another version and add your Acked-by.

Thanks
Hanjun Guo

> the change looks good to me.
> 
> Acked-by: Toshi Kani <toshi.kani@hp.com>
> 
> Thanks,
> -Toshi
> 
> 
> 
> 
> .
> 


