From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 08 Apr 2008 02:17:50 +0000
Subject: Re: pv_ops progress & ask for suggestion
Message-Id: <20080408021750.GD27760%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A03000059@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A03000059@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Apr 07, 2008 at 05:47:38PM +0800, Dong, Eddie wrote:
> Tony & all:
> 	Recently we have completed the IVT.s pv_ops by using dual
> compile, and also many cleanups to simplify the changes to upstream
> code. All the C code touching privilege instruction is replaced with
> indirect function call (will be binary patched to use direct function
> call in future), and IVT table is dual compiled to minimize impact to
> native IVT table, but we get some dilemma in handling kernel/entry.S and
> also generic policy for other ASM files.
> 
> 	In entry.S, there are around 17 privilege instructions, some of
> them must be paravirtualized including 2 cover instructions, and 1 "RFI"
> (this one is due to Xen hypervisor issue). There are other 15 privilege
> instructions (In Xen) such as CR access that could be paravirtualized
> for performance reason.

Probably we can discusse well with the concrete patch.
So I'll post the patches. 
(Creating the reviewable patch set may take a while though.)


> 	Now we have 2 choices:
> 	Alt1:  Dual compile entry.S like IVT.s (dual compile all ASM
> files if it needs virtualization)
> 		pros: Same policy with iVT, use same MACRO to
> replacement.
> 		cons: There are other ASM files such as
> sn/kernel/pio_phys.S need to be dual compiled too.
> 			And unlike IVT table, the memory occupied by
> dual compiled code won't be able to be freed easily since the size is
> not fixed. Also all future ASM code touch privilege instruction may need
> to be dual compiled too.

I suppose the more generalized problem is
- The memory for unused pv code/data won't be executed/referenced
  so that it can be freed somehow.
  Is it worth while to do that? And how to do it?
Looking at current xen code size it might be worth while,
but not so big win.
This is not ia64 specific issues, and should be addressed
in arch generic way. This hasn't been addressed even on x86.
Presumably it can be implemented by introducing sepcial sections like
pv.{native, xen, ...}.{text, data, ...} with linker trick.


> 	Alt2: Use indirect call like C code for non IVT nor gate page
> code (dual compile only for IVT & gate page which has fixed size and
> performance killer)
> 		Pros: flexible for future ASM code (just use same MACRO,
> no dual compile requirement).
> 		Cons: 2 sets of solution for ASM code, and also slightly
> performance lose due to indirect function call (future patching will
> convert it to direct function call, or in place code.)
> 		
> 
> 	Any suggestions?
> 
> 	Thanks, eddie

-- 
yamahata
