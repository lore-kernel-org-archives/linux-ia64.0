From: Dean Roe <roe@sgi.com>
Date: Mon, 06 Mar 2006 16:28:37 +0000
Subject: Re: [PATCH] fix for-loop in sn_hwperf_geoid_to_cnode()
Message-Id: <20060306162837.GA23976@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060303150312.GA32225@sgi.com>
In-Reply-To: <20060303150312.GA32225@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Mar 03, 2006 at 01:52:56PM -0800, Luck, Tony wrote:
> Any ideas on the relative proportions of nodes with/without memory?
> Should we consider renaming "for_each_node()" as "for_each_mnode()"
> (meaning only scan nodes with memory).  That would stop mm/slab.c
> from allocating useless arraycaches for nodes with no memory.  But
> this is turning into a discussion that would have to happen on LKML.

Memory nodes are far more prevalent than IO nodes.  I don't think it
is worth changing this, at least not at this time.


> 
> Perhaps you could add an /*ACPI3.0-FIXME*/ comment (or some such)
> to the loop in Dean's patch as a reminder to fix this later?  That
> might also serve as a clue to any janitor that tries to clean
> up this code back to using "for_each_node()" (and a reminder to
> me to not take such a patch).

I'll add a comment and send out a new patch in a few minutes.

Thanks,
Dean
