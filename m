From: Greg Ungerer <gerg@snapgear.com>
Date: Thu, 09 Sep 2010 23:17:37 +0000
Subject: Re: [RFC trollpatch 1/1] genirq: Remove the fits all and nothing
Message-Id: <4C896B11.6030705@snapgear.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100908152036.643594727@linutronix.de> <4C888AFF.80304@snapgear.com> <20100909140926.GH24791@bombadil.infradead.org>
In-Reply-To: <20100909140926.GH24791@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Christoph Hellwig <hch@infradead.org>, linux-alpha@vger.kernel.org, linux-cris-kernel@axis.com, Haavard Skinnemoen <hskinnemoen@atmel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Hirokazu Takata <takata@linux-m32r.org>, Greg Ungerer <gerg@uclinux.org>, Jeff Dike <jdike@addtoit.com>, linux-parisc@vger.kernel.org, Chris Zankel <chris@zankel.net>, linux-arch@vger.kernel.org


Hi Kyle,

Kyle McMartin wrote:
> On Thu, Sep 09, 2010 at 05:21:35PM +1000, Greg Ungerer wrote:
>> The m68knommu arch should be easy to fix up. Here is a first pass
>> patch. Tested and working on 1 board so far. I need to check all
>> the processor types, and test a few more to be sure :-)
>>
> 
> Dunno if you noticed, Greg, but you've already had a removal patch
> submitted some time ago...

I had forgotten about that patch... But if you follow the email
trail I had to drop it soon after, it caused user space to lock
up. I let Steven know (in that same thread) but he never came
back with any fixes/updates.

(That patch also added support for edge triggered GPIO interrupts,
and that may well have been the source of the problems).

Thanks
Greg


