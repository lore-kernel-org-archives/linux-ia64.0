From: Paul Jackson <pj@sgi.com>
Date: Fri, 23 Sep 2005 11:18:02 +0000
Subject: Re: Using Cpusets with HyperThreads
Message-Id: <20050923041802.68b3db71.pj@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050923000016.2cc416ac.pj@sgi.com>
In-Reply-To: <20050923000016.2cc416ac.pj@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> how about a system with K sockets per node, L cores per socket and M
> threads per core? ... where K, L and/or M are not necessarily constant?

Though I introduced this note by speaking of A and B sides, the
format of CPU number lists allows for specifying any particular
set of logical processors.

As systems with more varied architectures become available, I
suspect that we will add some convenience options to the cpuset
library and command interfaces, when we see what would be useful.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
