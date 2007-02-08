From: "Bob Picco" <bob.picco@hp.com>
Date: Thu, 08 Feb 2007 11:49:01 +0000
Subject: Re: [2.6.20][PATCH] fix mempolicy error check on a system with memory-less-node
Message-Id: <20070208114901.GA25152@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206202312.4f979bcf.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0702060925130.9812@schroedinger.engr.sgi.com> <20070207101400.feda1bf9.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0702070002430.2188@schroedinger.engr.sgi.com> <20070207173647.86bd64c0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070207173647.86bd64c0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, clameter@engr.sgi.com, akpm@osdl.org, linux-ia64@vger.kernel.org

Hiroyuki KAMEZAWA wrote:	[Wed Feb 07 2007, 03:36:47AM EST]
> On Wed, 7 Feb 2007 00:04:41 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > On Wed, 7 Feb 2007, KAMEZAWA Hiroyuki wrote:
> > 
> > > > Hmmm... Remove the node from the node_online_map instead?
> > > > 
> > > Changing defintion of node_online_map is harmfil. (there are cpu-only-nodes.)
> > > How about adding  nodemask for nodes equips memory ?
> > 
> > Ok that is better but...
> > 
> > Would it be possible to attach the cpus to the 
> > next nodes with memory and mark the node offline? That way we could avoid 
> > another mask that we constantly have to check?
> > 
> Added ia64 list to CC.
> I know ia64 kernel did what you say in old days (I know RHEL4/2.6.9 kernel does it).
> Someone changed it and created cpu-only-node for some purpose, I don't know why.
That was me. It will probably be later today or Friday before I've had
time to review the code.  For reference look for string memory_less in
arch/ia64/mm/discontig.c.

The short story is HP ships NUMA boxes with interleaved memory only by
default which is represented by a single memory only node. Originally all
the CPU nodes where assigned to the memory node. The code was very
complicated and incorrect to me. Subsequently, and what we have now, the CPU
only nodes are revealed and the memory only node too. I do believe that a
cpu only nodes should be possible but now there seems to be a new issue.

bob
> 
> 
> > Or fix the location where the error occurred to be able to tolerate a node 
> > with no zones?
> > 
> Hmm, 
> In this case, MPOL_MBIND, the user requests to allocate memory from specified nodes.
> I think it's better to tell him "you can't do that" than silently allocating memory
> from other places.
> 
> -Kame
> 
> 
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
