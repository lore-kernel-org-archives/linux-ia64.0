From: Amerigo Wang <amwang@redhat.com>
Date: Mon, 31 Aug 2009 03:25:08 +0000
Subject: Re: [Patch 0/8] V5 Implement crashkernel=auto
Message-Id: <4A9B4294.6080902@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090827031800.4534.94868.sendpatchset@localhost.localdomain>	<1251680096.5279.6.camel@concordia> <m1ws4kznvf.fsf@fess.ebiederm.org>
In-Reply-To: <m1ws4kznvf.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: michael@ellerman.id.au, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, "M. Mohan Kumar" <mohan@in.ibm.com>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

Eric W. Biederman wrote:
> Michael Ellerman <michael@ellerman.id.au> writes:
>
>   
>> On Wed, 2009-08-26 at 23:15 -0400, Amerigo Wang wrote:
>>     
>>> V4 -> V5:
>>>  - Rename the global functions, as suggested by Andrew.
>>>  - Save some macros, as suggested by Andrew.
>>>  - Change the high threshold, from 32G to 4G.
>>>  - Change the low threshold on ppc, suggested by ppc developers.
>>>  - Make the mm part as a seperate function, suggest by Eric.
>>>  - Make the IA64 code more readable.
>>>  - Reorder the patchset again, since review from mm people is done.
>>>
>>> V3 -> V4:
>>>  - Reorder the patches.
>>>  - Really free the reserved memory, instead of remapping it.
>>>    (Thanks to KAMEZAWA Hiroyuki!)
>>>  - Release the reserved memory resource when the size is 0.
>>>  - Use strict_strtoul() instead of simple_strtoul().
>>>
>>> V2 -> V3:
>>>  - Use more clever way to calculate reserved memory size, especially for IA64.
>>>  - Add that patch that implements shrinking reserved memory
>>>
>>> V1 -> V2:
>>>  - Use include/asm-generic/kexec.h, suggested by Neil.
>>>  - Rename a local variable, suggested by Fenghua.
>>>  - Fix some style problems found by checkpatch.pl.
>>>  - Unify the Kconfig docs.
>>>
>>> This series of patch implements automatically reserved memory for crashkernel,
>>> by introducing a new boot option "crashkernel=auto". This idea is from Neil.
>>>
>>> In case of breaking user-space applications, it modifies this boot option after
>>> it decides how much memory should be reserved.
>>>
>>> On different arch, the threshold and reserved memory size is different. Please
>>> refer patch 7/8 which contains an update for the documentation.
>>>
>>> Patch 8/8 implements shrinking reserved memory at run-time, which is useful
>>> when more than enough memory is reserved automatically.
>>>
>>> This patchset _is_ already tested on x86_64, IA64 and ppc64.
>>>       
>> I don't want to sound like a micro-kernel zealot, I'm not, but I'm still
>> unconvinced as to why the auto logic needs to go in the kernel. What is
>> the compelling reason that the kernel needs to do this calculation vs
>> some userspace tool? We already have the syntax that allows defining a
>> different crash size depending on the size of RAM.
>>
>> The shrinking of reserved memory is cool.
>>     
>
> Michael I am in agreement with you.
> The shrinking is good.
>
> If we can come up with some simple and generic logic that we can use
> to reserve memory then I am in favor.  However all this patchset is
> doing is moving user space specific arbitrary hacks into the kernel we
> do that perfectly well on the command line.  Having the amount to
> reserve be arch specific is complete non-sense and a major maintenance
> pain.
>   

Ok, since you guys think we should not do sth in kernel space if we can 
do it in user space, why not removing the extended crash kernel syntax??

E.g.
crashkernelQ2M-2G:64M,2G-:128M

I am *quite* sure this can be done in user space too. In theory, only 
you need is just:

crashkernel=X@Y

all the rest things can be done in user space. Enjoy!

