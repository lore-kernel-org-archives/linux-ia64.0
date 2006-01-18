From: Matthew Chapman <matthewc@cse.unsw.edu.au>
Date: Wed, 18 Jan 2006 13:14:53 +0000
Subject: Re: [ia64-technical] Re: First Montecito Reference Manual is now available
Message-Id: <20060118131453.GA19788@cse.unsw.EDU.AU>
List-Id: <linux-ia64.vger.kernel.org>
References: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
In-Reply-To: <B8E391BBE9FE384DAA4C5C003888BE6F05701C2A@scsmsx401.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jan 17, 2006 at 11:22:28AM -0800, Luck, Tony wrote:
> 
> > TLB entries are tagged with the hardware thread.  Is there any
> > possibility to override this (I mean, even theoretically)?
> A4) The thread identifier is considered part of the VA to ensure that VA
> and PA aliases between threads do not turn up problems (such as different
> access rights and or accessed/dirty behaviors.  It cannot be undone.

For the record, I'm a little disappointed about this decision not to
make the tagging feature configurable (via an MSR).

Now I agree that thread tagging is the right default, for the benefit of
legacy operating systems that may use CPU-local mappings in a way that
would not be safe if the TLBs weren't thread-tagged.

However, this means that OSs that are aware of the system topology must
nonetheless pay the performance price of a TLB that is effectively
smaller.

It seems to me that, at least at the L2TLB level, the "untagged" model
could be implemented as an alternative at minimal cost;  e.g. OR the
control bit into the tag.  L1TLBs obviously have much tighter timing
constraints, but the technique that is implemented for the L1ITLB would
work in any case.

I'm aware of a couple of architectures that have TLBs shared between
threads without explicit thread-tagging, and I'm sure that there's more
to come...  so this is something that OSs will eventually have to deal
with anyway.

Matt

