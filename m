From: Matthew Wilcox <matthew@wil.cx>
Date: Mon, 01 Nov 2004 17:16:49 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <20041101171649.GT8958@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 01, 2004 at 09:07:32AM -0800, Jesse Barnes wrote:
> If I understand you right, you don't want a top level domain for your 32 way 
> systems, but you *do* want the node domains to span the whole thing.  Is that 
> right?
> 
> If so, you could do something like this I think?
> 
>  if (numnodes <= SMALL_SYSTEM_THRESHOLD) {
>   SD_NODES_PER_DOMAIN = numnodes;
>   build_node_domains(); /* each one spans the system */
>  } else {
>   SD_NODES_PER_DOMAIN = 4; /* or whatever */
>   build_node_domains(); /* only spans nearby nodes */
>   build_top_level_domain(); /* whole system, infrequently balanced */
>  }
> 
> Would that address your concerns?

Doesn't sound like a great idea.  HP's already shipping 128-way Superdome
IA-64 systems, and they'll want to be set up rather differently from the
Altix systems.  I think this code needs to be autotuning so it doesn't
need to be touched whenever a vendor releases a new configuration (I
think I heard that NASA's Altixes had a custom CPU brick with twice the
CPUs in it?)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
