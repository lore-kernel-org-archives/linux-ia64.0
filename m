From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 14 May 2004 02:09:56 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <200405131909.56934.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday, May 13, 2004 6:28 pm, Dave Hansen wrote:
> I don't see any real reasons why we can't make I/O only nodes.  I know
> that we've run into and fixed a few situations where a node came up with
> either no cpus or no memory for various reasons before.  Does anybody
> have any philosophical objections to having I/O only nodes?

Well, it's kind of odd conceptually (to me a node implies memory) but SGI has 
such nodes.  They're simply numalink<->pci bridges, and as such are 
individually addressable and have physical NUMA node ids.

> In any case, I'd bet we'll need some form of this eventually.  On my
> hardware,  It's probably possible to hotplug individual CPUs or sections
> of memory in such a way that a node has no online cpus or memory.  So,
> we'll probably have to handle those cases anyway.

Yep, I suppose so.

Jesse
