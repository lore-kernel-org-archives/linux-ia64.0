From: Andrew Morton <akpm@osdl.org>
Date: Sat, 28 Aug 2004 01:39:40 +0000
Subject: Re: page fault scalability patch final : i386 tested, x86_64
Message-Id: <20040827183940.33b38bc2.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0408151924250.4480@schroedinger.engr.sgi.com>
	<20040816143903.GY11200@holomorphy.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B679F@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67A9@mtv-atc-605e--n.corp.sgi.com>
	<B6E8046E1E28D34EB815A11AC8CA3129027B67B4@mtv-atc-605e--n.corp.sgi.com>
	<Pine.LNX.4.58.0408271616001.14712@schroedinger.engr.sgi.com>
	<20040827233602.GB1024@wotan.suse.de>
	<Pine.LNX.4.58.0408271717400.15597@schroedinger.engr.sgi.com>
	<20040827172337.638275c3.davem@davemloft.net>
	<20040827173641.5cfb79f6.akpm@osdl.org>
	<20040828010253.GA50329@muc.de>
In-Reply-To: <20040828010253.GA50329@muc.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@muc.de>
Cc: davem@davemloft.net, clameter@sgi.com, ak@suse.de, wli@holomorphy.com, davem@redhat.com, raybry@sgi.com, benh@kernel.crashing.org, manfred@colorfullife.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, vrajesh@umich.edu, hugh@veritas.com

Andi Kleen <ak@muc.de> wrote:
>
> > When can we reasonably expect someone to blow this out of the water? 
>  > Within the next couple of years, I suspect?
> 
>  With 4 level page tables x86-64 will support 47 bits virtual theoretical.
>  They cannot be used right now because the current x86-64 CPUs have
>  40 bits physical max and it is currently even hardcoded to 40bits,
>  but I planned to drop that in the 4 level patch (in fact I already did) 
>  so that the kernel will in theory support CPUs will more physical memory.
> 

hm.  What's the maximum virtual size on power5?

>  > It does look like we need a new type which is atomic64 on 64-bit and
>  > atomic32 on 32-bit.  That could be used to fix the
>  > mmaping-the-same-page-4G-times-kills-the-kernel bug too.
> 
>  Yep.  Good plan. atomic_long_t ? 

Sounds good.  Converting page->_count should be fairly straightforward now
too, as it's all done via wrappers.

>  > 
>  > > and this limit actually
>  > > mostly comes from the 3-level page table limits.
>  > 
>  > This reminds me - where's that 4-level pagetable patch got to?
> 
>  It exists on my HD, but is not really finished yet.
> 
>  I was on vacation and travelling and had some other things to do, so it got 
>  delayed a bit, but I hope to work on it soon again.

OK, thanks.  There's no rush on this one.
