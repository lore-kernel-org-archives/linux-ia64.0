From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Date: Wed, 23 Nov 2005 15:37:07 +0000
Subject: Re: [Xen-devel] __ia64__ ifdef in xmalloc.c: "Fix ar.unat handling forfast paths"
Message-Id: <883776988128f1657bc6dbd7d993cae1@cl.cam.ac.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05080A09@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05080A09@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: "Tian, Kevin" <kevin.tian@intel.com>, Xen Mailing List <xen-devel@lists.xensource.com>, linux-ia64@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Tony Breeds <tony@bakeyournoodle.com>, djm@kirby.fc.hp.com, David Mosberger-Tang <David.Mosberger@acm.org>


On 23 Nov 2005, at 15:07, Luck, Tony wrote:

>> It's not hard to support arbitrary alignment, at the cost of burning
>> some space. We should probably do that.
>
> The "we" in that last sentence is the Xen team ... referring
> to making fixes to xmalloc?

Correct. But I've thought more on it and I guess that actually the 
number of cases where we have structures with alignment requirements 
stricter than SMP_CACHE_BYTES will be very small. In fact I can't think 
of any in Xen right now. :-)

So it makes most sense for ia64 Xen to define SMP_CACHE_BYTES to a 
sensible largeish number irrespective of CONFIG_SMP (after all, how 
many uniproc ia64 systems are there), and solve the general alignment 
problem in xmalloc only if we really need to.

  -- Keir

