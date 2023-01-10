From: Andrzej Hajda <andrzej.hajda@intel.com>
Date: Tue, 10 Jan 2023 12:46:37 +0000
Subject: Re: [Intel-gfx] [RFC DO NOT MERGE] treewide: use __xchg in most obvious places
Message-Id: <1bfae3d0-8c0b-ea83-7184-db847a4a969f@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Y7b6/7coJEVlTVxK@phenom.ffwll.local>
 <20230110105306.3973122-1-andrzej.hajda@intel.com>
 <Y71G1tkmUzM4BLxn@smile.fi.intel.com>
In-Reply-To: <Y71G1tkmUzM4BLxn@smile.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, dri-devel@lists.freedesktop.org, linux-mips@vger.kernel.org, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-snps-arc@lists.infradead.org, Boqun Feng <boqun.feng@gmail.com>, linux-xtensa@linux-xtensa.org, Arnd Bergmann <arnd@arndb.de>, intel-gfx@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, loongarch@lists.linux.dev, Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, Daniel Vetter <daniel@ffwll.ch>, linux-alpha@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org

On 10.01.2023 12:07, Andy Shevchenko wrote:
> On Tue, Jan 10, 2023 at 11:53:06AM +0100, Andrzej Hajda wrote:
>> This patch tries to show usability of __xchg helper.
>> It is not intended to be merged, but I can convert
>> it to proper patchset if necessary.
>>
>> There are many more places where __xchg can be used.
>> This demo shows the most spectacular cases IMHO:
>> - previous value is returned from function,
>> - temporary variables are in use.
>>
>> As a result readability is much better and diffstat is quite
>> nice, less local vars to look at.
>> In many cases whole body of functions is replaced
>> with __xchg(ptr, val), so as further refactoring the whole
>> function can be removed and __xchg can be called directly.
> 
> ...
> 
>>   arch_uretprobe_hijack_return_addr(unsigned long trampoline_vaddr,
>>   				  struct pt_regs *regs)
>>   {
>> -	unsigned long orig_ret_vaddr;
>> -
>> -	orig_ret_vaddr = regs->ARM_lr;
>> -	/* Replace the return addr with trampoline addr */
>> -	regs->ARM_lr = trampoline_vaddr;
>> -	return orig_ret_vaddr;
>> +	return __xchg(&regs->ARM_lr, trampoline_vaddr);
>>   }
> 
> If it's not a callback, the entire function can be killed.
> And this is a good example of the function usage.
> OTOH, these places might have a side effect (if it's in deep CPU
> handlers), means we need to do this carefully.
> 
> ...
> 
>>   static inline void *qed_chain_produce(struct qed_chain *p_chain)
>>   {
>> -	void *p_ret = NULL, *p_prod_idx, *p_prod_page_idx;
>> +	void *p_prod_idx, *p_prod_page_idx;
>>   
>>   	if (is_chain_u16(p_chain)) {
>>   		if ((p_chain->u.chain16.prod_idx &
>> @@ -390,11 +391,8 @@ static inline void *qed_chain_produce(struct qed_chain *p_chain)
>>   		p_chain->u.chain32.prod_idx++;
>>   	}
>>   
>> -	p_ret = p_chain->p_prod_elem;
>> -	p_chain->p_prod_elem = (void *)(((u8 *)p_chain->p_prod_elem) +
>> -					p_chain->elem_size);
>> -
>> -	return p_ret;
>> +	return __xchg(&p_chain->p_prod_elem,
>> +		      (void *)(((u8 *)p_chain->p_prod_elem) + p_chain->elem_size));
> 
> Wondering if you still need a (void *) casting after the change. Ditto for the
> rest of similar cases.

IMHO it is not needed also before the change and IIRC gcc has an 
extension which allows to drop (u8 *) cast as well [1].

[1]: https://gcc.gnu.org/onlinedocs/gcc/Pointer-Arith.html

> 
>>   }
> 
> ...
> 
> Btw, is it done by coccinelle? If no, why not providing the script?
> 

Yes I have used cocci. My cocci skills are far from perfect, so I did 
not want to share my dirty code, but this is nothing secret:

@r1@
expression x, v;
local idexpression p;
@@
-       p = x;
-       x = v;
-       return p;
+       return __xchg(&x, v);

@depends on r1@
expression e;
@@
         __xchg(
-       &*e,
+       e,
         ...)

@depends on r1@
expression t;
@@
-       if (t) {
+       if (t)
                 return __xchg(...);
-       }

@depends on r1@
type t;
identifier p;
expression e;
@@
(
-       t p;
|
-       t p = e;
)
         ... when != p

Regards
Andrzej
