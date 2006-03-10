From: "Luck, Tony" <tony.luck@intel.com>
Date: Fri, 10 Mar 2006 17:28:25 +0000
Subject: RE: Fix race in the accessed/dirty bit handlers
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F05EC7B9F@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603071901420.2463@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Please consider the second issue I mentioned about the "itc":
> Making sure that an external purge request will not be missed by our new
> translation. See also on page 3:127:

While this is true, I'm still not seeing how this can cause
a problem (but I didn't see the problem that Christoph just
found that started this whole thread in six years of looking
at this code, so I'm willing to accept that I may be missing
something).

If another processor has a purge floating out there on the
bus at this time, it would be because that other processor
was making some change to this mapping.  In which case it
would have executed:

 *pte = new_value
 ptc

Are you saying that these events may become visible to the
processor that is executing the dirty_bit handler in either
order, so that you are worried we'll see the old *pte value
when we do the load, but miss the purge because we didn't
wait for the itc.d to complete before we did the load?

-Tony
