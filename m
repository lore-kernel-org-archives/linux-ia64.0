From: "Dong, Eddie" <eddie.dong@intel.com>
Date: Tue, 08 Apr 2008 02:31:20 +0000
Subject: RE: pv_ops progress & ask for suggestion
Message-Id: <10EA09EFD8728347A513008B6B0DA77A0304409F@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A03000059@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A03000059@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
> On Mon, Apr 07, 2008 at 05:47:38PM +0800, Dong, Eddie wrote:
>> Tony & all:
>> 	Recently we have completed the IVT.s pv_ops by using dual
>> compile, and also many cleanups to simplify the changes to upstream
>> code. All the C code touching privilege instruction is replaced with
>> indirect function call (will be binary patched to use direct function
>> call in future), and IVT table is dual compiled to minimize impact to
>> native IVT table, but we get some dilemma in handling kernel/entry.S
>> and also generic policy for other ASM files.
>> 
>> 	In entry.S, there are around 17 privilege instructions, some of
>> them must be paravirtualized including 2 cover instructions, and 1
>> "RFI" (this one is due to Xen hypervisor issue). There are other 15
>> privilege instructions (In Xen) such as CR access that could be
>> paravirtualized for performance reason.
> 
> Probably we can discusse well with the concrete patch.
> So I'll post the patches.
> (Creating the reviewable patch set may take a while though.)

If it is 200 lines of patch, that is perfect. If it is a 2000+ lines of
patch, I prefer a 200 lines of pseudo code.

> 
> 
>> 	Now we have 2 choices:
>> 	Alt1:  Dual compile entry.S like IVT.s (dual compile all ASM
>> files if it needs virtualization)
>> 		pros: Same policy with iVT, use same MACRO to
>> replacement.
>> 		cons: There are other ASM files such as
>> sn/kernel/pio_phys.S need to be dual compiled too.
>> 			And unlike IVT table, the memory occupied by
>> dual compiled code won't be able to be freed easily since the size is
>> not fixed. Also all future ASM code touch privilege instruction may
>> need to be dual compiled too.
> 
> I suppose the more generalized problem is
> - The memory for unused pv code/data won't be executed/referenced
>   so that it can be freed somehow.
>   Is it worth while to do that? And how to do it?

For IVT table (64K) & gate page (1 page), it can be done except
relocating
those IP relative symbols.

> Looking at current xen code size it might be worth while,
> but not so big win.

Agree in some level. Depend on how strictly we want the code to be
perfect.


> This is not ia64 specific issues, and should be addressed
> in arch generic way. This hasn't been addressed even on x86.

X86 doesn't use dual compile.

Eddie
