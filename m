From: Paul Jackson <pj@sgi.com>
Date: Thu, 25 Sep 2003 06:38:04 +0000
Subject: Re: [Lse-tech] Re: CPUSET Proposal
Message-Id: <marc-linux-ia64-106447204008302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106444308519469@msgid-missing>
In-Reply-To: <marc-linux-ia64-106444308519469@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Well, the thing is, CKRM essentially has the cross-resource bits and
> makes up some group that can be joined and departed from and inherited
> and so on with all the right knobs ...

The hierarchies don't correspond, or do so only accidentally.

That is, cpusets, as proposed, have a hierarchy such that one
cpuset is the child of another if one cpuset describes a subset
of another's CPUs.

At first blush, I don't see a hierarchy of CKRM Classes, rather
just a flat space, say Gold, Silver and Bronze.

  "When all you have is a hammer, the whole world looks like a nail"

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
