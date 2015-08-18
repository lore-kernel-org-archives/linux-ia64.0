From: Ingo Molnar <mingo@kernel.org>
Date: Tue, 18 Aug 2015 07:51:07 +0000
Subject: Re: provide more common DMA API functions V2
Message-Id: <20150818075107.GA31884@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439795216-32189-1-git-send-email-hch@lst.de>
 <20150817142429.95a3965e0b35d0f35d3c4cfe@linux-foundation.org>
 <20150818053825.GA20771@lst.de>
 <20150817224552.43d7267d.akpm@linux-foundation.org>
In-Reply-To: <20150817224552.43d7267d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 18 Aug 2015 07:38:25 +0200 Christoph Hellwig <hch@lst.de> wrote:
> 
> > On Mon, Aug 17, 2015 at 02:24:29PM -0700, Andrew Morton wrote:
> > > 110254 bytes saved, shrinking the kernel by a whopping 0.17%. 
> > > Thoughts?
> > 
> > Sounds fine to me.
> 
> OK, I'll clean it up a bit, check that each uninlining actually makes
> sense and then I'll see how it goes.
> 
> > > 
> > > I'll merge these 5 patches for 4.3.  That means I'll release them into
> > > linux-next after 4.2 is released.
> > 
> > So you only add for-4.3 code to -next after 4.2 is odd?  Isn't thast the
> > wrong way around?
> 
> Linus will be releasing 4.2 in 1-2 weeks and until then, linux-next is
> supposed to contain only 4.2 material.  Once 4.2 is released,
> linux-next is open for 4.3 material.

Isn't that off by one?

I.e. shouldn't this be:

> I'll merge these 5 patches for 4.4.  That means I'll release them into 
> linux-next after 4.2 is released.
>
> [...]
> 
> Linus will be releasing 4.2 in 1-2 weeks and until then, linux-next is supposed 
> to contain only 4.3 material.  Once 4.2 is released and the 4.3 merge window 
> opens, linux-next is open for 4.4 material.

?

Thanks,

	Ingo
