From: Amerigo Wang <amwang@redhat.com>
Date: Wed, 26 Aug 2009 06:59:19 +0000
Subject: Re: [Patch 6/8] powerpc: add CONFIG_KEXEC_AUTO_RESERVE
Message-Id: <4A94DD47.4000202@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20090821065637.4855.32234.sendpatchset@localhost.localdomain> <20090821065739.4855.19179.sendpatchset@localhost.localdomain> <1251121443.10645.56.camel@concordia> <4A938348.2020306@redhat.com> <20090825102837.GB14591@in.ibm.com>
In-Reply-To: <20090825102837.GB14591@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mohan@in.ibm.com
Cc: michael@ellerman.id.au, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, Neil Horman <nhorman@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, kamezawa.hiroyu@jp.fujitsu.com, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>

M. Mohan Kumar wrote:
> On Tue, Aug 25, 2009 at 02:23:04PM +0800, Amerigo Wang wrote:
>   
>> Michael Ellerman wrote:
>>     
>>> On Fri, 2009-08-21 at 02:55 -0400, Amerigo Wang wrote:
>>>   
>>>       
>>>> Introduce a new config option KEXEC_AUTO_RESERVE for powerpc.
>>>>
>>>> Index: linux-2.6/arch/powerpc/Kconfig
>>>> =================================>>>> --- linux-2.6.orig/arch/powerpc/Kconfig
>>>> +++ linux-2.6/arch/powerpc/Kconfig
>>>> @@ -346,6 +346,17 @@ config KEXEC
>>>>  	  support.  As of this writing the exact hardware interface is
>>>>  	  strongly in flux, so no good recommendation can be made.
>>>>  +config KEXEC_AUTO_RESERVE
>>>> +	bool "automatically reserve memory for kexec kernel"
>>>> +	depends on KEXEC
>>>> +	default y
>>>> +	---help---
>>>> +	  Automatically reserve memory for a kexec kernel, so that you don't
>>>> +	  need to specify numbers for the "crashkernel=X@Y" boot option,
>>>> +	  instead you can use "crashkernel=auto". To make this work, you need
>>>> +	  to have more than 4G memory. On PPC, 256M is reserved, 1/32 memory
>>>> +	  on PPC64, but it will not exceed 1T/32.
>>>>     
>>>>         
>>> To be honest I don't see why this logic goes in the kernel. It seems to
>>> me that it's policy how much memory you devote to the crash kernel vs
>>> the production kernel. It depends on what kind of crash kernel you're
>>> loading, a minimal UP dump kernel, or a full-featured SMP behemoth, An
>>> it depends on how much memory you're willing to leave idle in the
>>> off-chance you crash.
>>>   
>>>       
>> True, but since in the crash kernel, we have very little memory, so  
>> probably loading a full-featured SMP kernel doesn't make much sense...
>>
>> And in patch 1/8, I introduced a way to free the reserved memory at  
>> run-time.
>>
>>     
>>> That aside, I don't see how this will be useful in practice, if it only
>>> works for memory sizes over 4G? Or are we saying that people with less
>>> than 4G don't need crash kernels? If we're not saying that, those users,
>>> or those users' distros, still need to do some logic to work out if they
>>> have < 4GB of memory and if so pick a crash kernel size. So why can't
>>> they pick the size in the > 4GB case also?
>>>   
>>>       
>> No, we set 4G as a threshold because we only want this work when have  
>> have enough memory which is defined as 4G currently... This can be  
>> changed to arch-dependent, e.g. ppc. I am very open to this.
>>
>>     
>
> So the distro/admin have to use crashkernel=auto for machines having more
> than 4GB RAM and for machines with less than 4GB RAM they have to use the
> crashkernel=x@y (or extended crashkernel syntax)? IMHO it will be nice if
> crashkernel=auto could handle all of the situations.
>   

Exactly yes.

As you suggested, I already change 4G to 2G on ppc.

I think I have already explained the reason in a previous email, I just 
don't know if '2G - reserved_memory' is safe for ppc or not. What is the 
minimum memory size for a normal kernel to run on ppc? And how is it if 
I configure PAGE_SIZE > 4K, e.g. 64K?

Thanks!

