From: Christian Hildner <christian.hildner@hob.de>
Date: Mon, 26 Jan 2004 08:05:30 +0000
Subject: Re: Loadable module and kernel gp
Message-Id: <4014CA4A.4020504@hob.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <4010EEC0.7020003@hob.de>
In-Reply-To: <4010EEC0.7020003@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Luck, Tony schrieb:

>>>>>>>On Fri, 23 Jan 2004 10:52:00 +0100, Christian Hildner 
>>>>>>>              
>>>>>>>
>><christian.hildner@hob.de> said:
>>
>>  Christian> Hi, does anybody know a simple way for a loadable module
>>  Christian> to get the gp value of the kernel? Is there any sample
>>  Christian> code?
>>
>>The safest way is probably to materialize a function pointer for a
>>function that is known to be in the kernel (and exported) and then to
>>read the second word.
>>
Yes, that's it, thanks. Sometimes good solutions are also simple. I'll 
try it.

>
>In case "materialzie a function pointer" is total greek:
>
>#include <linux/slab.h>
>
>struct fptr {
>	unsigned long func_addr;
>	unsigned long gp;
>};
>
>your_routine()
>{
>	struct fptr = (struct fptr *)kmalloc; /*function known to be in kernel */
>
>	printk("Kernel gp is %lx\n", fptr->gp);
>}
>
>
>Untested ... kmalloc is declared "inline" so that might mess things
>up.  Just choose some other exported thing if it is.
>
I hope the compiler will not explode if I request the pointer to an 
inlined function ;-). I like the idea of using kmalloc since this symbol 
should be present in almost any kernel.

Thanks

Christian

