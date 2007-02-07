From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 07 Feb 2007 08:36:47 +0000
Subject: Re: [2.6.20][PATCH] fix mempolicy error check on a system with
Message-Id: <20070207173647.86bd64c0.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070206202312.4f979bcf.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0702060925130.9812@schroedinger.engr.sgi.com>
	<20070207101400.feda1bf9.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0702070002430.2188@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702070002430.2188@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, clameter@engr.sgi.com, akpm@osdl.org, linux-ia64@vger.kernel.org

On Wed, 7 Feb 2007 00:04:41 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:

> On Wed, 7 Feb 2007, KAMEZAWA Hiroyuki wrote:
> 
> > > Hmmm... Remove the node from the node_online_map instead?
> > > 
> > Changing defintion of node_online_map is harmfil. (there are cpu-only-nodes.)
> > How about adding  nodemask for nodes equips memory ?
> 
> Ok that is better but...
> 
> Would it be possible to attach the cpus to the 
> next nodes with memory and mark the node offline? That way we could avoid 
> another mask that we constantly have to check?
> 
Added ia64 list to CC.
I know ia64 kernel did what you say in old days (I know RHEL4/2.6.9 kernel does it).
Someone changed it and created cpu-only-node for some purpose, I don't know why.


> Or fix the location where the error occurred to be able to tolerate a node 
> with no zones?
> 
Hmm, 
In this case, MPOL_MBIND, the user requests to allocate memory from specified nodes.
I think it's better to tell him "you can't do that" than silently allocating memory
from other places.

-Kame





