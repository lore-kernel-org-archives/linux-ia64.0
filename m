From: Christoph Lameter <clameter@engr.sgi.com>
Date: Tue, 06 Dec 2005 18:01:28 +0000
Subject: Re: [PATCH 1/2] Zone reclaim V2
Message-Id: <Pine.LNX.4.62.0512060957160.18975@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051206172444.18786.30131.sendpatchset@schroedinger.engr.sgi.com>
 <20051206175256.GO11190@wotan.suse.de>
In-Reply-To: <20051206175256.GO11190@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, torvalds@osdl.org

On Tue, 6 Dec 2005, Andi Kleen wrote:

> > An arch can control zone_reclaim by setting zone_reclaim_mode during bootup
> > if it is discovered that the kernel is running on an NUMA configuration.
> 
> Looks much better. Thanks. But how about auto controlling the variable in generic
> code based on node_distance() (at least for the non node hotplug case)

Any suggestions on how to determine zone reclaim behavior based on node 
distances? AFAIK the main aspects in this are latency and bandwidth of 
remote accesses. These vary depending on the distance of the remote node 
under consideration.

> > +int zone_reclaim_mode;
> 
> I would mark it __read_mostly to avoid potential false sharing.

Ok.
