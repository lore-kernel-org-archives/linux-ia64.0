From: Dean Nelson <dcn@sgi.com>
Date: Wed, 14 Jul 2004 16:04:48 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <20040714160448.GB10539@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 16, 2004 at 05:39:44PM +0100, Christoph Hellwig wrote:
> On Wed, Jun 16, 2004 at 11:33:39AM -0500, Dean Nelson wrote:
> > --- linux.orig/mm/page_alloc.c	Thu Jun 10 14:47:51 2004
> > +++ linux/mm/page_alloc.c	Thu Jun 10 16:31:55 2004
> > @@ -40,6 +40,7 @@ unsigned long totalram_pages;
> >  unsigned long totalhigh_pages;
> >  int nr_swap_pages;
> >  int numnodes = 1;
> > +EXPORT_SYMBOL(numnodes);
> 
> bad idea.  I have patches to completely kill numnodes, don't try to
> mess with it.  So far it's also completly an architecture-thing.

What are you planning to replace numnodes with?

XPC has two functions (xpc_allow_IPI_ops() and xpc_restrict_IPI_ops()) which
need to change the protections governing IPI operations and AMO (memory)
operations for each node in a partition. What mechanism are you proposing
to allow one to iterate through all of the nodes in a partition?

Thanks,
Dean

