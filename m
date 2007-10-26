From: Kumar Gala <galak@kernel.crashing.org>
Date: Fri, 26 Oct 2007 14:55:46 +0000
Subject: Re: [PATCH] IA64, PPC, SPARC: minor irq handler cleanups
Message-Id: <A5CC1A2F-831A-494E-8C2F-6E499C0A36E0@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org> <d12d72446eb0ff40da5e709b1f658df479b92658.1193390975.git.jeff@garzik.org> <CF660BA8-BEC6-4CB7-9627-0135ACD46DD8@kernel.crashing.org> <4721B817.7090602@garzik.org>
In-Reply-To: <4721B817.7090602@garzik.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jeff@garzik.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, davem@davemloft.net, tony.luck@intel.com, linux-ia64@vger.kernel.org, paulus@samba.org, benh@kernel.crashing.org


On Oct 26, 2007, at 4:49 AM, Jeff Garzik wrote:

> Kumar Gala wrote:
>> On Oct 26, 2007, at 4:40 AM, Jeff Garzik wrote:
>>> ia64/sn/kernel/huberror.c:
>>>     - remove pointless void* cast
>>>     - add KERN_xxx prefix
>>>
>>> ia64/sn/pci/tioce_provider.c: start functions at column zero
>>>
>>> ppc/8xx_io/fec.c: kill prototype, remove extra whitespace
>>>
>>> ppc/platforms/85xx/*
>>>     'irq' argument in irq handler is used purely as a temporary
>>>     variable.  Update the function to reflect this usage, changing
>>>     the first arg's name from 'irq' to 'dummy'
>>>
>>> ppc/platforms/sbc82xx.c: ditto
>>>
>>> sparc/kernel/time.c: mark timer_interrupt() static (from DaveM)
>>>
>>> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
>>> ---
>>>  arch/ia64/sn/kernel/huberror.c               |    4 ++--
>>>  arch/ia64/sn/pci/tioce_provider.c            |    6 ++++--
>>>  arch/ppc/8xx_io/fec.c                        |    3 +--
>>>  arch/ppc/platforms/85xx/mpc8560_ads.c        |    4 +++-
>>>  arch/ppc/platforms/85xx/mpc85xx_cds_common.c |    4 +++-
>>>  arch/ppc/platforms/85xx/stx_gp3.c            |    4 +++-
>>>  arch/ppc/platforms/85xx/tqm85xx.c            |    4 +++-
>>>  arch/ppc/platforms/sbc82xx.c                 |    4 +++-
>>>  arch/sparc/kernel/time.c                     |    2 +-
>>>  9 files changed, 23 insertions(+), 12 deletions(-)
>> I haven't been following this with detail.  Is the intent that  
>> this would be for 2.6.24 or .25?
>
> These patches are all cleanups and minor fixes I found while  
> iterating through each interrupt handler in the kernel, in pursuit  
> of a related project.
>
> So they can stand by themselves, and can integrate into whatever  
> flow maintainers find most comfortable.
>
> I'm not in any rush, but neither would I like them to sit forever...

Ok. Not to be a pain, but it would be easier if this one patch might  
be easier if it was split down the arch lines so each maintainer can  
deal with it.

I say this especially for the ppc code because the intent in 2.6.25  
is to actually try and remove some of the files you are fixing up for  
their arch/powerpc variants.

- k
