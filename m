From: "Van Maren, Kevin" <kevin.vanmaren@unisys.com>
Date: Mon, 10 Nov 2003 17:38:34 +0000
Subject: RE: discontig patch question
Message-Id: <marc-linux-ia64-106848594127249@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106847971018555@msgid-missing>
In-Reply-To: <marc-linux-ia64-106847971018555@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> From: Jesse Barnes [mailto:jbarnes@sgi.com]
> 
> On Mon, Nov 10, 2003 at 09:52:49AM -0600, Van Maren, Kevin wrote:
> > The EFI memory map is simple, and looks like:
> >  0- 4G Node 0 (2G + 2G hole)
> >  4- 8G Node 1
> >  8-12G Node 2
> > 12-16G Node 3
> > 16-20G Node 0 (2 G memory-map I/O reclaim)
> > with 4G per node, 16GB total.
> > 
> > Because of ORDERROUNDDOWN in count_pages (arch/ia64/mm/init.c),
> > the memory ended up being assigned like this:
> > 
> >  0- 8G Node 1 (6G, 2GB hole)
> >  8-16G Node 3 (8G)
> > 16-20G Node 0 (2G)
> >        Node 2 (0G)
> > 
> > Which was not at all what I wanted.
> 
> I guess I didn't see this because the nodes on sn2 are so 
> large (64GB).

I've never run with so little memory before either :-(

> > ORDERROUNDDOWN causes the kernel to assign all memory starting at the
> > (PAGE_SIZE << MAX_ORDER) boundary to the current node, which in my case
> > is 16KB << 19 (hard-coded for IA64), or 8GB.
> 
> I wonder if that shouldn't be simply 1UL<<MAX_ORDER...  
> That's all that
> mm/page_alloc.c seems to care about.

But doesn't it deal with page-sized chunks?

It makes sense if all the memory chunks have to start on a "MAX_ORDER"
boundary, but is that really the case?  That's pretty restrictive, at least
with such a large MAX_ORDER.

Why is MAX_ORDER 19 on IA64?

> > I understand the GRANULE rounding, but is there a compelling reason that
> > we need 8GB node chunks on IA64 Linux (with 16KB pages)?
>
> I don't think so.

Thanks,
Kevin
