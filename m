From: Ingo Molnar <mingo@elte.hu>
Date: Fri, 20 Aug 2004 08:06:21 +0000
Subject: Re: [PATCH] add scheduler domains for ia64
Message-Id: <20040820080621.GA2310@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <200408131108.40502.jbarnes@engr.sgi.com> <200408171657.32357.jbarnes@engr.sgi.com> <41255DBA.3030909@yahoo.com.au> <200408192222.35512.jbarnes@engr.sgi.com>
In-Reply-To: <200408192222.35512.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, John Hawkes <hawkes@sgi.com>


* Jesse Barnes <jbarnes@engr.sgi.com> wrote:

> This patch adds some more NUMA specific logic to the creation of
> scheduler domains.  Domains spanning all CPUs in a large system are
> too large to schedule across efficiently, leading to livelocks and
> inordinate amounts of time being spent in scheduler routines.  With
> this patch applied, the node scheduling domains for NUMA platforms
> will only contain a specified number of nearby CPUs, based on the
> value of SD_NODES_PER_DOMAIN.  It also allows arches to override
> SD_NODE_INIT, which sets the domain scheduling parameters for each
> node's domain.  This is necessary especially for large systems.

looks good to me too.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

	Ingo
