From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 16 Jun 2004 17:20:25 +0000
Subject: Re: [PATCH 1/4] SGI Altix cross partition functionality
Message-Id: <200406161320.25204.jbarnes@engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040616163339.GA27891@sgi.com>
In-Reply-To: <20040616163339.GA27891@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday, June 16, 2004 12:39 pm, Christoph Hellwig wrote:
> >  cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
> > +EXPORT_SYMBOL(node_to_cpu_mask);
>
> Isn't there a higher level interface for this?

Yeah, but node_to_cpumask() is just a wrapper around this array.

Jesse
