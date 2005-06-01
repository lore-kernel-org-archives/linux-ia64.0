From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 01 Jun 2005 18:46:58 +0000
Subject: Re: [PATCH] Periodically drain non local pagesets
Message-Id: <1117651618.13600.16.camel@localhost>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506011047060.9277@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506011047060.9277@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, 2005-06-01 at 10:48 -0700, Christoph Lameter wrote:
> +               struct per_cpu_pageset *pset;
> +
> +               /* Do not drain local pagesets */
> +               if (zone = zone_table[numa_node_id()])
> +                       continue;
> +

It's best to avoid using NUMA-specific data structures, even in #ifdef
NUMA code.  This particular use is incorrect, as the zone_table[] is not
indexed by numa_node_id(), but rather by a combination of the node
number and the zone number (see NODEZONE()).

I'd suggest using something like this:

	if (zone->zone_pgdat->node_id = numa_node_id())

It might be nice to have a zone_node_id() macro that hides this as well.
With a macro like that that #defines to 0 when !CONFIG_NUMA, the #ifdef
around that function could probably go away.  

Also, are you sure that you need the local_irq_en/disable()?  

-- Dave

