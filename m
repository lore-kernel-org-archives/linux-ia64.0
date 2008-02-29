From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 29 Feb 2008 09:39:55 +0000
Subject: Re: [kvm-ia64-devel] [PATCH 0/5] RFC: ia64/pv_ops: ia64 intrinsicsparavirtualization
Message-Id: <20080229093955.GE11349%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12041926372068-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12041926372068-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 29, 2008 at 04:19:27PM +0800, Dong, Eddie wrote:
> Seems rebounded, just resend.
> 
> 
 wrote:
>>>>   Cons:
>>>>   - Binary patch is difficult.
>>>>     ia64 function call uses stacked registers, so that marking
>>>>   br.call     instruction is difficult. - so that the performance
>>>> is suboptimal especially for native case.
>>>> 
>>> 
>>> I am not sure if this statement is true. We can still patching it.
>>> For example using same inline asm code for paravirt_get_cpuid
>>> definition and it could be exactly same with X86.
>> 
>> Stacked registers must be allocated by alloc instruction.
>> And it is issued in caller function's prologue. I.e. gcc maintains
>> how many local registers (sol) and output output registers (sof -
>> sol) are used.
> 
> It depends on where do we start to patch. I.e. if the patch code will
> replace the prologue code or not? I think we can solve this by
> replace the prologue, but  I may miss something.

Yes, we can scan instruction backward looking for alloc instruction
and rewrite it and know its frame size (sol and sof).
Thus we can guarantee that output registers are accessible.
In fact specifying "out0", "out1", ... as clobbered registers
in inline assembler code, gcc allocates them. and we can
clobber those registers.

However we can't clobber stacked registers out of specified ones
so that its conversion differs from C function calling one.
For example
        func()
                // out0 and out1 are allocated.
                paravirt_get_cpuid(index);
                        // asm volatile ("..."
                        //               "br.call xen_get_cpuid"
                        //               "...":
                        //               input: output:
                        //               "out0");
                other_func(arg0, arg1);

In xen_get_cpuid() we can't clobber out1 so that xen_get_cpuid()
isn't allowed to allocate any extra stacked registers.
It means that xen_get_cpuid() can't be written in C.


>> So if we call function from inline assembly, we have to tell to gcc
>> how many output registers are used. I haven't found the way to do
>> that.
> 
> The new (patched) code comes from the type of pv_ops, so it know
> how many parameters it used and how to alloc etc.
> 
>> On the other hand On x86, just telling clobbered registers is okay.
>> 
>> Even if we find the way to tell it to gcc, the next issue it how to
>> determin how many local registers (sol).
> 
> The original prologue is replaced, so we only care the new code
> prologue which is known to us if we still call somewhere. Some time,
> it doesn't 
> need call other function if the code size is enough to hold the new
> code. 

I don't say it's impossible. (The ultimate way is to add such
extension to gcc.)
I want to claim that C function call option is much more difficult
than other options and it's worth while to consider other options.
Why not some kind of static calling convension?

-- 
yamahata
