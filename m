From: Michael Ellerman <mpe@ellerman.id.au>
Date: Wed, 27 Sep 2017 06:26:44 +0000
Subject: Re: [RFC][PATCH v2 0/7] printk/ia64/ppc64/parisc64: let's deprecate %pF/%pf printk specifiers
Message-Id: <87y3p0ejx7.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170920162910.32053-1-sergey.senozhatsky@gmail.com> <20170922053404.3zpfpwetabjut2er@santosiv.in.ibm.com>
In-Reply-To: <20170922053404.3zpfpwetabjut2er@santosiv.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Santosh Sivaraj <santosh@fossix.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, James Bottomley <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>, Andrew Morton <akpm@linux-foundation.org>, Jessica Yu <jeyu@kernel.org>, Alexei Starovoitov <ast@kernel.org>, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Santosh Sivaraj <santosh@fossix.org> writes:

> * Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote (on 2017-09-20 16:29:02 +0000):
>
>>         Hello
>> 
>>         RFC
>> 
>>         On some arches C function pointers are indirect and point to
>> a function descriptor, which contains the actual pointer to the code.
>> This mostly doesn't matter, except for cases when people want to print
>> out function pointers in symbolic format, because the usual '%pS/%ps'
>> does not work on those arches as expected. That's the reason why we
>> have '%pF/%pf', but since it's here because of a subtle ABI detail
>> specific to some arches (ppc64/ia64/parisc64) it's easy to misuse
>> '%pF/%pf' and '%pS/%ps' (see [1], for example).
>> 
>>         This patch set attempts to move ia64/ppc64/parisc64 C function
>> pointer ABI details out of printk() to arch code. Function dereference
>> code now checks if a pointer belongs to a .opd ELF section and dereferences
>> that pointer only if it does. The kernel and modules have their own .opd
>> sections that's why I use two different ARCH functions: for kernel and
>> for module pointer dereference.
>> 
>>         I planned to remove dereference_function_descriptor() entirely,
>> but then I discovered a bunch other uses cases (kgdbts, init/main.c,
>> extable, etc.), so I decided to keep dereference_function_descriptor()
>> around because the main point of this patch set is to deprecate %pF/%pf.
>> But at the same time, I think I can go further and handle both kernel
>> and module descriptor dereference in dereference_function_descriptor().
>> We need a module pointer for module .opd check, so that will come at an
>> extra cost of module lookup (may be there will some other issues along
>> the way, haven't checked it).
>> 
>> Right now we've got:
>> 
>> - dereference_function_descriptor(addr)
>>         a generic (old) function. it simply attempts to dereference
>>         whatever pointer we give it.
>> 
>> - dereference_kernel_function_descriptor(addr)
>>         dereferences a kernel pointer if it's within the kernel's .opd
>>         section.
>> 
>> - dereference_module_function_descriptor(module, addr)
>>         dereference a module pointer if it's within the module's .opd
>>         section.
>> 
>> 
>> *** A BIG NOTE ***
>>         I don't own ia64/ppc64/parisc64 hardware, so the patches are not
>>         tested. Sorry about that!
>
> Tested patch series on ppc64 sucessfully.
>
> You may add tested by to the series.
>
> Tested-by: Santosh Sivaraj <santosh@fossix.org>

Thanks Santosh.

I also gave it a quick spin. I'll give you an ack for the powerpc changes.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)


Thanks for cleaning this up Sergey.

cheers
