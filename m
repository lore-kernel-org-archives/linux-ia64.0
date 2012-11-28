From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Wed, 28 Nov 2012 00:43:20 +0000
Subject: Re: [Patch v4 00/12] memory-hotplug: hot-remove physical memory
Message-Id: <50B55E28.1030608@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1354010422-19648-1-git-send-email-wency@cn.fujitsu.com> <20121127112741.b616c2f6.akpm@linux-foundation.org>
In-Reply-To: <20121127112741.b616c2f6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, benh@kernel.crashing.org, paulus@samba.org, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jianguo Wu <wujianguo@huawei.com>

Hi Andrew,

2012/11/28 4:27, Andrew Morton wrote:
> On Tue, 27 Nov 2012 18:00:10 +0800
> Wen Congyang <wency@cn.fujitsu.com> wrote:
>
>> The patch-set was divided from following thread's patch-set.
>>      https://lkml.org/lkml/2012/9/5/201
>>
>> The last version of this patchset:
>>      https://lkml.org/lkml/2012/11/1/93
>
> As we're now at -rc7 I'd prefer to take a look at all of this after the
> 3.7 release - please resend everything shortly after 3.8-rc1.

Almost patches about memory hotplug has been merged into your and Rafael's
tree. And these patches are waiting to open the v3.8 merge window.
Remaining patches are only this patch-set. So we hope that this patch-set
is merged into v3.8.

In merging this patch-set into v3.8, Linux on x86_64 makes a memory hot plug
possible.

Thanks,
Yasuaki Ishimatsu

>
>> If you want to know the reason, please read following thread.
>>
>> https://lkml.org/lkml/2012/10/2/83
>
> Please include the rationale within each version of the patchset rather
> than by linking to an old email.  Because
>
> a) this way, more people are likely to read it
>
> b) it permits the text to be maimtained as the code evolves
>
> c) it permits the text to be included in the mainlnie commit, where
>     people can find it.
>
>> The patch-set has only the function of kernel core side for physical
>> memory hot remove. So if you use the patch, please apply following
>> patches.
>>
>> - bug fix for memory hot remove
>>    https://lkml.org/lkml/2012/10/31/269
>>
>> - acpi framework
>>    https://lkml.org/lkml/2012/10/26/175
>
> What's happening with the acpi framework?  has it received any feedback
> from the ACPI developers?
>


