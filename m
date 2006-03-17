From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Mar 2006 18:03:55 +0000
Subject: Re: [patch] mspec - special memory driver and do_no_pfn handler
Message-Id: <20060317180355.GA8232@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0k6auuy5n.fsf@jaguar.mkp.net> <20060316163728.06f49c00.akpm@osdl.org> <Pine.LNX.4.64.0603161659210.3618@g5.osdl.org> <1142571490.9022.37.camel@localhost.localdomain> <441A7E34.90508@sgi.com> <441AB9A9.2000704@de.ibm.com>
In-Reply-To: <441AB9A9.2000704@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: carsteno@de.ibm.com
Cc: Jes Sorensen <jes@sgi.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, hch@lst.de, Hugh Dickins <hugh@veritas.com>

On Fri, Mar 17, 2006 at 02:29:13PM +0100, Carsten Otte wrote:
> Jes Sorensen wrote:
> > Well then the question is, would it simplify the code using no_pfn in
> > this case? Hacking up fake struct page entries seems even more of a
> > hack to me.
> I second that. That's were we are with our dcss xip thing today.
> It _is_ a hack to have a struct page that you don't need.

The same is true for the SPU support.  The way it's done currently works
which is great, but the way it's done is everything but nice.

