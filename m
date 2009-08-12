From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 12 Aug 2009 02:43:30 +0000
Subject: Re: [RFC Patch 2/2] kexec: allow to shrink reserved memory
Message-Id: <m1ws5992gd.fsf@fess.ebiederm.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090811104144.5154.77871.sendpatchset@localhost.localdomain>
	<20090811104154.5154.78710.sendpatchset@localhost.localdomain>
	<m1r5vi9l9v.fsf@fess.ebiederm.org> <4A821A14.1020408@redhat.com>
	<m17hx9n6s5.fsf@fess.ebiederm.org> <4A822404.9030603@redhat.com>
In-Reply-To: <4A822404.9030603@redhat.com> (Amerigo Wang's message of "Wed\, 12 Aug 2009 10\:08\:04 +0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Amerigo Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, Ingo Molnar <mingo@elte.hu>

Amerigo Wang <amwang@redhat.com> writes:

> Eric W. Biederman wrote:
>> Amerigo Wang <amwang@redhat.com> writes:
>>
>>   
>>> Eric W. Biederman wrote:
>>>     
>>>> Amerigo Wang <amwang@redhat.com> writes:
>>>>
>>>>         
>>>>> This patch implements shrinking the reserved memory for crash kernel,
>>>>> if it is more than enough.
>>>>>
>>>>> For example, if you have already reserved 128M, now you just want 100M,
>>>>> you can do:
>>>>>
>>>>> # echo $((100*1024*1024)) > /sys/kernel/kexec_crash_size
>>>>>             
>>>> This patch looks like a reasonable start.
>>>>
>>>> However once a crash kernel image is loaded we have already told that
>>>> image about the memory that is available and what you are doing here
>>>> will go and stop on the memory that is reserved but not yet used,
>>>> totally breaking the DMA protections.  AKA we know the memory is safe
>>>> from ongoing DMAs because it has lain fallow since boot up.
>>>>
>>>> The only safe thing to do is to reduce the memory size before (possibly
>>>> just before) we load the crash kernel.  Which means we should only
>>>> be allowed to shrink the size when nothing is loaded, exactly the
>>>> opposite of what you have implemented.
>>>>
>>>>         
>>> Confused, why just loading the crash kernel makes it unsafe?
>>> DMA should be avoided when reserving that memory during boot, shouldn't it?
>>>     
>>
>> Yes.  But you are removing the reservation and starting DMA on memory
>> we have told the crash kernel it can use.
>>   
>
> We can modify the info given to the crash kernel.

Only by unloading and reloading.

>>> I know I missed the part that freeing memory before loading, but if it is safe
>>> before loading, how can it be unsafe after that?
>>>     
>>
>> We tell the crash kernel when loading it, it can use all of the reserved memory.
>>   
>
> Yeah, but we should reload the kernel after shrinking the memory, it is not
> surprised that doing this is necessary...

So unload the crash kernel first.  If you don't you open a race where
many of the guarantees we make for the crash kernel about the state of
the memory it might be using are not true.

In general I expect we will be able to do this all before we load the
crash kernel the first time.  But at least we should not need to reboot
things if there is a problem.

Eric



