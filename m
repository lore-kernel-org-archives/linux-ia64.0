From: jbarnes@sgi.com (Jesse Barnes)
Date: Wed, 25 Feb 2004 16:52:21 +0000
Subject: Re: [Lse-tech] fix zonelist ordering for NUMA
Message-Id: <20040225165221.GA20253@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1077652196.26287.6.camel@arrakis>
In-Reply-To: <1077652196.26287.6.camel@arrakis>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Feb 25, 2004 at 07:59:33PM +0900, j-nomura@ce.jp.nec.com wrote:
> I cleaned up the patch based on the comments from Jesse and Matthew.
> 
> >   1) make it arch independent
> >      this means having arch code populate a SLIT-like table for use by
> >      the generic zonelist building code
> 
> I moved the whole function to mm/page_alloc.c.

Looks even better, that was fast! :)

> >   3) some systems have pgdats w/o any CPUs associated with them, they
> >      need to be dealt with differently than regular nodes, maybe as
> >      extensions to an existing node
> 
> Headless node is prefered over the nodes with same distance.

I'd be curious to hear about others with similar configurations.  On
sn2, we may have multiple headless nodes for each node with CPUs.  In
such a configuration, it seems best to have each node with CPUs 'own' a
set of headless nodes, and allocate from them even if they're further
away than other nodes with CPUs.  I don't think we have to worry about
that too much now though, since the algorithm below could be tweaked to
do just that easier than the simple sort code I did awhile back.

> >   2) handle the cases that Erich talked about a bit better
> 
> Any idea for doing it in generic way?

We could adjust 'val' below based on an array that weights each node as
it's added to a zonelist.  I think that would be up to the caller of
find_next_best_node() to adjust, but would be used in the routine below.
Doing it that way would allow the balancing that Erich was talking about
as well as the headless node stuff we want for sn2.

Thanks,
Jesse
