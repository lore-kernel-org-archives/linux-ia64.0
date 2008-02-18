From: Robin Holt <holt@sgi.com>
Date: Mon, 18 Feb 2008 11:54:34 +0000
Subject: Re: paravirt_ops support in IA64
Message-Id: <20080218115434.GC11391@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
In-Reply-To: <10EA09EFD8728347A513008B6B0DA77A02C8234B@pdsmsx411.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Feb 18, 2008 at 11:52:30AM +0800, Zhang, Xiantao wrote:
> Dong, Eddie wrote:
> > 
> > 	In X86, there are another enhancement (dynamic patching) base on
> > pv_ops. The purpose is to improve cpu predication by converting
> > indriect function call to direct function call for both C & ASM code.
> > We may take similar approach some time later too.   
> > 
> > 	We really need advices from community before we jump into
> coding.
> > 	CC some active members that I though may be interested in pv_ops
> > since KVM-IA64 mailinglist doesn;t exist yet. 
> 
> Hi, Eddie
> 
> we just created the kvm-ia64-devel mailing list, and cc to the guys from
> this list who maybe interested in this topic. 
> If you or other guys who are interested in kvm-ia64-devel or pv_virt_ops
> for ia64, please subscribe it here

Can we please keep the discussion about changes to arch/ia64 core
functionality on this list and not move it elsewhere.  This list is low
enough volume and the contributors to the discussion will be consistent
enough that most non-interested people will ignore things.  The other
changes related to virtualization specific to ia64 are fine in that
forum, but if you are changing ivt.S, entry.S, etc, IMHO, those should
be discussed here.  Also, could you repost the patches?

On a different note, I am willingly and woefully unaware of what the
paravirt _NEEDS_ are.  Could those be summarised as well?  I will
admit to being completely ignorant about how paravirt works on x86.
Please don't state them in terms of we want to change the code this way,
but rather in terms of we need to intercept these points in the kernel
for this reason/purpose.

Thanks,
Robin
