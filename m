From: Paul Jackson <pj@sgi.com>
Date: Thu, 13 May 2004 04:59:43 +0000
Subject: Re: Who's doing what with cpu/memory/node hotplug?
Message-Id: <20040512215943.4c99cefc.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040512205107.16bb82a6.pj@sgi.com>
In-Reply-To: <20040512205107.16bb82a6.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Iam not sure what specifically you are looking for ...

I was looking for the short and sweet overview such as you just
presented ;).  Thanks.

I need to start following this hotplug work because it is next door to
the cpu/memory placement work that I am most focused on, such as
cpusets, led by Simon Derr of Bull, sitting on top of sched_setaffinity
and Andi Kleen's numa work.  A cpuset is a set of cpu and memory
resources that several tasks share, perhaps exclusively (all other
tasks kept out).

At some point, questions such as "what happens when a node is unplugged
from a cpuset" will need to be answered.  And even earlier, "what happens
when a cpu is unplugged that was in a tasks cpus_allowed, or a memory
node unplugged, that was in a vma's list of allowed memory zones."

Or perhaps the answers to these questions are already known ??

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
