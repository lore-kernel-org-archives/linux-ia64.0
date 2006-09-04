From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 04 Sep 2006 17:39:43 +0000
Subject: Re: NODE_DATA without CONFIG_NUMA
Message-Id: <Pine.LNX.4.64.0609041037230.29229@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060904062323.GA9293@verge.net.au>
In-Reply-To: <20060904062323.GA9293@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 4 Sep 2006, Jes Sorensen wrote:

> Christoph Lameter wrote:
> > On Mon, 4 Sep 2006, Jes Sorensen wrote:
> > 
> > > I haven't looked at the details, given you don't say where it breaks,
> > > but it would make sense to me that a non-NUMA system is treated as a
> > > single node system, eg. NODE_DATA(0) ought to be valid.
> > 
> > NODE_DATA should always be available. The problem is likely due to DISCONTIG
> > being associatiated tightly with NUMA.
> 
> But DISCONTIG will probably go away at some point, so maybe it's time to
> disentangle that?

I think we should fix the bug.

Disentangle is good but we cannot get rid of DISCONTIG since SPARSEMEM so 
far does not match DISCONTIG performance since it does not support 
virtual mem_map. See the recent discussion in regards to virt_to_page().

