From: Keiichiro Tokunaga <tokunaga.keiich@jp.fujitsu.com>
Date: Fri, 14 May 2004 03:02:07 +0000
Subject: Re: [Lhns-devel] Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040514120207.49964fcf.tokunaga.keiich@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040513150842.22F5.YGOTO@us.fujitsu.com>
In-Reply-To: <20040513150842.22F5.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 13 May 2004 18:28:37 -0700
Dave Hansen <haveblue@us.ibm.com> wrote:

> On Thu, 2004-05-13 at 18:14, Keiichiro Tokunaga wrote:
> > On Wed, 12 May 2004 23:50:58 -0700 Dave Hansen <haveblue@us.ibm.com> wrote:
> > > Why not?  We already export the information about which PCI busses are
> > > attached to which NUMA nodes.  How are I/O devices different from CPU or
> > > memory?  
> > 
> > I have just one concern.
> > How about a container device that contains IO devices only?
> >   - Does it count as a NUMA node?
> >   - Is it having a NUMA node ID?
> 
> I don't see any real reasons why we can't make I/O only nodes.  I know
> that we've run into and fixed a few situations where a node came up with
> either no cpus or no memory for various reasons before.  Does anybody
> have any philosophical objections to having I/O only nodes?

I'm afraid I didn't know that the issue had discussed.  I just
wondered if it's possible or not.  It was more like a question
and I don't have any objection to having I/O only nodes.  Can
you direct me to the discussion so that I could follow you :)?

Thanks,
Kei
