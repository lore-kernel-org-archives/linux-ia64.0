From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 28 Feb 2005 17:54:43 +0000
Subject: RE: [Patch 0/3] Page Table Fixups.
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02FC7C37@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050226142250.GB10965@lnx-holt.americas.sgi.com>
In-Reply-To: <20050226142250.GB10965@lnx-holt.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>I originally meant to send these three to you as well
>for inclusion.  Do you want me to repost all of the messages
>or can you pick them up from the mailing list?

I can get them all out of the linux-ia64 mailing list, no need
for explicit copies to me.

>I decided to not do the zero slab allocator because introducing
>node awareness seemed to be a very daunting task and others at
>SGI are already planning work in that area.  With the third patch
>in this set, the need for a node aware slab allocator becomes
>less important as quicklist size is shrunk based upon free
>memory in the system.

This looks like a plausible approach for now ... when the node-aware
slab allocator is up and running we can re-visit the question
of whether to keep the quicklists.

>                            This happens from either cpu idle or
>from tlb_finish_mmu(), which seems to be often enough.

But I'm a little worried about this.  There is no guarantee that
we will *ever* be idle (someone might pin a copy of SETI at a low
nice value to every cpu in the system to soak up all idle cycles).
Calls to tlb_finish_mmu() would be very dependent on what the
application is doing.  Can you take a bit more of a look at this
area ... try to think from the point of view of a malicious user
who would like to grind the system to a halt by tying up all the
memory in the quicklists ... convince me that they can't do much
damage.

-Tony
