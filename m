From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 23 Nov 2005 23:22:50 +0000
Subject: Re: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling
Message-Id: <1132788170.13942.2.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05080A09@scsmsx401.amr.corp.intel.com>
	<883776988128f1657bc6dbd7d993cae1@cl.cam.ac.uk>
In-Reply-To: <883776988128f1657bc6dbd7d993cae1@cl.cam.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Cc: "Tian, Kevin" <kevin.tian@intel.com>, Xen Mailing List <xen-devel@lists.xensource.com>, linux-ia64@vger.kernel.org, Tony Breeds <tony@bakeyournoodle.com>, djm@kirby.fc.hp.com, "Luck, Tony" <tony.luck@intel.com>, David Mosberger-Tang <David.Mosberger@acm.org>

On Wed, 2005-11-23 at 15:37 +0000, Keir Fraser wrote:
> On 23 Nov 2005, at 15:07, Luck, Tony wrote:
> 
> >> It's not hard to support arbitrary alignment, at the cost of burning
> >> some space. We should probably do that.
> >
> > The "we" in that last sentence is the Xen team ... referring
> > to making fixes to xmalloc?
> 
> Correct. But I've thought more on it and I guess that actually the 
> number of cases where we have structures with alignment requirements 
> stricter than SMP_CACHE_BYTES will be very small. In fact I can't think 
> of any in Xen right now. :-)

Right, which was why the original BUG_ON() which started this
discussion...

Rusty.
-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman

