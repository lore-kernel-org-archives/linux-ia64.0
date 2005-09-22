From: Bob Picco <bob.picco@hp.com>
Date: Thu, 22 Sep 2005 18:47:23 +0000
Subject: Re: [Lhms-devel] [PATCH 4/4] V4 ia64 SPARSEMEM - SPARSEMEM code changes
Message-Id: <20050922184723.GE16066@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1127406976.10664.52.camel@localhost>
In-Reply-To: <1127406976.10664.52.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dave Hansen wrote:	[Thu Sep 22 2005, 02:05:07PM EDT]
> On Thu, 2005-09-22 at 13:59 -0400, Bob Picco wrote:
> > > > +#ifdef CONFIG_VIRTUAL_MEM_MAP
> > > >             NODE_DATA(node)->node_mem_map = vmem_map + pfn_offset;
> > > > +#endif
> > > 
> > > Is CONFIG_FLAT_NODE_MEM_MAP more appropriate here?  That's how
> > > ->node_mem_map is #ifdef'd to begin with in mmzone.h.
> >
> > Well I think this is doable but probaably shouldn't. This code is very
> > specific to CONFIG_VIRTUAL_MEM_MAP.
> 
> FLAT_NODE_MEM_MAP depends on only !SPARSEMEM, as does VIRTUAL_MEM_MAP.
> So, I guess they're functionally equivalent right now.  It might be most
> nice to at least add a comment, saying that it actually depends on both.
> 
> 
> 
> -- Dave
> 
Okay. I'll add a comment before VIRTUAL_MEM_MAP in Kconfig file. That will
cover all uses of VIRTUAL_MEM_MAP.

thanks,

bob
