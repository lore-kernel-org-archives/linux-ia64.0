From: Andi Kleen <ak@suse.de>
Date: Tue, 06 Dec 2005 18:09:20 +0000
Subject: Re: [PATCH 1/2] Zone reclaim V2
Message-Id: <20051206180920.GR11190@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051206172444.18786.30131.sendpatchset@schroedinger.engr.sgi.com> <20051206175256.GO11190@wotan.suse.de> <Pine.LNX.4.62.0512060957160.18975@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0512060957160.18975@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org

On Tue, Dec 06, 2005 at 10:01:28AM -0800, Christoph Lameter wrote:
> On Tue, 6 Dec 2005, Andi Kleen wrote:
> 
> > > An arch can control zone_reclaim by setting zone_reclaim_mode during bootup
> > > if it is discovered that the kernel is running on an NUMA configuration.
> > 
> > Looks much better. Thanks. But how about auto controlling the variable in generic
> > code based on node_distance() (at least for the non node hotplug case)
> 
> Any suggestions on how to determine zone reclaim behavior based on node 
> distances? AFAIK the main aspects in this are latency and bandwidth of 
> remote accesses. These vary depending on the distance of the remote node 
> under consideration.

I would enable it if distance for any combination of online (or possible?) nodes is 
> LOCAL_DISTANCE. I guess hotplug can be ignored for now.

If an architecture really needs something better it can be still refined. But there aren't 
that many NUMA architectures anyways, so it shouldn't be a big issue. 

It will actually need some tweaking on Opterons because many BIOS just
report 10 everywhere in SLIT and it should be still enabled, but that can be done 
in the architecture then.

-Andi

