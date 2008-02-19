From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 19 Feb 2008 00:13:46 +0000
Subject: Re: paravirt_ops support in IA64
Message-Id: <32163.1203380026@ocs10w>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080218113116.GD8023%yamahata@valinux.co.jp>
In-Reply-To: Your message of "Mon, 18 Feb 2008 20:31:16 +0900."
	<20080218113116.GD8023%yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: Jack Steiner <steiner@sgi.com>, linux-ia64@vger.kernel.org, "Dong,
	Eddie" <eddie.dong@intel.com>, virtualization@lists.linux-foundation.org, Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, "Zhang,
	Xiantao" <xiantao.zhang@intel.com>, xen-ia64-devel <xen-ia64-devel@lists.xensource.com>

Isaku Yamahata (on Mon, 18 Feb 2008 20:31:16 +0900) wrote:
>On Mon, Feb 18, 2008 at 11:28:41AM +0800, Dong, Eddie wrote:
>> 	2: Same IVT source code, but dual/mulitple compile to generate
>> dual/multiple IVT table. I.e. we replace those primitive ops (sensitive
>> instructions) with a MACRO which uses compile option for different
>> hypervisor type. 
>> 		The pseudo code of the MACRO could be: (take read CR.IVR
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
>Pros:
>- single code
>- hopefull less maintenance cost compared to #1
>
>Cons:
>- requires restriction on register usage. And we need to define its
>  convension.
>  When modifying ivt.S in the future after converting ivt.S,
>  those convesion must be kept in mind.
>- suboptimal for paravirtualized case compared to #1 case

Please, please, please do _NOT_ hide register numbers inside small
macros like this.  It makes it far too easy to miss register side
effects when looking at IA64 assembler code.  Instead make the register
usage a parameter to the macro, so a human looking at the source code
can see which registers are being used.  The macros in
include/asm-ia64/mca_asm.h are good examples of this approach.  IOW

#define ASM_READ_IVR(breg, greg) ... move greg=cr.ivr

	ASM_READ_IVR(breg1, gr24)	# make it obvious which registers are hit

For large macros like SAVE_ALL there is no choice but to hide register
side effects inside the macro, but that should be the exception, not
the rule.

