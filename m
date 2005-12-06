From: Andi Kleen <ak@suse.de>
Date: Tue, 06 Dec 2005 17:52:56 +0000
Subject: Re: [PATCH 1/2] Zone reclaim V2
Message-Id: <20051206175256.GO11190@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051206172444.18786.30131.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051206172444.18786.30131.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, ak@suse.de, torvalds@osdl.org

On Tue, Dec 06, 2005 at 09:24:44AM -0800, Christoph Lameter wrote:
> Zone reclaim allows the reclaiming of pages from a zone if the number of free
> pages falls below the watermark even if other zones still have enough pages
> available. Zone reclaim is of particular importance for NUMA machines. It can
> be more beneficial to reclaim a page than taking the performance penalties
> that come with allocating a page on a remote zone.
> 
> The patch replaces Martin Hick's zone reclaim function (which was never
> working properly).
> 
> An arch can control zone_reclaim by setting zone_reclaim_mode during bootup
> if it is discovered that the kernel is running on an NUMA configuration.

Looks much better. Thanks. But how about auto controlling the variable in generic
code based on node_distance() (at least for the non node hotplug case)


> +/*
> + * Zone reclaim mode
> + *
> + * If non-zero call zone_reclaim when the number of free pages falls below
> + * the watermarks.
> + */
> +int zone_reclaim_mode;

I would mark it __read_mostly to avoid potential false sharing.

-Andi
