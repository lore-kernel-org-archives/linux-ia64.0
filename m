From: Dan Pop <Dan.Pop@cern.ch>
Date: Tue, 19 Sep 2000 15:45:35 +0000
Subject: Re: [linux-ia64] Predication vs. Branching
Message-Id: <marc-linux-ia64-105590678205505@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205504@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205504@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


On Tue, 19 Sep 2000, Jonathan Case Nicklin wrote:

> Dan Pop wrote:
> 
> > On Tue, 19 Sep 2000, Jonathan Case Nicklin wrote:
> >
> > > This might not be the appropriate forum, but what the heck. Does anyone
> > > have
> > > a definitive answer on what happens to predicated instructions that are
> > > not
> > > executed (ie where in the pipeline are they discarded).
> >
> > According to the manual, they become NOPs of the appropriate type.
> >
> > Dan
> 
> Dan,
>     But When? Do they always consume execution resources or are they
> dropped as soon as their predicate dependency is fulfilled... assuming their
> 
> dependent predicate evaluates false and that there are predicate dependent
> instructions in the pipeline.

According to the Itanium microarchitecture manual, they do consume
execution resources, by their mere presence in the bundle.

I.e. the following code still keeps the CPU busy for one cycle:

{.mib
	nop.m	0
	nop.i	0
	nop.b	0
}
{.mib
	nop.m   0
	nop.i   0
	nop.b   0
}

No execution unit can be assigned to a more useful instruction during
that cycle.

Replacing the NOPs by predicated away instructions of the
corresponding types shouldn't change anything.

Dan



