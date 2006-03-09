From: Robin Holt <holt@sgi.com>
Date: Thu, 09 Mar 2006 16:12:47 +0000
Subject: Re: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <20060309161247.GA26604@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 08, 2006 at 04:55:45PM -0700, Bjorn Helgaas wrote:
> On Wednesday 08 March 2006 15:02, Dean Roe wrote:
> > On Mon, Mar 06, 2006 at 10:35:19AM -0700, Bjorn Helgaas wrote:
> > > On Monday 06 March 2006 09:32, Dean Roe wrote:
> > > > -	for_each_node(cnode) {
> > > > +	/*
> > > > +	 * FIXME: replace with cleaner for_each_XXX macro which addresses
> > > > +	 * both compute and IO nodes once ACPI3.0 is available.
> > > > +	 */
> > > > +	for (cnode = 0; cnode < num_cnodes; cnode++) {
> > > 
> > > I don't understand this ACPI 3.0 dependency.  Can't you just define
> > > for_each_XXX() the way you want it, and fill in the bitmask or whatever
> > > it uses either (a) using ACPI 3.0 data, or (b) some interim hack?
> > > 
> > > Bjorn
> > 
> > I can't really tell from your response, so...did you see Jack's explanation
> > of this?
> >     http://marc.theaimsgroup.com/?l=linux-ia64&m4141537904761&w=2
> > 
> > Are you saying you *really* want a for_each_sn_cnode() macro?  I guess
> > we can go that route if necessary...I just prefer the one-line change
> > rather than changing 4-5 files when we aren't really sure yet what the
> > final implementation will look like.
> 
> I saw his response, but it wasn't clear to me what ACPI 3.0 is going
> to solve.  Are you saying that with ACPI 3.0, you will be able to
> use for_each_node()?

The node informatoin is stored in a single byte.  With the introduction
of I/O only nodes, we can easily exceed the 512 node limit placed on
the byte size.  ACPI 3.0 should raise that node limit to at least a
16-bit word.

> 
> If that's the case, my question is, why can't you use for_each_node()
> today, and use some interim hack to fill in node_possible_map?

The node field size does not allow for it.

> If not, what "for_each_XXX" macro are you planning to use when
> you have ACPI 3.0?

Not sure yet because ACPI 3.0 is still way off in the future.  We
will know more when that time comes.

Robin
