From: Matthew Dobson <colpatch@us.ibm.com>
Date: Tue, 09 Nov 2004 23:58:44 +0000
Subject: Re: Externalize SLIT table
Message-Id: <1100044724.3980.23.camel@arrakis>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041103205655.GA5084@sgi.com>
	 <20041104.105908.18574694.t-kochi@bq.jp.nec.com>
	 <20041104141337.GA18445@sgi.com>  <200411041631.42627.efocht@hpce.nec.com>
	 <1100029381.3980.12.camel@arrakis>
	 <Pine.LNX.4.61.0411100722070.14545@woolami.melbourne.sgi.com>
In-Reply-To: <Pine.LNX.4.61.0411100722070.14545@woolami.melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mark Goodwin <markgw@sgi.com>
Cc: Erich Focht <efocht@hpce.nec.com>, Jack Steiner <steiner@sgi.com>, Takayoshi Kochi <t-kochi@bq.jp.nec.com>, linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 2004-11-09 at 12:34, Mark Goodwin wrote:
> On Tue, 9 Nov 2004, Matthew Dobson wrote:
> > ...
> > I don't think we should export the *exact same* node distance information
> > through the CPUs, though.
> 
> We should still export cpu distances though because the distance between
> cpus on the same node may not be equal. e.g. consider a node with multiple
> cpu sockets, each socket with a hyperthreaded (or dual core) cpu.

Well, I'm not sure that just because a CPU has two hyperthread units in
the same core that those HT units have a different distance or latency
to memory...?  The fact that it is a HT unit and not a physical core has
implications to the scheduler, but I thought that the 2 siblings looked
identical to userspace, no?  If 2 CPUs in the same node are on the same
bus, then in all likelihood they have the same "distance".


> Once again however, it depends on the definition of distance. For nodes,
> we've established it's the ACPI SLIT (relative distance to memory). For
> cpus, should it be distance to memory? Distance to cache? Registers? Or
> what?
> 
> -- Mark

That's the real issue.  We need to agree upon a meaningful definition of
CPU-to-CPU "distance".  As Jesse mentioned in a follow-up, we can all
agree on what Node-to-Node "distance" means, but there doesn't appear to
be much consensus on what CPU "distance" means.

-Matt

