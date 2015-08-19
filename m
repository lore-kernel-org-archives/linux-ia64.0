From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 19 Aug 2015 23:52:33 +0000
Subject: Re: provide more common DMA API functions V2
Message-Id: <20150820095233.30bb9689@canb.auug.org.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439795216-32189-1-git-send-email-hch@lst.de>
        <20150817142429.95a3965e0b35d0f35d3c4cfe@linux-foundation.org>
        <20150818053825.GA20771@lst.de>
        <20150817224552.43d7267d.akpm@linux-foundation.org>
        <20150818075107.GA31884@gmail.com>
        <20150819080814.GA18115@lst.de>
        <20150819143656.3a38eb538ffac60386e1224a@linux-foundation.org>
In-Reply-To: <20150819143656.3a38eb538ffac60386e1224a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Ingo Molnar <mingo@kernel.org>, arnd@arndb.de, linux@arm.linux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, ysato@users.sourceforge.jp, monstr@monstr.eu, jonas@southpole.se, cmetcalf@ezchip.com, gxt@mprc.pku.edu.cn, x86@kernel.org, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew (sorry, I can't tell who made the incorrect statement below
that I am replying to),

On Wed, 19 Aug 2015 14:36:56 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 19 Aug 2015 10:08:14 +0200 Christoph Hellwig <hch@lst.de> wrote:
> 
> > On Tue, Aug 18, 2015 at 09:51:07AM +0200, Ingo Molnar wrote:
> > > I.e. shouldn't this be:
> > > 
> > > > I'll merge these 5 patches for 4.4.  That means I'll release them into 
> > > > linux-next after 4.2 is released.
> > > >
> > > > [...]
> > > > 
> > > > Linus will be releasing 4.2 in 1-2 weeks and until then, linux-next is supposed 
> > > > to contain only 4.3 material.  Once 4.2 is released and the 4.3 merge window 
> > > > opens, linux-next is open for 4.4 material.

Just to be clear: the above should read "Once 4.2 is released and the
4.3 merge window *closes* (i.e. v4.3-rc1 is released), linux-next is
open for 4.4 material".

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
