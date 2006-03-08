From: Dean Roe <roe@sgi.com>
Date: Wed, 08 Mar 2006 22:02:06 +0000
Subject: Re: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <20060308220206.GA11094@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 06, 2006 at 10:35:19AM -0700, Bjorn Helgaas wrote:
> On Monday 06 March 2006 09:32, Dean Roe wrote:
> > -	for_each_node(cnode) {
> > +	/*
> > +	 * FIXME: replace with cleaner for_each_XXX macro which addresses
> > +	 * both compute and IO nodes once ACPI3.0 is available.
> > +	 */
> > +	for (cnode = 0; cnode < num_cnodes; cnode++) {
> 
> I don't understand this ACPI 3.0 dependency.  Can't you just define
> for_each_XXX() the way you want it, and fill in the bitmask or whatever
> it uses either (a) using ACPI 3.0 data, or (b) some interim hack?
> 
> Bjorn

I can't really tell from your response, so...did you see Jack's explanation
of this?
    http://marc.theaimsgroup.com/?l=linux-ia64&m4141537904761&w=2

Are you saying you *really* want a for_each_sn_cnode() macro?  I guess
we can go that route if necessary...I just prefer the one-line change
rather than changing 4-5 files when we aren't really sure yet what the
final implementation will look like.  I just want to make sure I am reading
you correctly.

Thanks,
Dean

-- 
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com