> Date: Wed, 16 Dec 2009 19:15:39 -0800                                                                                                                                              
> From: Steven King <sfking@fdwdc.com>                                                                                                                                               
> To: Greg Ungerer <gerg@snapgear.com>                                                                                                                                               
> Subject: [PATCH] m68knommu: get rid of __do_IRQ and add support for
>  using gpio irqs.       
> 
> (noticed this while searching for __do_IRQ related stuff in my email
> last night.)
> 
> regards, Kyle
> 
>> Regards
>> Greg
>>
>>
>> -- 
>> ------------------------------------------------------------------------
>> Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
>> SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
>> 8 Gardner Close                             FAX:         +61 7 3217 5323
>> Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
> 
>> m68knommu: stop using __do_IRQ
>>
>> The use of __do_IRQ is deprecated, so lets stop using it.
>> Generally the interrupts on the supported processors here are
>> level triggered, so this is strait forward to switch over to
>> using the standard handle_level_irq flow handler.
>>
>> Signed-off-by: Greg Ungerer <gerg@uclinux.org>
>> ---
>>  arch/m68knommu/Kconfig                       |    4 ++++
>>  arch/m68knommu/platform/5272/intc.c          |    1 +
>>  arch/m68knommu/platform/68328/ints.c         |    1 +
>>  arch/m68knommu/platform/68360/ints.c         |    1 +
>>  arch/m68knommu/platform/coldfire/intc-2.c    |    1 +
>>  arch/m68knommu/platform/coldfire/intc-simr.c |    1 +
>>  arch/m68knommu/platform/coldfire/intc.c      |    1 +
>>  7 files changed, 10 insertions(+), 0 deletions(-)
>>
>> diff --git a/arch/m68knommu/Kconfig b/arch/m68knommu/Kconfig
>> index 2609c39..fd28178 100644
>> --- a/arch/m68knommu/Kconfig
>> +++ b/arch/m68knommu/Kconfig
>> @@ -59,6 +59,10 @@ config GENERIC_HARDIRQS
>>  	bool
>>  	default y
>>  
>> +config GENERIC_HARDIRQS_NO__DO_IRQ
>> +	bool
>> +	default y
>> +
>>  config GENERIC_CALIBRATE_DELAY
>>  	bool
>>  	default y
>> diff --git a/arch/m68knommu/platform/5272/intc.c b/arch/m68knommu/platform/5272/intc.c
>> index 7081e0a..e9da6f1 100644
>> --- a/arch/m68knommu/platform/5272/intc.c
>> +++ b/arch/m68knommu/platform/5272/intc.c
>> @@ -133,6 +133,7 @@ void __init init_IRQ(void)
>>  		irq_desc[irq].depth = 1;
>>  		irq_desc[irq].chip = &intc_irq_chip;
>>  		intc_irq_set_type(irq, 0);
>> +		set_irq_handler(irq, handle_level_irq);
>>  	}
>>  }
>>  
>> diff --git a/arch/m68knommu/platform/68328/ints.c b/arch/m68knommu/platform/68328/ints.c
>> index b91ee85..90516ee 100644
>> --- a/arch/m68knommu/platform/68328/ints.c
>> +++ b/arch/m68knommu/platform/68328/ints.c
>> @@ -183,6 +183,7 @@ void __init init_IRQ(void)
>>  		irq_desc[i].action = NULL;
>>  		irq_desc[i].depth = 1;
>>  		irq_desc[i].chip = &intc_irq_chip;
>> +		set_irq_handler(irq, handle_level_irq);
>>  	}
>>  }
>>  
>> diff --git a/arch/m68knommu/platform/68360/ints.c b/arch/m68knommu/platform/68360/ints.c
>> index 6f22970..cdf691e 100644
>> --- a/arch/m68knommu/platform/68360/ints.c
>> +++ b/arch/m68knommu/platform/68360/ints.c
>> @@ -136,6 +136,7 @@ void init_IRQ(void)
>>  		irq_desc[i].action = NULL;
>>  		irq_desc[i].depth = 1;
>>  		irq_desc[i].chip = &intc_irq_chip;
>> +		set_irq_handler(irq, handle_level_irq);
>>  	}
>>  }
>>  
>> diff --git a/arch/m68knommu/platform/coldfire/intc-2.c b/arch/m68knommu/platform/coldfire/intc-2.c
>> index 5598c8b..6410f7e 100644
>> --- a/arch/m68knommu/platform/coldfire/intc-2.c
>> +++ b/arch/m68knommu/platform/coldfire/intc-2.c
>> @@ -88,6 +88,7 @@ void __init init_IRQ(void)
>>  		irq_desc[irq].action = NULL;
>>  		irq_desc[irq].depth = 1;
>>  		irq_desc[irq].chip = &intc_irq_chip;
>> +		set_irq_handler(irq, handle_level_irq);
>>  	}
>>  }
>>  
>> diff --git a/arch/m68knommu/platform/coldfire/intc-simr.c b/arch/m68knommu/platform/coldfire/intc-simr.c
>> index 1b01e79..7f4abb3 100644
>> --- a/arch/m68knommu/platform/coldfire/intc-simr.c
>> +++ b/arch/m68knommu/platform/coldfire/intc-simr.c
>> @@ -73,6 +73,7 @@ void __init init_IRQ(void)
>>  		irq_desc[irq].depth = 1;
>>  		irq_desc[irq].chip = &intc_irq_chip;
>>  		intc_irq_set_type(irq, 0);
>> +		set_irq_handler(irq, handle_level_irq);
>>  	}
>>  }
>>  
>> diff --git a/arch/m68knommu/platform/coldfire/intc.c b/arch/m68knommu/platform/coldfire/intc.c
>> index a4560c8..40b9e8d 100644
>> --- a/arch/m68knommu/platform/coldfire/intc.c
>> +++ b/arch/m68knommu/platform/coldfire/intc.c
>> @@ -148,6 +148,7 @@ void __init init_IRQ(void)
>>  		irq_desc[irq].depth = 1;
>>  		irq_desc[irq].chip = &intc_irq_chip;
>>  		intc_irq_set_type(irq, 0);
>> +		set_irq_handler(irq, handle_level_irq);
>>  	}
>>  }
>>  
> 
> 


-- 
------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
