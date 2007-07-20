From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 20 Jul 2007 05:52:08 +0000
Subject: Re: [PATCH take3 0/12] Support vector domain on ia64
Message-Id: <m1abtr39mf.fsf@ebiederm.dsl.xmission.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <469CB3FA.7010301@jp.fujitsu.com>
In-Reply-To: <469CB3FA.7010301@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> writes:

> Hi Eric,
>
> Eric W. Biederman wrote:
>> Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com> writes:
>>
>>> - define NR_IRQS as follow:
>>>
>>>   Vector domain can provide the number of irqs being proportional to the
>>>   number of CPUs theoretically. However, the relation between them is
>>>   actually not linear, especially in large system. To avoid the memory
>>>   consumption derived from too many irqs, I define NR_IRQS as follows:
>>>
>>>   #if (NR_VECTORS + 32 * NR_CPUS) < 1024
>>>   #define NR_IRQS (NR_VECTORS + 32 * NR_CPUS)
>>>   #else
>>>   #define NR_IRQS 1024
>>>   #endif
>>
>>
>> Below is my old patch to address this in a different way.
>> Basically this moves the per cpu counter of the number of
>> times an irq has happened on an individual cpu out of the
>> per cpu area.  Honestly I think this might even have better
>> cache performance.
>
> Sorry for my late reply.
>
> I overviewed your patch and the patch looks good to me. It can improve
> not only ia64 vector domain but also x86_64 vector domain. I'll consider
> testing the patch after rebasing it, and if it'll be OK, including your
> idea (or similar one) into my patchset.
>
> BTW, I googled to find the discussion related to your patch, but can't find
> it at all. Where did you submit it to?

I just started the discussion. :)

Basically I have a tree where I am working on removing all arrays of
size NR_IRQS.   Which makes it then possible to assign irq numbers
with a stable scheme even when we have a bunch of them.  You might
find a little bit about that on linux-arch.

I haven't had time to finish my internal tree merge it anywhere.  So
the half complete pieces are just sitting on my hard drive.

Eric
