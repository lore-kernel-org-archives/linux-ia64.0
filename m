From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 29 Feb 2008 02:45:49 +0000
Subject: Re: [PATCH 0/5] RFC: ia64/pv_ops: ia64 intrinsics paravirtualization
Message-Id: <20080229024549.GB11349%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <12041926372068-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12041926372068-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Feb 29, 2008 at 01:21:27AM +0800, Dong, Eddie wrote:

> > * Option 4: indirect function call
> > The code would look like
> >         struct pv_cpu_ops {
> >                 unsigned long (*get_cpuid)(unsigned long index)
> >                 ....
> >         };
> >         extern struct pv_cpu_ops pv_cpu_ops;
> >         ...
> >         static inline unsigned long
> >         paravirt_get_cpuid(unsigned long index)
> >         {
> >                 return pv_cpu_ops->get_cpuid(index);
> >         }
> >         #define ia64_get_cpuid  paravirt_get_cpuid
> > 
> >   Pros:
> >   - Binary patch isn't required.
> >   - indirect function call is the very way x86 pv_ops adopted.
> >   - If hypervisor supports fast hypercall using gate page,
> >     it may want to use function call.
> > 
> >   Cons:
> >   - Binary patch is difficult.
> >     ia64 function call uses stacked registers, so that marking br.call
> >     instruction is difficult.
> >   - so that the performance is suboptimal especially for native case.
> > 
> 
> I am not sure if this statement is true. We can still patching it. For
> example
> using same inline asm code for paravirt_get_cpuid definition and it
> could be
> exactly same with X86.

Stacked registers must be allocated by alloc instruction.
And it is issued in caller function's prologue. I.e. gcc maintains
how many local registers (sol) and output output registers (sof - sol)
are used.
So if we call function from inline assembly, we have to tell to gcc 
how many output registers are used. I haven't found the way to do
that.
On the other hand On x86, just telling clobbered registers is okay.

Even if we find the way to tell it to gcc, the next issue it how to
determin how many local registers (sol).
In assembler source code we can refer function arguments as out0...,
but when binary patching we have to determin its register number.

-- 
yamahata
