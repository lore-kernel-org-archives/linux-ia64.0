From: Horms <horms@verge.net.au>
Date: Fri, 30 Jun 2006 03:56:55 +0000
Subject: Re: [PATCH] ia64, kexec: allow base of crashkernel to be auto-discovered
Message-Id: <20060630035652.GA18087@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060628110052.GA11751@verge.net.au>
In-Reply-To: <20060628110052.GA11751@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jun 29, 2006 at 02:51:33PM -0700, Luck, Tony wrote:
> > >   Also it is wrong to put TLB map of RAM that does not exist together
> > > with kernel text and data.
> > 
> > Sorry, I don't understand that.
> 
> Here's an example.  Many systems have (for legacy reasons) mapped
> VGA memory at 0xA0000-0xC0000.  This memory is typically uncacheable
> so that when you write to those addresses the bits show up on the
> screen (rather than sitting in the processor cache for some indeterminate
> amount of time).
> 
> Now if Linux is using a 64MB entry to map the kernel, and the kernel
> has been loaded into the bottom 64M of memory, the mapping for the
> kernel (which has a WB attribute) will overlap the VGA memory (which
> doesn't support WB) ... and so you will most probably machine check
> when someone accesses the VGA (or worse if some speculative access or
> prefetch happens to pull from the VGA area).
> 
> So the rule is that Linux must never create TLB mappings for things
> that don't exist, or for blocks of memory with incompatible attributes.

I might be confused, but I'm not exactly sure that my patch would run
into this problem. It only tries to insert the "Crash kernel" resource
as a sub-resource of an existing "System RAM" resource, and does so in
such a way that it should not overlap with any existing sub-resources.
Surely VGA and the like are in completely different resources not
covered by a "System RAM" resource.

-- 
Horms                                           
H: http://www.vergenet.net/~horms/          W: http://www.valinux.co.jp/en/

