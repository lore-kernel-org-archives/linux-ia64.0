From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 18 Feb 2008 11:31:16 +0000
Subject: Re: paravirt_ops support in IA64
Message-Id: <20080218113116.GD8023%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Added CC:virtualization@lists.linux-foundation.org]

On Mon, Feb 18, 2008 at 11:28:41AM +0800, Dong, Eddie wrote:
> Hi, Tony & all:
> 	Recently Xen-IA64 community is considering to add paravirt_ops
> support to keep sync with X86 and reduce maintenance effort. With
> pv_ops, sensitive instructions or some high level primitive
> functionalities (such as MMU ops) are replaced with pv_ops which is a
> function table call whose exact function pointer is initialized at Linux
> startup time depending on different hypervisor (or native) runing
> underlayer.

I've been working on forward porting Xenfied Linux.
Now I have domU boot and disk/network working with linux 2.6.25-rc1.
I'm planning to post those patch in this week. At worst I'll post
the cpu virtualization part which is discussed in this thread.
For those curious, please see
http://people.valinux.co.jp/~yamahata/xen-ia64/20080214/xen-ia64-20080214.patch
Sorry for the single jumbo patch, I'm now splitting it up into many
small patches for post.


> 	With this, we can reuse many code with X86 such as irqchip with
> X86, and similar dma support with X86, similar xenoprof/PMU profiling
> support etc. While CPU side pv_ops is quit different especially for
> those ASM code, since IA64 processor doesn;t have memory/stack ready at
> most IVT handler code.
> 
> 	In X86, ASM side pv_ops can save clobber registers to stack and
> do function call, but IA64 can't due to unavailable of memory access.
> 
> #define DISABLE_INTERRUPTS(clobbers)
> \
> 	PARA_SITE(PARA_PATCH(pv_irq_ops, PV_IRQ_irq_disable), clobbers,
> \
> 		  pushl %eax; pushl %ecx; pushl %edx;
> \
> 		  call *%cs:pv_irq_ops+PV_IRQ_irq_disable;
> \
> 		  popl %edx; popl %ecx; popl %eax)
> \
> 
> 
> 	One of the 1st biggest argument is how to support those ASM IVT
> handler code. Some ideas discussed include:

Although ivt.S has the top priority, but there are other two codes which 
xen paravirtualizes currently.

pal.S:
More specifically ia64_pal_call_static()
Maybe we can go without paravirtualized ia64_pall_call_static().
Since pal static convension is very stable, having implementation 
or each paravirtualization technology might be acceptable because
it won't cause maintenance const much.

entry.S:
The kernel leaving point. This is the counter part of ivt.S.
More concretely ia64_switch_to(), ia64_leave_syscall() and
ia64_leave_kernel(). They require certainly paravirtualization
because they include sensitive instructions and performance critical.
Those functions can't be switched very easily compared to the ivt
case so that some kind of facitilty which switch those or 
binary patching them are necessary.


> 	1: Dual IVT source code, dual IVT table.
> 		This is current Xen did, and probably are not warmly
> welcomed since it is not in upstream yet and have maintenance effort.

Pros:
- Optimal code can be possible for native and each paravirtualized case.
- Doesn't introduce any further restriction on native case.

Cons:
- Ugly and maintenance cost as you already stated.
  

> 	2: Same IVT source code, but dual/mulitple compile to generate
> dual/multiple IVT table. I.e. we replace those primitive ops (sensitive
> instructions) with a MACRO which uses compile option for different
> hypervisor type. 
> 		The pseudo code of the MACRO could be: (take read CR.IVR
> as example)
> 
> AltA:
> #define ASM_READ_IVR	/* read IVR to GR24 */
> #ifdef XEN
> 	breg1 = return address
> 	br    xen_readivr
> #else	/* native
> 	mov  GR24=CR.IVR;
> #endif
> 		Or
> AltB:
> #define ASM_READ_IVR	/* read IVR to GR24 */
> #ifdef XEN
> 	in place code of function xen_readivr
> #else	/* native
> 	mov  GR24=CR.IVR;
> #endif
> 
> 		From maintenance effort point of view, it is minimized,
> but not exactly what X86 pv_ops look like.
> 
> 		Both approach will cause code size issue, but altB is
> much worse in this area, while AltA need one additional BR clobber
> register


Pros:
- single code
- hopefull less maintenance cost compared to #1

Cons:
- requires restriction on register usage. And we need to define its
  convension.
  When modifying ivt.S in the future after converting ivt.S,
  those convesion must be kept in mind.
- suboptimal for paravirtualized case compared to #1 case


> 	3: Single IVT table, using indirect function call for pv_ops.
> 		This is more like X86 pv_ops, but we need to pay 2
> additional BR clobber registers due to indirect function call, like
> following pseudo code:
> 
> AltC:
> 	breg0 = pv_ops base
> 	breg0 += offset for this pv_ops
> 	breg1 = return address;
> 	br  breg0.		/* pv_ops clobbered breg0/breg1 */
> 
> 
> 	For both #2 & #3, we need to modify Linux IVT code to get
> clobber register for those MACROs, #3 need 2 br registers and 1-2 GR
> registers for the function body. #2A needs least clobber register, just
> 1-2 GR registers.

#2B may also need clobber 1(or 2?) GR registers depending on the
original instruction.

Pros:
- single code/binary
- less maintenance cost

Cons:
- requires restriction on register usage. And we need to define its
  convension.
  When modifying ivt.S in the future after converting ivt.S,
  those convesion must be kept in mind.
- more clobbered register (for AltC)
- suboptimal even for native case.

Presumably we can use binary patching technique to mitigate those overhead.
Probably for native case, we can convert those branch with single
instruction.
For example we can make 'br breg0' into direct branch.
AltD(AltC'):
        breg1 = return address;
        br  native_pv_ops_ops   <== binary patch at boot time


> 	In X86, there are another enhancement (dynamic patching) base on
> pv_ops. The purpose is to improve cpu predication by converting indriect
> function call to direct function call for both C & ASM code. We may take
> similar approach some time later too.
> 
> 	We really need advices from community before we jump into
> coding.
> 	CC some active members that I though may be interested in pv_ops
> since KVM-IA64 mailinglist doesn;t exist yet.

The final goal is merging up Xenified Linux/IA64 domU/dom0 code.
I expect that it requires many clean up and abstraction.
The first step is merging domU first and it would requires 
- XenLinux portabiliy clean up
  Those kind of patches can be pused into upstream independently
- cpu instruction paravirtualization
  - assembly code
  - instrinsics
- iosapic paravirtualization(event channel)
- xen irq chip
- and more...

thanks,
-- 
yamahata
