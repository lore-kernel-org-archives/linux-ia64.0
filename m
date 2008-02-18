From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Mon, 18 Feb 2008 15:43:11 +0000
Subject: RE: paravirt_ops support in IA64
Message-Id: <10EA09EFD8728347A513008B6B0DA77A02C82768@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
 
>> 	2: Same IVT source code, but dual/mulitple compile to generate
>> dual/multiple IVT table. I.e. we replace those primitive ops
>> (sensitive instructions) with a MACRO which uses compile option for
>> 		different hypervisor type. The pseudo code of the MACRO
could be:
>> (take read CR.IVR 
>> as example)
>> 
>> AltA:
>> #define ASM_READ_IVR	/* read IVR to GR24 */
>> #ifdef XEN
>> 	breg1 = return address
>> 	br    xen_readivr
>> #else	/* native
>> 	mov  GR24=CR.IVR;
>> #endif
>> 		Or
>> AltB:
>> #define ASM_READ_IVR	/* read IVR to GR24 */
>> #ifdef XEN
>> 	in place code of function xen_readivr
>> #else	/* native
>> 	mov  GR24=CR.IVR;
>> #endif
>> 
>> 		From maintenance effort point of view, it is minimized,
>> but not exactly what X86 pv_ops look like.
>> 
>> 		Both approach will cause code size issue, but altB is
>> much worse in this area, while AltA need one additional BR clobber
>> register
> 
> 
> Pros:
> - single code
> - hopefull less maintenance cost compared to #1
> 
> Cons:
> - requires restriction on register usage. And we need to define its
>   convension.
>   When modifying ivt.S in the future after converting ivt.S,
>   those convesion must be kept in mind.
> - suboptimal for paravirtualized case compared to #1 case
> 
> 
>> 	3: Single IVT table, using indirect function call for pv_ops.
>> 		This is more like X86 pv_ops, but we need to pay 2
>> additional BR clobber registers due to indirect function call, like
>> following pseudo code: 
>> 
>> AltC:
>> 	breg0 = pv_ops base
>> 	breg0 += offset for this pv_ops
>> 	breg1 = return address;
>> 	br  breg0.		/* pv_ops clobbered breg0/breg1 */
>> 
>> 
>> 	For both #2 & #3, we need to modify Linux IVT code to get
>> clobber register for those MACROs, #3 need 2 br registers and 1-2 GR
>> registers for the function body. #2A needs least clobber register,
>> just 1-2 GR registers.
> 
> #2B may also need clobber 1(or 2?) GR registers depending on the
> original instruction.

Yes, clobber GR # is almost same for all Alts.

> 
> Pros:
> - single code/binary
> - less maintenance cost
> 
> Cons:
> - requires restriction on register usage. And we need to define its
>   convension.
>   When modifying ivt.S in the future after converting ivt.S,
>   those convesion must be kept in mind.
> - more clobbered register (for AltC)
> - suboptimal even for native case.

After binary patching, native side won't have impact. 
We can have in place patching, i..e. replace whole AltC
code dynamically with "mov GRx=CR.IVR;nop;nop..."

> 
> Presumably we can use binary patching technique to mitigate those
> overhead. Probably for native case, we can convert those branch with
> single instruction.
> For example we can make 'br breg0' into direct branch.

If it is single IVT table, we don't know the target address of
the function call.

> AltD(AltC'):
>         breg1 = return address;
>         br  native_pv_ops_ops   <== binary patch at boot time
> 

?? Are u talking about AltA?

thanks, Eddie
