From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 25 Sep 2003 06:44:30 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106447222008402@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, I wrote:
>> Well, the thing is, CKRM essentially has the cross-resource bits and
>> makes up some group that can be joined and departed from and inherited
>> and so on with all the right knobs ...

On Wed, Sep 24, 2003 at 11:38:04PM -0700, Paul Jackson wrote:
> The hierarchies don't correspond, or do so only accidentally.
> That is, cpusets, as proposed, have a hierarchy such that one
> cpuset is the child of another if one cpuset describes a subset
> of another's CPUs.
> At first blush, I don't see a hierarchy of CKRM Classes, rather
> just a flat space, say Gold, Silver and Bronze.

It's meant to flatten the hierarchy by using numerical measures of
share to precompute the effect of the hierarchy. A directly hierarchical
data structure representation's traversal is too inefficient to be
tolerated in certain performance-critical codepaths, e.g. schedule().

The hierarchy is meant to be there, just implemented without that
traversal in the scheduler (and elsewhere).


-- wli
