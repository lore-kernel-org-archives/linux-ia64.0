From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 25 Sep 2003 06:23:51 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106447099207495@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

At some point in the past, I wrote:
>> This sounds like it has progressively more commonality with CKRM; the
>> notion is of a workclass, not of a purely cpu-oriented notion.

On Wed, Sep 24, 2003 at 11:09:58PM -0700, Paul Jackson wrote:
> I _knew_ I shouldn't have thrown in that paragraph that began "There are
> also some resource management capabilities, ...".
> There are two aspects to CKRM - a common classification of service levels,
> and hooks in each scheduler of resources to respect those levels.
> These cpusets, either as proposed, or possible fancier forms that also
> manage memory, do not replace, cannot be replaced by, and do not compete
> with CKRM.  Rather they cooperate with CKRM, and represent one more
> place, along side network drivers, schedulers and memory allocators,
> that eventually will want to respect CKRM service levels.
> The point of _this_ subthread was to consider whether this could more or
> less entirely be done in user space.  The two aspects even of Simon's
> current proposal that I don't see can be done in user space are the
> migration, and the permission model.

Well, the thing is, CKRM essentially has the cross-resource bits and
makes up some group that can be joined and departed from and inherited
and so on with all the right knobs. So the question is "what does CKRM
lack that cpusets needs?" It sounds to me like the major point missing
is "nobody else can touch this cpu" if I read cpusets properly.


-- wli
