From: Jay Lan <jlan@sgi.com>
Date: Thu, 10 Aug 2006 20:11:52 +0000
Subject: Re: [Fastboot] Ia64 kdump patch
Message-Id: <44DB9308.9070804@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060608083516.GH28607@verge.net.au>
In-Reply-To: <20060608083516.GH28607@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jay Lan wrote:
> Jay Lan wrote:
> 
>> Hi Nanhai and horms,
>>
> 
> [snip]
> 
>> However, the second kernel was not booted and system remained
>> alive.
>>
>> The /proc/{sysrq-trigger,iomem} after the trigger were as below:
>> (holism,9) ls -l /proc/{sysrq-trigger,iomem}
>> -r--r--r-- 1 root root 0 Aug  9 08:10 /proc/iomem
>> --w------- 1 root root 0 Aug  9 08:10 /proc/sysrq-trigger
>> (holism,10)
>>
>> I built the kernel based on 2.6.18-rc2 with Nanhai's
>> kexec-kdump-ia64-2.6.16.patch and my fixes to
>>   - replace  irq_descp(dev->irq) with irq_desc + dev->irq
>>   - replace  desc->handle with desc-chip
>> for compilation.
>>
>> As to kexec-tools, i use kdump9 with Nanhai's
>> kexec-tools-kdump9-ia64-zou.patch.
> 
> 
> Hi,
> 
> I forgot to mention that i ran kexec with these parameters:
> [root@holism redhat]# kexec -p <dump-capture-kernel> \
>  --initrd=,initrd-for-dump-capture-kernel> \
>  --append="root=LABEL=/ init 1 irqpoll console=ttyS0,38400n8 maxcpus=1"
> [root@holism redhat]#
> 
> The command was executed without an error or warning.

And, the first kernel was booted with this append:
append="rhgb quiet root=LABEL=/ console=ttyS0,38400n8 \
  crashkernel8M@256M"

I should have provided all these info at my 1st email :(

Regards,
  - jay

> 
> Thanks,
>  - jay
> 
> 
>> What did i miss here? Do i miss any patch(es)?
>> My machine is a HP zx6000 loaded with FC5.
>>
>> Thanks!
>>  - jay
>>
>>>
>>> Thanks
>>> Zou Nan hai
> 
> 

