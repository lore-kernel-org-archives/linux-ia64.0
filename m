From: Jonathan Case Nicklin <nicklin@missioncriticallinux.com>
Date: Tue, 19 Sep 2000 12:18:08 +0000
Subject: Re: [linux-ia64] Predication vs. Branching
Message-Id: <marc-linux-ia64-105590678205504@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Dan Pop wrote:

> On Tue, 19 Sep 2000, Jonathan Case Nicklin wrote:
>
> > This might not be the appropriate forum, but what the heck. Does anyone
> > have
> > a definitive answer on what happens to predicated instructions that are
> > not
> > executed (ie where in the pipeline are they discarded).
>
> According to the manual, they become NOPs of the appropriate type.
>
> Dan

Dan,
    But When? Do they always consume execution resources or are they
dropped as soon as their predicate dependency is fulfilled... assuming their

dependent predicate evaluates false and that there are predicate dependent
instructions in the pipeline.

-Jonathan Nicklin


