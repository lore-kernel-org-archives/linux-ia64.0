From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sat, 26 Jun 2004 05:48:26 +0000
Subject: RE: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406260546.i5Q5ktY03168@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David Mosberger wrote on Friday, June 25, 2004 10:29 PM
>
>   Ken> The relocation of r16 is incorrect.  For BP, we are not installing any
>   Ken> region 7 TLB mapping.
>
> Indeed!  I must be missing something though: with your patch, r13 will
> be initialized to the region 7 address again, which defeats the
> purpose of the original patch.  I think the initialization of r13
> needs to be conditional on whether we're dealing with init_task or
> anything else.

Not sure what you mean.  The first two hunks are trying to revert the
change in rev 1.24 and r16 initialization, which gets put into kr(stack)
later. I'm not touching r13.

>   Ken> As explained earlier, BP did a call to efi_call_phys which
>   Ken> switches to physical mode and then back to virtual.  When going
>   Ken> back to virtual, it converts ar.bspstore and sp to region 7
>   Ken> address.  After that, any heavy weight fault will lead into
>   Ken> nested fault because there are no region 7 dtlb mapping for its
>   Ken> stack.  The fix is to special case ia64_switch_mode_virt to
>   Ken> compute ar.bspstore and sp's virtual addresses into region 5.
>
> True, but it's really ugly to add more special cases.  Wouldn't it be
> better to explicitly pass the sp/bsp that need to be restored?
> (Caveat: can't use the normal calling conventions there; perhaps r17
> and r18 could be used?)

Yeah, but we have to update all the call sites, current efi_call_phys
and two other PAL static/stacked calls.


