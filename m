From: Jack Steiner <steiner@sgi.com>
Date: Fri, 10 Mar 2006 17:57:28 +0000
Subject: Re: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <20060310175728.GA18011@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Mar 09, 2006 at 10:57:09AM -0700, Bjorn Helgaas wrote:
> On Thursday 09 March 2006 09:12, Robin Holt wrote:
> > On Wed, Mar 08, 2006 at 04:55:45PM -0700, Bjorn Helgaas wrote:
> > > On Wednesday 08 March 2006 15:02, Dean Roe wrote:
> > > > Are you saying you *really* want a for_each_sn_cnode() macro?  I guess
> > > > we can go that route if necessary...I just prefer the one-line change
> > > > rather than changing 4-5 files when we aren't really sure yet what the
> > > > final implementation will look like.
> > > 
> > > I saw his response, but it wasn't clear to me what ACPI 3.0 is going
> > > to solve.  Are you saying that with ACPI 3.0, you will be able to
> > > use for_each_node()?
> > 
> > The node informatoin is stored in a single byte.  With the introduction
> > of I/O only nodes, we can easily exceed the 512 node limit placed on
> > the byte size.  ACPI 3.0 should raise that node limit to at least a
> > 16-bit word.
> 
> I'm only trying to point out that you should be able to separate the
> for_each_XXX() interface from the current ACPI limit.
> 
> > > If that's the case, my question is, why can't you use for_each_node()
> > > today, and use some interim hack to fill in node_possible_map?
> > 
> > The node field size does not allow for it.
> 
> Which node field doesn't allow it?  for_each_node() uses the
> node_possible_mask bitmap, which can be any size you need.

If we extend node_possible_map, I think we would also have to extend several
other tables as well. For example, it is possibly that code that finds
a node in the node_possible_map may also expect to find the node in
the slit, node_to_cpu_mask, nid_to_pxm_map, ...

All of this could be done but it requires a lot more code & testing than
Deans's patch and it would still be a hack that would be deleted later when
we get the _real_ solution that involve BIOS & ACPI changes. I'd rather
minimize any new temporary hacks & focus on the longer term solution. 

In fact, I posted part of what you are suggesting last week:
	http://marc.theaimsgroup.com/?l=linux-ia64&m4133701316260&w=2

This patch extends the size of the node_possible_map. The patch adds an
option to support up to 1024 cpu/memory nodes on SN systems. The patch does
not yet address the problem of IO nodes. For that, we need ACPI3.0 and
a new BIOS. The patch, by necessity, is also SN specific until we get
to ACPI3.0.

This patch has not yet been accepted - hopefully a candidate for 2.6.17.
However, this is the first step in the direction that you are suggesting.

In the interim, we need a fix in 2.6.16 (we have problems on our large systems
without it) & I think Dean's patch should be ok.  It is a 1-line fix, 
is used in only one spot & is not likely to be copied to other places.


> 
> > > If not, what "for_each_XXX" macro are you planning to use when
> > > you have ACPI 3.0?
> > 
> > Not sure yet because ACPI 3.0 is still way off in the future.  We
> > will know more when that time comes.
> 
> If you think for_each_node() is the correct interface to use here,
> just use it, and make node_possible_mask large enough.  That means
> you might need some glue code deal with the fact that ACPI 2.0
> can't populate the whole thing, but that's not a problem.
> 
> If you think you need something other than for_each_node(), why
> not just take a stab at defining the correct interface now, and
> fix it later if you need to?  I think that's better than putting
> in something that you *know* will need to be changed later.

I expect that once IO nodes are fully supported by ACPI, we will use the
standard "for_each_node" macros. It's possible that we may want to
introduce a "for_each_node_with_memory" macro (there is already a
"for_each_node_with_cpus" macro). A lot more design is required...


--- Jack

