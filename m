From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Thu, 05 Jul 2007 11:55:22 +0000
Subject: Re: [RFC][PATCH take2 0/13] Support vector domain on ia64
Message-Id: <468CDC2A.2020509@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <46779036.5050602@jp.fujitsu.com>
In-Reply-To: <46779036.5050602@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony,

Luck, Tony wrote:
>> Here is a series of patches for ia64 vector domain. By these patches, we can
>> use more than 256 irqs. The patchset is based on existing x86-64 vector domain
>> code. This is for 2.6.22-rc5 and I tested them on my ia64 box.
> 
> There are a few whitespace issues (<space><tab>) amongst these patches (I think
> in parts 6 & 13).  Here's the summary of the broken bits:
> 
> < +	unsigned int 	gsi_base;	/* GSI base */
> < +	unsigned short 	num_rte;	/* # of RTEs on this IOSAPIC */
> ---
>> +	unsigned int	gsi_base;	/* GSI base */
>> +	unsigned short	num_rte;	/* # of RTEs on this IOSAPIC */
> 
> < +  		if (irq < 0)
> ---
>> +		if (irq < 0)
> 
> < +#define IRQ_RSVD 		(2)
> ---
>> +#define IRQ_RSVD		(2)
> 
> < + 	return vector;
> ---
>> +	return vector;
> 
> I also got two build errors which broke several configurations:
> 
> tiger-up (this is arch/ia64/configs/tiger_defconfig with CONFIG_SMP deleted)
> 
> arch/ia64/kernel/irq_ia64.c: In function `parse_vector_domain':
> arch/ia64/kernel/irq_ia64.c:270: error: `no_int_routing' undeclared (first use in this function)
> arch/ia64/kernel/irq_ia64.c:270: error: (Each undeclared identifier is reported only once
> arch/ia64/kernel/irq_ia64.c:270: error: for each function it appears in.)
> make[1]: *** [arch/ia64/kernel/irq_ia64.o] Error 1
> 
> generic-up (arch/ia64/defconfig with CONFIG_SMP deleted)
> 
> same error as tiger-up
> 
> generic-smp (arch/ia64-defconfig)
> 
>   CC      arch/ia64/kernel/asm-offsets.s
> In file included from include/linux/hardirq.h:7,
>                  from include/linux/interrupt.h:11,
>                  from include/asm-ia64/mca.h:16,
>                  from arch/ia64/kernel/asm-offsets.c:15:
> include/asm/hardirq.h:30:3: #error HARDIRQ_BITS is too low!
> make[1]: *** [arch/ia64/kernel/asm-offsets.s] Error 1
> 
> 
> sn2-smp (arch/ia64/configs/sn2_defconfig)
> 
> same error as generic-smp
> 
> generic-sparse (arch/ia64/configs/gensparse_defconfig)
> 
> same error as generic-smp
> 
> allnoconfig (make allnoconfig)
> 
> same error as tiger-up
> 
> 
> 
> Booting the arch/ia64/configs/tiger_defconfig kernel on my 4-socket Montecito tiger platform, I
> get an almost immediate oops.  I don't have the full stack backtrace, but the highlights were:
> 
> die
> ia64_do_page_fault
> ia64_leave_kernel
> ia64_handle_irq
> ia64_leave_kernel
> unlock_ipi_calllock
> start_secondary
> 
> I tried both with and without the new "vector=percpu" boot option (which needs to be
> documented in Documentation/kernel-parameters.txt), but it dies with the same
> stack trace both ways.
>

I tried it on my 4-socket Montecito machine, but didn't happen.
Could you send me your .config file and entire stack trace ?

Thanks,
Yasuaki Ishimatsu

> -Tony
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 



