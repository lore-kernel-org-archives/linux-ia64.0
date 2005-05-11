From: Christoph Lameter <clameter@engr.sgi.com>
Date: Wed, 11 May 2005 15:49:24 +0000
Subject: Re: [RFC] pcibus_to_node implementation for ia64
Message-Id: <Pine.LNX.4.58.0505110847190.22833@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0505051707220.6114@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 11 May 2005, colin ngam wrote:

> >That's certainly another way to go--just make the function do a search
> >to find the closest node with memory (and/or CPUs) all by itself.  The
> >obvious disadvantage is that you'll incur that cost on every function
> >call unless you build a lookup table at boot time or somesuch.

This search is performed by alloc_pages using the zonelists.

> How often do you do this to worry about latency?

Currently pcibus_to_node is only used during device initialization to
allocate the control structures on a node.


> >That's where things get confusing, since 'node' is an overloaded term
> >here.  It does *not* return a node that you can pass into
> >alloc_pages_node for instance, which I think is what Christoph wants.
> >It does, however, return a node id in the cnodeid sense, but one that
> >could be useless in most parts of the kernel.
> >
> >
> Exactly.

How do I get a node that I can pass to alloc_pages_node?

